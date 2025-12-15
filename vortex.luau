--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local RS = game:GetService("ReplicatedStorage")
local gc = getgc(true)

local function findTargetConstant()
    local candidates = {}
    
    for _, obj in pairs(gc) do
        pcall(function()
            if type(obj) == "function" and islclosure(obj) and not isexecutorclosure(obj) then
                local protos = getprotos(obj)
                if protos and #protos == 1 then
                    local consts = getconstants(protos[1])
                    for _, const in pairs(consts) do
                        if type(const) == "number" and const > 1000000 and const < 10000000 then
                            table.insert(candidates, {value = const, func = obj})
                        end
                    end
                end
            end
        end)
    end
    
    return candidates
end

for _, obj in pairs(gc) do
    pcall(function()
        if type(obj) == "table" and rawlen(obj) == 19 then
            local last = rawget(obj, 19)
            if type(last) == "userdata" then
                for i = 2, 18 do
                    rawset(obj, i, math.random(1e6, 1e8))
                end
            end
        end
    end)
end

local detectedConstants = findTargetConstant()

if #detectedConstants > 0 then
    for _, candidate in ipairs(detectedConstants) do
        pcall(function()
            hookfunction(candidate.func, newcclosure(function() end))
        end)
    end
end

local remote = RS.Remotes.CharacterSoundEvent
local oldFire = remote.FireServer

hookfunction(remote.FireServer, newcclosure(function(self, ...)
    local args = {...}
    
    if type(args[1]) == "string" and #args[1] > 20 then
        if args[2] == "b51b07a5c14d" or args[2] == "error" then
            return
        end
    end
    
    return oldFire(self, ...)
end))

_G.b51b07a5c14d = false

local fakeLS = Instance.new("LocalScript")
fakeLS.Disabled = true
fakeLS.Parent = game:GetService("ReplicatedFirst")

for _, tbl in pairs(gc) do
    pcall(function()
        if type(tbl) == "table" then
            local mt = getrawmetatable(tbl)
            if mt and mt.__call then
                local oldCall = mt.__call
                rawset(mt, "__call", newcclosure(function(self, a, b, c, d, e, f)
                    if a and b and c and d and e and f then
                        if a > 1000 and b > 1000 then
                            return { 20.02 }
                        end
                    end
                    return oldCall(self, a, b, c, d, e, f)
                end))
                rawset(mt, "__tostring", nil)
            end
        end
    end)
end

task.wait(1)

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title = "Vortex Hub🌌🎄🎅",
    Footer = "by @spny | https://discord.gg/eYjFRpuKFH",
    NotifySide = "Right",
    ShowCustomCursor = false,
    Mobile = {
        Enabled = true,
        Title = "Vortex Hub 🌌🎅🎄",
        Icon = "rbxassetid://10723434711"
    }
})

