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
local function parse_querystring(str)
  local result = {}
  if type(str) == "string" then
    local str1 = str:split("&", true)
    for i,v in ipairs(str1) do
      local str2 = v:split("=", true)
      result[str2[1]] = str2[2]
    end
  end
  return result
end


local function parse_headers(str)

end


--------------------------------------------------------------------------------
-- Instance functions
--------------------------------------------------------------------------------
function request.new()
  local req = {
    params = {},
    body = nil,
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