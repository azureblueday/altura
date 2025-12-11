local Altura = {}
Altura.__index = Altura

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Default theme (matched to screenshot style)
Altura.Theme = {
    BG = Color3.fromRGB(20,20,23),
    Panel = Color3.fromRGB(28,28,33),
    Sidebar = Color3.fromRGB(24,24,30),
    Accent = Color3.fromRGB(207,70,70),
    Text = Color3.fromRGB(235,235,235),
    SubText = Color3.fromRGB(170,170,170),
    Stroke = Color3.fromRGB(60,60,60),
    Radius = 10,
    Transparency = 0
}

-- Storage (autosave)
Altura.Storage = {}

-- Helpers
local function round(obj, px)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, px or Altura.Theme.Radius)
    c.Parent = obj
    return c
end

local function stroke(obj, thickness)
    local s = Instance.new("UIStroke")
    s.Color = Altura.Theme.Stroke
    s.Thickness = thickness or 1
    s.Parent = obj
    return s
end

local function tweenProperties(instance, time, props, onComplete)
    local ti = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, ti, props)
    tween:Play()
    if onComplete then
        tween.Completed:Connect(onComplete)
    end
    return tween
end

-- Safe file helpers (works in exploit env; safely no-op otherwise)
local function safeWriteFile(path, data)
    if writefile then
        pcall(writefile, path, data)
    end
end

local function safeReadFile(path)
    if isfile and isfile(path) and readfile then
        local ok, res = pcall(readfile, path)
        if ok then return res end
    end
    return nil
end

local function safeIsFile(path)
    if isfile then
        return isfile(path)
    end
    return false
end

-- Notification system
function Altura:Notify(text, duration)
    duration = duration or 2
    if not self._notifHolder then
        local sg = Instance.new("ScreenGui")
        sg.Name = "AlturaNotifs"
        sg.ResetOnSpawn = false
        sg.Parent = game.CoreGui
        local holder = Instance.new("Frame", sg)
        holder.AnchorPoint = Vector2.new(1,0)
        holder.Position = UDim2.new(1,-10,0,10)
        holder.Size = UDim2.new(0, 320, 0, 0)
        holder.BackgroundTransparency = 1
        holder.BorderSizePixel = 0
        self._notifHolder = holder
        local list = Instance.new("UIListLayout", holder)
        list.Padding = UDim.new(0,8)
        list.HorizontalAlignment = Enum.HorizontalAlignment.Right
        list.SortOrder = Enum.SortOrder.LayoutOrder
    end

    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,44)
    f.BackgroundColor3 = self.Theme.Panel
    f.Parent = self._notifHolder
    f.AnchorPoint = Vector2.new(1,0)
    round(f,8); stroke(f,1)

    local t = Instance.new("TextLabel", f)
    t.BackgroundTransparency = 1
    t.Size = UDim2.new(1,-12,1,0)
    t.Position = UDim2.new(0,8,0,0)
    t.Font = Enum.Font.Gotham
    t.TextSize = 14
    t.TextColor3 = self.Theme.Text
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.TextYAlignment = Enum.TextYAlignment.Center
    t.Text = text

    f.BackgroundTransparency = 1
    tweenProperties(f, 0.25, {BackgroundTransparency = 0})
    task.delay(duration, function()
        tweenProperties(f, 0.25, {BackgroundTransparency = 1}, function() f:Destroy() end)
    end)
end

-- Autosave API
function Altura:SetStorageKey(key)
    self.SaveKey = key
    if key then
        self:Load()
    end
end

function Altura:Save()
    if not self.SaveKey then return end
    local ok, json = pcall(function() return HttpService:JSONEncode(self.Storage) end)
    if ok and json then
        safeWriteFile(self.SaveKey, json)
    end
end

function Altura:Load()
    if not self.SaveKey then return end
    local raw = safeReadFile(self.SaveKey)
    if raw then
        local ok, tbl = pcall(function() return HttpService:JSONDecode(raw) end)
        if ok and type(tbl) == "table" then
            self.Storage = tbl
        end
    end
end

