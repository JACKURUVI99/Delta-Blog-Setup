#!/bin/bash

# Config
DB_NAME="chatdb"
DB_USER="chatuser"
DB_PASS="chatpass"
DB_HOST="localhost"
DB_PORT=3306
SQL_SCHEMA="/Delta-Blog-Setup/server/db_setup.sql"
SERVER_DIR="/Delta-Blog-Setup/server"
SERVER_SCRIPT="server.lua"
SERVER_PORT=8888

# Prompt for root MariaDB password once
read -sp "Enter MariaDB root password: " ROOT_PASS
echo

# Step 1: Initialize DB user and database
echo "[+] Setting up database and user..."

mysql -u root -p"$ROOT_PASS" <<EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;
DROP USER IF EXISTS '$DB_USER'@'$DB_HOST';
CREATE USER '$DB_USER'@'$DB_HOST' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'$DB_HOST';
FLUSH PRIVILEGES;
EOF

if [ $? -ne 0 ]; then
  echo "[-] Failed to setup database or user."
  exit 1
fi

# Step 2: Import DB schema
echo "[+] Importing database schema..."
mysql -u root -p"$ROOT_PASS" $DB_NAME < "$SQL_SCHEMA"

if [ $? -ne 0 ]; then
  echo "[-] Failed to import database schema."
  exit 1
fi

# Step 3: Kill process on server port (if any)
echo "[+] Checking for running chat server on port $SERVER_PORT..."
PID=$(sudo lsof -t -i:$SERVER_PORT)
if [ -n "$PID" ]; then
  echo "[+] Killing process $PID on port $SERVER_PORT..."
  sudo kill $PID
fi

# Step 4: Export environment variables for Lua server
export MYSQL_USER="$DB_USER"
export MYSQL_PASSWORD="$DB_PASS"
export MYSQL_DATABASE="$DB_NAME"
export MYSQL_HOST="$DB_HOST"
export MYSQL_PORT="$DB_PORT"

# Step 5: Start chat server
echo "[+] Starting Lua chat server..."
cd "$SERVER_DIR"
exec lua "$SERVER_SCRIPT"
