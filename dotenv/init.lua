-------------------------------------------------------------------------------
-- module declaration
-------------------------------------------------------------------------------
local dotenv = {
  _VERSION = "0.0.1";
  _DESCRIPTION = "Module for .env management.",
  _LICENSE = [[
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


-------------------------------------------------------------------------------
-- local functions
-------------------------------------------------------------------------------
local function parse_env(data)
  local result = {}
  local lines = data:lines(true)
  for i,v in ipairs(lines) do
    if v ~= "" or v:startsWith("#") == false then
      local parts = v:split('=', true)
      local key, value = parts[1], ""
      if #parts > 2 then
        table.concat(parts, '=', 2)
      else
        value = parts[2]
      end
      
      result[key] = value
    end
  end
  
  return result
end


local function load_file(path)
  local handle = io.open(path, "r")
  if handle ~= nil then
    local content = handle:read("*a")
    handle:close()
    return content
  end
  
  return error("File " .. path .. " not found.")
end



-------------------------------------------------------------------------------
-- module functions
-------------------------------------------------------------------------------
function dotenv.load(filepath)
  local path = filepath ~= nil and filepath or [[.\.env]]
  local env_content = load_file(path)
  return parse_env(env_content)
end



-------------------------------------------------------------------------------
-- Returning module
-------------------------------------------------------------------------------
return dotenv