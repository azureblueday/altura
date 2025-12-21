--<< Services >>--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Players = game:GetService("Players")

local Workspace = game:GetService("Workspace")

local RunService = game:GetService("RunService")

local UserInputService = game:GetService("UserInputService")

local Debris = game:GetService("Debris")



--<< Variables >>--

local LocalPlayer = Players.LocalPlayer

local Connections = {} -- Track all connections for cleanup



-- Safe pcall wrapper

local function safeCall(func, ...)

    local success, result = pcall(func, ...)

    return success and result

end



-- Anti-AC hook

local garbage_list = getgc(true)



for _, obj in next, garbage_list do

    if type(obj) == "function" and islclosure(obj) and not isexecutorclosure(obj) then

        local protos = getprotos(obj)

        if protos and #protos == 1 then

            local consts = getconstants(protos[1])

            if table.find(consts, 5100020) then

                hookfunction(obj, function() end)

            end

        end

    end

end



for _, v in garbage_list do

    if type(v) == "table" then

        local mt = getrawmetatable(v)

        if mt and mt.__call and islclosure(mt.__call) and not isexecutorclosure(mt.__call) then

            local old_call

            old_call = hookfunction(

                mt.__call,

                newcclosure(function(self, a, b, c, d, e, f, ...)

                    if a and b and c and d and e and f then

                        if type(a) == "number" and type(b) == "number" and a > 1000 and b > 1000 then

                            return { 20.01 }

                        end

                    end

                    return old_call(self, a, b, c, d, e, f, ...)

                end)

            )

            rawset(mt, "__tostring", nil)

        end

    end

end



for _, obj in getconnections(game:GetService("ScriptContext").Error) do

    if obj and obj.Function then

        hookfunction(obj.Function, newcclosure(function() return end))

    end

end



-- Load Obsidian UI Library

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()

local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()



local Options = Library.Options

local Toggles = Library.Toggles



Library.ForceCheckbox = false

Library.ShowToggleFrameInKeybinds = true



local Window = Library:CreateWindow({

    Title = "Nova Hub",

    Footer = "Made by @d1starzz || https://discord.gg/Q8g5Njz9bt",

    NotifySide = "Right",

    ShowCustomCursor = true,

    Center = true,

    AutoShow = true,

    TabPadding = 8,

    Color = Color3.fromRGB(0, 196, 255)

})



local Tabs = {

    Mag = Window:AddTab("Catching", "magnet"),

    Physical = Window:AddTab("Physical", "shield"),

    Player = Window:AddTab("Player", "user"),

    Visuals = Window:AddTab("Visuals", "eye"),

    Misc = Window:AddTab("Misc", "box"),

    Settings = Window:AddTab("Settings", "settings"),

}



-- Create groupboxes

local MagGroupBox = Tabs.Mag:AddLeftGroupbox("Magnets")

local MagSettingsGroupBox = Tabs.Mag:AddRightGroupbox("Settings")



local PhysicalGroupBox = Tabs.Physical:AddLeftGroupbox("Features")

local PlayerGroupBox = Tabs.Player:AddLeftGroupbox("Movement")

local PlayerCombatGroupBox = Tabs.Player:AddRightGroupbox("Combat")

local PlayerAdvancedGroupBox = Tabs.Player:AddLeftGroupbox("Advanced")



local VisualsGroupBox = Tabs.Visuals:AddLeftGroupbox("Visuals")

local MiscGroupBox = Tabs.Misc:AddLeftGroupbox("Misc")



-- ========== CHARACTER MANAGEMENT ==========

local char, hum, hrp



local function getCharacter()

    char = LocalPlayer.Character

    if char then

        hum = char:FindFirstChildOfClass("Humanoid")

        hrp = char:FindFirstChild("HumanoidRootPart")

    end

    return char, hum, hrp

end



getCharacter()



Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newChar)

    char = newChar

    hum = newChar:WaitForChild("Humanoid", 10)

    hrp = newChar:WaitForChild("HumanoidRootPart", 10)

end)



-- ========== MAGNET SYSTEM ==========

local MagnetSettings = {

    enabled = false,

    mode = "Regular",

    range = 13,

    hitboxEnabled = false,

    hitboxType = "Forcefield",

    rainbowEnabled = false,

    rainbowSpeed = 0.5,

    rainbowHue = 0

}



local hitboxes = {}

local ballData = {} -- Store velocity/position data per ball



local modeRanges = {

    Regular = 13,

    League = 6,

    Legit = 10,

    Rage = 25,

    Custom = 0

}



local function getMagnetRange()

    if MagnetSettings.mode == "Custom" then

        return MagnetSettings.range

    end

    return modeRanges[MagnetSettings.mode] or 13

end



