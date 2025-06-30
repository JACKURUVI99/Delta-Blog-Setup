#!/bin/bash

echo "[+] Pulling latest Docker images..."
docker-compose pull

echo "[+] Restarting containers..."
docker-compose down
docker-compose up -d
bash /Delta-Blog-Setup/scripts/full_chat_setup.sh "YourRootPasswordHere" &
echo "[✓] Deployed."
