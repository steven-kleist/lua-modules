package.path = table.concat({
  [[C:\Host\lua-modules\?.lua]],
  [[C:\Host\lua-modules\?\init.lua]],
  package.path
}, ';')

local test = require "simple_test"


test('get env var from file', function(t)
  
  local dotenv = require "dotenv"
  
  local env = dotenv.load()
  
  t.ok(env['LOGIN_NAME'] == 'stevenkl', 'passed!')
end)