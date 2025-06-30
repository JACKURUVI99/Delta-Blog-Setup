local socket = require("socket")
local host, port = "localhost", 8888
local client = assert(socket.tcp())
client:connect(host, port)
client:settimeout(0)

local function readline()
  local line = ""
  while true do
    local chunk, err = client:receive(1)
    if chunk then
      if chunk == "\n" then break end
      line = line .. chunk
    elseif err == "timeout" then
      socket.sleep(0.01)
    else
      break
    end
  end
  return line
end

while true do
  local line = readline()
  if line and #line > 0 then
    print(line)
    if line:find("Username:") or line:find("Password:") then
      local input = io.read()
      client:send(input .. "\n")
    end
  end
end