local Tabs = {
    Catching = Window:AddTab("Catching", "hand"),
    Physics = Window:AddTab("Physics", "zap"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")
local ContextActionService = game:GetService("ContextActionService")

local Player = Players.LocalPlayer
while not Player do
    Player = Players.LocalPlayer
    wait()
end

-- Settings
local autocatchon = false
local catchdistance = 10
local magson = false
local magsrange = 0
local magsdelayon = false
local magsdelay = 0
local showhitboxon = false
local hitboxshape = "Sphere"
local hitboxcolor = Color3.fromRGB(128, 0, 128)
local hitboxes = {}
local catchresizeon = false
local catchresizerange = 10
local lmgg = 0
local magmode = "FTI"
local speedEnabled = false
local speedValue = 0.1
local movementLoop = nil
local jumpoweron = false
local jumpboost = 50
local nojpcooldownon = false
local njcconnections = {}
local pullvector = false
local pullvectorpower = 1
local pullvectordistance = 5
local clicktackleon = false
local clicktacklerange = 5
local ballpathOn = false
local ballpathColor = Color3.fromRGB(128,0,128)
local ballpathConnection
local deleteOOBEnabled = false

-- Functions
local function gotfb()
    local character = Player.Character
    if not character then return false end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():match("football") or tool:FindFirstChild("Handle")) then
            return true
        end
    end
    return false
end

local function findclosestball()
    local character = Player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = character.HumanoidRootPart
    local closestball, mindist = nil, math.huge
    for _, ball in pairs(Workspace:GetChildren()) do
        if ball.Name:lower():match("football") and ball:IsA("BasePart") and not ball.Anchored then
            local dist = (hrp.Position - ball.Position).Magnitude
            if dist < mindist then closestball, mindist = ball, dist end
        end
    end
    return closestball, mindist
end

local function hitboxx(oid)
    if not oid or hitboxes[oid] or not magson or not showhitboxon then return end
    local holder = oid:FindFirstAncestorOfClass("Model")
    if holder and Players:GetPlayerFromCharacter(holder) then return end
    local hitbox = Instance.new("Part")
    hitbox.Name = "Hitbox"
    hitbox.Size = Vector3.new(magsrange, magsrange, magsrange)
    hitbox.Anchored = true
    hitbox.CanCollide = false
    hitbox.Transparency = 0.2
    hitbox.Material = Enum.Material.ForceField
    hitbox.Color = Color3.fromRGB(128, 0, 128)
    hitbox.CastShadow = false
    hitbox.CFrame = oid.CFrame
    hitbox.Shape = Enum.PartType.Ball
    hitbox.Parent = oid
    local success, uistroke = pcall(function() return Instance.new("UIStroke") end)
    if success and uistroke then
        pcall(function()
            uistroke.Color = Color3.fromRGB(255,255,255)
            uistroke.Thickness = 1
            uistroke.Transparency = 0
            uistroke.Parent = hitbox
        end)
    end
    hitboxes[oid] = {part = hitbox}
    local connection
    connection = RunService.Heartbeat:Connect(function(dt)
        if not oid or not oid.Parent or not magson or not showhitboxon then
            if hitbox then hitbox:Destroy() end
            if connection then connection:Disconnect() end
            hitboxes[oid] = nil
            return
        end
        local holder = oid:FindFirstAncestorOfClass("Model")
        if holder and Players:GetPlayerFromCharacter(holder) then
            if hitbox then hitbox:Destroy() end
            if connection then connection:Disconnect() end
            hitboxes[oid] = nil
            return
        end
        hitbox.CFrame = oid.CFrame
        hitbox.Size = Vector3.new(magsrange, magsrange, magsrange)
        hitbox.Color = Color3.fromRGB(128, 0, 128)
    end)
end

local function fitbalsize()
    for oid, data in pairs(hitboxes) do
        if data and data.part then
            data.part.Size = Vector3.new(magsrange, magsrange, magsrange)
            data.part.Color = Color3.fromRGB(128, 0, 128)
        else
            if data and data.part then data.part:Destroy() end
            hitboxes[oid] = nil
        end
    end
end

local function remove()
    for oid, football in pairs(hitboxes) do
        if football.part then football.part:Destroy() end
    end
    hitboxes = {}
end

local function footballhitbox()
    if not magson then return end
    for _, child in pairs(Workspace:GetChildren()) do
        if child.Name:lower():match("football") and child:IsA("BasePart") then
            hitboxx(child)
        end
    end
end

local function getfutbal()
    local character = Player.Character
    if not (character and character:FindFirstChild("HumanoidRootPart")) then return nil end
    local playerpos = character.HumanoidRootPart.Position
    local closestfootballpart, mindist = nil, math.huge
    for _, child in pairs(Workspace:GetChildren()) do
        if child.Name:lower():match("football") and child:IsA("BasePart") then
            local dist = (child.Position - playerpos).Magnitude
            if dist < mindist and dist <= magsrange then closestfootballpart, mindist = child, dist end
        end
    end
    return closestfootballpart
end

local function catch(ball)
    if not ball then return nil end
    local character = Player.Character
    if not character then return end
    local catchleft = character:FindFirstChild("CatchLeft")
    local catchright = character:FindFirstChild("CatchRight")
    local closest, mindist = nil, math.huge
    local ballpos = ball.Position
    local rg = magsrange
    if catchleft and catchleft:IsA("BasePart") then
        local dist = (catchleft.Position - ballpos).Magnitude
        if dist < mindist and dist <= rg then closest, mindist = catchleft, dist end
    end
    if catchright and catchright:IsA("BasePart") then
        local dist = (catchright.Position - ballpos).Magnitude
        if dist < mindist and dist <= rg then closest, mindist = catchright, dist end
    end
    return closest
end

local function rrrrrrrsizenugget(character)
    if not character then return end
    if catchresizeon then
        local catchleft = character:FindFirstChild("CatchLeft")
        local catchright = character:FindFirstChild("CatchRight")
        if catchleft then
            catchleft.Size = Vector3.new(catchresizerange, catchresizerange, catchresizerange)
            catchleft.Transparency = 1
        end
        if catchright then
            catchright.Size = Vector3.new(catchresizerange, catchresizerange, catchresizerange)
            catchright.Transparency = 1
        end
    else
        local catchleft = character:FindFirstChild("CatchLeft")
        local catchright = character:FindFirstChild("CatchRight")
        if catchleft then
            catchleft.Size = Vector3.new(0.75, 5, 1.5)
            catchleft.Transparency = 1
        end
        if catchright then
            catchright.Size = Vector3.new(0.75, 5, 1.5)
            catchright.Transparency = 1
        end
    end
end

local function startMovementSystem()
    if not movementLoop then
        movementLoop = RunService.Heartbeat:Connect(function(dt)
            if not speedEnabled then return end
            local character = Player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            local hrp = character.HumanoidRootPart
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and humanoid.MoveDirection.Magnitude > 0 then
                local speedStudsPerSec = speedValue * 8
                local moveVector = humanoid.MoveDirection * speedStudsPerSec * dt
                hrp.CFrame = hrp.CFrame + moveVector
            end
        end)
    end
end

local function stopMovementSystem()
    if movementLoop then
        movementLoop:Disconnect()
        movementLoop = nil
    end
end

local function whenmoving(character)
    if not character then return end
    local humanoid = character:WaitForChild("Humanoid")
    local humanoidrootpart = character:WaitForChild("HumanoidRootPart")
    humanoid.StateChanged:Connect(function(_, newstate)
        if newstate == Enum.HumanoidStateType.Jumping and jumpoweron then
            task.wait(0.05)
            humanoidrootpart.AssemblyLinearVelocity = humanoidrootpart.AssemblyLinearVelocity + Vector3.new(0, jumpboost - 50, 0)
        end
    end)
end

local function njc(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid")
    local connection = RunService.Stepped:Connect(function()
        if nojpcooldownon then
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        end
    end)
    njcconnections[char] = connection
end

local function findclosestsleveesor(maxdistance)
    local character = Player.Character
    if not character then
        return nil
    end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return nil
    end
    local closestdistance = maxdistance
    local closestcharacter = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == Player or plr.Team == Player.Team then
            continue
        end
        local targetchar = plr.Character
        if not targetchar then
            continue
        end
        local targethrp = targetchar:FindFirstChild("HumanoidRootPart")
        if not targethrp then
            continue
        end
        local hasfootball = false
        for _, item in ipairs(targetchar:GetChildren()) do
            if item:IsA("Tool") and item.Name:match("Football") then
                hasfootball = true
                break
            end
        end
        if not hasfootball then
            continue
        end
        local distance = (hrp.Position - targethrp.Position).Magnitude
        if distance < closestdistance then
            closestdistance = distance
            closestcharacter = targetchar
        end
    end
    return closestcharacter
end

local function beamProjectile(g, v0, x0, t1)
    local c = 0.125
    local p3 = 0.5*g*t1*t1 + v0*t1 + x0
    local p2 = p3 - (g*t1*t1 + v0*t1)/3
    local p1 = (c*g*t1*t1 + 0.5*v0*t1 + x0 - c*(x0+p3))/(3*c) - p2

    local curve0 = (p1 - x0).magnitude
    local curve1 = (p2 - p3).magnitude

    local b = (x0 - p3).unit
    local r1 = (p1 - x0).unit
    local u1 = r1:Cross(b).unit
    local r2 = (p2 - p3).unit
    local u2 = r2:Cross(b).unit
    b = u1:Cross(r1).unit

    local cf1 = CFrame.new(
        x0.x, x0.y, x0.z,
        r1.x, u1.x, b.x,
        r1.y, u1.y, b.y,
        r1.z, u1.z, b.z
    )
    local cf2 = CFrame.new(
        p3.x, p3.y, p3.z,
        r2.x, u2.x, b.x,
        r2.y, u2.y, b.y,
        r2.z, u2.z, b.z
    )
    return curve0, -curve1, cf1, cf2
end

local function TriggerTouchEvent()
    local Camera = workspace.CurrentCamera
    local xPos = Camera.ViewportSize.X / 2
    local yPos = Camera.ViewportSize.Y / 2
    VIM:SendTouchEvent(1, Enum.UserInputState.Begin.Value, xPos, yPos)
    task.wait(0.005)
    VIM:SendTouchEvent(1, Enum.UserInputState.End.Value, xPos, yPos)
end

-- UI Groups
local MagsGroup = Tabs.Catching:AddLeftGroupbox("Mags")
local FootballGroup = Tabs.Catching:AddLeftGroupbox("Football")
local SpeedGroup = Tabs.Catching:AddRightGroupbox("Speed")
local PullGroup = Tabs.Catching:AddRightGroupbox("Pull")

local JumpPowerGroup = Tabs.Physics:AddLeftGroupbox("Jump Power")
local PhysicsStuffGroup = Tabs.Physics:AddRightGroupbox("Jump Cooldown")
local DeleteOOBGroup = Tabs.Physics:AddRightGroupbox("Delete OOB")
local TackleGroup = Tabs.Physics:AddLeftGroupbox("Tackle")

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")

-- Mags Settings
MagsGroup:AddSlider("magsrange", {
    Text = "Range",
    Min = 0,
    Max = 20,
    Default = 0,
    Rounding = 1,
    Callback = function(Value)
        magsrange = Value
        if magson and showhitboxon then fitbalsize() end
    end
})

MagsGroup:AddToggle("mags", {
    Text = "Mags",
    Default = false,
    Callback = function(Value)
        magson = Value
        if not Value then
            remove()
        elseif showhitboxon then
            footballhitbox()
        end
    end
})

MagsGroup:AddSlider("magsdelay", {
    Text = "Delay",
    Min = 0,
    Max = 1,
    Default = 0,
    Rounding = 1,
    Callback = function(Value)
        magsdelay = Value
        magsdelayon = Value > 0
    end
})

MagsGroup:AddDropdown("magtype", {
    Values = {"Blatant", "Legit"},
    Default = "Blatant",
    Text = "Mag Type",
    Callback = function(Value)
        local newvalue = Value == "Blatant" and 20 or Value == "Legit" and 8 or 3
        if Options and Options.magsrange and Options.magsrange.SetValue then
            Options.magsrange:SetValue(newvalue)
        end
    end
})

MagsGroup:AddDropdown("magmode", {
    Values = {"FTI", "CFrame"},
    Default = "FTI",
    Text = "Mag Mode",
    Callback = function(Value)
        magmode = Value
    end
})

MagsGroup:AddToggle("showhitbox", {
    Text = "Show Hitbox",
    Default = false,
    Callback = function(Value)
        showhitboxon = Value
        if not Value then
            remove()
        elseif magson then
            footballhitbox()
        end
    end
})

MagsGroup:AddToggle("autocatch", {
    Text = "Auto Catch",
    Default = false,
    Callback = function(Value)
        autocatchon = Value
    end
})

MagsGroup:AddSlider("catchdistance", {
    Text = "Auto Catch Radius",
    Min = 1,
    Max = 25,
    Default = 10,
    Rounding = 1,
    Callback = function(Value)
        catchdistance = Value
    end
})

-- Football Settings
FootballGroup:AddToggle("ballpath", {
    Text = "Ball Path",
    Default = false,
    Callback = function(Value)
        ballpathOn = Value
        if not Value then
            if ballpathConnection then ballpathConnection:Disconnect() ballpathConnection = nil end
            for _, obj in ipairs(Workspace.Terrain:GetChildren()) do
                if obj:IsA("Beam") and obj.Name == "BallPath" then obj:Destroy()
                elseif obj:IsA("Attachment") and obj.Name == "BallPathAttachment" then obj:Destroy() end
            end
        else
            if ballpathConnection then ballpathConnection:Disconnect() end
            ballpathConnection = Workspace.ChildAdded:Connect(function(ball)
                if ball.Name:lower():find("football") and ball:IsA("BasePart") then
                    task.wait()
                    local vel = ball.Velocity
                    local pos = ball.Position
                    local c0, c1, cf1, cf2 = beamProjectile(Vector3.new(0, -28, 0), vel, pos, 10)
                    local beam = Instance.new("Beam")
                    local a0 = Instance.new("Attachment")
                    local a1 = Instance.new("Attachment")
                    beam.Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, ballpathColor),
                        ColorSequenceKeypoint.new(1, ballpathColor)
                    }
                    beam.Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(0.01, 0), NumberSequenceKeypoint.new(0.99, 0), NumberSequenceKeypoint.new(1, 0.01)
                    }
                    beam.CurveSize0 = c0
                    beam.CurveSize1 = c1
                    beam.Segments = 1750
                    beam.Width0 = 1
                    beam.Width1 = 1
                    beam.Name = "BallPath"
                    beam.Parent = Workspace.Terrain

                    a0.Parent = Workspace.Terrain
                    a1.Parent = Workspace.Terrain
                    a0.Name = "BallPathAttachment"
                    a1.Name = "BallPathAttachment"
                    a0.CFrame = a0.Parent.CFrame:Inverse() * cf1
                    a1.CFrame = a1.Parent.CFrame:Inverse() * cf2
                    beam.Attachment0 = a0
                    beam.Attachment1 = a1

                    local heartbeatConn
                    heartbeatConn = RunService.Heartbeat:Connect(function()
                        if ball.Velocity.Magnitude < 1 then
                            heartbeatConn:Disconnect()
                            beam:Destroy()
                            a0:Destroy()
                            a1:Destroy()
                        end
                    end)
                    task.spawn(function()
                        repeat task.wait() until not ball.Parent or not Workspace:FindFirstChild(ball.Name)
                        if beam and beam.Parent then beam:Destroy() end
                        if a0 and a0.Parent then a0:Destroy() end
                        if a1 and a1.Parent then a1:Destroy() end
                    end)
                end
            end)
        end
    end
})

