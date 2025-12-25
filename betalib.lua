--!strict
-- TyrantUI.lua (single-file UI library)
-- Layout inspired by the screenshots: left rail tabs + right content + top header + subtabs
-- Purple theme, smooth tweens, toggles/sliders/dropdowns/tabs/subtabs

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

--// tiny helper
local function clamp(n: number, a: number, b: number): number
	if n < a then return a end
	if n > b then return b end
	return n
end

local function round(n: number, step: number): number
	if step <= 0 then return n end
	return math.floor((n / step) + 0.5) * step
end

local function tween(obj: Instance, ti: TweenInfo, props: {[string]: any})
	local t = TweenService:Create(obj, ti, props)
	t:Play()
	return t
end

local function create(className: string, props: {[string]: any}?, children: {Instance}?): Instance
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

--// Theme
local Theme = {
	Bg0 = Color3.fromRGB(10, 10, 14),
	Bg1 = Color3.fromRGB(14, 14, 20),
	Bg2 = Color3.fromRGB(18, 18, 26),

	Stroke = Color3.fromRGB(32, 32, 45),
	StrokeSoft = Color3.fromRGB(28, 28, 40),

	Text = Color3.fromRGB(235, 235, 245),
	TextDim = Color3.fromRGB(160, 160, 175),
	TextFaint = Color3.fromRGB(120, 120, 135),

	Purple = Color3.fromRGB(150, 80, 255),
	Purple2 = Color3.fromRGB(120, 60, 230),
	Purple3 = Color3.fromRGB(95, 45, 190),

	Success = Color3.fromRGB(80, 220, 140),
	Warn = Color3.fromRGB(255, 200, 80),

	Shadow = Color3.fromRGB(0, 0, 0),
}

local Fonts = {
	Semibold = Enum.Font.GothamSemibold,
	Medium = Enum.Font.GothamMedium,
	Regular = Enum.Font.Gotham,
	Mono = Enum.Font.Code,
}

local Anim = {
	Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Med = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Slow = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
}

--// Library object
local TyrantUI = {}

export type Window = {
	Gui: ScreenGui,
	Main: Frame,
	Sidebar: Frame,
	Content: Frame,

	Tabs: {[string]: any},
	ActiveTab: any?,
	ActiveSubTab: any?,

	SetVisible: (self: Window, v: boolean) -> (),
	Destroy: (self: Window) -> (),

	CreateTab: (self: Window, tabTopName: string, tabSideName: string?, iconText: string?) -> any,
}

export type Tab = {
	Name: string,
	Button: TextButton,
	Page: Frame,
	SubTabs: {[string]: any},
	ActiveSubTab: any?,

	Show: (self: Tab) -> (),
	Hide: (self: Tab) -> (),
	CreateSubTab: (self: Tab, name: string) -> any,
}

export type SubTab = {
	Name: string,
	Button: TextButton,
	Container: ScrollingFrame,
	Layout: UIListLayout,

	Show: (self: SubTab) -> (),
	Hide: (self: SubTab) -> (),

	AddSection: (self: SubTab, title: string, desc: string?) -> Frame,
	AddToggle: (self: SubTab, opts: any) -> any,
	AddSlider: (self: SubTab, opts: any) -> any,
	AddDropdown: (self: SubTab, opts: any) -> any,
	AddButton: (self: SubTab, opts: any) -> any,
	AddParagraph: (self: SubTab, title: string, body: string) -> any,
}

--// Core widget styles
local function applyCorner(inst: Instance, r: number)
	create("UICorner", {CornerRadius = UDim.new(0, r), Parent = inst})
end

local function applyStroke(inst: Instance, transparency: number?, color: Color3?)
	local s = create("UIStroke", {
		Color = color or Theme.StrokeSoft,
		Thickness = 1,
		Transparency = transparency or 0.35,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = inst,
	})
	return s
end