local function updateRainbowColor()

    MagnetSettings.rainbowHue = (MagnetSettings.rainbowHue + (MagnetSettings.rainbowSpeed / 255)) % 1

    return Color3.fromHSV(MagnetSettings.rainbowHue, 1, 1)

end



local function createOrUpdateHitbox(ball)

    if not ball or not ball.Parent then return end

    

    local size = getMagnetRange()

    local hitbox = hitboxes[ball]



    if not hitbox or not hitbox.Parent then

        hitbox = Instance.new("Part")

        hitbox.Anchored = true

        hitbox.CanCollide = false

        hitbox.CanQuery = false

        hitbox.CastShadow = false

        hitbox.Name = "MagnetHitbox"

        hitbox.Parent = Workspace

        hitboxes[ball] = hitbox

    end



    hitbox.Size = Vector3.new(size, size, size)

    hitbox.CFrame = ball.CFrame



    -- Clear old visual elements

    for _, v in pairs(hitbox:GetChildren()) do

        if v:IsA("SelectionBox") or v:IsA("SelectionSphere") then

            v:Destroy()

        end

    end



    -- Apply visual style

    if MagnetSettings.rainbowEnabled then

        hitbox.Shape = Enum.PartType.Ball

        hitbox.Material = Enum.Material.ForceField

        hitbox.Color = updateRainbowColor()

        hitbox.Transparency = 0.3

    elseif MagnetSettings.hitboxType == "Forcefield" then

        hitbox.Shape = Enum.PartType.Ball

        hitbox.Material = Enum.Material.ForceField

        hitbox.Color = Color3.fromRGB(50, 205, 50)

        hitbox.Transparency = 0.3

    elseif MagnetSettings.hitboxType == "Sphere" then

        hitbox.Shape = Enum.PartType.Ball

        hitbox.Material = Enum.Material.SmoothPlastic

        hitbox.Color = Color3.fromRGB(255, 105, 180)

        hitbox.Transparency = 0.4

        local outline = Instance.new("SelectionSphere")

        outline.Adornee = hitbox

        outline.SurfaceColor3 = Color3.fromRGB(137, 207, 240)

        outline.SurfaceTransparency = 0.3

        outline.Parent = hitbox

    elseif MagnetSettings.hitboxType == "Box" then

        hitbox.Shape = Enum.PartType.Block

        hitbox.Material = Enum.Material.SmoothPlastic

        hitbox.Color = Color3.fromRGB(120, 120, 120)

        hitbox.Transparency = 0.65

        local outline = Instance.new("SelectionBox")

        outline.Adornee = hitbox

        outline.LineThickness = 0.05

        outline.Color3 = Color3.fromRGB(120, 120, 120)

        outline.Transparency = 0.6

        outline.Parent = hitbox

    end

end



local function clearHitbox(ball)

    local hitbox = hitboxes[ball]

    if hitbox then

        hitbox:Destroy()

        hitboxes[ball] = nil

    end

    ballData[ball] = nil

end



local function clearAllHitboxes()

    for ball, hitbox in pairs(hitboxes) do

        if hitbox then hitbox:Destroy() end

    end

    hitboxes = {}

    ballData = {}

end



-- Magnet UI Controls

MagGroupBox:AddToggle("MagnetEnabled", {

    Text = "Magnets",

    Default = false,

    Callback = function(v)

        MagnetSettings.enabled = v

        if not v then clearAllHitboxes() end

    end

})



MagGroupBox:AddDropdown("MagnetType", {

    Values = { "Regular", "League", "Legit", "Rage", "Custom" },

    Default = "Regular",

    Callback = function(v)

        MagnetSettings.mode = v

        if v ~= "Custom" and Options.MagnetRange then

            Options.MagnetRange:SetValue(modeRanges[v])

            MagnetSettings.range = modeRanges[v]

        end

    end

})



MagGroupBox:AddSlider("MagnetRange", {

    Text = "Magnet Range",

    Default = 13,

    Min = 0,

    Max = 25,

    Rounding = 1,

    Callback = function(v)

        MagnetSettings.range = v

    end

})



MagSettingsGroupBox:AddToggle("MagnetHitbox", {

    Text = "Magnet Hitbox",

    Default = false,

    Callback = function(v)

        MagnetSettings.hitboxEnabled = v

        if not v then clearAllHitboxes() end

    end

})



MagSettingsGroupBox:AddDropdown("HitboxType", {

    Values = { "Forcefield", "Sphere", "Box" },

    Default = "Forcefield",

    Callback = function(v)

        MagnetSettings.hitboxType = v

    end

})



MagSettingsGroupBox:AddToggle("RainbowHitbox", {

    Text = "Rainbow Hitbox",

    Default = false,

    Callback = function(v)

        MagnetSettings.rainbowEnabled = v

    end

})



