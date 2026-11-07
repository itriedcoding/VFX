--[[
	AssetsPanel - the texture manager.

	Browse the catalogue, add any Roblox texture by id, pull textures already
	used in the place, and validate every asset against the content provider so
	a missing decal is caught before it ships as an invisible effect.
]]

local Util = require(script.Parent.Parent.Core.Util)
local Theme = require(script.Parent.Parent.Core.Theme)
local Assets = require(script.Parent.Parent.Core.Assets)
local Kit = require(script.Parent.Kit)

local AssetsPanel = {}
AssetsPanel.__index = AssetsPanel

local GROUPS = { "All", "Fire", "Smoke", "Magic", "Energy", "Utility", "Mine" }

function AssetsPanel.new(parent: Instance, ctx: any, onPick: ((string) -> ())?)
	local self = setmetatable({}, AssetsPanel)
	self.ctx = ctx
	self.store = ctx.store
	self.onPick = onPick
	self.query = ""
	self.group = "All"
	self.status = {}
	self.cards = {}

	local root = Kit.frame(parent, {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Theme.color.bg1,
	})
	self.root = root

	local header = Kit.frame(root, {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
	})
	Kit.label(header, "Texture assets", {
		Position = UDim2.fromOffset(14, 8),
		Size = UDim2.new(1, -60, 0, 18),
		Font = Theme.font.bold,
		TextSize = Theme.text.title,
	})
	Kit.caption(header, "Particle, beam and trail textures. Validate before shipping.", {
		Position = UDim2.fromOffset(14, 25),
		Size = UDim2.new(1, -60, 0, 14),
		TextSize = Theme.text.tiny,
	})
	local closeButton = Kit.iconButton(header, "\u{00d7}", {
		size = UDim2.fromOffset(26, 26),
		tooltip = "Close",
		onClick = function()
			self.ctx.closeModal()
		end,
	})
	closeButton.Position = UDim2.new(1, -36, 0, 8)
	closeButton.TextColor3 = Theme.color.textDim

	local searchHolder = Kit.frame(root, {
		Size = UDim2.new(1, -28, 0, 30),
		Position = UDim2.fromOffset(14, 48),
		BackgroundTransparency = 1,
	})
	self.search = Kit.searchBox(searchHolder, "Search textures, tags or asset ids...", function(text)
		self.query = text
		self:render()
	end)

	local filters = Kit.hlist(root, 4, {
		Size = UDim2.new(1, -28, 0, 22),
		Position = UDim2.fromOffset(14, 84),
	})
	filters.AutomaticSize = Enum.AutomaticSize.None
	filters.Size = UDim2.new(1, -28, 0, 22)
	self.filterButtons = {}
	for _, group in ipairs(GROUPS) do
		local button = Kit.chip(filters, group, function()
			self.group = group
			self:render()
			self:refreshFilters()
		end, group == self.group)
		table.insert(self.filterButtons, { name = group, button = button })
	end

	local addRow = Kit.hlist(root, 6, {
		Size = UDim2.new(1, -28, 0, 28),
		Position = UDim2.fromOffset(14, 112),
	})
	addRow.AutomaticSize = Enum.AutomaticSize.None
	addRow.Size = UDim2.new(1, -28, 0, 28)
	local idBox = Kit.textBox(addRow, "", {
		placeholder = "Paste an asset id or rbxassetid://...",
		size = UDim2.new(1, -74, 0, 28),
		onSubmit = function(text)
			self:addAsset(text)
		end,
	})
	idBox.Parent = addRow
	Kit.button(addRow, "Add", {
		variant = "primary",
		height = 28,
		size = UDim2.fromOffset(64, 28),
		onClick = function()
			self:addAsset(idBox.Text)
		end,
	})

	local tools = Kit.hlist(root, 6, {
		Size = UDim2.new(1, -28, 0, 24),
		Position = UDim2.fromOffset(14, 146),
	})
	tools.AutomaticSize = Enum.AutomaticSize.None
	tools.Size = UDim2.new(1, -28, 0, 24)
	Kit.button(tools, "Validate all", {
		variant = "secondary",
		height = 22,
		size = UDim2.fromOffset(86, 22),
		textSize = Theme.text.tiny,
		tooltip = "Preload every texture and flag anything that fails",
		onClick = function()
			self:validateAll()
		end,
	})
	Kit.button(tools, "Import from selection", {
		variant = "ghost",
		height = 22,
		size = UDim2.fromOffset(126, 22),
		textSize = Theme.text.tiny,
		onClick = function()
			self:importFromSelection()
		end,
	})
	self.summary = Kit.caption(tools, "", {
		Size = UDim2.new(1, -220, 0, 22),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextSize = Theme.text.tiny,
	})

	local scroll = Kit.scroll(root, {
		Size = UDim2.new(1, 0, 1, -184),
		Position = UDim2.fromOffset(0, 178),
	}, 12)
	scroll.ScrollBarThickness = 4
	self.scroll = scroll

	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0.5, -6, 0, 108)
	grid.CellPadding = UDim2.fromOffset(8, 8)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.FillDirectionMaxCells = 2
	grid.Parent = scroll
	self.grid = grid

	self:render()
	return self
