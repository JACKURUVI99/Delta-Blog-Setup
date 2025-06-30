local socket = require("socket")
local luasql = require("luasql.mysql")

-- Database connection params (change if needed)
local DB_NAME = os.getenv("MYSQL_DATABASE") or "chatdb"
local DB_USER = os.getenv("MYSQL_USER") or "chatuser"
local DB_PASS = os.getenv("MYSQL_PASSWORD") or "chatpass"
local DB_HOST = os.getenv("MYSQL_HOST") or "127.0.0.1"
local DB_PORT = tonumber(os.getenv("MYSQL_PORT")) or 3306

-- Connect to database
local env = assert(luasql.mysql())
local conn = assert(env:connect(DB_NAME, DB_USER, DB_PASS, DB_HOST, DB_PORT))

print("[✓] Connected to MySQL")

-- Server config
local server = assert(socket.bind("*", 8888))
local clients = {}

print("[✓] Chat server running on port 8888...")

local function log(msg)
  local f = io.open("server.log", "a")
  f:write(os.date("%Y-%m-%d %H:%M:%S") .. " - " .. msg .. "\n")
  f:close()
end

local function send_line(sock, line)
  sock:send(line .. "\n")
end

local function broadcast(room, msg, sender)
  for _, c in ipairs(clients) do
    if c.room == room and c.sock ~= sender then
      local ok, err = c.sock:send(msg .. "\n")
      if not ok then
        log("Failed to send message to " .. (c.username or "unknown") .. ": " .. tostring(err))
      end
    end
  end
end

local function add_message(username, room, msg)
  local safe_msg = msg:gsub("'", "''") -- basic escape for '
  local sql = string.format("INSERT INTO messages (username, room, message) VALUES ('%s', '%s', '%s')", username, room, safe_msg)
  local res, err = conn:execute(sql)
  if not res then
    log("DB insert error: " .. tostring(err))
  end
end

local function auth_user(sock)
  send_line(sock, "Username:")
  local username = sock:receive("*l")
  if not username then return nil end

  send_line(sock, "Password:")
  local password = sock:receive("*l")
  if not password then return nil end

  -- Check if user exists
  local cursor, err = conn:execute("SELECT password FROM users WHERE username='" .. username .. "'")
  if not cursor then
    log("DB query error: " .. tostring(err))
    send_line(sock, "[-] DB error. Try again later.")
    return nil
  end

  local row = cursor:fetch({}, "a")
  cursor:close()

  if row then
    if row.password == password then
      send_line(sock, "[+] Login successful!")
      return username
    else
      send_line(sock, "[-] Incorrect password")
      return nil
    end
  else
    -- Create user
    local res, err = conn:execute(string.format(
      "INSERT INTO users (username, password) VALUES ('%s', '%s')",
      username, password
    ))
    if res then
      send_line(sock, "[+] Account created!")
      return username
    else
      log("DB insert user error: " .. tostring(err))
      send_line(sock, "[-] Could not create account.")
      return nil
    end
  end
end

local function handle_client(c)
  local sock = c.sock
  sock:settimeout(nil) -- blocking mode

  local username = auth_user(sock)
  if not username then
    sock:close()
    return
  end
  c.username = username

  send_line(sock, "Enter room name:")
  local room = sock:receive("*l")
  if not room or room == "" then room = "main" end
  c.room = room

  -- Insert room if not exists
  conn:execute(string.format("INSERT IGNORE INTO rooms (name, created_by) VALUES ('%s', '%s')", room, username))

  broadcast(room, "[*] " .. username .. " joined the room", sock)
  send_line(sock, "[Room] Users: " .. table.concat(
    (function()
      local ulist = {}
      for _, cl in ipairs(clients) do
        if cl.room == room then table.insert(ulist, cl.username) end
      end
      return ulist
    end)(), ", "
  ))

  while true do
    local line, err = sock:receive("*l")
    if not line then
      if err == "closed" then break end
      sock:settimeout(0.1)
    else
      broadcast(room, username .. ": " .. line, sock)
      add_message(username, room, line)
    end
  end

  sock:close()
  -- Remove from clients list
  for i, client in ipairs(clients) do
    if client == c then
      table.remove(clients, i)
      break
    end
  end
  broadcast(room, "[-] " .. username .. " left the room", nil)
  log(username .. " disconnected.")
end

while true do
  local client_sock = server:accept()
  if client_sock then
    client_sock:settimeout(0)
    local client = {sock = client_sock}
    table.insert(clients, client)

    local co = coroutine.create(function() handle_client(client) end)
    coroutine.resume(co)
  else
    socket.sleep(0.01)
  end
end
