local _JIT_MAX = function(f) return f end
local _NO_VIRT = function(f) return f end
local _NO_UPS  = function(f) return f end

print("Cryptic FF2 Loading..") 
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalizationService = game:GetService("LocalizationService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

-- PLAYER REFERENCES
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    LocalPlayer = Players.LocalPlayer
    task.wait()
end
local Mouse = LocalPlayer:GetMouse()

getgenv().QBA = {
    enabled = false,
    mobileEnabled = false,  -- Toggle for mobile buttons
    data = {
        Direction = Vector3.new(0, 0, 0),
        Power = 0
    }
}

local ShowUICards = true
local ShowLockButton = false
local ShowSwitchButton = false

local CurrentThrowType = "Dime"
local ThrowTypeMap = {
    ["Dime"] = "Mag",
    ["Mag"] = "Bullet",
    ["Bullet"] = "Dime"
}

local ThrowLeadDistance = {
    Dime = 5,
    Mag = 4,
    Bullet = 0.6
}

local IsTargetLocked = false
local LockedTarget = nil
local CurrentTarget = nil

local ThrowData = {
    angle = 40,
    power = 0,
    direction = Vector3.new(0, 0, 0)
}

local TrajectoryEnabled = true
local TrajectoryColor = Color3.new(1, 1, 1)
local TrajectoryBeam = nil
local TrajectoryAttachment0 = nil
local TrajectoryAttachment1 = nil
local TrajectoryEndPart = nil

local AutoAngleEnabled = false
local CustomAngleEnabled = true
local CustomAngleValue = 40

local TargetHighlight = Instance.new("Highlight")
TargetHighlight.FillColor = Color3.fromRGB(200, 200, 200)
TargetHighlight.OutlineColor = Color3.fromRGB(200, 200, 200)
TargetHighlight.Parent = CoreGui


local Config = {
    Hitbox = {
        Color = Color3.fromRGB(138, 43, 226),
        Enabled = false,
        Transparency = 0.5,
        Shape = "Ball",
        RotationSpeed = 0,
        Radius = 30,
        Rainbow = false,
        RainbowHue = 0,
        RainbowSaturation = 1,
        RainbowValue = 1,
        RainbowIncrement = 0.02,
        RainbowSpeed = 0.05
    },
    Magnet = {
        Enabled = false,
        Type = "Normal",
        ForceMultiplier = 1,
        Delay = 0
    },
    DiveEnabled = false,
    DiveRange = 2,
    BallPathEnabled = false,
    PredictionColor = Color3.fromRGB(138, 43, 226),
    PredictTime = 10
}

local PlayerMods = {
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait(),
    Humanoid = nil,
    RootPart = nil,
    JUMP_POWER = 50,
    speedEnabled = false,
    speedValue = 0.5,
    movementConnection = nil,
    jumpEnabled = false,
    jumpVelocity = 50,
    infiniteJump = false,
    NoJumpCooldown = false,
    AutoFixWalkSpeed = false,
    DESIRED_SPEED = 20,
    NoCollision = false,
    BlockReach = false,
    BlockReachSize = 5
}

local FreezeController = {
    autoFreezeEnabled = false,
    autoFreezeMode = "After Catch",
    autoFreezeDuration = 0.25,
    manualFreezeEnabled = true,
    manualMode = "Toggle",
    freezeBind = Enum.KeyCode.G,
    mobileFreezeEnabled = true,
    character = nil,
    humanoid = nil,
    rootPart = nil,
    originalPlatformStand = false,
    frozen = false,
    autoUnfreezeAt = nil,
    inAir = false,
    apexFired = false,
    jumpArmed = false,
    peakY = 0,
    jumpStart = 0,
    lastCatch = 0,
    CATCH_DEBOUNCE = 0.25,
    MIN_AIR_TIME = 0.06,
    ARM_VY = 2,
    APEX_VY = 0.15,
    DESCEND_EPS = 0.03
}

local AutoRush = {enabled = false, predictionDelay = 0}
local PullVector = {enabled = false, power = 1, distance = 20, connection = nil}
local AutoKick = {Enabled = false, WalkToBall = true, KickPower = 95, KickAccuracy = 95, Randomize = false}
local JumpPrediction = {enabled = false, connection = nil}
local Skybox = {enabled = false, selected = "Gray", intensity = 0, Original = {}, originalSkySnap = nil}
local Misc = {tpEnabled = false, mobileTPEnabled = false, tpDistance = 10, fpsCapEnabled = false, fpsCapValue = 120, noTexturesEnabled = false, stadiumHidden = false, AntiOOB = false, AntiBlock = false, AntiAdmin = false, boostEnabled = false, boostDuration = 0.18, maxJP = 70, boostToken = 0, boostConn = nil, angleTick = 0, shiftLockEnabled = false, lastEnabled = false}

local hue = 0
local rainbowTick = 0
local rotationDeg = 0
local scanTick = 0
local closestBall = nil
local closestDist = math.huge
local activeTweens = {}

local HitboxPart = Instance.new("Part")
HitboxPart.Name = "CatchHitbox"
HitboxPart.Size = Vector3.new(30, 30, 30)
HitboxPart.Transparency = 1
HitboxPart.Anchored = true
HitboxPart.CanCollide = false
HitboxPart.Shape = Enum.PartType.Ball
HitboxPart.Material = Enum.Material.ForceField
HitboxPart.Color = Color3.fromRGB(138, 43, 226)
HitboxPart.Parent = Workspace

local Utilities = {}

function Utilities.HasFootball()
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():match("football") or tool:FindFirstChild("Handle")) then
            return true
        end
    end
    return false
end

function Utilities.BeamProjectile(gravity, velocity, startPos, flightTime)
    local c = 0.125
    local p3 = 0.5 * gravity * flightTime * flightTime + velocity * flightTime + startPos
    local p2 = p3 - (gravity * flightTime * flightTime + velocity * flightTime) / 3
    local p1 = (c * gravity * flightTime * flightTime + 0.5 * velocity * flightTime + startPos - c * (startPos + p3)) / (3 * c) - p2
    
    local curve0 = (p1 - startPos).Magnitude
    local curve1 = (p2 - p3).Magnitude
    
    local b = (startPos - p3).Unit
    local r1 = (p1 - startPos).Unit
    local u1 = r1:Cross(b).Unit
    local r2 = (p2 - p3).Unit
    local u2 = r2:Cross(b).Unit
    b = u1:Cross(r1).Unit
    
    local cf1 = CFrame.new(startPos.x, startPos.y, startPos.z, r1.x, u1.x, b.x, r1.y, u1.y, b.y, r1.z, u1.z, b.z)
    local cf2 = CFrame.new(p3.x, p3.y, p3.z, r2.x, u2.x, b.x, r2.y, u2.y, b.y, r2.z, u2.z, b.z)
    
    return curve0, -curve1, cf1, cf2
end

local ScreenGui = Instance.new('ScreenGui')
ScreenGui.Name = 'QBAimbotUI'
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new('Frame')
MainFrame.Name = 'MainFrame'
MainFrame.Size = UDim2.new(0, 600, 0, 90)
MainFrame.Position = UDim2.new(0.5, -300, 0.05, 0)
MainFrame.BackgroundTransparency = 1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UIListLayout = Instance.new('UIListLayout')
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout.Padding = UDim.new(0, 16)
UIListLayout.Parent = MainFrame

