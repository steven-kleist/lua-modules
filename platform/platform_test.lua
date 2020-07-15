local test = require "simple_test"
local platform = require "platform"
local semver = require "semver"

test('platform.engine.version == semver("5.1")', function(t)
    local v = platform.engine.version
    local v_should = semver("5.1")
    t.ok(v_should == semver(v))
end)