-- Speed Settings
SpeedGroup:AddSlider("SpeedValue", {
    Text = "Speed Value",
    Default = 0.1,
    Min = 0.1,
    Max = 1.2,
    Rounding = 1,
    Callback = function(value)
        speedValue = value
    end
})

SpeedGroup:AddToggle("CFrameSpeed", {
    Text = "CFrame Speed",
    Default = false,
    Callback = function(state)
        speedEnabled = state
        if state then
            startMovementSystem()
        else
            stopMovementSystem()
        end
    end
})

-- Pull Settings
PullGroup:AddToggle("pullvector", {
    Text = "Pull Vector",
    Default = false,
    Callback = function(Value)
        pullvector = Value
    end
})

PullGroup:AddSlider("pullvectorpower", {
    Text = "Pull Vector Speed",
    Min = 1,
    Max = 3,
    Default = 1,
    Rounding = 1,
    Callback = function(Value)
        pullvectorpower = Value
    end
})

PullGroup:AddSlider("pullvectordistance", {
    Text = "Pull Vector Radius",
    Min = 1,
    Max = 25,
    Default = 5,
    Rounding = 1,
    Callback = function(Value)
        pullvectordistance = Value
    end
})

-- Jump Power Settings
JumpPowerGroup:AddToggle("jumppower", {
    Text = "Jump Power",
    Default = false,
    Callback = function(Value) 
        jumpoweron = Value 
    end
})

