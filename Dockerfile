FROM python:3.9-slim

WORKDIR /app

# Kopiuj requirements i zainstaluj zależności
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Kopiuj kod aplikacji
COPY app.py .

# Expose port
EXPOSE 5000

# Uruchom aplikację
CMD ["python", "app.py"]
