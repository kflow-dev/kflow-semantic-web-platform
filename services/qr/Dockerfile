FROM python:3.11-slim

WORKDIR /app
RUN pip install fastapi uvicorn qrcode[pil]

COPY app.py .

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "7000"]
