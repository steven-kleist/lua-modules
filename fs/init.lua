local fs = {
  _VERSION    = "0.0.1",
  _DESCRIPTION = "Simple filesystem module for Lua and LuaScript (Windows).",
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



-- Detecting platform and runtime
local isWindows = package.config:sub(1,1) == "\\"
local sep = package.config:sub(1, 1)
local isLuaScript = _G.WScript and true or false

local obj = {}
if isLuaScript then
  obj.fso = luacom.CreateObject("Scripting.FileSystemObject")
  obj.shell = luacom.CreateObject("WScript.Shell")
end


-------------------------------------------------------------------------------
-- Static methods
-------------------------------------------------------------------------------

-- Returns a table with attributes
function fs.attributes() end


function fs.chdir(path)
  if isWindows then
    if isLuaScript then
      if obj.fso.FolderExists(path) then
        obj.shell.CurrentDirectory = path
      end
    end
    
    return nil
  end
end

function fs.lock_dir(path) end


-- Returns the current workinf directory
function fs.currentdir()
  if isWindows then
    if isLuaScript then
      return obj.shell.CurrentDirectory
    else
      local cwd = io.popen([[@echo/%CD%]]):read("*all"):gsub("%s+$", "")
      return cwd
    end
  end
end

function fs.dir(path, recursive)
  local recurse = recursive and "/S" or ""
  if isWindows then
    local cmd = ('@dir /B %s "%s"'):format(recurse, path)
    local result = io.popen(cmd):read("*a"):gsub("%s+$", "")
    return result:lines(true)
  end
end

function fs.lock() end

function fs.link() end

function fs.mkdir(path)
  local success = false
  if isWindows then
    if isLuaScript then
      local code = os.execute([[cmd /c @mkdir "]] .. path .. [["]])
      if code == 0 then success = true end
    else
      local ok, t, code = os.execute([[cmd /c @mkdir "]] .. path .. [["]])
      if ok and code == 0 then success = true end
    end
  end
  
  return success
end

function fs.rmdir(path)
  local success = false
  if isWindows then
    if isLuaScript then
      local code = os.execute([[cmd /c @rmdir /S /Q "]] .. path .. [["]])
      if code == 0 then success = true end
    else
      local ok, t, code = os.execute([[cmd /c @rmdir /S /Q "]] .. path .. [["]])
      if ok and code == 0 then success = true end
    end
  end
  
  return success
end

function fs.setmode() end

function fs.symlinkattributes() end

function fs.touch(path)
  if isWindows then
    local file = io.open(path)
    if file then
      file:close()
      local result = io.popen([[@copy /b "]]..path..[["+,, "]]..path..[["]])
      result:close()
      
    else
      local file = assert(io.open(path, "a"))
      file:write("")
      file:flush()
      file:close()
    end
  end
end

function fs.unlock() end

--- Finds executable in %PATH%
function fs.find(name)
  if isWindows then
    local result = io.popen([[@where ]] .. name):read("*a"):gsub("%s+$", "")
    return result:lines(true)
  end
end


function fs.basepath(file)
  local match = string.match(file, "^(.*)".. sep .. ".*$", 1)
  return match
end

-------------------------------------------------------------------------------
-- Returning insatnce
-------------------------------------------------------------------------------
return fs