local function CreateStatCard(cardName, initialValue)
    local card = Instance.new('Frame')
    card.Name = cardName
    card.Size = UDim2.new(0, 100, 0, 70)
    card.BackgroundColor3 = Color3.fromRGB(18, 8, 30)
    card.BackgroundTransparency = 0.1
    card.BorderSizePixel = 0
    card.Parent = MainFrame
    
    local corner = Instance.new('UICorner')
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card
    
    local stroke = Instance.new('UIStroke')
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = card
    
    local titleLabel = Instance.new('TextLabel')
    titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = cardName
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 12
    titleLabel.Font = Enum.Font.GothamMedium
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.Parent = card
    
    local divider = Instance.new('Frame')
    divider.Size = UDim2.new(0.8, 0, 0, 1)
    divider.Position = UDim2.new(0.1, 0, 0.4, 0)
    divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    divider.BackgroundTransparency = 0.4
    divider.BorderSizePixel = 0
    divider.Parent = card
    
    local valueLabel = Instance.new('TextLabel')
    valueLabel.Name = cardName .. 'Value'
    valueLabel.Size = UDim2.new(1, 0, 0.6, 0)
    valueLabel.Position = UDim2.new(0, 0, 0.4, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(initialValue)
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.TextSize = 20
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center
    valueLabel.TextYAlignment = Enum.TextYAlignment.Center
    valueLabel.TextStrokeTransparency = 0.8
    valueLabel.Parent = card
    
    return valueLabel
end

-- Create stat cards
local ThrowTypeDisplay = CreateStatCard('Mode (Z)', 'Dime')
local PowerDisplay = CreateStatCard('Power', '0')
local TargetDisplay = CreateStatCard('Target', 'None')
local FlightTimeDisplay = CreateStatCard('Time', '0.00s')
local AngleDisplay = CreateStatCard('Angle (R/F)', '40')
local InterceptableDisplay = CreateStatCard('Interceptable', 'No')

MainFrame.Visible = false

-- Mobile buttons container
local MobileButtonsFrame = Instance.new('Frame')
MobileButtonsFrame.Name = 'MobileButtonsFrame'
MobileButtonsFrame.Size = UDim2.new(0, 200, 0, 250)
MobileButtonsFrame.Position = UDim2.new(0.02, 0, 0.5, -125)
MobileButtonsFrame.BackgroundTransparency = 1
MobileButtonsFrame.Visible = false
MobileButtonsFrame.Parent = ScreenGui

local function CreateMobileButton(name, text, position)
    local button = Instance.new('TextButton')
    button.Name = name
    button.Size = UDim2.new(1, 0, 0, 45)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(18, 8, 30)
    button.BackgroundTransparency = 0.2
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(200, 170, 255)
    button.TextSize = 16
    button.Font = Enum.Font.GothamBold
    button.Parent = MobileButtonsFrame
    
    local corner = Instance.new('UICorner')
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local stroke = Instance.new('UIStroke')
    stroke.Color = Color3.fromRGB(110, 80, 170)
    stroke.Thickness = 2
    stroke.Parent = button
    
    return button
end

-- Create mobile buttons
local MobileModeSwitchBtn = CreateMobileButton('ModeSwitch', 'Change Mode', UDim2.new(0, 0, 0, 0))
local MobileLockBtn = CreateMobileButton('Lock', 'Lock', UDim2.new(0, 0, 0, 55))
local MobileAngleUpBtn = CreateMobileButton('AngleUp', 'Increase Angle', UDim2.new(0, 0, 0, 110))
local MobileAngleDownBtn = CreateMobileButton('AngleDown', 'Decrease Angle', UDim2.new(0, 0, 0, 165))

-- Mobile button event handlers
MobileModeSwitchBtn.Activated:Connect(function()
    if not QBA.enabled then return end
    CurrentThrowType = ThrowTypeMap[CurrentThrowType]
    MobileModeSwitchBtn.Text = "Change Mode"
    SwitchModeText.Text = CurrentThrowType
end)

MobileLockBtn.Activated:Connect(function()
    if not QBA.enabled or not Utilities.HasFootball() then return end
    IsTargetLocked = not IsTargetLocked
    if IsTargetLocked then
        LockedTarget = CurrentTarget
        MobileLockBtn.Text = 'Locked'
    else
        LockedTarget = nil
        MobileLockBtn.Text = 'Unlocked'
    end
end)

MobileAngleUpBtn.Activated:Connect(function()
    if not QBA.enabled or not CustomAngleEnabled then return end
    CustomAngleValue = math.min(CustomAngleValue + 5, 55)
end)

MobileAngleDownBtn.Activated:Connect(function()
    if not QBA.enabled or not CustomAngleEnabled then return end
    CustomAngleValue = math.max(CustomAngleValue - 5, 15)
end)

local function FindClosestTeammate()
    if not QBA.enabled then return nil end
    
    local camera = Workspace.CurrentCamera
    local closestDistance = math.huge
    local closestTarget = nil
    
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            local humanoid = obj:FindFirstChild("Humanoid")
            local characterPlayer = Players:GetPlayerFromCharacter(obj)
            
            if humanoid.Health > 0 and obj ~= LocalPlayer.Character and characterPlayer and characterPlayer.Team == LocalPlayer.Team then
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                local screenPoint = camera:WorldToViewportPoint(hrp.Position)
                local mousePos = UserInputService:GetMouseLocation()
                local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                
                if distance < closestDistance then
                    closestTarget = obj
                    closestDistance = distance
                end
            end
        end
    end
    
    -- Check NPCs for training
    local npcDistance = math.huge
    local npcTarget = nil
    
    for _, bot in ipairs(Workspace:GetChildren()) do
        if bot.Name == "npcwr" then
            local stationA = bot:FindFirstChild("a")
            local stationB = bot:FindFirstChild("b")
            if stationA and stationB then
                local bots = {stationA:FindFirstChild("bot 1"), stationB:FindFirstChild("bot 3")}
                for _, currentBot in ipairs(bots) do
                    if currentBot and currentBot:FindFirstChild("HumanoidRootPart") then
                        local screenPoint = camera:WorldToViewportPoint(currentBot.HumanoidRootPart.Position)
                        local mousePos = UserInputService:GetMouseLocation()
                        local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                        
                        if distance < npcDistance then
                            npcTarget = currentBot
                            npcDistance = distance
                        end
                    end
                end
            end
        end
    end
    
    return closestDistance < npcDistance and closestTarget or npcTarget
end

local function CalculateVelocityFromAngle(startPos, targetPos, gravity, angleDegrees)
    local rad = math.rad(angleDegrees)
    local dxz = Vector3.new(targetPos.X - startPos.X, 0, targetPos.Z - startPos.Z).Magnitude
    local dy = targetPos.Y - startPos.Y
    
    local cosAngle = math.cos(rad)
    local sinAngle = math.sin(rad)
    
    local numerator = gravity.Magnitude * dxz * dxz
    local denominator = 2 * cosAngle * cosAngle * (dxz * math.tan(rad) - dy)
    
    if denominator <= 0 then return nil end
    
    local v0Mag = math.sqrt(numerator / denominator)
    local horizontalDir = (Vector3.new(targetPos.X, startPos.Y, targetPos.Z) - startPos).Unit
    
    return horizontalDir * (v0Mag * cosAngle) + Vector3.new(0, v0Mag * sinAngle, 0)
end

local function UpdateUIDisplay(throwType, power, targetName, flightTime, angle, interceptable)
    ThrowTypeDisplay.Text = throwType
    PowerDisplay.Text = tostring(power)
    TargetDisplay.Text = targetName
    FlightTimeDisplay.Text = string.format('%.2fs', flightTime)
    AngleDisplay.Text = tostring(math.floor(angle))
    InterceptableDisplay.Text = interceptable and "Yes" or "No"
end

_G.__QBA_HB = _G.__QBA_HB or nil
if _G.__QBA_HB then
    _G.__QBA_HB:Disconnect()
    _G.__QBA_HB = nil
end

_G.__QBA_RUN_ID = (_G.__QBA_RUN_ID or 0) + 1
local RUN_ID = _G.__QBA_RUN_ID
print("[QBA] starting Heartbeat loop instance:", RUN_ID)

_G.__QBA_HB = RunService.Heartbeat:Connect(function()
    
    if not QBA.enabled then
        CurrentTarget = nil
        LockedTarget = nil
        TargetHighlight.Parent = nil
        MainFrame.Visible = false
        MobileButtonsFrame.Visible = false
        
        if TrajectoryBeam then
            TrajectoryBeam:Destroy()
            TrajectoryAttachment0:Destroy()
            TrajectoryAttachment1:Destroy()
            TrajectoryEndPart:Destroy()
            TrajectoryBeam = nil
            TrajectoryAttachment0 = nil
            TrajectoryAttachment1 = nil
            TrajectoryEndPart = nil
        end
        return
    end
    

    if IsTargetLocked and LockedTarget then
        CurrentTarget = LockedTarget
    else
        CurrentTarget = FindClosestTeammate()
    end
    
    local character = LocalPlayer.Character
    if CurrentTarget and character and character:FindFirstChild("Head") and CurrentTarget:FindFirstChild("HumanoidRootPart") and Utilities.HasFootball() then
        TargetHighlight.OutlineColor = IsTargetLocked and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(200, 200, 200)
        TargetHighlight.FillColor = IsTargetLocked and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(200, 200, 200)
        
        local gravity = Vector3.new(0, -28, 0)
        local leadDistance = ThrowLeadDistance[CurrentThrowType]
        local head = character.Head
        local startPosition = head.Position + Vector3.new(0, 2, 0)
        
        local receiverVelocity = CurrentTarget.HumanoidRootPart.Velocity
        local horizontalVelocity = Vector3.new(receiverVelocity.X, 0, receiverVelocity.Z)
        local speed = horizontalVelocity.Magnitude
        local moveDirection = horizontalVelocity.Unit
        
        if speed < 1 then
            moveDirection = (CurrentTarget.HumanoidRootPart.Position - startPosition).Unit
        end
        
        local targetPosition = CurrentTarget.HumanoidRootPart.Position + horizontalVelocity * 1.2 + moveDirection * leadDistance + Vector3.new(0, 5, 0)
        local horizontalDistance = (startPosition - targetPosition).Magnitude
        
        if horizontalDistance < 1 then
            ThrowData.direction = Vector3.new(0, 0, 0)
            ThrowData.power = 0
            QBA.data.Direction = Vector3.new(0, 0, 0)
            QBA.data.Power = 0
            TargetHighlight.Parent = nil
            
            if TrajectoryBeam then
                TrajectoryBeam:Destroy()
                TrajectoryAttachment0:Destroy()
                TrajectoryAttachment1:Destroy()
                TrajectoryEndPart:Destroy()
                TrajectoryBeam = nil
                TrajectoryAttachment0 = nil
                TrajectoryAttachment1 = nil
                TrajectoryEndPart = nil
            end
            return
        end
        
        local desiredHeight
        if CurrentThrowType == "Bullet" then
            desiredHeight = ((horizontalDistance ^ 2) * 0.0001) + ((horizontalDistance * 0.0001) / 3) + ((horizontalDistance / 13)) - 0.75
        else
            desiredHeight = ((horizontalDistance ^ 2) * 0.0013) + ((horizontalDistance * 0.0013) / 2) + ((horizontalDistance / 10) + 1) + 2
        end
        
        local flightTime = (function()
            local xMeters = desiredHeight * 4
            local a, b, c = 0.5 * gravity.Y, targetPosition.Y - startPosition.Y, xMeters - startPosition.Y
            local discriminant = b * b - 4 * a * c
            return discriminant >= 0 and math.max((-b + math.sqrt(discriminant)) / (2 * a), (-b - math.sqrt(discriminant)) / (2 * a)) or 0.1
        end)()
        
        local targetPos = CurrentTarget.HumanoidRootPart.Position + horizontalVelocity * flightTime + moveDirection * leadDistance + Vector3.new(0, 5, 0)
        
        local velocity
        if CustomAngleEnabled then
            velocity = CalculateVelocityFromAngle(startPosition, targetPos, gravity, CustomAngleValue)
            if not velocity then
                velocity = (targetPos - startPosition - 0.5 * gravity * flightTime * flightTime) / flightTime
            end
        else
            if CurrentThrowType == "Bullet" then
                velocity = CalculateVelocityFromAngle(startPosition, targetPos, gravity, 15)
                if not velocity then
                    velocity = (targetPos - startPosition - 0.5 * gravity * flightTime * flightTime) / flightTime
                end
            else
                velocity = (targetPos - startPosition - 0.5 * gravity * flightTime * flightTime) / flightTime
            end
        end
        
        local power = math.round(velocity.Y / ((startPosition + velocity) - startPosition).Unit.Y)
        power = math.clamp(power, 0, 95)
        
        if CustomAngleEnabled then
            ThrowData.angle = CustomAngleValue
        else
            local horizontalComponent = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
            local verticalComponent = velocity.Y
            if horizontalComponent > 0 then
                ThrowData.angle = math.deg(math.atan(verticalComponent / horizontalComponent))
            else
                ThrowData.angle = 90
            end
        end
        
        ThrowData.direction = ((startPosition + velocity) - startPosition).Unit
        ThrowData.power = power
        
        -- Update QBA data
        QBA.data.Direction = ThrowData.direction
        QBA.data.Power = math.round(math.clamp(power, 1, 95))
        
        TargetHighlight.Parent = CurrentTarget
        
        -- Update UI
        UpdateUIDisplay(CurrentThrowType, power, CurrentTarget.Name, flightTime, ThrowData.angle, false)
        
        -- Trajectory visualization
            
        if TrajectoryEnabled and QBA.enabled and Utilities.HasFootball() then
            if not TrajectoryBeam then
                TrajectoryBeam = Instance.new("Beam")
                TrajectoryAttachment0 = Instance.new("Attachment")
                TrajectoryAttachment1 = Instance.new("Attachment")
                TrajectoryBeam.Color = ColorSequence.new(TrajectoryColor)
                TrajectoryBeam.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(0.7, 0),
                    NumberSequenceKeypoint.new(1, 0.9)
                })
                TrajectoryBeam.Name = "Trajectory"
                TrajectoryBeam.Parent = Workspace.Terrain
                TrajectoryBeam.Segments = 1750
                TrajectoryAttachment0.Parent = Workspace.Terrain
                TrajectoryAttachment1.Parent = Workspace.Terrain
                TrajectoryBeam.Attachment0 = TrajectoryAttachment0
                TrajectoryBeam.Attachment1 = TrajectoryAttachment1
                TrajectoryBeam.Width0 = 0.8
                TrajectoryBeam.Width1 = 0.8
                
                TrajectoryEndPart = Instance.new("Part")
                TrajectoryEndPart.Shape = Enum.PartType.Ball
                TrajectoryEndPart.Size = Vector3.new(4, 4, 4)
                TrajectoryEndPart.Anchored = true
                TrajectoryEndPart.CanCollide = false
                TrajectoryEndPart.Transparency = 0.5
                TrajectoryEndPart.Material = Enum.Material.ForceField
                TrajectoryEndPart.Color = TrajectoryColor
                TrajectoryEndPart.Parent = Workspace.Terrain
            end
            
            -- Re-enable beam if it was hidden
            TrajectoryBeam.Enabled = true
            MainFrame.Visible = true
            MobileButtonsFrame.Visible = QBA.mobileEnabled
            if TrajectoryEndPart then
                TrajectoryEndPart.Transparency = 0.5
            end
            
            local c0, c1, cf1, cf2 = Utilities.BeamProjectile(gravity, velocity, startPosition, flightTime)
            TrajectoryBeam.CurveSize0 = c0
            TrajectoryBeam.CurveSize1 = c1
            TrajectoryAttachment0.CFrame = TrajectoryAttachment0.Parent.CFrame:Inverse() * cf1
            TrajectoryAttachment1.CFrame = TrajectoryAttachment1.Parent.CFrame:Inverse() * cf2
            TrajectoryEndPart.Position = cf2.Position
        elseif not TrajectoryEnabled and TrajectoryBeam then
            TrajectoryBeam:Destroy()
            TrajectoryAttachment0:Destroy()
            TrajectoryAttachment1:Destroy()
            TrajectoryEndPart:Destroy()
            TrajectoryBeam = nil
            TrajectoryAttachment0 = nil
            TrajectoryAttachment1 = nil
            TrajectoryEndPart = nil
        end
    else
        TargetHighlight.Parent = nil
        -- Don't destroy trajectory beam when not aiming, just hide it
        if TrajectoryBeam then
            TrajectoryBeam.Enabled = false
            if TrajectoryEndPart then
                TrajectoryEndPart.Transparency = 1
            end
        end
    end
