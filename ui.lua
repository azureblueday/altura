--====================================================
-- Altura UI Library v2
-- Dark | Sharp | Monospace | Animated | Configs
--====================================================

local Altura = {}
Altura.__index = Altura

-- Services
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- Config
local CONFIG_FOLDER = "Altura"
local CONFIG_FILE = CONFIG_FOLDER .. "/config.json"
local ConfigData = {}

-- Theme
local Theme = {
	BG = Color3.fromRGB(18,18,18),
	Panel = Color3.fromRGB(22,22,22),
	Element = Color3.fromRGB(28,28,28),
	Accent = Color3.fromRGB(110,130,255),
	Text = Color3.fromRGB(235,235,235),
	SubText = Color3.fromRGB(160,160,160),
	Stroke = Color3.fromRGB(40,40,40),
	Font = Enum.Font.Code
}

-- Utilities
local function corner(o,r)
	local c=Instance.new("UICorner")
	c.CornerRadius=UDim.new(0,r)
	c.Parent=o
end

local function stroke(o)
	local s=Instance.new("UIStroke")
	s.Color=Theme.Stroke
	s.Thickness=1
	s.Parent=o
end

local function tween(o,props)
	TweenService:Create(o,TweenInfo.new(0.15,Enum.EasingStyle.Quad),props):Play()
end

-- Config Helpers
local function saveConfig()
	if not isfolder(CONFIG_FOLDER) then
		makefolder(CONFIG_FOLDER)
	end
	writefile(CONFIG_FILE, game:GetService("HttpService"):JSONEncode(ConfigData))
end

local function loadConfig()
	if isfile(CONFIG_FILE) then
		ConfigData = game:GetService("HttpService"):JSONDecode(readfile(CONFIG_FILE))
	end
end
loadConfig()

