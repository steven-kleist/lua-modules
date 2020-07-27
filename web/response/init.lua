local response = {
  _VERSION = "0.0.1",
  _DESCRIPTION = "",
  _LICENSE = [[]],
}

require "strong"
local json = require "json"
local etlua = require "etlua"


local http_status = {
  [100] =	"Continue",
  [101] =	"Switching Protocols",
  [102] =	"Processing",
  [200] =	"OK",
  [201] =	"Created",
  [202] =	"Accepted",
  [203] =	"Non Authoritative Information",
  [204] =	"No Content",
  [205] =	"Reset Content",
  [206] =	"Partial Content",
  [207] =	"Multi-Status",
  [300] =	"Multiple Choices",
  [301] =	"Moved Permanently",
  [302] =	"Moved Temporarily",
  [303] =	"See Other",
  [304] =	"Not Modified",
  [305] =	"Use Proxy",
  [307] =	"Temporary Redirect",
  [308] =	"Permanent Redirect",
  [400] =	"Bad Request",
  [401] =	"Unauthorized",
  [402] =	"Payment Required",
  [403] =	"Forbidden",
  [404] =	"Not Found",
  [405] =	"Method Not Allowed",
  [406] =	"Not Acceptable",
  [407] =	"Proxy Authentication Required",
  [408] =	"Request Timeout",
  [409] =	"Conflict",
  [410] =	"Gone",
  [411] =	"Length Required",
  [412] =	"Precondition Failed",
  [413] =	"Request Entity Too Large",
  [414] =	"Request-URI Too Long",
  [415] =	"Unsupported Media Type",
  [416] =	"Requested Range Not Satisfiable",
  [417] =	"Expectation Failed",
  [418] =	"I'm a teapot",
  [419] =	"Insufficient Space on Resource",
  [420] =	"Method Failure",
  [422] =	"Unprocessable Entity",
  [423] =	"Locked",
  [424] =	"Failed Dependency",
  [428] =	"Precondition Required",
  [429] =	"Too Many Requests",
  [431] =	"Request Header Fields Too Large",
  [500] =	"Server Error",
  [501] =	"Not Implemented",
  [502] =	"Bad Gateway",
  [503] =	"Service Unavailable",
  [504] =	"Gateway Timeout",
  [505] =	"HTTP Version Not Supported",
  [507] =	"Insufficient Storage",
  [511] =	"Network Authentication Required",
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