end

function AssetsPanel:refreshFilters()
	for _, entry in ipairs(self.filterButtons) do
		local active = entry.name == self.group
		entry.button.BackgroundColor3 = if active then Theme.color.accentSoft else Theme.color.bg3
		entry.button.TextColor3 = if active then Theme.color.accentBright else Theme.color.textDim
	end
end

function AssetsPanel:visibleAssets(): { any }
	local list = {}
	for _, entry in ipairs(Assets.search(self.query)) do
		local include = true
		if self.group ~= "All" then
			include = if self.group == "Mine" then entry.custom == true else entry.group == self.group
		end
		if include then
			table.insert(list, entry)
		end
	end
	return list
end

function AssetsPanel:render()
	Kit.clear(self.scroll)
	self.cards = {}
	local list = self:visibleAssets()

	local okCount, missingCount, unknownCount = 0, 0, 0
	for _, entry in ipairs(list) do
		local status = self.status[entry.uri] or "unknown"
		if status == "ok" then
			okCount += 1
		elseif status == "missing" then
			missingCount += 1
		else
			unknownCount += 1
		end
	end
	self.summary.Text = string.format("%d textures  \u{00b7}  %d ok  \u{00b7}  %d unverified  \u{00b7}  %d failed", #list, okCount, unknownCount, missingCount)

	for index, entry in ipairs(list) do
		self:createCard(entry, index)
	end

	if #list == 0 then
		Kit.caption(self.scroll, "No textures match that search.", {
			Size = UDim2.new(1, -20, 0, 40),
			LayoutOrder = 1,
		})
	end
end

function AssetsPanel:createCard(entry: any, order: number)
	local card = Kit.frame(self.scroll, {
		Size = UDim2.new(0, 200, 0, 108),
		BackgroundColor3 = Theme.color.bg2,
		ClipsDescendants = true,
	})
	card.LayoutOrder = order
	Theme.corner(card, Theme.radius.md)
	Theme.stroke(card, Theme.color.line, 1, 0.35)

	local preview = Kit.frame(card, {
		Size = UDim2.new(1, 0, 0, 64),
		BackgroundColor3 = Theme.color.bg0,
	})
	local image = Instance.new("ImageLabel")
	image.BackgroundTransparency = 1
	image.Size = UDim2.new(1, -16, 1, -10)
	image.Position = UDim2.fromOffset(8, 5)
	image.Image = entry.uri
	image.ScaleType = Enum.ScaleType.Fit
	image.ImageTransparency = 0.05
	image.Parent = preview

	local name = Kit.label(card, entry.name, {
		Size = UDim2.new(1, -14, 0, 14),
		Position = UDim2.fromOffset(8, 66),
		TextSize = Theme.text.small,
		Font = Theme.font.medium,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	local meta = Kit.caption(card, string.format("%s \u{00b7} %s", entry.group or "Custom", if entry.builtin then "built in" else "asset"), {
		Size = UDim2.new(1, -90, 0, 12),
		Position = UDim2.fromOffset(8, 80),
		TextSize = Theme.text.tiny,
	})

	local status = self.status[entry.uri] or "unknown"
	local statusColor = if status == "ok" then Theme.color.good elseif status == "missing" then Theme.color.bad else Theme.color.warn
	local badge = Kit.label(card, if status == "ok" then "OK" elseif status == "missing" then "MISSING" else "VERIFY", {
		Size = UDim2.fromOffset(52, 12),
		Position = UDim2.new(1, -60, 0, 68),
		TextColor3 = statusColor,
		TextSize = Theme.text.tiny,
		Font = Theme.font.bold,
		TextXAlignment = Enum.TextXAlignment.Right,
	})

	local use = Kit.button(card, if self.onPick then "Use" else "Copy id", {
		variant = "accentSoft",
		height = 20,
		size = UDim2.fromOffset(48, 20),
		textSize = Theme.text.tiny,
		onClick = function()
			if self.onPick then
				self.onPick(entry.uri)
			else
				self.ctx.toast(entry.uri, "info")
			end
		end,
	})
	use.Position = UDim2.new(1, -56, 0, 84)

	local check = Kit.iconButton(card, "\u{2713}", {
		size = UDim2.fromOffset(20, 20),
		tooltip = "Validate this texture",
		onClick = function()
			self:validateOne(entry, badge)
		end,
	})
	check.Position = UDim2.new(0, 4, 0, 42)
	check.TextColor3 = Theme.color.white
	check.BackgroundColor3 = Theme.color.bg0
	check.BackgroundTransparency = 0.35
	check.ZIndex = 4

	if entry.custom then
		local remove = Kit.iconButton(card, "\u{00d7}", {
			size = UDim2.fromOffset(18, 18),
			tooltip = "Remove from my textures",
			onClick = function()
				self:removeAsset(entry.uri)
			end,
		})
		remove.Position = UDim2.new(0, 4, 0, 44)
		remove.Visible = false
		remove.TextColor3 = Theme.color.bad
		card.MouseEnter:Connect(function()
			remove.Visible = true
		end)
		card.MouseLeave:Connect(function()
			remove.Visible = false
		end)
		remove.ZIndex = 5
	end

	self.cards[entry.uri] = { badge = badge, image = image, status = status }
end

function AssetsPanel:validateOne(entry: any, badge: TextLabel?)
	if badge then
		badge.Text = "..."
	end
	task.spawn(function()
		local status = Assets.validate(entry.uri, self.root)
		self.status[entry.uri] = status
		self:render()
	end)
end

function AssetsPanel:validateAll()
	local list = self:visibleAssets()
	self.summary.Text = "Validating " .. #list .. " textures..."
	task.spawn(function()
		local failed = 0
		for _, entry in ipairs(list) do
			local status = Assets.validate(entry.uri, self.root)
			self.status[entry.uri] = status
			if status == "missing" then
				failed += 1
			end
		end
		self:render()
		if failed > 0 then
			self.ctx.toast(string.format("%d texture(s) failed to load", failed), "error")
		else
			self.ctx.toast("All textures loaded", "success")
		end
	end)
end

function AssetsPanel:addAsset(raw: string)
	local text = Util.trim(raw or "")
	if text == "" then
		return
	end
	local uri = Assets.resolve(text)
	if uri == "" then
		self.ctx.toast("That does not look like an asset id", "warn")
		return
	end

	for _, entry in ipairs(Assets.all()) do
		if entry.uri == uri then
			self.ctx.toast("That texture is already in the library", "info")
			return
		end
	end

	local custom = table.clone(Assets.custom)
	table.insert(custom, {
		id = "custom_" .. Util.slug(Assets.describe(uri)),
		name = Assets.describe(uri),
		uri = uri,
		group = "Utility",
		custom = true,
		tags = { "custom" },
	})
	Assets.setCustom(custom)
	self.store:setPref("customAssets", custom, { silent = true })
	self.ctx.toast("Added " .. Assets.describe(uri), "success")
	self:render()
end

function AssetsPanel:removeAsset(uri: string)
	local custom = {}
	for _, entry in ipairs(Assets.custom) do
		if entry.uri ~= uri then
			table.insert(custom, entry)
		end
	end
	Assets.setCustom(custom)
	self.store:setPref("customAssets", custom, { silent = true })
	self:render()
end

function AssetsPanel:importFromSelection()
	local selection = Util.Selection:Get()
	if #selection == 0 then
		self.ctx.toast("Select an effect in the Explorer first", "warn")
		return
	end

	local found = {}
	local seen = {}
	for _, root in ipairs(selection) do
		local candidates = { root }
		for _, descendant in ipairs(root:GetDescendants()) do
			table.insert(candidates, descendant)
		end
		for _, instance in ipairs(candidates) do
			if instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") then
				local uri = instance.Texture
				if uri and uri ~= "" and not seen[uri] then
					seen[uri] = true
					table.insert(found, uri)
				end
			end
		end
	end

	if #found == 0 then
		self.ctx.toast("No texture-bearing instances in the selection", "info")
		return
	end

	local custom = table.clone(Assets.custom)
	for _, uri in ipairs(found) do
		local already = false
		for _, entry in ipairs(Assets.all()) do
			if entry.uri == uri then
				already = true
				break
			end
		end
		if not already then
			table.insert(custom, {
				id = "custom_" .. Util.slug(Assets.describe(uri)) .. "_" .. #custom,
				name = Assets.describe(uri),
				uri = uri,
				group = "Utility",
				custom = true,
				tags = { "imported" },
			})
		end
	end
	Assets.setCustom(custom)
	self.store:setPref("customAssets", custom, { silent = true })
	self.ctx.toast(string.format("Imported %d texture(s)", #found), "success")
	self:render()
end

function AssetsPanel:destroy()
	self.root:Destroy()
end

return AssetsPanel