end)

local character = LocalPlayer.Character
local Head = character:FindFirstChild("Head") 

local __namecall
__namecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method, args = getnamecallmethod(), {...}
    if args[1] == "Clicked" and QBA.enabled then
        -- Place ID check: Only allow throwing during "HIKE" in specific game
        if game.PlaceId == 8204899140 then
            local success, messageText = pcall(function()
                return LocalPlayer.PlayerGui.MainGui.Message.Text
            end)
            if not success or messageText ~= "HIKE" then
                print("⚠️ Cannot throw - waiting for HIKE!")
                return __namecall(self, ...)
            end
        end
        
        return __namecall(self, "Clicked", character.Head.Position + QBA.data.Direction * 1.5, character.Head.Position + QBA.data.Direction * 10000, QBA.data.Power, 1)
    end
    return __namecall(self, ...)
end)

-- ============================================
-- INPUT HANDLING
-- ============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Z key - Switch throw mode
    if input.KeyCode == Enum.KeyCode.Z then
        CurrentThrowType = ThrowTypeMap[CurrentThrowType]
        SwitchModeText.Text = CurrentThrowType
    end
    
    -- Q key - Lock/unlock target
    if input.KeyCode == Enum.KeyCode.Q then
        if QBA.enabled and Utilities.HasFootball() then
            IsTargetLocked = not IsTargetLocked
            if IsTargetLocked then
                LockedTarget = CurrentTarget
                LockButtonText.Text = "Locked"
            else
                LockedTarget = nil
                LockButtonText.Text = "Unlocked"
            end
        end
    end
    
    -- R key - Increase angle
    if input.KeyCode == Enum.KeyCode.R then
        if CustomAngleEnabled then
            CustomAngleValue = math.min(CustomAngleValue + 5, 55)
        end
    end
    
    -- F key - Decrease angle
    if input.KeyCode == Enum.KeyCode.F then
        if CustomAngleEnabled then
            CustomAngleValue = math.max(CustomAngleValue - 5, 15)
        end
    end
    
    -- Gamepad controls
    if input.UserInputType == Enum.UserInputType.Gamepad1 then
        if input.KeyCode == Enum.KeyCode.Thumbstick1 then
            if QBA.enabled and Utilities.HasFootball() then
                IsTargetLocked = not IsTargetLocked
                if IsTargetLocked then
                    LockedTarget = CurrentTarget
                    LockButtonText.Text = "Locked"
                else
                    LockedTarget = nil
                    LockButtonText.Text = "Unlocked"
                end
            end
        elseif input.KeyCode == Enum.KeyCode.DPadDown then
            if QBA.enabled and Utilities.HasFootball() then
                CurrentThrowType = ThrowTypeMap[CurrentThrowType]
                SwitchModeText.Text = CurrentThrowType
            end
        end
    end
end)

local SKY_ASSETS = {Gray = 518952078, Sunset = 32584709, Night = 741300412, Thunder = 20498477, Nova = 19587080}
local PRESET_LIGHTING = {
    Gray = {Ambient = Color3.fromRGB(140, 140, 140), OutdoorAmbient = Color3.fromRGB(140, 140, 140), Brightness = 2, FogColor = Color3.fromRGB(140, 140, 140), FogStart = 0, FogEnd = 100000}, 
    Sunset = {Ambient = Color3.fromRGB(255, 200, 160), OutdoorAmbient = Color3.fromRGB(255, 190, 140), Brightness = 2, ClockTime = 18.2, FogColor = Color3.fromRGB(255, 170, 120), FogStart = 0, FogEnd = 100000}, 
    Night = {Ambient = Color3.fromRGB(25, 25, 45), OutdoorAmbient = Color3.fromRGB(20, 20, 35), Brightness = 1.6, ClockTime = 0.5, FogColor = Color3.fromRGB(15, 15, 25), FogStart = 0, FogEnd = 100000}, 
    Thunder = {Ambient = Color3.fromRGB(70, 70, 90), OutdoorAmbient = Color3.fromRGB(60, 60, 80), Brightness = 2, ClockTime = 16.5, FogColor = Color3.fromRGB(80, 80, 95), FogStart = 0, FogEnd = 100000}, 
    Nova = {Ambient = Color3.fromRGB(90, 40, 140), OutdoorAmbient = Color3.fromRGB(90, 40, 140), Brightness = 2, ClockTime = 20.0, FogColor = Color3.fromRGB(60, 20, 90), FogStart = 0, FogEnd = 100000}
}

local function getHumanoidRootPart() 
    local character = LocalPlayer.Character 
    return character and character:FindFirstChild("HumanoidRootPart") 
end

local function findCatchPart(char) 
    if not char then return nil end 
    local found = char:FindFirstChild("CatchRight", true) 
    if found then 
        if found:IsA("BasePart") then 
            return found 
        elseif found:IsA("Attachment") and found.Parent and found.Parent:IsA("BasePart") then 
            return found.Parent 
        end 
    end 
    return nil 
end

local function isGrounded(hum) 
    return hum and hum.FloorMaterial ~= Enum.Material.Air 
end

local function lerpNumber(a, b, t) 
    return a + (b - a) * t 
end

local function lerpColor(a, b, t) 
    return a:Lerp(b, t) 
end

