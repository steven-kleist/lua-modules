local response = {
  _VERSION = "0.0.1",
  _DESCRIPTION = "",
  _LICENSE = [[]],
}

require "strong"
local json = require "json"
local etlua = require "etlua"


local http_status = {
  [200] = "OK",
  [404] = "Not Found",
}


local response_ = {
  buffer = {
    status = "",
    head = {},
    body = {},
  },
  renderer = etlua,
  views = os.getenv("APP_VIEWS"),
}

-------------------------------------------------------------------------------
-- member functions
-------------------------------------------------------------------------------
function response:send()
  local data = ""
  
  data = table.concat({
    response_.buffer.status,
    (table.concat(response_.buffer.head, "\r\n")),
    "",
    (table.concat(response_.buffer.body, "\r\n"))
  }, "\r\n")
  return data
end


function response:status(status)
  status = type(status) == "number" and status or tonumber(status)
  if not status then
    return error("[response:status] {status} not convertable to number!")
  end
  
  response_.buffer.status = "HTTP/1.1 %d %s" % {status, http_status[status]}
  
  return self
  
end


function response:render(view, data)
  local tpl_data = io.open(response_.views .. [[\%s.html]] % view):read("*a")
  local tpl = etlua.compile(tpl_data)
  
  table.insert(response_.buffer.body, tpl(data))
  return self
end


function response:json(content)
  local data = ""
  if type(content) == "table" then
    data = json.encode(content)
  else
    data = content
  end
  self:header("Content-Type", "application/json")
  table.insert(response_.buffer.body, data)
  
  return self
end


function response:cookie(name, value, options)
  local cookie = "Set-Cookie: %s=%s" % {name, value}
  local opts   = ""
  if options ~= nil then
    opts = table.concat(options, "; ")
  end
  table.insert(response_.buffer.head, cookie .. (opts ~= "" and "; " .. opts or ""))
  return self
end


function response:header(name, value)
  table.insert(response_.buffer.head, "%s: %s" % {name, value})
  return self
end




-------------------------------------------------------------------------------
-- Return module
-------------------------------------------------------------------------------
return response