MagSettingsGroupBox:AddSlider("RainbowSpeed", {

    Text = "Rainbow Speed",

    Default = 0.5,

    Min = 0.1,

    Max = 2,

    Rounding = 1,

    Callback = function(v)

        MagnetSettings.rainbowSpeed = v

    end

})



-- Cleanup when ball is removed

Connections.BallRemoved = Workspace.ChildRemoved:Connect(function(obj)

    if obj.Name == "Football" then

        clearHitbox(obj)

    end

end)



-- Magnet Main Loop (optimized)

Connections.MagnetLoop = RunService.Heartbeat:Connect(function(deltaTime)

    if not MagnetSettings.enabled and not MagnetSettings.hitboxEnabled and not MagnetSettings.rainbowEnabled then

        return

    end

    

    if not char or not char.Parent then

        getCharacter()

        return

    end



    local leftCatch = char:FindFirstChild("LeftCatch") or char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")

    local rightCatch = char:FindFirstChild("RightCatch") or char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")

    

    if not leftCatch and not rightCatch then return end



    local range = getMagnetRange()

    local catchParts = {}

    if leftCatch then table.insert(catchParts, leftCatch) end

    if rightCatch then table.insert(catchParts, rightCatch) end



    -- Process all footballs

    for _, ball in pairs(Workspace:GetChildren()) do

        if ball:IsA("BasePart") and ball.Name == "Football" and not ball.Anchored then

            -- Calculate velocity

            local data = ballData[ball]

            if not data then

                data = { lastPos = ball.Position, velocity = Vector3.zero }

                ballData[ball] = data

            else

                data.velocity = (ball.Position - data.lastPos) / deltaTime

                data.lastPos = ball.Position

            end



            -- Update hitbox visualization

            if (MagnetSettings.hitboxEnabled or MagnetSettings.rainbowEnabled) and ball.Parent == Workspace then

                createOrUpdateHitbox(ball)

            else

                clearHitbox(ball)

            end



            -- Magnet logic

            if MagnetSettings.enabled then

                local predictedPos = ball.Position + data.velocity * 0.1

                

                -- Find nearest catch part

                local nearestCatch, nearestDist = nil, math.huge

                for _, part in pairs(catchParts) do

                    local dist = (part.Position - predictedPos).Magnitude

                    if dist < nearestDist then

                        nearestDist = dist

                        nearestCatch = part

                    end

                end



                if nearestCatch and nearestDist <= range then

                    safeCall(firetouchinterest, leftCatch, ball, 0)

                    safeCall(firetouchinterest, leftCatch, ball, 1)

                    if rightCatch then

                        safeCall(firetouchinterest, rightCatch, ball, 0)

                        safeCall(firetouchinterest, rightCatch, ball, 1)

                    end

                end

            end

        end

    end

end)



-- ========== PULL VECTOR ==========

local PullVectorSettings = {

    enabled = false,

    speed = 2,

    radius = 35

}



MagGroupBox:AddToggle("PullVectorEnabled", {

    Text = "Pull Vector",

    Default = false,

    Callback = function(v)

        PullVectorSettings.enabled = v

    end

})



MagGroupBox:AddSlider("PullVectorSpeed", {

    Text = "Pull Speed",

    Default = 2,

    Min = 1,

    Max = 5,

    Rounding = 1,

    Callback = function(v)

        PullVectorSettings.speed = v

    end

})



MagGroupBox:AddSlider("PullVectorRadius", {

    Text = "Pull Radius",

    Default = 35,

    Min = 10,

    Max = 50,

    Rounding = 1,

    Callback = function(v)

        PullVectorSettings.radius = v

    end

})



Connections.PullVector = RunService.Heartbeat:Connect(function()

    if not PullVectorSettings.enabled then return end

    if not char or not hrp then return end



    -- Find closest ball with trail (in-flight)

    local closest, shortestDist = nil, math.huge

    for _, obj in pairs(Workspace:GetChildren()) do

        if obj:IsA("BasePart") and obj.Name == "Football" and not obj.Anchored then

            if obj:FindFirstChildWhichIsA("Trail") then

                local dist = (obj.Position - hrp.Position).Magnitude

                if dist < shortestDist and dist <= PullVectorSettings.radius then

                    shortestDist = dist

                    closest = obj

                end

            end

        end

    end



    if closest then

        local dir = (closest.Position - hrp.Position).Unit

        hrp.AssemblyLinearVelocity = dir * PullVectorSettings.speed * 25

    end

end)



-- ========== ARM SIZE ==========

local ArmSettings = {

    enabled = false,

    size = 4

}



MagGroupBox:AddToggle("ArmSizeEnabled", {

    Text = "Arm Size",

    Default = false,

    Callback = function(v)

        ArmSettings.enabled = v

        if not v and char then

            local l = char:FindFirstChild("Left Arm")

            local r = char:FindFirstChild("Right Arm")

            if l then l.Size = Vector3.new(1, 2, 1) end

            if r then r.Size = Vector3.new(1, 2, 1) end

        end

    end

})



