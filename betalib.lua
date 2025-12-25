--!strict
-- TyrantUI.lua
-- Modular Sirius/Tyrant inspired UI library (Purple theme)
-- Features: Left icon rail tabs, subtabs, search, close/minimize, toasts, keybind widget,
-- config save/load, multi dropdown, draggable, resizable, blur, smooth tweens.
-- IMPORTANT: Fixes "Parent property is locked" by NEVER reparenting buttons after creation.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local TyrantUI = {}
TyrantUI.__index = TyrantUI

--========================================================
-- Helpers
--========================================================
local function clamp(n: number, a: number, b: number)
	if n < a then return a end
	if n > b then return b end
	return n
end

local function roundTo(n: number, step: number)
	if step <= 0 then return n end
	return math.floor(n / step + 0.5) * step
end

local function tween(obj: Instance, ti: TweenInfo, props: {[string]: any})
	local t = TweenService:Create(obj, ti, props)
	t:Play()
	return t
end

local function create(className: string, props: {[string]: any}?, children: {Instance}?)
	local inst = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			(inst :: any)[k] = v
		end
	end
	if children then
		for _, c in ipairs(children) do
			c.Parent = inst
		end
	end
	return inst
end

local function corner(inst: Instance, r: number)
	create("UICorner", { CornerRadius = UDim.new(0, r), Parent = inst })
end

local function stroke(inst: Instance, color: Color3, transparency: number)
	return create("UIStroke", {
		Color = color,
		Transparency = transparency,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = inst
	})
end

local function padding(inst: Instance, t: number, b: number, l: number, r: number)
	create("UIPadding", {
		PaddingTop = UDim.new(0, t),
		PaddingBottom = UDim.new(0, b),
		PaddingLeft = UDim.new(0, l),
		PaddingRight = UDim.new(0, r),
		Parent = inst
	})
end

local function listLayout(parent: Instance, pad: number, horizontal: boolean?)
	local layout = create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, pad),
		FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
		Parent = parent
	})
	return layout
end

local function bindAutoCanvas(scroll: ScrollingFrame, layout: UIListLayout, extra: number)
	local function recalc()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + extra)
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(recalc)
	task.defer(recalc)
end

local function safeCall(fn, ...)
	local ok, err = pcall(fn, ...)
	if not ok then
		warn("[TyrantUI] callback error:", err)
	end
end

local function hasFS()
	return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

--========================================================
-- Theme
--========================================================
local Theme = {
	Bg0 = Color3.fromRGB(10, 10, 14),
	Bg1 = Color3.fromRGB(14, 14, 20),
	Bg2 = Color3.fromRGB(18, 18, 26),
	Bg3 = Color3.fromRGB(22, 22, 32),

	Stroke = Color3.fromRGB(38, 38, 55),
	StrokeSoft = Color3.fromRGB(30, 30, 44),

	Text = Color3.fromRGB(235, 235, 245),
	TextDim = Color3.fromRGB(170, 170, 185),
	TextFaint = Color3.fromRGB(125, 125, 140),

	Accent = Color3.fromRGB(160, 85, 255),     -- purple
	Accent2 = Color3.fromRGB(125, 70, 235),
	Accent3 = Color3.fromRGB(95, 55, 190),

	Good = Color3.fromRGB(90, 220, 150),
	Warn = Color3.fromRGB(255, 200, 90),
	Bad  = Color3.fromRGB(255, 90, 120),
}

local Fonts = {
	SB = Enum.Font.GothamSemibold,
	M  = Enum.Font.GothamMedium,
	R  = Enum.Font.Gotham,
	Mono = Enum.Font.Code,
}

local Anim = {
	Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Med  = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Slow = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
}

--========================================================
-- Window Class
--========================================================
type WidgetEntry = {
	kind: string,
	name: string,
	root: Instance,
	searchTokens: string,
	setVisible: (v: boolean) -> (),
}

type TabObj = {
	Name: string,
	Icon: string,
	Button: TextButton,
	Page: Frame,
	SubBar: Frame,
	SubButtons: Frame,
	SubPages: Frame,
	SubTabs: {[string]: any},
	ActiveSub: any?,
}

type SubTabObj = {
	Name: string,
	Button: TextButton,
	Page: ScrollingFrame,
	Layout: UIListLayout,
	Widgets: {WidgetEntry},
}

export type Window = {
	Gui: ScreenGui,
	Main: Frame,
	Visible: boolean,
	ActiveTab: TabObj?,
	ActiveSub: SubTabObj?,
	Tabs: {[string]: TabObj},

	Notify: (self: Window, title: string, body: string, kind: string?) -> (),
	SetVisible: (self: Window, v: boolean) -> (),
	Destroy: (self: Window) -> (),

	Tab: (self: Window, name: string, icon: string?) -> any,
	SetKeybind: (self: Window, keyCode: Enum.KeyCode) -> (),
	SaveConfig: (self: Window, name: string) -> (),
	LoadConfig: (self: Window, name: string) -> (),
}

local WindowMT = {}
WindowMT.__index = WindowMT

--========================================================
-- UI Components (cards + widgets)
--========================================================
local function makeCard(parent: Instance, height: number)
	local card = create("Frame", {
		BackgroundColor3 = Theme.Bg2,
		BackgroundTransparency = 0.07,
		Size = UDim2.new(1, -6, 0, height),
		Parent = parent,
	})
	corner(card, 12)
	stroke(card, Theme.StrokeSoft, 0.55)
	return card
end

local function makeTitle(parent: Instance, text: string, y: number)
	return create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, y),
		Size = UDim2.new(1, -32, 0, 18),
		Font = Fonts.SB,
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = parent,
	})
end

local function makeDesc(parent: Instance, text: string, y: number)
	return create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, y),
		Size = UDim2.new(1, -32, 0, 18),
		Font = Fonts.M,
		Text = text,
		TextColor3 = Theme.TextFaint,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = parent,
	})