PlayerMods.Humanoid = PlayerMods.Character:WaitForChild("Humanoid")
PlayerMods.RootPart = PlayerMods.Character:WaitForChild("HumanoidRootPart")
PlayerMods.Humanoid.JumpPower = PlayerMods.JUMP_POWER

local function setupNoJumpCooldown(char)
    local hum = char:WaitForChild("Humanoid")
    local conn
    conn = RunService.Stepped:Connect(function()
        if PlayerMods.NoJumpCooldown then 
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) 
        end
    end)
    char.AncestryChanged:Connect(function() 
        if not char.Parent and conn then 
            conn:Disconnect() 
        end 
    end)
end

if LocalPlayer.Character then 
    setupNoJumpCooldown(LocalPlayer.Character) 
end

LocalPlayer.CharacterAdded:Connect(function(char)
    PlayerMods.Character = char
    PlayerMods.Humanoid = char:WaitForChild("Humanoid")
    PlayerMods.RootPart = char:WaitForChild("HumanoidRootPart")
    PlayerMods.Humanoid.JumpPower = PlayerMods.JUMP_POWER
    setupNoJumpCooldown(char)
    FreezeController.character = char
    FreezeController.humanoid = char:WaitForChild("Humanoid")
    FreezeController.rootPart = char:WaitForChild("HumanoidRootPart")
end)

RunService.Stepped:Connect(function()
    if not Misc.AntiBlock then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then 
            part.CanCollide = false 
        end
    end
end)

local function updateHitboxAppearance()
    HitboxPart.Transparency = Config.Hitbox.Enabled and Config.Hitbox.Transparency or 1
    if Config.Hitbox.Shape == "Box" then 
        HitboxPart.Shape = Enum.PartType.Block 
        HitboxPart.Material = Enum.Material.SmoothPlastic
    elseif Config.Hitbox.Shape == "Neon" then 
        HitboxPart.Shape = Enum.PartType.Ball 
        HitboxPart.Material = Enum.Material.Neon
    else 
        HitboxPart.Shape = Enum.PartType.Ball 
        HitboxPart.Material = Enum.Material.ForceField 
    end
    if not Config.Hitbox.Rainbow then 
        HitboxPart.Color = Config.Hitbox.Color 
    end
end

local function findClosestFootball(hrp)
    if not hrp then return nil, math.huge end
    local closest, minDist = nil, math.huge
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") and obj.Name == "Football" and obj.Parent and not obj.Anchored and obj.Velocity.Magnitude > 0.1 then
            local distance = (hrp.Position - obj.Position).Magnitude
            if distance < minDist then 
                closest, minDist = obj, distance 
            end
        end
    end
    return closest, minDist
end

local function triggerTouch(ball, limb, delay)
    if not (ball and limb and ball.Parent) then return end
    pcall(function()
        firetouchinterest(ball, limb, 0)
        if delay and delay > 0 then task.wait(delay) end
        if ball and ball.Parent then 
            firetouchinterest(ball, limb, 1) 
        end
    end)
end

local function handleNormalMagnet(ball, character, now)
    local lastTime = ball:GetAttribute("LastTouch") or 0
    if now - lastTime <= 0.15 + Config.Magnet.Delay then return end
    ball:SetAttribute("LastTouch", now)
    
    local catchRight = character:FindFirstChild("CatchR") or character:FindFirstChild("CatchRight")
    local catchLeft = character:FindFirstChild("CatchL") or character:FindFirstChild("CatchLeft")
    
    task.spawn(function()
        local delay = 0.01 + Config.Magnet.Delay
        if catchRight then triggerTouch(ball, catchRight, delay) end
        if catchLeft then triggerTouch(ball, catchLeft, delay) end
    end)
end

local function handleLegitMagnet(ball, character, now)
    local lastTime = ball:GetAttribute("LastLegit") or 0
    if now - lastTime <= 0.25 + Config.Magnet.Delay then return end
    ball:SetAttribute("LastLegit", now)
    
    pcall(function()
        if not ball or not ball.Parent then return end
        local originalSize = ball.Size
        local expandMultiplier = 3 + (Config.Magnet.ForceMultiplier * 2)
        local newSize = originalSize * expandMultiplier
        ball.Size = newSize
        
        task.spawn(function()
            local catchRight = character:FindFirstChild("CatchRight") or character:FindFirstChild("CatchR")
            local catchLeft = character:FindFirstChild("CatchLeft") or character:FindFirstChild("CatchL")
            if catchRight then triggerTouch(ball, catchRight, 0) end
            if catchLeft then triggerTouch(ball, catchLeft, 0) end
        end)
        
        task.delay(0.1, function() 
            if ball and ball.Parent then 
                pcall(function() ball.Size = originalSize end) 
            end 
        end)
    end)
end

local function handleLeagueMagnet(ball, hrp, now)
    local lastTime = ball:GetAttribute("LastTween") or 0
    if now - lastTime <= 0.15 + Config.Magnet.Delay then return end
    ball:SetAttribute("LastTween", now)
    
    if activeTweens[ball] then activeTweens[ball]:Cancel() end
    
    pcall(function()
        local targetPos = hrp.Position + Vector3.new(0, 1, 0)
        local speed = math.max(0.3, Config.Magnet.ForceMultiplier)
        local duration = 0.05 * speed
        local tween = TweenService:Create(ball, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos})
        activeTweens[ball] = tween
        tween.Completed:Connect(function() activeTweens[ball] = nil end)
        tween:Play()
    end)
end

local function handleBlatantMagnet(ball, character, now)
    local lastTime = ball:GetAttribute("LastBlatant") or 0
    if now - lastTime <= 0.03 + Config.Magnet.Delay then return end
    ball:SetAttribute("LastBlatant", now)
    
    local catchRight = character:FindFirstChild("CatchRight") or character:FindFirstChild("CatchR")
    local catchLeft = character:FindFirstChild("CatchLeft") or character:FindFirstChild("CatchL")
    
    if catchRight then 
        triggerTouch(ball, catchRight, 0) 
        triggerTouch(ball, catchRight, 0) 
    end
    if catchLeft then 
        triggerTouch(ball, catchLeft, 0) 
        triggerTouch(ball, catchLeft, 0) 
    end
end

FreezeController.character = LocalPlayer.Character
FreezeController.humanoid = FreezeController.character:WaitForChild("Humanoid")
FreezeController.rootPart = FreezeController.character:WaitForChild("HumanoidRootPart")

function FreezeController.Freeze()
    if not FreezeController.humanoid or not FreezeController.rootPart then return end
    FreezeController.originalPlatformStand = FreezeController.humanoid.PlatformStand
    FreezeController.humanoid.PlatformStand = true
    FreezeController.rootPart.Anchored = true
    FreezeController.frozen = true
end

function FreezeController.Unfreeze()
    if not FreezeController.humanoid or not FreezeController.rootPart then return end
    FreezeController.humanoid.PlatformStand = FreezeController.originalPlatformStand
    FreezeController.rootPart.Anchored = false
    FreezeController.frozen = false
    FreezeController.autoUnfreezeAt = nil
end

function FreezeController.ToggleFreeze() 
    if FreezeController.frozen then 
        FreezeController.Unfreeze() 
    else 
        FreezeController.Freeze() 
    end 
end

local function startAutoTimer()
    local dur = FreezeController.autoFreezeDuration
    if not dur or dur <= 0 then dur = 0.1 end
    FreezeController.autoUnfreezeAt = os.clock() + dur
end

local function isFootballTool(inst) 
    return inst and inst:IsA("Tool") and inst.Name == "Football" 
end

local function tryAfterCatch(inst)
    if not FreezeController.autoFreezeEnabled then return end
    if FreezeController.autoFreezeMode ~= "After Catch" then return end
    if not isFootballTool(inst) then return end
    
    local now = os.clock()
    if now - FreezeController.lastCatch < FreezeController.CATCH_DEBOUNCE then return end
    FreezeController.lastCatch = now
    FreezeController.Freeze()
    startAutoTimer()
end

local function hookBackpack()
    local backpack = LocalPlayer:WaitForChild("Backpack")
    backpack.ChildAdded:Connect(tryAfterCatch)
    for _, tool in ipairs(backpack:GetChildren()) do 
        if isFootballTool(tool) then 
            tryAfterCatch(tool) 
        end 
    end
end

local function hookCharacter()
    if not FreezeController.character then return end
    FreezeController.character.ChildAdded:Connect(tryAfterCatch)
    for _, tool in ipairs(FreezeController.character:GetChildren()) do 
        if isFootballTool(tool) then 
            tryAfterCatch(tool) 
        end 
    end
end

hookBackpack()
hookCharacter()

local function isAirborne()
    if not FreezeController.humanoid then return false end
    local st = FreezeController.humanoid:GetState()
    return st == Enum.HumanoidStateType.Jumping or st == Enum.HumanoidStateType.Freefall
end

local function findClosestFootballPV(maxDist)
    local character = LocalPlayer.Character
    if not character then return nil end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local closest, best = nil, maxDist or math.huge
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") and not obj.Anchored and obj.Name:lower():match("football") then
            local d = (hrp.Position - obj.Position).Magnitude
            if d < best then 
                best = d 
                closest = obj 
            end
        end
    end
    return closest, best
end

local function startPullVector()
    if PullVector.connection then return end
    PullVector.connection = RunService.Heartbeat:Connect(function(dt)
        if not PullVector.enabled then return end
        local character = LocalPlayer.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local ball, dist = findClosestFootballPV(PullVector.distance)
        if not ball or not dist then return end
        
        local dir = (ball.Position - hrp.Position)
        if dir.Magnitude < 0.1 then return end
        dir = dir.Unit
        
        local pullStudsPerSec = 25 * PullVector.power
        local step = dir * pullStudsPerSec * dt
        hrp.CFrame = hrp.CFrame + step
    end)
end