local function textLabel(props: any)
	return create("TextLabel", {
		BackgroundTransparency = 1,
		Font = props.Font or Fonts.Medium,
		Text = props.Text or "",
		TextColor3 = props.Color or Theme.Text,
		TextSize = props.Size or 14,
		TextXAlignment = props.XAlign or Enum.TextXAlignment.Left,
		TextYAlignment = props.YAlign or Enum.TextYAlignment.Center,
		RichText = true,
		AutomaticSize = props.AutoSize or Enum.AutomaticSize.None,
		Size = props.SizeUDim2 or UDim2.fromOffset(100, 20),
	})
end

local function iconPill(parent: Instance, iconText: string)
	local pill = create("Frame", {
		BackgroundColor3 = Theme.Bg2,
		BackgroundTransparency = 0.05,
		Size = UDim2.fromOffset(36, 36),
		Parent = parent,
	})
	applyCorner(pill, 10)
	applyStroke(pill, 0.45, Theme.Stroke)

	local inner = create("Frame", {
		BackgroundColor3 = Theme.Purple3,
		BackgroundTransparency = 0.15,
		Size = UDim2.fromOffset(36, 36),
		Parent = pill,
	})
	applyCorner(inner, 10)

	local t = create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Font = Fonts.Semibold,
		Text = iconText,
		TextColor3 = Theme.Text,
		TextSize = 18,
		Parent = inner,
	})

	return pill
end

local function makeShadow(parent: Instance, size: UDim2, pos: UDim2, z: number)
	local sh = create("ImageLabel", {
		BackgroundTransparency = 1,
		Image = "rbxassetid://1316045217", -- soft circle gradient
		ImageColor3 = Theme.Shadow,
		ImageTransparency = 0.65,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(10, 10, 118, 118),
		Size = size,
		Position = pos,
		ZIndex = z,
		Parent = parent,
	})
	return sh
end

--// Scroll auto canvas
local function bindAutoCanvas(scroll: ScrollingFrame, layout: UIListLayout, padBottom: number?)
	local function recalc()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + (padBottom or 18))
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(recalc)
	task.defer(recalc)
end

