# @intelforce/graphify-service

FastAPI wrapper around the [`graphifyy`](https://pypi.org/project/graphifyy/) Python package.

Mirrors `services/markitdown` — same pattern, same Docker base, same health-check shape.

## Why a service?

The dashboard (Next.js) and brain-builder (Node) are TypeScript. graphify is Python. Rather than bundle a Python runtime alongside Node, we run graphify as its own HTTP service. Brain-builder POSTs source files to `/build` and gets back a graph.

Trade-off accepted: one more service to operate, but cleaner deployment / scaling / language separation.

## Endpoints

### `GET /health`

Liveness probe. Verifies `graphify --version` resolves. Returns:

```json
{ "status": "ok", "graphify_available": true, "version": "1.x.x" }
```

### `POST /build`

Multipart form upload. Run graphify over the supplied files.

```bash
curl -X POST http://graphify-service:8080/build \
  -F "tenant_slug=acme-dental" \
  -F "files=@handbook.pdf" \
  -F "files=@policies.md"
```

Returns:

```json
{
  "graph": { "nodes": [...], "edges": [...], "communities": {...} },
  "node_count": 1002,
  "edge_count": 1137,
  "community_count": 126,
  "input_tokens": 458292,
  "output_tokens": 12547,
  "duration_ms": 384210
}
```

## Deploy

### Local

```bash
cd services/graphify-service
docker build -t intelforce/graphify-service .
docker run -p 8080:8080 \
  -e ANTHROPIC_API_KEY=sk-ant-... \
  intelforce/graphify-service
```

### Production

Recommended hosts in priority order:
1. **Fly.io** — single-region machine, scale-to-zero on idle, fastest cold-start
2. **Railway** — similar profile to Fly, simpler ops
3. **Cloudflare Containers** — keeps everything in Cloudflare; newer offering

Whichever you pick: set `ANTHROPIC_API_KEY` and (if needed) configure a bearer token for the brain-builder to authenticate. Lock `allow_origins` in `main.py` to the brain-builder's outbound IP / hostname.

## Cost

graphify drives Anthropic costs (extraction step uses Claude). Token usage is returned in the `/build` response so the brain-builder can write it to `ops.costs` and bill the right tenant.
