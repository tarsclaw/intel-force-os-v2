"""
Intel Force OS — MarkItDown microservice
Wraps Microsoft MarkItDown with a FastAPI HTTP interface.
Called from the Next.js dashboard when HR Lead uploads a handbook PDF.
"""

from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from markitdown import MarkItDown
import tempfile
import os
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Intel Force OS — MarkItDown",
    description="Converts HR handbooks (PDF, Word, PowerPoint, Excel) to structured markdown",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Lock down to dashboard domain in production
    allow_methods=["POST", "GET"],
    allow_headers=["*"],
)

ALLOWED_EXTENSIONS = {".pdf", ".docx", ".pptx", ".xlsx", ".html", ".txt"}
MAX_FILE_SIZE = 50 * 1024 * 1024  # 50 MB

md_converter = MarkItDown(enable_plugins=False)


@app.get("/health")
def health():
    return {"status": "ok", "service": "markitdown"}


@app.post("/convert")
async def convert(file: UploadFile = File(...)):
    """
    Convert an uploaded document to markdown.
    Returns the full markdown string plus metadata.
    """
    suffix = os.path.splitext(file.filename or "")[1].lower()
    if suffix not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail=f"Unsupported file type: {suffix}. Allowed: {', '.join(ALLOWED_EXTENSIONS)}",
        )

    content = await file.read()
    if len(content) > MAX_FILE_SIZE:
        raise HTTPException(status_code=413, detail="File too large (max 50 MB)")

    logger.info("Converting %s (%d bytes)", file.filename, len(content))

    tmp_path = None
    try:
        with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as tmp:
            tmp.write(content)
            tmp_path = tmp.name

        result = md_converter.convert(tmp_path)
        markdown = result.text_content

        # Basic stats to help the section parser
        line_count = markdown.count("\n")
        heading_count = sum(1 for line in markdown.splitlines() if line.startswith("#"))

        logger.info(
            "Converted %s: %d chars, %d lines, %d headings",
            file.filename,
            len(markdown),
            line_count,
            heading_count,
        )

        return {
            "markdown": markdown,
            "filename": file.filename,
            "chars": len(markdown),
            "lines": line_count,
            "headings": heading_count,
        }

    except Exception as e:
        logger.error("Conversion failed for %s: %s", file.filename, str(e))
        raise HTTPException(status_code=500, detail=f"Conversion failed: {str(e)}")

    finally:
        if tmp_path and os.path.exists(tmp_path):
            os.unlink(tmp_path)
