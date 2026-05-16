FROM python:3.12-slim

WORKDIR /app

# PDF conversion needs poppler (pdftotext fallback)
RUN apt-get update && apt-get install -y --no-install-recommends \
    poppler-utils \
    && rm -rf /var/lib/apt/lists/*

# Install MarkItDown with PDF, Word, PowerPoint, Excel support
RUN pip install --no-cache-dir \
    'markitdown[pdf,docx,pptx,xlsx]' \
    fastapi \
    uvicorn[standard] \
    python-multipart

COPY main.py .

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')"

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080", "--workers", "2"]
