--[[
	Version - the single source of truth for the plugin version and the
	release endpoints the updater talks to.

	`VERSION` must match package.json; tools/manifest.js fails the build when
	the two disagree, so a release can never ship a stale version number.
]]

local Version = {}

Version.VERSION = "1.0.2"

Version.REPO = "itriedcoding/VFX"
Version.RELEASES_URL = "https://github.com/itriedcoding/VFX/releases"
Version.API_URL = "https://api.github.com/repos/itriedcoding/VFX/releases/latest"

-- Stable URL that always points at the newest published release.
Version.MANIFEST_URL = "https://github.com/itriedcoding/VFX/releases/latest/download/manifest.json"
Version.MODEL_URL = "https://github.com/itriedcoding/VFX/releases/latest/download/VFXStudio.rbxmx"
Version.PLUGIN_ZIP_URL = "https://github.com/itriedcoding/VFX/releases/latest/download/VFXStudio.zip"

-- Fallback used until the first GitHub release exists (and as a canary for
-- builds that have landed on main but have not been tagged yet).
Version.FALLBACK_MANIFEST_URL = "https://raw.githubusercontent.com/itriedcoding/VFX/main/dist/manifest.json"

Version.MANIFEST_ASSET = "manifest.json"
Version.MODEL_ASSET = "VFXStudio.rbxmx"
Version.PLUGIN_ZIP_ASSET = "VFXStudio.zip"
Version.MIN_CHECK_INTERVAL = 6 * 60 * 60
Version.HTTP_TIMEOUT = 20

Version.MAX_FILES = 400
Version.MAX_TOTAL_BYTES = 8 * 1024 * 1024
Version.MAX_SOURCE_BYTES = 512 * 1024

function Version.clean(value: any): string
	local text = tostring(value or "")
	text = string.gsub(text, "^%s*[vV]%s*", "")
	return (string.gsub(text, "%s+$", ""))
end

--- Parses "1.2.3", "v1.2.3" or "1.2.3-beta.1" into comparable parts.
function Version.parse(value: any): any?
	local text = Version.clean(value)
	if text == "" then
		return nil
	end
	local major, minor, patch, prerelease = string.match(text, "^(%d+)%.(%d+)%.(%d+)%-?([%w%.%-]*)$")
	if not major then
		major, minor, patch = string.match(text, "^(%d+)%.(%d+)$")
		patch = patch or "0"
		prerelease = ""
	end
	if not major or not minor then
		return nil
	end
	return {
		major = tonumber(major) or 0,
		minor = tonumber(minor) or 0,
		patch = tonumber(patch) or 0,
		prerelease = if prerelease ~= nil and prerelease ~= "" then prerelease else nil,
		raw = text,
	}
end

--- Returns -1, 0 or 1. A prerelease sorts below its final release.
function Version.compare(a: any, b: any): number
	local left = Version.parse(a)
	local right = Version.parse(b)
	if not left or not right then
		return 0
	end
	for _, key in ipairs({ "major", "minor", "patch" }) do
		if left[key] ~= right[key] then
			return if left[key] > right[key] then 1 else -1
		end
	end
	if left.prerelease and not right.prerelease then
		return -1
	elseif right.prerelease and not left.prerelease then
		return 1
	elseif left.prerelease and right.prerelease then
		if left.prerelease == right.prerelease then
			return 0
		end
		return if left.prerelease > right.prerelease then 1 else -1
	end
	return 0
end

function Version.isNewer(candidate: any, current: any?): boolean
	return Version.compare(candidate, current or Version.VERSION) > 0
end

function Version.display(value: any?): string
	local text = Version.clean(value or Version.VERSION)
	return "v" .. text
end

return Version
