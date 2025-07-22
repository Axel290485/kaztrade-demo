#!/bin/bash

# === KONFIGURATION ===
REPO_NAME="agrarplattform"
GITHUB_USER="dein-benutzername"       # ❗️ Anpassen
GITHUB_EMAIL="deine@email.com"       # ❗️ Anpassen
GITHUB_TOKEN="ghp_ABC123..."         # ❗️ GitHub Token mit 'repo' Rechte

# === START ===

echo "🔧 Initialisiere Git-Repo..."
git init

echo "🔧 Setze Benutzerkonfiguration..."
git config user.name "$GITHUB_USER"
git config user.email "$GITHUB_EMAIL"

echo "📂 Füge Dateien hinzu..."
git add .

echo "✅ Erstelle Commit..."
git commit -m "Initial Commit für Agrarplattform"

echo "🌐 Verbinde mit GitHub..."
git remote add origin https://$GITHUB_TOKEN@github.com/$GITHUB_USER/$REPO_NAME.git

echo "🚀 Push zum Repository..."
git branch -M main
git push -u origin main

echo "🎉 Fertig! Repository unter: https://github.com/$GITHUB_USER/$REPO_NAME"