MagGroupBox:AddSlider("ArmSize", {

    Text = "Arm Length",

    Default = 4,

    Min = 2,

    Max = 20,

    Rounding = 1,

    Callback = function(v)

        ArmSettings.size = v

    end

})



Connections.ArmSize = RunService.Heartbeat:Connect(function()

    if not ArmSettings.enabled or not char then return end

    local l = char:FindFirstChild("Left Arm")

    local r = char:FindFirstChild("Right Arm")

    if l then l.Size = Vector3.new(1, ArmSettings.size, 1) end

    if r then r.Size = Vector3.new(1, ArmSettings.size, 1) end

end)



-- ========== PHYSICAL FEATURES ==========

-- Anti Jam

local AntiJamSettings = {

    enabled = false,

    connection = nil,

    charConnections = {}

}



PhysicalGroupBox:AddToggle("AntiJam", {

    Text = "Anti Jam",

    Default = false,

    Callback = function(v)

        AntiJamSettings.enabled = v



        if not v then

            if AntiJamSettings.connection then

                AntiJamSettings.connection:Disconnect()

                AntiJamSettings.connection = nil

            end

            for _, con in pairs(AntiJamSettings.charConnections) do

                con:Disconnect()

            end

            AntiJamSettings.charConnections = {}

            return

        end



        local function noCollide(character)

            if not character then return end

            for _, p in pairs(character:GetChildren()) do

                if p:IsA("BasePart") then

                    p.CanCollide = false

                end

            end

        end



        -- Apply to existing players

        for _, plr in pairs(Players:GetPlayers()) do

            if plr ~= LocalPlayer then

                if plr.Character then noCollide(plr.Character) end

                local con = plr.CharacterAdded:Connect(function(c)

                    task.wait(0.1)

                    noCollide(c)

                end)

                table.insert(AntiJamSettings.charConnections, con)

            end

        end



        -- Continuous application

        AntiJamSettings.connection = RunService.Heartbeat:Connect(function()

            for _, plr in pairs(Players:GetPlayers()) do

                if plr ~= LocalPlayer and plr.Character then

                    noCollide(plr.Character)

                end

            end

        end)

    end

})



-- Anti Block

local AntiBlockEnabled = false



PhysicalGroupBox:AddToggle("AntiBlock", {

    Text = "Anti Block",

    Default = false,

    Callback = function(v)

        AntiBlockEnabled = v

    end

})



Connections.AntiBlock = RunService.Heartbeat:Connect(function()

    if not AntiBlockEnabled or not char then return end

    local torso = char:FindFirstChild("Torso")

    if torso then

        local mover = torso:FindFirstChild("FFmover")

        if mover then mover:Destroy() end

    end

end)



-- ========== PLAYER MOVEMENT ==========

-- WalkSpeed

local WalkSpeedSettings = {

    enabled = false,

    speed = 20

}



PlayerGroupBox:AddToggle("WalkSpeedEnabled", {

    Text = "WalkSpeed",

    Default = false,

    Callback = function(v)

        WalkSpeedSettings.enabled = v

        if hum then

            hum.WalkSpeed = v and WalkSpeedSettings.speed or 16

        end

    end

})



PlayerGroupBox:AddSlider("WalkSpeedAmount", {

    Text = "WalkSpeed Amount",

    Default = 20,

    Min = 20,

    Max = 23,

    Rounding = 1,

    Callback = function(v)

        WalkSpeedSettings.speed = v

        if WalkSpeedSettings.enabled and hum then

            hum.WalkSpeed = v

        end

    end

})



Connections.WalkSpeed = RunService.Heartbeat:Connect(function()

    if not WalkSpeedSettings.enabled or not hum or not hrp then return end

    local mv = hum.MoveDirection

    if mv.Magnitude > 0 then

        hrp.Velocity = Vector3.new(mv.X * WalkSpeedSettings.speed, hrp.Velocity.Y, mv.Z * WalkSpeedSettings.speed)

    end

end)



-- CFrame Speed

local CFrameSettings = {

    enabled = false,

    speed = 1,

    type = "CFrame Speed"

}



PlayerGroupBox:AddToggle("CframeEnabled", {

    Text = "Cframe",

    Default = false,

    Callback = function(v)

        CFrameSettings.enabled = v

    end

})



PlayerGroupBox:AddSlider("CframeSlider", {

    Text = "Cframe slider",

    Default = 1,

    Min = 1,

    Max = 20,

    Rounding = 1,

    Callback = function(v)

        CFrameSettings.speed = v

    end

})



PlayerGroupBox:AddDropdown("SpeedType", {

    Values = { "CFrame Speed", "Velocity Speed" },

    Default = "CFrame Speed",

    Callback = function(v)

        CFrameSettings.type = v

    end

})



