FROM python:3.12-slim

WORKDIR /app

# graphify needs poppler for PDF reads (same as markitdown)
RUN apt-get update && apt-get install -y --no-install-recommends \
    poppler-utils \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install graphify + FastAPI runtime
RUN pip install --no-cache-dir \
    graphifyy \
    fastapi \
    uvicorn[standard] \
    python-multipart

COPY main.py .

# Health check uses the /health endpoint which probes graphify availability
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')"

EXPOSE 8080

# Single worker by default — graphify can be CPU-heavy and we don't want
# multiple builds racing the same Anthropic API key. Scale horizontally
# (multiple service instances) instead of vertically.
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080", "--workers", "1"]