local function stopPullVector() 
    if PullVector.connection then 
        PullVector.connection:Disconnect() 
        PullVector.connection = nil 
    end 
end

local function getClosestFootballAK()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local closest, dist = nil, math.huge
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("football") then
            local d = (obj.Position - hrp.Position).Magnitude
            if d < dist then 
                closest, dist = obj, d 
            end
        end
    end
    return closest
end

local function walkToBall()
    if not AutoKick.WalkToBall then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end
    
    local ball = getClosestFootballAK()
    if not ball then return end
    
    local toBall = ball.Position - hrp.Position
    local flat = Vector3.new(toBall.X, 0, toBall.Z)
    if flat.Magnitude < 1 then return end
    
    local forward = Vector3.new(hrp.CFrame.LookVector.X, 0, hrp.CFrame.LookVector.Z).Unit
    local cross = forward.X * flat.Z - forward.Z * flat.X
    local angleSign = math.sign(cross)
    local correction = (math.rad(30) * angleSign) - math.rad(45)
    local adjustedDir = (CFrame.Angles(0, correction, 0):VectorToWorldSpace(forward)).Unit
    local targetPos = hrp.Position + adjustedDir * flat.Magnitude
    hum:MoveTo(targetPos)
end

local function click()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

local function handleKicker()
    if not AutoKick.Enabled then return end
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return end
    local kickerGui = gui:FindFirstChild("KickerGui", true)
    if not kickerGui then return end
    local cursor = kickerGui:FindFirstChild("Cursor", true)
    if not cursor then return end
    
    if AutoKick.WalkToBall then walkToBall() end
    
    local power = AutoKick.Randomize and math.random(90, 100) or AutoKick.KickPower
    while AutoKick.Enabled and cursor.Position.Y.Scale > (0.01 + ((100 - power) * 0.012)) do 
        RunService.Heartbeat:Wait() 
    end
    click()
    
    while AutoKick.Enabled and cursor.Position.Y.Scale < (0.9 - ((100 - AutoKick.KickAccuracy) * 0.001)) do 
        RunService.Heartbeat:Wait() 
    end
    click()
end

task.spawn(function() 
    while true do 
        if AutoKick.Enabled then 
            handleKicker() 
        end 
        task.wait(0.5) 
    end 
end)

LocalPlayer:WaitForChild("PlayerGui").ChildAdded:Connect(function(child) 
    if child.Name == "KickerGui" then 
        task.delay(0.2, handleKicker) 
    end 
end)

local function hasFootball(char) 
    for _, v in ipairs(char:GetChildren()) do 
        if v:IsA("Tool") and v.Name == "Football" then 
            return true 
        end 
    end 
    return false 
end

local function getTargetHRP()
    local closest, shortest = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and hasFootball(plr.Character) then
            local hrp = plr.Character.HumanoidRootPart
            local dist = (PlayerMods.RootPart.Position - hrp.Position).Magnitude
            if dist < shortest then 
                shortest = dist 
                closest = hrp 
            end
        end
    end
    return closest
end

Skybox.Original = {
    Ambient = Lighting.Ambient, 
    OutdoorAmbient = Lighting.OutdoorAmbient, 
    Brightness = Lighting.Brightness, 
    ClockTime = Lighting.ClockTime, 
    FogColor = Lighting.FogColor, 
    FogStart = Lighting.FogStart, 
    FogEnd = Lighting.FogEnd
}

local function snapshotSky(skyObj) 
    return {
        SkyboxBk = skyObj.SkyboxBk, 
        SkyboxDn = skyObj.SkyboxDn, 
        SkyboxFt = skyObj.SkyboxFt, 
        SkyboxLf = skyObj.SkyboxLf, 
        SkyboxRt = skyObj.SkyboxRt, 
        SkyboxUp = skyObj.SkyboxUp, 
        SunTextureId = skyObj.SunTextureId, 
        SunAngularSize = skyObj.SunAngularSize, 
        MoonTextureId = skyObj.MoonTextureId, 
        MoonAngularSize = skyObj.MoonAngularSize, 
        StarCount = skyObj.StarCount, 
        CelestialBodiesShown = skyObj.CelestialBodiesShown
    } 
end

local skyInstance = Lighting:FindFirstChildOfClass("Sky")
if skyInstance then 
    Skybox.originalSkySnap = snapshotSky(skyInstance) 
end

local function getOrCreateSky() 
    local skyObj = Lighting:FindFirstChildOfClass("Sky") 
    if not skyObj then 
        skyObj = Instance.new("Sky") 
        skyObj.Name = "ClientSky" 
        skyObj.Parent = Lighting 
    end 
    return skyObj 
end

local function applySkyFromAssetId(assetId)
    local ok, objs = pcall(function() 
        return game:GetObjects(("rbxassetid://%d"):format(assetId)) 
    end)
    if not ok or not objs or not objs[1] then return false end
    
    local foundSky = nil
    for _, root in ipairs(objs) do 
        if root:IsA("Sky") then 
            foundSky = root 
            break 
        end 
        local s = root:FindFirstChildOfClass("Sky") 
        if s then 
            foundSky = s 
            break 
        end 
    end
    
    if not foundSky then return false end
    
    local skyObj = getOrCreateSky()
    skyObj.SkyboxBk = foundSky.SkyboxBk 
    skyObj.SkyboxDn = foundSky.SkyboxDn 
    skyObj.SkyboxFt = foundSky.SkyboxFt 
    skyObj.SkyboxLf = foundSky.SkyboxLf 
    skyObj.SkyboxRt = foundSky.SkyboxRt 
    skyObj.SkyboxUp = foundSky.SkyboxUp 
    skyObj.SunTextureId = foundSky.SunTextureId 
    skyObj.SunAngularSize = foundSky.SunAngularSize 
    skyObj.MoonTextureId = foundSky.MoonTextureId 
    skyObj.MoonAngularSize = foundSky.MoonAngularSize 
    skyObj.StarCount = foundSky.StarCount 
    skyObj.CelestialBodiesShown = foundSky.CelestialBodiesShown
    
    for _, root in ipairs(objs) do 
        root:Destroy() 
    end
    return true
end

local function applyLightingWithIntensity(presetName, t)
    local p = PRESET_LIGHTING[presetName]
    if not p then return end
    t = math.clamp(t, 0, 1)
    
    Lighting.Ambient = lerpColor(Skybox.Original.Ambient, p.Ambient or Skybox.Original.Ambient, t)
    Lighting.OutdoorAmbient = lerpColor(Skybox.Original.OutdoorAmbient, p.OutdoorAmbient or Skybox.Original.OutdoorAmbient, t)
    Lighting.Brightness = lerpNumber(Skybox.Original.Brightness, p.Brightness or Skybox.Original.Brightness, t)
    Lighting.ClockTime = lerpNumber(Skybox.Original.ClockTime, p.ClockTime or Skybox.Original.ClockTime, t)
    Lighting.FogColor = lerpColor(Skybox.Original.FogColor, p.FogColor or Skybox.Original.FogColor, t)
    Lighting.FogStart = lerpNumber(Skybox.Original.FogStart, p.FogStart or Skybox.Original.FogStart, t)
    Lighting.FogEnd = lerpNumber(Skybox.Original.FogEnd, p.FogEnd or Skybox.Original.FogEnd, t)
end

local function restoreOriginalEverything()
    for k, v in pairs(Skybox.Original) do 
        Lighting[k] = v 
    end
    
    local skyObj = Lighting:FindFirstChildOfClass("Sky")
    if skyObj and Skybox.originalSkySnap then 
        for k, v in pairs(Skybox.originalSkySnap) do 
            skyObj[k] = v 
        end
    elseif skyObj and skyObj.Name == "ClientSky" then 
        skyObj:Destroy() 
    end
end

local function applySkyboxCurrent() 
    if not Skybox.enabled then return end 
    local assetId = SKY_ASSETS[Skybox.selected] 
    if assetId then 
        applySkyFromAssetId(assetId) 
    end 
    applyLightingWithIntensity(Skybox.selected, Skybox.intensity) 
end

local function teleportForward() 
    if not Misc.tpEnabled then return end 
    local hrp = getHumanoidRootPart() 
    if not hrp then return end 
    local forward = hrp.CFrame.LookVector 
    local newPos = hrp.Position + (forward * Misc.tpDistance) 
    hrp.CFrame = CFrame.new(newPos, newPos + forward) 
end

local function stepTeleport(targetPos)
    local player = Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    
    hum:ChangeState(Enum.HumanoidStateType.Physics)
    hum.AutoRotate = false
    
    local function stepAxis(get, set, goal, increment)
        while math.abs(get() - goal) > increment do
            local current = get()
            local dir = (goal > current) and increment or -increment
            set(current + dir)
            task.wait(0.15)
        end
    end
    
    stepAxis(function() return hrp.Position.X end, function(v) hrp.CFrame = CFrame.new(v, hrp.Position.Y, hrp.Position.Z) end, targetPos.X, 8)
    stepAxis(function() return hrp.Position.Z end, function(v) hrp.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y, v) end, targetPos.Z, 8)
    stepAxis(function() return hrp.Position.Y end, function(v) hrp.CFrame = CFrame.new(hrp.Position.X, v, hrp.Position.Z) end, targetPos.Y, 1)
    
    hrp.CFrame = CFrame.new(targetPos)
    hum:ChangeState(Enum.HumanoidStateType.Running)
    hum.AutoRotate = true
end

local function applyFpsCap() 
    if typeof(setfpscap) ~= "function" then return end 
    if Misc.fpsCapEnabled then 
        setfpscap(math.floor(Misc.fpsCapValue)) 
    else 
        setfpscap(0) 
    end 
end

local originalMaterials = {}
local connections = {}

local function isRenderable(inst) 
    return inst:IsA("BasePart") 
end

