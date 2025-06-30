#!/bin/bash
echo "[+] Initializing MariaDB for chat server..."

read -s -p "Enter root MariaDB password: " rootpass
echo

mysql -u root -p"$rootpass" <<EOF
DROP USER IF EXISTS 'chatuser'@'localhost';
CREATE USER 'chatuser'@'localhost' IDENTIFIED BY 'chatpass';
CREATE DATABASE IF NOT EXISTS chatdb;
GRANT ALL PRIVILEGES ON chatdb.* TO 'chatuser'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "[✓] Chat database and user 'chatuser' set up successfully."