JumpPowerGroup:AddSlider("jumpboost", {
    Text = "Jump Power",
    Min = 50,
    Max = 65,
    Default = 50,
    Rounding = 1,
    Callback = function(Value) 
        jumpboost = Value 
    end
})

-- Jump Cooldown Settings
PhysicsStuffGroup:AddToggle("nojpcooldown", {
    Text = "No Jump Cooldown",
    Default = false,
    Callback = function(Value)
        nojpcooldownon = Value
        if not Value and Player.Character then
            local connection = njcconnections[Player.Character]
            if connection then
                connection:Disconnect()
                njcconnections[Player.Character] = nil
            end
        elseif Value and Player.Character then
            njc(Player.Character)
        end
    end
})

-- Delete OOB Settings
DeleteOOBGroup:AddToggle("DeleteOOB", {
    Text = "Delete OOB",
    Default = false,
    Callback = function(Value)
        deleteOOBEnabled = Value
    end
})

-- Tackle Settings
TackleGroup:AddToggle("clicktackle", {
    Text = "Click Tackle",
    Default = false,
    Callback = function(Value)
        clicktackleon = Value
    end
})

TackleGroup:AddSlider("clicktacklerange", {
    Text = "Click Tackle Range",
    Min = 1,
    Max = 15,
    Default = 5,
    Rounding = 1,
    Callback = function(Value)
        clicktacklerange = Value
    end
})