local function setSmooth(inst) 
    if not originalMaterials[inst] then 
        originalMaterials[inst] = inst.Material 
    end 
    inst.Material = Enum.Material.SmoothPlastic 
end

local function restore(inst) 
    local mat = originalMaterials[inst] 
    if mat then 
        inst.Material = mat 
    end 
end

function applyNoTextures(enabled)
    if enabled then
        for _, inst in ipairs(Workspace:GetDescendants()) do 
            if isRenderable(inst) then 
                setSmooth(inst) 
            end 
        end
        connections.desc = Workspace.DescendantAdded:Connect(function(inst) 
            if isRenderable(inst) then 
                setSmooth(inst) 
            end 
        end)
    else
        for inst, _ in pairs(originalMaterials) do 
            if inst and inst.Parent then 
                restore(inst) 
            end 
        end
        originalMaterials = {}
        if connections.desc then 
            connections.desc:Disconnect() 
            connections.desc = nil 
        end
    end
end

local modelsFolder = Workspace:WaitForChild("Models")
local stadium = modelsFolder:WaitForChild("Stadium")

local function applyStadiumHidden(v) 
    for _, obj in ipairs(stadium:GetDescendants()) do 
        if obj:IsA("BasePart") then 
            obj.Transparency = v and 1 or 0 
            obj.CanCollide = not v 
        end 
    end 
end

local function stopBoost() 
    if Misc.boostConn then 
        Misc.boostConn:Disconnect() 
        Misc.boostConn = nil 
    end 
end

local function jpToExtraY(jp) 
    local t = math.clamp((jp - 50) / 20, 0, 1) 
    return 10 * t 
end

local function hookCharacterAE(character)
    local humanoid = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    humanoid.Jumping:Connect(function()
        if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then return end
        if (os.clock() - Misc.angleTick) > 0.2 then return end
        if not Misc.boostEnabled then return end
        
        local extraY = jpToExtraY(Misc.maxJP)
        if extraY <= 0 then return end
        
        task.wait(0.05)
        if not hrp or not hrp.Parent then return end
        hrp.AssemblyLinearVelocity += Vector3.new(0, extraY, 0)
        
        stopBoost()
        Misc.boostToken += 1
        local my = Misc.boostToken
        local t0 = os.clock()
        
        Misc.boostConn = RunService.Heartbeat:Connect(function()
            if my ~= Misc.boostToken or not Misc.boostEnabled or not hrp or not hrp.Parent then 
                stopBoost() 
                return 
            end
            if (os.clock() - t0) >= Misc.boostDuration then 
                stopBoost() 
                return 
            end
            hrp.AssemblyLinearVelocity += Vector3.new(0, extraY * 0.12, 0)
        end)
    end)
end

if LocalPlayer.Character then 
    task.spawn(function() 
        hookCharacterAE(LocalPlayer.Character) 
    end) 
end

LocalPlayer.CharacterAdded:Connect(hookCharacterAE)

UserInputService:GetPropertyChangedSignal("MouseBehavior"):Connect(function() 
    Misc.shiftLockEnabled = (UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter) 
end)

task.spawn(function() 
    while true do 
        task.wait() 
        if not Misc.shiftLockEnabled and Misc.lastEnabled then 
            Misc.angleTick = os.clock() 
        end 
        Misc.lastEnabled = Misc.shiftLockEnabled 
    end 
end)

RunService.Heartbeat:Connect(function(deltaTime)
    rainbowTick = rainbowTick + deltaTime
    rotationDeg = (rotationDeg + Config.Hitbox.RotationSpeed) % 360
    scanTick = scanTick + deltaTime
    
    local hrp = getHumanoidRootPart()
    local character = LocalPlayer.Character
    
    if hrp and scanTick >= 0.10 then 
        scanTick = 0 
        closestBall, closestDist = findClosestFootball(hrp) 
    end
    
    if Config.Hitbox.Rainbow and rainbowTick >= Config.Hitbox.RainbowSpeed then 
        rainbowTick = 0 
        hue = (hue + Config.Hitbox.RainbowIncrement) % 1 
        HitboxPart.Color = Color3.fromHSV(hue, Config.Hitbox.RainbowSaturation, Config.Hitbox.RainbowValue)
    elseif not Config.Hitbox.Rainbow and HitboxPart.Color ~= Config.Hitbox.Color then 
        HitboxPart.Color = Config.Hitbox.Color 
    end
    
    if Config.Hitbox.Enabled and closestBall then
        local radius = Config.Hitbox.Radius
        HitboxPart.Size = Vector3.new(radius, radius, radius)
        local rotationCFrame = CFrame.Angles(0, math.rad(rotationDeg), 0)
        HitboxPart.CFrame = closestBall.CFrame * rotationCFrame
        HitboxPart.Transparency = Config.Hitbox.Transparency
    else 
        HitboxPart.Transparency = 1 
    end
    
    if Config.Magnet.Enabled and hrp and closestBall and character then
        local reach = Config.Hitbox.Radius * math.max(1, Config.Magnet.ForceMultiplier)
        if closestDist <= reach then
            local now = tick()
            if Config.Magnet.Type == "Normal" then 
                handleNormalMagnet(closestBall, character, now)
            elseif Config.Magnet.Type == "Legit" then 
                handleLegitMagnet(closestBall, character, now)
            elseif Config.Magnet.Type == "League" then 
                handleLeagueMagnet(closestBall, hrp, now)
            elseif Config.Magnet.Type == "Blatant" then 
                handleBlatantMagnet(closestBall, character, now) 
            end
        end
    end
    
    if FreezeController.frozen and FreezeController.autoUnfreezeAt and os.clock() >= FreezeController.autoUnfreezeAt then 
        FreezeController.Unfreeze() 
    end
    
    if FreezeController.autoFreezeEnabled and FreezeController.autoFreezeMode == "Zenith of Jump" then
        if not FreezeController.humanoid or not FreezeController.rootPart then return end
        
        local airborne = isAirborne()
        local y = FreezeController.rootPart.Position.Y
        local vy = FreezeController.rootPart.AssemblyLinearVelocity.Y
        
        if airborne and not FreezeController.inAir then 
            FreezeController.inAir = true 
            FreezeController.apexFired = false 
            FreezeController.jumpArmed = false 
            FreezeController.peakY = y 
            FreezeController.jumpStart = os.clock()
        elseif not airborne and FreezeController.inAir then 
            FreezeController.inAir = false 
        end
        
        if not FreezeController.inAir or FreezeController.apexFired then return end
        
        if vy > FreezeController.ARM_VY then 
            FreezeController.jumpArmed = true 
        end
        
        if y > FreezeController.peakY then 
            FreezeController.peakY = y 
        end
        
        if os.clock() - FreezeController.jumpStart < FreezeController.MIN_AIR_TIME then return end
        
        if not FreezeController.jumpArmed then return end
        
        if vy <= FreezeController.APEX_VY or (FreezeController.peakY - y) >= FreezeController.DESCEND_EPS then 
            FreezeController.apexFired = true 
            FreezeController.Freeze() 
            startAutoTimer() 
        end
    end
    
    if AutoRush.enabled then
        if PlayerMods.Humanoid and PlayerMods.Humanoid.Health > 0 then
            local targetHRP = getTargetHRP()
            if targetHRP then
                local predictedPosition = targetHRP.Position + (targetHRP.AssemblyLinearVelocity * AutoRush.predictionDelay)
                PlayerMods.Humanoid:MoveTo(predictedPosition)
            end
        end
    end
end)

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local eventConnection

local function beamProjectile(g, v0, x0, t1)
	local c = 0.125
	local p3 = 0.5 * g * t1 * t1 + v0 * t1 + x0
	local p2 = p3 - (g * t1 * t1 + v0 * t1) / 3
	local p1 = (c * g * t1 * t1 + 0.5 * v0 * t1 + x0 - c * (x0 + p3)) / (3 * c) - p2

	local curve0 = (p1 - x0).Magnitude
	local curve1 = (p2 - p3).Magnitude

	local b = (x0 - p3).Unit
	local r1 = (p1 - x0).Unit
	local u1 = r1:Cross(b).Unit

	local r2 = (p2 - p3).Unit
	local u2 = r2:Cross(b).Unit

	b = u1:Cross(r1).Unit

	local cf1 = CFrame.new(
		x0.X, x0.Y, x0.Z,
		r1.X, u1.X, b.X,
		r1.Y, u1.Y, b.Y,
		r1.Z, u1.Z, b.Z
	)

	local cf2 = CFrame.new(
		p3.X, p3.Y, p3.Z,
		r2.X, u2.X, b.X,
		r2.Y, u2.Y, b.Y,
		r2.Z, u2.Z, b.Z
	)

	return curve0, -curve1, cf1, cf2
end

local function createPrediction(ball)
	if not ball:IsA("BasePart") then return end

	task.wait()

	local velocity = ball.Velocity
	local position = ball.Position

	local c0, c1, cf1, cf2 = beamProjectile(
		Vector3.new(0, -28, 0),
		velocity,
		position,
		Config.PredictTime
	)

	local att0 = Instance.new("Attachment")
	local att1 = Instance.new("Attachment")

	att0.Parent = Workspace.Terrain
	att1.Parent = Workspace.Terrain
	att0.CFrame = cf1
	att1.CFrame = cf2

	local beam = Instance.new("Beam")
	beam.Name = "BallPrediction"
	beam.Color = ColorSequence.new(Config.PredictionColor)
	beam.Transparency = NumberSequence.new(0)
	beam.CurveSize0 = c0
	beam.CurveSize1 = c1
	beam.Width0 = 1
	beam.Width1 = 1
	beam.FaceCamera = true
	beam.LightEmission = 0.4
	beam.Brightness = 3
	beam.Segments = 1750
	beam.Attachment0 = att0
	beam.Attachment1 = att1
	beam.Parent = Workspace.Terrain

	local hb
	hb = RunService.Heartbeat:Connect(function()
		if not ball.Parent or ball.Velocity.Magnitude < 1 then
			hb:Disconnect()
			beam:Destroy()
			att0:Destroy()
			att1:Destroy()
		end
	end)
