--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║                      🍗 CRISPY UI 🍗                          ║
    ║         KFC & Fried Chicken Inspired Roblox UI Library        ║
    ║                                                               ║
    ║  Features: Toggles, Sliders, Dropdowns, TextInput, ColorPicker║
    ╚═══════════════════════════════════════════════════════════════╝
    
    Usage:
        local CrispyUI = loadstring(game:HttpGet("YOUR_URL"))()
        local Bucket = CrispyUI:CreateBucket("My Menu")
        local Recipe = Bucket:AddRecipe("Settings")
        Recipe:AddToggle({Name = "Crispy Mode", Default = true, Callback = function(v) print(v) end})
--]]

local CrispyUI = {}
CrispyUI.__index = CrispyUI

-- ═══════════════════════════════════════════════════════════════
-- 🎨 THEME CONFIGURATION - KFC Inspired Colors
-- ═══════════════════════════════════════════════════════════════

local Theme = {
    -- Primary KFC Colors
    KFCRed = Color3.fromRGB(200, 16, 46),
    DarkRed = Color3.fromRGB(140, 10, 30),
    DeepRed = Color3.fromRGB(92, 10, 10),
    
    -- Bucket & Crispy Colors
    BucketWhite = Color3.fromRGB(245, 245, 245),
    BucketCream = Color3.fromRGB(255, 248, 220),
    GoldenCrispy = Color3.fromRGB(255, 215, 0),
    GoldenBrown = Color3.fromRGB(218, 165, 32),
    CrispyOrange = Color3.fromRGB(255, 140, 50),
    
    -- Chicken Colors
    FriedLight = Color3.fromRGB(222, 184, 135),
    FriedMedium = Color3.fromRGB(210, 105, 30),
    FriedDark = Color3.fromRGB(139, 69, 19),
    
    -- Background
    DarkBrown = Color3.fromRGB(45, 24, 16),
    VeryDarkBrown = Color3.fromRGB(26, 10, 5),
    
    -- Text
    TextLight = Color3.fromRGB(255, 248, 220),
    TextGold = Color3.fromRGB(255, 215, 0),
    TextDark = Color3.fromRGB(92, 10, 10),
    
    -- Accent
    SpicyRed = Color3.fromRGB(255, 69, 0),
    HoneyGold = Color3.fromRGB(245, 183, 0),
}

-- ═══════════════════════════════════════════════════════════════
-- 🛠️ UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        if prop ~= "Parent" then
            instance[prop] = value
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

local function Tween(instance, properties, duration, style, direction)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
        Parent = parent
    })
end

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color or Theme.GoldenCrispy,
        Thickness = thickness or 3,
        Parent = parent
    })
end

local function AddPadding(parent, padding)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, padding),
        PaddingBottom = UDim.new(0, padding),
        PaddingLeft = UDim.new(0, padding),
        PaddingRight = UDim.new(0, padding),
        Parent = parent
    })
end

local function AddShadow(parent)
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://7912134082",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(50, 50, 450, 450),
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -15),
        ZIndex = -1,
        Parent = parent
    })
    return shadow
end