-- Theme API
function Altura:SetTheme(key, value)
    self.Theme[key] = value
end

function Altura:GetTheme(key)
    return self.Theme[key]
end

-- Create UI root
function Altura:Create(title)
    local instance = setmetatable({}, Altura)
    instance._tabs = {}
    instance._current = nil
    instance.Theme = Altura.Theme
    instance.Storage = Altura.Storage

    -- Load storage if key set
    if self.SaveKey then instance:Load() end

    local sg = Instance.new("ScreenGui")
    sg.Name = title or "AlturaUI"
    sg.ResetOnSpawn = false
    sg.Parent = game.CoreGui

    -- main window
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 980, 0, 560)
    main.Position = UDim2.new(0.5, -490, 0.5, -280)
    main.BackgroundColor3 = instance.Theme.BG
    main.BorderSizePixel = 0
    round(main, instance.Theme.Radius); stroke(main, 1)

    -- header label
    local header = Instance.new("TextLabel", main)
    header.BackgroundTransparency = 1
    header.Text = title or "Altura UI"
    header.Font = Enum.Font.GothamSemibold
    header.TextSize = 18
    header.TextColor3 = instance.Theme.Text
    header.Position = UDim2.new(0, 20, 0, 12)
    header.Size = UDim2.new(1, -40, 0, 26)

    -- sidebar
    local sidebar = Instance.new("Frame", main)
    sidebar.Size = UDim2.new(0, 200, 1, -70)
    sidebar.Position = UDim2.new(0, 10, 0, 50)
    sidebar.BackgroundColor3 = instance.Theme.Sidebar
    sidebar.BorderSizePixel = 0
    round(sidebar, 8); stroke(sidebar,1)

    local sidebarLayout = Instance.new("UIListLayout", sidebar)
    sidebarLayout.Padding = UDim.new(0,8)
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- content holder
    local contentHolder = Instance.new("Frame", main)
    contentHolder.Size = UDim2.new(1, -230, 1, -70)
    contentHolder.Position = UDim2.new(0, 220, 0, 50)
    contentHolder.BackgroundTransparency = 1

    -- window dragging
    do
        local dragging = false
        local dragStart = Vector2.new(0,0)
        local startPos = main.Position

        local function onInputBegan(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = main.Position
            end
        end
        local function onInputChanged(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
        local function onInputEnded(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end
        main.InputBegan:Connect(onInputBegan)
        UserInputService.InputChanged:Connect(onInputChanged)
        main.InputEnded:Connect(onInputEnded)
    end

    -- tab creation
    function instance:Tab(text, iconAssetId)
        local tab = {}

        -- sidebar button
        local btn = Instance.new("TextButton", sidebar)
        btn.Size = UDim2.new(1, -12, 0, 40)
        btn.BackgroundColor3 = instance.Theme.Sidebar
        btn.AutoButtonColor = false
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 15
        btn.TextColor3 = instance.Theme.SubText
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Text = "   "..(text or "Tab")
        round(btn, 8); stroke(btn,1)

        -- optionally show icon by adding an ImageLabel left of the text (not embedding in text)
        if iconAssetId then
            local icon = Instance.new("ImageLabel", btn)
            icon.Size = UDim2.new(0, 28, 0, 28)
            icon.Position = UDim2.new(0, 6, 0.5, -14)
            icon.BackgroundTransparency = 1
            icon.Image = tostring(iconAssetId)
        end

        -- page (scrolling)
        local page = Instance.new("ScrollingFrame", contentHolder)
        page.BackgroundColor3 = instance.Theme.Panel
        page.Size = UDim2.new(1, 0, 1, 0)
        page.ScrollBarThickness = 6
        page.Visible = false
        page.CanvasSize = UDim2.new(0,0,0,0)
        round(page, 10); stroke(page,1)
        local pad = Instance.new("UIPadding", page)
        pad.PaddingTop = UDim.new(0, 12)
        pad.PaddingLeft = UDim.new(0, 12)
        local list = Instance.new("UIListLayout", page)
        list.Padding = UDim.new(0, 12)
        list.SortOrder = Enum.SortOrder.LayoutOrder

        function tab:Show()
            -- hide all
            for _, t in pairs(instance._tabs) do
                t.Page.Visible = false
                t.Button.TextColor3 = instance.Theme.SubText
            end
            page.Visible = true
            btn.TextColor3 = instance.Theme.Accent
            instance._current = tab
            -- animated entrance
            page.BackgroundTransparency = 1
            tweenProperties(page, 0.18, {BackgroundTransparency = 0})
        end

        btn.MouseButton1Click:Connect(function()
            tab:Show()
        end)

        tab.Button = btn
        tab.Page = page

        table.insert(instance._tabs, tab)
        -- if first tab, show
        if #instance._tabs == 1 then
            tab:Show()
        end

        return tab
    end

    -- Section
    function instance:Section(tab, text)
        local label = Instance.new("TextLabel", tab.Page)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 18
        label.TextColor3 = instance.Theme.Text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Size = UDim2.new(1, -10, 0, 24)
        label.Text = text or ""
        return label
    end

    -- Toggle component
    function instance:Toggle(tab, text, key, callback)
        -- key: storage key to autosave, optional
        local frame = Instance.new("Frame", tab.Page)
        frame.Size = UDim2.new(1, -16, 0, 40)
        frame.BackgroundColor3 = instance.Theme.Panel
        round(frame, 8); stroke(frame,1)

        local label = Instance.new("TextLabel", frame)
        label.BackgroundTransparency = 1
        label.Text = text or "Toggle"
        label.Font = Enum.Font.Gotham
        label.TextSize = 15
        label.TextColor3 = instance.Theme.Text
        label.Size = UDim2.new(1, -50, 1, 0)
        label.TextXAlignment = Enum.TextXAlignment.Left

        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0, 36, 0, 20)
        btn.Position = UDim2.new(1, -46, 0.5, -10)
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        round(btn, 10)

        local dot = Instance.new("Frame", btn)
        dot.Size = UDim2.new(0, 16, 0, 16)
        dot.Position = UDim2.new(0, 2, 0, 2)
        dot.BackgroundColor3 = instance.Theme.SubText
        round(dot, 8)

        local state = false
        if key and instance.Storage[key] ~= nil then
            state = instance.Storage[key]
        end
        local function applyState()
            if state then
                dot.Position = UDim2.new(1, -18, 0, 2)
                dot.BackgroundColor3 = instance.Theme.Accent
            else
                dot.Position = UDim2.new(0, 2, 0, 2)
                dot.BackgroundColor3 = instance.Theme.SubText
            end
        end
        applyState()

        btn.MouseButton1Click:Connect(function()
            state = not state
            if key then
                instance.Storage[key] = state
                instance:Save()
            end
            applyState()
            if callback then
                callback(state)
            end
        end)

        return frame
    end

    -- Slider component
    function instance:Slider(tab, labelText, min, max, default, key, callback)
        min = min or 0; max = max or 100; default = default or min
        local frame = Instance.new("Frame", tab.Page)
        frame.Size = UDim2.new(1,-16,0,56)
        frame.BackgroundColor3 = instance.Theme.Panel
        round(frame,8); stroke(frame,1)

        local label = Instance.new("TextLabel", frame)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 15
        label.TextColor3 = instance.Theme.Text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Size = UDim2.new(1,-10,0,26)
        label.Position = UDim2.new(0,6,0,2)

        local bar = Instance.new("Frame", frame)
        bar.Size = UDim2.new(1,-20,0,8)
        bar.Position = UDim2.new(0,10,0,34)
        bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
        round(bar,4)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new(0,0,1,0)
        fill.BackgroundColor3 = instance.Theme.Accent
        round(fill,4)

        local dragging = false

        local saved = default
        if key and instance.Storage[key] ~= nil then
            saved = instance.Storage[key]
        end

        local function setValue(v)
            v = math.clamp(math.floor(v), min, max)
            label.Text = (labelText or "Slider").." ("..v..")"
            local rel = 0
            if max - min ~= 0 then
                rel = (v - min) / (max - min)
            end
            fill.Size = UDim2.new(rel, 0, 1, 0)
            if callback then callback(v) end
            if key then
                instance.Storage[key] = v
                instance:Save()
            end
        end

        setValue(saved)

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        bar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local absPos = bar.AbsolutePosition
                local absSize = bar.AbsoluteSize
                local rel = (input.Position.X - absPos.X) / absSize.X
                rel = math.clamp(rel, 0, 1)
                local value = min + math.floor((max - min) * rel + 0.5)
                setValue(value)
            end
        end)

        -- click-to-set
        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local absPos = bar.AbsolutePosition
                local absSize = bar.AbsoluteSize
                local rel = (input.Position.X - absPos.X) / absSize.X
                rel = math.clamp(rel, 0, 1)
                local value = min + math.floor((max - min) * rel + 0.5)
                setValue(value)
            end
        end)

        return frame
    end

    -- Dropdown component
    function instance:Dropdown(tab, labelText, items, key, callback)
        items = items or {}
        local frame = Instance.new("Frame", tab.Page)
        frame.Size = UDim2.new(1,-16,0,40)
        frame.BackgroundColor3 = instance.Theme.Panel
        round(frame,8); stroke(frame,1)

        local label = Instance.new("TextLabel", frame)
        label.BackgroundTransparency = 1
        label.Text = labelText or "Dropdown"
        label.Font = Enum.Font.Gotham
        label.TextSize = 15
        label.TextColor3 = instance.Theme.Text
        label.Size = UDim2.new(1,-10,1,0)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Position = UDim2.new(0,8,0,0)

        local arrow = Instance.new("TextLabel", frame)
        arrow.BackgroundTransparency = 1
        arrow.Text = "▾"
        arrow.Font = Enum.Font.Gotham
        arrow.TextSize = 14
        arrow.TextColor3 = instance.Theme.SubText
        arrow.Position = UDim2.new(1, -28, 0.5, -10)
        arrow.Size = UDim2.new(0, 20, 0, 20)
        arrow.TextXAlignment = Enum.TextXAlignment.Center

        local open = false
        local container

        local function openDropdown()
            if open then return end
            open = true
            arrow.Text = "▴"

            container = Instance.new("Frame", frame)
            container.Position = UDim2.new(0,0,1,8)
            container.Size = UDim2.new(1,0,0, math.clamp(#items * 34, 0, 300))
            container.BackgroundColor3 = instance.Theme.Panel
            round(container,8); stroke(container,1)

            local list = Instance.new("UIListLayout", container)
            list.Padding = UDim.new(0,4)

            for _, it in ipairs(items) do
                local btn = Instance.new("TextButton", container)
                btn.Size = UDim2.new(1,-8,0,30)
                btn.Position = UDim2.new(0,4,0,0)
                btn.BackgroundColor3 = Color3.fromRGB(45,45,50)
                btn.AutoButtonColor = false
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 14
                btn.TextColor3 = instance.Theme.Text
                btn.Text = it
                round(btn,6)
                btn.MouseButton1Click:Connect(function()
                    label.Text = labelText..": "..it
                    if key then instance.Storage[key] = it; instance:Save() end
                    if callback then callback(it) end
                    container:Destroy(); open = false; arrow.Text = "▾"
                end)
            end
        end

        local function closeDropdown()
            if not open then return end
            open = false
            arrow.Text = "▾"
            if container then container:Destroy() end
        end

        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if open then closeDropdown() else openDropdown() end
            end
        end)

        return frame
    end

    -- Keybind picker
    function instance:Keybind(tab, labelText, defaultKey, keyStorage, callback)
        local frame = Instance.new("Frame", tab.Page)
        frame.Size = UDim2.new(1,-16,0,40)
        frame.BackgroundColor3 = instance.Theme.Panel
        round(frame,8); stroke(frame,1)

        local label = Instance.new("TextLabel", frame)
        label.BackgroundTransparency = 1
        label.Text = labelText or "Keybind"
        label.Font = Enum.Font.Gotham
        label.TextSize = 15
        label.TextColor3 = instance.Theme.Text
        label.Size = UDim2.new(1,-140,1,0)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Position = UDim2.new(0,8,0,0)

        local keyBtn = Instance.new("TextButton", frame)
        keyBtn.Size = UDim2.new(0,120,0,26)
        keyBtn.Position = UDim2.new(1,-132,0.5,-13)
        keyBtn.Text = "["..tostring(defaultKey or "None").."]"
        keyBtn.Font = Enum.Font.Gotham
        keyBtn.TextSize = 14
        keyBtn.TextColor3 = instance.Theme.SubText
        keyBtn.AutoButtonColor = false
        round(keyBtn,8); stroke(keyBtn,1)
        keyBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)

        local listening = false
        local picked = defaultKey

        if keyStorage and instance.Storage[keyStorage] then
            picked = instance.Storage[keyStorage]
        end

        keyBtn.MouseButton1Click:Connect(function()
            listening = true
            keyBtn.Text = "[Press any key]"
            keyBtn.TextColor3 = instance.Theme.Text
        end)

        local function stopListening(keyCode)
            listening = false
            picked = keyCode
            keyBtn.Text = "["..tostring(keyCode).."]"
            keyBtn.TextColor3 = instance.Theme.SubText
            if keyStorage then instance.Storage[keyStorage] = keyCode; instance:Save() end
        end

        -- listen for keypress
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                stopListening(input.KeyCode.Name)
            elseif input.UserInputType == Enum.UserInputType.Keyboard then
                -- if matches current picked, call
                if picked and input.KeyCode.Name == tostring(picked) then
                    if callback then callback() end
                end
            end
        end)

        return frame
    end

    -- Color Picker (simple H/S-like pick with preview)
    function instance:ColorPicker(tab, labelText, defaultColor, keyStorage, callback)
        defaultColor = defaultColor or Color3.fromRGB(255,100,100)
        local frame = Instance.new("Frame", tab.Page)
        frame.Size = UDim2.new(1,-16,0,56)
        frame.BackgroundColor3 = instance.Theme.Panel
        round(frame,8); stroke(frame,1)

        local label = Instance.new("TextLabel", frame)
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1,-120,0,20)
        label.Position = UDim2.new(0,8,0,4)
        label.Font = Enum.Font.Gotham
        label.TextSize = 15
        label.Text = labelText or "Color"
        label.TextColor3 = instance.Theme.Text
        label.TextXAlignment = Enum.TextXAlignment.Left

        local preview = Instance.new("Frame", frame)
        preview.Size = UDim2.new(0, 36, 0, 36)
        preview.Position = UDim2.new(1, -44, 0, 8)
        preview.BackgroundColor3 = defaultColor
        round(preview, 8); stroke(preview,1)

        local open = false
        local pickerPanel

        -- load saved color
        local saved = defaultColor
        if keyStorage and instance.Storage[keyStorage] then
            local sv = instance.Storage[keyStorage]
            if type(sv) == "table" then
                saved = Color3.new(sv.R, sv.G, sv.B)
            end
        end
        preview.BackgroundColor3 = saved

        local function openPicker()
            if open then return end
            open = true
            pickerPanel = Instance.new("Frame", frame)
            pickerPanel.Position = UDim2.new(0,0,1,8)
            pickerPanel.Size = UDim2.new(1,0,0,160)
            pickerPanel.BackgroundColor3 = instance.Theme.Panel
            round(pickerPanel,8); stroke(pickerPanel,1)

            -- Hue slider
            local hueLabel = Instance.new("TextLabel", pickerPanel)
            hueLabel.BackgroundTransparency = 1
            hueLabel.Size = UDim2.new(1, -16, 0, 18)
            hueLabel.Position = UDim2.new(0,8,0,8)
            hueLabel.Font = Enum.Font.Gotham
            hueLabel.TextSize = 13
            hueLabel.TextColor3 = instance.Theme.SubText
            hueLabel.Text = "Pick color"

            local hueBar = Instance.new("Frame", pickerPanel)
            hueBar.Size = UDim2.new(1,-16,0,16)
            hueBar.Position = UDim2.new(0,8,0,36)
            hueBar.BackgroundColor3 = Color3.fromRGB(60,60,60)
            round(hueBar,6)

            local currentColor = saved

            local dragging = false
            hueBar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            hueBar.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = hueBar.AbsolutePosition
                    local size = hueBar.AbsoluteSize
                    local rel = math.clamp((i.Position.X - pos.X) / size.X, 0, 1)
                    local color = Color3.fromHSV(rel, 1, 1)
                    currentColor = color
                    preview.BackgroundColor3 = color
                end
            end)

            -- confirm button
            local confirm = Instance.new("TextButton", pickerPanel)
            confirm.Size = UDim2.new(0, 96, 0, 28)
            confirm.Position = UDim2.new(1, -108, 1, -40)
            confirm.BackgroundColor3 = instance.Theme.Sidebar
            confirm.Text = "Confirm"
            confirm.Font = Enum.Font.Gotham
            confirm.TextSize = 14
            confirm.TextColor3 = instance.Theme.Text
            round(confirm,8); stroke(confirm,1)
            confirm.MouseButton1Click:Connect(function()
                if keyStorage then
                    instance.Storage[keyStorage] = {R=currentColor.R, G=currentColor.G, B=currentColor.B}
                    instance:Save()
                end
                if callback then callback(currentColor) end
                pickerPanel:Destroy()
                open = false
            end)
        end

        preview.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                openPicker()
            end
        end)

        return frame
    end

    -- Number box (manual numeric entry)
    function instance:NumberBox(tab, labelText, defaultNumber, key, callback)
        local frame = Instance.new("Frame", tab.Page)
        frame.Size = UDim2.new(1,-16,0,40)
        frame.BackgroundColor3 = instance.Theme.Panel
        round(frame,8); stroke(frame,1)

        local label = Instance.new("TextLabel", frame)
        label.BackgroundTransparency = 1
        label.Text = labelText or "Number"
        label.Font = Enum.Font.Gotham
        label.TextColor3 = instance.Theme.Text
        label.TextSize = 15
        label.Size = UDim2.new(0.6,0,1,0)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Position = UDim2.new(0,8,0,0)

        local box = Instance.new("TextBox", frame)
        box.Size = UDim2.new(0.34, -16, 0, 28)
        box.Position = UDim2.new(1, -box.Size.X.Offset - 8, 0.5, -14)
        box.Text = tostring(defaultNumber or "")
        box.Font = Enum.Font.Gotham
        box.TextSize = 14
        box.TextColor3 = instance.Theme.SubText
        box.BackgroundColor3 = Color3.fromRGB(60,60,60)
        box.ClearTextOnFocus = false
        round(box,6); stroke(box,1)
        box.TextXAlignment = Enum.TextXAlignment.Center

        box.FocusLost:Connect(function(enter)
            local v = tonumber(box.Text)
            if v then
                if key then instance.Storage[key] = v; instance:Save() end
                if callback then callback(v) end
            else
                -- restore previous
                if key and instance.Storage[key] then
                    box.Text = tostring(instance.Storage[key])
                else
                    box.Text = tostring(defaultNumber or "")
                end
            end
        end)

        return frame
    end

    -- Expose the main gui for advanced users
    instance._rootGui = sg
    instance._main = main
    instance._sidebar = sidebar
    instance._contentHolder = contentHolder

    -- Expose some API methods to instance
    instance.Notify = function(_, t, d) return Altura.Notify(instance, t, d) end
    instance.SetStorageKey = function(_, k) instance.SaveKey = k; instance:SetStorageKey(k) end
    instance.Save = function() instance:Save() end
    instance.Load = function() instance:Load() end
    instance.SetTheme = function(_,k,v) instance.Theme[k]=v end
    instance.GetTheme = function(_,k) return instance.Theme[k] end

    return instance
end

-- Expose top-level convenience functions
setmetatable(Altura, {
    __call = function(_, ...) return Altura.Create(Altura, ...) end
})

return Altura
