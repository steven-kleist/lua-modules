local request = {
  _VERSION     = "0.0.1",
  _DESCRIPTION = "",
  _LICENSE     = [[
    MIT LICENSE

    * Copyright (c) 2020 Steven Kleist

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]],
}

require "strong"

--------------------------------------------------------------------------------
-- local functions
--------------------------------------------------------------------------------
local function hex_to_char(x)
  return string.char(tonumber(x, 16))
end


local function unescape(url)
  return url:gsub("%%(%x%x)", hex_to_char)
end


local function parse_querystring(str)
  local result = {}
  if type(str) == "string" then
    local str1 = str:split("&", true)
    for i,v in ipairs(str1) do
      local str2 = v:split("=", true)
      result[str2[1]] = unescape(str2[2])
    end
  end
  return result
end


local function parse_headers(str)
  local result = {}
  if type(str) == "string" then
    local str1 = str:lines("[\r\n]+", true)
    for i,v in ipairs(str1) do
      if v ~= "" then
        local str2 = v:split(": ", true)
        result[str2[1]] = (str2[2]):lstrip()
      end
    end
  end
  return result
end


local function parse_body(str)
  local result = {}
  if type(str) == "string" and #str >= 1 then
    local body_type = os.getenv("CONTENT_TYPE")
    local body_parts = body_type:split("%;%s?")
    
    -- parsing application/x-www-form-urlencoded data
    if body_type == "application/x-www-form-urlencoded" then
      local str1 = str:split("&", true)
      for i,v in ipairs(str1) do
        local str2 = v:split("=", true)
        result[str2[1]] = unescape(str2[2])
      end
    
    elseif body_parts[1] == "multipart/form-data" then
    
    
    elseif body_type == "text/json" then
      local json = require "json"
      result = json.decode(str)
    end
    
    
  end
  return result
end


--------------------------------------------------------------------------------
-- Instance functions
--------------------------------------------------------------------------------
function request.new()
  local req = {
    headers = parse_headers(os.getenv("ALL_HTTP")),
    body = os.getenv("REQUEST_METHOD") == "POST" and parse_body(io.read("*all")) or nil,
    cookies = {},
    method = os.getenv("REQUEST_METHOD"),
    path = (string.split(os.getenv("URL"), "?", true))[1],
    query = parse_querystring(os.getenv("QUERY_STRING")),
    secure = os.getenv("HTTPS") == "on" and true or false,
  }
  return req
end


--------------------------------------------------------------------------------
-- Returning request object
--------------------------------------------------------------------------------
return request