--// Window creation
function TyrantUI:CreateWindow(opts: any): Window
	opts = opts or {}
	local title = opts.Title or "Tyrant Hub"
	local version = opts.Version or "v1.0"
	local keybind = opts.Keybind or Enum.KeyCode.RightShift

	-- ScreenGui
	local gui = create("ScreenGui", {
		Name = "TyrantUI",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui"),
	})

	-- Main container
	local main = create("Frame", {
		BackgroundColor3 = Theme.Bg1,
		BackgroundTransparency = 0.05,
		Size = UDim2.fromOffset(880, 520),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Parent = gui,
	})
	applyCorner(main, 14)
	applyStroke(main, 0.25, Theme.Stroke)

	makeShadow(gui, UDim2.fromOffset(940, 580), UDim2.fromScale(0.5, 0.5) - UDim2.fromOffset(470, 290), 0).AnchorPoint = Vector2.new(0,0)

	-- Sidebar (left)
	local sidebar = create("Frame", {
		BackgroundColor3 = Theme.Bg0,
		BackgroundTransparency = 0.12,
		Size = UDim2.new(0, 240, 1, 0),
		Parent = main,
	})
	applyCorner(sidebar, 14)
	applyStroke(sidebar, 0.45, Theme.StrokeSoft)

	-- Content (right)
	local content = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -240, 1, 0),
		Position = UDim2.new(0, 240, 0, 0),
		Parent = main,
	})

	-- Sidebar header
	local sideHeader = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -20, 0, 64),
		Position = UDim2.new(0, 10, 0, 10),
		Parent = sidebar,
	})

	local logo = iconPill(sideHeader, "T")
	logo.Position = UDim2.fromOffset(0, 0)

	local titleLbl = create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(50, 6),
		Size = UDim2.new(1, -60, 0, 22),
		Font = Fonts.Semibold,
		Text = ("<font color=\"#%s\">%s</font> <font color=\"#%s\">%s</font>")
			:format(
				string.format("%02X%02X%02X", Theme.Purple.R*255, Theme.Purple.G*255, Theme.Purple.B*255),
				title,
				string.format("%02X%02X%02X", Theme.TextFaint.R*255, Theme.TextFaint.G*255, Theme.TextFaint.B*255),
				version
			),
		RichText = true,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Theme.Text,
		Parent = sideHeader,
	})

	-- Section label "MAIN"
	local mainLabel = create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 84),
		Size = UDim2.new(1, -24, 0, 18),
		Font = Fonts.Medium,
		Text = "MAIN",
		TextColor3 = Theme.TextFaint,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = sidebar,
	})

	-- Tabs list
	local tabList = create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(10, 108),
		Size = UDim2.new(1, -20, 1, -170),
		Parent = sidebar,
	})

	local tabLayout = create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = tabList,
	})

	-- Sidebar bottom icons
	local sideBottom = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -20, 0, 52),
		Position = UDim2.new(0, 10, 1, -62),
		Parent = sidebar,
	})

	local bottomHolder = create("Frame", {
		BackgroundColor3 = Theme.Bg2,
		BackgroundTransparency = 0.08,
		Size = UDim2.fromScale(1, 1),
		Parent = sideBottom,
	})
	applyCorner(bottomHolder, 12)
	applyStroke(bottomHolder, 0.55, Theme.StrokeSoft)

	local chatBtn = create("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(40, 40),
		Position = UDim2.fromOffset(10, 6),
		Text = "💬",
		TextSize = 18,
		Font = Fonts.Semibold,
		TextColor3 = Theme.TextDim,
		Parent = bottomHolder,
	})
	local gearBtn = create("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(40, 40),
		Position = UDim2.fromOffset(54, 6),
		Text = "⚙",
		TextSize = 18,
		Font = Fonts.Semibold,
		TextColor3 = Theme.TextDim,
		Parent = bottomHolder,
	})

	-- Content header (right top)
	local header = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -24, 0, 70),
		Position = UDim2.fromOffset(12, 10),
		Parent = content,
	})

	local pageTitle = create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -16, 0, 28),
		Font = Fonts.Semibold,
		Text = "Catching",
		TextColor3 = Theme.Text,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})

	local pageSubtitle = create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(8, 30),
		Size = UDim2.new(1, -16, 0, 20),
		Font = Fonts.Medium,
		Text = "Welcome to Catching!",
		TextColor3 = Theme.Purple,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})

	-- Subtabs bar
	local subBar = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -24, 0, 38),
		Position = UDim2.fromOffset(12, 80),
		Parent = content,
	})

	local subLayout = create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = subBar,
	})

	-- Divider under header+subtabs
	local divider = create("Frame", {
		BackgroundColor3 = Theme.StrokeSoft,
		BackgroundTransparency = 0.4,
		Size = UDim2.new(1, -24, 0, 1),
		Position = UDim2.fromOffset(12, 120),
		Parent = content,
	})

	-- Pages host
	local pages = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -24, 1, -132),
		Position = UDim2.fromOffset(12, 132),
		Parent = content,
	})

	-- Window object
	local window = {} :: any
	window.Gui = gui
	window.Main = main
	window.Sidebar = sidebar
	window.Content = content
	window.Tabs = {}
	window.ActiveTab = nil
	window.ActiveSubTab = nil

	-- Visibility toggle
	local visible = true
	function window:SetVisible(v: boolean)
		visible = v
		gui.Enabled = v
	end

	function window:Destroy()
		gui:Destroy()
	end

	-- Dragging (top bar drag, simple)
	do
		local dragging = false
		local dragStart: Vector2? = nil
		local startPos: UDim2? = nil

		main.InputBegan:Connect(function(input)
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

	-- Keybind hide/show
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == keybind then
			window:SetVisible(not visible)
		end
	end)

	-- Internal: set header titles
	local function setHeader(tabName: string, subtitle: string?)
		pageTitle.Text = tabName
		pageSubtitle.Text = subtitle or ("Welcome to " .. tabName .. "!")
	end

	-- Internal: clear subtabs bar
	local function clearSubBar()
		for _, child in ipairs(subBar:GetChildren()) do
			if child:IsA("TextButton") or child:IsA("Frame") then
				child:Destroy()
			end
		end
	end

	-- Tab factory
	function window:CreateTab(tabTopName: string, tabSideName: string?, iconText: string?)
		tabSideName = tabSideName or tabTopName
		iconText = iconText or "↻"

		-- Sidebar tab button
		local btn = create("TextButton", {
			BackgroundColor3 = Theme.Bg2,
			BackgroundTransparency = 0.12,
			Size = UDim2.new(1, 0, 0, 44),
			Text = "",
			AutoButtonColor = false,
			Parent = tabList,
		})
		applyCorner(btn, 10)
		local st = applyStroke(btn, 0.6, Theme.StrokeSoft)

		local ico = create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.fromOffset(28, 44),
			Font = Fonts.Semibold,
			Text = iconText,
			TextColor3 = Theme.Purple,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = btn,
		})

		local nameLbl = create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(40, 0),
			Size = UDim2.new(1, -52, 1, 0),
			Font = Fonts.Semibold,
			Text = tabSideName,
			TextColor3 = Theme.Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = btn,
		})

		-- Page frame
		local page = create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Visible = false,
			Parent = pages,
		})

		local tab = {} :: any
		tab.Name = tabTopName
		tab.Button = btn
		tab.Page = page
		tab.SubTabs = {}
		tab.ActiveSubTab = nil

		-- Subtabs host per tab (buttons created dynamically into subBar)
		local function activateSub(sub: any)
			-- hide old
			if tab.ActiveSubTab and tab.ActiveSubTab ~= sub then
				tab.ActiveSubTab:Hide()
			end
			tab.ActiveSubTab = sub
			window.ActiveSubTab = sub
			sub:Show()
		end

		function tab:Show()
			-- hide other tabs
			if window.ActiveTab and window.ActiveTab ~= tab then
				window.ActiveTab:Hide()
			end
			window.ActiveTab = tab

			-- visuals on sidebar tab
			tween(btn, Anim.Med, {BackgroundTransparency = 0.02})
			tween(st, Anim.Med, {Transparency = 0.25})
			tween(ico, Anim.Med, {TextColor3 = Theme.Purple})
			tween(nameLbl, Anim.Med, {TextColor3 = Theme.Text})

			-- show page
			page.Visible = true

			-- update header
			setHeader(tabTopName, opts.SubtitleMap and opts.SubtitleMap[tabTopName] or nil)

			-- rebuild subtabs bar for this tab
			clearSubBar()
			for _, sub in pairs(tab.SubTabs) do
				sub.Button.Parent = subBar
			end

			-- activate first subtab
			local first = nil
			for _, sub in pairs(tab.SubTabs) do
				first = sub
				break
			end
			if first then
				activateSub(first)
			end
		end

		function tab:Hide()
			-- reset sidebar tab visuals
			tween(btn, Anim.Med, {BackgroundTransparency = 0.12})
			tween(st, Anim.Med, {Transparency = 0.6})
			tween(ico, Anim.Med, {TextColor3 = Theme.TextFaint})
			tween(nameLbl, Anim.Med, {TextColor3 = Theme.TextDim})

			page.Visible = false
			if tab.ActiveSubTab then
				tab.ActiveSubTab:Hide()
			end
		end

		function tab:CreateSubTab(name: string)
			-- Subtab button (top row)
			local subBtn = create("TextButton", {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(120, 34),
				Text = "",
				AutoButtonColor = false,
				Parent = nil, -- attached when tab active
			})

			local label = create("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Font = Fonts.Semibold,
				Text = name,
				TextColor3 = Theme.TextDim,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = subBtn,
			})

			local underline = create("Frame", {
				BackgroundColor3 = Theme.Purple,
				BackgroundTransparency = 1, -- hidden until active
				Size = UDim2.new(1, 0, 0, 2),
				Position = UDim2.new(0, 0, 1, -2),
				Parent = subBtn,
			})
			applyCorner(underline, 2)

			-- Container scroll inside page
			local scroll = create("ScrollingFrame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				ScrollBarThickness = 3,
				ScrollBarImageColor3 = Theme.Purple2,
				ScrollBarImageTransparency = 0.15,
				Visible = false,
				Parent = page,
			})

			local layout = create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 10),
				Parent = scroll,
			})
			create("UIPadding", {
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 12),
				PaddingLeft = UDim.new(0, 6),
				PaddingRight = UDim.new(0, 6),
				Parent = scroll,
			})

			bindAutoCanvas(scroll, layout, 24)

			local sub = {} :: any
			sub.Name = name
			sub.Button = subBtn
			sub.Container = scroll
			sub.Layout = layout

			function sub:Show()
				-- deactivate other subtabs
				for _, s in pairs(tab.SubTabs) do
					if s ~= sub then
						s:Hide()
					end
				end
				scroll.Visible = true
				tween(label, Anim.Med, {TextColor3 = Theme.Text})
				tween(underline, Anim.Med, {BackgroundTransparency = 0})
			end

			function sub:Hide()
				scroll.Visible = false
				tween(label, Anim.Med, {TextColor3 = Theme.TextDim})
				tween(underline, Anim.Med, {BackgroundTransparency = 1})
			end

			-- Click subtab
			subBtn.MouseButton1Click:Connect(function()
				activateSub(sub)
			end)

			-- Widgets
			local function cardBase(height: number)
				local card = create("Frame", {
					BackgroundColor3 = Theme.Bg2,
					BackgroundTransparency = 0.08,
					Size = UDim2.new(1, -6, 0, height),
					Parent = scroll,
				})
				applyCorner(card, 12)
				applyStroke(card, 0.6, Theme.StrokeSoft)
				return card
			end

			function sub:AddSection(title: string, desc: string?)
				local card = cardBase(desc and 74 or 56)

				local t = create("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(16, 12),
					Size = UDim2.new(1, -32, 0, 18),
					Font = Fonts.Semibold,
					Text = title,
					TextColor3 = Theme.Text,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = card,
				})

				if desc then
					local d = create("TextLabel", {
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(16, 34),
						Size = UDim2.new(1, -32, 0, 18),
						Font = Fonts.Medium,
						Text = desc,
						TextColor3 = Theme.TextFaint,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						Parent = card,
					})
				end

				return card
			end

			function sub:AddParagraph(title: string, body: string)
				local card = cardBase(90)

				local t = create("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(16, 12),
					Size = UDim2.new(1, -32, 0, 18),
					Font = Fonts.Semibold,
					Text = title,
					TextColor3 = Theme.Text,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = card,
				})

				local b = create("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(16, 34),
					Size = UDim2.new(1, -32, 0, 46),
					Font = Fonts.Medium,
					Text = body,
					TextColor3 = Theme.TextFaint,
					TextSize = 12,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					Parent = card,
				})

				return card
			end

			function sub:AddToggle(o: any)
				o = o or {}
				local name = o.Name or "Toggle"
				local desc = o.Description
				local state = (o.CurrentValue == true)
				local callback = o.Callback

				local card = cardBase(desc and 78 or 56)

				local nameLbl2 = create("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(16, 10),
					Size = UDim2.new(1, -120, 0, 18),
					Font = Fonts.Semibold,
					Text = name,
					TextColor3 = Theme.TextDim,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = card,
				})

				if desc then
					create("TextLabel", {
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(16, 30),
						Size = UDim2.new(1, -120, 0, 18),
						Font = Fonts.Medium,
						Text = desc,
						TextColor3 = Theme.TextFaint,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						Parent = card,
					})
				end

				local toggle = create("Frame", {
					BackgroundColor3 = Theme.Bg1,
					BackgroundTransparency = 0.15,
					Size = UDim2.fromOffset(52, 26),
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -16, 0.5, 0),
					Parent = card,
				})
				applyCorner(toggle, 999)
				applyStroke(toggle, 0.65, Theme.StrokeSoft)

				local knob = create("Frame", {
					BackgroundColor3 = Theme.Text,
					Size = UDim2.fromOffset(20, 20),
					Position = UDim2.fromOffset(4, 3),
					Parent = toggle,
				})
				applyCorner(knob, 999)

				local hit = create("TextButton", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Text = "",
					Parent = toggle,
				})

				local function render(v: boolean)
					state = v
					if v then
						tween(toggle, Anim.Med, {BackgroundColor3 = Theme.Purple3, BackgroundTransparency = 0.08})
						tween(knob, Anim.Med, {Position = UDim2.fromOffset(28, 3)})
						tween(nameLbl2, Anim.Med, {TextColor3 = Theme.Text})
					else
						tween(toggle, Anim.Med, {BackgroundColor3 = Theme.Bg1, BackgroundTransparency = 0.15})
						tween(knob, Anim.Med, {Position = UDim2.fromOffset(4, 3)})
						tween(nameLbl2, Anim.Med, {TextColor3 = Theme.TextDim})
					end
				end

				local function set(v: boolean)
					render(v)
					if callback then
						task.spawn(function()
							pcall(callback, v)
						end)
					end
				end

				hit.MouseButton1Click:Connect(function()
					set(not state)
				end)

				render(state)

				return {
					Set = set,
					Get = function() return state end,
					Frame = card,
				}
			end

			function sub:AddSlider(o: any)
				o = o or {}
				local name = o.Name or "Slider"
				local desc = o.Description
				local range = o.Range or {0, 100}
				local minv = range[1]
				local maxv = range[2]
				local step = o.Increment or 1
				local suffix = o.Suffix or ""
				local value = o.CurrentValue or minv
				local callback = o.Callback

				local card = cardBase(desc and 92 or 70)

				local nameLbl2 = create("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(16, 10),
					Size = UDim2.new(1, -32, 0, 18),
					Font = Fonts.Semibold,
					Text = name,
					TextColor3 = Theme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = card,
				})

				if desc then
					create("TextLabel", {
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(16, 30),
						Size = UDim2.new(1, -32, 0, 18),
						Font = Fonts.Medium,
						Text = desc,
						TextColor3 = Theme.TextFaint,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						Parent = card,
					})
				end

				local valLbl = create("TextLabel", {
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, -16, 0, 10),
					Size = UDim2.fromOffset(170, 18),
					Font = Fonts.Medium,
					Text = "",
					TextColor3 = Theme.TextDim,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Right,
					Parent = card,
				})

				local bar = create("Frame", {
					BackgroundColor3 = Theme.Bg1,
					BackgroundTransparency = 0.22,
					Position = UDim2.fromOffset(16, desc and 58 or 36),
					Size = UDim2.new(1, -32, 0, 10),
					Parent = card,
				})
				applyCorner(bar, 999)
				applyStroke(bar, 0.75, Theme.StrokeSoft)

				local fill = create("Frame", {
					BackgroundColor3 = Theme.Purple2,
					BackgroundTransparency = 0.05,
					Size = UDim2.fromScale(0, 1),
					Parent = bar,
				})
				applyCorner(fill, 999)

				local knob = create("Frame", {
					BackgroundColor3 = Theme.Text,
					Size = UDim2.fromOffset(14, 14),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0, 0.5),
					Parent = bar,
				})
				applyCorner(knob, 999)

				local hit = create("TextButton", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Text = "",
					Parent = bar,
				})

				local dragging = false

				local function render(v: number)
					value = clamp(round(v, step), minv, maxv)
					local a = (value - minv) / (maxv - minv)
					fill.Size = UDim2.fromScale(a, 1)
					knob.Position = UDim2.fromScale(a, 0.5)
					valLbl.Text = string.format("%.2f%s", value, suffix)
				end

				local function set(v: number)
					render(v)
					if callback then
						task.spawn(function()
							pcall(callback, value)
						end)
					end
				end

				local function valueFromX(x: number)
					local rel = (x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
					rel = clamp(rel, 0, 1)
					return minv + (maxv - minv) * rel
				end

				hit.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						set(valueFromX(input.Position.X))
					end
				end)
				hit.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if not dragging then return end
					if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
						set(valueFromX(input.Position.X))
					end
				end)

				render(value)

				return {
					Set = set,
					Get = function() return value end,
					Frame = card,
				}
			end

			function sub:AddDropdown(o: any)
				o = o or {}
				local name = o.Name or "Dropdown"
				local desc = o.Description
				local options: {string} = o.Options or {"Option A", "Option B"}
				local current = o.CurrentOption or options[1]
				local callback = o.Callback

				local card = cardBase(desc and 86 or 64)

				create("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(16, 10),
					Size = UDim2.new(1, -200, 0, 18),
					Font = Fonts.Semibold,
					Text = name,
					TextColor3 = Theme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = card,
				})

				if desc then
					create("TextLabel", {
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(16, 30),
						Size = UDim2.new(1, -200, 0, 18),
						Font = Fonts.Medium,
						Text = desc,
						TextColor3 = Theme.TextFaint,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						Parent = card,
					})
				end

				local box = create("Frame", {
					BackgroundColor3 = Theme.Bg1,
					BackgroundTransparency = 0.12,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -16, 0.5, 0),
					Size = UDim2.fromOffset(170, 34),
					Parent = card,
				})
				applyCorner(box, 10)
				applyStroke(box, 0.65, Theme.StrokeSoft)

				local val = create("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(12, 0),
					Size = UDim2.new(1, -34, 1, 0),
					Font = Fonts.Medium,
					Text = tostring(current),
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
					Font = Fonts.Semibold,
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

				local open = false
				local listFrame = create("Frame", {
					BackgroundColor3 = Theme.Bg2,
					BackgroundTransparency = 0.06,
					Visible = false,
					ClipsDescendants = true,
					Position = UDim2.new(1, -16 - 170, 0, (desc and 78 or 56)),
					Size = UDim2.fromOffset(170, 0),
					Parent = card,
				})
				applyCorner(listFrame, 10)
				applyStroke(listFrame, 0.55, Theme.StrokeSoft)

				local list = create("UIListLayout", {
					Padding = UDim.new(0, 6),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = listFrame,
				})
				create("UIPadding", {
					PaddingTop = UDim.new(0, 8),
					PaddingBottom = UDim.new(0, 8),
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					Parent = listFrame,
				})

				local function closeList()
					open = false
					tween(arrow, Anim.Fast, {Rotation = 0, TextColor3 = Theme.TextFaint})
					tween(listFrame, Anim.Med, {Size = UDim2.fromOffset(170, 0)})
					task.delay(0.2, function()
						if not open then listFrame.Visible = false end
					end)
				end

				local function openList()
					open = true
					listFrame.Visible = true
					tween(arrow, Anim.Fast, {Rotation = 180, TextColor3 = Theme.Purple})
					local height = (#options * 30) + 16 + ((#options - 1) * 6)
					height = clamp(height, 0, 210)
					tween(listFrame, Anim.Med, {Size = UDim2.fromOffset(170, height)})
				end

				local function setOption(opt: string)
					current = opt
					val.Text = opt
					if callback then
						task.spawn(function()
							pcall(callback, opt)
						end)
					end
				end

				for i, opt in ipairs(options) do
					local item = create("TextButton", {
						BackgroundColor3 = Theme.Bg1,
						BackgroundTransparency = 0.22,
						Size = UDim2.new(1, 0, 0, 30),
						Text = opt,
						Font = Fonts.Medium,
						TextSize = 12,
						TextColor3 = Theme.TextDim,
						AutoButtonColor = false,
						Parent = listFrame,
					})
					applyCorner(item, 8)
					applyStroke(item, 0.8, Theme.StrokeSoft)

					item.MouseEnter:Connect(function()
						tween(item, Anim.Fast, {BackgroundTransparency = 0.08})
						tween(item, Anim.Fast, {TextColor3 = Theme.Text})
					end)
					item.MouseLeave:Connect(function()
						tween(item, Anim.Fast, {BackgroundTransparency = 0.22})
						tween(item, Anim.Fast, {TextColor3 = Theme.TextDim})
					end)

					item.MouseButton1Click:Connect(function()
						setOption(opt)
						closeList()
					end)
				end

				click.MouseButton1Click:Connect(function()
					if open then closeList() else openList() end
				end)

				return {
					Set = setOption,
					Get = function() return current end,
					Frame = card,
				}
			end

			function sub:AddButton(o: any)
				o = o or {}
				local name = o.Name or "Button"
				local desc = o.Description
				local callback = o.Callback

				local card = cardBase(desc and 78 or 56)

				create("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(16, 10),
					Size = UDim2.new(1, -200, 0, 18),
					Font = Fonts.Semibold,
					Text = name,
					TextColor3 = Theme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = card,
				})

				if desc then
					create("TextLabel", {
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(16, 30),
						Size = UDim2.new(1, -200, 0, 18),
						Font = Fonts.Medium,
						Text = desc,
						TextColor3 = Theme.TextFaint,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						Parent = card,
					})
				end

				local btn = create("TextButton", {
					BackgroundColor3 = Theme.Purple3,
					BackgroundTransparency = 0.12,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -16, 0.5, 0),
					Size = UDim2.fromOffset(140, 34),
					Text = "Apply",
					Font = Fonts.Semibold,
					TextSize = 12,
					TextColor3 = Theme.Text,
					AutoButtonColor = false,
					Parent = card,
				})
				applyCorner(btn, 10)
				applyStroke(btn, 0.4, Theme.Purple2)

				btn.MouseEnter:Connect(function()
					tween(btn, Anim.Fast, {BackgroundTransparency = 0.02})
				end)
				btn.MouseLeave:Connect(function()
					tween(btn, Anim.Fast, {BackgroundTransparency = 0.12})
				end)

				btn.MouseButton1Click:Connect(function()
					if callback then
						task.spawn(function()
							pcall(callback)
						end)
					end
				end)

				return {
					Press = function()
						if callback then pcall(callback) end
					end,
					Frame = card,
				}
			end

			tab.SubTabs[name] = sub
			subBtn.Parent = subBar

			return sub
		end

		-- Sidebar interactions
		btn.MouseEnter:Connect(function()
			if window.ActiveTab == tab then return end
			tween(btn, Anim.Fast, {BackgroundTransparency = 0.06})
		end)
		btn.MouseLeave:Connect(function()
			if window.ActiveTab == tab then return end
			tween(btn, Anim.Fast, {BackgroundTransparency = 0.12})
		end)
		btn.MouseButton1Click:Connect(function()
			tab:Show()
		end)

		window.Tabs[tabTopName] = tab
		return tab
	end

	-- default accent adjustments (purple)
	chatBtn.MouseEnter:Connect(function() tween(chatBtn, Anim.Fast, {TextColor3 = Theme.Purple}) end)
	chatBtn.MouseLeave:Connect(function() tween(chatBtn, Anim.Fast, {TextColor3 = Theme.TextDim}) end)
	gearBtn.MouseEnter:Connect(function() tween(gearBtn, Anim.Fast, {TextColor3 = Theme.Purple}) end)
	gearBtn.MouseLeave:Connect(function() tween(gearBtn, Anim.Fast, {TextColor3 = Theme.TextDim}) end)

	return (window :: any) :: Window
end

return TyrantUI
