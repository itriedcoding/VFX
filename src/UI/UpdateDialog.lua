--[[
	UpdateDialog - release-synced updates, inside Studio.

	Shows the installed version, checks GitHub, applies a downloaded build to the
	running plugin without a restart, and offers the save-to-disk step that makes
	the update survive a Studio restart.
]]

local Util = require(script.Parent.Parent.Core.Util)
local Theme = require(script.Parent.Parent.Core.Theme)
local Version = require(script.Parent.Parent.Core.Version)
local Kit = require(script.Parent.Kit)

local UpdateDialog = {}
UpdateDialog.__index = UpdateDialog

function UpdateDialog.new(parent: Instance, ctx: any)
	local self = setmetatable({}, UpdateDialog)
	self.ctx = ctx
	self.updater = ctx.updater
	self.connections = {}

	local root = Kit.frame(parent, {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Theme.color.bg1,
	})
	self.root = root

	local header = Kit.frame(root, {
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
	})
	Kit.label(header, "Updates", {
		Position = UDim2.fromOffset(16, 10),
		Size = UDim2.new(1, -70, 0, 20),
		Font = Theme.font.bold,
		TextSize = Theme.text.title,
	})
	Kit.caption(header, "Synced with GitHub releases for " .. Version.REPO, {
		Position = UDim2.fromOffset(16, 30),
		Size = UDim2.new(1, -70, 0, 14),
		TextSize = Theme.text.tiny,
	})
	local close = Kit.iconButton(header, "\u{00d7}", {
		size = UDim2.fromOffset(26, 26),
		tooltip = "Close",
		onClick = function()
			ctx.closeModal()
		end,
	})
	close.Position = UDim2.new(1, -38, 0, 12)

	local body = Kit.vlist(root, 10, {
		Size = UDim2.new(1, -32, 0, 0),
		Position = UDim2.fromOffset(16, 58),
	})
	body.AutomaticSize = Enum.AutomaticSize.Y

	-- Version card -------------------------------------------------------------
	local card = Kit.frame(body, {
		Size = UDim2.new(1, 0, 0, 72),
		BackgroundColor3 = Theme.color.bg2,
	})
	Theme.corner(card, Theme.radius.md)

	self.installedLabel = Kit.label(card, "Installed  " .. Version.display(Version.VERSION), {
		Position = UDim2.fromOffset(12, 8),
		Size = UDim2.new(1, -24, 0, 16),
		TextSize = Theme.text.small,
		Font = Theme.font.medium,
	})
	self.latestLabel = Kit.caption(card, "Latest  -", {
		Position = UDim2.fromOffset(12, 26),
		Size = UDim2.new(1, -24, 0, 14),
		TextSize = Theme.text.tiny,
	})
	self.stateLabel = Kit.label(card, "Ready.", {
		Position = UDim2.fromOffset(12, 44),
		Size = UDim2.new(1, -24, 0, 16),
		TextColor3 = Theme.color.textMuted,
		TextSize = Theme.text.tiny,
		TextWrapped = true,
	})

	-- Actions ------------------------------------------------------------------
	local actions = Kit.hlist(body, 8, {
		Size = UDim2.new(1, 0, 0, 30),
	})
	actions.AutomaticSize = Enum.AutomaticSize.None
	actions.Size = UDim2.new(1, 0, 0, 30)

	self.checkButton = Kit.button(actions, "Check for updates", {
		variant = "secondary",
		height = 30,
		size = UDim2.fromOffset(136, 30),
		onClick = function()
			self:check()
		end,
	})
	self.updateButton = Kit.button(actions, "Update now", {
		variant = "primary",
		height = 30,
		size = UDim2.fromOffset(104, 30),
		onClick = function()
			self:update()
		end,
	})
	self.saveButton = Kit.button(actions, "Save plugin file", {
		variant = "ghost",
		height = 30,
		size = UDim2.fromOffset(112, 30),
		tooltip = "Save the updated plugin model so it survives a Studio restart",
		onClick = function()
			self:save()
		end,
	})

	-- Auto-check ---------------------------------------------------------------
	local autoRow = Kit.hlist(body, 8, {
		Size = UDim2.new(1, 0, 0, 22),
	})
	autoRow.AutomaticSize = Enum.AutomaticSize.None
	autoRow.Size = UDim2.new(1, 0, 0, 22)
	local autoToggle = Kit.toggle(autoRow, self.updater:isAutoCheckEnabled(), function(value)
		self.updater:setAutoCheck(value)
		self:refresh()
	end)
	autoToggle.Parent = autoRow
	Kit.caption(autoRow, "Check for updates when Studio opens", {
		Size = UDim2.new(1, -44, 0, 22),
		TextSize = Theme.text.tiny,
	})

	-- Notes --------------------------------------------------------------------
	Kit.caption(body, "RELEASE NOTES", {
		Size = UDim2.new(1, 0, 0, 14),
		Font = Theme.font.bold,
		TextSize = Theme.text.tiny,
		TextColor3 = Theme.color.textMuted,
	})

	local notesCard = Kit.frame(body, {
		Size = UDim2.new(1, 0, 0, 132),
		BackgroundColor3 = Theme.color.bg0,
	})
	Theme.corner(notesCard, Theme.radius.sm)
	self.notesBox = Kit.textBox(notesCard, "", {
		size = UDim2.new(1, -16, 1, -16),
		font = Theme.font.mono,
		textSize = 10,
	})
	self.notesBox.Position = UDim2.fromOffset(8, 8)
	self.notesBox.TextWrapped = true
	self.notesBox.TextYAlignment = Enum.TextYAlignment.Top
	self.notesBox.TextXAlignment = Enum.TextXAlignment.Left
	self.notesBox.Text = "Press \"Check for updates\" to fetch the latest build notes."

	-- Release link -------------------------------------------------------------
	Kit.caption(body, "RELEASES", {
		Size = UDim2.new(1, 0, 0, 14),
		Font = Theme.font.bold,
		TextSize = Theme.text.tiny,
		TextColor3 = Theme.color.textMuted,
	})
	local linkBox = Kit.textBox(body, Version.RELEASES_URL, {
		size = UDim2.new(1, 0, 0, 26),
		font = Theme.font.mono,
		textSize = Theme.text.tiny,
	})
	linkBox.TextEditable = true

	Kit.caption(body, "After updating, press \"Save plugin file\", choose VFXStudio.rbxmx in your Plugins folder and overwrite it. Studio has no API that writes plugin files directly, so this is the one manual step.", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true,
		TextSize = Theme.text.tiny,
		TextColor3 = Theme.color.textMuted,
	})

	-- Footer -------------------------------------------------------------------
	local footer = Kit.hlist(root, 8, {
		Size = UDim2.new(1, -32, 0, 32),
		Position = UDim2.new(0, 16, 1, -44),
	})
	footer.AutomaticSize = Enum.AutomaticSize.None
	footer.Size = UDim2.new(1, -32, 0, 32)

	self.closeButton = Kit.button(footer, "Done", {
		variant = "accentSoft",
		height = 32,
		size = UDim2.fromOffset(84, 32),
		onClick = function()
			ctx.closeModal()
		end,
	})
	self.hintLabel = Kit.caption(footer, "", {
		Size = UDim2.new(1, -96, 0, 32),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextSize = Theme.text.tiny,
		TextWrapped = true,
	})

	table.insert(self.connections, self.updater.signals:on("state", function()
		self:refresh()
	end))

	self:refresh()
	return self