local function CreateRipple(button, color)
    button.ClipsDescendants = true
    
    button.MouseButton1Click:Connect(function()
        local mouse = UserInputService:GetMouseLocation()
        local relativePos = Vector2.new(
            mouse.X - button.AbsolutePosition.X,
            mouse.Y - button.AbsolutePosition.Y
        )
        
        local ripple = Create("Frame", {
            Name = "Ripple",
            BackgroundColor3 = color or Theme.GoldenCrispy,
            BackgroundTransparency = 0.7,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, relativePos.X, 0, relativePos.Y),
            Size = UDim2.new(0, 0, 0, 0),
            Parent = button
        })
        AddCorner(ripple, 999)
        
        local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
        Tween(ripple, {
            Size = UDim2.new(0, maxSize, 0, maxSize),
            BackgroundTransparency = 1
        }, 0.5)
        
        task.delay(0.5, function()
            ripple:Destroy()
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- 🪣 MAIN BUCKET (WINDOW) CREATION
-- ═══════════════════════════════════════════════════════════════

function CrispyUI:CreateBucket(title)
    local Bucket = {}
    Bucket.Recipes = {}
    
    -- Create ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "CrispyUI_" .. title,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    })
    
    -- Main Container (The Bucket)
    local MainFrame = Create("Frame", {
        Name = "Bucket",
        BackgroundColor3 = Theme.KFCRed,
        Size = UDim2.new(0, 380, 0, 500),
        Position = UDim2.new(0.5, -190, 0.5, -250),
        Parent = ScreenGui
    })
    AddCorner(MainFrame, 16)
    AddShadow(MainFrame)
    
    -- Red to Dark Red Gradient
    local MainGradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.KFCRed),
            ColorSequenceKeypoint.new(1, Theme.DarkRed)
        }),
        Rotation = 90,
        Parent = MainFrame
    })
    
    -- Golden Border
    AddStroke(MainFrame, Theme.GoldenCrispy, 4)
    
    -- Bucket Header (White Top with Stripes)
    local Header = Create("Frame", {
        Name = "Header",
        BackgroundColor3 = Theme.BucketWhite,
        Size = UDim2.new(1, 0, 0, 70),
        Parent = MainFrame
    })
    Create("UICorner", {
        CornerRadius = UDim.new(0, 16),
        Parent = Header
    })
    
    -- Bottom cover for header corners
    local HeaderBottomCover = Create("Frame", {
        Name = "BottomCover",
        BackgroundColor3 = Theme.BucketWhite,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 1, -20),
        BorderSizePixel = 0,
        Parent = Header
    })
    
    -- KFC Style Stripes
    local StripeContainer = Create("Frame", {
        Name = "Stripes",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 15),
        Position = UDim2.new(0, 0, 1, -20),
        ClipsDescendants = true,
        Parent = Header
    })
    
    for i = 0, 12 do
        Create("Frame", {
            BackgroundColor3 = i % 2 == 0 and Theme.KFCRed or Theme.BucketWhite,
            Size = UDim2.new(0, 30, 1, 0),
            Position = UDim2.new(0, i * 30, 0, 0),
            BorderSizePixel = 0,
            Parent = StripeContainer
        })
    end
    
    -- Title with Chicken Emoji
    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -80, 0, 50),
        Position = UDim2.new(0, 15, 0, 5),
        Font = Enum.Font.FredokaOne,
        Text = "🍗 " .. title .. " 🍗",
        TextColor3 = Theme.KFCRed,
        TextSize = 24,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    -- Close Button (X)
    local CloseButton = Create("TextButton", {
        Name = "Close",
        BackgroundColor3 = Theme.KFCRed,
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(1, -48, 0, 10),
        Font = Enum.Font.FredokaOne,
        Text = "✕",
        TextColor3 = Theme.BucketWhite,
        TextSize = 18,
        Parent = Header
    })
    AddCorner(CloseButton, 8)
    AddStroke(CloseButton, Theme.GoldenCrispy, 2)
    CreateRipple(CloseButton, Theme.SpicyRed)
    
    CloseButton.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0, 380, 0, 0)}, 0.3)
        task.wait(0.3)
        ScreenGui:Destroy()
    end)
    
    -- Minimize Button
    local MinimizeButton = Create("TextButton", {
        Name = "Minimize",
        BackgroundColor3 = Theme.HoneyGold,
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(1, -90, 0, 10),
        Font = Enum.Font.FredokaOne,
        Text = "−",
        TextColor3 = Theme.TextDark,
        TextSize = 24,
        Parent = Header
    })
    AddCorner(MinimizeButton, 8)
    AddStroke(MinimizeButton, Theme.GoldenBrown, 2)
    
    local isMinimized = false
    local originalSize = MainFrame.Size
    
    MinimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            Tween(MainFrame, {Size = UDim2.new(0, 380, 0, 70)}, 0.3)
            MinimizeButton.Text = "+"
        else
            Tween(MainFrame, {Size = originalSize}, 0.3)
            MinimizeButton.Text = "−"
        end
    end)
    
    -- Content Container
    local ContentContainer = Create("ScrollingFrame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -90),
        Position = UDim2.new(0, 10, 0, 80),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.GoldenCrispy,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = MainFrame
    })
    
    local ContentLayout = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = ContentContainer
    })
    
    AddPadding(ContentContainer, 5)
    
    -- Dragging Functionality
    local dragging, dragInput, dragStart, startPos
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- ═══════════════════════════════════════════════════════════════
    -- 📦 RECIPE (SECTION/TAB) CREATION
    -- ═══════════════════════════════════════════════════════════════
    
    function Bucket:AddRecipe(name)
        local Recipe = {}
        Recipe.Elements = {}
        
        -- Recipe Container (Section)
        local RecipeFrame = Create("Frame", {
            Name = "Recipe_" .. name,
            BackgroundColor3 = Theme.DeepRed,
            BackgroundTransparency = 0.3,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = ContentContainer
        })
        AddCorner(RecipeFrame, 12)
        AddStroke(RecipeFrame, Theme.GoldenCrispy, 2)
        
        -- Recipe Header
        local RecipeHeader = Create("TextButton", {
            Name = "Header",
            BackgroundColor3 = Theme.FriedDark,
            Size = UDim2.new(1, 0, 0, 40),
            Font = Enum.Font.FredokaOne,
            Text = "  🍗 " .. name,
            TextColor3 = Theme.GoldenCrispy,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = RecipeFrame
        })
        AddCorner(RecipeHeader, 12)
        
        -- Cover bottom corners
        local HeaderCover = Create("Frame", {
            BackgroundColor3 = Theme.FriedDark,
            Size = UDim2.new(1, 0, 0, 15),
            Position = UDim2.new(0, 0, 1, -15),
            BorderSizePixel = 0,
            ZIndex = 0,
            Parent = RecipeHeader
        })
        
        -- Arrow indicator
        local Arrow = Create("TextLabel", {
            Name = "Arrow",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 30, 1, 0),
            Position = UDim2.new(1, -35, 0, 0),
            Font = Enum.Font.FredokaOne,
            Text = "▼",
            TextColor3 = Theme.GoldenCrispy,
            TextSize = 14,
            Parent = RecipeHeader
        })
        
        -- Elements Container
        local ElementsContainer = Create("Frame", {
            Name = "Elements",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 0),
            Position = UDim2.new(0, 10, 0, 45),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = RecipeFrame
        })
        
        local ElementsLayout = Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = ElementsContainer
        })
        
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 10),
            Parent = ElementsContainer
        })
        
        -- Toggle Recipe Visibility
        local isOpen = true
        RecipeHeader.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            ElementsContainer.Visible = isOpen
            Arrow.Text = isOpen and "▼" or "▶"
            Tween(Arrow, {Rotation = isOpen and 0 or -90}, 0.2)
        end)
        
        -- ═══════════════════════════════════════════════════════════════
        -- 🔘 TOGGLE (Drumstick Switch)
        -- ═══════════════════════════════════════════════════════════════
        
        function Recipe:AddToggle(options)
            local Toggle = {}
            local enabled = options.Default or false
            
            local ToggleFrame = Create("Frame", {
                Name = "Toggle_" .. options.Name,
                BackgroundColor3 = Theme.DarkBrown,
                BackgroundTransparency = 0.5,
                Size = UDim2.new(1, 0, 0, 45),
                Parent = ElementsContainer
            })
            AddCorner(ToggleFrame, 10)
            AddStroke(ToggleFrame, Theme.GoldenBrown, 1)
            
            local ToggleLabel = Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -80, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                Font = Enum.Font.GothamMedium,
                Text = options.Name,
                TextColor3 = Theme.TextLight,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ToggleFrame
            })
            
            -- Switch Track
            local SwitchTrack = Create("Frame", {
                Name = "Track",
                BackgroundColor3 = enabled and Theme.CrispyOrange or Theme.DeepRed,
                Size = UDim2.new(0, 55, 0, 28),
                Position = UDim2.new(1, -70, 0.5, -14),
                Parent = ToggleFrame
            })
            AddCorner(SwitchTrack, 14)
            AddStroke(SwitchTrack, Theme.GoldenCrispy, 2)
            
            -- Track Gradient
            local TrackGradient = Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180))
                }),
                Rotation = 90,
                Parent = SwitchTrack
            })
            
            -- Drumstick Knob
            local Knob = Create("Frame", {
                Name = "Knob",
                BackgroundColor3 = Theme.FriedLight,
                Size = UDim2.new(0, 24, 0, 24),
                Position = enabled and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12),
                Parent = SwitchTrack
            })
            AddCorner(Knob, 12)
            
            -- Knob Gradient (Crispy texture)
            Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.FriedLight),
                    ColorSequenceKeypoint.new(0.5, Theme.FriedMedium),
                    ColorSequenceKeypoint.new(1, Theme.FriedDark)
                }),
                Rotation = 135,
                Parent = Knob
            })
            
            -- Drumstick emoji
            local DrumstickEmoji = Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = "🍗",
                TextSize = 12,
                Parent = Knob
            })
            
            -- Click Detection
            local ClickButton = Create("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                Parent = SwitchTrack
            })
            
            local function UpdateToggle()
                Tween(Knob, {
                    Position = enabled and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
                }, 0.2, Enum.EasingStyle.Back)
                
                Tween(SwitchTrack, {
                    BackgroundColor3 = enabled and Theme.CrispyOrange or Theme.DeepRed
                }, 0.2)
                
                if options.Callback then
                    options.Callback(enabled)
                end
            end
            
            ClickButton.MouseButton1Click:Connect(function()
                enabled = not enabled
                UpdateToggle()
            end)
            
            function Toggle:Set(value)
                enabled = value
                UpdateToggle()
            end
            
            function Toggle:Get()
                return enabled
            end
            
            return Toggle
        end
        
        -- ═══════════════════════════════════════════════════════════════
        -- 📊 SLIDER (Spice Meter)
        -- ═══════════════════════════════════════════════════════════════
        
        function Recipe:AddSlider(options)
            local Slider = {}
            local min = options.Min or 0
            local max = options.Max or 100
            local value = options.Default or min
            
            local SliderFrame = Create("Frame", {
                Name = "Slider_" .. options.Name,
                BackgroundColor3 = Theme.DarkBrown,
                BackgroundTransparency = 0.5,
                Size = UDim2.new(1, 0, 0, 65),
                Parent = ElementsContainer
            })
            AddCorner(SliderFrame, 10)
            AddStroke(SliderFrame, Theme.GoldenBrown, 1)
            
            -- Header with value
            local SliderHeader = Create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 25),
                Position = UDim2.new(0, 10, 0, 5),
                Parent = SliderFrame
            })
            
            local SliderLabel = Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.7, 0, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = options.Name,
                TextColor3 = Theme.TextLight,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SliderHeader
            })
            
            local ValueLabel = Create("TextLabel", {
                Name = "Value",
                BackgroundTransparency = 1,
                Size = UDim2.new(0.3, 0, 1, 0),
                Position = UDim2.new(0.7, 0, 0, 0),
                Font = Enum.Font.FredokaOne,
                Text = tostring(value),
                TextColor3 = Theme.GoldenCrispy,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = SliderHeader
            })
            
            -- Spice Track (Gradient from mild to hot)
            local Track = Create("Frame", {
                Name = "Track",
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, 35),
                Parent = SliderFrame
            })
            AddCorner(Track, 10)
            AddStroke(Track, Theme.GoldenCrispy, 2)
            
            -- Spice Gradient (Yellow -> Orange -> Red)
            Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.HoneyGold),
                    ColorSequenceKeypoint.new(0.5, Theme.CrispyOrange),
                    ColorSequenceKeypoint.new(1, Theme.KFCRed)
                }),
                Parent = Track
            })
            
            -- Unfilled portion (dark overlay)
            local UnfilledOverlay = Create("Frame", {
                Name = "Unfilled",
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = 0.6,
                Size = UDim2.new(1 - ((value - min) / (max - min)), 0, 1, 0),
                Position = UDim2.new((value - min) / (max - min), 0, 0, 0),
                BorderSizePixel = 0,
                Parent = Track
            })
            Create("UICorner", {
                CornerRadius = UDim.new(0, 10),
                Parent = UnfilledOverlay
            })
            
            -- Slider Thumb (Pepper/Chicken)
            local Thumb = Create("Frame", {
                Name = "Thumb",
                BackgroundColor3 = Theme.GoldenCrispy,
                Size = UDim2.new(0, 28, 0, 28),
                Position = UDim2.new((value - min) / (max - min), -14, 0.5, -14),
                ZIndex = 5,
                Parent = Track
            })
            AddCorner(Thumb, 14)
            AddStroke(Thumb, Theme.BucketWhite, 3)
            
            local ThumbEmoji = Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = "🌶️",
                TextSize = 14,
                ZIndex = 6,
                Parent = Thumb
            })
            
            -- Slider Interaction
            local dragging = false
            
            local function UpdateSlider(input)
                local trackAbsPos = Track.AbsolutePosition.X
                local trackAbsSize = Track.AbsoluteSize.X
                local mousePos = input.Position.X
                
                local percent = math.clamp((mousePos - trackAbsPos) / trackAbsSize, 0, 1)
                value = math.floor(min + (max - min) * percent)
                
                Thumb.Position = UDim2.new(percent, -14, 0.5, -14)
                UnfilledOverlay.Size = UDim2.new(1 - percent, 0, 1, 0)
                UnfilledOverlay.Position = UDim2.new(percent, 0, 0, 0)
                ValueLabel.Text = tostring(value)
                
                -- Change emoji based on spice level
                local spicePercent = (value - min) / (max - min)
                if spicePercent < 0.33 then
                    ThumbEmoji.Text = "🍗"
                elseif spicePercent < 0.66 then
                    ThumbEmoji.Text = "🌶️"
                else
                    ThumbEmoji.Text = "🔥"
                end
                
                if options.Callback then
                    options.Callback(value)
                end
            end
            
            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    UpdateSlider(input)
                end
            end)
            
            Track.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)
            
            function Slider:Set(newValue)
                value = math.clamp(newValue, min, max)
                local percent = (value - min) / (max - min)
                Thumb.Position = UDim2.new(percent, -14, 0.5, -14)
                UnfilledOverlay.Size = UDim2.new(1 - percent, 0, 1, 0)
                UnfilledOverlay.Position = UDim2.new(percent, 0, 0, 0)
                ValueLabel.Text = tostring(value)
            end
            
            function Slider:Get()
                return value
            end
            
            return Slider
        end
        
        -- ═══════════════════════════════════════════════════════════════
        -- 📋 DROPDOWN (Bucket Menu)
        -- ═══════════════════════════════════════════════════════════════
        
        function Recipe:AddDropdown(options)
            local Dropdown = {}
            local selected = options.Default or options.Options[1]
            local isOpen = false
            
            local DropdownFrame = Create("Frame", {
                Name = "Dropdown_" .. options.Name,
                BackgroundColor3 = Theme.DarkBrown,
                BackgroundTransparency = 0.5,
                Size = UDim2.new(1, 0, 0, 75),
                ClipsDescendants = true,
                Parent = ElementsContainer
            })
            AddCorner(DropdownFrame, 10)
            AddStroke(DropdownFrame, Theme.GoldenBrown, 1)
            
            local DropdownLabel = Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 25),
                Position = UDim2.new(0, 10, 0, 5),
                Font = Enum.Font.GothamMedium,
                Text = options.Name,
                TextColor3 = Theme.TextLight,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = DropdownFrame
            })
            
            -- Selected Option Button (Bucket Style)
            local SelectedButton = Create("TextButton", {
                Name = "Selected",
                BackgroundColor3 = Theme.BucketWhite,
                Size = UDim2.new(1, -20, 0, 38),
                Position = UDim2.new(0, 10, 0, 30),
                Font = Enum.Font.FredokaOne,
                Text = "🍗 " .. selected,
                TextColor3 = Theme.KFCRed,
                TextSize = 14,
                Parent = DropdownFrame
            })
            AddCorner(SelectedButton, 8)
            AddStroke(SelectedButton, Theme.GoldenCrispy, 2)
            
            local Arrow = Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 25, 1, 0),
                Position = UDim2.new(1, -30, 0, 0),
                Font = Enum.Font.FredokaOne,
                Text = "▼",
                TextColor3 = Theme.KFCRed,
                TextSize = 12,
                Parent = SelectedButton
            })
            
            -- Options Container
            local OptionsContainer = Create("Frame", {
                Name = "Options",
                BackgroundColor3 = Theme.BucketCream,
                Size = UDim2.new(1, -20, 0, #options.Options * 35 + 10),
                Position = UDim2.new(0, 10, 0, 73),
                Visible = false,
                ZIndex = 10,
                Parent = DropdownFrame
            })
            AddCorner(OptionsContainer, 8)
            AddStroke(OptionsContainer, Theme.GoldenCrispy, 2)
            
            local OptionsLayout = Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2),
                Parent = OptionsContainer
            })
            AddPadding(OptionsContainer, 5)
            
            -- Create option buttons
            for i, option in ipairs(options.Options) do
                local OptionButton = Create("TextButton", {
                    Name = "Option_" .. option,
                    BackgroundColor3 = Theme.BucketWhite,
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = Enum.Font.GothamMedium,
                    Text = "  🍗 " .. option,
                    TextColor3 = Theme.TextDark,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 11,
                    Parent = OptionsContainer
                })
                AddCorner(OptionButton, 6)
                
                OptionButton.MouseEnter:Connect(function()
                    Tween(OptionButton, {BackgroundColor3 = Theme.KFCRed, TextColor3 = Theme.BucketWhite}, 0.15)
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    Tween(OptionButton, {BackgroundColor3 = Theme.BucketWhite, TextColor3 = Theme.TextDark}, 0.15)
                    OptionButton.BackgroundTransparency = 0.5
                end)
                
                OptionButton.MouseButton1Click:Connect(function()
                    selected = option
                    SelectedButton.Text = "🍗 " .. selected
                    isOpen = false
                    OptionsContainer.Visible = false
                    Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 75)}, 0.2)
                    Tween(Arrow, {Rotation = 0}, 0.2)
                    
                    if options.Callback then
                        options.Callback(selected)
                    end
                end)
            end
            
            -- Toggle dropdown
            SelectedButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                OptionsContainer.Visible = isOpen
                
                local targetHeight = isOpen and (75 + #options.Options * 35 + 20) or 75
                Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.2)
                Tween(Arrow, {Rotation = isOpen and 180 or 0}, 0.2)
            end)
            
            function Dropdown:Set(option)
                if table.find(options.Options, option) then
                    selected = option
                    SelectedButton.Text = "🍗 " .. selected
                end
            end
            
            function Dropdown:Get()
                return selected
            end
            
            function Dropdown:Refresh(newOptions)
                -- Clear existing options
                for _, child in ipairs(OptionsContainer:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                
                options.Options = newOptions
                -- Recreate options (simplified)
            end
            
            return Dropdown
        end
        
        -- ═══════════════════════════════════════════════════════════════
        -- ✏️ TEXT INPUT (Order Box)
        -- ═══════════════════════════════════════════════════════════════
        
        function Recipe:AddTextInput(options)
            local TextInput = {}
            
            local InputFrame = Create("Frame", {
                Name = "TextInput_" .. options.Name,
                BackgroundColor3 = Theme.DarkBrown,
                BackgroundTransparency = 0.5,
                Size = UDim2.new(1, 0, 0, 70),
                Parent = ElementsContainer
            })
            AddCorner(InputFrame, 10)
            AddStroke(InputFrame, Theme.GoldenBrown, 1)
            
            local InputLabel = Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 25),
                Position = UDim2.new(0, 10, 0, 5),
                Font = Enum.Font.GothamMedium,
                Text = options.Name,
                TextColor3 = Theme.TextLight,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = InputFrame
            })
            
            -- Input Box (Receipt style)
            local InputBoxContainer = Create("Frame", {
                BackgroundColor3 = Theme.BucketCream,
                Size = UDim2.new(1, -20, 0, 35),
                Position = UDim2.new(0, 10, 0, 28),
                Parent = InputFrame
            })
            AddCorner(InputBoxContainer, 8)
            AddStroke(InputBoxContainer, Theme.GoldenCrispy, 2)
            
            -- Emoji icon
            local IconLabel = Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 35, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = "📝",
                TextSize = 18,
                Parent = InputBoxContainer
            })
            
            local InputBox = Create("TextBox", {
                Name = "Input",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -45, 1, 0),
                Position = UDim2.new(0, 40, 0, 0),
                Font = Enum.Font.GothamMedium,
                Text = options.Default or "",
                PlaceholderText = options.Placeholder or "Enter your order...",
                PlaceholderColor3 = Color3.fromRGB(160, 82, 45),
                TextColor3 = Theme.TextDark,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = options.ClearOnFocus or false,
                Parent = InputBoxContainer
            })
            
            InputBox.Focused:Connect(function()
                Tween(InputBoxContainer, {BackgroundColor3 = Theme.BucketWhite}, 0.2)
                AddStroke(InputBoxContainer, Theme.SpicyRed, 3)
            end)
            
            InputBox.FocusLost:Connect(function(enterPressed)
                Tween(InputBoxContainer, {BackgroundColor3 = Theme.BucketCream}, 0.2)
                
                if options.Callback then
                    options.Callback(InputBox.Text, enterPressed)
                end
            end)
            
            function TextInput:Set(text)
                InputBox.Text = text
            end
            
            function TextInput:Get()
                return InputBox.Text
            end
            
            return TextInput
        end
        
        -- ═══════════════════════════════════════════════════════════════
        -- 🎨 COLOR PICKER (Sauce Selector)
        -- ═══════════════════════════════════════════════════════════════
        
        function Recipe:AddColorPicker(options)
            local ColorPicker = {}
            local selectedColor = options.Default or Color3.fromRGB(200, 16, 46)
            local isOpen = false
            
            -- Preset sauce colors
            local SauceColors = {
                {name = "Ketchup", color = Color3.fromRGB(200, 16, 46)},
                {name = "Mustard", color = Color3.fromRGB(245, 183, 0)},
                {name = "BBQ", color = Color3.fromRGB(139, 69, 19)},
                {name = "Honey", color = Color3.fromRGB(218, 165, 32)},
                {name = "Buffalo", color = Color3.fromRGB(255, 107, 53)},
                {name = "Ranch", color = Color3.fromRGB(255, 253, 240)},
                {name = "Sriracha", color = Color3.fromRGB(178, 34, 34)},
                {name = "Teriyaki", color = Color3.fromRGB(101, 67, 33)},
                {name = "Sweet Chili", color = Color3.fromRGB(255, 69, 0)},
                {name = "Garlic Parm", color = Color3.fromRGB(255, 215, 0)},
                {name = "Creamy", color = Color3.fromRGB(255, 239, 213)},
                {name = "Nashville Hot", color = Color3.fromRGB(220, 20, 60)},
            }
            
            local ColorFrame = Create("Frame", {
                Name = "ColorPicker_" .. options.Name,
                BackgroundColor3 = Theme.DarkBrown,
                BackgroundTransparency = 0.5,
                Size = UDim2.new(1, 0, 0, 75),
                ClipsDescendants = true,
                Parent = ElementsContainer
            })
            AddCorner(ColorFrame, 10)
            AddStroke(ColorFrame, Theme.GoldenBrown, 1)
            
            local ColorLabel = Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 25),
                Position = UDim2.new(0, 10, 0, 5),
                Font = Enum.Font.GothamMedium,
                Text = options.Name,
                TextColor3 = Theme.TextLight,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ColorFrame
            })
            
            -- Color Preview Button
            local ColorPreview = Create("TextButton", {
                Name = "Preview",
                BackgroundColor3 = selectedColor,
                Size = UDim2.new(1, -20, 0, 38),
                Position = UDim2.new(0, 10, 0, 30),
                Font = Enum.Font.FredokaOne,
                Text = "🎨 Pick Your Sauce",
                TextColor3 = Theme.BucketWhite,
                TextSize = 14,
                Parent = ColorFrame
            })
            AddCorner(ColorPreview, 8)
            AddStroke(ColorPreview, Theme.GoldenCrispy, 3)
            
            -- Add text shadow for readability
            Create("UIStroke", {
                Color = Color3.fromRGB(0, 0, 0),
                Thickness = 1,
                Transparency = 0.5,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Parent = ColorPreview
            })
            
            -- Color Palette Container
            local PaletteContainer = Create("Frame", {
                Name = "Palette",
                BackgroundColor3 = Theme.VeryDarkBrown,
                Size = UDim2.new(1, -20, 0, 180),
                Position = UDim2.new(0, 10, 0, 73),
                Visible = false,
                ZIndex = 10,
                Parent = ColorFrame
            })
            AddCorner(PaletteContainer, 10)
            AddStroke(PaletteContainer, Theme.GoldenCrispy, 2)
            AddPadding(PaletteContainer, 10)
            
            -- Sauce Grid
            local SauceGrid = Create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 80),
                Parent = PaletteContainer
            })
            
            Create("UIGridLayout", {
                CellSize = UDim2.new(0, 38, 0, 38),
                CellPadding = UDim2.new(0, 8, 0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = SauceGrid
            })
            
            for i, sauce in ipairs(SauceColors) do
                local SauceSwatch = Create("TextButton", {
                    Name = sauce.name,
                    BackgroundColor3 = sauce.color,
                    Size = UDim2.new(0, 38, 0, 38),
                    Text = "",
                    ZIndex = 11,
                    Parent = SauceGrid
                })
                AddCorner(SauceSwatch, 8)
                AddStroke(SauceSwatch, Theme.GoldenCrispy, 2)
                
                SauceSwatch.MouseEnter:Connect(function()
                    Tween(SauceSwatch, {Size = UDim2.new(0, 42, 0, 42)}, 0.1)
                end)
                
                SauceSwatch.MouseLeave:Connect(function()
                    Tween(SauceSwatch, {Size = UDim2.new(0, 38, 0, 38)}, 0.1)
                end)
                
                SauceSwatch.MouseButton1Click:Connect(function()
                    selectedColor = sauce.color
                    ColorPreview.BackgroundColor3 = selectedColor
                    
                    if options.Callback then
                        options.Callback(selectedColor)
                    end
                end)
            end
            
            -- Custom RGB Sliders
            local RGBContainer = Create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 80),
                Position = UDim2.new(0, 0, 0, 90),
                Parent = PaletteContainer
            })
            
            local function CreateRGBSlider(name, color, yPos, getValue, setValue)
                local SliderFrame = Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 22),
                    Position = UDim2.new(0, 0, 0, yPos),
                    ZIndex = 11,
                    Parent = RGBContainer
                })
                
                local Label = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 20, 1, 0),
                    Font = Enum.Font.FredokaOne,
                    Text = name,
                    TextColor3 = color,
                    TextSize = 14,
                    ZIndex = 11,
                    Parent = SliderFrame
                })
                
                local Track = Create("Frame", {
                    BackgroundColor3 = color,
                    Size = UDim2.new(1, -60, 0, 12),
                    Position = UDim2.new(0, 25, 0.5, -6),
                    ZIndex = 11,
                    Parent = SliderFrame
                })
                AddCorner(Track, 6)
                
                local Thumb = Create("Frame", {
                    BackgroundColor3 = Theme.BucketWhite,
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(getValue() / 255, -8, 0.5, -8),
                    ZIndex = 12,
                    Parent = Track
                })
                AddCorner(Thumb, 8)
                AddStroke(Thumb, color, 2)
                
                local ValueLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 30, 1, 0),
                    Position = UDim2.new(1, -30, 0, 0),
                    Font = Enum.Font.GothamBold,
                    Text = tostring(math.floor(getValue())),
                    TextColor3 = Theme.TextLight,
                    TextSize = 12,
                    ZIndex = 11,
                    Parent = SliderFrame
                })
                
                local dragging = false
                
                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                
                Track.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local percent = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                        local value = math.floor(percent * 255)
                        
                        Thumb.Position = UDim2.new(percent, -8, 0.5, -8)
                        ValueLabel.Text = tostring(value)
                        
                        setValue(value)
                        ColorPreview.BackgroundColor3 = selectedColor
                        
                        if options.Callback then
                            options.Callback(selectedColor)
                        end
                    end
                end)
                
                return {Track = Track, Thumb = Thumb, ValueLabel = ValueLabel}
            end
            
            CreateRGBSlider("R", Color3.fromRGB(255, 80, 80), 0,
                function() return selectedColor.R * 255 end,
                function(v) selectedColor = Color3.fromRGB(v, selectedColor.G * 255, selectedColor.B * 255) end
            )
            
            CreateRGBSlider("G", Color3.fromRGB(80, 255, 80), 26,
                function() return selectedColor.G * 255 end,
                function(v) selectedColor = Color3.fromRGB(selectedColor.R * 255, v, selectedColor.B * 255) end
            )
            
            CreateRGBSlider("B", Color3.fromRGB(80, 150, 255), 52,
                function() return selectedColor.B * 255 end,
                function(v) selectedColor = Color3.fromRGB(selectedColor.R * 255, selectedColor.G * 255, v) end
            )
            
            -- Toggle palette
            ColorPreview.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                PaletteContainer.Visible = isOpen
                
                local targetHeight = isOpen and 260 or 75
                Tween(ColorFrame, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.25)
            end)
            
            function ColorPicker:Set(color)
                selectedColor = color
                ColorPreview.BackgroundColor3 = selectedColor
            end
            
            function ColorPicker:Get()
                return selectedColor
            end
            
            return ColorPicker
        end
        
        -- ═══════════════════════════════════════════════════════════════
        -- 🔘 BUTTON (Crispy Button)
        -- ═══════════════════════════════════════════════════════════════
        
        function Recipe:AddButton(options)
            local Button = {}
            
            local ButtonFrame = Create("TextButton", {
                Name = "Button_" .. options.Name,
                BackgroundColor3 = Theme.KFCRed,
                Size = UDim2.new(1, 0, 0, 42),
                Font = Enum.Font.FredokaOne,
                Text = "🍗 " .. options.Name,
                TextColor3 = Theme.BucketWhite,
                TextSize = 16,
                AutoButtonColor = false,
                Parent = ElementsContainer
            })
            AddCorner(ButtonFrame, 10)
            AddStroke(ButtonFrame, Theme.GoldenCrispy, 3)
            
            -- Gradient
            Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180))
                }),
                Rotation = 90,
                Parent = ButtonFrame
            })
            
            -- Shadow effect
            local Shadow = Create("Frame", {
                BackgroundColor3 = Theme.DeepRed,
                Size = UDim2.new(1, 0, 0, 5),
                Position = UDim2.new(0, 0, 1, 0),
                ZIndex = -1,
                Parent = ButtonFrame
            })
            AddCorner(Shadow, 10)
            
            ButtonFrame.MouseEnter:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Theme.SpicyRed}, 0.15)
            end)
            
            ButtonFrame.MouseLeave:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Theme.KFCRed}, 0.15)
            end)
            
            ButtonFrame.MouseButton1Down:Connect(function()
                Tween(ButtonFrame, {Position = ButtonFrame.Position + UDim2.new(0, 0, 0, 3)}, 0.1)
                Shadow.Visible = false
            end)
            
            ButtonFrame.MouseButton1Up:Connect(function()
                Tween(ButtonFrame, {Position = ButtonFrame.Position - UDim2.new(0, 0, 0, 3)}, 0.1)
                Shadow.Visible = true
            end)
            
            ButtonFrame.MouseButton1Click:Connect(function()
                if options.Callback then
                    options.Callback()
                end
            end)
            
            return Button
        end
        
        -- ═══════════════════════════════════════════════════════════════
        -- 📝 LABEL (Info Text)
        -- ═══════════════════════════════════════════════════════════════
        
        function Recipe:AddLabel(text)
            local Label = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 25),
                Font = Enum.Font.GothamMedium,
                Text = text,
                TextColor3 = Theme.TextGold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                Parent = ElementsContainer
            })
            
            return Label
        end
        
        -- ═══════════════════════════════════════════════════════════════
        -- ➖ DIVIDER (Separator)
        -- ═══════════════════════════════════════════════════════════════
        
        function Recipe:AddDivider()
            local Divider = Create("Frame", {
                Name = "Divider",
                BackgroundColor3 = Theme.GoldenCrispy,
                BackgroundTransparency = 0.5,
                Size = UDim2.new(1, 0, 0, 2),
                Parent = ElementsContainer
            })
            AddCorner(Divider, 1)
            
            return Divider
        end
        
        table.insert(Bucket.Recipes, Recipe)
        return Recipe
    end
    
    -- Destroy the bucket
    function Bucket:Destroy()
        ScreenGui:Destroy()
    end
    
    return Bucket
