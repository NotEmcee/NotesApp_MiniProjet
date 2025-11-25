# Image Python légère
FROM python:3.9-slim

# Répertoire de travail dans le conteneur
WORKDIR /app

# Installation des dépendances
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copie du code source
COPY app.py .

# Exposition du port
EXPOSE 5000

# Lancement de l'application
CMD ["python", "app.py"]