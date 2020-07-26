package.path = table.concat({
  [[C:\Host\lua-modules\?.lua]],
  [[C:\Host\lua-modules\?\init.lua]],
  package.path
}, ';')

local test = require "simple_test"
local fs = require "fs"


test('get env var from file', function(t)
  
  local dotenv = require "dotenv"
  
  local env = dotenv.load(fs.currentdir() .. [[\dotenv\.env]])
  
  t.ok(env['LOGIN_NAME'] == 'stevenkl', 'passed!')
end)