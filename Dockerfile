FROM python:3.9-slim

# Metadane
LABEL maintainer="Your Name"
LABEL description="Simple Python App for Jenkins Demo"

# Ustaw zmienne środowiskowe
ENV APP_ENV=production
ENV PYTHONUNBUFFERED=1

# Utwórz użytkownika aplikacji
RUN useradd --create-home --shell /bin/bash app
WORKDIR /app

# Skopiuj requirements i zainstaluj zależności
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Skopiuj kod aplikacji
COPY app.py .

# Zmień właściciela plików
RUN chown -R app:app /app
USER app

# Expose port
EXPOSE 5000

# Uruchom aplikację
CMD ["python", "app.py"]
