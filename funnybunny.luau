--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "NovaLoader"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

-- Background container
local bg = Instance.new("Frame")
bg.Parent = gui
bg.Size = UDim2.fromScale(0.42, 0.22)
bg.Position = UDim2.fromScale(0.5, 0.5)
bg.AnchorPoint = Vector2.new(0.5, 0.5)
bg.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
bg.BorderSizePixel = 0

Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 12)

-- Stroke
local stroke = Instance.new("UIStroke")
stroke.Parent = bg
stroke.Thickness = 1
stroke.Color = Color3.fromRGB(55, 55, 55)
stroke.Transparency = 0.15

-- Title
local title = Instance.new("TextLabel")
title.Parent = bg
title.Size = UDim2.fromScale(1, 0.25)
title.Position = UDim2.fromScale(0, 0.1)
title.BackgroundTransparency = 1
title.Text = "Nova Hub || Football Fusion 2"
title.Font = Enum.Font.GothamBold
title.TextSize = 36
title.TextColor3 = Color3.fromRGB(235, 235, 235)

-- Loading bar background
local barBG = Instance.new("Frame")
barBG.Parent = bg
barBG.Size = UDim2.fromScale(0.88, 0.18)
barBG.Position = UDim2.fromScale(0.06, 0.58)
barBG.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
barBG.BorderSizePixel = 0

Instance.new("UICorner", barBG).CornerRadius = UDim.new(0, 8)

-- Loading bar fill
local barFill = Instance.new("Frame")
barFill.Parent = barBG
barFill.Size = UDim2.fromScale(0, 1)
barFill.BackgroundColor3 = Color3.fromRGB(159, 115, 254)
barFill.BorderSizePixel = 0

Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 8)

-- Percentage text
local percentText = Instance.new("TextLabel")
percentText.Parent = bg
percentText.Size = UDim2.fromScale(1, 0.15)
percentText.Position = UDim2.fromScale(0, 0.82)
percentText.BackgroundTransparency = 1
percentText.Text = "0%"
percentText.Font = Enum.Font.GothamMedium
percentText.TextSize = 14
percentText.TextColor3 = Color3.fromRGB(200, 200, 200)

--// Progress function
local function setProgress(p)
	p = math.clamp(p, 0, 1)

	TweenService:Create(
		barFill,
		TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = UDim2.fromScale(p, 1) }
	):Play()

	percentText.Text = math.floor(p * 100) .. "%"
end

--// Loading sequence
task.spawn(function()
	-- 0 → 43%
	for i = 0, 0.43, 0.03 do
		setProgress(i)
		task.wait(0.08)
	end

	-- Pause at 43%
	task.wait(2)

	-- 43% → 88%
	for i = 0.43, 0.88, 0.03 do
		setProgress(i)
		task.wait(0.08)
	end

	-- Pause at 88%
	task.wait(2)

	-- 88% → 100%
	for i = 0.88, 1, 0.02 do
		setProgress(i)
		task.wait(0.06)
	end

	percentText.Text = "Loaded"
	task.wait(0.6)

	gui:Destroy()
end)