--====================================================
-- WINDOW
--====================================================
function Altura:NewWindow()
	local Window = {Tabs = {}}

	local gui = Instance.new("ScreenGui", game.CoreGui)
	gui.Name = "AlturaUI"

	local main = Instance.new("Frame", gui)
	main.Size = UDim2.fromScale(0.44, 0.55)
	main.Position = UDim2.fromScale(0.5, 0.5)
	main.AnchorPoint = Vector2.new(0.5,0.5)
	main.BackgroundColor3 = Theme.BG
	main.BorderSizePixel = 0
	corner(main,6)
	stroke(main)

	-- Title Bar
	local top = Instance.new("Frame", main)
	top.Size = UDim2.new(1,0,0,44)
	top.BackgroundColor3 = Theme.Panel
	corner(top,6)

	local title = Instance.new("TextLabel", top)
	title.Text = "Altura"
	title.Font = Theme.Font
	title.TextSize = 18
	title.TextColor3 = Theme.Text
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0,14,0,0)
	title.Size = UDim2.new(0,200,1,0)
	title.TextXAlignment = Left

	-- Tabs
	local tabBar = Instance.new("Frame", main)
	tabBar.Position = UDim2.new(0,10,0,54)
	tabBar.Size = UDim2.new(1,-20,0,34)
	tabBar.BackgroundTransparency = 1

	local tabLayout = Instance.new("UIListLayout", tabBar)
	tabLayout.FillDirection = Horizontal
	tabLayout.Padding = UDim.new(0,6)

	-- Content
	local content = Instance.new("Frame", main)
	content.Position = UDim2.new(0,10,0,96)
	content.Size = UDim2.new(1,-20,1,-106)
	content.BackgroundTransparency = 1

	--====================================================
	-- TAB
	--====================================================
	function Window:Tab(name)
		local Tab = {}

		local btn = Instance.new("TextButton", tabBar)
		btn.Text = name
		btn.Font = Theme.Font
		btn.TextSize = 14
		btn.TextColor3 = Theme.SubText
		btn.BackgroundColor3 = Theme.Element
		btn.Size = UDim2.new(0,140,1,0)
		corner(btn,4)
		stroke(btn)

		local page = Instance.new("ScrollingFrame", content)
		page.Size = UDim2.new(1,0,1,0)
		page.ScrollBarImageTransparency = 1
		page.Visible = false

		local layout = Instance.new("UIListLayout", page)
		layout.Padding = UDim.new(0,8)

		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
		end)

		btn.MouseButton1Click:Connect(function()
			for _,t in pairs(Window.Tabs) do
				t.Page.Visible = false
				t.Button.TextColor3 = Theme.SubText
			end
			page.Visible = true
			btn.TextColor3 = Theme.Text
		end)

		if #Window.Tabs == 0 then
			page.Visible = true
			btn.TextColor3 = Theme.Text
		end

		--================================================
		-- ELEMENTS
		--================================================

		function Tab:Label(text)
			local l = Instance.new("TextLabel", page)
			l.Text = text
			l.Font = Theme.Font
			l.TextSize = 14
			l.TextColor3 = Theme.SubText
			l.BackgroundTransparency = 1
			l.Size = UDim2.new(1,-10,0,20)
			l.TextXAlignment = Left
		end

		function Tab:Toggle(text,cfg)
			local state = ConfigData[text] ?? cfg.Default ?? false

			local f = Instance.new("Frame", page)
			f.Size = UDim2.new(1,-10,0,38)
			f.BackgroundColor3 = Theme.Element
			corner(f,4); stroke(f)

			local lbl = Instance.new("TextLabel", f)
			lbl.Text = text
			lbl.Font = Theme.Font
			lbl.TextSize = 14
			lbl.TextColor3 = Theme.Text
			lbl.BackgroundTransparency = 1
			lbl.Position = UDim2.new(0,10,0,0)
			lbl.Size = UDim2.new(1,-60,1,0)
			lbl.TextXAlignment = Left

			local box = Instance.new("Frame", f)
			box.Size = UDim2.new(0,20,0,20)
			box.Position = UDim2.new(1,-30,0.5,-10)
			box.BackgroundColor3 = state and Theme.Accent or Theme.Panel
			corner(box,3)

			f.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
					state = not state
					tween(box,{BackgroundColor3 = state and Theme.Accent or Theme.Panel})
					ConfigData[text] = state
					saveConfig()
					cfg.Callback(state)
				end
			end)
		end

		function Tab:Slider(text,cfg)
			local val = ConfigData[text] ?? cfg.Default ?? cfg.Min

			local f = Instance.new("Frame", page)
			f.Size = UDim2.new(1,-10,0,50)
			f.BackgroundColor3 = Theme.Element
			corner(f,4); stroke(f)

			local lbl = Instance.new("TextLabel", f)
			lbl.Text = text .. ": " .. val
			lbl.Font = Theme.Font
			lbl.TextSize = 14
			lbl.TextColor3 = Theme.Text
			lbl.BackgroundTransparency = 1
			lbl.Position = UDim2.new(0,10,0,4)
			lbl.Size = UDim2.new(1,-20,0,18)
			lbl.TextXAlignment = Left

			local bar = Instance.new("Frame", f)
			bar.Position = UDim2.new(0,10,0,32)
			bar.Size = UDim2.new(1,-20,0,6)
			bar.BackgroundColor3 = Theme.Panel
			corner(bar,3)

			local fill = Instance.new("Frame", bar)
			fill.Size = UDim2.new((val-cfg.Min)/(cfg.Max-cfg.Min),0,1,0)
			fill.BackgroundColor3 = Theme.Accent
			corner(fill,3)

			local dragging=false
			local function update(x)
				local p=math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
				val=math.floor(cfg.Min+(cfg.Max-cfg.Min)*p)
				lbl.Text=text..": "..val
				tween(fill,{Size=UDim2.new(p,0,1,0)})
				ConfigData[text]=val
				saveConfig()
				cfg.Callback(val)
			end

			bar.InputBegan:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
					dragging=true
					update(i.Position.X)
				end
			end)

			UIS.InputChanged:Connect(function(i)
				if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
					update(i.Position.X)
				end
			end)

			UIS.InputEnded:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
					dragging=false
				end
			end)
		end

		function Tab:Keybind(text,cfg)
			local key = ConfigData[text] or cfg.Default or "None"
			local listening=false

			local b = Instance.new("TextButton", page)
			b.Size = UDim2.new(1,-10,0,36)
			b.BackgroundColor3 = Theme.Element
			b.Text = text.." ["..key.."]"
			b.Font = Theme.Font
			b.TextSize = 14
			b.TextColor3 = Theme.Text
			corner(b,4); stroke(b)

			b.MouseButton1Click:Connect(function()
				b.Text=text.." [PRESS]"
				listening=true
			end)

			UIS.InputBegan:Connect(function(i,gp)
				if listening and not gp then
					key=i.KeyCode.Name
					b.Text=text.." ["..key.."]"
					ConfigData[text]=key
					saveConfig()
					cfg.Callback(key)
					listening=false
				elseif i.KeyCode.Name==key then
					cfg.Pressed()
				end
			end)
		end

		table.insert(Window.Tabs,{Button=btn,Page=page})
		return Tab
	end

	return Window
end

return Altura