end

local function start()
	if not Config.BallPathEnabled or eventConnection then return end

	local function onBall(ball)
		if ball:IsA("BasePart") and ball.Name == "Football" then
			createPrediction(ball)
		end
	end

	eventConnection = Workspace.ChildAdded:Connect(onBall)

	for _, v in ipairs(Workspace:GetChildren()) do
		onBall(v)
	end
end

local function stop()
	if eventConnection then
		eventConnection:Disconnect()
		eventConnection = nil
	end
end

-- WalkSpeed fixer
RunService.RenderStepped:Connect(function()
	if not PlayerMods.AutoFixWalkSpeed then return end

	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if humanoid.WalkSpeed == 0 then
		humanoid.WalkSpeed = PlayerMods.DESIRED_SPEED
	end
end)

RunService.RenderStepped:Connect(function(dt)
    if PlayerMods.speedEnabled then
        local char = PlayerMods.Character
        local hum = PlayerMods.Humanoid
        local root = PlayerMods.RootPart
        if char and hum and root and hum.MoveDirection.Magnitude > 0 then
            local moveDir = hum.MoveDirection.Unit
            local baseDist = hum.WalkSpeed * dt
            local extraDist = baseDist * PlayerMods.speedValue
            root.CFrame = root.CFrame + (moveDir * extraDist)
        end
    end
    
    if PlayerMods.BlockReach then
        local char = LocalPlayer.Character
        if char then
            local blockpart = char:FindFirstChild("BlokPart") or char:FindFirstChild("BlockPart")
            if blockpart then 
                blockpart.Size = Vector3.new(PlayerMods.BlockReachSize, PlayerMods.BlockReachSize, PlayerMods.BlockReachSize) 
                blockpart.Transparency = 1 
            end
        end
    end
    
    if PlayerMods.AutoFixWalkSpeed then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.WalkSpeed == 0 then 
                humanoid.WalkSpeed = 20 
            end
        end
    end
    
    if PlayerMods.NoCollision then
        local char = LocalPlayer.Character
        if char then 
            for _, part in ipairs(char:GetDescendants()) do 
                if part:IsA("BasePart") then 
                    part.CanCollide = false 
                end 
            end 
        end
    end
    
    if Misc.AntiOOB then
        task.spawn(function()
            local Models = Workspace:FindFirstChild('Models')
            if not Models then return end
            
            local Boundaries = {}
            for _, v in pairs(Models:GetChildren()) do 
                if v.Name == 'Boundaries' then 
                    table.insert(Boundaries, v) 
                end 
            end
            
            while Misc.AntiOOB and task.wait(0.001) do 
                for _, v in pairs(Boundaries) do 
                    if v.Name == 'Boundaries' and v.Parent then 
                        v.Parent = ReplicatedStorage 
                    end 
                end 
            end
        end)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if not PlayerMods.jumpEnabled then return end
    local hum = PlayerMods.Humanoid
    local hrp = PlayerMods.RootPart
    if not hum or not hrp then return end
    if not PlayerMods.infiniteJump and not isGrounded(hum) then return end
    local v = hrp.AssemblyLinearVelocity
    hrp.AssemblyLinearVelocity = Vector3.new(v.X, PlayerMods.jumpVelocity, v.Z)
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    if input.KeyCode == Enum.KeyCode.E then 
        local hrp = getHumanoidRootPart() 
        if hrp and Config.DiveEnabled then 
            pcall(function() 
                hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * Config.DiveRange 
            end) 
        end 
    end
    
    if not FreezeController.manualFreezeEnabled then return end
    
    if input.KeyCode == FreezeController.freezeBind then 
        FreezeController.autoUnfreezeAt = nil 
        if FreezeController.manualMode == "Hold" then 
            FreezeController.Freeze() 
        else 
            FreezeController.ToggleFreeze() 
        end 
    end
    
    if input.KeyCode == Enum.KeyCode.F then 
        teleportForward() 
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    if not FreezeController.manualFreezeEnabled then return end
    if input.KeyCode == FreezeController.freezeBind then 
        if FreezeController.manualMode == "Hold" then 
            FreezeController.Unfreeze() 
        end 
    end
end)

Workspace.ChildRemoved:Connect(function(child)
    if child:IsA("BasePart") and child.Name == "Football" then
        if activeTweens[child] then 
            activeTweens[child]:Cancel() 
            activeTweens[child] = nil 
        end
        if closestBall == child then 
            closestBall = nil 
            closestDist = math.huge 
        end
    end
end)

local function createInstance(className, properties) 
    local instance = Instance.new(className) 
    for k, v in pairs(properties) do 
        if typeof(k) ~= 'string' then continue end 
        instance[k] = v 
    end 
    return instance 
end

-- catching tab
local NovaUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/azureblueday/Nova-UI-Library/refs/heads/main/source.lua"))()

game:GetService("UserInputService").InputBegan:Connect(function(input, gpe) 
    if gpe then return end 
    if input.KeyCode == Enum.KeyCode.LeftControl then 
        Window:Toggle() 
    end 
end)

-- Create the main window
local Window = NovaUI.new("🌙   Cryptic Hub || Football Fusion 2", nil)

-- qb tab
local ThrowingTab = Window:CreateTab("Throwing", NovaUI.Icons.sports_football)
local QBAimbot = Window:CreateSection(ThrowingTab, "QB Aimbot")

Window:CreateToggle(QBAimbot, "QB Aimbot", false, function(v) 
    QBA.enabled = v 
end, "qb_aimbot_enabled")

Window:CreateToggle(QBAimbot, "Mobile Buttons", false, function(v) 
    QBA.mobileEnabled = v 
end, "qb_beam_mode")

local CustomLeads = Window:CreateSection(ThrowingTab, "Custom Leads")

Window:CreateSlider(CustomLeads, "Dime Lead", -12, 20, 5, function(v) 
    ThrowTypeMap["Dime"] = v 
end, "dime_lead")

Window:CreateSlider(CustomLeads, "Mag Lead", -12, 20, 4, function(v) 
    ThrowTypeMap["Mag"] = v 
end, "mag_lead")

Window:CreateSlider(CustomLeads, "Bullet Lead", -12, 20, 0.6, function(v) 
    ThrowTypeMap["Bullet"] = v 
end, "bullet_lead")
local CatchingTab = Window:CreateTab("Catching", NovaUI.Icons.sports_mma)

local MagnetSec = Window:CreateSection(CatchingTab, "Magnets")

Window:CreateToggle(MagnetSec, "Magnet", false, function(v) 
    Config.Magnet.Enabled = v 
end, "magnet_enabled")

Window:CreateSlider(MagnetSec, "Magnet Distance", 0, 30, 5, function(v) 
    Config.Hitbox.Radius = v 
end, "magnet_distance")

Window:CreateDropdown(MagnetSec, "Magnet Type", {"League", "Legit", "Normal", "Blatant"}, "Normal", function(o) 
    Config.Magnet.Type = o 
end, "magnet_type")

Window:CreateToggle(MagnetSec, "Show Magnet Hitbox", false, function(v) 
    Config.Hitbox.Enabled = v 
    updateHitboxAppearance() 
end, "magnet_show_hitbox")

Window:CreateColorPicker(MagnetSec, "Magnet Hitbox Color", Color3.fromRGB(138, 43, 226), function(c) 
    Config.Hitbox.Color = c 
    if not Config.Hitbox.Rainbow then 
        HitboxPart.Color = c 
    end 
end, "magnet_hitbox_color")

Window:CreateToggle(MagnetSec, "Rainbow Magnet Hitbox", false, function(v) 
    Config.Hitbox.Rainbow = v 
end, "magnet_rainbow_hitbox")

local PVSec = Window:CreateSection(CatchingTab, "Pull Vector")

Window:CreateToggle(PVSec, "Pull Vector", false, function(v) 
    PullVector.enabled = v 
    if v then 
        startPullVector() 
    else 
        stopPullVector() 
    end 
end, "pull_vector_enabled")

Window:CreateSlider(PVSec, "Pull Vector Power", 1, 5, 3, function(v) 
    PullVector.power = v 
end, "pull_vector_power")

Window:CreateSlider(PVSec, "Pull Vector Distance", 1, 25, 10, function(v) 
    PullVector.distance = v 
end, "pull_vector_distance")

local FakeFreeze = Window:CreateSection(CatchingTab, "Fake Freeze Tech")

Window:CreateToggle(FakeFreeze, "Freeze Tech (G)", false, function(v) 
    FreezeController.manualFreezeEnabled = v 
    if not v then 
        FreezeController.Unfreeze() 
    end 
end, "freeze_tech_enabled")

Window:CreateDropdown(FakeFreeze, "Freeze Tech Mode", {"Toggle", "Hold"}, "Toggle", function(s) 
    FreezeController.manualMode = s or "Toggle" 
end, "freeze_tech_mode")

local AutoFreeze = Window:CreateSection(CatchingTab, "Auto Freeze")

Window:CreateToggle(AutoFreeze, "Auto Freeze", false, function(v) 
    FreezeController.autoFreezeEnabled = v 
end, "auto_freeze_enabled")

Window:CreateDropdown(AutoFreeze, "Auto Freeze Mode", {"Zenith of Jump", "After Catch"}, "After Catch", function(s) 
    FreezeController.autoFreezeMode = s or "After Catch" 
end, "auto_freeze_mode")

Window:CreateSlider(AutoFreeze, "Freeze Duration", 0, 2, 0.2, function(v) 
    FreezeController.autoFreezeDuration = v 
end, "freeze_duration")