end

function UpdateDialog:refresh()
	if not self.root.Parent then
		return
	end
	local updater = self.updater
	local installed = Version.display(updater:installedVersion())
	self.installedLabel.Text = "Installed  " .. installed

	local info = updater.info
	if info then
		local newer = updater:hasUpdate()
		self.latestLabel.Text = string.format(
			"Latest  %s  (%s)",
			Version.display(info.version),
			if info.source == "release" then "GitHub release" else "main branch"
		)
		self.latestLabel.TextColor3 = if newer then Theme.color.accentBright else Theme.color.textMuted
		self.notesBox.Text = if info.notes ~= "" then info.notes else "No release notes."
		self.updateButton.Text = if newer then "Update to " .. Version.display(info.version) else "Up to date"
		self.updateButton.TextColor3 = if newer then Theme.color.white else Theme.color.textDim
		self.updateButton.BackgroundColor3 = if newer then Theme.color.accent else Theme.color.bg3
	else
		self.latestLabel.Text = "Latest  -"
		self.updateButton.Text = "Update now"
	end

	local busy = updater.state == "checking" or updater.state == "downloading" or updater.state == "applying"
	self.checkButton.Text = if updater.state == "checking" then "Checking..." else "Check for updates"
	self.checkButton.TextColor3 = if busy then Theme.color.textFaint else Theme.color.text

	local message = updater.stateMessage
	if updater.state == "error" then
		self.stateLabel.Text = "Error: " .. tostring(updater.lastError)
		self.stateLabel.TextColor3 = Theme.color.bad
		self.notesBox.Text = tostring(updater.lastError)
	elseif updater.state == "ready" then
		self.stateLabel.Text = "Updated in this Studio session. Save the plugin file to keep it."
		self.stateLabel.TextColor3 = Theme.color.good
	elseif busy then
		self.stateLabel.Text = message or "Working..."
		self.stateLabel.TextColor3 = Theme.color.accentBright
	else
		self.stateLabel.Text = if message then message else "Ready."
		self.stateLabel.TextColor3 = Theme.color.textMuted
	end

	self.hintLabel.Text = if updater.appliedManifest
		then "Running v" .. Version.clean(updater.appliedVersion or Version.VERSION) .. " from this update."
		else ""
