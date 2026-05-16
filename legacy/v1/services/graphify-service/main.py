"""
Intel Force OS — Graphify microservice
Wraps the `graphifyy` Python package with a FastAPI HTTP interface.

Called from services/brain-builder when a tenant's brain needs to be built.
The brain-builder uploads a set of source files; this service runs the full
graphify pipeline (detect → extract → cluster → label) and returns the resulting
graph.json plus token usage so cost can be charged back to the tenant.

Operational notes:
  - Single-tenant per request: each /build call creates an isolated tmp dir.
  - Concurrency: uvicorn --workers controls parallel builds (default 1 to avoid
    the LLM rate-limiting the same Anthropic key from multiple build threads).
  - Timeouts: graphify itself has a 5-min internal cap on the LLM extraction
    step. We set the HTTP timeout client-side at 10 minutes.
"""

import json
import logging
import os
import shutil
import subprocess
import tempfile
import time
from pathlib import Path
from typing import List

from fastapi import FastAPI, UploadFile, File, HTTPException, Form
from fastapi.middleware.cors import CORSMiddleware

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Intel Force OS — Graphify",
    description="Builds per-tenant knowledge graphs from uploaded source files",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Lock down to brain-builder host in production
    allow_methods=["POST", "GET"],
    allow_headers=["*"],
)

ALLOWED_EXTENSIONS = {".md", ".txt", ".pdf", ".html", ".docx"}
GRAPHIFY_BIN = os.environ.get("GRAPHIFY_BIN", "graphify")


@app.get("/health")
def health():
    """Liveness probe — verifies the graphify CLI is reachable."""
    import shutil

    bin_path = shutil.which(GRAPHIFY_BIN)
    available = bin_path is not None

    # Try `--help` (supported); fall back to just checking the binary exists
    version = ""
    if available:
        try:
            result = subprocess.run(
                [GRAPHIFY_BIN, "--help"],
                capture_output=True,
                text=True,
                timeout=5,
            )
            # Pull the first line of help output as a "version" indicator
            version = (result.stdout or result.stderr or "").splitlines()[0][:80] if result.returncode == 0 else ""
        except (FileNotFoundError, subprocess.TimeoutExpired):
            version = ""

    return {
        "status": "ok",
        "service": "graphify",
        "graphify_available": available,
        "graphify_path": bin_path,
        "version": version,
    }


@app.post("/build")
async def build_graph(
    files: List[UploadFile] = File(...),
    tenant_slug: str = Form(...),
    mode: str = Form("default"),
):
    """
    Run graphify over the uploaded source files. Returns the graph JSON plus
    token usage and timing.

    Form fields:
      - files: one or more source files (.md/.txt/.pdf/.html/.docx)
      - tenant_slug: used for logging, written to graphify cost.json
      - mode: "default" or "deep" — passed through to graphify --mode

    Response shape:
      {
        "graph": { ... full graph.json ... },
        "node_count": 1002,
        "edge_count": 1137,
        "community_count": 126,
        "input_tokens": 458292,
        "output_tokens": 12547,
        "duration_ms": 384210
      }
    """
    if not files:
        raise HTTPException(status_code=400, detail="At least one file required")

    # Validate extensions
    for f in files:
        ext = Path(f.filename or "").suffix.lower()
        if ext not in ALLOWED_EXTENSIONS:
            raise HTTPException(
                status_code=400,
                detail=f"Unsupported extension: {ext} (allowed: {sorted(ALLOWED_EXTENSIONS)})",
            )

    started = time.time()
    work_dir = tempfile.mkdtemp(prefix=f"graphify-{tenant_slug}-")
    input_dir = Path(work_dir) / "input"
    input_dir.mkdir(parents=True)

    try:
        # Stage files
        for f in files:
            target = input_dir / Path(f.filename or f"file-{id(f)}").name
            with target.open("wb") as out:
                content = await f.read()
                out.write(content)

        logger.info(
            "[graphify] tenant=%s files=%d staged at %s",
            tenant_slug,
            len(files),
            input_dir,
        )

        # Run graphify (no viz — we only need graph.json)
        cmd = [GRAPHIFY_BIN, str(input_dir), "--no-viz"]
        if mode == "deep":
            cmd.extend(["--mode", "deep"])

        result = subprocess.run(
            cmd,
            cwd=work_dir,
            capture_output=True,
            text=True,
            timeout=600,  # 10 minute cap
        )

        if result.returncode != 0:
            logger.error("[graphify] failed for tenant=%s: %s", tenant_slug, result.stderr)
            raise HTTPException(
                status_code=500,
                detail=f"graphify exited with code {result.returncode}: {result.stderr[:500]}",
            )

        # Read output
        graph_path = Path(work_dir) / "graphify-out" / "graph.json"
        if not graph_path.exists():
            raise HTTPException(status_code=500, detail="graphify did not produce graph.json")

        graph = json.loads(graph_path.read_text())

        # Read cost.json if available for token counts
        cost_path = Path(work_dir) / "graphify-out" / "cost.json"
        input_tokens = 0
        output_tokens = 0
        if cost_path.exists():
            cost_data = json.loads(cost_path.read_text())
            runs = cost_data.get("runs", [])
            if runs:
                input_tokens = runs[-1].get("input_tokens", 0)
                output_tokens = runs[-1].get("output_tokens", 0)

        nodes = graph.get("nodes", [])
        edges = graph.get("links", graph.get("edges", []))
        # community count from analysis.json if present
        analysis_path = Path(work_dir) / "graphify-out" / ".graphify_analysis.json"
        community_count = 0
        if analysis_path.exists():
            analysis = json.loads(analysis_path.read_text())
            community_count = len(analysis.get("communities", {}))
        else:
            # Derive from node community ids
            community_count = len({n.get("community", 0) for n in nodes})

        duration_ms = int((time.time() - started) * 1000)

        logger.info(
            "[graphify] ✓ tenant=%s nodes=%d edges=%d duration=%dms",
            tenant_slug,
            len(nodes),
            len(edges),
            duration_ms,
        )

        return {
            "graph": graph,
            "node_count": len(nodes),
            "edge_count": len(edges),
            "community_count": community_count,
            "input_tokens": input_tokens,
            "output_tokens": output_tokens,
            "duration_ms": duration_ms,
        }

    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=504, detail="graphify timed out (10 minutes)")
    finally:
        # Always clean up
        shutil.rmtree(work_dir, ignore_errors=True)