Connections.CFrameSpeed = RunService.Heartbeat:Connect(function()

    if not CFrameSettings.enabled or not hum or not hrp then return end

    local dir = hum.MoveDirection

    if dir.Magnitude > 0 then

        if CFrameSettings.type == "Velocity Speed" then

            hrp.Velocity = dir * (CFrameSettings.speed * 10)

        else

            hrp.CFrame += dir * (CFrameSettings.speed / 58.5)

        end

    end

end)



-- JumpPower

local JumpSettings = {

    enabled = false,

    power = 50,

    connection = nil

}



local function setupJumpPower()

    if JumpSettings.connection then

        JumpSettings.connection:Disconnect()

    end

    

    if not hum then return end

    

    JumpSettings.connection = hum.StateChanged:Connect(function(_, state)

        if state == Enum.HumanoidStateType.Jumping and JumpSettings.enabled and hrp then

            task.delay(0.02, function()

                if hrp and JumpSettings.enabled then

                    hrp.Velocity = Vector3.new(hrp.Velocity.X, JumpSettings.power, hrp.Velocity.Z)

                end

            end)

        end

    end)

end



setupJumpPower()



PlayerGroupBox:AddToggle("JumpPowerEnabled", {

    Text = "Enable JumpPower",

    Default = false,

    Callback = function(state)

        JumpSettings.enabled = state

    end

})



PlayerGroupBox:AddSlider("JumpPowerValue", {

    Text = "JumpPower Value",

    Default = 50,

    Min = 50,

    Max = 70,

    Rounding = 1,

    Callback = function(value)

        JumpSettings.power = value

    end

})



-- ========== ANGLE ENHANCER ==========

local AngleEnhancerSettings = {

    enabled = false,

    jumpPower = 50,

    boosting = false,

    connection = nil

}



local function setupAngleEnhancer()

    if AngleEnhancerSettings.connection then

        AngleEnhancerSettings.connection:Disconnect()

    end

    

    if not hum or not hrp then return end

    

    AngleEnhancerSettings.connection = hum.StateChanged:Connect(function(_, newState)

        if newState == Enum.HumanoidStateType.Jumping and AngleEnhancerSettings.enabled then

            task.wait(0.05)

            if hrp then

                local velocity = hrp.AssemblyLinearVelocity

                local power = AngleEnhancerSettings.boosting and AngleEnhancerSettings.jumpPower or (AngleEnhancerSettings.jumpPower - 10)

                hrp.AssemblyLinearVelocity = Vector3.new(velocity.X, power, velocity.Z)

            end

        end

    end)

end



setupAngleEnhancer()



Connections.AngleEnhancer = RunService.RenderStepped:Connect(function()

    if AngleEnhancerSettings.enabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then

        if not AngleEnhancerSettings.boosting then

            AngleEnhancerSettings.boosting = true

            task.delay(0.25, function()

                AngleEnhancerSettings.boosting = false

            end)

        end

    end

end)



PlayerAdvancedGroupBox:AddToggle("AngleEnhancer", {

    Text = "Angle Enhancer",

    Default = false,

    Callback = function(v)

        AngleEnhancerSettings.enabled = v

    end

})



PlayerAdvancedGroupBox:AddSlider("AngleJumpPower", {

    Text = "Angle Enhancer Power",

    Default = 50,

    Min = 50,

    Max = 70,

    Rounding = 1,

    Callback = function(v)

        AngleEnhancerSettings.jumpPower = v

    end

})



-- ========== NO JUMP COOLDOWN ==========

local NoJumpCooldownEnabled = false



local function applyNoJumpCooldown()

    if not hum or not NoJumpCooldownEnabled then return end

    hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)

end



Connections.NoJumpCooldown = RunService.Heartbeat:Connect(applyNoJumpCooldown)



PlayerAdvancedGroupBox:AddToggle("NoJumpCooldown", {

    Text = "No Jump Cooldown",

    Default = false,

    Callback = function(v)

        NoJumpCooldownEnabled = v

    end

})



-- ========== QUICK TP ==========

local QuickTPSettings = {

    enabled = false,

    distance = 0,

    showMobile = false,

    screenGui = nil

}



local function teleportForward()

    if not hrp then return end

    local dir = hrp.CFrame.LookVector

    local pos = hrp.Position + dir * QuickTPSettings.distance

    hrp.CFrame = CFrame.new(pos, pos + dir)

end



Connections.QuickTP = UserInputService.InputBegan:Connect(function(input, gpe)

    if not gpe and input.KeyCode == Enum.KeyCode.F and QuickTPSettings.enabled then

        teleportForward()

    end

end)



