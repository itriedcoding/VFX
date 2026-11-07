--[[
	Live update check.

	Concatenated after tools/mock.lua with `LIVE_HTTP` seeded from real GitHub
	responses fetched by tools/release-check.js. This runs the exact Updater
	code the plugin runs - same validation, same fallback, same version
	comparison - so the output is what the in-Studio panel would show.
]]

local Version = require(root.Core.Version)
local Updater = require(root.Core.Updater)

local settings = {}
local pluginStub = {
	GetSetting = function(_, key)
		return settings[key]
	end,
	SetSetting = function(_, key, value)
		settings[key] = value
	end,
}

local updater = Updater.new(pluginStub, makeNode("VFXStudio", "Folder", nil))
local info = updater:check()

local function clean(value: any): string
	return (string.gsub(tostring(value or ""), "\n", " "))
end

print("STATE=" .. clean(updater.state))
print("ERROR=" .. clean(updater.lastError))
print("INSTALLED=" .. clean(updater:installedVersion()))
if info then
	print("SOURCE=" .. clean(info.source))
	print("LATEST=" .. clean(info.version))
	print("MANIFEST=" .. clean(info.manifestUrl))
	print("URL=" .. clean(info.url))
	print("NOTES=" .. clean(info.notes))
	print("UPDATE=" .. tostring(updater:hasUpdate()))
else
	print("UPDATE=false")
end
print("REQUESTS=" .. tostring(#MOCK_HTTP.requests))