-- Menu Settings
MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(value)
        Library.KeybindFrame.Visible = value
    end,
})

MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = false,
    Callback = function(Value)
        Library.ShowCustomCursor = Value
    end,
})

MenuGroup:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" },
    Default = "Right",
    Text = "Notification Side",
    Callback = function(Value)
        Library:SetNotifySide(Value)
    end,
})

MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { 
    Default = "LeftControl", 
    NoUI = true, 
    Text = "Menu keybind" 
})

MenuGroup:AddButton({
    Text = "Unload",
    Func = function()
        Library:Unload()
    end
})

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("Kali Hub")
SaveManager:SetFolder("KaliHub/FF2")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

-- Initialize character
if Player.Character then
    rrrrrrrsizenugget(Player.Character)
    whenmoving(Player.Character)
    njc(Player.Character)
end

Player.CharacterAdded:Connect(function(char)
    rrrrrrrsizenugget(char)
    whenmoving(char)
    njc(char)
end)

-- Main Loops
RunService.Heartbeat:Connect(function(deltatime)
    if not magson then return end
    local cnp = tick()
    if magsdelayon and (cnp - lmgg) < magsdelay then return end
    local magthatbihfoo = getfutbal()
    if magthatbihfoo then
        local closestcatchpart = catch(magthatbihfoo)
        if closestcatchpart then
            if magmode == "CFrame" then
                magthatbihfoo.CFrame = closestcatchpart.CFrame
            else
                firetouchinterest(closestcatchpart, magthatbihfoo, 0)
                task.wait()
                firetouchinterest(closestcatchpart, magthatbihfoo, 1)
            end
        end
    end
    if magsdelayon then lmgg = cnp end
end)

