--[[
	Library - the preset browser.

	Categories, instant search, favourites, "my presets" and a paged card grid
	with thumbnails generated from each effect's real texture and palette.
	324 presets are paged 24 at a time so the panel stays instant in Studio.
]]

local Util = require(script.Parent.Parent.Core.Util)
local Theme = require(script.Parent.Parent.Core.Theme)
local Assets = require(script.Parent.Parent.Core.Assets)
local Kit = require(script.Parent.Kit)

local Library = {}
Library.__index = Library

local PAGE_SIZE = 24

local function primaryTexture(spec: any): (string, Color3, Color3)
	local texture = Assets.defaultUri
	local firstColor = Theme.color.accent
	local lastColor = Theme.color.accentDeep

	for _, comp in ipairs(spec.components or {}) do
		if comp.kind == "particle" then
			texture = Assets.resolve(comp.texture)
			local points = comp.color or {}
			if #points > 0 then
				firstColor = Util.hex(points[1][2] or "#ffffff")
				lastColor = Util.hex(points[#points][2] or "#ffffff")
			end
			break
		end
	end
	return texture, firstColor, lastColor
end

local function glyphFor(spec: any): string
	local hasParticle, hasBeam, hasTrail, hasLight = false, false, false, false
	for _, comp in ipairs(spec.components or {}) do
		if comp.kind == "particle" then
			hasParticle = true
		elseif comp.kind == "beam" then
			hasBeam = true
		elseif comp.kind == "trail" then
			hasTrail = true
		elseif comp.kind == "light" then
			hasLight = true
		end
	end
	if hasBeam then
		return "\u{2726}"
	elseif hasTrail then
		return "\u{2192}"
	elseif hasLight then
		return "\u{2600}"
	elseif hasParticle then
		return "\u{273b}"
	end
	return "\u{25c6}"
end

function Library.new(parent: Instance, ctx: any)
	local self = setmetatable({}, Library)
	self.ctx = ctx
	self.store = ctx.store
	self.query = ""
	self.category = "All"
	self.page = 1
	self.showFavoritesOnly = false
	self.cards = {}

	local root = Kit.frame(parent, {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Theme.color.bg1,
	})
	self.root = root

	-- header ------------------------------------------------------------------
	local header = Kit.frame(root, {
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
	})
	local title = Kit.label(header, "VFX Library", {
		Position = UDim2.fromOffset(12, 8),
		Size = UDim2.new(1, -100, 0, 16),
		Font = Theme.font.bold,
		TextSize = Theme.text.title,
	})
	self.countLabel = Kit.label(header, "", {
		Position = UDim2.fromOffset(12, 26),
		Size = UDim2.new(1, -100, 0, 14),
		TextColor3 = Theme.color.textMuted,
		TextSize = Theme.text.tiny,
	})
	local favButton = Kit.iconButton(header, "\u{2605}", {
		size = UDim2.fromOffset(26, 26),
		tooltip = "Show favourites only",
		onClick = function()
			self.showFavoritesOnly = not self.showFavoritesOnly
			favButton.TextColor3 = if self.showFavoritesOnly then Theme.color.warn else Theme.color.textDim
			self.page = 1
			self:refresh()
		end,
	})
	favButton.Position = UDim2.new(1, -34, 0, 10)
	self.favButton = favButton

	-- search ------------------------------------------------------------------
	local searchHolder = Kit.frame(root, {
		Size = UDim2.new(1, -24, 0, 30),
		Position = UDim2.fromOffset(12, 48),
		BackgroundTransparency = 1,
	})
	self.search = Kit.searchBox(searchHolder, "Search 324 effects, tags, categories...", function(text)
		self.query = text
		self.page = 1
		self:refresh()
	end)

	-- categories --------------------------------------------------------------
	local categoryScroll = Kit.scroll(root, {
		Size = UDim2.new(1, 0, 0, 116),
		Position = UDim2.fromOffset(0, 84),
	}, 6)
	categoryScroll.ScrollBarThickness = 3
	self.categoryHolder = categoryScroll
	categoryScroll.ClipsDescendants = true

	local categoryList = Kit.frame(categoryScroll, {
		Size = UDim2.new(1, -10, 0, 0),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	self.categoryList = categoryList

	-- results -----------------------------------------------------------------
	local resultHeader = Kit.frame(root, {
		Size = UDim2.new(1, -24, 0, 22),
		Position = UDim2.fromOffset(12, 206),
		BackgroundTransparency = 1,
	})
	self.resultHeader = resultHeader
	self.resultLabel = Kit.label(resultHeader, "", {
		Size = UDim2.new(1, -80, 1, 0),
		TextColor3 = Theme.color.textMuted,
		TextSize = Theme.text.tiny,
		Font = Theme.font.bold,
	})
	self.sortLabel = Kit.label(resultHeader, "A-Z", {
		Size = UDim2.fromOffset(50, 20),
		Position = UDim2.new(1, -50, 0, 1),
		TextColor3 = Theme.color.textFaint,
		TextSize = Theme.text.tiny,
		TextXAlignment = Enum.TextXAlignment.Right,
	})

	local gridScroll, gridContent = Kit.scroll(root, {
		Size = UDim2.new(1, 0, 1, -232),
		Position = UDim2.fromOffset(0, 230),
	}, 8)
	self.gridScroll = gridScroll

	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0.5, -7, 0, 96)
	grid.CellPadding = UDim2.fromOffset(6, 6)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.FillDirectionMaxCells = 2
	grid.Parent = gridScroll
	self.gridLayout = grid

	-- load more --------------------------------------------------------------
	self.moreButton = Kit.button(root, "Load more effects", {
		variant = "secondary",
		height = 26,
		size = UDim2.new(1, -24, 0, 26),
		onClick = function()
			self.page += 1
			self:renderGrid(true)
		end,
	})
	self.moreButton.Position = UDim2.new(0, 12, 1, -34)
	self.moreButton.Visible = false

	self.signals = {}
	self:bindStore()
	self:refreshCategories()
	self:refresh()
	return self
end

function Library:bindStore()
	local connections = {}
	table.insert(connections, self.store.signals:on("custom", function()
		self:refreshCategories()
		self:refresh()
	end))
	table.insert(connections, self.store.signals:on("favorites", function()
		self:refreshCategories()
		self:refresh()
	end))
	table.insert(connections, self.store.signals:on("pref", function(payload)
		if payload.key == "lastPresetId" then
			self:refreshSelection()
		end
	end))
	self.connections = connections
end

function Library:refreshCategories()
	Kit.clear(self.categoryList)
	local categories = self.store:categories()
	local index = 0
	for _, category in ipairs(categories) do
		index += 1
		local active = self.category == category.name
		local row = Kit.button(self.categoryList, "", {
			variant = if active then "accentSoft" else "ghost",
			height = 24,
			size = UDim2.new(1, 0, 0, 24),
			onClick = function()
				self.category = category.name
				self.page = 1
				self:refreshCategories()
				self:refresh()
			end,
		})
		row.LayoutOrder = index
		row.TextXAlignment = Enum.TextXAlignment.Left

		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 9)
		pad.Parent = row

		Kit.label(row, category.label or category.name, {
			Size = UDim2.new(1, -38, 1, 0),
			TextColor3 = if active then Theme.color.text else Theme.color.textDim,
			TextSize = Theme.text.small,
			Font = if active then Theme.font.medium else Theme.font.body,
		})

		local countText = tostring(category.count or 0)
		Kit.label(row, countText, {
			Size = UDim2.fromOffset(30, 24),
			Position = UDim2.new(1, -34, 0, 0),
			TextColor3 = Theme.color.textFaint,
			TextSize = Theme.text.tiny,
			TextXAlignment = Enum.TextXAlignment.Right,
			Font = Theme.font.mono,
		})
	end
end

function Library:refresh()
	self:renderGrid(false)
	self:refreshSelection()
end

function Library:refreshSelection()
	for id, card in pairs(self.cards) do
		local active = self.store.prefs.lastPresetId == id
		card.stroke.Color = if active then Theme.color.accent else Theme.color.line
		card.stroke.Thickness = if active then 2 else 1
		card.stroke.Transparency = if active then 0 else 0.45
		card.frame.BackgroundColor3 = if active then Theme.color.bg3 else Theme.color.bg2
	end
end

function Library:renderGrid(append: boolean)
	if not append then
		Kit.clear(self.gridScroll)
		self.cards = {}
	end

	local results = self.store:search(self.query, {
		category = self.category,
		favoritesOnly = self.showFavoritesOnly,
	})

	self.countLabel.Text = string.format("%d effects - %d categories", #self.store.presets.all + #self.store.custom, #self.store.presets.categories)
	self.resultLabel.Text = string.upper(self.category == "All" and "All effects" or self.category) .. "  \u{00b7}  " .. #results .. " results"

	local limit = math.min(#results, self.page * PAGE_SIZE)
	local start = if append then (self.page - 1) * PAGE_SIZE + 1 else 1

	if #results == 0 then
		if not append then
			local empty = Kit.label(self.gridScroll, "No effects match this search.\nTry a tag like \"fire\", \"magic\" or \"impact\".", {
				Size = UDim2.new(1, -10, 0, 60),
				TextColor3 = Theme.color.textMuted,
				TextWrapped = true,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextSize = Theme.text.small,
			})
			empty.LayoutOrder = 1
		end
		self.moreButton.Visible = false
		return
	end

	for index = start, limit do
		local spec = results[index]
		if spec then
			self:createCard(spec, index)
		end
	end

	self.moreButton.Visible = limit < #results
	self.moreButton.Text = string.format("Load %d more", math.min(PAGE_SIZE, #results - limit))
end

function Library:createCard(spec: any, order: number)
	local texture, colorA, colorB = primaryTexture(spec)

	local cardFrame = Kit.frame(self.gridScroll, {
		Size = UDim2.new(0, 130, 0, 96),
		BackgroundColor3 = if self.store.prefs.lastPresetId == spec.id then Theme.color.bg3 else Theme.color.bg2,
		ClipsDescendants = true,
	})
	cardFrame.LayoutOrder = order
	local stroke = Theme.stroke(cardFrame, Theme.color.line, 1, 0.45)
	Theme.corner(cardFrame, Theme.radius.md)

	local thumb = Kit.frame(cardFrame, {
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundColor3 = Theme.color.bg0,
	})
	local thumbGradient = Instance.new("UIGradient")
	thumbGradient.Color = ColorSequence.new(Theme.shade(colorB, 0.55), Theme.color.bg0)
	thumbGradient.Rotation = 115
	thumbGradient.Parent = thumb

	local image = Instance.new("ImageLabel")
	image.BackgroundTransparency = 1
	image.Size = UDim2.new(1, -14, 1, -8)
	image.Position = UDim2.fromOffset(7, 2)
	image.Image = texture
	image.ImageColor3 = colorA
	image.ImageTransparency = 0.05
	image.ScaleType = Enum.ScaleType.Fit
	image.Parent = thumb

	local glow = Instance.new("ImageLabel")
	glow.BackgroundTransparency = 1
	glow.Size = UDim2.new(1, -6, 1, -6)
	glow.Position = UDim2.fromOffset(3, 3)
	glow.Image = texture
	glow.ImageColor3 = colorA
	glow.ImageTransparency = 0.62
	glow.ScaleType = Enum.ScaleType.Fit
	glow.Parent = thumb

	local glyph = Kit.label(thumb, glyphFor(spec), {
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.fromOffset(6, 5),
		TextColor3 = Theme.color.white,
		TextTransparency = 0.35,
		TextSize = 11,
		Font = Theme.font.bold,
	})

	local nameLabel = Kit.label(cardFrame, spec.name, {
		Size = UDim2.new(1, -12, 0, 16),
		Position = UDim2.fromOffset(8, 55),
		TextSize = Theme.text.small,
		Font = Theme.font.medium,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	local meta = Kit.label(cardFrame, string.format("%s  \u{00b7}  %ds", spec.category, math.max(1, math.floor(spec.duration + 0.5))), {
		Size = UDim2.new(1, -12, 0, 13),
		Position = UDim2.fromOffset(8, 70),
		TextColor3 = Theme.color.textMuted,
		TextSize = Theme.text.tiny,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	local star = Kit.iconButton(cardFrame, if self.store:isFavorite(spec.id) then "\u{2605}" else "\u{2606}", {
		size = UDim2.fromOffset(20, 20),
		tooltip = "Favourite",
		onClick = function()
			self.store:toggleFavorite(spec.id)
			star.Text = if self.store:isFavorite(spec.id) then "\u{2605}" else "\u{2606}"
			star.TextColor3 = if self.store:isFavorite(spec.id) then Theme.color.warn else Theme.color.textDim
		end,
	})
	star.Position = UDim2.new(1, -24, 0, 57)
	star.TextColor3 = if self.store:isFavorite(spec.id) then Theme.color.warn else Theme.color.textDim
	star.ZIndex = 3

	local click = Instance.new("TextButton")
	click.BackgroundTransparency = 1
	click.Text = ""
	click.Size = UDim2.new(1, 0, 1, 0)
	click.ZIndex = 2
	click.Parent = cardFrame

	local hoverTween = function(target: Vector2?)
		Util.tween(cardFrame, { BackgroundColor3 = Theme.color.bg3 }, 0.1)
		Util.tween(image, { ImageTransparency = 0 }, 0.12)
		Util.tween(glow, { ImageTransparency = 0.4 }, 0.12)
	end
	local leaveTween = function()
		Util.tween(cardFrame, { BackgroundColor3 = if self.store.prefs.lastPresetId == spec.id then Theme.color.bg3 else Theme.color.bg2 }, 0.12)
		Util.tween(image, { ImageTransparency = 0.05 }, 0.12)
		Util.tween(glow, { ImageTransparency = 0.62 }, 0.12)
	end

	click.MouseEnter:Connect(hoverTween)
	click.MouseLeave:Connect(leaveTween)

	click.Activated:Connect(function()
		local ok, err = pcall(function()
			self.store:applyPreset(spec)
			self.ctx.toast("Loaded " .. spec.name)
			self:refreshSelection()
		end)
		if not ok then
			warn("[VFX Studio] could not load preset: " .. tostring(err))
			self.ctx.toast("Could not load that preset", "error")
		end
	end)

	Kit.tooltip(click, spec.description or spec.name)

	self.cards[spec.id] = {
		frame = cardFrame,
		stroke = stroke,
	}
end

function Library:setQuery(query: string)
	self.search.Text = query
end

function Library:destroy()
	Kit.disconnectAll(self.connections or {})
	self.root:Destroy()
end

return Library