local function createMobileTPButton()

    if QuickTPSettings.screenGui then

        QuickTPSettings.screenGui:Destroy()

    end

    

    local gui = Instance.new("ScreenGui")

    gui.Name = "QuickTP"

    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    gui.ResetOnSpawn = false

    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")



    local btn = Instance.new("TextButton")

    btn.Size = UDim2.new(0, 70, 0, 70)

    btn.Position = UDim2.new(0.5, -35, 1, -100)

    btn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)

    btn.Text = "TP"

    btn.TextColor3 = Color3.fromRGB(0, 0, 0)

    btn.Font = Enum.Font.GothamBold

    btn.TextSize = 22

    btn.Parent = gui



    local corner = Instance.new("UICorner")

    corner.CornerRadius = UDim.new(0.5, 0)

    corner.Parent = btn



    btn.MouseButton1Click:Connect(function()

        if QuickTPSettings.enabled then

            teleportForward()

        end

    end)



    QuickTPSettings.screenGui = gui

end



local function removeMobileTPButton()

    if QuickTPSettings.screenGui then

        QuickTPSettings.screenGui:Destroy()

        QuickTPSettings.screenGui = nil

    end

end



PlayerAdvancedGroupBox:AddToggle("QuickTP", {

    Text = "Quick TP (Press F)",

    Default = false,

    Callback = function(v)

        QuickTPSettings.enabled = v

    end

})



PlayerAdvancedGroupBox:AddSlider("TPDistance", {

    Text = "Quick TP Distance",

    Default = 0,

    Min = 0,

    Max = 5,

    Rounding = 1,

    Callback = function(v)

        QuickTPSettings.distance = v

    end

})



PlayerAdvancedGroupBox:AddToggle("ShowMobileTP", {

    Text = "Show Button (Mobile)",

    Default = false,

    Callback = function(v)

        QuickTPSettings.showMobile = v

        if v then

            createMobileTPButton()

        else

            removeMobileTPButton()

        end

    end

})



-- ========== COMBAT FEATURES ==========

local TackleReachSettings = {

    enabled = false,

    range = 15,

    showHitbox = false,

    connection = nil

}



local function activateTackleReach()

    if TackleReachSettings.connection then

        TackleReachSettings.connection:Disconnect()

    end



    TackleReachSettings.connection = RunService.Heartbeat:Connect(function()

        if not TackleReachSettings.enabled or not char or not hrp then return end



        local players = Players:GetPlayers()

        for _, plr in pairs(players) do

            if plr ~= LocalPlayer and plr.Character then

                local targetHRP = plr.Character:FindFirstChild("HumanoidRootPart")

                if targetHRP then

                    local dist = (hrp.Position - targetHRP.Position).Magnitude

                    if dist <= TackleReachSettings.range then

                        for _, part in pairs(plr.Character:GetChildren()) do

                            if part:IsA("BasePart") then

                                local myPart = char:FindFirstChild(part.Name)

                                if myPart then

                                    safeCall(firetouchinterest, myPart, part, 0)

                                    safeCall(firetouchinterest, myPart, part, 1)

                                end

                            end

                        end

                    end

                end

            end

        end

    end)

end



PlayerCombatGroupBox:AddToggle("TackleReach", {

    Text = "Tackle Reach",

    Default = false,

    Callback = function(v)

        TackleReachSettings.enabled = v

        if v then

            activateTackleReach()

        elseif TackleReachSettings.connection then

            TackleReachSettings.connection:Disconnect()

            TackleReachSettings.connection = nil

        end

    end

})



PlayerCombatGroupBox:AddSlider("TackleReachRange", {

    Text = "Custom Reach",

    Default = 15,

    Min = 0,

    Max = 25,

    Rounding = 1,

    Callback = function(v)

        TackleReachSettings.range = v

    end

})



PlayerCombatGroupBox:AddToggle("ShowTackleHitbox", {

    Text = "Show Hitbox",

    Default = false,

    Callback = function(v)

        TackleReachSettings.showHitbox = v

    end

})



-- ========== VISUALS ==========

-- Jump predictions

local JumpPredictionSettings = {

    enabled = false,

    connection = nil

}