end

function UpdateDialog:check()
	if self.updater.state == "checking" or self.updater.state == "downloading" then
		return
	end
	task.spawn(function()
		local ok, info = pcall(function()
			return self.updater:check()
		end)
		if not ok then
			self.ctx.toast("Update check failed", "error")
			self:refresh()
			return
		end
		self:refresh()
		if info then
			if self.updater:hasUpdate() then
				self.ctx.toast(string.format("v%s is available", Version.clean(info.version)), "info")
			else
				self.ctx.toast("You are on the latest version", "success")
			end
		else
			self.ctx.toast(self.updater.lastError or "Could not check for updates", "warn")
		end
	end)
end

function UpdateDialog:update()
	if self.updater.state == "downloading" or self.updater.state == "applying" then
		return
	end
	task.spawn(function()
		local manifest, err = self.updater:downloadManifest()
		if not manifest then
			self.ctx.toast(err or "Download failed", "error")
			self:refresh()
			return
		end
		local ok, applyError = self.updater:apply(manifest)
		if not ok then
			self.ctx.toast(applyError or "Update failed", "error")
			self:refresh()
			return
		end
		self.ctx.toast("Updated to v" .. Version.clean(manifest.version) .. " in this session", "success")
		self:refresh()
		-- Rebuild the editor against the new modules.
		if self.ctx.onUpdated then
			task.defer(function()
				local callback = self.ctx.onUpdated
				if callback then
					callback()
				end
			end)
		end
	end)
end

function UpdateDialog:save()
	local ok, err = self.updater:saveToDisk()
	if not ok then
		self.ctx.toast(err or "Could not open the save dialog", "error")
		return
	end
	self.ctx.toast("Choose your Plugins folder and overwrite VFXStudio.rbxmx", "info")
	self.hintLabel.Text = "Save dialog opened. Overwrite VFXStudio.rbxmx, then restart Studio."
end

function UpdateDialog:destroy()
	for _, connection in ipairs(self.connections) do
		pcall(function()
			connection:disconnect()
		end)
	end
	self.root:Destroy()
end

return UpdateDialog
