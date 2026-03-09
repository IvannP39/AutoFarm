FROM python:3.11-slim

WORKDIR /app
RUN apt-get update && apt-get install -y sqlite3 && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# RPi.GPIO seulement sur ARM (Pi) — ignoré silencieusement ailleurs
RUN pip install RPi.GPIO 2>/dev/null || true

COPY main.py .
EXPOSE 8080
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]