end

-- ═══════════════════════════════════════════════════════════════
-- 🔔 NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════════

function CrispyUI:Notify(options)
    local title = options.Title or "Notification"
    local text = options.Text or ""
    local duration = options.Duration or 3
    
    local player = Players.LocalPlayer
    local gui = player:FindFirstChild("PlayerGui"):FindFirstChild("CrispyUI_Notifications")
    
    if not gui then
        gui = Create("ScreenGui", {
            Name = "CrispyUI_Notifications",
            ResetOnSpawn = false,
            Parent = player.PlayerGui
        })
        
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Parent = gui
        })
        
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 20),
            PaddingRight = UDim.new(0, 20),
            Parent = gui
        })
    end
    
    local NotifFrame = Create("Frame", {
        BackgroundColor3 = Theme.KFCRed,
        Size = UDim2.new(0, 280, 0, 70),
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, 300, 1, 0),
        Parent = gui
    })
    AddCorner(NotifFrame, 12)
    AddStroke(NotifFrame, Theme.GoldenCrispy, 3)
    AddShadow(NotifFrame)
    
    -- Header stripe
    local Stripe = Create("Frame", {
        BackgroundColor3 = Theme.FriedDark,
        Size = UDim2.new(1, 0, 0, 25),
        Parent = NotifFrame
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Stripe})
    Create("Frame", {
        BackgroundColor3 = Theme.FriedDark,
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BorderSizePixel = 0,
        Parent = Stripe
    })
    
    local TitleLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -15, 0, 25),
        Position = UDim2.new(0, 10, 0, 0),
        Font = Enum.Font.FredokaOne,
        Text = "🍗 " .. title,
        TextColor3 = Theme.GoldenCrispy,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = NotifFrame
    })
    
    local TextLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 35),
        Position = UDim2.new(0, 10, 0, 28),
        Font = Enum.Font.GothamMedium,
        Text = text,
        TextColor3 = Theme.TextLight,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = NotifFrame
    })
    
    -- Animate in
    Tween(NotifFrame, {Position = UDim2.new(1, -20, 1, 0)}, 0.3, Enum.EasingStyle.Back)
    
    -- Animate out and destroy
    task.delay(duration, function()
        Tween(NotifFrame, {Position = UDim2.new(1, 300, 1, 0)}, 0.3)
        task.wait(0.3)
        NotifFrame:Destroy()
    end)
end

return CrispyUI