-- player tab
local PlayerTab = Window:CreateTab("Player", NovaUI.Icons.account_circle)

local Walkspeed = Window:CreateSection(PlayerTab, "Walkspeed")

Window:CreateToggle(Walkspeed, "Walkspeed", false, function(v) 
    PlayerMods.speedEnabled = v 
end, "walkspeed_enabled")

Window:CreateSlider(Walkspeed, "Walkspeed Amount", 0.1, 1.4, 0.5, function(v) 
    PlayerMods.speedValue = v 
end, "walkspeed_amount")

local JumpPower = Window:CreateSection(PlayerTab, "Jump Power")

Window:CreateToggle(JumpPower, "Jump Power", false, function(v) 
    PlayerMods.jumpEnabled = v 
end, "jump_power_enabled")

Window:CreateSlider(JumpPower, "Jump Power Amount", 50, 70, 50, function(v) 
    PlayerMods.jumpVelocity = v 
end, "jump_power_amount")

Window:CreateToggle(JumpPower, "Infinite Jump", false, function(v) 
    PlayerMods.infiniteJump = v 
end, "infinite_jump")

local AESection = Window:CreateSection(PlayerTab, "Angle Enhancer")

Window:CreateToggle(AESection, "Angle Enhancer", false, function(v) 
    Misc.boostEnabled = v 
    if not v then 
        Misc.boostToken += 1 
        stopBoost() 
    end 
end, "angle_enhancer_enabled")

Window:CreateSlider(AESection, "Angle Enhancer Power", 50, 70, 50, function(v) 
    Misc.maxJP = v 
end, "angle_enhancer_power")

Window:CreateSlider(AESection, "Angle Enhancer Timing", 0.1, 1, 0.2, function(v) 
    Misc.boostDuration = v 
end, "angle_enhancer_timing")

local QTPSec = Window:CreateSection(PlayerTab, "Quick Teleport")

Window:CreateToggle(QTPSec, "Quick TP (F)", false, function(v) 
    Misc.tpEnabled = v 
end, "quick_tp_enabled")

Window:CreateSlider(QTPSec, "Quick TP Distance", 0, 10, 3, function(v) 
    Misc.tpDistance = v 
end, "quick_tp_distance")

-- physics
local PhysicsTab = Window:CreateTab("Physics", NovaUI.Icons.view_in_ar)

local BlockSection = Window:CreateSection(PhysicsTab, "Block Extender")

Window:CreateToggle(BlockSection, "Block Extender", false, function(v) 
    PlayerMods.BlockReach = v 
end, "block_extender_enabled")

Window:CreateSlider(BlockSection, "Block Extender Range", 0, 10, 5, function(v) 
    PlayerMods.BlockReachSize = v 
end, "block_extender_range")

local OtherPhysics = Window:CreateSection(PhysicsTab, "Other")

Window:CreateToggle(OtherPhysics, "Anti Jam", false, function(v) 
    PlayerMods.NoCollision = v 
end, "anti_jam")

Window:CreateToggle(OtherPhysics, "No Move Restrictions", false, function(v) 
    PlayerMods.NoMoveRestrictions = v 
end, "no_move_restrictions")

Window:CreateToggle(OtherPhysics, "Anti Block", false, function(v) 
    Misc.AntiBlock = v 
end, "anti_block")

Window:CreateToggle(OtherPhysics, "Anti Out of Bounds", false, function(v) 
    Misc.AntiOOB = v 
end, "anti_oob")

Window:CreateToggle(OtherPhysics, "No Jump Cooldown", false, function(v) 
    PlayerMods.NoJumpCooldown = v 
end, "no_jump_cooldown")

-- visuals
local VisTab = Window:CreateTab("Visuals", NovaUI.Icons.visibility)

local SkyboxSec = Window:CreateSection(VisTab, "Skybox Changer")

Window:CreateToggle(SkyboxSec, "Skybox Changer", false, function(v) 
    Skybox.enabled = v 
    if v then 
        applySkyboxCurrent() 
    else 
        restoreOriginalEverything() 
    end 
end, "skybox_changer_enabled")

Window:CreateDropdown(SkyboxSec, "Skybox Type", {"Gray", "Sunset", "Nova", "Night", "Thunder"}, "Gray", function(o) 
    if typeof(o) == "table" then 
        o = o[1] 
    end 
    Skybox.selected = o or Skybox.selected 
    if Skybox.enabled then 
        applySkyboxCurrent() 
    end 
end, "skybox_type")

Window:CreateSlider(SkyboxSec, "Skybox Effect Intensity", 0, 1, 0, function(v) 
    Skybox.intensity = v 
    if Skybox.enabled then 
        applyLightingWithIntensity(Skybox.selected, Skybox.intensity) 
    end 
end, "skybox_intensity")

local BallVisuals = Window:CreateSection(VisTab, "Ball Visuals")

Window:CreateToggle(BallVisuals, "Ball Path", false, function(v) 
    Config.BallPathEnabled = v 
    if v then 
        start() 
    else 
        stop() 
    end 
end, "ball_path_enabled")

local OtherVisuals = Window:CreateSection(VisTab, "Other")

Window:CreateToggle(OtherVisuals, "FPS Cap", false, function(v) 
    Misc.fpsCapEnabled = v 
    applyFpsCap() 
end, "fps_cap_enabled")

Window:CreateSlider(OtherVisuals, "FPS Value", 30, 999, 120, function(v) 
    Misc.fpsCapValue = v 
    if Misc.fpsCapEnabled then 
        applyFpsCap() 
    end 
end, "fps_cap_value")

Window:CreateToggle(OtherVisuals, "Low Graphics Mode", false, function(v) 
    Misc.noTexturesEnabled = v 
    applyNoTextures(v) 
end, "low_graphics_mode")

Window:CreateToggle(OtherVisuals, "Hide Stadium", false, function(v) 
    Misc.stadiumHidden = v 
    applyStadiumHidden(v) 
end, "hide_stadium")

-- ============================================
-- AUTOMATICS TAB
-- ============================================
local AutoTab = Window:CreateTab("Automatics", NovaUI.Icons.autorenew)

local AutoRushSec = Window:CreateSection(AutoTab, "Auto Rush")

Window:CreateToggle(AutoRushSec, "Auto Rush", false, function(v) 
    AutoRush.enabled = v 
end, "auto_rush_enabled")

Window:CreateSlider(AutoRushSec, "Prediction Delay", 0, 3, 0.1, function(v) 
    AutoRush.predictionDelay = v 
end, "auto_rush_prediction_delay")

local EndSec = Window:CreateSection(AutoTab, "Teleports")

Window:CreateButton(EndSec, "TP Home Endzone", function() 
    task.spawn(function() 
        stepTeleport(Vector3.new(2, 6, 169)) 
    end) 
end)

Window:CreateButton(EndSec, "TP Away Endzone", function() 
    task.spawn(function() 
        stepTeleport(Vector3.new(2, 6, -169)) 
    end) 
end)

local AutoKickSec = Window:CreateSection(AutoTab, "Auto Kick")

Window:CreateToggle(AutoKickSec, "Auto Kick", false, function(v) 
    AutoKick.Enabled = v 
end, "auto_kick_enabled")

Window:CreateToggle(AutoKickSec, "Walk to Ball", false, function(v) 
    AutoKick.WalkToBall = v 
end, "auto_kick_walk_to_ball")

Window:CreateSlider(AutoKickSec, "Kick Power", 0, 100, 95, function(v) 
    AutoKick.KickPower = v 
end, "auto_kick_power")

Window:CreateSlider(AutoKickSec, "Kick Accuracy", 0, 100, 95, function(v) 
    AutoKick.KickAccuracy = v 
end, "auto_kick_accuracy")

Window:CreateToggle(AutoKickSec, "Randomized Kick", false, function(v) 
    AutoKick.Randomize = v 
end, "auto_kick_randomize")

-- misc
local MiscTab = Window:CreateTab("Settings", NovaUI.Icons.settings)

local MiscFeatures = Window:CreateSection(MiscTab, "Misc")

Window:CreateButton(MiscFeatures, "Copy Discord Link", function() 
    setclipboard("discord.gg/getnova") 
    Window:Notify("Copied", "Discord link copied to clipboard!", "success", 2)
end)

Window:CreateButton(MiscFeatures, "Rejoin Server", function() 
    task.spawn(function() 
        local TeleportService = game:GetService("TeleportService")
        local LocalPlayer = game:GetService("Players").LocalPlayer
        if not LocalPlayer or not game.JobId or game.JobId == "" then 
            return 
        end 
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) 
    end) 
end)

Window:CreateButton(MiscFeatures, "Server Hop", function() 
    task.spawn(function() 
        local HttpService = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
        local LocalPlayer = game:GetService("Players").LocalPlayer
        local placeId = game.PlaceId 
        local currentJobId = game.JobId 
        local badServers = {} 
        local cursor = nil 
        
        for _ = 1, 20 do 
            local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor and ("&cursor=" .. cursor) or "") 
            local ok, resp = pcall(function() 
                return game:HttpGet(url) 
            end) 
            if not ok or not resp then 
                return 
            end 
            
            local data = HttpService:JSONDecode(resp) 
            local candidates = {} 
            if data and data.data then 
                for _, server in ipairs(data.data) do 
                    if server.id ~= currentJobId and not badServers[server.id] and server.playing < server.maxPlayers then 
                        table.insert(candidates, server) 
                    end 
                end 
            end 
            
            for _, server in ipairs(candidates) do 
                local tpOk = pcall(function() 
                    TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer) 
                end) 
                if tpOk then 
                    return 
                end 
                badServers[server.id] = true 
            end 
            
            cursor = data and data.nextPageCursor 
            if not cursor then 
                break 
            end 
        end 
    end) 
end)

-- Build the config system
Window:BuildConfig(MiscTab)

print("Cryptic Loaded!")