VisualsGroupBox:AddToggle("JumpPredictions", {

    Text = "Jump predictions",

    Default = false,

    Callback = function(v)

        JumpPredictionSettings.enabled = v

        

        if v then

            JumpPredictionSettings.connection = Workspace.ChildAdded:Connect(function(ball)

                if not JumpPredictionSettings.enabled then return end

                if not (ball.Name == "Football" and ball:IsA("BasePart")) then return end

                

                task.wait()

                

                local v0 = ball.Velocity

                local x0 = ball.Position

                local dt = 1/30

                local grav = Vector3.new(0, -28, 0)

                local points = { x0 }

                

                local rayParams = RaycastParams.new()

                rayParams.RespectCanCollide = true

                

                for _ = 1, 300 do -- Max iterations to prevent infinite loop

                    local currentPoint = points[#points]

                    local ray = Workspace:Raycast(currentPoint, Vector3.new(0, -1000, 0), rayParams)

                    local ray2 = Workspace:Raycast(currentPoint, Vector3.new(0, -14.4, 0), rayParams)

                    

                    if not ray or ray2 then

                        if v0.Y < 0 then break end

                    end

                    

                    v0 += grav * dt

                    points[#points + 1] = currentPoint + (v0 * dt)

                end

                

                local optimal = points[#points]

                if not optimal or not hrp then return end

                

                local part = Instance.new("Part")

                part.Anchored = true

                part.CanCollide = false

                part.CanQuery = false

                part.CastShadow = false

                part.Position = Vector3.new(optimal.X, hrp.Position.Y + 1.5, optimal.Z)

                part.Material = Enum.Material.Neon

                part.Size = Vector3.new(1.5, 1.5, 1.5)

                part.Color = Color3.fromRGB(159, 115, 254)

                part.Parent = Workspace

                

                -- Wait for ball to be caught/removed

                repeat task.wait() until not ball.Parent or ball.Parent ~= Workspace

                part:Destroy()

            end)

        else

            if JumpPredictionSettings.connection then

                JumpPredictionSettings.connection:Disconnect()

                JumpPredictionSettings.connection = nil

            end

        end

    end

})



-- Ball Path

local Grapher = {

    Width = 0.6,

    CastStep = 3 / 60,

    Gravity = 28,

    Enabled = false,

    LastUpdate = 0,

    Template = nil

}



Grapher.Template = Instance.new("Part")

Grapher.Template.Anchored = true

Grapher.Template.CanCollide = false

Grapher.Template.CanQuery = false

Grapher.Template.CastShadow = false

Grapher.Template.Transparency = 1

Grapher.Template.Name = "BeamHolder"



function Grapher:GetFolder()

    local f = Workspace:FindFirstChild("NovaFF2Visuals")

    if not f then

        f = Instance.new("Folder")

        f.Name = "NovaFF2Visuals"

        f.Parent = Workspace

    end

    return f

end



function Grapher:GetDynamicColor()

    local t = tick() * 2

    local lerpVal = (math.sin(t) + 1) / 2

    local babyBlue = Color3.fromRGB(137, 207, 240)

    local babyPurple = Color3.fromRGB(159, 115, 254)

    return babyBlue:Lerp(babyPurple, lerpVal)

end



function Grapher:Segment(p0, p1)

    local part = self.Template:Clone()

    part.Parent = self:GetFolder()



    local a0 = Instance.new("Attachment")

    a0.WorldPosition = p0

    a0.Parent = part

    

    local a1 = Instance.new("Attachment")

    a1.WorldPosition = p1

    a1.Parent = part



    local beam = Instance.new("Beam")

    beam.Attachment0 = a0

    beam.Attachment1 = a1

    beam.Color = ColorSequence.new(self:GetDynamicColor())

    beam.Transparency = NumberSequence.new(0.1)

    beam.Width0 = self.Width

    beam.Width1 = self.Width

    beam.FaceCamera = true

    beam.LightEmission = 1

    beam.Parent = part



    Debris:AddItem(part, 4)

end



function Grapher:Trajectory(origin, velocity)

    local points = {}

    local elapsed = 0

    

    while elapsed < 5 do

        elapsed += self.CastStep

        local pos = origin + velocity * elapsed - Vector3.new(0, 0.5 * self.Gravity * elapsed^2, 0)

        table.insert(points, pos)

    end

    

    for i = 1, #points - 1 do

        self:Segment(points[i], points[i + 1])

    end

end



function Grapher:Run(position, velocity)

    local now = tick()

    if now - self.LastUpdate < 0.15 then return end

    self.LastUpdate = now

    self:Trajectory(position, velocity)

end



Connections.BallPath = Workspace.ChildAdded:Connect(function(child)

    if child:IsA("BasePart") and child.Name == "Football" then

        local con

        con = child:GetPropertyChangedSignal("Velocity"):Connect(function()

            if Grapher.Enabled then

                Grapher:Run(child.Position, child.Velocity)

            end

            con:Disconnect()

        end)

    end

end)



VisualsGroupBox:AddToggle("BallPath", {

    Text = "Ball Path",

    Default = false,

    Callback = function(v)

        Grapher.Enabled = v

    end

})



-- ========== MISC TAB ==========

MiscGroupBox:AddButton("No Textures", function()

    local count = 0

    local services = {

        Workspace,

        game:GetService("Lighting"),

        game:GetService("ReplicatedStorage"),

        game:GetService("ReplicatedFirst")

    }

    

    -- Also include all player characters

    for _, player in pairs(Players:GetPlayers()) do

        if player.Character then

            table.insert(services, player.Character)

        end

    end

    

    for _, service in pairs(services) do

        pcall(function()

            for _, obj in pairs(service:GetDescendants()) do

                if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SurfaceAppearance") then

                    pcall(function()

                        obj.Transparency = 1

                        obj:Destroy()

                    end)

                    count = count + 1

                end

            end

        end)

    end

    

    -- Also remove textures from terrain and parts by setting material

    pcall(function()

        for _, obj in pairs(Workspace:GetDescendants()) do

            if obj:IsA("BasePart") and obj.Name ~= "Terrain" then

                pcall(function()

                    if obj.Material == Enum.Material.Grass or 

                       obj.Material == Enum.Material.Sand or 

                       obj.Material == Enum.Material.Rock or 

                       obj.Material == Enum.Material.Brick or 

                       obj.Material == Enum.Material.Concrete or

                       obj.Material == Enum.Material.Wood or

                       obj.Material == Enum.Material.WoodPlanks or

                       obj.Material == Enum.Material.Fabric or

                       obj.Material == Enum.Material.Marble or

                       obj.Material == Enum.Material.Granite or

                       obj.Material == Enum.Material.Pebble or

                       obj.Material == Enum.Material.Cobblestone then

                        obj.Material = Enum.Material.SmoothPlastic

                    end

                end)

            end

        end

    end)

    

    Library:Notify({
        Title = "Nova Hub",
        Description = "Removed " .. count .. " textures!",
        Time = 3

    })

end)



-- ========== SETTINGS TAB ==========

local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu", "wrench")



MenuGroup:AddToggle("KeybindMenuOpen", {

    Default = Library.KeybindFrame.Visible,

    Text = "Open Keybind Menu",

    Callback = function(value)

        Library.KeybindFrame.Visible = value

    end

})



MenuGroup:AddToggle("ShowCustomCursor", {

    Text = "Custom Cursor",

    Default = true,

    Callback = function(Value)

        Library.ShowCustomCursor = Value

    end

})



MenuGroup:AddDropdown("NotificationSide", {

    Values = { "Left", "Right" },

    Default = "Right",

    Text = "Notification Side",

    Callback = function(Value)

        Library:SetNotifySide(Value)

    end

})



MenuGroup:AddDivider()

MenuGroup:AddLabel("Menu bind")

    :AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })



MenuGroup:AddButton("Unload", function()

    -- Cleanup all connections

    for name, con in pairs(Connections) do

        if typeof(con) == "RBXScriptConnection" then

            con:Disconnect()

        end

    end

    

    -- Cleanup special connections

    if AntiJamSettings.connection then AntiJamSettings.connection:Disconnect() end

    for _, con in pairs(AntiJamSettings.charConnections) do con:Disconnect() end

    if TackleReachSettings.connection then TackleReachSettings.connection:Disconnect() end

    if JumpSettings.connection then JumpSettings.connection:Disconnect() end

    if AngleEnhancerSettings.connection then AngleEnhancerSettings.connection:Disconnect() end

    if JumpPredictionSettings.connection then JumpPredictionSettings.connection:Disconnect() end

    

    -- Cleanup visuals

    clearAllHitboxes()

    removeMobileTPButton()

    

    local folder = Workspace:FindFirstChild("ProjectFF2Visuals")

    if folder then folder:Destroy() end

    

    Library:Unload()

end)



Library.ToggleKeybind = Options.MenuKeybind



-- Hand the library over to our managers

ThemeManager:SetLibrary(Library)

SaveManager:SetLibrary(Library)



SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({ "MenuKeybind" })



ThemeManager:SetFolder("NovaFF2")

SaveManager:SetFolder("NovaFF2/settings")



SaveManager:BuildConfigSection(Tabs.Settings)

ThemeManager:ApplyToTab(Tabs.Settings)

SaveManager:LoadAutoloadConfig()



-- Re-setup connections on respawn

Connections.RespawnHandler = LocalPlayer.CharacterAdded:Connect(function(newChar)

    char = newChar

    hum = newChar:WaitForChild("Humanoid", 10)

    hrp = newChar:WaitForChild("HumanoidRootPart", 10)

    

    task.wait(0.5)

    

    -- Re-setup state-based features

    setupJumpPower()

    setupAngleEnhancer()

    

    -- Reapply walkspeed

    if WalkSpeedSettings.enabled and hum then

        hum.WalkSpeed = WalkSpeedSettings.speed

    end

    

    -- Reapply arm size

    if ArmSettings.enabled then

        local l = char:FindFirstChild("Left Arm")

        local r = char:FindFirstChild("Right Arm")

        if l then l.Size = Vector3.new(1, ArmSettings.size, 1) end

        if r then r.Size = Vector3.new(1, ArmSettings.size, 1) end

    end

end)



Library:Notify({

    Title = "Nova Hub",

    Description = "Successfully loaded!",

    Time = 3

})