end

--========================================================
-- Window: Create
--========================================================
function TyrantUI:CreateWindow(opts: any): Window
	opts = opts or {}
	local title = opts.Title or "Tyrant Hub"
	local version = opts.Version or "v1.0"
	local keybind: Enum.KeyCode = opts.Keybind or Enum.KeyCode.RightShift

	-- GUI parent
	local parentGui = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

	local gui = create("ScreenGui", {
		Name = "TyrantUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = parentGui,
	})

	-- Blur
	local blur = create("BlurEffect", {
		Size = 0,
		Enabled = true,
		Parent = Lighting,
	})

	-- Main window
	local main = create("Frame", {
		BackgroundColor3 = Theme.Bg1,
		BackgroundTransparency = 0.04,
		Size = UDim2.fromOffset(920, 540),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Parent = gui,
	})
	corner(main, 14)
	stroke(main, Theme.Stroke, 0.25)

	-- Shadow (soft)
	create("ImageLabel", {
		BackgroundTransparency = 1,
		Image = "rbxassetid://1316045217",
		ImageColor3 = Color3.new(0,0,0),
		ImageTransparency = 0.7,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(10, 10, 118, 118),
		Size = UDim2.new(1, 80, 1, 80),
		Position = UDim2.fromOffset(-40, -40),
		ZIndex = 0,
		Parent = main,
	})

	-- Left rail (icons)
	local rail = create("Frame", {
		BackgroundColor3 = Theme.Bg0,
		BackgroundTransparency = 0.10,
		Size = UDim2.new(0, 64, 1, 0),
		Parent = main,
	})
	corner(rail, 14)
	stroke(rail, Theme.StrokeSoft, 0.5)

	-- Right side (rest)
	local shell = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -64, 1, 0),
		Position = UDim2.fromOffset(64, 0),
		Parent = main,
	})

	-- Top bar
	local top = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 66),
		Parent = shell,
	})
	padding(top, 14, 0, 16, 16)

	-- Title left
	local titleLbl = create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -240, 0, 24),
		Font = Fonts.SB,
		Text = title .. "  " .. version,
		TextColor3 = Theme.Text,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = top,
	})

	local subLbl = create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 26),
		Size = UDim2.new(1, -240, 0, 18),
		Font = Fonts.M,
		Text = "Welcome!",
		TextColor3 = Theme.Accent,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = top,
	})

	-- Search box (top right)
	local searchWrap = create("Frame", {
		BackgroundColor3 = Theme.Bg2,
		BackgroundTransparency = 0.08,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.fromOffset(190, 34),
		Parent = top,
	})
	corner(searchWrap, 10)
	stroke(searchWrap, Theme.StrokeSoft, 0.6)

	local searchIcon = create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.fromOffset(20, 34),
		Font = Fonts.SB,
		Text = "⌕",
		TextColor3 = Theme.TextFaint,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = searchWrap,
	})

	local searchBox = create("TextBox", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(32, 0),
		Size = UDim2.new(1, -40, 1, 0),
		Font = Fonts.M,
		Text = "",
		PlaceholderText = "Search...",
		TextColor3 = Theme.TextDim,
		PlaceholderColor3 = Theme.TextFaint,
		TextSize = 12,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = searchWrap,
	})

	-- Close button (top far right)
	local closeBtn = create("TextButton", {
		BackgroundColor3 = Theme.Bg2,
		BackgroundTransparency = 0.08,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -200, 0, 0),
		Size = UDim2.fromOffset(34, 34),
		Text = "✕",
		Font = Fonts.SB,
		TextSize = 14,
		TextColor3 = Theme.TextDim,
		AutoButtonColor = false,
		Parent = top,
	})
	corner(closeBtn, 10)
	stroke(closeBtn, Theme.StrokeSoft, 0.6)

	-- Divider
	local div = create("Frame", {
		BackgroundColor3 = Theme.StrokeSoft,
		BackgroundTransparency = 0.45,
		Size = UDim2.new(1, -32, 0, 1),
		Position = UDim2.fromOffset(16, 66),
		Parent = shell,
	})

	-- Subtab bar (under divider)
	local subBar = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 44),
		Position = UDim2.fromOffset(0, 66),
		Parent = shell,
	})
	padding(subBar, 10, 0, 16, 16)

	local subBtnHolder = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -16, 1, 0),
		Parent = subBar,
	})
	local subBtnLayout = listLayout(subBtnHolder, 14, true)

	-- Pages area
	local pages = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, -(66 + 44)),
		Position = UDim2.fromOffset(0, 66 + 44),
		Parent = shell,
	})
	padding(pages, 6, 14, 16, 16)

	-- Rail logo top
	local logo = create("Frame", {
		BackgroundColor3 = Theme.Accent3,
		BackgroundTransparency = 0.12,
		Size = UDim2.fromOffset(44, 44),
		Position = UDim2.fromOffset(10, 10),
		Parent = rail,
	})
	corner(logo, 12)

	create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Font = Fonts.SB,
		Text = "T",
		TextColor3 = Theme.Text,
		TextSize = 20,
		Parent = logo,
	})

	-- Rail tab buttons holder
	local railBtns = create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(10, 66),
		Size = UDim2.new(1, -20, 1, -140),
		Parent = rail,
	})
	local railLayout = listLayout(railBtns, 10, false)

	-- Rail bottom icons
	local railBottom = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -20, 0, 64),
		Position = UDim2.new(0, 10, 1, -74),
		Parent = rail,
	})

	local railBWrap = create("Frame", {
		BackgroundColor3 = Theme.Bg2,
		BackgroundTransparency = 0.10,
		Size = UDim2.fromScale(1, 1),
		Parent = railBottom,
	})
	corner(railBWrap, 12)
	stroke(railBWrap, Theme.StrokeSoft, 0.6)

	local gear = create("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(44, 44),
		Position = UDim2.fromOffset(0, 10),
		Text = "⚙",
		Font = Fonts.SB,
		TextSize = 18,
		TextColor3 = Theme.TextDim,
		AutoButtonColor = false,
		Parent = railBWrap,
	})

	-- Resize grip
	local grip = create("Frame", {
		BackgroundColor3 = Theme.Bg2,
		BackgroundTransparency = 0.18,
		Size = UDim2.fromOffset(22, 22),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -10, 1, -10),
		Parent = main,
	})
	corner(grip, 8)
	stroke(grip, Theme.StrokeSoft, 0.65)
	create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1,1),
		Font = Fonts.SB,
		Text = "↘",
		TextColor3 = Theme.TextFaint,
		TextSize = 12,
		Parent = grip
	})

	-- Toast container
	local toastHost = create("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -18, 1, -18),
		Size = UDim2.fromOffset(320, 240),
		ZIndex = 50,
		Parent = gui,
	})
	local toastLayout = listLayout(toastHost, 10, false)
	toastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

	-- Window object
	local self: any = setmetatable({}, WindowMT)
	self.Gui = gui
	self.Main = main
	self.Visible = true
	self.Tabs = {}
	self.ActiveTab = nil
	self.ActiveSub = nil
	self._keybind = keybind
	self._blur = blur
	self._subBtnHolder = subBtnHolder
	self._subBtnLayout = subBtnLayout
	self._pages = pages
	self._railBtns = railBtns
	self._searchBox = searchBox
	self._subLbl = subLbl
	self._toastHost = toastHost
	self._config = {} -- widgetId -> value
	self._configStore = {} -- in-memory fallback

	-- Blur animate on show
	tween(blur, Anim.Slow, { Size = 14 })

	--====================================================
	-- Drag window (using top area)
	--====================================================
	do
		local dragging = false
		local dragStart: Vector2? = nil
		local startPos: UDim2? = nil

		top.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = input.Position
				startPos = main.Position
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and dragStart and startPos then
				local delta = input.Position - dragStart
				main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	end

	--====================================================
	-- Resize window
	--====================================================
	do
		local resizing = false
		local start: Vector2? = nil
		local startSize: Vector2? = nil
		local minW, minH = 760, 460
		local maxW, maxH = 1200, 740

		grip.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				resizing = true
				start = input.Position
				startSize = Vector2.new(main.AbsoluteSize.X, main.AbsoluteSize.Y)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				resizing = false
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if not resizing then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement and start and startSize then
				local d = input.Position - start
				local nw = clamp(startSize.X + d.X, minW, maxW)
				local nh = clamp(startSize.Y + d.Y, minH, maxH)
				main.Size = UDim2.fromOffset(nw, nh)
			end
		end)
	end

	--====================================================
	-- Hover animations
	--====================================================
	closeBtn.MouseEnter:Connect(function()
		tween(closeBtn, Anim.Fast, { BackgroundTransparency = 0.02 })
		tween(closeBtn, Anim.Fast, { TextColor3 = Theme.Bad })
	end)
	closeBtn.MouseLeave:Connect(function()
		tween(closeBtn, Anim.Fast, { BackgroundTransparency = 0.08 })
		tween(closeBtn, Anim.Fast, { TextColor3 = Theme.TextDim })
	end)

	closeBtn.MouseButton1Click:Connect(function()
		self:SetVisible(false)
	end)

	-- Gear opens Settings tab (if exists)
	gear.MouseEnter:Connect(function() tween(gear, Anim.Fast, { TextColor3 = Theme.Accent }) end)
	gear.MouseLeave:Connect(function() tween(gear, Anim.Fast, { TextColor3 = Theme.TextDim }) end)
	gear.MouseButton1Click:Connect(function()
		local t = self.Tabs["Settings"]
		if t then
			self:_ActivateTab(t)
		else
			self:Notify("Settings", "Create a Settings tab to use this button.", "warn")
		end
	end)

	-- Keybind toggle
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == self._keybind then
			self:SetVisible(not self.Visible)
		end
	end)

	--====================================================
	-- Notifications
	--====================================================
	function self:Notify(ti: string, body: string, kind: string?)
		kind = kind or "info"
		local accent = Theme.Accent
		if kind == "good" then accent = Theme.Good end
		if kind == "warn" then accent = Theme.Warn end
		if kind == "bad" then accent = Theme.Bad end

		local card = create("Frame", {
			BackgroundColor3 = Theme.Bg2,
			BackgroundTransparency = 0.06,
			Size = UDim2.new(1, 0, 0, 0),
			Parent = toastHost,
			ZIndex = 50,
		})
		corner(card, 12)
		stroke(card, Theme.StrokeSoft, 0.55)

		local bar = create("Frame", {
			BackgroundColor3 = accent,
			BackgroundTransparency = 0.05,
			Size = UDim2.new(0, 3, 1, -16),
			Position = UDim2.fromOffset(10, 8),
			Parent = card,
			ZIndex = 51,
		})
		corner(bar, 2)

		local titleL = create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(20, 10),
			Size = UDim2.new(1, -30, 0, 18),
			Font = Fonts.SB,
			Text = ti,
			TextColor3 = Theme.Text,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 51,
			Parent = card,
		})

		local bodyL = create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(20, 30),
			Size = UDim2.new(1, -30, 0, 36),
			Font = Fonts.M,
			Text = body,
			TextColor3 = Theme.TextFaint,
			TextSize = 12,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 51,
			Parent = card,
		})

		tween(card, Anim.Med, { Size = UDim2.new(1, 0, 0, 74) })

		task.delay(3.2, function()
			if card and card.Parent then
				tween(card, Anim.Med, { BackgroundTransparency = 1 })
				tween(card, Anim.Med, { Size = UDim2.new(1, 0, 0, 0) })
				task.delay(0.25, function()
					if card then card:Destroy() end
				end)
			end
		end)
	end

	--====================================================
	-- Visible toggle
	--====================================================
	function self:SetVisible(v: boolean)
		self.Visible = v
		gui.Enabled = v
		if v then
			tween(self._blur, Anim.Slow, { Size = 14 })
		else
			tween(self._blur, Anim.Slow, { Size = 0 })
		end
	end

	function self:Destroy()
		if self._blur then self._blur:Destroy() end
		if gui then gui:Destroy() end
	end

	function self:SetKeybind(keyCode: Enum.KeyCode)
		self._keybind = keyCode
	end

	--====================================================
	-- Config Save/Load
	--====================================================
	function self:SaveConfig(name: string)
		local payload = HttpService:JSONEncode(self._config)
		local fname = "tyrantui_" .. name .. ".json"

		if hasFS() then
			writefile(fname, payload)
			self:Notify("Config Saved", fname, "good")
		else
			self._configStore[name] = payload
			self:Notify("Config Saved", "Saved in memory (no writefile).", "warn")
		end
	end

	function self:LoadConfig(name: string)
		local fname = "tyrantui_" .. name .. ".json"
		local payload: string? = nil

		if hasFS() then
			if isfile(fname) then
				payload = readfile(fname)
			end
		else
			payload = self._configStore[name]
		end

		if not payload then
			self:Notify("Config", "No config found: " .. name, "bad")
			return
		end

		local decoded
		local ok = pcall(function()
			decoded = HttpService:JSONDecode(payload :: string)
		end)
		if not ok or type(decoded) ~= "table" then
			self:Notify("Config", "Invalid config file.", "bad")
			return
		end

		-- Apply to known widgets
		for id, value in pairs(decoded :: any) do
			local w = (self._widgetIndex and self._widgetIndex[id]) or nil
			if w and w.Apply then
				safeCall(w.Apply, value)
			end
		end

		self:Notify("Config Loaded", name, "good")
	end

	--====================================================
	-- Internal: search filter on active subtab
	--====================================================
	function self:_ApplySearchFilter(text: string)
		local sub = self.ActiveSub
		if not sub then return end

		local q = string.lower((text or ""):gsub("^%s+", ""):gsub("%s+$",""))
		for _, entry: WidgetEntry in ipairs(sub.Widgets) do
			if q == "" then
				entry.setVisible(true)
			else
				entry.setVisible(string.find(entry.searchTokens, q, 1, true) ~= nil)
			end
		end
	end

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		self:_ApplySearchFilter(searchBox.Text)
	end)

	--====================================================
	-- Internal tab activation
	--====================================================
	function self:_ActivateTab(tab: TabObj)
		-- hide current tab
		if self.ActiveTab and self.ActiveTab ~= tab then
			self.ActiveTab.Page.Visible = false
			-- unhighlight rail button
			tween(self.ActiveTab.Button, Anim.Med, { BackgroundTransparency = 1 })
			(self.ActiveTab.Button:FindFirstChild("Icon") :: TextLabel).TextColor3 = Theme.TextFaint
		end

		self.ActiveTab = tab
		tab.Page.Visible = true

		-- highlight rail button
		tween(tab.Button, Anim.Med, { BackgroundTransparency = 0.06 })
		(tab.Button:FindFirstChild("Icon") :: TextLabel).TextColor3 = Theme.Accent

		-- rebuild subtabs bar (NO REPARENTING)
		for _, child in ipairs(subBtnHolder:GetChildren()) do
			if child:IsA("TextButton") then
				child.Visible = false
			end
		end
		for _, sub in pairs(tab.SubTabs) do
			sub.Button.Visible = true
		end

		-- default subtab
		local first: any = nil
		for _, sub in pairs(tab.SubTabs) do first = sub break end
		if first then
			self:_ActivateSub(first)
		end

		-- update subtitle
		self._subLbl.Text = "Welcome to " .. tab.Name .. "!"
	end

	function self:_ActivateSub(sub: SubTabObj)
		-- hide previous
		if self.ActiveSub and self.ActiveSub ~= sub then
			self.ActiveSub.Page.Visible = false
			local prevBtn = self.ActiveSub.Button
			tween(prevBtn, Anim.Med, { BackgroundTransparency = 1 })
			(prevBtn:FindFirstChild("Label") :: TextLabel).TextColor3 = Theme.TextDim
			(prevBtn:FindFirstChild("Underline") :: Frame).BackgroundTransparency = 1
		end

		self.ActiveSub = sub
		sub.Page.Visible = true

		local btn = sub.Button
		tween(btn, Anim.Med, { BackgroundTransparency = 0.88 })
		(btn:FindFirstChild("Label") :: TextLabel).TextColor3 = Theme.Text
		(btn:FindFirstChild("Underline") :: Frame).BackgroundTransparency = 0

		-- apply current search filter to new page
		self:_ApplySearchFilter(self._searchBox.Text)
	end

	--====================================================
	-- Tab builder (public)
	--====================================================
	function self:Tab(name: string, icon: string?)
		icon = icon or "▣"

		-- Rail button
		local btn = create("TextButton", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 44),
			Text = "",
			AutoButtonColor = false,
			Parent = railBtns,
		})
		corner(btn, 12)

		local ico = create("TextLabel", {
			Name = "Icon",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromOffset(44, 44),
			Font = Fonts.SB,
			Text = icon,
			TextColor3 = Theme.TextFaint,
			TextSize = 16,
			Parent = btn,
		})

		btn.MouseEnter:Connect(function()
			tween(btn, Anim.Fast, { BackgroundTransparency = 0.92 })
		end)
		btn.MouseLeave:Connect(function()
			if self.ActiveTab and self.ActiveTab.Button == btn then return end
			tween(btn, Anim.Fast, { BackgroundTransparency = 1 })
		end)

		-- Page for this tab
		local page = create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Visible = false,
			Parent = pages,
		})

		-- Subtab pages holder
		local subPages = create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Parent = page,
		})

		local tab: TabObj = {
			Name = name,
			Icon = icon,
			Button = btn,
			Page = page,
			SubBar = subBar,
			SubButtons = subBtnHolder,
			SubPages = subPages,
			SubTabs = {},
			ActiveSub = nil,
		}

		self.Tabs[name] = tab

		btn.MouseButton1Click:Connect(function()
			self:_ActivateTab(tab)
		end)

		-- Subtab builder
		local TabAPI = {}
		TabAPI.__tab = tab

		function TabAPI:SubTab(subName: string)
			-- Subtab button created ONCE and stays parented (fix for parent-lock)
			local sbtn = create("TextButton", {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(140, 28),
				Text = "",
				AutoButtonColor = false,
				Visible = false, -- only shown when tab is active
				Parent = subBtnHolder,
			})

			local lbl = create("TextLabel", {
				Name = "Label",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Font = Fonts.SB,
				Text = subName,
				TextColor3 = Theme.TextDim,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = sbtn,
			})

			local underline = create("Frame", {
				Name = "Underline",
				BackgroundColor3 = Theme.Accent,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 2),
				Position = UDim2.new(0, 0, 1, -2),
				Parent = sbtn,
			})
			corner(underline, 2)

			-- Subtab scrolling page
			local scroll = create("ScrollingFrame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				ScrollBarThickness = 3,
				ScrollBarImageColor3 = Theme.Accent2,
				ScrollBarImageTransparency = 0.2,
				Visible = false,
				Parent = subPages,
			})

			local layout = listLayout(scroll, 10, false)
			padding(scroll, 8, 14, 6, 6)
			bindAutoCanvas(scroll, layout, 24)

			local sub: SubTabObj = {
				Name = subName,
				Button = sbtn,
				Page = scroll,
				Layout = layout,
				Widgets = {},
			}

			tab.SubTabs[subName] = sub

			sbtn.MouseEnter:Connect(function()
				if self.ActiveSub and self.ActiveSub.Button == sbtn then return end
				tween(lbl, Anim.Fast, { TextColor3 = Theme.Text })
			end)
			sbtn.MouseLeave:Connect(function()
				if self.ActiveSub and self.ActiveSub.Button == sbtn then return end
				tween(lbl, Anim.Fast, { TextColor3 = Theme.TextDim })
			end)

			sbtn.MouseButton1Click:Connect(function()
				self:_ActivateSub(sub)
			end)

			-- Subtab widget API
			local SubAPI = {}
			SubAPI.__sub = sub

			-- register widget for search
			local function registerWidget(kind: string, name2: string, root: Instance, tokens: string)
				local entry: WidgetEntry = {
					kind = kind,
					name = name2,
					root = root,
					searchTokens = string.lower(tokens),
					setVisible = function(v: boolean)
						(root :: any).Visible = v
					end,
				}
				table.insert(sub.Widgets, entry)
			end

			function SubAPI:Section(title2: string, desc: string?)
				local h = desc and 74 or 56
				local card = makeCard(scroll, h)
				makeTitle(card, title2, 12)
				if desc then makeDesc(card, desc, 34) end
				registerWidget("section", title2, card, title2 .. " " .. (desc or ""))
				return card
			end

			function SubAPI:Paragraph(title2: string, body: string)
				local card = makeCard(scroll, 96)
				makeTitle(card, title2, 12)

				local b = create("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(16, 34),
					Size = UDim2.new(1, -32, 0, 52),
					Font = Fonts.M,
					Text = body,
					TextColor3 = Theme.TextFaint,
					TextSize = 12,
					TextWrapped = true,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = card,
				})

				registerWidget("paragraph", title2, card, title2 .. " " .. body)
				return card
			end

			function SubAPI:Toggle(o: any)
				o = o or {}
				local labelText = o.Name or "Toggle"
				local desc = o.Description
				local flag = o.Flag or ("toggle_" .. labelText)
				local value = (o.Default == true)
				local cb = o.Callback

				local card = makeCard(scroll, desc and 78 or 56)
				makeTitle(card, labelText, 10)
				if desc then makeDesc(card, desc, 30) end

				local track = create("Frame", {
					BackgroundColor3 = Theme.Bg1,
					BackgroundTransparency = 0.15,
					Size = UDim2.fromOffset(54, 26),
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -16, 0.5, 0),
					Parent = card,
				})
				corner(track, 999)
				stroke(track, Theme.StrokeSoft, 0.65)

				local knob = create("Frame", {
					BackgroundColor3 = Theme.Text,
					Size = UDim2.fromOffset(20, 20),
					Position = UDim2.fromOffset(4, 3),
					Parent = track,
				})
				corner(knob, 999)

				local hit = create("TextButton", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Text = "",
					Parent = track,
				})

				local function render(v: boolean)
					value = v
					self._config[flag] = v
					if v then
						tween(track, Anim.Med, { BackgroundColor3 = Theme.Accent3, BackgroundTransparency = 0.08 })
						tween(knob, Anim.Med, { Position = UDim2.fromOffset(30, 3) })
					else
						tween(track, Anim.Med, { BackgroundColor3 = Theme.Bg1, BackgroundTransparency = 0.15 })
						tween(knob, Anim.Med, { Position = UDim2.fromOffset(4, 3) })
					end
				end

				local api = {}
				function api:Set(v: boolean)
					render(v)
					if cb then safeCall(cb, v) end -- user can do: autocatch = v
				end
				function api:Get() return value end
				function api:Apply(v) api:Set(v == true) end -- for config load

				hit.MouseButton1Click:Connect(function()
					api:Set(not value)
				end)

				render(value)
				registerWidget("toggle", labelText, card, labelText .. " " .. (desc or ""))
				return api
			end

			function SubAPI:Slider(o: any)
				o = o or {}
				local labelText = o.Name or "Slider"
				local desc = o.Description
				local flag = o.Flag or ("slider_" .. labelText)
				local range = o.Range or {0, 100}
				local minv, maxv = range[1], range[2]
				local step = o.Step or 1
				local suffix = o.Suffix or ""
				local value = o.Default or minv
				local cb = o.Callback

				local card = makeCard(scroll, desc and 92 or 70)
				makeTitle(card, labelText, 10)
				if desc then makeDesc(card, desc, 30) end

				local valueLbl = create("TextLabel", {
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, -16, 0, 10),
					Size = UDim2.fromOffset(220, 18),
					Font = Fonts.M,
					Text = "",
					TextColor3 = Theme.TextDim,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Right,
					Parent = card,
				})

				local barY = desc and 58 or 36
				local bar = create("Frame", {
					BackgroundColor3 = Theme.Bg1,
					BackgroundTransparency = 0.22,
					Position = UDim2.fromOffset(16, barY),
					Size = UDim2.new(1, -32, 0, 10),
					Parent = card,
				})
				corner(bar, 999)
				stroke(bar, Theme.StrokeSoft, 0.75)

				local fill = create("Frame", {
					BackgroundColor3 = Theme.Accent2,
					BackgroundTransparency = 0.05,
					Size = UDim2.fromScale(0, 1),
					Parent = bar,
				})
				corner(fill, 999)

				local knob = create("Frame", {
					BackgroundColor3 = Theme.Text,
					Size = UDim2.fromOffset(14, 14),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0, 0.5),
					Parent = bar,
				})
				corner(knob, 999)

				local hit = create("TextButton", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Text = "",
					Parent = bar,
				})

				local dragging = false

				local function render(v: number, animate: boolean?)
					v = clamp(roundTo(v, step), minv, maxv)
					value = v
					self._config[flag] = v

					local alpha = (v - minv) / (maxv - minv)
					valueLbl.Text = string.format("%s: %.2f%s", labelText, v, suffix)

					if animate then
						tween(fill, Anim.Fast, { Size = UDim2.fromScale(alpha, 1) })
						tween(knob, Anim.Fast, { Position = UDim2.fromScale(alpha, 0.5) })
					else
						fill.Size = UDim2.fromScale(alpha, 1)
						knob.Position = UDim2.fromScale(alpha, 0.5)
					end
				end

				local function valueFromX(x: number)
					local rel = (x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
					rel = clamp(rel, 0, 1)
					return minv + (maxv - minv) * rel
				end

				local api = {}
				function api:Set(v: number)
					render(v, true)
					if cb then safeCall(cb, value) end
				end
				function api:Get() return value end
				function api:Apply(v) api:Set(tonumber(v) or value) end

				hit.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						api:Set(valueFromX(input.Position.X))
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if not dragging then return end
					if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
						api:Set(valueFromX(input.Position.X))
					end
				end)

				render(value, false)
				registerWidget("slider", labelText, card, labelText .. " " .. (desc or "") .. " " .. suffix)
				return api
			end

			-- Dropdown (single select)
			function SubAPI:Dropdown(o: any)
				o = o or {}
				local labelText = o.Name or "Dropdown"
				local desc = o.Description
				local flag = o.Flag or ("dropdown_" .. labelText)
				local options: {string} = o.Options or {"A","B"}
				local value = o.Default or options[1]
				local cb = o.Callback

				local card = makeCard(scroll, desc and 86 or 64)
				makeTitle(card, labelText, 10)
				if desc then makeDesc(card, desc, 30) end

				local box = create("Frame", {
					BackgroundColor3 = Theme.Bg1,
					BackgroundTransparency = 0.12,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -16, 0.5, 0),
					Size = UDim2.fromOffset(190, 34),
					Parent = card,
				})
				corner(box, 10)
				stroke(box, Theme.StrokeSoft, 0.65)

				local valLbl = create("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(12, 0),
					Size = UDim2.new(1, -34, 1, 0),
					Font = Fonts.M,
					Text = tostring(value),
					TextColor3 = Theme.TextDim,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = box,
				})

				local arrow = create("TextLabel", {
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -10, 0.5, 0),
					Size = UDim2.fromOffset(18, 18),
					Font = Fonts.SB,
					Text = "▾",
					TextColor3 = Theme.TextFaint,
					TextSize = 14,
					Parent = box,
				})

				local click = create("TextButton", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Text = "",
					Parent = box,
				})

				local drop = create("Frame", {
					BackgroundColor3 = Theme.Bg2,
					BackgroundTransparency = 0.06,
					ClipsDescendants = true,
					Visible = false,
					Size = UDim2.fromOffset(190, 0),
					Position = UDim2.new(1, -16 - 190, 0, (desc and 78 or 56)),
					Parent = card,
				})
				corner(drop, 10)
				stroke(drop, Theme.StrokeSoft, 0.55)
				padding(drop, 8, 8, 8, 8)
				local dl = listLayout(drop, 6, false)

				local open = false
				local function setOpen(v: boolean)
					open = v
					if v then
						drop.Visible = true
						tween(arrow, Anim.Fast, { Rotation = 180, TextColor3 = Theme.Accent })
						local h = clamp(#options * 30 + (#options-1)*6 + 16, 0, 220)
						tween(drop, Anim.Med, { Size = UDim2.fromOffset(190, h) })
					else
						tween(arrow, Anim.Fast, { Rotation = 0, TextColor3 = Theme.TextFaint })
						tween(drop, Anim.Med, { Size = UDim2.fromOffset(190, 0) })
						task.delay(0.20, function()
							if not open then drop.Visible = false end
						end)
					end
				end

				local function setValue(v: string)
					value = v
					self._config[flag] = v
					valLbl.Text = v
					if cb then safeCall(cb, v) end
				end

				for _, opt in ipairs(options) do
					local item = create("TextButton", {
						BackgroundColor3 = Theme.Bg1,
						BackgroundTransparency = 0.22,
						Size = UDim2.new(1, 0, 0, 30),
						Text = opt,
						Font = Fonts.M,
						TextSize = 12,
						TextColor3 = Theme.TextDim,
						AutoButtonColor = false,
						Parent = drop,
					})
					corner(item, 8)
					stroke(item, Theme.StrokeSoft, 0.8)

					item.MouseEnter:Connect(function()
						tween(item, Anim.Fast, { BackgroundTransparency = 0.08 })
						tween(item, Anim.Fast, { TextColor3 = Theme.Text })
					end)
					item.MouseLeave:Connect(function()
						tween(item, Anim.Fast, { BackgroundTransparency = 0.22 })
						tween(item, Anim.Fast, { TextColor3 = Theme.TextDim })
					end)

					item.MouseButton1Click:Connect(function()
						setValue(opt)
						setOpen(false)
					end)
				end

				click.MouseButton1Click:Connect(function()
					setOpen(not open)
				end)

				setValue(value)

				local api = {}
				function api:Set(v: string) setValue(v) end
				function api:Get() return value end
				function api:Apply(v) api:Set(tostring(v)) end

				registerWidget("dropdown", labelText, card, labelText .. " " .. (desc or "") .. " " .. table.concat(options, " "))
				return api
			end

			-- Multi dropdown
			function SubAPI:MultiDropdown(o: any)
				o = o or {}
				local labelText = o.Name or "Multi Dropdown"
				local desc = o.Description
				local flag = o.Flag or ("multi_" .. labelText)
				local options: {string} = o.Options or {"A","B","C"}
				local selected: {[string]: boolean} = {}
				local cb = o.Callback

				for _, v in ipairs(o.Default or {}) do
					selected[v] = true
				end

				local function selectedList()
					local out = {}
					for _, opt in ipairs(options) do
						if selected[opt] then table.insert(out, opt) end
					end
					return out
				end

				local card = makeCard(scroll, desc and 86 or 64)
				makeTitle(card, labelText, 10)
				if desc then makeDesc(card, desc, 30) end

				local box = create("Frame", {
					BackgroundColor3 = Theme.Bg1,
					BackgroundTransparency = 0.12,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -16, 0.5, 0),
					Size = UDim2.fromOffset(220, 34),
					Parent = card,
				})
				corner(box, 10)
				stroke(box, Theme.StrokeSoft, 0.65)

				local valLbl = create("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(12, 0),
					Size = UDim2.new(1, -34, 1, 0),
					Font = Fonts.M,
					Text = "Select...",
					TextColor3 = Theme.TextDim,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = box,
				})

				local arrow = create("TextLabel", {
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -10, 0.5, 0),
					Size = UDim2.fromOffset(18, 18),
					Font = Fonts.SB,
					Text = "▾",
					TextColor3 = Theme.TextFaint,
					TextSize = 14,
					Parent = box,
				})

				local click = create("TextButton", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Text = "",
					Parent = box,
				})

				local drop = create("Frame", {
					BackgroundColor3 = Theme.Bg2,
					BackgroundTransparency = 0.06,
					ClipsDescendants = true,
					Visible = false,
					Size = UDim2.fromOffset(220, 0),
					Position = UDim2.new(1, -16 - 220, 0, (desc and 78 or 56)),
					Parent = card,
				})
				corner(drop, 10)
				stroke(drop, Theme.StrokeSoft, 0.55)
				padding(drop, 8, 8, 8, 8)
				listLayout(drop, 6, false)

				local open = false
				local function refreshLabel()
					local list = selectedList()
					if #list == 0 then
						valLbl.Text = "Select..."
					else
						valLbl.Text = table.concat(list, ", ")
					end
					self._config[flag] = list
					if cb then safeCall(cb, list) end
				end

				local function setOpen(v: boolean)
					open = v
					if v then
						drop.Visible = true
						tween(arrow, Anim.Fast, { Rotation = 180, TextColor3 = Theme.Accent })
						local h = clamp(#options * 30 + (#options-1)*6 + 16, 0, 240)
						tween(drop, Anim.Med, { Size = UDim2.fromOffset(220, h) })
					else
						tween(arrow, Anim.Fast, { Rotation = 0, TextColor3 = Theme.TextFaint })
						tween(drop, Anim.Med, { Size = UDim2.fromOffset(220, 0) })
						task.delay(0.20, function()
							if not open then drop.Visible = false end
						end)
					end
				end

				for _, opt in ipairs(options) do
					local item = create("TextButton", {
						BackgroundColor3 = Theme.Bg1,
						BackgroundTransparency = 0.22,
						Size = UDim2.new(1, 0, 0, 30),
						Text = "  " .. opt,
						Font = Fonts.M,
						TextSize = 12,
						TextColor3 = Theme.TextDim,
						AutoButtonColor = false,
						Parent = drop,
					})
					corner(item, 8)
					stroke(item, Theme.StrokeSoft, 0.8)

					local check = create("TextLabel", {
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(8, 0),
						Size = UDim2.fromOffset(18, 30),
						Font = Fonts.SB,
						Text = selected[opt] and "✓" or "",
						TextColor3 = Theme.Accent,
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
						Parent = item,
					})

					local function render()
						check.Text = selected[opt] and "✓" or ""
						if selected[opt] then
							tween(item, Anim.Fast, { BackgroundTransparency = 0.08 })
						else
							tween(item, Anim.Fast, { BackgroundTransparency = 0.22 })
						end
					end

					item.MouseButton1Click:Connect(function()
						selected[opt] = not selected[opt]
						render()
						refreshLabel()
					end)

					render()
				end

				click.MouseButton1Click:Connect(function()
					setOpen(not open)
				end)

				refreshLabel()

				local api = {}
				function api:Get() return selectedList() end
				function api:Set(list: {string})
					selected = {}
					for _, v in ipairs(list) do selected[v] = true end
					refreshLabel()
				end
				function api:Apply(v)
					if type(v) == "table" then
						api:Set(v :: any)
					end
				end

				registerWidget("multidropdown", labelText, card, labelText .. " " .. (desc or "") .. " " .. table.concat(options, " "))
				return api
			end

			function SubAPI:Button(o: any)
				o = o or {}
				local labelText = o.Name or "Button"
				local desc = o.Description
				local text = o.Text or "Apply"
				local cb = o.Callback

				local card = makeCard(scroll, desc and 78 or 56)
				makeTitle(card, labelText, 10)
				if desc then makeDesc(card, desc, 30) end

				local btn = create("TextButton", {
					BackgroundColor3 = Theme.Accent3,
					BackgroundTransparency = 0.12,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -16, 0.5, 0),
					Size = UDim2.fromOffset(160, 34),
					Text = text,
					Font = Fonts.SB,
					TextSize = 12,
					TextColor3 = Theme.Text,
					AutoButtonColor = false,
					Parent = card,
				})
				corner(btn, 10)
				stroke(btn, Theme.Accent2, 0.45)

				btn.MouseEnter:Connect(function()
					tween(btn, Anim.Fast, { BackgroundTransparency = 0.03 })
				end)
				btn.MouseLeave:Connect(function()
					tween(btn, Anim.Fast, { BackgroundTransparency = 0.12 })
				end)
				btn.MouseButton1Click:Connect(function()
					if cb then safeCall(cb) end
				end)

				registerWidget("button", labelText, card, labelText .. " " .. (desc or "") .. " " .. text)
				return btn
			end

			-- Keybind widget (in Settings tab recommended)
			function SubAPI:Keybind(o: any)
				o = o or {}
				local labelText = o.Name or "Keybind"
				local desc = o.Description or "Press a key to set your UI toggle key."
				local defaultKey: Enum.KeyCode = o.Default or self._keybind

				local card = makeCard(scroll, 78)
				makeTitle(card, labelText, 10)
				makeDesc(card, desc, 30)

				local btn = create("TextButton", {
					BackgroundColor3 = Theme.Bg1,
					BackgroundTransparency = 0.12,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -16, 0.5, 0),
					Size = UDim2.fromOffset(160, 34),
					Text = defaultKey.Name,
					Font = Fonts.SB,
					TextSize = 12,
					TextColor3 = Theme.Text,
					AutoButtonColor = false,
					Parent = card,
				})
				corner(btn, 10)
				stroke(btn, Theme.StrokeSoft, 0.65)

				local waiting = false
				btn.MouseButton1Click:Connect(function()
					if waiting then return end
					waiting = true
					btn.Text = "Press a key..."
					self:Notify("Keybind", "Press any key now.", "info")

					local conn
					conn = UserInputService.InputBegan:Connect(function(input, gp)
						if gp then return end
						if input.UserInputType == Enum.UserInputType.Keyboard then
							conn:Disconnect()
							waiting = false
							self:SetKeybind(input.KeyCode)
							btn.Text = input.KeyCode.Name
							self:Notify("Keybind", "Set to " .. input.KeyCode.Name, "good")
						end
					end)
				end)

				registerWidget("keybind", labelText, card, labelText .. " " .. desc)
				return btn
			end

			-- Config widgets
			function SubAPI:Config(o: any)
				o = o or {}
				local card = makeCard(scroll, 92)
				makeTitle(card, "Config", 10)
				makeDesc(card, "Save / Load your settings.", 30)

				local nameBox = create("TextBox", {
					BackgroundColor3 = Theme.Bg1,
					BackgroundTransparency = 0.12,
					Position = UDim2.fromOffset(16, 56),
					Size = UDim2.new(1, -16 - 16 - 220, 0, 30),
					Font = Fonts.M,
					Text = "default",
					PlaceholderText = "config name",
					TextColor3 = Theme.TextDim,
					PlaceholderColor3 = Theme.TextFaint,
					TextSize = 12,
					ClearTextOnFocus = false,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = card,
				})
				corner(nameBox, 10)
				stroke(nameBox, Theme.StrokeSoft, 0.65)
				padding(nameBox, 0, 0, 10, 10)

				local saveBtn = create("TextButton", {
					BackgroundColor3 = Theme.Accent3,
					BackgroundTransparency = 0.12,
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, -16, 0, 56),
					Size = UDim2.fromOffset(100, 30),
					Text = "Save",
					Font = Fonts.SB,
					TextSize = 12,
					TextColor3 = Theme.Text,
					AutoButtonColor = false,
					Parent = card,
				})
				corner(saveBtn, 10)
				stroke(saveBtn, Theme.Accent2, 0.45)

				local loadBtn = create("TextButton", {
					BackgroundColor3 = Theme.Bg1,
					BackgroundTransparency = 0.12,
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, -16 - 110, 0, 56),
					Size = UDim2.fromOffset(100, 30),
					Text = "Load",
					Font = Fonts.SB,
					TextSize = 12,
					TextColor3 = Theme.Text,
					AutoButtonColor = false,
					Parent = card,
				})
				corner(loadBtn, 10)
				stroke(loadBtn, Theme.StrokeSoft, 0.65)

				saveBtn.MouseButton1Click:Connect(function()
					self:SaveConfig(nameBox.Text)
				end)
				loadBtn.MouseButton1Click:Connect(function()
					self:LoadConfig(nameBox.Text)
				end)

				registerWidget("config", "Config", card, "config save load")
				return card
			end

			return SubAPI
		end

		return TabAPI
	end

	-- Widget index for config applying
	self._widgetIndex = {} :: any
	-- Hook: when widgets are created, they can store into _widgetIndex via returned api if desired.
	-- (In this file, Apply exists on Toggle/Slider/Dropdown/Multi.)

	-- Auto-activate first tab once user creates one
	task.defer(function()
		-- no auto until tab added; user controls via calling window.Tabs...
	end)

	-- nice intro toast
	self:Notify(title, "UI loaded (purple theme).", "good")

	return (self :: any) :: Window
end

return TyrantUI
