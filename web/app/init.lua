local app = {
  _VERSION = "0.0.1",
  _DESCRIPTION = "",
  _LICENSE = [[]],
}

local app_ = {}
app_.router = require "router"

--app.handler  = require "web.handler.cgi"
app.request  = require "web.request"
app.response = require "web.response"

-- Route[] ~ { method = "GET", path = "/some-path", action = function()end }
app.routes   = {}
app.models   = {}
app.renderer = {}
app.views    = {}

setmetatable(app, app_)
-------------------------------------------------------------------------------
-- member functions
-------------------------------------------------------------------------------
function app:get(path, action)
  if type(path) ~= "string" then return error("[app:get] {path} must be string!") end
  app_.router:get(path, action)
  return self
end


function app:post(path, action)
  if type(path) ~= "string" then return error("[app:get] {path} must be string!") end
  app_.router:get(path, action)
  return self
end


function app:use(middleware)
  
end


function app:handle_request()
  local ok, data = app_.router:execute()
  if ok then
    print(self.response:finish())
  else
    print("Error.")
  end
  
end


-------------------------------------------------------------------------------
-- return app
-------------------------------------------------------------------------------
return app