Workspace.ChildAdded:Connect(function(child)
    if child.Name:lower():match("football") and magson and showhitboxon and child:IsA("BasePart") then
        hitboxx(child)
    end
end)

task.spawn(function()
    while task.wait(0.02) do
        if not autocatchon then continue end

        local ball, distance = findclosestball()
        if ball and distance <= catchdistance then
            TriggerTouchEvent()
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if pullvector then
            local character = Player.Character
            if character then
                local humanoidrootpart = character:FindFirstChild("HumanoidRootPart")
                if humanoidrootpart then
                    for _, ball in pairs(Workspace:GetChildren()) do
                        if ball.Name:lower():match("football") and ball:IsA("BasePart") then
                            local distance = (humanoidrootpart.Position - ball.Position).Magnitude
                            if distance <= pullvectordistance then
                                local direction = (ball.Position - humanoidrootpart.Position).Unit
                                humanoidrootpart.AssemblyLinearVelocity = direction * pullvectorpower * 25
                            end
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if deleteOOBEnabled then
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj:IsA("BasePart") and obj.Position.Y < -100 then
                    obj:Destroy()
                end
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameprocessed)
    if gameprocessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if not clicktackleon then return end
        local slveesor = findclosestsleveesor(clicktacklerange)
        if slveesor and slveesor:FindFirstChild("HumanoidRootPart") then
            local character = Player.Character
            if not character then return end
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            hrp.CFrame = slveesor.HumanoidRootPart.CFrame
        end
    end
end)

Library:Notify({
    Title = "Kali Hub",
    Description = "Script loaded successfully!",
    Time = 5,
})

Library:OnUnload(function()
    magson = false
    autocatchon = false
    speedEnabled = false
    pullvector = false
    jumpoweron = false
    nojpcooldownon = false
    clicktackleon = false
    ballpathOn = false
    deleteOOBEnabled = false
    
    for _, data in pairs(hitboxes) do
        if data.part and data.part.Parent then 
            data.part:Destroy() 
        end
    end
    
    local character = Player.Character
    if character then
        if catchresizeon then
            local catchleft = character:FindFirstChild("CatchLeft")
            local catchright = character:FindFirstChild("CatchRight")
            if catchleft then catchleft.Size = Vector3.new(0.75, 5, 1.5) end
            if catchright then catchright.Size = Vector3.new(0.75, 5, 1.5) end
        end
    end
    
    for char, connection in pairs(njcconnections) do
        if connection then connection:Disconnect() end
    end
    njcconnections = {}
    
    stopMovementSystem()
    
    if ballpathConnection then 
        ballpathConnection:Disconnect() 
    end
    
    for _, obj in ipairs(Workspace.Terrain:GetChildren()) do
        if obj:IsA("Beam") and obj.Name == "BallPath" then obj:Destroy()
        elseif obj:IsA("Attachment") and obj.Name == "BallPathAttachment" then obj:Destroy() end
    end
end)
