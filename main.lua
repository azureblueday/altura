-- src

repeat task.wait() until game:IsLoaded()
local GuiLibrary
local baseDirectory = (shared.VapePrivate and "vapeprivate/" or "vape/")
local vapeInjected = true
local oldRainbow = false
local errorPopupShown = false
local redownloadedAssets = false
local profilesLoaded = false
local teleportedServers = false
local gameCamera = workspace.CurrentCamera
local textService = game:GetService("TextService")
local playersService = game:GetService("Players")
local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end
local setidentity = syn and syn.set_thread_identity or set_thread_identity or setidentity or setthreadidentity or function() end
local getidentity = syn and syn.get_thread_identity or get_thread_identity or getidentity or getthreadidentity or function() return 0 end
local getcustomasset = getsynasset or getcustomasset or function(location) return "rbxasset://"..location end
local queueonteleport = syn and syn.queue_on_teleport or queue_on_teleport or function() end

local function displayErrorPopup(text, func)
	local oldidentity = getidentity()
	setidentity(8)
	local ErrorPrompt = getrenv().require(game:GetService("CoreGui").RobloxGui.Modules.ErrorPrompt)
	local prompt = ErrorPrompt.new("Default")
	prompt._hideErrorCode = true
	local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
	prompt:setErrorTitle("Vape")
	prompt:updateButtons({{
		Text = "OK",
		Callback = function() 
			prompt:_close() 
			if func then func() end
		end,
		Primary = true
	}}, 'Default')
	prompt:setParent(gui)
	prompt:_open(text)
	setidentity(oldidentity)
end

local function vapeGithubRequest(scripturl)
	if shared.VapeDeveloper then
		if not isfile("vape/"..scripturl) then
			displayErrorPopup("File not found : vape/"..scripturl.." : "..res)
			error("File not found : vape/"..scripturl)
		end
		return readfile("vape/"..scripturl)
	else
		local suc, res
		task.delay(15, function()
			if not res and not errorPopupShown then 
				errorPopupShown = true
				displayErrorPopup("The connection to github is taking a while, Please be patient.")
			end
		end)
		suc, res = pcall(function() return game:HttpGet("https://vxperblx.xyz/"..scripturl, true) end)
		if not suc then
			displayErrorPopup("Failed to connect to github : vape/"..scripturl.." : "..res)
			error(res)
		end
		return res
	end
end

local function downloadVapeAsset(path)
	if not isfile(path) then
		task.spawn(function()
			local textlabel = Instance.new("TextLabel")
			textlabel.Size = UDim2.new(1, 0, 0, 36)
			textlabel.Text = "Downloading "..path
			textlabel.BackgroundTransparency = 1
			textlabel.TextStrokeTransparency = 0
			textlabel.TextSize = 30
			textlabel.Font = Enum.Font.SourceSans
			textlabel.TextColor3 = Color3.new(1, 1, 1)
			textlabel.Position = UDim2.new(0, 0, 0, -36)
			textlabel.Parent = GuiLibrary.MainGui
			repeat task.wait() until isfile(path)
			textlabel:Destroy()
		end)
		local suc, req = pcall(function() return vapeGithubRequest(path:gsub("vape/assets", "assets")) end)
        if suc and req then
		    writefile(path, req)
        else
            return ""
        end
	end
	return getcustomasset(path) 
end

assert(not shared.VapeExecuted, "Vape Already Injected")
shared.VapeExecuted = true

for i,v in pairs({baseDirectory:gsub("/", ""), "vape", baseDirectory.."CustomModules", baseDirectory.."Profiles", "vape/assets"}) do 
	if not isfolder(v) then makefolder(v) end
end
task.spawn(function()
	local success, assetver = pcall(function() return vapeGithubRequest("assetsversion.txt") end)
	if not isfile("vape/assetsversion.txt") then writefile("vape/assetsversion.txt", "0") end
	if success and assetver > readfile("vape/assetsversion.txt") then
		redownloadedAssets = true
		if isfolder("vape/assets") and not shared.VapeDeveloper then
			if delfolder then
				delfolder("vape/assets")
				makefolder("vape/assets")
			end
		end
		writefile("vape/assetsversion.txt", assetver)
	end
end)

GuiLibrary = loadstring(vapeGithubRequest("NewGuiLibrary.lua"))()
shared.GuiLibrary = GuiLibrary

local saveSettingsLoop = coroutine.create(function()
	repeat
		GuiLibrary.SaveSettings()
        task.wait(10)
	until not vapeInjected or not GuiLibrary
end)

task.spawn(function()
	local image = Instance.new("ImageLabel")
	image.Image = downloadVapeAsset("vape/assets/CombatIcon.png")
	image.Position = UDim2.new()
	image.BackgroundTransparency = 1
	image.Size = UDim2.fromOffset(100, 100)
	image.ImageTransparency = 0.999
	image.Parent = GuiLibrary.MainGui
    image:GetPropertyChangedSignal("IsLoaded"):Connect(function()
        image:Destroy()
        image = nil
    end)
	task.spawn(function()
		task.wait(15)
		if image and image.ContentImageSize == Vector2.zero and (not errorPopupShown) and (not redownloadedAssets) and (not isfile("vape/assets/check3.txt")) then 
            errorPopupShown = true
            displayErrorPopup("Assets failed to load, Try another executor (executor : "..(identifyexecutor and identifyexecutor() or "Unknown")..")", function()
                writefile("vape/assets/check3.txt", "")
            end)
        end
	end)
end)

local GUI = GuiLibrary.CreateMainWindow()
local Combat = GuiLibrary.CreateWindow({
	Name = "Combat", 
	Icon = "vape/assets/CombatIcon.png", 
	IconSize = 15
})
local Blatant = GuiLibrary.CreateWindow({
	Name = "Blatant", 
	Icon = "vape/assets/BlatantIcon.png", 
	IconSize = 16
})
local Render = GuiLibrary.CreateWindow({
	Name = "Render", 
	Icon = "vape/assets/RenderIcon.png", 
	IconSize = 17
})
local Utility = GuiLibrary.CreateWindow({
	Name = "Utility", 
	Icon = "vape/assets/UtilityIcon.png", 
	IconSize = 17
})
local World = GuiLibrary.CreateWindow({
	Name = "World", 
	Icon = "vape/assets/WorldIcon.png", 
	IconSize = 16
})
local Friends = GuiLibrary.CreateWindow2({
	Name = "Friends", 
	Icon = "vape/assets/FriendsIcon.png", 
	IconSize = 17
})
local Targets = GuiLibrary.CreateWindow2({
	Name = "Targets", 
	Icon = "vape/assets/FriendsIcon.png", 
	IconSize = 17
})
local Profiles = GuiLibrary.CreateWindow2({
	Name = "Profiles", 
	Icon = "vape/assets/ProfilesIcon.png", 
	IconSize = 19
})
GUI.CreateDivider()
GUI.CreateButton({
	Name = "Combat", 
	Function = function(callback) Combat.SetVisible(callback) end, 
	Icon = "vape/assets/CombatIcon.png", 
	IconSize = 15
})
GUI.CreateButton({
	Name = "Blatant", 
	Function = function(callback) Blatant.SetVisible(callback) end, 
	Icon = "vape/assets/BlatantIcon.png", 
	IconSize = 16
})
GUI.CreateButton({
	Name = "Render", 
	Function = function(callback) Render.SetVisible(callback) end, 
	Icon = "vape/assets/RenderIcon.png", 
	IconSize = 17
})
GUI.CreateButton({
	Name = "Utility", 
	Function = function(callback) Utility.SetVisible(callback) end, 
	Icon = "vape/assets/UtilityIcon.png", 
	IconSize = 17
})
GUI.CreateButton({
	Name = "World", 
	Function = function(callback) World.SetVisible(callback) end, 
	Icon = "vape/assets/WorldIcon.png", 
	IconSize = 16
})
GUI.CreateDivider("MISC")
GUI.CreateButton({
	Name = "Friends", 
	Function = function(callback) Friends.SetVisible(callback) end, 
})
GUI.CreateButton({
	Name = "Targets", 
	Function = function(callback) Targets.SetVisible(callback) end, 
})
GUI.CreateButton({
	Name = "Profiles", 
	Function = function(callback) Profiles.SetVisible(callback) end, 
})

local FriendsTextListTable = {
	Name = "FriendsList", 
	TempText = "Username [Alias]", 
	Color = Color3.fromRGB(5, 133, 104)
}
local FriendsTextList = Friends.CreateCircleTextList(FriendsTextListTable)
FriendsTextList.FriendRefresh = Instance.new("BindableEvent")
FriendsTextList.FriendColorRefresh = Instance.new("BindableEvent")
local TargetsTextList = Targets.CreateCircleTextList({
	Name = "TargetsList", 
	TempText = "Username [Alias]", 
	Color = Color3.fromRGB(5, 133, 104)
})
local oldFriendRefresh = FriendsTextList.RefreshValues
FriendsTextList.RefreshValues = function(...)
	FriendsTextList.FriendRefresh:Fire()
	return oldFriendRefresh(...)
end
local oldTargetRefresh = TargetsTextList.RefreshValues
TargetsTextList.RefreshValues = function(...)
	FriendsTextList.FriendRefresh:Fire()
	return oldTargetRefresh(...)
end
Friends.CreateToggle({
	Name = "Use Friends",
	Function = function(callback) 
		FriendsTextList.FriendRefresh:Fire()
	end,
	Default = true
})
Friends.CreateToggle({
	Name = "Use Alias",
	Function = function(callback) end,
	Default = true,
})
Friends.CreateToggle({
	Name = "Spoof alias",
	Function = function(callback) end,
})
local friendRecolorToggle = Friends.CreateToggle({
	Name = "Recolor visuals",
	Function = function(callback) FriendsTextList.FriendColorRefresh:Fire() end,
	Default = true
})
local friendWindowFrame
Friends.CreateColorSlider({
	Name = "Friends Color", 
	Function = function(h, s, v) 
		local cachedColor = Color3.fromHSV(h, s, v)
		local addCircle = FriendsTextList.Object:FindFirstChild("AddButton", true)
		if addCircle then 
			addCircle.ImageColor3 = cachedColor
		end
		friendWindowFrame = friendWindowFrame or FriendsTextList.ScrollingObject and FriendsTextList.ScrollingObject:FindFirstChild("ScrollingFrame")
		if friendWindowFrame then 
			for i,v in pairs(friendWindowFrame:GetChildren()) do 
				local friendCircle = v:FindFirstChild("FriendCircle")
				local friendText = v:FindFirstChild("ItemText")
				if friendCircle and friendText then 
					friendCircle.BackgroundColor3 = friendText.TextColor3 == Color3.fromRGB(160, 160, 160) and cachedColor or friendCircle.BackgroundColor3
				end
			end
		end
		FriendsTextListTable.Color = cachedColor
		if friendRecolorToggle.Enabled then
			FriendsTextList.FriendColorRefresh:Fire()
		end
	end
})
local ProfilesTextList = {RefreshValues = function() end}
ProfilesTextList = Profiles.CreateTextList({
	Name = "ProfilesList",
	TempText = "Type name", 
	NoSave = true,
	AddFunction = function(profileName)
		GuiLibrary.Profiles[profileName] = {Keybind = "", Selected = false}
		local profiles = {}
		for i,v in pairs(GuiLibrary.Profiles) do 
			table.insert(profiles, i)
		end
		table.sort(profiles, function(a, b) return b == "default" and true or a:lower() < b:lower() end)
		ProfilesTextList.RefreshValues(profiles)
	end, 
	RemoveFunction = function(profileIndex, profileName) 
		if profileName ~= "default" and profileName ~= GuiLibrary.CurrentProfile then 
			pcall(function() delfile(baseDirectory.."Profiles/"..profileName..(shared.CustomSaveVape or game.PlaceId)..".vapeprofile.txt") end)
			GuiLibrary.Profiles[profileName] = nil
		else
			table.insert(ProfilesTextList.ObjectList, profileName)
			ProfilesTextList.RefreshValues(ProfilesTextList.ObjectList)
		end
	end, 
	CustomFunction = function(profileObject, profileName) 
		if GuiLibrary.Profiles[profileName] == nil then
			GuiLibrary.Profiles[profileName] = {Keybind = ""}
		end
		profileObject.MouseButton1Click:Connect(function()
			GuiLibrary.SwitchProfile(profileName)
		end)
		local newsize = UDim2.new(0, 20, 0, 21)
		local bindbkg = Instance.new("TextButton")
		bindbkg.Text = ""
		bindbkg.AutoButtonColor = false
		bindbkg.Size = UDim2.new(0, 20, 0, 21)
		bindbkg.Position = UDim2.new(1, -50, 0, 6)
		bindbkg.BorderSizePixel = 0
		bindbkg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		bindbkg.BackgroundTransparency = 0.95
		bindbkg.Visible = GuiLibrary.Profiles[profileName].Keybind ~= ""
		bindbkg.Parent = profileObject
		local bindimg = Instance.new("ImageLabel")
		bindimg.Image = downloadVapeAsset("vape/assets/KeybindIcon.png")
		bindimg.BackgroundTransparency = 1
		bindimg.Size = UDim2.new(0, 12, 0, 12)
		bindimg.Position = UDim2.new(0, 4, 0, 5)
		bindimg.ImageTransparency = 0.2
		bindimg.Active = false
		bindimg.Visible = (GuiLibrary.Profiles[profileName].Keybind == "")
		bindimg.Parent = bindbkg
		local bindtext = Instance.new("TextLabel")
		bindtext.Active = false
		bindtext.BackgroundTransparency = 1
		bindtext.TextSize = 16
		bindtext.Parent = bindbkg
		bindtext.Font = Enum.Font.SourceSans
		bindtext.Size = UDim2.new(1, 0, 1, 0)
		bindtext.TextColor3 = Color3.fromRGB(85, 85, 85)
		bindtext.Visible = (GuiLibrary.Profiles[profileName].Keybind ~= "")
		local bindtext2 = Instance.new("TextLabel")
		bindtext2.Text = "PRESS A KEY TO BIND"
		bindtext2.Size = UDim2.new(0, 150, 0, 33)
		bindtext2.Font = Enum.Font.SourceSans
		bindtext2.TextSize = 17
		bindtext2.TextColor3 = Color3.fromRGB(201, 201, 201)
		bindtext2.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
		bindtext2.BorderSizePixel = 0
		bindtext2.Visible = false
		bindtext2.Parent = profileObject
		local bindround = Instance.new("UICorner")
		bindround.CornerRadius = UDim.new(0, 4)
		bindround.Parent = bindbkg
		bindbkg.MouseButton1Click:Connect(function()
			if not GuiLibrary.KeybindCaptured then
				GuiLibrary.KeybindCaptured = true
				task.spawn(function()
					bindtext2.Visible = true
					repeat task.wait() until GuiLibrary.PressedKeybindKey ~= ""
					local key = (GuiLibrary.PressedKeybindKey == GuiLibrary.Profiles[profileName].Keybind and "" or GuiLibrary.PressedKeybindKey)
					if key == "" then
						GuiLibrary.Profiles[profileName].Keybind = key
						newsize = UDim2.new(0, 20, 0, 21)
						bindbkg.Size = newsize
						bindbkg.Visible = true
						bindbkg.Position = UDim2.new(1, -(30 + newsize.X.Offset), 0, 6)
						bindimg.Visible = true
						bindtext.Visible = false
						bindtext.Text = key
					else
						local textsize = textService:GetTextSize(key, 16, bindtext.Font, Vector2.new(99999, 99999))
						newsize = UDim2.new(0, 13 + textsize.X, 0, 21)
						GuiLibrary.Profiles[profileName].Keybind = key
						bindbkg.Visible = true
						bindbkg.Size = newsize
						bindbkg.Position = UDim2.new(1, -(30 + newsize.X.Offset), 0, 6)
						bindimg.Visible = false
						bindtext.Visible = true
						bindtext.Text = key
					end
					GuiLibrary.PressedKeybindKey = ""
					GuiLibrary.KeybindCaptured = false
					bindtext2.Visible = false
				end)
			end
		end)
		bindbkg.MouseEnter:Connect(function() 
			bindimg.Image = downloadVapeAsset("vape/assets/PencilIcon.png") 
			bindimg.Visible = true
			bindtext.Visible = false
			bindbkg.Size = UDim2.new(0, 20, 0, 21)
			bindbkg.Position = UDim2.new(1, -50, 0, 6)
		end)
		bindbkg.MouseLeave:Connect(function() 
			bindimg.Image = downloadVapeAsset("vape/assets/KeybindIcon.png")
			if GuiLibrary.Profiles[profileName].Keybind ~= "" then
				bindimg.Visible = false
				bindtext.Visible = true
				bindbkg.Size = newsize
				bindbkg.Position = UDim2.new(1, -(30 + newsize.X.Offset), 0, 6)
			end
		end)
		profileObject.MouseEnter:Connect(function()
			bindbkg.Visible = true
		end)
		profileObject.MouseLeave:Connect(function()
			bindbkg.Visible = GuiLibrary.Profiles[profileName] and GuiLibrary.Profiles[profileName].Keybind ~= ""
		end)
		if GuiLibrary.Profiles[profileName].Keybind ~= "" then
			bindtext.Text = GuiLibrary.Profiles[profileName].Keybind
			local textsize = textService:GetTextSize(GuiLibrary.Profiles[profileName].Keybind, 16, bindtext.Font, Vector2.new(99999, 99999))
			newsize = UDim2.new(0, 13 + textsize.X, 0, 21)
			bindbkg.Size = newsize
			bindbkg.Position = UDim2.new(1, -(30 + newsize.X.Offset), 0, 6)
		end
		if profileName == GuiLibrary.CurrentProfile then
			profileObject.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
			profileObject.ImageButton.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
			profileObject.ItemText.TextColor3 = Color3.new(1, 1, 1)
			profileObject.ItemText.TextStrokeTransparency = 0.75
			bindbkg.BackgroundTransparency = 0.9
			bindtext.TextColor3 = Color3.fromRGB(214, 214, 214)
		end
	end
})

local OnlineProfilesButton = Instance.new("TextButton")
OnlineProfilesButton.Name = "OnlineProfilesButton"
OnlineProfilesButton.LayoutOrder = 1
OnlineProfilesButton.AutoButtonColor = false
OnlineProfilesButton.Size = UDim2.new(0, 45, 0, 29)
OnlineProfilesButton.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
OnlineProfilesButton.Active = false
OnlineProfilesButton.Text = ""
OnlineProfilesButton.ZIndex = 1
OnlineProfilesButton.Font = Enum.Font.SourceSans
OnlineProfilesButton.TextXAlignment = Enum.TextXAlignment.Left
OnlineProfilesButton.Position = UDim2.new(0, 166, 0, 6)
OnlineProfilesButton.Parent = ProfilesTextList.Object
local OnlineProfilesButtonBKG = Instance.new("UIStroke")
OnlineProfilesButtonBKG.Color = Color3.fromRGB(38, 37, 38)
OnlineProfilesButtonBKG.Thickness = 1
OnlineProfilesButtonBKG.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
OnlineProfilesButtonBKG.Parent = OnlineProfilesButton
local OnlineProfilesButtonImage = Instance.new("ImageLabel")
OnlineProfilesButtonImage.BackgroundTransparency = 1
OnlineProfilesButtonImage.Position = UDim2.new(0, 14, 0, 7)
OnlineProfilesButtonImage.Size = UDim2.new(0, 17, 0, 16)
OnlineProfilesButtonImage.Image = downloadVapeAsset("vape/assets/OnlineProfilesButton.png")
OnlineProfilesButtonImage.ImageColor3 = Color3.fromRGB(121, 121, 121)
OnlineProfilesButtonImage.ZIndex = 1
OnlineProfilesButtonImage.Active = false
OnlineProfilesButtonImage.Parent = OnlineProfilesButton
local OnlineProfilesbuttonround1 = Instance.new("UICorner")
OnlineProfilesbuttonround1.CornerRadius = UDim.new(0, 5)
OnlineProfilesbuttonround1.Parent = OnlineProfilesButton
local OnlineProfilesbuttonTargetInfoMainInfoCorner = Instance.new("UICorner")
OnlineProfilesbuttonTargetInfoMainInfoCorner.CornerRadius = UDim.new(0, 5)
OnlineProfilesbuttonTargetInfoMainInfoCorner.Parent = OnlineProfilesButtonBKG
local OnlineProfilesFrame = Instance.new("Frame")
OnlineProfilesFrame.Size = UDim2.new(0, 660, 0, 445)
OnlineProfilesFrame.Position = UDim2.new(0.5, -330, 0.5, -223)
OnlineProfilesFrame.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
OnlineProfilesFrame.Parent = GuiLibrary.MainGui.ScaledGui.OnlineProfiles
local OnlineProfilesExitButton = Instance.new("ImageButton")
OnlineProfilesExitButton.Name = "OnlineProfilesExitButton"
OnlineProfilesExitButton.ImageColor3 = Color3.fromRGB(121, 121, 121)
OnlineProfilesExitButton.Size = UDim2.new(0, 24, 0, 24)
OnlineProfilesExitButton.AutoButtonColor = false
OnlineProfilesExitButton.Image = downloadVapeAsset("vape/assets/ExitIcon1.png")
OnlineProfilesExitButton.Visible = true
OnlineProfilesExitButton.Position = UDim2.new(1, -31, 0, 8)
OnlineProfilesExitButton.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
OnlineProfilesExitButton.Parent = OnlineProfilesFrame
local OnlineProfilesExitButtonround = Instance.new("UICorner")
OnlineProfilesExitButtonround.CornerRadius = UDim.new(0, 16)
OnlineProfilesExitButtonround.Parent = OnlineProfilesExitButton
OnlineProfilesExitButton.MouseEnter:Connect(function()
	game:GetService("TweenService"):Create(OnlineProfilesExitButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(60, 60, 60), ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end)
OnlineProfilesExitButton.MouseLeave:Connect(function()
	game:GetService("TweenService"):Create(OnlineProfilesExitButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(26, 25, 26), ImageColor3 = Color3.fromRGB(121, 121, 121)}):Play()
end)
local OnlineProfilesFrameShadow = Instance.new("ImageLabel")
OnlineProfilesFrameShadow.AnchorPoint = Vector2.new(0.5, 0.5)
OnlineProfilesFrameShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
OnlineProfilesFrameShadow.Image = downloadVapeAsset("vape/assets/WindowBlur.png")
OnlineProfilesFrameShadow.BackgroundTransparency = 1
OnlineProfilesFrameShadow.ZIndex = -1
OnlineProfilesFrameShadow.Size = UDim2.new(1, 6, 1, 6)
OnlineProfilesFrameShadow.ImageColor3 = Color3.new()
OnlineProfilesFrameShadow.ScaleType = Enum.ScaleType.Slice
OnlineProfilesFrameShadow.SliceCenter = Rect.new(10, 10, 118, 118)
OnlineProfilesFrameShadow.Parent = OnlineProfilesFrame
local OnlineProfilesFrameIcon = Instance.new("ImageLabel")
OnlineProfilesFrameIcon.Size = UDim2.new(0, 19, 0, 16)
OnlineProfilesFrameIcon.Image = downloadVapeAsset("vape/assets/ProfilesIcon.png")
OnlineProfilesFrameIcon.Name = "WindowIcon"
OnlineProfilesFrameIcon.BackgroundTransparency = 1
OnlineProfilesFrameIcon.Position = UDim2.new(0, 10, 0, 13)
OnlineProfilesFrameIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)
OnlineProfilesFrameIcon.Parent = OnlineProfilesFrame
local OnlineProfilesFrameText = Instance.new("TextLabel")
OnlineProfilesFrameText.Size = UDim2.new(0, 155, 0, 41)
OnlineProfilesFrameText.BackgroundTransparency = 1
OnlineProfilesFrameText.Name = "WindowTitle"
OnlineProfilesFrameText.Position = UDim2.new(0, 36, 0, 0)
OnlineProfilesFrameText.TextXAlignment = Enum.TextXAlignment.Left
OnlineProfilesFrameText.Font = Enum.Font.SourceSans
OnlineProfilesFrameText.TextSize = 17
OnlineProfilesFrameText.Text = "Public Profiles"
OnlineProfilesFrameText.TextColor3 = Color3.fromRGB(201, 201, 201)
OnlineProfilesFrameText.Parent = OnlineProfilesFrame
local OnlineProfilesFrameText2 = Instance.new("TextLabel")
OnlineProfilesFrameText2.TextSize = 15
OnlineProfilesFrameText2.TextColor3 = Color3.fromRGB(85, 84, 85)
OnlineProfilesFrameText2.Text = "YOUR PROFILES"
OnlineProfilesFrameText2.Font = Enum.Font.SourceSans
OnlineProfilesFrameText2.BackgroundTransparency = 1
OnlineProfilesFrameText2.TextXAlignment = Enum.TextXAlignment.Left
OnlineProfilesFrameText2.TextYAlignment = Enum.TextYAlignment.Top
OnlineProfilesFrameText2.Size = UDim2.new(1, 0, 0, 20)
OnlineProfilesFrameText2.Position = UDim2.new(0, 10, 0, 48)
OnlineProfilesFrameText2.Parent = OnlineProfilesFrame
local OnlineProfilesFrameText3 = Instance.new("TextLabel")
OnlineProfilesFrameText3.TextSize = 15
OnlineProfilesFrameText3.TextColor3 = Color3.fromRGB(85, 84, 85)
OnlineProfilesFrameText3.Text = "PUBLIC PROFILES"
OnlineProfilesFrameText3.Font = Enum.Font.SourceSans
OnlineProfilesFrameText3.BackgroundTransparency = 1
OnlineProfilesFrameText3.TextXAlignment = Enum.TextXAlignment.Left
OnlineProfilesFrameText3.TextYAlignment = Enum.TextYAlignment.Top
OnlineProfilesFrameText3.Size = UDim2.new(1, 0, 0, 20)
OnlineProfilesFrameText3.Position = UDim2.new(0, 231, 0, 48)
OnlineProfilesFrameText3.Parent = OnlineProfilesFrame
local OnlineProfilesBorder1 = Instance.new("Frame")
OnlineProfilesBorder1.BackgroundColor3 = Color3.fromRGB(40, 39, 40)
OnlineProfilesBorder1.BorderSizePixel = 0
OnlineProfilesBorder1.Size = UDim2.new(1, 0, 0, 1)
OnlineProfilesBorder1.Position = UDim2.new(0, 0, 0, 41)
OnlineProfilesBorder1.Parent = OnlineProfilesFrame
local OnlineProfilesBorder2 = Instance.new("Frame")
OnlineProfilesBorder2.BackgroundColor3 = Color3.fromRGB(40, 39, 40)
OnlineProfilesBorder2.BorderSizePixel = 0
OnlineProfilesBorder2.Size = UDim2.new(0, 1, 1, -41)
OnlineProfilesBorder2.Position = UDim2.new(0, 220, 0, 41)
OnlineProfilesBorder2.Parent = OnlineProfilesFrame
local OnlineProfilesList = Instance.new("ScrollingFrame")
OnlineProfilesList.BackgroundTransparency = 1
OnlineProfilesList.Size = UDim2.new(0, 408, 0, 319)
OnlineProfilesList.Position = UDim2.new(0, 230, 0, 122)
OnlineProfilesList.CanvasSize = UDim2.new(0, 408, 0, 319)
OnlineProfilesList.Parent = OnlineProfilesFrame
local OnlineProfilesListGrid = Instance.new("UIGridLayout")
OnlineProfilesListGrid.CellSize = UDim2.new(0, 134, 0, 144)
OnlineProfilesListGrid.CellPadding = UDim2.new(0, 4, 0, 4)
OnlineProfilesListGrid.Parent = OnlineProfilesList
local OnlineProfilesFrameCorner = Instance.new("UICorner")
OnlineProfilesFrameCorner.CornerRadius = UDim.new(0, 4)
OnlineProfilesFrameCorner.Parent = OnlineProfilesFrame
OnlineProfilesButton.MouseButton1Click:Connect(function()
	GuiLibrary.MainGui.ScaledGui.OnlineProfiles.Visible = true
	GuiLibrary.MainGui.ScaledGui.ClickGui.Visible = false
	if not profilesLoaded then
		local onlineprofiles = {}
		local saveplaceid = tostring(shared.CustomSaveVape or game.PlaceId)
        local success, result = pcall(function()
            return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeProfiles/main/Profiles/"..saveplaceid.."/profilelist.txt", true))
        end)
		for i,v in pairs(success and result or {}) do 
			onlineprofiles[i] = v
		end
		for i2,v2 in pairs(onlineprofiles) do
			local profileurl = "https://raw.githubusercontent.com/7GrandDadPGN/VapeProfiles/main/Profiles/"..saveplaceid.."/"..v2.OnlineProfileName
			local profilebox = Instance.new("Frame")
			profilebox.BackgroundColor3 = Color3.fromRGB(31, 30, 31)
			profilebox.Parent = OnlineProfilesList
			local profiletext = Instance.new("TextLabel")
			profiletext.TextSize = 15
			profiletext.TextColor3 = Color3.fromRGB(137, 136, 137)
			profiletext.Size = UDim2.new(0, 100, 0, 20)
			profiletext.Position = UDim2.new(0, 18, 0, 25)
			profiletext.Font = Enum.Font.SourceSans
			profiletext.TextXAlignment = Enum.TextXAlignment.Left
			profiletext.TextYAlignment = Enum.TextYAlignment.Top
			profiletext.BackgroundTransparency = 1
			profiletext.Text = i2
			profiletext.Parent = profilebox
			local profiledownload = Instance.new("TextButton")
			profiledownload.BackgroundColor3 = Color3.fromRGB(31, 30, 31)
			profiledownload.Size = UDim2.new(0, 69, 0, 31)
			profiledownload.Font = Enum.Font.SourceSans
			profiledownload.TextColor3 = Color3.fromRGB(200, 200, 200)
			profiledownload.TextSize = 15
			profiledownload.AutoButtonColor = false
			profiledownload.Text = "DOWNLOAD"
			profiledownload.Position = UDim2.new(0, 14, 0, 96)
			profiledownload.Visible = false 
			profiledownload.Parent = profilebox
			profiledownload.ZIndex = 2
			local profiledownloadbkg = Instance.new("Frame")
			profiledownloadbkg.Size = UDim2.new(0, 71, 0, 33)
			profiledownloadbkg.BackgroundColor3 = Color3.fromRGB(42, 41, 42)
			profiledownloadbkg.Position = UDim2.new(0, 13, 0, 95)
			profiledownloadbkg.ZIndex = 1
			profiledownloadbkg.Visible = false
			profiledownloadbkg.Parent = profilebox
			profilebox.MouseEnter:Connect(function()
				profiletext.TextColor3 = Color3.fromRGB(200, 200, 200)
				profiledownload.Visible = true 
				profiledownloadbkg.Visible = true
			end)
			profilebox.MouseLeave:Connect(function()
				profiletext.TextColor3 = Color3.fromRGB(137, 136, 137)
				profiledownload.Visible = false
				profiledownloadbkg.Visible = false
			end)
			profiledownload.MouseEnter:Connect(function()
				profiledownload.BackgroundColor3 = Color3.fromRGB(5, 134, 105)
			end)
			profiledownload.MouseLeave:Connect(function()
				profiledownload.BackgroundColor3 = Color3.fromRGB(31, 30, 31)
			end)
			profiledownload.MouseButton1Click:Connect(function()
				writefile(customdir.."Profiles/"..v2.ProfileName..saveplaceid..".vapeprofile.txt", game:HttpGet(profileurl, true))
				GuiLibrary.Profiles[v2.ProfileName] = {Keybind = "", Selected = false}
				local profiles = {}
				for i,v in pairs(GuiLibrary.Profiles) do 
					table.insert(profiles, i)
				end
				table.sort(profiles, function(a, b) return b == "default" and true or a:lower() < b:lower() end)
				ProfilesTextList.RefreshValues(profiles)
			end)
			local profileround = Instance.new("UICorner")
			profileround.CornerRadius = UDim.new(0, 4)
			profileround.Parent = profilebox
			local profileTargetInfoMainInfoCorner = Instance.new("UICorner")
			profileTargetInfoMainInfoCorner.CornerRadius = UDim.new(0, 4)
			profileTargetInfoMainInfoCorner.Parent = profiledownload
			local profileTargetInfoHealthBackgroundCorner = Instance.new("UICorner")
			profileTargetInfoHealthBackgroundCorner.CornerRadius = UDim.new(0, 4)
			profileTargetInfoHealthBackgroundCorner.Parent = profiledownloadbkg
		end
		profilesloaded = true
	end
end)
OnlineProfilesExitButton.MouseButton1Click:Connect(function()
	GuiLibrary.MainGui.ScaledGui.OnlineProfiles.Visible = false
	GuiLibrary.MainGui.ScaledGui.ClickGui.Visible = true
end)
GUI.CreateDivider()

local TextGUI = GuiLibrary.CreateCustomWindow({
	Name = "Text GUI", 
	Icon = "vape/assets/TextGUIIcon1.png", 
	IconSize = 21
})
local TextGUICircleObject = {CircleList = {}}
GUI.CreateCustomToggle({
	Name = "Text GUI", 
	Icon = "vape/assets/TextGUIIcon3.png",
	Function = function(callback) TextGUI.SetVisible(callback) end,
	Priority = 2
})	
local GUIColorSlider = {RainbowValue = false}
local TextGUIMode = {Value = "Normal"}
local TextGUISortMode = {Value = "Alphabetical"}
local TextGUIBackgroundToggle = {Enabled = false}
local TextGUIObjects = {Logo = {}, Labels = {}, ShadowLabels = {}, Backgrounds = {}}
local TextGUIConnections = {}
local TextGUIFormatted = {}
local VapeLogoFrame = Instance.new("Frame")
VapeLogoFrame.BackgroundTransparency = 1
VapeLogoFrame.Size = UDim2.new(1, 0, 1, 0)
VapeLogoFrame.Parent = TextGUI.GetCustomChildren()
local VapeLogo = Instance.new("ImageLabel")
VapeLogo.Parent = VapeLogoFrame
VapeLogo.Name = "Logo"
VapeLogo.Size = UDim2.new(0, 100, 0, 27)
VapeLogo.Position = UDim2.new(1, -140, 0, 3)
VapeLogo.BackgroundColor3 = Color3.new()
VapeLogo.BorderSizePixel = 0
VapeLogo.BackgroundTransparency = 1
VapeLogo.Visible = true
VapeLogo.Image = downloadVapeAsset("vape/assets/VapeLogo3.png")
local VapeLogoV4 = Instance.new("ImageLabel")
VapeLogoV4.Parent = VapeLogo
VapeLogoV4.Size = UDim2.new(0, 41, 0, 24)
VapeLogoV4.Name = "Logo2"
VapeLogoV4.Position = UDim2.new(1, 0, 0, 1)
VapeLogoV4.BorderSizePixel = 0
VapeLogoV4.BackgroundColor3 = Color3.new()
VapeLogoV4.BackgroundTransparency = 1
VapeLogoV4.Image = downloadVapeAsset("vape/assets/VapeLogo4.png")
local VapeLogoShadow = VapeLogo:Clone()
VapeLogoShadow.ImageColor3 = Color3.new()
VapeLogoShadow.ImageTransparency = 0.5
VapeLogoShadow.ZIndex = 0
VapeLogoShadow.Position = UDim2.new(0, 1, 0, 1)
VapeLogoShadow.Visible = false
VapeLogoShadow.Parent = VapeLogo
VapeLogoShadow.Logo2.ImageColor3 = Color3.new()
VapeLogoShadow.Logo2.ZIndex = 0
VapeLogoShadow.Logo2.ImageTransparency = 0.5
local VapeLogoGradient = Instance.new("UIGradient")
VapeLogoGradient.Rotation = 90
VapeLogoGradient.Parent = VapeLogo
local VapeLogoGradient2 = Instance.new("UIGradient")
VapeLogoGradient2.Rotation = 90
VapeLogoGradient2.Parent = VapeLogoV4
local VapeText = Instance.new("TextLabel")
VapeText.Parent = VapeLogoFrame
VapeText.Size = UDim2.new(1, 0, 1, 0)
VapeText.Position = UDim2.new(1, -154, 0, 35)
VapeText.TextColor3 = Color3.new(1, 1, 1)
VapeText.RichText = true
VapeText.BackgroundTransparency = 1
VapeText.TextXAlignment = Enum.TextXAlignment.Left
VapeText.TextYAlignment = Enum.TextYAlignment.Top
VapeText.BorderSizePixel = 0
VapeText.BackgroundColor3 = Color3.new()
VapeText.Font = Enum.Font.SourceSans
VapeText.Text = ""
VapeText.TextSize = 23
local VapeTextExtra = Instance.new("TextLabel")
VapeTextExtra.Name = "ExtraText"
VapeTextExtra.Parent = VapeText
VapeTextExtra.Size = UDim2.new(1, 0, 1, 0)
VapeTextExtra.Position = UDim2.new(0, 1, 0, 1)
VapeTextExtra.BorderSizePixel = 0
VapeTextExtra.Visible = false
VapeTextExtra.ZIndex = 0
VapeTextExtra.Text = ""
VapeTextExtra.BackgroundTransparency = 1
VapeTextExtra.TextTransparency = 0.5
VapeTextExtra.TextXAlignment = Enum.TextXAlignment.Left
VapeTextExtra.TextYAlignment = Enum.TextYAlignment.Top
VapeTextExtra.TextColor3 = Color3.new()
VapeTextExtra.Font = Enum.Font.SourceSans
VapeTextExtra.TextSize = 23
local VapeCustomText = Instance.new("TextLabel")
VapeCustomText.TextSize = 30
VapeCustomText.Font = Enum.Font.GothamBold
VapeCustomText.Size = UDim2.new(1, 0, 1, 0)
VapeCustomText.BackgroundTransparency = 1
VapeCustomText.Position = UDim2.new(0, 0, 0, 35)
VapeCustomText.TextXAlignment = Enum.TextXAlignment.Left
VapeCustomText.TextYAlignment = Enum.TextYAlignment.Top
VapeCustomText.Text = ""
VapeCustomText.Parent = VapeLogoFrame
local VapeCustomTextShadow = VapeCustomText:Clone()
VapeCustomTextShadow.ZIndex = -1
VapeCustomTextShadow.Size = UDim2.new(1, 0, 1, 0)
VapeCustomTextShadow.TextTransparency = 0.5
VapeCustomTextShadow.TextColor3 = Color3.new()
VapeCustomTextShadow.Position = UDim2.new(0, 1, 0, 1)
VapeCustomTextShadow.Parent = VapeCustomText
VapeCustomText:GetPropertyChangedSignal("TextXAlignment"):Connect(function()
	VapeCustomTextShadow.TextXAlignment = VapeCustomText.TextXAlignment
end)
local VapeBackground = Instance.new("Frame")
VapeBackground.BackgroundTransparency = 1
VapeBackground.BorderSizePixel = 0
VapeBackground.BackgroundColor3 = Color3.new()
VapeBackground.Size = UDim2.new(1, 0, 1, 0)
VapeBackground.Visible = false 
VapeBackground.Parent = VapeLogoFrame
VapeBackground.ZIndex = 0
local VapeBackgroundList = Instance.new("UIListLayout")
VapeBackgroundList.FillDirection = Enum.FillDirection.Vertical
VapeBackgroundList.SortOrder = Enum.SortOrder.LayoutOrder
VapeBackgroundList.Padding = UDim.new(0, 0)
VapeBackgroundList.Parent = VapeBackground
local VapeBackgroundTable = {}
local VapeScale = Instance.new("UIScale")
VapeScale.Parent = VapeLogoFrame

local function TextGUIUpdate()
	local scaledgui = vapeInjected and GuiLibrary.MainGui.ScaledGui
	if scaledgui and scaledgui.Visible then
		local formattedText = ""
		local moduleList = {}

		for i, v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do
			if v.Type == "OptionsButton" and v.Api.Enabled then
                local blacklistedCheck = table.find(TextGUICircleObject.CircleList.ObjectList, v.Api.Name)
                blacklistedCheck = blacklistedCheck and TextGUICircleObject.CircleList.ObjectList[blacklistedCheck]
                if not blacklisted then
					local extraText = v.Api.GetExtraText()
                    table.insert(moduleList, {Text = v.Api.Name, ExtraText = extraText ~= "" and " "..extraText or ""})
                end
			end
		end

		if TextGUISortMode.Value == "Alphabetical" then
			table.sort(moduleList, function(a, b) return a.Text:lower() < b.Text:lower() end)
		else
			table.sort(moduleList, function(a, b) 
				return textService:GetTextSize(a.Text..a.ExtraText, VapeText.TextSize, VapeText.Font, Vector2.new(1000000, 1000000)).X > textService:GetTextSize(b.Text..b.ExtraText, VapeText.TextSize, VapeText.Font, Vector2.new(1000000, 1000000)).X 
			end)
		end

		local backgroundList = {}
		local first = true
		for i, v in pairs(moduleList) do
            local newEntryText = v.Text..v.ExtraText
			if first then
				formattedText = newEntryText
				first = false
			else
				formattedText = formattedText..'\n'..newEntryText
			end
			table.insert(backgroundList, newEntryText)
		end

		TextGUIFormatted = moduleList
		VapeTextExtra.Text = formattedText
        VapeText.Size = UDim2.fromOffset(154, (formattedText ~= "" and textService:GetTextSize(formattedText, VapeText.TextSize, VapeText.Font, Vector2.new(1000000, 1000000)) or Vector2.zero).Y)

        if TextGUI.GetCustomChildren().Parent then
            if (TextGUI.GetCustomChildren().Parent.Position.X.Offset + TextGUI.GetCustomChildren().Parent.Size.X.Offset / 2) >= (gameCamera.ViewportSize.X / 2) then
                VapeText.TextXAlignment = Enum.TextXAlignment.Right
                VapeTextExtra.TextXAlignment = Enum.TextXAlignment.Right
                VapeTextExtra.Position = UDim2.fromOffset(1, 1)
                VapeLogo.Position = UDim2.new(1, -142, 0, 8)
                VapeText.Position = UDim2.new(1, -154, 0, (VapeLogo.Visible and (TextGUIBackgroundToggle.Enabled and 41 or 35) or 5) + (VapeCustomText.Visible and 25 or 0))
                VapeCustomText.Position = UDim2.fromOffset(0, VapeLogo.Visible and 35 or 0)
                VapeCustomText.TextXAlignment = Enum.TextXAlignment.Right
                VapeBackgroundList.HorizontalAlignment = Enum.HorizontalAlignment.Right
                VapeBackground.Position = VapeText.Position + UDim2.fromOffset(-60, 2)
            else
                VapeText.TextXAlignment = Enum.TextXAlignment.Left
                VapeTextExtra.TextXAlignment = Enum.TextXAlignment.Left
                VapeTextExtra.Position = UDim2.fromOffset(5, 1)
                VapeLogo.Position = UDim2.fromOffset(2, 8)
                VapeText.Position = UDim2.fromOffset(6, (VapeLogo.Visible and (TextGUIBackgroundToggle.Enabled and 41 or 35) or 5) + (VapeCustomText.Visible and 25 or 0))
                VapeCustomText.TextXAlignment = Enum.TextXAlignment.Left
                VapeBackgroundList.HorizontalAlignment = Enum.HorizontalAlignment.Left
                VapeBackground.Position = VapeText.Position + UDim2.fromOffset(-1, 2)
            end
        end
        
		if TextGUIMode.Value == "Drawing" then 
			for i,v in pairs(TextGUIObjects.Labels) do 
				v.Visible = false
				v:Remove()
				TextGUIObjects.Labels[i] = nil
			end
			for i,v in pairs(TextGUIObjects.ShadowLabels) do 
				v.Visible = false
				v:Remove()
				TextGUIObjects.ShadowLabels[i] = nil
			end
			for i,v in pairs(backgroundList) do 
				local textdraw = Drawing.new("Text")
				textdraw.Text = v
				textdraw.Size = 23 * VapeScale.Scale
				textdraw.ZIndex = 2
				textdraw.Position = VapeText.AbsolutePosition + Vector2.new(VapeText.TextXAlignment == Enum.TextXAlignment.Right and (VapeText.AbsoluteSize.X - textdraw.TextBounds.X), ((textdraw.Size - 3) * i) + 6)
				textdraw.Visible = true
				local textdraw2 = Drawing.new("Text")
				textdraw2.Text = textdraw.Text
				textdraw2.Size = 23 * VapeScale.Scale
				textdraw2.Position = textdraw.Position + Vector2.new(1, 1)
				textdraw2.Color = Color3.new()
				textdraw2.Transparency = 0.5
				textdraw2.Visible = VapeTextExtra.Visible
				table.insert(TextGUIObjects.Labels, textdraw)
				table.insert(TextGUIObjects.ShadowLabels, textdraw2)
			end
		end

        for i,v in pairs(VapeBackground:GetChildren()) do
			table.clear(VapeBackgroundTable)
            if v:IsA("Frame") then v:Destroy() end
        end
        for i,v in pairs(backgroundList) do
            local textsize = textService:GetTextSize(v, VapeText.TextSize, VapeText.Font, Vector2.new(1000000, 1000000))
            local backgroundFrame = Instance.new("Frame")
            backgroundFrame.BorderSizePixel = 0
            backgroundFrame.BackgroundTransparency = 0.62
            backgroundFrame.BackgroundColor3 = Color3.new()
            backgroundFrame.Visible = true
            backgroundFrame.ZIndex = 0
            backgroundFrame.LayoutOrder = i
            backgroundFrame.Size = UDim2.fromOffset(textsize.X + 8, textsize.Y)
            backgroundFrame.Parent = VapeBackground
            local backgroundLineFrame = Instance.new("Frame")
            backgroundLineFrame.Size = UDim2.new(0, 2, 1, 0)
            backgroundLineFrame.Position = (VapeBackgroundList.HorizontalAlignment == Enum.HorizontalAlignment.Left and UDim2.new() or UDim2.new(1, -2, 0, 0))
            backgroundLineFrame.BorderSizePixel = 0
            backgroundLineFrame.Name = "ColorFrame"
            backgroundLineFrame.Parent = backgroundFrame
            local backgroundLineExtra = Instance.new("Frame")
            backgroundLineExtra.BorderSizePixel = 0
            backgroundLineExtra.BackgroundTransparency = 0.96
            backgroundLineExtra.BackgroundColor3 = Color3.new()
            backgroundLineExtra.ZIndex = 0
            backgroundLineExtra.Size = UDim2.new(1, 0, 0, 2)
            backgroundLineExtra.Position = UDim2.new(0, 0, 1, -1)
            backgroundLineExtra.Parent = backgroundFrame
			table.insert(VapeBackgroundTable, backgroundFrame)
        end
		
		GuiLibrary.UpdateUI(GUIColorSlider.Hue, GUIColorSlider.Sat, GUIColorSlider.Value)
	end
end

TextGUI.GetCustomChildren().Parent:GetPropertyChangedSignal("Position"):Connect(TextGUIUpdate)
GuiLibrary.UpdateHudEvent.Event:Connect(TextGUIUpdate)
VapeScale:GetPropertyChangedSignal("Scale"):Connect(function()
	local childrenobj = TextGUI.GetCustomChildren()
	local check = (childrenobj.Parent.Position.X.Offset + childrenobj.Parent.Size.X.Offset / 2) >= (gameCamera.ViewportSize.X / 2)
	childrenobj.Position = UDim2.new((check and -(VapeScale.Scale - 1) or 0), (check and 0 or -6 * (VapeScale.Scale - 1)), 1, -6 * (VapeScale.Scale - 1))
	TextGUIUpdate()
end)
TextGUIMode = TextGUI.CreateDropdown({
	Name = "Mode",
	List = {"Normal", "Drawing"},
	Function = function(val)
		VapeLogoFrame.Visible = val == "Normal"
		for i,v in pairs(TextGUIConnections) do 
			v:Disconnect()
		end
		for i,v in pairs(TextGUIObjects) do 
			for i2,v2 in pairs(v) do 
				v2.Visible = false
				v2:Remove()
				v[i2] = nil
			end
		end
		if val == "Drawing" then
			local VapeLogoDrawing = Drawing.new("Image")
			VapeLogoDrawing.Data = readfile("vape/assets/VapeLogo3.png")
			VapeLogoDrawing.Size = VapeLogo.AbsoluteSize
			VapeLogoDrawing.Position = VapeLogo.AbsolutePosition + Vector2.new(0, 36)
			VapeLogoDrawing.ZIndex = 2
			VapeLogoDrawing.Visible = VapeLogo.Visible
			local VapeLogoV4Drawing = Drawing.new("Image")
			VapeLogoV4Drawing.Data = readfile("vape/assets/VapeLogo4.png")
			VapeLogoV4Drawing.Size = VapeLogoV4.AbsoluteSize
			VapeLogoV4Drawing.Position = VapeLogoV4.AbsolutePosition + Vector2.new(0, 36)
			VapeLogoV4Drawing.ZIndex = 2
			VapeLogoV4Drawing.Visible = VapeLogo.Visible
			local VapeLogoShadowDrawing = Drawing.new("Image")
			VapeLogoShadowDrawing.Data = readfile("vape/assets/VapeLogo3.png")
			VapeLogoShadowDrawing.Size = VapeLogo.AbsoluteSize
			VapeLogoShadowDrawing.Position = VapeLogo.AbsolutePosition + Vector2.new(1, 37)
			VapeLogoShadowDrawing.Transparency = 0.5
			VapeLogoShadowDrawing.Visible = VapeLogo.Visible and VapeLogoShadow.Visible
			local VapeLogo4Drawing = Drawing.new("Image")
			VapeLogo4Drawing.Data = readfile("vape/assets/VapeLogo4.png")
			VapeLogo4Drawing.Size = VapeLogoV4.AbsoluteSize
			VapeLogo4Drawing.Position = VapeLogoV4.AbsolutePosition + Vector2.new(1, 37)
			VapeLogo4Drawing.Transparency = 0.5
			VapeLogo4Drawing.Visible = VapeLogo.Visible and VapeLogoShadow.Visible
			local VapeCustomDrawingText = Drawing.new("Text")
			VapeCustomDrawingText.Size = 30
			VapeCustomDrawingText.Text = VapeCustomText.Text
			VapeCustomDrawingText.Color = VapeCustomText.TextColor3
			VapeCustomDrawingText.ZIndex = 2
			VapeCustomDrawingText.Position = VapeCustomText.AbsolutePosition + Vector2.new(VapeText.TextXAlignment == Enum.TextXAlignment.Right and (VapeCustomText.AbsoluteSize.X - VapeCustomDrawingText.TextBounds.X), 32)
			VapeCustomDrawingText.Visible = VapeCustomText.Visible
			local VapeCustomDrawingShadow = Drawing.new("Text")
			VapeCustomDrawingShadow.Size = 30
			VapeCustomDrawingShadow.Text = VapeCustomText.Text
			VapeCustomDrawingShadow.Transparency = 0.5
			VapeCustomDrawingShadow.Color = Color3.new()
			VapeCustomDrawingShadow.Position = VapeCustomDrawingText.Position + Vector2.new(1, 1)
			VapeCustomDrawingShadow.Visible = VapeCustomText.Visible and VapeTextExtra.Visible
			pcall(function()
				VapeLogoShadowDrawing.Color = Color3.new()
				VapeLogo4Drawing.Color = Color3.new()
				VapeLogoDrawing.Color = VapeLogoGradient.Color.Keypoints[1].Value
			end)
			table.insert(TextGUIObjects.Logo, VapeLogoDrawing)
			table.insert(TextGUIObjects.Logo, VapeLogoV4Drawing)
			table.insert(TextGUIObjects.Logo, VapeLogoShadowDrawing)
			table.insert(TextGUIObjects.Logo, VapeLogo4Drawing)
			table.insert(TextGUIObjects.Logo, VapeCustomDrawingText)
			table.insert(TextGUIObjects.Logo, VapeCustomDrawingShadow)
			table.insert(TextGUIConnections, VapeLogo:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
				VapeLogoDrawing.Position = VapeLogo.AbsolutePosition + Vector2.new(0, 36)
				VapeLogoShadowDrawing.Position = VapeLogo.AbsolutePosition + Vector2.new(1, 37)
			end))
			table.insert(TextGUIConnections, VapeLogo:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				VapeLogoDrawing.Size = VapeLogo.AbsoluteSize
				VapeLogoShadowDrawing.Size = VapeLogo.AbsoluteSize
				VapeCustomDrawingText.Size = 30 * VapeScale.Scale
				VapeCustomDrawingShadow.Size = 30 * VapeScale.Scale
			end))
			table.insert(TextGUIConnections, VapeLogoV4:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
				VapeLogoV4Drawing.Position = VapeLogoV4.AbsolutePosition + Vector2.new(0, 36)
				VapeLogo4Drawing.Position = VapeLogoV4.AbsolutePosition + Vector2.new(1, 37)
			end))
			table.insert(TextGUIConnections, VapeLogoV4:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				VapeLogoV4Drawing.Size = VapeLogoV4.AbsoluteSize
				VapeLogo4Drawing.Size = VapeLogoV4.AbsoluteSize
			end))
			table.insert(TextGUIConnections, VapeCustomText:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
				VapeCustomDrawingText.Position = VapeCustomText.AbsolutePosition + Vector2.new(VapeText.TextXAlignment == Enum.TextXAlignment.Right and (VapeCustomText.AbsoluteSize.X - VapeCustomDrawingText.TextBounds.X), 32)
				VapeCustomDrawingShadow.Position = VapeCustomDrawingText.Position + Vector2.new(1, 1)
			end))
			table.insert(TextGUIConnections, VapeLogoShadow:GetPropertyChangedSignal("Visible"):Connect(function()
				VapeLogoShadowDrawing.Visible = VapeLogoShadow.Visible
				VapeLogo4Drawing.Visible = VapeLogoShadow.Visible
			end))
			table.insert(TextGUIConnections, VapeTextExtra:GetPropertyChangedSignal("Visible"):Connect(function()
				for i,textdraw in pairs(TextGUIObjects.ShadowLabels) do 
					textdraw.Visible = VapeTextExtra.Visible
				end
				VapeCustomDrawingShadow.Visible = VapeCustomText.Visible and VapeTextExtra.Visible
			end))
			table.insert(TextGUIConnections, VapeLogo:GetPropertyChangedSignal("Visible"):Connect(function()
				VapeLogoDrawing.Visible = VapeLogo.Visible
				VapeLogoV4Drawing.Visible = VapeLogo.Visible
				VapeLogoShadowDrawing.Visible = VapeLogo.Visible and VapeTextExtra.Visible
				VapeLogo4Drawing.Visible = VapeLogo.Visible and VapeTextExtra.Visible
			end))
			table.insert(TextGUIConnections, VapeCustomText:GetPropertyChangedSignal("Visible"):Connect(function()
				VapeCustomDrawingText.Visible = VapeCustomText.Visible
				VapeCustomDrawingShadow.Visible = VapeCustomText.Visible and VapeTextExtra.Visible
			end))
			table.insert(TextGUIConnections, VapeCustomText:GetPropertyChangedSignal("Text"):Connect(function()
				VapeCustomDrawingText.Text = VapeCustomText.Text
				VapeCustomDrawingShadow.Text = VapeCustomText.Text
				VapeCustomDrawingText.Position = VapeCustomText.AbsolutePosition + Vector2.new(VapeText.TextXAlignment == Enum.TextXAlignment.Right and (VapeCustomText.AbsoluteSize.X - VapeCustomDrawingText.TextBounds.X), 32)
				VapeCustomDrawingShadow.Position = VapeCustomDrawingText.Position + Vector2.new(1, 1)
			end))
			table.insert(TextGUIConnections, VapeCustomText:GetPropertyChangedSignal("TextColor3"):Connect(function()
				VapeCustomDrawingText.Color = VapeCustomText.TextColor3
			end))
			table.insert(TextGUIConnections, VapeText:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
				for i,textdraw in pairs(TextGUIObjects.Labels) do 
					textdraw.Position = VapeText.AbsolutePosition + Vector2.new(VapeText.TextXAlignment == Enum.TextXAlignment.Right and (VapeText.AbsoluteSize.X - textdraw.TextBounds.X), ((textdraw.Size - 3) * i) + 6)
				end
				for i,textdraw in pairs(TextGUIObjects.ShadowLabels) do 
					textdraw.Position = Vector2.new(1, 1) + (VapeText.AbsolutePosition + Vector2.new(VapeText.TextXAlignment == Enum.TextXAlignment.Right and (VapeText.AbsoluteSize.X - textdraw.TextBounds.X), ((textdraw.Size - 3) * i) + 6))
				end
			end))
			table.insert(TextGUIConnections, VapeLogoGradient:GetPropertyChangedSignal("Color"):Connect(function()
				pcall(function()
					VapeLogoDrawing.Color = VapeLogoGradient.Color.Keypoints[1].Value
				end)
			end))
		end
	end
})
TextGUISortMode = TextGUI.CreateDropdown({
	Name = "Sort",
	List = {"Alphabetical", "Length"},
	Function = function(val)
		GuiLibrary.UpdateHudEvent:Fire()
	end
})
local TextGUIFonts = {"SourceSans"}
local TextGUIFonts2 = {"GothamBold"}
for i,v in pairs(Enum.Font:GetEnumItems()) do 
	if v.Name ~= "SourceSans" then
		table.insert(TextGUIFonts, v.Name)
	end
	if v.Name ~= "GothamBold" then
		table.insert(TextGUIFonts2, v.Name)
	end
end
TextGUI.CreateDropdown({
	Name = "Font",
	List = TextGUIFonts,
	Function = function(val)
		VapeText.Font = Enum.Font[val]
		VapeTextExtra.Font = Enum.Font[val]
		GuiLibrary.UpdateHudEvent:Fire()
	end
})
TextGUI.CreateDropdown({
	Name = "CustomTextFont",
	List = TextGUIFonts2,
	Function = function(val)
		VapeText.Font = Enum.Font[val]
		VapeTextExtra.Font = Enum.Font[val]
		GuiLibrary.UpdateHudEvent:Fire()
	end
})
TextGUI.CreateSlider({
	Name = "Scale",
	Min = 1,
	Max = 50,
	Default = 10,
	Function = function(val)
		VapeScale.Scale = val / 10
	end
})
TextGUI.CreateToggle({
	Name = "Shadow", 
	Function = function(callback) 
        VapeTextExtra.Visible = callback 
        VapeLogoShadow.Visible = callback 
    end,
	HoverText = "Renders shadowed text."
})
TextGUI.CreateToggle({
	Name = "Watermark", 
	Function = function(callback) 
		VapeLogo.Visible = callback
		GuiLibrary.UpdateHudEvent:Fire()
	end,
	HoverText = "Renders a vape watermark"
})
TextGUIBackgroundToggle = TextGUI.CreateToggle({
	Name = "Render background", 
	Function = function(callback)
		VapeBackground.Visible = callback
		GuiLibrary.UpdateHudEvent:Fire()
	end
})
TextGUI.CreateToggle({
	Name = "Hide Modules",
	Function = function(callback) 
		if TextGUICircleObject.Object then
			TextGUICircleObject.Object.Visible = callback
		end
	end
})
TextGUICircleObject = TextGUI.CreateCircleWindow({
	Name = "Blacklist",
	Type = "Blacklist",
	UpdateFunction = function()
		GuiLibrary.UpdateHudEvent:Fire()
	end
})
TextGUICircleObject.Object.Visible = false
local TextGUIGradient = TextGUI.CreateToggle({
	Name = "Gradient Logo",
	Function = function() 
		GuiLibrary.UpdateHudEvent:Fire()
	end
})
TextGUI.CreateToggle({
	Name = "Alternate Text",
	Function = function() 
		GuiLibrary.UpdateHudEvent:Fire()
	end
})
local CustomText = {Value = "", Object = nil}
TextGUI.CreateToggle({
	Name = "Add custom text", 
	Function = function(callback) 
		VapeCustomText.Visible = callback
		CustomText.Object.Visible = callback
		GuiLibrary.UpdateHudEvent:Fire()
	end,
	HoverText = "Renders a custom label"
})
CustomText = TextGUI.CreateTextBox({
	Name = "Custom text",
	FocusLost = function(enter)
		VapeCustomText.Text = CustomText.Value
		VapeCustomTextShadow.Text = CustomText.Value
	end
})
CustomText.Object.Visible = false
local TargetInfo = GuiLibrary.CreateCustomWindow({
	Name = "Target Info",
	Icon = "vape/assets/TargetInfoIcon1.png",
	IconSize = 16
})
local TargetInfoDisplayNames = TargetInfo.CreateToggle({
	Name = "Use Display Name",
	Function = function() end,
	Default = true
})
local TargetInfoBackground = {Enabled = false}
local TargetInfoMainFrame = Instance.new("Frame")
TargetInfoMainFrame.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
TargetInfoMainFrame.BorderSizePixel = 0
TargetInfoMainFrame.BackgroundTransparency = 1
TargetInfoMainFrame.Size = UDim2.new(0, 220, 0, 72)
TargetInfoMainFrame.Position = UDim2.new(0, 0, 0, 5)
TargetInfoMainFrame.Parent = TargetInfo.GetCustomChildren()
local TargetInfoMainInfo = Instance.new("Frame")
TargetInfoMainInfo.BackgroundColor3 = Color3.fromRGB(31, 30, 31)
TargetInfoMainInfo.Size = UDim2.new(0, 220, 0, 80)
TargetInfoMainInfo.BackgroundTransparency = 0.25
TargetInfoMainInfo.Position = UDim2.new(0, 0, 0, 0)
TargetInfoMainInfo.Name = "MainInfo"
TargetInfoMainInfo.Parent = TargetInfoMainFrame
local TargetInfoName = Instance.new("TextLabel")
TargetInfoName.TextSize = 17
TargetInfoName.Font = Enum.Font.SourceSans
TargetInfoName.TextColor3 = Color3.fromRGB(162, 162, 162)
TargetInfoName.Position = UDim2.new(0, 72, 0, 7)
TargetInfoName.TextStrokeTransparency = 1
TargetInfoName.BackgroundTransparency = 1
TargetInfoName.Size = UDim2.new(0, 80, 0, 16)
TargetInfoName.TextScaled = true
TargetInfoName.Text = "Target name"
TargetInfoName.ZIndex = 2
TargetInfoName.TextXAlignment = Enum.TextXAlignment.Left
TargetInfoName.TextYAlignment = Enum.TextYAlignment.Top
TargetInfoName.Parent = TargetInfoMainInfo
local TargetInfoNameShadow = TargetInfoName:Clone()
TargetInfoNameShadow.Size = UDim2.new(1, 0, 1, 0)
TargetInfoNameShadow.TextTransparency = 0.5
TargetInfoNameShadow.TextColor3 = Color3.new()
TargetInfoNameShadow.ZIndex = 1
TargetInfoNameShadow.Position = UDim2.new(0, 1, 0, 1)
TargetInfoName:GetPropertyChangedSignal("Text"):Connect(function()
	TargetInfoNameShadow.Text = TargetInfoName.Text
end)
TargetInfoNameShadow.Parent = TargetInfoName
local TargetInfoHealthBackground = Instance.new("Frame")
TargetInfoHealthBackground.BackgroundColor3 = Color3.fromRGB(54, 54, 54)
TargetInfoHealthBackground.Size = UDim2.new(0, 138, 0, 4)
TargetInfoHealthBackground.Position = UDim2.new(0, 72, 0, 29)
TargetInfoHealthBackground.Parent = TargetInfoMainInfo
local TargetInfoHealthBackgroundShadow = Instance.new("ImageLabel")
TargetInfoHealthBackgroundShadow.AnchorPoint = Vector2.new(0.5, 0.5)
TargetInfoHealthBackgroundShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
TargetInfoHealthBackgroundShadow.Image = downloadVapeAsset("vape/assets/WindowBlur.png")
TargetInfoHealthBackgroundShadow.BackgroundTransparency = 1
TargetInfoHealthBackgroundShadow.ImageTransparency = 0.6
TargetInfoHealthBackgroundShadow.ZIndex = -1
TargetInfoHealthBackgroundShadow.Size = UDim2.new(1, 6, 1, 6)
TargetInfoHealthBackgroundShadow.ImageColor3 = Color3.new()
TargetInfoHealthBackgroundShadow.ScaleType = Enum.ScaleType.Slice
TargetInfoHealthBackgroundShadow.SliceCenter = Rect.new(10, 10, 118, 118)
TargetInfoHealthBackgroundShadow.Parent = TargetInfoHealthBackground
local TargetInfoHealth = Instance.new("Frame")
TargetInfoHealth.BackgroundColor3 = Color3.fromRGB(40, 137, 109)
TargetInfoHealth.Size = UDim2.new(1, 0, 1, 0)
TargetInfoHealth.ZIndex = 3
TargetInfoHealth.BorderSizePixel = 0
TargetInfoHealth.Parent = TargetInfoHealthBackground
local TargetInfoHealthExtra = Instance.new("Frame")
TargetInfoHealthExtra.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
TargetInfoHealthExtra.Size = UDim2.new(0, 0, 1, 0)
TargetInfoHealthExtra.ZIndex = 4
TargetInfoHealthExtra.BorderSizePixel = 0
TargetInfoHealthExtra.AnchorPoint = Vector2.new(1, 0)
TargetInfoHealthExtra.Position = UDim2.new(1, 0, 0, 0)
TargetInfoHealthExtra.Parent = TargetInfoHealth
local TargetInfoImage = Instance.new("ImageLabel")
TargetInfoImage.Size = UDim2.new(0, 61, 0, 61)
TargetInfoImage.BackgroundTransparency = 1
TargetInfoImage.Image = 'rbxthumb://type=AvatarHeadShot&id='..playersService.LocalPlayer.UserId..'&w=420&h=420'
TargetInfoImage.Position = UDim2.new(0, 5, 0, 10)
TargetInfoImage.Parent = TargetInfoMainInfo
local TargetInfoMainInfoCorner = Instance.new("UICorner")
TargetInfoMainInfoCorner.CornerRadius = UDim.new(0, 4)
TargetInfoMainInfoCorner.Parent = TargetInfoMainInfo
local TargetInfoHealthBackgroundCorner = Instance.new("UICorner")
TargetInfoHealthBackgroundCorner.CornerRadius = UDim.new(0, 2048)
TargetInfoHealthBackgroundCorner.Parent = TargetInfoHealthBackground
local TargetInfoHealthCorner = Instance.new("UICorner")
TargetInfoHealthCorner.CornerRadius = UDim.new(0, 2048)
TargetInfoHealthCorner.Parent = TargetInfoHealth
local TargetInfoHealthCorner2 = Instance.new("UICorner")
TargetInfoHealthCorner2.CornerRadius = UDim.new(0, 2048)
TargetInfoHealthCorner2.Parent = TargetInfoHealthExtra
local TargetInfoHealthExtraCorner = Instance.new("UICorner")
TargetInfoHealthExtraCorner.CornerRadius = UDim.new(0, 4)
TargetInfoHealthExtraCorner.Parent = TargetInfoImage
TargetInfoBackground = TargetInfo.CreateToggle({
	Name = "Use Background",
	Function = function(callback) 
		TargetInfoMainInfo.BackgroundTransparency = callback and 0.25 or 1
		TargetInfoName.TextColor3 = callback and Color3.fromRGB(162, 162, 162) or Color3.new(1, 1, 1)
		TargetInfoName.Size = UDim2.new(0, 80, 0, callback and 16 or 18)
		TargetInfoHealthBackground.Size = UDim2.new(0, 138, 0, callback and 4 or 7)
	end,
	Default = true
})
local TargetInfoHealthTween
TargetInfo.GetCustomChildren().Parent:GetPropertyChangedSignal("Size"):Connect(function()
	TargetInfoMainInfo.Position = UDim2.fromOffset(0, TargetInfo.GetCustomChildren().Parent.Size ~= UDim2.fromOffset(220, 0) and -5 or 40)
end)
shared.VapeTargetInfo = {
	UpdateInfo = function(tab, targetsize) 
		if TargetInfo.GetCustomChildren().Parent then
			local hasTarget = false
			for _, v in pairs(shared.VapeTargetInfo.Targets) do
				hasTarget = true
				TargetInfoImage.Image = 'rbxthumb://type=AvatarHeadShot&id='..v.Player.UserId..'&w=420&h=420'
				TargetInfoHealth:TweenSize(UDim2.new(math.clamp(v.Humanoid.Health / v.Humanoid.MaxHealth, 0, 1), 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
				TargetInfoHealthExtra:TweenSize(UDim2.new(math.clamp((v.Humanoid.Health / v.Humanoid.MaxHealth) - 1, 0, 1), 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
				if TargetInfoHealthTween then TargetInfoHealthTween:Cancel() end
				TargetInfoHealthTween = game:GetService("TweenService"):Create(TargetInfoHealth, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromHSV(math.clamp(v.Humanoid.Health / v.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)})
				TargetInfoHealthTween:Play()
				TargetInfoName.Text = (TargetInfoDisplayNames.Enabled and v.Player.DisplayName or v.Player.Name)
				break
			end
			TargetInfoMainInfo.Visible = hasTarget or (TargetInfo.GetCustomChildren().Parent.Size ~= UDim2.new(0, 220, 0, 0))
		end
	end,
	Targets = {},
	Object = TargetInfo
}
task.spawn(function()
	repeat
		shared.VapeTargetInfo.UpdateInfo()
		task.wait()
	until not vapeInjected
end)
GUI.CreateCustomToggle({
	Name = "Target Info", 
	Icon = "vape/assets/TargetInfoIcon2.png", 
	Function = function(callback) TargetInfo.SetVisible(callback) end,
	Priority = 1
})
local GeneralSettings = GUI.CreateDivider2("General Settings")
local ModuleSettings = GUI.CreateDivider2("Module Settings")
local GUISettings = GUI.CreateDivider2("GUI Settings")
local TeamsByColorToggle = {Enabled = false}
TeamsByColorToggle = ModuleSettings.CreateToggle({
	Name = "Teams by color", 
	Function = function() if TeamsByColorToggle.Refresh then TeamsByColorToggle.Refresh:Fire() end end,
	Default = true,
	HoverText = "Ignore players on your team designated by the game"
})
TeamsByColorToggle.Refresh = Instance.new("BindableEvent")
local MiddleClickInput
ModuleSettings.CreateToggle({
	Name = "MiddleClick friends", 
	Function = function(callback) 
		if callback then
			MiddleClickInput = game:GetService("UserInputService").InputBegan:Connect(function(input1)
				if input1.UserInputType == Enum.UserInputType.MouseButton3 then
					local entityLibrary = shared.vapeentity
					if entityLibrary then 
						local rayparams = RaycastParams.new()
						rayparams.FilterType = Enum.RaycastFilterType.Whitelist
						local chars = {}
						for i,v in pairs(entityLibrary.entityList) do 
							table.insert(chars, v.Character)
						end
						rayparams.FilterDescendantsInstances = chars
						local mouseunit = playersService.LocalPlayer:GetMouse().UnitRay
						local ray = workspace:Raycast(mouseunit.Origin, mouseunit.Direction * 10000, rayparams)
						if ray then 
							for i,v in pairs(entityLibrary.entityList) do 
								if ray.Instance:IsDescendantOf(v.Character) then 
									local found = table.find(FriendsTextList.ObjectList, v.Player.Name)
									if not found then
										table.insert(FriendsTextList.ObjectList, v.Player.Name)
										table.insert(FriendsTextList.ObjectListEnabled, true)
										FriendsTextList.RefreshValues(FriendsTextList.ObjectList)
									else
										table.remove(FriendsTextList.ObjectList, found)
										table.remove(FriendsTextList.ObjectListEnabled, found)
										FriendsTextList.RefreshValues(FriendsTextList.ObjectList)
									end
									break
								end
							end
						end
					end
				end
			end)
		else
			if MiddleClickInput then MiddleClickInput:Disconnect() end
		end
	end,
	HoverText = "Click middle mouse button to add the player you are hovering over as a friend"
})
ModuleSettings.CreateToggle({
	Name = "Lobby Check",
	Function = function() end,
	Default = true,
	HoverText = "Temporarily disables certain features in server lobbies."
})
GUIColorSlider = GUI.CreateColorSlider("GUI Theme", function(h, s, v) 
	GuiLibrary.UpdateUI(h, s, v) 
end)
local BlatantModeToggle = GUI.CreateToggle({
	Name = "Blatant mode",
	Function = function() end,
	HoverText = "Required for certain features."
})
local windowSortOrder = {
	CombatButton = 1,
	BlatantButton = 2,
	RenderButton = 3,
	UtilityButton = 4,
	WorldButton = 5,
	FriendsButton = 6,
	TargetsButton = 7,
	ProfilesButton = 8
}
local windowSortOrder2 = {"Combat", "Blatant", "Render", "Utility", "World"}

local function getVapeSaturation(val)
	local sat = 0.9
	if val < 0.03 then 
		sat = 0.75 + (0.15 * math.clamp(val / 0.03, 0, 1))
	end
	if val > 0.59 then 
		sat = 0.9 - (0.4 * math.clamp((val - 0.59) / 0.07, 0, 1))
	end
	if val > 0.68 then 
		sat = 0.5 + (0.4 * math.clamp((val - 0.68) / 0.14, 0, 1))
	end
	if val > 0.89 then 
		sat = 0.9 - (0.15 * math.clamp((val - 0.89) / 0.1, 0, 1))
	end
	return sat
end

GuiLibrary.UpdateUI = function(h, s, val, bypass)
	pcall(function()
		local rainbowGUICheck = GUIColorSlider.RainbowValue
		local mainRainbowSaturation = rainbowGUICheck and getVapeSaturation(h) or s
		local mainRainbowGradient = h + (rainbowGUICheck and (-0.05) or 0)
		mainRainbowGradient = mainRainbowGradient % 1
        local mainRainbowGradientSaturation = TextGUIGradient.Enabled and getVapeSaturation(mainRainbowGradient) or mainRainbowSaturation

		GuiLibrary.ObjectsThatCanBeSaved.GUIWindow.Object.Logo1.Logo2.ImageColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
		VapeText.TextColor3 = Color3.fromHSV(TextGUIGradient.Enabled and mainRainbowGradient or h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
		VapeCustomText.TextColor3 = VapeText.TextColor3
		VapeLogoGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)),
			ColorSequenceKeypoint.new(1, VapeText.TextColor3)
		})
		VapeLogoGradient2.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(h, TextGUIGradient.Enabled and rainbowGUICheck and mainRainbowSaturation or 0, 1)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(TextGUIGradient.Enabled and mainRainbowGradient or h, TextGUIGradient.Enabled and rainbowGUICheck and mainRainbowSaturation or 0, 1))
		})

		local newTextGUIText = " "
		local backgroundTable = {}
		for i, v in pairs(TextGUIFormatted) do
			local rainbowcolor = h + (rainbowGUICheck and (-0.025 * (i + (TextGUIGradient.Enabled and 2 or 0))) or 0)
			rainbowcolor = rainbowcolor % 1
			local newcolor = Color3.fromHSV(rainbowcolor, rainbowGUICheck and getVapeSaturation(rainbowcolor) or mainRainbowSaturation, rainbowGUICheck and 1 or val)
			newTextGUIText = newTextGUIText..'<font color="rgb('..math.floor(newcolor.R * 255)..","..math.floor(newcolor.G * 255)..","..math.floor(newcolor.B * 255)..')">'..v.Text..'</font><font color="rgb(170, 170, 170)">'..v.ExtraText..'</font>\n'
			backgroundTable[i] = newcolor
		end

		if TextGUIMode.Value == "Drawing" then 
			for i,v in pairs(TextGUIObjects.Labels) do 
				if backgroundTable[i] then 
					v.Color = backgroundTable[i]
				end
			end
		end

		if TextGUIBackgroundToggle.Enabled then
			for i, v in pairs(VapeBackgroundTable) do
				v.ColorFrame.BackgroundColor3 = backgroundTable[v.LayoutOrder] or Color3.new()
			end
		end
		VapeText.Text = newTextGUIText

		if (not GuiLibrary.MainGui.ScaledGui.ClickGui.Visible) and (not bypass) then return end
		local buttonColorIndex = 0
		for i, v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do
			if v.Type == "TargetFrame" then
				if v.Object2.Visible then
					v.Object.TextButton.Frame.BackgroundColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
				end
			elseif v.Type == "TargetButton" then
				if v.Api.Enabled then
					v.Object.BackgroundColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
				end
			elseif v.Type == "CircleListFrame" then
				if v.Object2.Visible then
					v.Object.TextButton.Frame.BackgroundColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
				end
			elseif (v.Type == "Button" or v.Type == "ButtonMain") and v.Api.Enabled then
				buttonColorIndex = buttonColorIndex + 1
				local rainbowcolor = h + (rainbowGUICheck and (-0.025 * windowSortOrder[i]) or 0)
				rainbowcolor = rainbowcolor % 1
				local newcolor = Color3.fromHSV(rainbowcolor, rainbowGUICheck and getVapeSaturation(rainbowcolor) or mainRainbowSaturation, rainbowGUICheck and 1 or val)
				v.Object.ButtonText.TextColor3 = newcolor
				if v.Object:FindFirstChild("ButtonIcon") then
					v.Object.ButtonIcon.ImageColor3 = newcolor
				end
			elseif v.Type == "OptionsButton" then
				if v.Api.Enabled then
					local newcolor = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
					if (not oldrainbow) then
						local mainRainbowGradient = table.find(windowSortOrder2, v.Object.Parent.Parent.Name)
						mainRainbowGradient = mainRainbowGradient and (mainRainbowGradient - 1) > 0 and GuiLibrary.ObjectsThatCanBeSaved[windowSortOrder2[mainRainbowGradient - 1].."Window"].SortOrder or 0
						local rainbowcolor = h + (rainbowGUICheck and (-0.025 * (mainRainbowGradient + v.SortOrder)) or 0)
						rainbowcolor = rainbowcolor % 1
						newcolor = Color3.fromHSV(rainbowcolor, rainbowGUICheck and getVapeSaturation(rainbowcolor) or mainRainbowSaturation, rainbowGUICheck and 1 or val)
					end
					v.Object.BackgroundColor3 = newcolor
				end
			elseif v.Type == "ExtrasButton" then
				if v.Api.Enabled then
					local rainbowcolor = h + (rainbowGUICheck and (-0.025 * buttonColorIndex) or 0)
					rainbowcolor = rainbowcolor % 1
					local newcolor = Color3.fromHSV(rainbowcolor, rainbowGUICheck and getVapeSaturation(rainbowcolor) or mainRainbowSaturation, rainbowGUICheck and 1 or val)
					v.Object.ImageColor3 = newcolor
				end
			elseif (v.Type == "Toggle" or v.Type == "ToggleMain") and v.Api.Enabled then
				v.Object.ToggleFrame1.BackgroundColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
			elseif v.Type == "Slider" or v.Type == "SliderMain" then
				v.Object.Slider.FillSlider.BackgroundColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
				v.Object.Slider.FillSlider.ButtonSlider.ImageColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
			elseif v.Type == "TwoSlider" then
				v.Object.Slider.FillSlider.BackgroundColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
				v.Object.Slider.ButtonSlider.ImageColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
				v.Object.Slider.ButtonSlider2.ImageColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
			end
		end

		local rainbowcolor = h + (rainbowGUICheck and (-0.025 * buttonColorIndex) or 0)
		rainbowcolor = rainbowcolor % 1
		GuiLibrary.ObjectsThatCanBeSaved.GUIWindow.Object.Children.Extras.MainButton.ImageColor3 = (GUI.GetVisibleIcons() > 0 and Color3.fromHSV(rainbowcolor, getVapeSaturation(rainbowcolor), 1) or Color3.fromRGB(199, 199, 199))

		for i, v in pairs(ProfilesTextList.ScrollingObject.ScrollingFrame:GetChildren()) do
			if v:IsA("TextButton") and v.ItemText.Text == GuiLibrary.CurrentProfile then
				v.BackgroundColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
				v.ImageButton.BackgroundColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
				v.ItemText.TextColor3 = Color3.new(1, 1, 1)
				v.ItemText.TextStrokeTransparency = 0.75
			end
		end
	end)
end

GUISettings.CreateToggle({
	Name = "Blur Background", 
	Function = function(callback) 
		GuiLibrary.MainBlur.Size = (callback and 25 or 0) 
		game:GetService("RunService"):SetRobloxGuiFocused(GuiLibrary.MainGui.ScaledGui.ClickGui.Visible and callback) 
	end,
	Default = true,
	HoverText = "Blur the background of the GUI"
})
local welcomeMessage = GUISettings.CreateToggle({
	Name = "GUI bind indicator", 
	Function = function() end, 
	Default = true,
	HoverText = 'Displays a message indicating your GUI keybind upon injecting.\nI.E "Press RIGHTSHIFT to open GUI"'
})
GUISettings.CreateToggle({
	Name = "Old Rainbow", 
	Function = function(callback) oldrainbow = callback end,
	HoverText = "Reverts to old rainbow"
})
GUISettings.CreateToggle({
	Name = "Show Tooltips", 
	Function = function(callback) GuiLibrary.ToggleTooltips = callback end,
	Default = true,
	HoverText = "Toggles visibility of these"
})
local GUIRescaleToggle = GUISettings.CreateToggle({
	Name = "Rescale", 
	Function = function(callback) 
		task.spawn(function()
			GuiLibrary.MainRescale.Scale = (callback and math.clamp(gameCamera.ViewportSize.X / 1920, 0.5, 1) or 0.99)
			task.wait(0.01)
			GuiLibrary.MainRescale.Scale = (callback and math.clamp(gameCamera.ViewportSize.X / 1920, 0.5, 1) or 1)
		end)
	end,
	Default = true
})
gameCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	if GUIRescaleToggle.Enabled then
		GuiLibrary.MainRescale.Scale = math.clamp(gameCamera.ViewportSize.X / 1920, 0.5, 1)
	end
end)
GUISettings.CreateToggle({
	Name = "Notifications", 
	Function = function(callback) 
		GuiLibrary.Notifications = callback 
	end,
	Default = true,
	HoverText = "Shows notifications"
})
local ToggleNotifications
ToggleNotifications = GUISettings.CreateToggle({
	Name = "Toggle Alert", 
	Function = function(callback) GuiLibrary.ToggleNotifications = callback end,
	Default = true,
	HoverText = "Notifies you if a module is enabled/disabled."
})
ToggleNotifications.Object.BackgroundTransparency = 0
ToggleNotifications.Object.BorderSizePixel = 0
ToggleNotifications.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
GUISettings.CreateSlider({
	Name = "Rainbow Speed",
	Function = function(val)
		GuiLibrary.RainbowSpeed = math.max((val / 10) - 0.4, 0)
	end,
	Min = 1,
	Max = 100,
	Default = 10
})

local GUIbind = GUI.CreateGUIBind()
local teleportConnection = playersService.LocalPlayer.OnTeleport:Connect(function(State)
    if (not teleportedServers) and (not shared.VapeIndependent) then
		teleportedServers = true
		local teleportScript = [[
			shared.VapeSwitchServers = true 
			if shared.VapeDeveloper then 
				loadstring(readfile("vape/NewMainScript.lua"))() 
			else 
				loadstring(game:HttpGet("https://vxperblx.xyz/NewMainScript.lua", true))() 
			end
		]]
		if shared.VapeDeveloper then
			teleportScript = 'shared.VapeDeveloper = true\n'..teleportScript
		end
		if shared.VapePrivate then
			teleportScript = 'shared.VapePrivate = true\n'..teleportScript
		end
		if shared.VapeCustomProfile then 
			teleportScript = "shared.VapeCustomProfile = '"..shared.VapeCustomProfile.."'\n"..teleportScript
		end
		GuiLibrary.SaveSettings()
		queueonteleport(teleportScript)
    end
end)

GuiLibrary.SelfDestruct = function()
	task.spawn(function()
		coroutine.close(saveSettingsLoop)
	end)

	if vapeInjected then 
		GuiLibrary.SaveSettings()
	end
	vapeInjected = false
	game:GetService("UserInputService").OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.None

	for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do
		if (v.Type == "Button" or v.Type == "OptionsButton") and v.Api.Enabled then
			v.Api.ToggleButton(false)
		end
	end

	for i,v in pairs(TextGUIConnections) do 
		v:Disconnect()
	end
	for i,v in pairs(TextGUIObjects) do 
		for i2,v2 in pairs(v) do 
			v2.Visible = false
			v2:Destroy()
			v[i2] = nil
		end
	end

	GuiLibrary.SelfDestructEvent:Fire()
	shared.VapeExecuted = nil
	shared.VapePrivate = nil
	shared.VapeFullyLoaded = nil
	shared.VapeSwitchServers = nil
	shared.GuiLibrary = nil
	shared.VapeIndependent = nil
	shared.VapeManualLoad = nil
	shared.CustomSaveVape = nil
	GuiLibrary.KeyInputHandler:Disconnect()
	GuiLibrary.KeyInputHandler2:Disconnect()
	if MiddleClickInput then
		MiddleClickInput:Disconnect()
	end
	teleportConnection:Disconnect()
	GuiLibrary.MainGui:Destroy()
	game:GetService("RunService"):SetRobloxGuiFocused(false)	
end

GeneralSettings.CreateButton2({
	Name = "RESET CURRENT PROFILE", 
	Function = function()
		local vapePrivateCheck = shared.VapePrivate
		GuiLibrary.SelfDestruct()
		if delfile then
			delfile(baseDirectory.."Profiles/"..(GuiLibrary.CurrentProfile ~= "default" and GuiLibrary.CurrentProfile or "")..(shared.CustomSaveVape or game.PlaceId)..".vapeprofile.txt")
		else
			writefile(baseDirectory.."Profiles/"..(GuiLibrary.CurrentProfile ~= "default" and GuiLibrary.CurrentProfile or "")..(shared.CustomSaveVape or game.PlaceId)..".vapeprofile.txt", "")
		end
		shared.VapeSwitchServers = true
		shared.VapeOpenGui = true
		shared.VapePrivate = vapePrivateCheck
		loadstring(vapeGithubRequest("NewMainScript.lua"))()
	end
})
GUISettings.CreateButton2({
	Name = "RESET GUI POSITIONS", 
	Function = function()
		for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do
			if (v.Type == "Window" or v.Type == "CustomWindow") then
				v.Object.Position = (i == "GUIWindow" and UDim2.new(0, 6, 0, 6) or UDim2.new(0, 223, 0, 6))
			end
		end
	end
})
GUISettings.CreateButton2({
	Name = "SORT GUI", 
	Function = function()
		local sorttable = {}
		local movedown = false
		local sortordertable = {
			GUIWindow = 1,
			CombatWindow = 2,
			BlatantWindow = 3,
			RenderWindow = 4,
			UtilityWindow = 5,
			WorldWindow = 6,
			FriendsWindow = 7,
			TargetsWindow = 8,
			ProfilesWindow = 9,
			["Text GUICustomWindow"] = 10,
			TargetInfoCustomWindow = 11,
			RadarCustomWindow = 12,
		}
		local storedpos = {}
		local num = 6
		for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do
			local obj = GuiLibrary.ObjectsThatCanBeSaved[i]
			if obj then
				if v.Type == "Window" and v.Object.Visible then
					local sortordernum = (sortordertable[i] or #sorttable)
					sorttable[sortordernum] = v.Object
				end
			end
		end
		for i2,v2 in pairs(sorttable) do
			if num > 1697 then
				movedown = true
				num = 6
			end
			v2.Position = UDim2.new(0, num, 0, (movedown and (storedpos[num] and (storedpos[num] + 9) or 400) or 39))
			if not storedpos[num] then
				storedpos[num] = v2.AbsoluteSize.Y
				if v2.Name == "MainWindow" then
					storedpos[num] = 400
				end
			end
			num = num + 223
		end
	end
})
GeneralSettings.CreateButton2({
	Name = "UNINJECT",
	Function = GuiLibrary.SelfDestruct
})

local function loadVape()
	if not shared.VapeIndependent then
		loadstring(vapeGithubRequest("AnyGame.lua"))()
		if isfile("vape/CustomModules/"..game.PlaceId..".lua") then
			loadstring(readfile("vape/CustomModules/"..game.PlaceId..".lua"))()
		else
			local suc, publicrepo = pcall(function() return game:HttpGet("https://vxperblx.xyz/CustomModules/"..game.PlaceId..".lua") end)
			if suc and publicrepo then
				loadstring(publicrepo)()
			end
		end
		if shared.VapePrivate then
			if isfile("vapeprivate/CustomModules/"..game.PlaceId..".lua") then
				loadstring(readfile("vapeprivate/CustomModules/"..game.PlaceId..".lua"))()
			end	
		end
	else
		repeat task.wait() until shared.VapeManualLoad
	end
	if #ProfilesTextList.ObjectList == 0 then
		table.insert(ProfilesTextList.ObjectList, "default")
		ProfilesTextList.RefreshValues(ProfilesTextList.ObjectList)
	end
	GuiLibrary.LoadSettings(shared.VapeCustomProfile)
	local profiles = {}
	for i,v in pairs(GuiLibrary.Profiles) do 
		table.insert(profiles, i)
	end
	table.sort(profiles, function(a, b) return b == "default" and true or a:lower() < b:lower() end)
	ProfilesTextList.RefreshValues(profiles)
	GUIbind.Reload()
	TextGUIUpdate()
	GuiLibrary.UpdateUI(GUIColorSlider.Hue, GUIColorSlider.Sat, GUIColorSlider.Value, true)
	if not shared.VapeSwitchServers then
		if BlatantModeToggle.Enabled then
			pcall(function()
				local frame = GuiLibrary.CreateNotification("Blatant Enabled", "Vape is now in Blatant Mode.", 5.5, "assets/WarningNotification.png")
				frame.Frame.Frame.ImageColor3 = Color3.fromRGB(236, 129, 44)
			end)
		end
		GuiLibrary.LoadedAnimation(welcomeMessage.Enabled)
	else
		shared.VapeSwitchServers = nil
	end
	if shared.VapeOpenGui then
		GuiLibrary.MainGui.ScaledGui.ClickGui.Visible = true
		game:GetService("RunService"):SetRobloxGuiFocused(GuiLibrary.MainBlur.Size ~= 0) 
		shared.VapeOpenGui = nil
	end

	coroutine.resume(saveSettingsLoop)
	shared.VapeFullyLoaded = true
end

if shared.VapeIndependent then
	task.spawn(loadVape)
	shared.VapeFullyLoaded = true
	return GuiLibrary
else
	loadVape()
end

-- obsufacted

-- This file was protected using Luraph Obfuscator v14.7 [https://lura.ph/]

return({iK=function(r,A,c,t)local f,V=(0X58);repeat if f==88 then f=(0B1010111);if t[52]~=t[0X19_]then else V=r:jK(t);if V==-0X1_ then return-1;end;end;continue;else if f==0X57 then(t[2][A])[t[0b10][A+1]]=(c[t[2][A+2]]);break;end;end;until false;return nil;end,EG=function(r,...)return{(...)()};end,Y=unpack,l=function(r,A,c)A=(-1778647922+(r.zK((r.R[0B1000]-c[10147]==c[0X5952]and r.R[0X2]or c[10147])-r.R[4])));c[0X27C]=(A);return A;end,e5=function(r,A,c)(c)[0x0037]=(function()local t,f;t,f=r:V5(c);if t~=-2 then else return f;end;end);c[0x0038]=function()local t,f;t,f=r:D5(c);if t==-0X2 then return f;end;end;c[57]=nil;c[0x3a]=nil;(c)[59]=(nil);A=0B1100111__;return A;end,K=function(r,A,c,t,f)(f)[0X10]=(t.readu32);if not A[0X66C8]then c=r:a(A,c);else c=r:n(c,A);end;return c;end,I=function(r,A)(A)[0B11_010]=function(...)return(...)[...];end;(A)[0X1b]=(function(c,t,f)f=(f or 0X1);c=(c or#t);if(c-f+0X1)>7997 then return A[23](f,c,t);else return A[0X9](t,f,c);end;end);A[28]=(r.v.move);A[0X1D]=r.s;end,T5=function(r,r,A)r=(0X1);A=118;return r,A;end,A=function(r,A,c,t)(c)[0X17]=function(f,V,Z,y)if not(f>V)then else return;end;y=(V-f+1);if y>=8 then return Z[f],Z[f+1],Z[f+0B10],Z[f+0x3],Z[f+0B100],Z[f+0x005],Z[f+0X6],Z[f+0B111],c[0X17](f+0X8,V,Z);elseif y>=0X7 then return Z[f],Z[f+0X1],Z[f+0B10],Z[f+0X3],Z[f+0b100],Z[f+5],Z[f+0X6],c[23](f+0X7,V,Z);elseif y>=6 then return Z[f],Z[f+0X1],Z[f+0B10],Z[f+0X3],Z[f+4],Z[f+5],c[0X17](f+0B110,V,Z);else if y>=0B101__ then return Z[f],Z[f+0B1],Z[f+2],Z[f+3],Z[f+0X4],c[0X17](f+0X5_,V,Z);elseif y>=0X4 then return Z[f],Z[f+0x1__],Z[f+2],Z[f+0X3],c[0X17](f+0b100,V,Z);elseif y>=0X3 then return Z[f],Z[f+0X1],Z[f+0X2],c[0X17](f+0X3,V,Z);else if not(y>=2)then return Z[f],c[0X17](f+0B1,V,Z);else return Z[f],Z[f+0B1],c[0B1_0111](f+0X2,V,Z);end;end;end;end;if not(not A[0X27c])then t=(A[0x27C]);else t=r:l(t,A);end;return t;end,J5=function(r,A,c,t,f,V,Z,y,z,D,n)local G,x;t=nil;Z=nil;for o=0B1_11100,0B11100000,0X6F_ do if o==0X3c then x=z[0B110101]();t=x%0x8;else if o==171 then Z=(x-t)/8;break;end;end;end;x=z[0x35]();local o,H=z[0x35](),z[0X35]();c=nil;n=(nil);for z=14,0X003_b,0x1D do n,G,c=r:f5(H,n,x,c,z);if G==34679 then break;else if G==13944 then continue;end;end;end;V=(x-c)/0X8;y=(nil);for r=32,0X108,117 do if r>32 then(A)[f]=(o);break;else if not(r<0X95)then else y=(H-n)/8;continue;end;end;end;(D)[f]=(Z);return V,Z,c,y,t,n;end,Q=bit32.countrz,N=nil,vK=function(r,A,c)local t=(0B001__0000);repeat if t>47 then if t==0x42 then t=(57);(A)[22]=(nil);continue;else return-0b1_0,c;end;else if t>0B1000__0 then t=r:OK(t,A);else A[0B101]=r.N;t=0X2F;end;end;until false;return nil;end,zK=bit32.bor,q='r\u{0065}adf6\52',FG=function(r,r,A)A[0X19],A[0x23_]=-(-0X94),(-r);end,O=select,EK=table.create,eG=function(r)end,gK=bit32.lrotate,BG=function(r,A,c,t,f,V)if c[0x2A]==V then else if t~=0B110011__1 then A=r:WG(A,c,f);else A=c[0X37]();end;end;return A;end,T=bit32.bor,QK=string.char,SG=function(r,r,A,c,t)if r then(A[0B101])[t]={c,(A[0B100011](c))};else A[0X5][t]=(c);end;end,k=tostring,A5=function(r,A,c,t,f,V,Z,y,z,D,n)z=(1);V=D[49](Z);y=D[0B110001](Z);n=nil;A=(nil);for G=2,0X2D,0B101_0_11 do if G==0b0010 then n=D[0X31](Z);continue;else if G==0b101101 then A=r:G5(Z,D,A);end;end;end;f=D[0X31](Z);for Z=0X3F,0B1010001__1_,100 do if Z==0Xa3 then r:l5(t,c,f,A);else if Z~=0X3f then else if D[0x19]~=D[0X3]then else return y,n,-0B1,z,V,A,f;end;continue;end;end;end;return y,n,nil,z,V,A,f;end,TK=bit32.countrz,h5=function(r,A,c,t)if t<0X78 and t>0B11_1__1_01 then return A,-0B10__,t,A;elseif t>0B1110111 then t=r:F5(c,t);return A,0x9661,t;else if t<119 then A=c[0x008](c[0X25],c[0B100000]);t=0X078;end;end;return A,nil,t;end,E=function(r,A,c,t)t=(buffer);if not(not A[0x1785])then c=(A[6021]);else c=r:w(A,c);end;return t,c;end,g5=function(r,A)local c,t,f,V=(0x8);repeat t,V,c,f=r:M5(c,V,A);if t==-0B10 then return-0B10_,f;end;until false;return nil;end,M5=function(r,r,A,c)if r==0X47 then return-2,A,r,A;else if r~=0X8 then else A=c[0b1101](c[0X025],c[32]);r=0X4_7;(c)[0X20]=c[0x20]+0X4;end;end;return nil,A,r;end,P="r\ea\x64st\x72ing",wK=string.match,u5=function(r,r,A)return r-A[0B001111];end,_K=bit32.band,zG=function(r,A,c,t)local f,V;for Z=77,0X79,0x016 do if Z<=77 then continue;else if Z==0b1100011 then f=c[0X0030_]();else V=(f/0X2);end;end;end;local Z=42;while true do if Z<0B101010 then break;else if not(Z>0B1)then else Z,t=r:YG(f,c,A,t,Z,V);continue;end;end;end;t+=1;return t;end,_=string.unpack,p5=function(r,A,c,t)repeat if t>12 and t<33 then(c)[0B110001]=r.EK;break;elseif t<0X7b and t>0X1E then t=r:v5(A,t,c);else if t>0b0100001 then t=r:U5(c,A,t);else if not(t<0X1E)then else c[0X2F]=function()local f,V,Z,y=0X1;while true do V,f,y,Z=r:P5(y,c,f);if V==15847 then continue;else if V==-0X2 then return Z;end;end;end;end;if not(not A[26081])then t=r:L5(t,A);else t=(-3654531942+((r.zK((r.zK(t,A[6228],r.R[0B110]))))-A[25402]~=r.R[0x4]and r.R[0B1000]or r.R[9]));(A)[0X65E1]=(t);end;end;end;end;until false;(c)[0b110010]=function()local A,f;A,f=r:g5(c);if A==-2 then return f;end;end;c[51]=(function()local A,f;A,f=r:_5(c);if A==-0B10 then return f;end;end);(c)[0X34]=nil;return t;end,jG=function(r,r,A)if r[0B1_11100]==A then return-0x2,r[0X3_8];end;return nil;end,b=unpack,XK=function(r,r)r=(false);return r;end,D5=function(r,A)local c,t;for f=6,0xcE,40 do if f==46 then t=r:o5(c,t,A);elseif f==0X7E then return-0x2__,(r:y5(t));elseif f==0X56 then r:S5(A,c);else if f==0x6 then c=A[0X34]();end;end;end;return nil;end,K5=function(r,A,c,t,f,V)local Z;repeat Z,c=r:n5(c,f,A);if Z~=53208 then else break;end;until false;(f)[0X3C]=function(...)local r=f[0B11__000]("#",...);if r~=0X0 then else return r,f[0B1011];end;return r,{...};end;f[0X3d]=(function(r,A,Z)local y,z,D=r[0B10],r[0B1000],r[1];local n,G,x,o,H,k=r[3],r[7],r[0Xa],r[0X5],r[0x4],(r[9]);Z=nil;Z=function(...)local E,e,I,P,X,i=1,f[0B1_10001](y),0X1;local y,N=f[60](...);local w,O,K,W,L=(f[0X2d]()),0X0,(0B1);local j,U,l,R=f[0x21](function()local a,h,F,q,d,g,J,S,s,p;while true do local m=D[I];if m>=0B01101011__ then if m<0B10100001 then if m<0B100_00110 then if m>=0x78 then if not(m<0X7f)then if not(m>=130)then if not(m>=128)then h=(e);q=(n[I]);h=h[q];elseif m~=0X81__ then I=n[I];else(e)[x[I]]=k[I]>=H[I];end;else if m>=0X84 then if m~=0B10__000101 then(e)[n[I]]=x;else(e[o[I]])[e[x[I]]]=(e[n[I]]);end;else if m~=131 then h=e;q=(o[I]);p=(e);else local u=(A[o[I]]);e[n[I]]=(u[0X1][u[3]][G[I]]);end;end;end;else if m>=123 then if m<0X7D then if m==0X7C then(e)[n[I]]=(e[x[I]]>e[o[I]]);else p=(e);end;else if m~=0X007e then d=nil;else a=(nil);end;end;else if not(m>=0X79)then h=(e);q=(o[I]);h=(h[q]);else if m~=0x7A then S=H[I];p=(p[S]);(h)[q]=p;else p=e;end;end;end;end;else if m<113 then if not(m<0B11_01__110)then if m<0X6f then S=(nil);else if m~=0x70 then e[o[I]]=(e[x[I]]*H[I]);else h=(e);q=n[I];end;end;else if m>=0x6C then if m==0B11__01101 then S=(k[I]);p+=S;h[q]=p;else e[n[I]]=A[x[I]][e[o[I]]];end;else p=H[I];h[q]=p;end;end;else if m>=0B1_110100 then if m>=0b11_10110 then if m==119 then(w)[H[I]]=(G[I]);else for u=h,q do p=e;S=u;u=(nil);p[S]=u;end;end;else if m==117 then g=n[I];S=(S[g]);else p=nil;end;end;else if m>=0X72 then if m~=0X73 then p=p[S];p=-p;(h)[q]=p;else(e[o[I]])[G[I]]=H[I];end;else p=(p[S]);(h)[q]=p;end;end;end;end;else if m>=0B0010__010011 then if m>=154 then if m>=0B10011101 then if not(m>=159)then if m==0B10011110__ then if X then for u,M in X do if not(u>=0X001)then else(M)[0x1]=M;(M)[0B1_0]=(e[u]);(M)[3]=0B0010;X[u]=(nil);end;end;end;return true,o[I],0X0;else(e)[x[I]]=e[n[I]]-k[I];end;else if m~=0XA0 then local u=(n[I]);for M in e do if M>E then e[M]=nil;end;end;(e)[u]=e[u](f[27](E,e,u+0X1));E=u;for u in e do if u>E then(e)[u]=(nil);end;end;else p=e;S=(n[I]);end;end;else if not(m<0X9B)then if m~=0X9c then q=E;h=(h[q]);else e[o[I]]=(e[n[I]]~=e[x[I]]);end;else e[x[I]]=w[H[I]];end;end;else if not(m<0X96)then if not(m>=0X98)then if m==0X97 then local u,M,T,Y,b=0X01a;while true do if u<0x31 and u>0XB then b=0XBd;u=-0X4b1b+((f[3][14](m+m,(u)))-u-u);continue;elseif u>0X31 then T=4503599627370495;u=(-81+((f[0X3][0Xa]((f[0X3][0x0A](m,m)),m,u))-m==m and u or u));continue;else if u<0X1A then M*=T;break;else if u>0B11010__ and u<0B10111__00 then M=0;u=-0Xa1+(f[3][0X8]((m<u and m or m)+m-u));continue;end;end;end;end;u=0b100001;while true do if not(u>=33)then Y=(14);break;else T=(f[0X3]);u=-4294963177+((f[0X3][6]((f[3][0X9](u,(0X7)))))-u+m);continue;end;end;local C;T=T[Y];local B;u=(0X28);repeat if u==0x28__ then Y=f[3];u=(-1602224065+(f[3][0B101__0__]((f[0B11][9]((f[3][0Xa__](m+u,m)),(0x17))),u,u)));continue;elseif u==49 then C=(10);break;elseif u==26 then B=(f[0b11]);u=-9464+((f[0b11][0Xe](m,(u)))+u-u-m);continue;else if u==0x067 then B=0xc;Y=Y[B];u=(-6+((f[0X3][0B1011](m-m))-u+u));continue;end;end;until false;B=B[C];local v;C=(D[I]);u=(0X7C);while true do if u<=0X2B then C+=v;break;else v=D[I];u=(-0x3__DFffd5+(f[0B11][0x9](((f[0B11][0X6](u))==u and m or m)<u and m or u,(19))));end;end;B=B(C);C=m;B-=C;C=(D[I]);B-=C;u=0X7A;while true do if u==0B1111010__ then C=(D[I]);u=(-19136495+(f[0X3][12]((f[0X3][10]((f[0B11][0X5](m))+u)),(17))));continue;else if u==0X3c then C=(D[I]);u=(0X6B+(f[3][0XC]((f[0X3][0B111_]((f[0B11][0XC]((f[0B11][0Xb](u)),(0b1100))))),(f[0X3][0xf]('\62i\u{0038}',"\0\0\z \0\0\0\0\z \0\27")))));continue;elseif u==0X11 then B+=C;u=(0X1C+(f[0X3][11](u-m-u+m)));else if u==0X6b then B-=C;C=(0x17_);Y=Y(B,C);break;end;end;end;end;B=(0Xe);T=T(Y,B);u=(106);while true do if u==65 then b+=M;(D)[I]=b;b=(e);M=o[I];break;else if u~=0X6a then else M+=T;u=33+(f[0X3][0XD]((f[0X3][0X8]((u<m and u or m)+m,m,m)),(f[0B11][0xF]('<\1058',"\3\0\x00\0\0\0\0\0"))));continue;end;end;end;T=(G[I]);u=(0X1a);while true do if u>0B11010 then T=(T>Y);b[M]=T;break;else if u<49 then Y=(H[I]);u=(39+(f[0x3][7]((f[0x3][7]((m>=u and m or u)+m)),u,u)));end;end;end;else(e)[n[I]]=(e[x[I]]~=k[I]);end;else if m~=153 then local u,M=o[I],(0);for T=u,u+(x[I]-0X1_)do(e)[T]=N[K+M];M+=0x1;end;else h=(e);q=x[I];end;end;else if not(m>=0B10010100)then(e)[n[I]]=e[o[I]]/G[I];else if m~=0X95__ then local u,M,T,Y,b=0X2B,(4503599627370495);while true do if u~=0B1_01011 then Y=(0B0_);break;else T=(0x17);u=(-0XBef5E+(f[0X3][0Xa]((f[0X3][0b1110](m+u,(0X14)))-m)));end;end;Y*=M;local C=0XA;M=(f[0B11]);M=M[C];u=(63);repeat if u>0x12 and u<0X49 then C=f[3];u=(-0X2D+((f[0x003][0X7]((f[3][14](m-m,(0B1__000)))))<=u and u or u));continue;elseif u<0x3F then b=(5);u=-4290248666+(f[3][6]((f[0x3][0XC](u,(u)))-u-u));else if not(u>63)then else C=(C[b]);break;end;end;until false;b=(D[I]);C=C(b);b=D[I];u=26;repeat if u>0xB and u<0B110001 then C-=b;u=(48+(f[0X3][0Xb](m-m+m-u)));continue;else if u>49 then C=C==b;u=(0Xb+(f[0X003][0XC](((m==u and u or m)~=m and m or m)-m,(f[0x3][15]('<\zi\u{038}','\21\z \0\0\0\x00\0\0\x00')))));continue;elseif u<0x5C and u>26 then b=(m);u=-0B11100_0+(f[0x003][0X9]((f[0X3][0x9](m,(0)))-m+m,(0b00)));continue;else if u<26 then if C then C=m;end;break;end;end;end;until false;if not C then C=D[I];end;u=0B1011001;repeat if u<0X59 then C=D[I];break;elseif u>0X64 then C-=b;M=M(C);u=(0B10101+((f[0X3][0b1101]((f[0X3][0X0D](m,(0Xe))),(0b11_1_10)))-u+m));elseif u<0X064 and u>54 then b=D[I];C+=b;u=0B11001_00+(f[3][0B1001](u-u+m-m,(16)));else if not(u>89 and u<0B1110011_)then else b=D[I];u=0XF+((f[0X00__3][0X8]((f[0X3][7]((f[0B0_11][8](u,m,m)),m,u)),m))<=m and u or m);end;end;until false;M-=C;u=0X24;while true do if not(u>0X24)then C=D[I];u=(0B01010111+((f[3][0Xd](m+m-m,(0XB)))-u));continue;elseif not(u>=0X76)then M+=C;Y+=M;u=(67+((f[0B11][0Xd]((f[0X3][0X6]((f[0B11][0b1__01](u)))),(1)))~=m and u or u));else T+=Y;break;end;end;u=(0X2__8);while true do if u<0x67 and u>49 then M=M<C;T[Y]=(M);break;else if u>0x5c then T=(e);Y=(x[I]);u=0B1101__0+(f[0B11][0b1100]((f[3][0X6_]((f[0X3][0xA]((f[0x3][0XA](m,u,m)))))),(0X1e)));else if u>26 and u<0B11_0001 then D[I]=(T);u=(0xFb+((f[0B11][0B1010]((f[3][0B111](m-m))))-m));continue;elseif u>0X28 and u<0B1011100 then C=H[I];u=0x005C+(f[3][0x7]((f[0x3][0B111]((f[3][0B111](m+u,m)),u)),m));else if u<0x28 then M=(k[I]);u=-0X63+((f[0B11][10]((f[0x3][0B110]((f[0B11][0X7](u,m)))),u))~=u and m or m);continue;end;end;end;end;end;else local u=false;i+=W;if W<=0B0 then u=(i>=L);else u=(i<=L);end;if not(u)then else e[n[I]+3]=(i);I=(o[I]);end;end;end;end;end;else if m>=0B10001100 then if m<0x8F then if not(m<141)then if m==0X08__e then q=(x[I]);p=k[I];else local u=A[o[I]];(u[1][u[0b11]])[e[x[I]]]=e[n[I]];end;else h=nil;end;else if m>=0B10010001 then if m==0B0010__0_10010 then S=(nil);else local u=k[I];local M=u[0XB];local T=#M;local Y=(T>0 and{});local b=f[0X3d](u,Y);(f[0X00__29])(b,w);(e)[x[I]]=(b);if Y then for C=0X1,T do b=M[C];u=b[0X1];local M=(b[0B11]);if u==0X0 then if not(not X)then else X=({});end;local T=X[M];if not T then T={[0X3]=M,[0B1]=e};(X)[M]=(T);end;(Y)[C-0x1]=T;else if u~=0X1 then(Y)[C-1]=(A[M]);else Y[C-1]=(e[M]);end;end;end;end;end;else if m==0B10010000 then h=(e);q=(n[I]);p=(e);else(A[x[I]])[k[I]]=(H[I]);end;end;end;else if not(m>=0b10001001)then if not(m>=135)then q=n[I];h=(h[q]);q=(k[I]);else if m==0b10001000 then h=e;q=o[I];p=e;else h=e;q=o[I];p=H[I];end;end;else if not(m<0b10001010)then if m~=0b00__1000101__1 then e[x[I]]=o;else p=w;S=(H[I]);p=(p[S]);end;else local u=(o[I]);E=(u+x[I]-0X1);for M in e do if not(M>E)then else(e)[M]=nil;end;end;(e[u])(f[0B11_011](E,e,u+0X1));E=(u-0B1);for u in e do if u>E then(e)[u]=(nil);end;end;end;end;end;end;end;else if not(m>=0B10__111100)then if m>=0xAE then if m<181 then if m<0XB1 then if not(m<0B10101111)then if m~=0XB0 then local u=A[x[I]];(e)[o[I]]=u[0b1][u[0X3]];else local u=(n[I]);if not(X)then else for M,T in X do if M>=u then(T)[1]=T;(T)[0B10]=e[M];(T)[0B11]=(0x2);X[M]=nil;end;end;end;end;else h=(nil);end;else if not(m<0xb3)then if m~=180 then h=A;else(e)[o[I]]=e[x[I]]..H[I];end;else if m~=0X00b2 then if not(e[x[I]]<=k[I])then I=n[I];end;else local u=(n[I]);local M=(e[u]);local T=o[I];f[0B11100](e,u+0B1,u+x[I],T+0x1,M);end;end;end;else if not(m>=0b10111000)then if m>=182 then if m~=0b10110111 then h=(e);else(e)[o[I]]=(e[n[I]][e[x[I]]]);end;else if not(X)then else for u,M in X do if not(u>=0B1)then else M[0x1]=M;(M)[0X2]=e[u];M[0b11]=0X2;(X)[u]=(nil);end;end;end;return false,x[I],E;end;else if m<186 then if m==185 then J=nil;else S=x[I];p=p[S];end;else if m~=0B10_111011 then e[n[I]]=(e[x[I]]%e[o[I]]);else S=(S[g]);end;end;end;end;else if not(m>=0xa7_)then if not(m>=0xA4)then if not(m>=0B10100010)then local J,u,M,T,Y,b,C=0x2E,0b1000;repeat if J==0b1__01111 then T=(f[0x3]);J=(0B10100_00+((f[0b11][0X7](o[I]-m+o[I],J))-J));elseif J==57 then C=(f[0X3]);break;elseif J==0X42 then C=0b101;T=T[C];J=-4294967048+(f[0X3_][8]((f[0X3][0xc__](J-m,o[I]))-o[I]));continue;elseif J==0X35 then b=(0X0);T=4503599627370495;J=(-0x25+((f[3][0b1_100]((f[0X3][0xA](m)),o[I]))-m==m and J or J));continue;else if J==0B10000 then b*=T;J=0X2F+(f[0X3][0x5]((J<m and o[I]or J)+J-m));else if J==0X2e then M=0X28;J=(7+((f[0X3][0xd_](J+J,o[I]))-m>o[I]and J or J));end;end;end;until false;C=C[u];u=(f[0X3]);local B,v;J=0b10111__00;repeat if not(J>0X00b)then u=u[B];break;else B=0B1000;J=(-150+(f[0B11][0xA](((f[0B11][13](m,o[I]))>o[I]and m or J)<J and o[I]or o[I],m)));end;until false;B=(f[3]);J=0b1;while true do if J==0x6C then B=B[v];break;else if J~=0X1 then else v=0b101_0;J=0x06C+((m+m+J==m and J or m)-m);continue;end;end;end;v=o[I];J=(22);repeat if J==56 then Y=(o[I]);J=-0X6a+(f[0X3][0Xa]((f[0X3][7]((f[0X3][5](J-J)),J)),m));else if J==0X37 then v=(v>=Y);J=0B100111+(f[0x3][0xB]((f[3][0xe]((f[0B11][0x8]((f[3][13](m,o[I])))),o[I]))));continue;else if J==0x7D then v+=Y;J=-4294967241+((f[0B11][6](J-o[I]-o[I]))+J);else if J==0X16 then Y=(m);J=0x7b+(f[0b11][0Xb]((f[0b11][0X9](o[I],(J)))-J-J));continue;else if J==0B101010 then if v then v=D[I];end;break;end;end;end;end;end;until false;if not v then v=o[I];end;Y=m;J=(0X30);repeat if J~=48 then v=m;break;else B=B(v,Y);J=-4294967216+(f[0X3][0B110_]((f[0b11][0X7]((m<o[I]and J or o[I])+o[I],m,J))));continue;end;until false;B=(B<v);if not(B)then else B=o[I];end;if not B then B=(o[I]);end;v=(o[I]);J=0X13;repeat if J==0x13 then B-=v;J=(-4294967050+((f[0b11][0X6](J~=m and m or o[I]))+o[I]+o[I]));continue;else if J==0B1010110 then u=u(B);break;end;end;until false;C=C(u);T=T(C);b+=T;M+=b;D[I]=(M);J=0X1E;while true do if J>0B0 and J<0X65 then M=w;b=(G[I]);T=e;J=11+(((f[3][12](o[I],(J)))<m and J or J)+J+J);else if J<0x1E then T=T[C];(M)[b]=T;break;else if J>0B111__10 then C=o[I];J=-2147483663+(f[0X3][14]((f[0x3][0b10__1]((f[0X3__][0b1001](o[I],o[I]))>J and m or o[I])),o[I]));end;end;end;end;else if m==0XA3 then(e)[o[I]]=r;else e[o[I]]=(f[0x2b](e[n[I]],G[I]));end;end;else if m>=0b10100101 then if m==0B10100110 then i=P[0X4];L=(P[0b1]);W=(P[0X3]);P=P[0B101];else h-=q;E=h;for r in e do if not(r>E)then else(e)[r]=(nil);end;end;end;else E=n[I];for r in e do if not(r>E)then else(e)[r]=nil;end;end;(e)[E]=e[E]();for r in e do if not(r>E)then else(e)[r]=(nil);end;end;end;end;else if m<170 then if not(m>=0X0A8)then(e)[o[I]]=(H[I]~=G[I]);else if m==0xa9 then e[o[I]]={};else(e)[n[I]]=(G[I]+k[I]);end;end;else if not(m<0XA_c)then if m~=0x00ad then h=(e);q=(n[I]);p=e;else local r=(A[n[I]]);r[0B1][r[0X3]][G[I]]=(e[o[I]]);end;elseif m==0B10101011 then(e)[x[I]]=(k[I]<H[I]);else(e)[n[I]]=f[0b1__10001](o[I]);end;end;end;end;else if not(m>=201)then if m>=0B110_0_0010 then if not(m<197)then if m>=0B11000111 then if m~=0B1_100100_0 then E=(n[I]);for r in e do if r>E then(e)[r]=nil;end;end;(e[E])();E-=1;for r in e do if not(r>E)then else(e)[r]=nil;end;end;else(e)[o[I]]=(e[n[I]]%G[I]);end;else if m==0B11000110 then e[n[I]]=(e[o[I]]);else(h)[q]=p;end;end;else if not(m>=195)then if not(k[I]<=e[n[I]])then I=x[I];end;else if m~=196 then(e)[x[I]]=k[I]==H[I];else p=e;S=(x[I]);p=(p[S]);end;end;end;else if not(m<0B1011111__1)then if not(m<0B11000000)then if m==0b11000001 then e[n[I]]=(f[0X2B](e[o[I]],e[x[I]]));elseif e[o[I]]==G[I]then else I=(n[I]);end;else q=o[I];h=h[q];q=G[I];end;else if not(m<189)then if m~=190 then e[o[I]]=(G[I]>H[I]);else(e)[n[I]]=(#e[o[I]]);end;else e[n[I]]=e[o[I]]+G[I];end;end;end;else if not(m<208)then if not(m>=0X00D3_)then if not(m>=0Xd1)then local r=A[x[I]];r[0B1][r[0x3]]=(e[n[I]]);else if m==0b110__10010 then local r,J=n[I],x[I];if J~=0b0 then E=(r+J-1);for u in e do if u>E then e[u]=(nil);end;end;end;local u,M,T=o[I];if J~=0B1 then M,T=f[60](e[r](f[0X1B](E,e,r+0X1)));else M,T=f[0X3c](e[r]());end;if u==1 then E=r-0B1;else if u==0 then M=M+r-0b1;E=(M);else M=r+u-0X2;E=M+0X1;end;J=(0X00);for u=r,M do J+=0X1;e[u]=T[J];end;end;for r in e do if r>E then e[r]=(nil);end;end;else S=f[0X1C];g=(e);s=(h);a=(0X1);s+=a;a=E;F=(q);d=0X1;F+=d;d=(p);(S)(g,s,a,F,d);end;end;else if m>=0XD5 then if m==0Xd6_ then g=nil;else h=e;q=n[I];end;else if m==0B11010100 then local r=A[o[I]];r[0b1][r[0X3]][H[I]]=G[I];else p=(H[I]);end;end;end;else if not(m<0b11_001100)then if m<0Xc_e then if m~=0Xcd then(e)[o[I]]=e[x[I]]-e[n[I]];else p=(H[I]);S=e;g=x[I];end;else if m~=0b0011001111 then p=A;else e[o[I]]=(e[x[I]]+e[n[I]]);end;end;else if m>=0xCA then if m==0B110__01011 then p=(p..S);else p=A;S=(o[I]);end;else local r=(y-O-0x1);if r<0x0 then r=-0X01;end;local y,a=x[I],0X0;for d=y,y+r do(e)[d]=(N[K+a]);a+=0X1;end;E=y+r;for r in e do if not(r>E)then else e[r]=(nil);end;end;end;end;end;end;end;end;else if m>=0B110101 then if not(m<0X50)then if m>=0X5_d then if m>=0X064 then if not(m>=103)then if not(m<0X65)then if m~=0X66 then h=x[I];else e[x[I]]=(k[I]-H[I]);end;else local r=x[I];E=(r+0X2__);for y in e do if y>E then(e)[y]=nil;end;end;e[r]=e[r](e[r+0B1],e[r+2]);E=(r);for r in e do if r>E then e[r]=(nil);end;end;end;elseif not(m>=0X69)then if m~=0x68 then e[n[I]]=(not e[x[I]]);else(e)[x[I]]=H[I]*e[o[I]];end;else if m==0x6a then if not(X)then else for r,y in X do if not(r>=0X1)then else(y)[0X1]=y;y[2]=(e[r]);y[3]=(2);(X)[r]=nil;end;end;end;local r=(x[I]);E=(r+0x1);return true,r,2;else e[n[I]]=f[0B11][o[I]];end;end;else if not(m>=96)then if not(m<0X05e)then if m~=0X5F then if X then for r,y in X do if not(r>=0X1)then else y[0X1]=(y);(y)[0b10]=(e[r]);y[0X3]=(2);X[r]=(nil);end;end;end;local r=(n[I]);return false,r,r;else S=x[I];p=(p[S]);end;else h[q]=p;end;else if not(m>=0X62)then if m==0x61 then S=x[I];else O=(x[I]);for r=0b1,O do(e)[r]=N[r];end;K=(O+0X1);end;else if m==0X63 then if e[o[I]]~=e[n[I]]then I=(x[I]);end;else local r=(A[o[I]]);(r[0X1])[r[3]]=H[I];end;end;end;end;else if m>=0X56 then if m>=0b1011001 then if not(m<0x5B)then if m==92 then if not(e[x[I]]<=e[o[I]])then I=n[I];end;else(e)[n[I]]=e[x[I]]..e[o[I]];end;else if m~=90 then local r=o[I];E=(r+0X1);for y in e do if y>E then e[y]=(nil);end;end;e[r]=e[r](e[r+1]);E=r;for r in e do if not(r>E)then else e[r]=nil;end;end;else if not(e[x[I]])then else I=(o[I]);end;end;end;else if not(m<0x57)then if m~=0B10110_0__0 then if not e[x[I]]then I=n[I];end;else q=nil;end;else S=(S[g]);p=p[S];end;end;else if not(m<83)then if m>=0X54 then if m~=0B1010101 then(e)[x[I]]=D;else(e)[n[I]]=e[o[I]]//e[x[I]];end;else local r=(x[I]);E=r+1;for y in e do if not(y>E)then else e[y]=nil;end;end;(e[r])(e[r+0X1]);E=r-0x1;for r in e do if not(r>E)then else e[r]=nil;end;end;end;else if m>=0X51 then if m~=0B1010010 then p=p[S];S=(G[I]);p=(p[S]);else h=n[I];q=(x[I]);for r=h,q do p=(e);S=r;r=nil;(p)[S]=r;end;end;else S=o[I];p=p[S];end;end;end;end;else if m<0X42 then if m<59 then if m<0x38 then if not(m>=0B110110__)then h=(e);q=o[I];else if m~=0X37 then h=e;q=o[I];else e[o[I]]=(H[I]..e[x[I]]);end;end;else if m<0X39 then S=(e);g=x[I];S=(S[g]);else if m~=58 then e[n[I]]=(e[o[I]]==G[I]);else p=(nil);end;end;end;else if not(m>=62)then if m>=60 then if m==0X03__d then S=e;g=x[I];else local r=(A[o[I]]);(e)[n[I]]=r[1][r[0b11]][e[x[I]]];end;else S=(H[I]);p-=S;end;else if not(m<64)then if m~=65 then S=(n[I]);else e[o[I]]=e[x[I]][H[I]];end;else if m~=0X3F then h=n[I];q=x[I];else p=A;S=o[I];end;end;end;end;else if not(m<73)then if m>=0X4C then if m<0X4e then if m~=77 then e[o[I]]=(H[I]);else p-=S;(h)[q]=(p);end;else if m~=0b1001111 then(e)[n[I]]=(A[o[I]][G[I]]);else(e)[o[I]]=e[n[I]]>G[I];end;end;else if m<0X4A_ then S=(H[I]);p=p[S];else if m~=0X4b then e[n[I]]=e[o[I]]==e[x[I]];else local r,y,O,K,a,d=0B101101;while true do if not(r>0X28)then if r~=0X28__ then y=(f[3]);a=0X5;break;else y=(4503599627370495);r=0B111__00+(f[0b11][0B111]((m>m and m or r)+m<m and m or m));continue;end;else if r~=0X2D_ then d*=y;r=(0X81+(((f[3][6](m))<=r and r or r)-r-r));continue;else d=0X0;r=(-4294967090+((f[0X3][0X06]((m==m and m or m)+r))-r));continue;end;end;end;y=y[a];local J,u=(0X39);r=0x23;while true do if not(r>38)then if r==0x26 then u=0B110;r=52+(f[0B11][0B101]((f[0x003][10]((f[0X3][0XA](r,m))-r,m))));continue;else a=(f[3]);r=(-1277914+(f[3][0X9]((f[0x3][8]((f[0X3][6](r)),r,r))+m,(0Xf))));continue;end;else if r<77 then u=f[0x3];break;else a=a[u];r=-0x4cFfb8+(f[0x3][8]((f[0x3][0X9__]((f[0B11][0X7](m>r and r or r,r,r)),(16)))));end;end;end;r=(91);while true do if r<0X5B then O=f[0b11];r=0B10101+((f[0B11_][0Xb](m+r+m))+m);elseif r<0B11__11110 and r>0X5B then K=0X6;break;elseif r<0x6__0 and r>0B1000101 then O=6;r=(-4294967019+(f[3][0B110](((r>=m and m or r)==r and m or m)+m)));elseif not(r>0B01100000)then else u=u[O];r=-258+(m+r+r+r-r);continue;end;end;r=98;while true do if r==0b1011001 then K=(m);r=0b1100010+(f[3][0B1011]((f[0x3][0X6]((f[3][5](m))~=r and m or r))));elseif r==0x73 then u=u(O);break;elseif r==98 then O=O[K];r=(0X42+(((f[0b11][0X6]((f[3][12](m,(13)))))==r and m or r)-m));elseif r~=100 then else O=O(K);r=(0X28+((f[3][0Xa]((f[0B11][0X9](m,(0X0)))<=r and m or r,m))>m and m or m));continue;end;end;a=a(u);u=(D[I]);a=a<u;if not(a)then else a=(D[I]);end;if not(not a)then else a=(D[I]);end;u=(m);r=12;while true do if r<123 and r>0x0c then a=(m);break;elseif r>0B11110 then y=y(a);r=(0X1e+(f[0X3][0B1_101](((r<m and r or r)<=m and r or m)+m,(0Xe))));elseif r<0X1e then a-=u;r=(-921402+((f[0B11][0b1100](m+m+m,(r)))-m));end;end;y+=a;r=0X8;while true do if r>0x8 then if r>=122 then if y then y=(D[I]);end;break;else y=y>a;r=(122+(((f[0X3][0Xb](r))-m<m and m or m)-m));continue;end;else a=(m);r=(-0X4Ab9+(f[0X3][0Xc](r-r+m<=m and m or m,(r))));continue;end;end;if not y then y=m;end;r=0x77;while true do if r==119 then d+=y;r=0x6a+((f[0b11][0XC](r-r,(26)))+m-m);elseif r==65 then(D)[I]=J;break;elseif r~=0x6A then else J+=d;r=-0xA0__+((f[0x3][0XA](r-r,m))+m+m);continue;end;end;J=(e);r=95;while true do if r==95 then d=n[I];r=(0X1b+(f[0X3][0x5](r+r+m+m)));elseif r==0B00110010 then y=x;r=(0X37+((f[0X3][5](r+r))-r+m));continue;elseif r~=105 then else J[d]=y;break;end;end;end;end;end;elseif not(m>=0b1000101)then if m<0x43 then(e)[x[I]]=(k[I]<=H[I]);else if m==0X44 then(e)[n[I]]=nil;else(e)[n[I]]=(A[x[I]]);end;end;else if not(m<0X4_7)then if m==72 then(w)[G[I]]=e[o[I]];else if not(not(e[o[I]]<e[x[I]]))then else I=n[I];end;end;else if m==0x46 then e[n[I]]=n;else local r=(o[I]);E=r+x[I]-0X1;for y in e do if not(y>E)then else(e)[y]=(nil);end;end;(e)[r]=e[r](f[0B110_11](E,e,r+0b1));E=(r);for r in e do if r>E then(e)[r]=nil;end;end;end;end;end;end;end;else if not(m<0X1a)then if m>=0X27 then if not(m<0B101110)then if m<0X31 then if not(m>=0b101111)then q=(o[I]);p=e;S=h;else if m~=0B110000 then for r=n[I],x[I]do(e)[r]=nil;end;else e[n[I]]=(e[x[I]]<e[o[I]]);end;end;else if not(m<0X33)then if m==0x034 then if not(not(e[n[I]]<G[I]))then else I=(o[I]);end;else for r=0X1,n[I]do e[r]=(N[r]);end;end;else if m~=50 then else F=(nil);end;end;end;else if not(m<0x2a)then if not(m>=44)then if m~=0X0_02b then q=o[I];else if e[n[I]]==G[I]then I=o[I];end;end;else if m~=0x2D then local r=o[I];local y,D,N=i();if y then(e)[r+0B1]=D;e[r+0B10]=(N);I=(x[I]);end;else local r=(n[I]);E=r+2;for y in e do if not(y>E)then else e[y]=nil;end;end;e[r](e[r+0X1],e[r+0X2]);E=(r-0x1);for r in e do if r>E then(e)[r]=(nil);end;end;end;end;else if not(m>=0X28)then if e[x[I]]==e[n[I]]then I=(o[I]);end;else if m==0X2_9 then local r,y=n[I],e[x[I]];e[r+0b1]=y;(e)[r]=(y[k[I]]);else p=p[S];end;end;end;end;else if not(m<32)then if not(m<0X23)then if not(m>=0X25)then if m~=36 then h();h=E;else(e)[o[I]]=(e[n[I]]>=e[x[I]]);end;else if m==38 then h=e;q=o[I];p={};else h=(e);q=(n[I]);p=nil;end;end;else if not(m>=0X21_)then local r,y=x[I],(n[I]);E=(r+y-1);for D in e do if not(D>E)then else e[D]=nil;end;end;if X then for D,N in X do if D>=0x1 then N[1]=(N);N[0X2]=(e[D]);(N)[0X3]=(0X2);X[D]=nil;end;end;end;return true,r,y;else if m==0B100010 then(e[n[I]])[k[I]]=(e[x[I]]);else q=x[I];end;end;end;else if not(m>=0x1_d)then if not(m>=0X1B)then(e)[n[I]]=(G[I]^e[o[I]]);else if m~=0X1C_ then h=n[I];E=(h);for r in e do if not(r>E)then else e[r]=nil;end;end;else local r=(o[I]);for y in e do if not(y>E)then else(e)[y]=nil;end;end;e[r](f[0B1_1_011](E,e,r+1));E=r-0X1;for r in e do if r>E then(e)[r]=nil;end;end;end;end;else if m>=0X1E then if m==0B11111 then p=p[S];S=G[I];p=p[S];else A[x[I]][k[I]]=e[n[I]];end;else g=(nil);end;end;end;end;else if m<0xd then if m<6 then if m>=3 then if m>=0X4 then if m~=5 then(f[0X3])[o[I]]=e[n[I]];else h=(e);q=(n[I]);p=G[I];end;else p+=S;(h)[q]=(p);end;else if not(m<0X1)then if m~=0X2 then S=(x[I]);p=(p[S]);S=e;else p=(w);S=H[I];p=(p[S]);end;else(e)[x[I]]=H[I]-e[o[I]];end;end;else if m>=0b1001 then if not(m<0xB)then if m==12 then q=nil;else S=(o[I]);end;else if m~=0xA_ then s=nil;else(e)[o[I]]=-e[n[I]];end;end;else if not(m<7)then if m~=0X8 then q=(1);else P={[3]=W,[0b101]=P,[0X1]=L,[0X4]=i};local r=o[I];W=(e[r+0X2]+0);L=e[r+0X1]+0x00;i=(e[r]-W);I=x[I];end;else e[o[I]]=(H[I]+e[x[I]]);end;end;end;else if m>=0X13 then if m>=0b10110 then if not(m<0b11000__)then if m~=0B11001 then if X then for r,A in X do if not(r>=0X1)then else A[0B1]=(A);A[0X2]=e[r];A[0X3]=2;X[r]=(nil);end;end;end;return;else e[x[I]][e[o[I]]]=(H[I]);end;else if m~=0B10111 then e[o[I]]=e[n[I]]/e[x[I]];else p=p(S);end;end;else if not(m>=0x14)then h=(e);else if m~=0B10101 then q=(k[I]);p=e;else q=(n[I]);p=(f[0x31]);end;end;end;else if not(m<0X10__)then if not(m<0X11)then if m==0B1_0010 then e[o[I]]=e[x[I]]*e[n[I]];else P=({[0X3]=W,[0B101]=P,[0X001]=L,[0x4_]=i});E=o[I];local r=f[0X28](function(...)(f[0X3b])();for A,y in...do(f[0x3b])(true,A,y);end;end);(r)(e[E],e[E+1],e[E+0X2]);for A in e do if not(A>E)then else(e)[A]=nil;end;end;i=(r);I=(x[I]);end;else local r,A=x[I],o[I];local y=(e[r]);f[0B11100](e,r+0x1,E,A+0B1,y);end;else if not(m<0xE)then if m==15 then h=h[q];elseif not(k[I]<e[n[I]])then I=x[I];end;else q=(G[I]);p=(H[I]);end;end;end;end;end;end;end;I+=1;end;end);if j then if U then if R~=0b1 then return e[l](f[0x1b](E,e,l+1));else return e[l]();end;else if not(l)then else return f[27](R,e,l);end;end;else if X then for r,A in X do if r>=0X1 then A[1]=(A);(A)[0B10]=(e[r]);(A)[0X3]=(0x2);(X)[r]=(nil);end;end;end;if f[0X23](U)~='\s\u{74}ri\110\u{67}'then(f[0X26_])(U,0B0);elseif not(f[0b10__0111](U,":\z (%\zd\z \x2B)[\x3A\x0D\x0A\x5D"))then f[0X26](U,0x0);else f[38]("\76ura\z ph\u{0020}\83cri\p\z\u{074}:"..(z[I]or"\40\105nt\101rna\u{6C})")..':\32'..f[0XE](U),0X0);end;end;end;return Z;end);f[0x3E]=(nil);t=nil;V=nil;return c,t,V;end,C5=function(r,r)r=0X7c;return r;end,R={36573,1710985504,1298096646,2516319384,1383663380,983263336,467192080,3654532065,520332205},V5=function(r,A)local c,t,f;for V=0b1000011,312,104 do c,f,t=r:x5(A,V,f);if c==0b1110 then continue;else if c~=-0B10 then else return-0X002,t;end;end;end;return nil;end,bK=function(r,A,c)if c<0b01001__0100 then r:hK(A);else if c>0x76 then while A[0x1B_]do A[0X3a],A[48]=A[0b1__10101],(92<0X66)/(0b111010__10*189);return-1;end;end;end;return nil;end,n5=function(r,A,c,t)if A<0X67 then c[59]=coroutine.yield;return 53208,A;else if A>0x1A then c[0X3a]=(function()local f,V;f,V=r:a5(c);if f==-0X2 then return V;end;end);if not t[0XEA5]then t[0X6_Fc0]=(-2+((r.zK(t[26312]+t[8992]+t[0Xd97]))>=r.R[0X3]and t[10786]or t[0x2889]));A=-983263333+(r.zK((r.cK((r.rK((r.CK(t[24182],(t[8985]))),(t[0x43__5d]))),t[10786],t[10786])),t[0X1951],r.R[0B110]));t[3749]=(A);else A=t[0x00EA5];end;end;end;return nil,A;end,D=function(r,A,c,t,f)f[0B1100]=c[r.j];if not(not t[0X27a3])then A=t[0X27A3];else A=(-4709019184+((r.uK((r.uK(r.R[7]-r.R[0b10__01]))))+r.R[0X007]));(t)[0X27a3__]=(A);end;return A;end,u=bit32.countlz,lG=function(r,r,A)A=r[0x36]();return A;end,jK=function(r,A)local c;for t=0x0076,0X9_4,0B11110 do c=r:bK(A,t);if c~=-0x1 then else return-0x1;end;end;return nil;end,HG=function(r,A,c,t,f)t=(0B1000000);if f[0X1A]==f[0B101100]then(f)[6],f[0B01111]=(175 or 0Xbd)/f[47],f[0b111010];else if not(A<=180)then c=r:IG(c,f);else c=f[47]();end;end;return c,t;end,MK=function(r,A,c,t,f,V)local Z,y;A=(0X0034);while true do if A>6 then if A==0X2D then y=f();break;else(V)[62]=(function()local z;z=(nil);local D,n,G,x,o;o,x,n,G=r:B5(x,V,n,G,o);local H,k,E,e,I,P;E,e,D,H,k,I,P=r:A5(I,x,G,P,k,n,E,H,V,e);if D==-1 then return;end;local X,i;i,D,X,z=r:_G(H,x,e,o,P,k,n,i,V,I,E,G,X);if D==-0B1 then return;else if D~=-0B10 then else return z;end;end;i,D,X,z=r:QG(V,X,i,x);if D==-2 then return z;end;for z=0X7__e,343,0X54 do if z==0x7E then x[0X8]=(X);elseif z==0Xd2 then for D=0X1,V[48]()do H=r:zG(X,V,H);end;continue;else if z==294 then return(r:wG(x));end;end;end;end);if not(not c[8223])then A=c[8223];else A=(-0X4A22C__8__5e+((r.cK((r.zK(c[17245]))+c[23822],r.R[0X2]))-r.R[0X7]));c[8223]=(A);end;continue;end;else if A>3 then t=function(...)local z;z=r:EG(...);return r.Y(z);end;if not c[24308]then A=(0x2d+(r._K((r.YK(c[6228]-r.R[0X7]+c[6021])))));c[24308]=A;else A=(c[24308]);end;else f=(function()local z;z=(nil);local D,n,G,x,o;n,x,o,z,G,D=r:ZK(o,n,V,G,x);if z==-1 then return;else if z==-0B10 then return D;end;end;(V)[2]=V[49](x*0X3);n=(104);repeat z,n=r:mK(o,n,x,V,G);if z==0XBB4_1 then break;else if z~=-0X1 then else return;end;end;until false;G=(o[V[52]()]);if V[0X2_4]~=V[0b1011]then z,D=r:vK(V,G);if z==-0B1__0 then return D;end;end;end);if not(not c[0X6EF2])then A=(c[0x006Ef2]);else(c)[0X1A9_]=0X55+(r.YK((r.TK(r.R[0X9_]))-c[0X65__e1]==c[17868]and c[0X68a6]or c[0X2320]));A=-1710986200+((r.gK(c[0X435d]+c[0X41_15],(c[0x201F])))-c[0X5952]+r.R[2]);c[28402]=A;end;continue;end;end;end;A=0b1111100;repeat if not(A>0X15)then if A<0b1010_1 then(V[0x3])[0B101]=r.u;if not c[17133]then A=-4294967151+((r.uK((r.pK((r.TK(c[6481])),(c[0x4E0A])))))-c[26081]);c[0X42eD]=A;else A=r:LK(c,A);end;else(V[0X3])[0b1100]=(r.r.lshift);if not(not c[0x4768])then A=c[18280];else A=-7+((r.cK((r.uK((r.cK(c[23431])))),r.R[4]))>r.R[0X7]and c[0X1951_]or c[18107]);c[0X4768]=(A);end;end;else if not(A<=43)then if A==112 then r:UK(V);break;else if V[0B111100]==V[0b101100]then else for z=120,0X12_4,90 do Z=r:PK(z,V);if Z==0X990b then break;end;end;V[0X3][9]=r.gK;V[0B11][0B001000]=r.g;V[0X3][0Xe]=r.p;V[0x3][10]=r.T;(V[0B11])[7]=r.c;end;if not c[0X7d__c3]then A=(-4289200085+(r.pK((r._K((r.cK(c[19978]))-c[0x50B3])),(c[0X2319]))));(c)[0x7dC3]=(A);else A=(c[0X07Dc3]);end;continue;end;else(V[0x3])[0B10_11]=r.Q;if not c[0X846]then A=r:sK(A,c);else A=c[0X846];end;continue;end;end;until false;y=V[0X3D](y,V[0X2C])(r,f,r.d,V[0X1a],t,V[55],V[42],V[50],r.R,V[61]);return A,t,{V[61](y,V[0b101100_])},f;end,qK=function(r,A,c)for t=0X27,0Xa3,0x7C do r:kK(c,t,A);end;end,t=function(r,A,c,t,f)(A)[0B1100__0]=nil;A[0X19]=nil;t=47;repeat if t<57 then A[21]=c[r.m];A[0x16]=r.N;if not(not f[25402])then t=(f[25402]);else(f)[0X1951]=(-4130484745+(r.pK((f[31743]+f[0X613e]<r.R[0B01]and r.R[7]or f[22866])-f[0X68a6],(f[24894]))));t=0X42+(r.TK((r.cK(f[0X66C8]+f[6021]<=f[0X6_6c8]and r.R[7]or f[6021]))));f[0x633A]=t;end;elseif t<0X44 and t>0B111001 then t=r:A(f,A,t);continue;elseif t>66 then A[0B11001]=(4503599627370496);break;else if not(t<0B1000010 and t>0X002F)then else A[0B11__0__00]=r.O;if not f[0X7BAb]then(f)[0x5_d_0E]=(-0X4d5F61f9+(((r.rK(r.R[0B11_0],(f[24894])))+r.R[0X8]<f[22866]and f[6228]or r.R[0X3])+f[0x2_889]));t=-4294967110+(r.zK((r.YK((r.pK(r.R[0X4],(f[0X613E])))))-f[6481]));f[0X7BaB]=(t);else t=(f[0x7bab]);end;continue;end;end;until false;return t;end,XG=function(r,r,A)r=#A;return r;end,JG=function(r,r,A)A=r[0B110010]();return A;end,oG=function(r,r,A)(A)[0b101]=A[0B11000__1__](r);end,w=function(r,A,c)A[0x2320]=-4130489651+(r.gK((r.R[0X7]-r.R[0B111]<r.R[0B0011]and r.R[0B111]or r.R[4])+c,(A[24894])));c=-2699718004+(r.CK((r._K((r.pK(c,(c))),A[24894],r.R[0X6]))>r.R[8]and r.R[0X2]or r.R[0x6__],(c)));(A)[0x1785]=c;return c;end,KG=function(r,r,A)A[0x3A],A[0B10010]=A[0x23],(r);end,H5=function(r,A,c,t,f,V)if c>0X017 and c<0B11_10101 then r:t5(V,A);return 31991;else if c<0X46 then r:I5(t,V);return 31991;else if c>0B1000110 then(V)[0B1010]=(f);return 0Xb5eA;end;end;end;return nil;end,dG=function(r,A,c,t,f,V)local Z;A=nil;V=nil;for y=0X6a,115,9 do V,Z,A=r:RG(t,V,y,f,A);if Z==0xda46 then continue;end;end;if t[0B110110]==t[0x7]then else(A)[V+0B001]=c;end;return V,A;end,xG=function(r,r,A)A[0B10110]={};r=(0b101010);return r;end,m='\99opy',OG=function(r,r,A,c,t)A=(0X6D);t[r+0B1]=(c);return A;end,ZG=function(r,A,c,t,f)if f~=A[11]then r:NG(f,c,t);end;end,B5=function(r,A,c,t,f,V)t=(nil);f=nil;A=nil;V=(nil);local Z=(40);while true do if Z==0B110001 then V=r:W5(t,V,c);break;elseif Z==103 then Z=0X1a;f=c[0X3__1](t);elseif Z==0x1a then Z=(0B110001);A={r.N,nil,nil,nil,r.N,nil,r.N,r.N,nil,nil,r.N};else if Z~=0X28 then else Z=(0X67);t=(c[0b110100]()-10435);end;end;end;return V,A,t,f;end,GG=function(r,A,c,t,f,V,Z)if V>125 then return 0X5b42,c;else if V<0Xa5 then c=r:BG(c,t,A,f,Z);end;end;return nil,c;end,h='r\z\x65a\x64u8',a5=function(r,r)local A,c;for t=101,374,113 do if t==0B11010110 then c=r[0x4](A);else if t==0X65 then A=r[0X34_]();else if t~=327 then else(r[0X1_5])(c,0,r[37],r[0B100000],A);(r)[32]=(r[0X20]+A);return-2,c;end;end;end;end;return nil;end,L5=function(r,r,A)r=(A[0X65E1]);return r;end,CG=function(r,A,c,t,f,V,Z,y,z,D,n,G,x,o,H,k,E)local e,I;(Z)[c]=(o);for P=0X2d,0xa_1,0x5__1__ do e,I=r:gG(H,D,t,o,Z,c,n,y,f,G,E,P,V,x,z,k,A);if e==0XE91d then break;elseif e==8307 then continue;else if e==-0B01 then return-0x1;else if e==-0X2 then return-0X2,I;end;end;end;end;return nil;end,OK=function(r,r,A)(A)[2]=(nil);r=(0X42);return r;end,AG=function(r,r,A)A=r[0X30]();return A;end,O5=function(r,A,c)A=(-0x65Fb9114+((r.CK((r.zK(c[8985],c[0x5952])),(c[0x613e])))+r.R[0B10__0]~=c[0X5D_0e]and r.R[0X2]or c[27928]));(c)[0X4E0A]=(A);return A;end,sG=function(r,r)r[0b110101]=(-21);end,uK=bit32.bnot,G=function(r,r,A)A[0B10100]=(r.writeu32);A[21]=nil;(A)[0B10110]=(nil);A[0B10111]=(nil);end,UG=function(r,A,c)if A[0B0110]==c then if 0X6d then local c=71;repeat if c<0X7A then c=0B111101_0;A[0x3C],A[0X037]=0XF,-A[0X37];else if c>71 then r:sG(A);break;end;end;until false;end;end;end,M=coroutine.wrap,G5=function(r,r,A,c)c=A[0X31](r);return c;end,pK=bit32.lshift,WG=function(r,A,c,t)for f=0X63,202,0x67 do if f==202 then A=c[0x2e]();else if f~=0X0063 then else if c[0B1]~=c[0b11]then else for f=0X4a,233,0X37 do if f<0B10000001 then if c[0X3D]then r:nG(c);end;continue;else if not(f>0B1001010)then else r:KG(t,c);break;end;end;end;end;continue;end;end;end;return A;end,uG=function(r,r,A,c)A[c]=(r);end,dK=function(r,A,c,t)local f;t[0X39]=c;for V=0B1,A do local Z,y,z=0x6f;repeat if Z==0X2 then Z=0b1111_001;z=t[0X2a]();continue;elseif Z==121 then if t[0B110111]~=t[0XB]then else for D=0X24,0X68,0B1000100 do r:yG(t,D);end;end;break;else if Z~=0B1101111 then else y=nil;Z=0x2;end;end;until false;for D=126,0b11001001,0X4B do if D>126 then r:SG(c,t,y,V);else if D<0Xc9 then if not(z<=0X69)then if t[0B110100]==t[0X1]then for V=22,0B11000__000__,0X003F do if V>0x16 then return-0x2,43;else if V<0b101_0101 then if not(t[0x12])then else return-0B10,0Xa7;end;end;end;end;else if z>154 then if z>0Xb2 then local V=0X25;repeat if V>37 then break;else if V<0x40 then y,V=r:HG(z,y,V,t);continue;end;end;until false;else y=-t[42]();end;else local V,D=(0X11);repeat if V==0X11 then D=0X3a;if not(z>0X80)then y=r:XK(y);else for n=0X2_2,0B1_1_1__00011,0x5__A do if n==0X7C then break;else if n==0b10_0010 then if t[0X3D]==t[0X12]then r:fG(A,c,t,D);elseif D==0X18 then return-1;else if z>=0x9A then y=t[0X38]();else y=r:JG(t,y);end;end;end;end;end;end;V=(0B1_1110__0_);else if V~=0B1111_00_ then else r:RK();break;end;end;until false;end;end;else Z=(0X06A);while true do if Z<0X6A then r:DG();break;else if not(Z>0X41)then else if not(z>0B101000)then y=r:tG(c,y,z,t);else local V=(0X71);while true do if not(V>0B11100)then V=0X4B;if not(z<=0B1100101)then for D=125,0XB7,0b101000 do f,y=r:GG(z,y,t,A,D,c);if f~=0x5B4__2 then else break;end;end;else y=r:aG(y);end;elseif V<=0x4b then r:eG();break;else if c==t[0x0036]then return-0X1_;end;V=(0x1c);continue;end;end;end;Z=(0X41);continue;end;end;end;end;end;end;end;end;return nil;end,l5=function(r,r,A,c,t)A[0B101]=r;A[4]=(t);A[0x3]=c;end,F5=function(r,r,A)A=0X77;r[0x20]=r[0x20]+1;return A;end,w5=function(r,A)(A)[54]=function()local c,t,f,V=A[0X11](A[0X25],A[0x20]),0X44;repeat f,t,V=r:z5(c,t,A);if f~=-2 then else return V;end;until false;end;end,YK=bit32.countlz,Z='le\110',P5=function(r,r,A,c)if c==0b1 then c=0B1101100;r=A[0Xa](A[0B1__001__01__],A[32]);return 15847,c,r;elseif c==0X5b then return-2,c,r,r;else if c==0X6C then A[32]=A[0B10_0000]+0b10;c=(0B101__1011);return 0X3D__e7,c,r;end;end;return nil,c,r;end,vG=function(r,r,A,c,t)A[t]=(r[0x5][c]);end,p=bit32.rrotate,f=function(r,A,c)c=(-0x7__2eB90cC+(r.zK((r.uK(A[8048]>=c and r.R[0X5]or A[10377]))-r.R[0B110],A[10786],A[0X27a3])));(A)[12708]=c;return c;end,C=bit32.rshift,UK=function(r,A)A[0x3][0b110]=r.r.bnot;end,r=bit32,q5=function(r,A,c,t)A=54;while true do if A<0B110110__ then(c)[0x2_c_]=({});break;else if not(A>29)then else A=r:k5(A,c,t);continue;end;end;end;(c)[0X2D]=(getfenv);(c)[0X2e]=(nil);c[0X2_f]=(nil);c[0X30]=nil;c[0b110001]=(nil);A=(0B1_00001);return A;end,LG=function(r,A,c,t,f,V)if t<0X6_c then f[2][c+0x003]=A;return 16010,t;else if not(t>0X5b)then else t=r:PG(V,t,f,c);return 0X001c61,t;end;end;return nil,t;end,U5=function(r,A,c,t)A[0X3__0]=function()local f;for V=69,150,26 do if V>0b001000101 then A[0X20]=A[0B100000]+4;return f;else if V<95 then f=A[0B10000](A[0X25],A[0B100000]);end;end;end;end;if not c[0x45cC]then t=r:s5(c,t);else t=(c[0x045CC]);end;return t;end,pG=function(r,r)(r)[52]=0xB6;end,F='\u{063}\114\101\u{061}te',gG=function(r,A,c,t,f,V,Z,y,z,D,n,G,x,o,H,k,E,e)local I,P;if x==45 then A[Z]=D;return 0x2073;else if x~=0B1111110 then else if n==0X004 then if not(G[0X39])then(t)[Z]=G[5][f];else local x,X;X,x=r:dG(x,e,G,f,X);(x)[X+0X2]=Z;x[X+0X3]=(7);end;elseif n==0X3 then local x=0X5f;while true do if x==0X5F then x=0B1_10010__;if G[35]==f then return-0X1;end;continue;else if x==50 then r:ZG(G,V,Z,f);break;end;end;end;else if n==0X5 then if G[0B1]~=G[0xB]then else for x=0xD,0Xb9,0X7d do if x==0XD then(G)[0x1a],G[15]=G[0X6],(0x92);continue;else if x~=0X08_a then else if-0X64<-0X0 then r:FG(H,G);end;break;end;end;end;end;V[Z]=Z+f;else if n==0b0 then V[Z]=Z-f;else if n==0B110 then local V;for n=0x50,0B11011100,0B1000110 do if n>0X50 and n<0xDC then G[0x2][V+0b1]=(t);else if n>150 then G[0X2][V+0B10]=(Z);G[0x2][V+0B11__]=(f);else if n<0B010010110 then V=(#G[0B10]);continue;end;end;end;end;end;end;end;end;if o==0B100 then if not(G[0X39])then c[Z]=G[0X5][y];else local t,V,n=G[5][y],(0X11);repeat P,V,n=r:hG(e,n,t,Z,V);if P==4239 then break;else if P==62960 then continue;end;end;until false;end;elseif o==0X03 then r:bG(Z,y,k);elseif o==0x5 then for t=0X05B,0X1__1a,0X6B do P,I=r:iG(Z,k,G,D,t,y);if P==0X48cC then break;else if P~=-0B010__ then else return-0X2__,I;end;end;end;else if o==0 then(k)[Z]=(Z-y);else if o==6 then local t,V;for n=0b11011,150,0X17 do if n<50 then t=#G[2];continue;else if n>0B11011 then V=0X2F;break;end;end;end;if V==0X02F then for V=0B1101001_,0X75,0xc do if V~=0B1110101 then(G[0X2])[t+0B1]=c;else(G[0X2])[t+2]=Z;end;end;end;G[0X2][t+0B11]=y;end;end;end;if E==0X04 then if o==G[0X33]then for c=0b101101,0B10__11000,0b1110 do P=r:qG(c,G);if P==-0B1 then return-0X1;end;end;else if G[0X39]then local c=G[0X5][D];local t=#c;local V=(70);repeat if not(V>70)then V=r:OG(t,V,e,c);else if V>0X6__8 then V=0B0_01101000;c[t+0B10]=(Z);else r:mG(t,c);break;end;end;until false;else r:vG(G,z,D,Z);end;end;elseif E==0X3 then for c=61,0X8F,0X52__ do if c==143 then A[Z]=(D);else if c~=0x3D then else if G[0X23]~=o then else return-0B1__;end;continue;end;end;end;elseif E==0x5 then for c=105,0xbc,0X53 do if c==0X69_ then r:UG(G,f);continue;else if c==0b10111100 then A[Z]=Z+D;end;end;end;elseif E==0B0 then A[Z]=Z-D;else if E==0X6 then r:MG(z,Z,D,G);end;end;return 0XE91d;end;end;return nil;end,aG=function(r,r)r=(true);return r;end,NK=function(r,A,c,t,f,V)local Z,y;if c<0x4C then Z,y=r:dK(f,V,t);if Z==-0b1 then return-0X1,A;else if Z~=-0B10 then else return-0X2,A,y;end;end;else if c>0X1C then A=t[52]()-3945;return 0xCA7,A;end;end;return nil,A;end,RK=function(r)end,o5=function(r,r,A,c)A=c[0X1F](c[0b100101],c[0X0020],r);return A;end,X=function(r)local A,c,t,f=({});t,f=r:z(t,f,A);local V,Z;Z,V,f=r:o(t,A,Z,f,V);r:y(A);r:S(A);Z=r:e(f,A,t,Z);Z=r:B(f,t,A,Z);r:G(f,A);Z=r:t(A,f,Z,t);r:I(A);Z=r:R5(t,A,f,Z);c,Z=r:N5(Z,t,V,A);if c==-1 then return;end;Z=r:j5(Z,t,A);Z=r:q5(Z,A,t);Z=r:p5(t,A,Z);Z=r:E5(Z,A,t);Z=r:e5(Z,A);V,f=nil;Z,V,f=r:K5(t,Z,V,A,f);Z,f,c,V=r:MK(Z,t,f,V,A);return r.Y(c);end,z=function(r,r,A,c)r={};(c)[0x1]=nil;c[0X2]=nil;A=nil;return r,A;end,MG=function(r,A,c,t,f)local V,Z=(#f[0B10]);f[0B10][V+0B1]=A;A=(0B1101100);repeat Z,A=r:LG(t,V,A,f,c);if Z==0X1c6__1 then continue;else if Z~=0x3E8A then else break;end;end;until false;end,YG=function(r,A,c,t,f,V,Z)V=(0B1);if A%2==0x0 then(t)[f]=(Z-Z%1);else f=c[48]();local A;for y=0X6C,0B11110010,0xb do if y==0X006c then A=c[0B110000__]();continue;else if y==0B1110__111 then r:rG(f,t,Z,A);break;end;end;end;end;return V,f;end,R5=function(r,A,c,t,f)(c)[0x001E]=nil;(c)[0B11111]=(nil);c[0B100000]=(nil);(c)[0B100001]=(nil);(c)[34]=(nil);c[0b1000_11]=nil;(c)[0X24]=(nil);f=0X1c;repeat if f==28 then(c)[0X1E]=r.U;if not A[16661]then f=r:H(f,A);else f=A[16661];end;elseif f==0X4B then(c)[31]=(t[r.P]);if not A[8048]then f=(-0X47+((r.pK(r.R[0B1000]-r.R[6],(A[0X613E])))-A[0x1951]>=A[26790]and A[23431]or A[24894]));A[8048]=f;else f=(A[0X1F70]);end;continue;elseif f==16 then f=r:J(A,c,f);continue;elseif f==0X035 then(c)[0x21]=pcall;if not A[8985]then f=-520332189+((r.zK((r.gK((r.pK(A[0X7BfF],(A[0X613e]))),(A[24894])))))>=A[10786]and r.R[0b1001]or r.R[8]);(A)[8985]=f;else f=(A[0x2319]);end;continue;else if f==0X2E then f=r:X5(A,f,c);continue;else if f==0X2f then c[0x24]=(function(r)r=c[0x1e](r,"z","!\33\x21\z !\z!");local A=#r-0x4;local t=c[0b100]((A/0B101)*0X4);local V,Z=0B0,{};for y=0B101,A,5 do local A=c[29](r,y,y+0X4);y=Z[A];if not y then local r,z,D,n,G=c[0X22](A,0B1,0x5);local x=((G-0B100001_)+(n-0x21)*85+(D-0X21)*7225+(z-0X21)*0X95EE__d+(r-0X021)*52200625);y=x;Z[A]=y;end;(c[0b10__100])(t,V,y);V+=0X4;end;return t;end);break;end;end;end;until false;(c)[0x2_5]=c[0x2_4]([=[LPH?r@bQ,"!Bn&!+25r-D7]f-S?Mr`EId4^acMpD;A054H,tV&BQdLBZUa@OS.0o7CVhdi9b2N^B$FsgK>Dr!a$Q4!a,S1f*:Z#DXh9'f0_q?dSF]!EkG@p,LrYs0P<I;[G/d#*3kFh,E_pJN<\O'[s>V2k?PeC;dd=%,0BDPc$#^rj"0T*mg25O#U=L=%^ag`HD45`G.QO%O>Ec5RqIWFdoE/XdF<K=A/$YnDd;b?/<]T5=bS@^`rb8^*Bk1f@?.m&L5\$&3Z.%"4E5g/?7nThL4&:1d]RE!q=0j[M'X^s%lh>;`:Pt;QjD-Y&p\[ALY2-a]+0jU_k/;\K:AW0nT!@P:O4Y_Nq8^Cl$DjqSSaY)ZS7lJ#]Ojb=cTH"4i,gaRUpY9>;Of'Q>)KEOkmB'F3F\K*^LUeRO?VPe\?k!pr>t?D,]TBH>Le;Me/d+>?ug:Qp]#,7t#^:Vs]#//Y=EB0ZFcrU;*$.M@>P2jCl1\Mq32cQ2$OZCpi[Pd2mDp[Wd^i3*4/(HZK$m2Ng/'V_ICs0J.Qn$QK0\WgAWgIAS""HOZIYSd2Ds@;*TkeL$W>P8VWk(m`\hEf;E+&SR[HdRfDWZ/$a);e`[':8Y!BCMO;7qW_d1Ps2/_WbQ`l;5[?/b&*b^SE/cM)0'Y0o(*\R[7SQF)[!Hu$g_!D",:n5YD4$@'np`9/57$URS:%V`4@bXVdVK;da[nL[qi.O?#7rLr?0)1=oo9$,3VNhcp8"uO*"\8*f0M*AO+h>K<M\P9oYh55rp%;^KC0l9\8`]4%'^h)\[2X)Y>njN4)K>)B[@-6JE#A*?+0dMfa6;)E6#$A`u?D/L0IT"mHhX$el.-iu%l00J<cXFF;N`oRFZ]m]UN&,0>oH0EF]aSNbhD=!3DpUNt7aERV$E*VEnb$`C?o\FSQi[f&DbeBpjg_oJDtACILF2\+k%6CGP<e[H!Kittj^.OS002-['+br<;;Y\u9Y>9:t%.SR.X[MI-&\]sg4ECD;0bSLV(WfYq/'k:"jI?mf5;DQ9:"*Iht:(kT?hB-nD22O`]4"Li\$2%\2"BETT@DOlF]1']Zc5QFje]qV^_aBl_5+Pd>_&c+7BXW<TGVRWQYi9nTcuY%Ic@ptmpcq3IHL_i>Q!Y1)(g2FT?PgTG0mpIb0em*pO?$Yaoh3`qKk1%[0Om]M7HlSjieXKub=UF$MsK_D;p\4,\%H.*9H2UKlZ6ocD][M,+hl#'/f^!L'*fI>AEM;CcCX9H7-eGlV[/K?U8<L2VU8=SQD/JLRZkr0S2&7SjeT#fTD4<_AMhmhN5T[tLU^UZH4q8gJ1i_n=OR3sGB6p^B!]ii4%PDfe@,Om'>6_H3X*J`F^3@;V6("HU5tDX'H50S'^:NAVct4AUl2:r>W<W<#G*QCciOTlqedef8JTo`]fNpPTcX]YN52'%2:017'P]Lt?R6@AGkOY5q_7s2%olcJm?eoL[EDC8AcSODel3Y>/@,YjbSkC,HqmdR`f2s\]If-RVD6^SA=i;rIWNi4e*Nt`8<G[<3E_:'Mhrr3h+dg:A"89p!+A=-1m=`XFWNVn>j%QOk)qRkUWUb&2J_*j2qKfZ4D:3@qi:"$;6=sB7]shWG-9"udAKc`j2nHl8+D=T;&5+RR>O"sXokk']&lp4L3![L2FH!ngMr4\0HdO<#GG;([=,OMMpb,0gJ**nWj;0sZGiXmN[Vo5S_fCS[;W-,&)\=MlLn'KHM'trDIrt;d3<1q2T`!^@cc;aNs8Yh_,!4"Jh^h*1@"Rf/-R\57J@=K4]q)-/.GG3a'T*66/u_0:-Htm)OcCcW^ujj;t';V<MI#Zr3JqTKo=5%U%W`%1$V,g*Prn(m$XoBkr>.'K*g7e2Gf>g;(QNGRPEgg*E)c.k?%8pQ.b:gO#GHu1j,/q`gOHi)el@n2/\(AQego+Chi'$,C:r@Wik"&.iLg%8!*4>^p&+2PiF_tNkAl3+mNe0a#rC7,<1\HAlg$FG%I:#m!if!J8LT<J"]TZFPK&J#X=4*@d#=sZFTZa">%B-Gi5*7[utaK>ioOCXd=e#<oKm'30uVal`c;P7"/SWo(t#srSsEAHcDWP\JH0#rC]V^$Z*u'VS+p#o%'8m#Xq*l3BS`ZW%"#MQBJ4Dd1p.M?^J2aOiF!]=snf[V['*ok"27?'H5]k$hkHg*>095+j9Z4Vi,h;.],l<GWhNNJc<4r"XJOQ0%Z$*Q?[nXFdtS0?qZQQWpH2r=Xo[`0k]"51^g>Oel^llC4hnY[f;t/+kAfHfS@-Td;P"aTg8_nhboa+*"@l^5Qs,+;&<2I#*h('D)6HpI,=p4?KmK$)L[U>A3/NTo.Fj+V@EudUfT[@>^$Q0N5R'1F`X*aj$$pIWbjS6:jfjrmsBq-]XQ1N3EHjVd-TUq6$c):b+qj54lg_HH_9n^"4Dp3(@*di=!isV/Ag,:k4R,c\7ag#gK/^dfl<C]#ci&kj3]Q!DM<?]"`)KZEt*&J>h&J3Naas#9^i/fc5J<^T1_E8]Om/P@[tlZ1fl/WBns4Y!QRA_X7;u,l0GfgJZCH_F5.6WJ6XP3T(r&=V+0:>4Q7sNU>3PmoH!'kcaXGqZ)Sh,CT't_>*7#j<S+,#3)^Wa)q,=gQB&K)<LS*X=a26b*tVq4_K(Itg\?@PO,hir#f=t2Y>AgI"-"DZMaopIS&=bRjbQu"R.et8@GVm-.l"*5p?$^WEN":FW?6HVAsK\m>6@,0\*/S>Q'Nqd+b6nT@TJeOQ1j5hgmM6TGh!N?IPd&7C(3c*m_C@#FTK>R&.U%QI4FGIoI7^$;(kcuGl6U=VI@-V)5t2'5fpb#OV6cNH_?hm6QpK3A#24"`tY4i0XN^kkU^Fp?/G4]BA]V8],_Oi8(-n;6ZR?-!-<nN%r&AX7blaXXZ<)aVuBG@mMu/NTB=8Jrg)sQ_6CMuZ$6Dr*9@Ea?4$E0?X1U:hrpi9/Eg0>bs1'?6(?#.EPPGt,<"N5RE04"j*IIlG4nU\K;LdmK])-NL-!?mUeO>LPWBX]]$(`R8`N+J2Ke=5Gu:'=N\)%Wf7(u&d@Z@[Z=MB-VHBGN/7T$hngpoHJ6"MZ`ac8hFuLHL0rWdLN5jlO"_U:3eST<$>kl_0].&^1%5q-7JZ/6l1(_DMA7HI2Toos4KHM4NfaM=$CCgO&*7@D*JguR!KSNtVLYhL0gI\-/Z_:&$_Rij8_ploS3*[\OqGS7+KXOT>)kl4D)j1(OFtA%Db4aZL\nm[cf\\Ht3#9XILp/PWbfZC8)&VXAMGRVMl"WLcbhR[B-0VHM@"0Ug"`B6mY07efKXQ+";I&S=RJ)A.6-7(%VJK\i`!]BA'F(#F)LuWjhJTT$:RWn$qr:EYoe9aoZ_j`ohE_<QO<DE=aBm3+\s&1rZ.-[D(phUC7tkrkL&cPHccp%W\kNETas67FBI89'7EJ262$eThnm`[c[%JtqYqQice+b1E2@GI(+-sQoWC-nOd#M\8enL-c".;^#<+<aj84*r?%e[_fku6:e%F[s6<!'_-1%a;W\2=?ke)^\U+/\tkWe??g#fb)5F+"F>8$]84HlI!1/B&5qeVI8;Bsl/`,q<ajco@[,6U\LX'$jc?'f#CdP^[p9m`-@Ei.[-\_7bWWa:S>UAh.\+@GY<TP4/=_5[b8Ci8V=>=@0Brqi@9V`sW/l3HZ&?A2%C"M!+e\$OW%e(rb=2p/mF8S^,Rgk1BmT]k>%[U&Ue7CaHQXKUWYS.fV%b/c`_A'-CB['Ea]Q/+2R,O!.Z);ZA(YX[D.C#fIcIc=77u*c9^g?kUKefU!L+fQ)65jCd\A>CB8^D[O]Tp$u!W'[a6s72sH/@/M%U/9)7i_8=S$W8`^B@e#_t"B7$*'?1"e-a4ODjrqqh1]ri(i53u%APAZ</W#X:1bi67,lfS12ZP*'-#Ks]\(bFbfbI(X73n3\Z_#G.+P`3p3*;8rA&\rd&-*:2cm-D]*,-UKVaLP,q3hs3grtg!P(rKK^%[btO0[6W2pGiHNQp^q<EWV1X8tXd+05%>Irt1\o2[onNQ_<nbG+'_Vc2Wo?1hH$Cf2?TpAoZ6W=SqN;3KLkRqBV_CKG$q8*95;UE[$d7\,`WDjK6]-!%&]W:bZeP"c^b0EW4[c@Z[]RdpR+%94l!qN=`N*!)"J;.+Krq_lar3PcpX+\G(V\BYpS]=)V4dAPKeMQH[KbL.SAR_;IN;:H8uIc^#$>0&8TV`DhU;Q@T3C=-35GE8!Pn+p-/&kJX%DibS_bC=fI*3H"m/5fMS0LGo2[*`3bPT.`K]s;<7"GZPo!#^[m"8]!&eRY4d:DBdJ3Yf#]QD`eGlGNmaGql'_.OGDN+J@aZ.;O4F>bE_jA5l0*Vlghro5>7u&.'IqPm8a4`KU):4f=Np+$lS(8:PSLSL.S`1W`W@PgcH2+WmM&HBCV%`;G46R04NG>sPM+)0n[VY@,tqJs3+UfA?X"(j*+IpJ<JPCkm&*-EcnC?M:]F?a,;#-`+*`h2e;H*9uUEE<M,3FtfIaB>nG"(,G@3@i\LO5W$^3n,sOR39lW5LDZmnJicm*IjCb3iW@SBX)L[)'hBPgh>ImnZY)l5Ni+'B0Rn;W[-=A@VSfQu'2$H5[=i+iW:l4rPDVah:bi(SZsjI[Vc+]G])F9:7Xsqfn@O4AP27UETpL]U/72.iK2Y4m"5@Io<hsVVML5m"`2bAT(VWIpP=cF,Rd..'@QXZ$XH.)rA5GZ:e"@]6J:)V*:4s&.Q-ck1$kB'e\ogj$:W#]>gI.L<.k4qUq?e"QQ1ILkfM(4)NW&AKEX8Za2)aVun*KZY!XAtP!Up-Pl->'F+at@^XoCUFr*,NKj=.&%\Tina!1*VTLXmD9B&W@+)kFlT]#iG;%p;DCE.\?((>-FLH->-F$^U1Ba<f_L^Ckl$P'oL:6bk[2QoprL*8Ye4@]XJb(^O$95NJnXMpnP/mRj!;g^2X.=:"f<a6EDdG8!^tZdLLi!d?_D.<ksVGfUq,E3O!2jSfnWi\JO]b^:s9i\XsVb?QSnLr>l"]>DCbN(i28]IXl/0fOf3QV'p1>NmicPX5Z.@l2uA7-m1:'p$ET7"uCF,7k*l+K7[NNKm$tKdajq%sF5d:?5Ard>XB7dHG?(=EGS\b%W@$F-:Z!3lm&9$:DLl[1j.iC!ak?hL>-6-6dY<>L>CTf5bM5odG*rgk6gl<?`WKki8G's8#>V'&9n/Re>"p6Gs@n5ZU4Ab.*&!6AJDRLOr\d'L\`UT"fCsFO>Qri2P/e,^!P0098-u+&(piU]=:9k,T\WSTa20krXZH(WG6#Pd!4"l(^8m&F64>l@%]%%$ti8rQ6/Z]8&Ejh!NMfPCt]qgQQ1K![>U<c&F3IQiD:[:;'I&=?dmN5U+@dre\WXqDN.kA@J=MKm.7b&XR)c?ELN;\#&HQT0`<MkUr+u*AGU<8P760!XT`,Ja![XP#@H?kofne&d!mQU/F`^f+=^mg@N@gX[!7dc(ph0_edY5-9ip4j9P0LGBtV_ouGO#r1Q\m7:fstk?3e=m*mJl3pAR_B&b[MYB>fRI"cV1jkl8s(V+`jW7"%sDd#p,PC+fCM,2alm6#0jZ\m!n07Pr7dZ(WeC:C3^:Y0<uE!3u!UW[&UN-f=mb!(@G+g`\W_C&r((E%PLSE8h*f$\ZP/l\0bb.fjk.6fHW/iF)fm:L.+6VI*V6Lf_Y%#JW\?qs=!`XW0VH"pd"mW/%5jmEOaj;9fo7NCUpmj*,j$p'uLcD1.Eqj8&u's.UKqpQ@qVJGXlEcLsbs35/j"T?B.Ylrs^q:WgEjSulmM)4+@S+,]*s,I"'<u%,t(U4[q<%M`Rnr&3+KN===Ck#<ej5r+XerVKJUjid(()6/((XSaVpV-/tXmb6"$<K8ed.SSMGU]Vk!N"A)3@ql1Vn[b[NZ:%K#Bl[4eDpP82D-!"jlpkNFrKJ_pAeL%BA7Y2Qg+QDfP^/jD+BJf/lRMF.1,9^?AW///Kgs;L!HC(PAL/?`Y7&oC#YfJh_.$-8%NRGaRr1B-;410l!<#S_Ni9J_EYq@<W=CHeQeV+[P"gERYM^&nZ:WGgKg9BP)YB6+69l&]rVYF%H)O.H\\HYn-Q]]P?sbZ.Z#gBc3*,8F*[*H6Ed:)Bd'B8FZj2&].S!+pG$a#5$BAV(Wj6=2FXun/>i2bCllE0Mf1OCPnq?"YGU$CIVAJtLn!k=jBOicB`#@l"IoAYh,A3lRLP`YrYq>p99:0Pp!k-e!(=SliCE*[I`N^ObUj&Vfmb3j_VqIP`ktD.FG@%[l4WQPj%;9%U?9MBNu-GZF*9(=o3M+^1,HB34#qX,6e=SM<UD6k%TSQB\FEeK8s]%>!_K(IKX@tn=oE8R>KYh$D)L7@TKo4E"RTQ%5^rpaI,MOFa^C8O%`iCX(Zb$m'A^E5N?M0D.CPDca3ni[7hl@k_cZo=E`A@Q4fm4tY_cp/c1TZeOqNj;aV1.oQ()#C0fh7C]mg;d^*bk[k:%<JgSD8S1p<A?P,A_a`geiQNe,`0$<b9(g[_Y/Pk6MP1q!VpOf[G*a;dj6^'":(<ohj)At`T/_qQ$L]NV'cSj"c`FcDG?Ae2cOHC]nq45Jt6IR7Z.VU51ro"V'!@n4>fW7l@BWn(I[QE_\l-+8iW8^!(BZsNS';eYPBHYd<i?fe"m5XO1!Z\=M>e++@>;p/e8A(n*3piM+QfB38rR*m2`Pe,'Is+LCWJm/?QdL)>Tm-,R@TNjh%Bb%Yua_Sf[4agn7!H,MG%7'pB3^@X7-K,S!167,Ob&'59<>h3+];F.0els_BYnNb.^`<SiC0Sp19T0Ke^I5P8"BH4Zkk_Sr&R#8t]!MXHpLYbTQ&o?[h!;%,BYd?C$JHEI_="nQh0"65/;@ts[#bkI=c"gh#ji,C>n!*C<q2+N9*PciV_k\h;DggWRa*Ec@n;aP$MRWAVW/auMle!9D3ZG*,24bRKgF5;^`OUPBQLAYTOSggj&7a%%M$(YE!X4B3pCJr.O)kFNmQtoi)h\PZo,(n2@_?P>+q'>aGX_J49mq4p4l<,,@33h)sn)I;Io+#C\#6P6X10V@',dm_B@PQi3E%aJi5;f>>>0U"/*f,IoJhO:LC0hp5J<?H?gk&HE9MW(U%/Yh##]reA'gqaQIX]\#:G3OBH6BSBc)*drt-M:j4kgM?+J$3h"a2L?n0!%NV^-4p,hk&G)3/A\uu[?0S-\[_p\]7D2B7H]jF.QSkus$-V9H=aDacU>6H/Ted"W-2aQB>4#D+'PQAoDCbLaIQk1lb4SujSGifE>?]mP)hq/&7W8b?bA;f-gnTH';XlXF/WYU]U/T@=dI6l>8N-0pFFL2F!UBU,@L'$>^Guk0:#8,miMc'n)3g%5&J5Te*@-e>83mN4lQn&A/DB(a"Z&M+C\C=KUl0d_B3cZ("^d<Pp*U1<@"-;lnp,WTpt-\%!nKRb>YE9ZT?3^Pf5!+!eCR788#d>8"$LQW^g1M]s*'+hM1st=:J-klm\cD/-L.Q8Ua<YE`N,iPd/1u-;m]%M8617nM/Dm`OcOZs+f4ksf!.e6biFalDup7QY-?OMTr4njM9=.S`K%X;QR<</d\j7$St`<mX+X'6?7E:*'Qn@U%n9qVW'M>d'pVpe=ue/#iYBSg_5qWq[jP>H,JtFmc1C8fY%N8&pE%9[omdSeLeiCT]UI#U5/1ePF[,Ga/NQS:c:?bhG_ARBa+KhPJlQlH\%d'c$#mj@7+hZ!2#^%E!#gn9O,1n'r*I[k;lu<Z.!TTT^`P6Z?3h'l<>5'$UuPON.f3pcg,0ko+,0nQY))rOaXIsX=/L1K2BtdJ$g[#>G;HWII6`\N7,]nW4Zg69@NUCiGC2lsP:i=6q8/:P"U5m,jIm$5g17-O`jqDC;Bb;P3Of`sA6aQ<o&4m*,aUD$h2YZg`*i-Y%kWb<e#*O9&IXk5h!1be-dJD(;T%Pq6+gufh:>>K9b!=<f@j-_Tt0,;R3o`]jXYoZ3m4[^33(&nVteWMDASQDJB#eJmp91a0i->(^!tl38#/rg,PW9op3hRF_?;-sXAYcQ;T'\>B`c1Zp7/0BpHEas#3r#@h`h=qJ\^?<$s=Fd3XSQ:4g!&iNW/r)1fS/4+!!Bh/]%gfW06jUiQU0Nbp:e#)HjGo?Eu2p>2&5jhX`LA="`h>*S#.D^t\L[8/_WtT+EE8J?FO9.VHBj\<_3A0.)egO!_eD,/ip,N2:JfD#\+GZ2aE$)R!oD\aTe8<4OKbJ)1d+Br]h!e03O<^g9upd=pq`DSjqE)dR8X/tO3iqNJ6H"H?b!-M:<pQ(D4B0t["nRF78p1_C74VV36CcZd.!RQ;#p7/A7ngl3p?G'ZmS2ao0gCJ1n3NPN2=&MW03XVO<GE)]7$j_dY[HCBL0jUGG?#N5o?l&2P#_T2MP;'Dn#7IkCl"]VU6Za_sfCHeVEMa:2#\7>+_[)salUQ-*sqk;FI+5FFV1njpVUiZ1]:XXPD6:9Wdl^='"_#0n..Bq'[$+.M.kBXQcHU)@3$97mJ6^@Eh:dR-!8R@[h(^.>lK9N,@S0@9JS+L[mg*mGDTW7BP(QUmc<%$N<LYbI>^^ThN#mWTMp4$f`*,@bRK>f6uK_dW98OnBg)lAB8!g0]s:7%2W&+V.lPUmf1%b:t5*l;9-TbUTh.8>j\\6TaKj_P[^AOG^pF2ZI:=oai;="5c9ePVQMoB,*7GPF$(+@^@I9qc]I#WdNUkKbsS'u8l/REuHF,CKa9e?P@V7dN(TIf^??Xhqhg[h5jZq<bCJC^m<N4)3j>"@Z!?[P=a'$JT+'W"gX&JHCl6Q;]gGj"]l9kG1S1=u\?jm!/#?;W,'6Qn](]2hG""/ba<?6lFVb7F`o$XH&ukh_'.Hf#2cnLGngqCg8V$:ft_!E[-"B5rgl=SVO=E"l3El^8=>YW*jGkXGb6N]r]n,A6`dm>SoR^*<h%%)]5b46B>HBdoF8\YUmId-WZp6B(`M/?.$BW7^4=`&S'*t)-5]kq\YrPJPHB:QR_f9@B2\m\J[`V(&I%b/fgCm#3NaL1h@>t8KOD4TL(L],-gIC^$*!G0_#"=ZR\<6XCQ`#au55@b%p:R@)cG5A'B:Y(>jlKG>tcgPrZui$:5^soh['2rC]KJ'lKdE`[mk@4H*iR)s['\m09u_=o$A<>QSU^gqAcKEX+(BohD>pA9=b%Ok:,iMq'F70WUP"Q'@"l!T&bmJM]MAKH%cV1gE+uq[6f;eDT^=L/F`SGp>iL^m&a'M\nDmHDReV'sa\u*ASJODC]BW!>/jk1LN(RMM\RFEb-KLb2CDld4#5p!O@AQRD<*p^g=h31kjQ`$iaOt8^[=Y^tjP2Un"`rE(=m[_$dFO5pGmIiTn4bL<GJA(>UcjG/[Yn&d;XAGtC5GgGpGhB3Q3Qn(qm@<P"#KC)orZANOBh',eWE@5\"3.%aFl/*%&P:0?4]RTHUo[J@jqjIZ"RQFW.1XB&"7>E;[p$nL$>5]1KDS-m:.E<-F*1D,kZ0QI@\jmK]65]M0)g(&t!RKqsa,LD#;Al<a,lK7W!:WqM+p&nY&-`M'X^sV-thg&/j+Jjpi_+EqX;J]D',7u<Xr?Nsb$i42.;mM+tC0&hlKl@f!>"6.+TB@\"iF>a#0D>Q7h18#n[MZ4KJF'9p1s<tQ<rkhJ"ms!f,O2NCD5B=::7oE"&+[%FFTE:jarMWm0g8FG*ZV"?Zqq02:[o/b0+(lL'&b3#6mhpaDVMlFhcLsiCG;d`;iO"hiPha&h7^-9MW1E%lr&tFh.:'=SP<rMp&<84o]o*%b[b3)oo+b4?TN'"*ps_QEWNKN*9"K+:$QRV6In<F]#W4ea97]F:^Q("Su<`'09OAodQFL-eTpeVCCX8";sPcr8=`aNIo`h4G4aG3)n='"oAi=AH<th\(D?R@M9uc9ob'#eKXhJP*p#8epeHkQr^3CV-q:=$8&9"pgdnKkoa5:5WF#Qr25Or-C%mrdeX/pV/YNW%$Z`MBCU`[G8dAYKe].gNDlG11$Zs+26M>G.&PAJ<$QVV`]aHZPS^f^;VoQ9jPHDuTisocmJ&e,4Y@o^D#5g%UD),Kr`EB/WS9;R_-:DmA2o_oXH$!QT9_#.aIM6t%P\+t8m1:_M-VP(dNg(t^Wsn/)-kbM?%h;J^4kAnqFctTX*_/6oRmQD_2bo4&@(<.rn&r5f[Lu:r+"ik`>+!&[Kibkd*q4E%Y<[@eG>d8],hAlc%hB8EMs+!;,?Ccl6QZqNOGsf&geK)/CcG:c)&GGk?,P;C.$\i0)89cKcN1[QHMSUEm<nd.,VMFpMR^M9[3f:2`m%pnd/qM&k9b/GFeSO$$tNS/;8s];\.G6Ip'naqqVSs\GgT@s+mY$5$e2\gaEijGQALjGO))T>?rW7-kdD3I8b`9i*>EQah%0Q4S9WlB4\69Qd^O--p&sDs+.>>5$RUAmY:K]X(H<;"2(hSSQ?B7FH`T?\V0d3AB/Z%:hFjb.=BY"M#HhijV(!TMB36tt[Gtq$C3QFdBo_nr;j6d9V$Pc*K?sSeFmlCs,+"hpLZ7..$/k4PnT:Nk&X0`\YZ#NM%NUrt*`.i`,0d#uh)fL_gcm9PgCDWgD+j.pl(!;ES3l5D[o,X!KV8`@WE6i%AhdZJc_o!P>?@>adtU*QRMm2^!$t!hiKaE_,p9e$j[/`D6&P8!7cX$&,KTphRoi<9AsR;QAs4TZ;j:8ASF*dim5sO>YDP)bRlQRi.&.luel61@@hQH8<JSe/F3Uf;8!TNh+'RuuaAt^G9^Y,6(*tJ%!titX66d^m8(\4m9U)Y.AATF^,5[M6`+>)U,"_^/!0WHrfg=/h;j5$g/1FlEdK'?7/Vg/ePYpA)'9IHbcA2QI/C"uWmOZXHN9GCgQLBOW7^i`3A#\![FR;=5W_ichJj<<:FS.KlPch#fD<i9:_ShM3FK9)XRFS+VDC]AgJHq+.?VI-nga-"@\uVfI@j6>;S`LX:oK'<2g8#jFNsF9)[\AgW`j)-Gq8ob-37c)[h.8lgMZ-s\Hr"([1l9#aGfa8(A#aC$rO;?[SMb+.>FaBs4,1DIP\nbA]f\T7Es`-2IPMV2qnApOI<S,q_Ut%cY8T,*WI<eOn"iAP!M05=3[!Sn<%0eWl_kAXp*.Mj9W^0=09u/g;suo.)0;P:kgnK-\oFY:KDm\)(<&rI[>]jp('`(tABu]N*Mn6#o`q#2fb4nLU$2Q:ab^Z5pg:j-?d^;@i_pa%:+P$@@l`tXP1k#GXM:b()RZ;ue15a$"1U%M?P/YX8J-hcXAY==imsrDC%(AeG]odf[#Lgbhs53_LB]uW6AKfqooWH>[.s50SA1&oX\3Mpo/PK';I:&fHQ3ck"&*0b!sgi5I_[g*h,f;@-.6Q\D-gLje#f*hVK$0Y"X[K.e'^-b-SMPEd=uYq!@ff7kuapqjGnQOeHcbE$c1d`j]Y`Yo3J76X(?q4m`X/@*\;GDof>Rm?!3-=bAi_;p)W"32h&:<odpP80?u9[OeX47T'g#>d<&4Q`-6%0coJd;LR2urn!TCgmc"raMT^9`4)]/AD!ZXGI/7)04E+hAC2fcqn3Q'mdHao],c@jU`@MQUV+po-(TNHmGcp:='5:KLQ"fcN;foB<iu=&KC`\4A@N2F\T*Z9E<Gbr2g9L?os3.3!2T&-Y^+Ee^Z`<i&Xh'uO'shJI^13+OjE<:B/5=s?^CgUFmtGciW.3iCopDIkOWje[c=ACV!?>$?K?ll@nsGA$4#i$g2Gh/LiPtMsjFeKNM#Gu*q$J!m'o=-jB1fVhC!t8cE3m.#r[j,\'M%Ms]r[cW]43)uY<$XfqYT\:*2q;MAohZ1#D:T7bM%;a.8"*3)>H^EKH4^slMiY6e)#GV1[_GCm-<.kFl?MWCR92[P'o@gEKsOl7]`U=U_H*`A9a,Q[n0j'[@-25mFEZ57f-<WPV(@rrNYYu?9A6k=hB-@6n9?NrdA:!1RW$\(q"`g\Ib;<5X^/7]GD`+PYC7/?WWbHcZo#E[[)$5[[!fcf4IgZHUt)f+/24O6Af;?hDM,@Gi^@QO7)_H'#!dN.da.5C>VgX9jpl)N>AGK[lO,LUKEo9>e[.!eUmqiFQ$]-BVd2<1.`a)+S#Pl&1E/6`uqADUna(`,aq%kAX.A&Ft@4_mW^TLZ4oo6m_g^si(7kMN"nc+>D!`q/ac;PTs?LY:a+IYCsMf#)T3!`;Ol(u@n(#,qWE=Mdp38"?Sk_\*4bar56Z3omU#@g"c!u"LR!8C5>*n>#q/0]rjU6s:+l#BgtY3%J;N;fr.n8hlSHdW6bhDj2GtTnO*N5;\fa6;RM<\]"H=2kG%V.u[Vd?2Ve!?%H-#C>(U(&J^4D\k&,[X,`A6ZqJEuEf8l;pqW0k(Gj_C0<1JSSOEG)Z->54DP+(i%/?qY1?1RE2bkeQD[Efj1KebZd,[`6olFBG-T`$?a%gT0c!OnaW8G`s!()nr>(-k"0oEdAOqMMJji<-fM&%`23OTn?'NgVJ/bTcbDr(lXqQg10'6/+I,j38J2gP=h9W)Zp:Q5u6)?AMm3Y]tVD4!4)'Zba`f?"*b-'%NZ`=^8m$]M*6p(cJq$SG?7V31%Rqt=[.&F1sAg9UVNlZ2l^t?,4f\.LX%L>EL9.+C+^<>P#]\u#kKSWWC#5,="jP1:clKR/+C1V85gPf?2jd%>5nR:/HZ3#F3oH=O<r]M,a7A%b[fa!oM0+$234QKT<4DqqV$8[%.E5'aknDe]\oTQh<CYN"^4+]?:]d\FN^?sC`H1k>\bKD:lCp+JP)5]R>aYs4;rf37sj\s53lGBcY'n=Jq/#?-[P<[L0i2!1H_<K6<mSqCLb"jbcfFK.+=!+"J/]Xf1/]QGq*lUC=dPj-]%RMV?%Nqq5Ksi_iCSk-W;T`!b7UX:2EbA/):#7H@jbRB2Q.rmUNGJp8[GJZ,uj5?XmH$U5>I=PPj537Cq0lMmmr>EW3>1m7@P&3#fD4giA&ql*P-r9p%5:X'IJ[:<o:%Cn'a+s69B7e-1YW1LR1-7-,T-e#,Zh`kkuf7Dk:lTPEMTR=U&.h&r'CD+^6e%^u@cnf,4JKr@5&"F0Eg(c,)11R6)S0b^,%G/PYu..\h92.jA;3fEFbNllRXL[U?N>)fV,=9o]9<\rW3HG8G;r"o.kQqeDpQ^^j\\:F?(:gq:UOc'VdL*Jjghn2I\:-5F-7K&H0\9cS_pct'qe)mO0J=nV`ESB\b5>lmVLV'u3_`e;8";D\)Ct/Ho*sb/B1Q,8456F=sG*QTSYbRV.D<bMA)&0m/Io4)c+%pt!qpP"3'.(RllQZQE0V)$BWa1fQ25"#+#@>@)%cE13EV'YCUrdEWGY=8RF0YrCg4QX*->.?q_UUkU+LOnP):HS^$=O4cSVK$rZ\X[JId+cf6hQA%!7"P^s0Og[F!0*VGT0/)#RH-%?8+ACS:=1RRGK3EKo9')p4RUA.^5F:AqKIY>t#8]gAIp)]S.l@]a5FR6/@fSGXfh!s):NRELW`b=[,ZWJskt-QusEaL?+6@[(LMhCm&$eZ+e.Qc%#/bgErUkVY.nIU^S-lLo4!-^iW']n_Z5g']:5'R9]6k3Nt$J.dC3(K9bt_,O]A7"c5TCG6/sm[)0Ci-b6.4H`VXsJC[^NFGb#n8g'g]QVDQ4NH2):9\[o]"8OnMU^/Q7_H1nC,jbL_5.JZR*a?lQBobU8jAs*-2a&]<Adq&I+Sr^YI-.P?*Nu?&#j!6bn<ZQX$+hA+YeL:Knk!O4g0L+6#+BB[Fq9*[,S"=:Dbs,9aGODslo2EAG0Ut:e3<S__$J^nLAIheRU,-eGIqRK8)mu^3ge7AHg7qMBu;EI8lN)_^:qd'lr#Q[nl_pEL].I^5"%[q/fc:[B1n^fp]B79+GcaG2"bk;5_)rh>TlAe6dSZH\3;>Nm6`i?:o8NP9P&fS:n"N>*X+c)C<?hS2b<qu_Q8SX3+UV\Jl6T9k6\hF"!p]-o5FlPe9*M$$6bj3]A;;i@/5\uDeJ:/e/=]``,q,=Oo`_&Gm\:cP&f2/)M't[JJ5PPAiKaF$E(u&=TJi2LP]527B.>"Wfd:l\iauM(SJ*k`$d+B,#tHbU9b]i4@bi?lQT3b,t$[u3Z!=;DFI%AeBJEF[$R%C^FB?*=u?OS0S\o#e=B'-=gE-J9GDg2YJn>JWoEN+\k)@/9HktW9c7Y'5/e=pO35<eMSCYs._pdHhV,?mgX;gAFT9at,K5;>=M:!^NM+DL&33-#,jYch2D".@-g\*BQ$<5o<9^3RrUo=1+8@Ed@>QA8==eY$$5$(*NAH*anmIE:1/Q@:kt'Kk9a)>B^a_B_ZRCpN4--A!^G;=4&L&8:p3pkDR6p9GO5'eq+fUD^_s3kqMMGd@P$!@X(U8P+`C.1:LBoSLM=&9%+ZYSnCNQq0r\MF)+\bqG>oro_(QA\/,7`+7+P;rV6t4R?AKRSL"_O(ui5R+d+O?L/Xg%GT6VR%*Tf.CG$.ZPB_aFO#4%(^Y?Q2F@DJ%pV.jgDug:(6$?>Rp3`m3p2<:6j8Mffc1h9,pM"))bL2e6:TKVKA@8s`UOo:70T^n;ld@'HS1fftOg6MJaqb&K66$B:R\#q";AZb5H-aAD)B^;JXFdVX\T][rb6FS$+pZ;feT\B*)b@LcI$Xjge/H=>mng#.tp?>AgALYN(@K1CYV_9=_BCS7XlT*G0+1pZP^GDor*"Unjj#kcA>"2f<agK9Z)2IC+A@J1pf!=bh66,bIf:"hj2Hia?!&Y^O\eIjX"$0eJe@I1T"B#)7)DaXlKIoX/p?N`V5,[2"SrutqMNl1rl[DCT?A%d\37[*]3TSVHF^I)'YN2M4tV$V?^!=ENQ"8N'1\fV%OIbq-&+K$%E%j0)5?sXps(a-W_@m<Fr_]uQ:e&"r-Q$db'P66ZsAcW+XMj0K6=>4kS)Q0ba$mdpR$1=G"2/#)^XU/.=A2=o&"ofd*il5M4]ec<AWTARHcs5h>)=lN7`lWbY&;XiMRPmk+,7EN2lNHZ@PRM%8;%o!(5ZV.`s&eo5IdDI4/*3EH7t&Gq</:I7ccL`Q#+Y4!jWnMY[d=+uN"MGAL&j:9"k?#4LHA=c):4$@`^shVi+CW.H^USs.=7&#IS?EDcTG30JF&7dPFbpK.ZN3L]`a=Na!%31b\U@JoG@47UOcG]<3sJ4;h`s$'$MT?2X$FVk5K_AIM%/*qn1:t,/qJFS]MK-Bj3%8=P`0dP'!P3U=8SbT>gL>+BNqcbM^*^g!*IWo82W_j+rh][n@$L;B>,OF".j"S\4.k=GX+gCnWpa8G'`'/%1tNGYXVZ?'S-KFhB*(]_nEl@J.JBO\^b#=aqu-bQfZF/1nYNoGAi+!<Q$;2/kKdZ2t?]cs%Isa`94$ahb;m^nsJ0,1F^jT6U%MO"MLY1e&`kjT=)flt.^Oj\e%s/9t#H@mSZ[YjQ=).+m)E&?3;#"HS'f/sFnhq&<*bN[Km]oY:c?EWOkU;60#c/!@RoO_<.AIB_^il5>b(4).BnXF4I:IiiDe9Wm%QggABM6`CG8G71P'"\@o>9k\Y(CWK!`b+&$KSef:U]`V[8qO\HrrC;Jt)A<F6JAF9R-6lF\)OSpX%S"NnCf.o7)pCT+;>J7oIq$iqNHt$Oh*$YA#doe;k-2m)].GeI;(f$[=?PQM<#!<4mYgL7qKGm(luM"U_5o;1d'cgaDf.Vu^:^]iN^%C?`C31%#+UsM?D.%7W\TY_>i%d,4K#?V,CQWK]9I9r"5A:gK?M.;cleoDM<7`qWJ37i2sfcI`+GQqejQ9foPjG@I'$bJ2e7iGY*E:orOO@IgcBS$U:9E+HrTjA"eRV9JpW+2.[A#E<1)!sl5i356'iKo?fQ_e<ZO=u^9F!uZ=t%6^gV,/5fr6C1E$iK?$+(#+1a%GPU"%\il5K+[PQtr-6V]ZWUX8q==g"qVG=5QFj4a*Y?l9tE2GC:55K$Vc1$Q>O[8=_.T7WiHh=:rQjjg(S:MQ>(k2i^^^ukQ&9K"2R6jBYP+J8ZJnio=84j,9@;!0<cUo`9;+t`ZD`bm@qEU4Yd8['dN1t=eADi.Cmq;WG("VlY-VQ:N2D_DV`H>!gK^-KY>&EH3>5)n?^/XiGKnO0q(gAP*cW9>qQF]&E!R#cYH,fDhBB`-2&'!e\FC@]!0["^8HEGa2,d]*B9IlCDpt#.Lm*Rhd-NJsV%*AVI1W9j;)BjGpIh05kc[j-&S8<SCGMCn57;Vh@;.h3Jk:H4nT%NUr;PjgQAZOZO_aGn>\iTc,DiFOqq9geVji<S7TsuEjnkrL!SCI&q^Jrc[#da2MP?;m]%Yjqn,sarG?aLjt1nNotSPI(*O@>nc]g!S%X6rs9"Vu@E9SEaEqD.N2O067+rHr%NTj:RY<Gu%o*f8t@aHB<^L[$9ip'/<*;tLRL7*-p+V>p(kcoXQ9&_:XBN<sfZM&HKYA*7g9PO'abc]!'Dc>hoh8M>gcXnN\t1=mUqV=]cG(HR:;V^Y?'7ZS'X=,kh-FXF_)AI?"WIFRg-HBN!Kr78C(m=6ErB!g@*N)?.croa_arRgLGOI`3Y5e:HLC\LWSB@IV`iVRdsD!in/E%-D^"<mE5$(u>W!)hFE`$e21lias$(DR#nDR3/"*+[O8PWIJ89^@V<YWVfVafU,#=g_T5;[=.?M+e%YF\eUrI>@$Ch'0>p[6^;ps0#Pj`)U:J45s4\5ogKdWb_e`AMQTT.`ESg#F,if3F4p-Akh/Q])W@0l\lM(9W?Rl"0GloL^uo1CXq`%X[.E.5c&7&k5\sO&"Y'qNkgoH2I+s8-@.Y5O5k+q"(1/n.Vu1+Al\q?DsCOnJIAn_X>br.^M1%!`.$a"[FZULT5AT4g&,bG88qT#P]Y`h\8>Cnaoq/NJdJPn.8'BRCu^<$f=U4kUfU>/aQ0Krj`&[!j6[D_5%m&#+k*X_LgG?gZDnf\d.ii2+'L2]^k9ZW'M]@6dK6I]p".[SUg^'D\AI*M[^Z!9IF-&UQfTuc_5GrEVgM`nX7M!A+8S9#-8YZsi0@/uYe;OQ8i2_!;tn56>l7RA\PX\.A&ra50J??+MLOq[3qcg/pjoCPT5h+]D#\(;Y=*jkCAao6:Tc#NXD7-t3NUn"T$FY=jE7.FG<KnW5iLbbj";,l%FJ>,:#]S\9(.s3VfbL'3k>26S[Ju?P"3(]1Oa&+E1NVo'=a8j><jUnb7EM3"(N#qp(Y7+f.O9d@bts%deVF@"7+fb1a=*Is4,G$h%;tPJFiH_a.lHf3M.F*_427ZP-:;s6K03[=Gi/Z;XOkooaqVf+%4H`F^j_t><\H])3l_l'/4h"P;=GUK2*!h[-<>09c9']jn47%X9QYjTf?\EflTLD1IYA&<R#XP[MsQh3S%g>V61`o$a-6Po:a4h@n3D1P3(sqP2=$'qOqg3&m7Z9[`3.*$kcrph2f5PW'TI!,n5l?k<s3]::pY=7gJt4R'P>IeqL0+HETr;NFfgc3Wc7o4:F)^6mZq-@fmG)($jKKT;X[64N&G(/M-HpH0kjT'39s4Qhq\PjoWKJP*qYNc=Rg,.dQL!k:RaOaRI@_l.?j6C-g%f3(oK_F=X4hI$A7j&$pBF95I1I4<ch&LqiC!m9K[hG25,VW>73t<)%3[2D^CR-i/$IFoVVV;+r0QncDg?ZAh%JU2;K47)AE1!T_*2SN\\:#^,5QSjt3^KVZT:7]XTZHW3pi:_2gae)QXHR3p33.`IXoWd83a,.=VXprd\/U3/^ULb7)Eq2WtS7$oe,9m"ZrV#XDh=muY.Tr*.&[O]ceG0I5PlWpsdncfl;hnPT'FW,-i`AX7;^')H`pdFHT/)umL8sM/?gZ[(^'J7pnl]Ljnp'.jOM#m><2/F(:C[Rk($m;I9/]4d/LbQ)rAXnk7^&u+'0R:7lGP'as>,6'Ei5H;V,Ict@oFuHld:1k3m_0!8$]i([5p=Sf^6ob<KJ4ZTYXZ$=<,X1o&qtR)3ie<)lb3a=6%7Q&kD$q:Ri<NdaXU8E(b*aU*aI,r36(@Agd9Vp5VNG@;4$b3&P1^f,SlHc%m]X!;e-$.Tj=_[(XDSE<5@cg^[\#ICW!)&+3bR_D9TQ^]bjc]Ng\<2=:pdsT(88-0=Wg#h6kI#<''Ep]N*DrWQqT!a&:G4K4\>%f6Y<*!iumPq-Hpp[oc8>(_PXDA,')k:=kJmiO=u5lbsMDD20h.qdVAM#CU!3rOAF.qE998-`UhsCA>3VmYh!"2Ftu%TTI)ZZY4e5@:lbs+hEQ,=g-D9cKODtAB>/O3dfn+'@-ZA+^9Pl7pr`TdKW(/hK2ijFhBeb.$E8[%]P%Ar$@O6;>]!_K%&edT!BMd(9]['1',r=fSLRgVYFX6D\63G&8aQoXZ]Ln150l@CbM7B;g7]u>\?(a;m%'d.9_Z-M6EF&\DD9t='Re(<)_F^bRigt$L_A1Q[<Nc_6L13rWB$gg80LTD19,fg$9,2)jpfZfSE[X=KuS!>C=:t4<ug];?a<$dH:;g-s1+.Y6ji^?b2^$[n(Y2Sj)'AI"m"K16^aH"eDR^Ch@"$//I::QRE<=X>N\>imno?`32/-3^o9ueZi*iU:en,G2a<Sr.W5<WhBo#(i+e_a]7NXAh,U!Co:>(IH4JU"7JLEk5pI%-rPU8EGpW:^E4*B(qg5+H]A<^%@81bm%FE(\dFrN-tk8SD=HfnbBtl<NP7?W[X.h!3!u_Ykiqt,``dV:7ZeZ><.$e7O3%X225P3oSueUmE!U^qHZ-=F$CGN+X6>sXBAIRVQ4s7%S.s=Wet6s.GgGQ/B<=_t$F,;19.%YZds8"FrI5XNcXZTXm3#Mn0rGL&PDoNH#QSDW[!?t>,6]<=G7[j0G\j@mH+1N:g]tQD$dq^L$!\%j/V'3WJg@H)\O</+.9joQ@6%)@#-Qk>I(BE*"!!#94G^%kX2@K[akgp<IXO8sSrX0rHajq3C3iQ'Zg>8VZ3g<uasMX;8,+3A"+s,J\9^8$GQHLaJj2FqnZOTVqL#YNpl"KQTWE+NKJ-;D0)%7Rp3Zuj?'!&:Y&GgfR;8T`93/>noMtTS)WCf>bFftf6%.duX\t,Uha;eg@d1\K6PFu,+gAA_?>gk?<*=E:E9ETQ1=CUfb2_uBlP6<41'![#7T-&@Yh.HB@5\6T'rMI9"JAi^j%aF;6:@=NWu_8`^#peM7p;U*W#D:gmNb>f)a<b/.82&og\T&>R\a^9*H.O/oC*3n4uN`<bS&&?eKecVi1:t2/XP(r5m#Bk`KM)"djQeoNld!Aq&C=]anf+BUo*sdW$f(NiNf@Z/>YJfX7!6+>Ak7t*j=NCVf_\qbGUNPJ;8fGf-AA>a(1n<JN9kg-e"4F)DhHt+X9&hH#aspRH7?j4X#>l8Q-3rog]*P<Sj!pLJP76bs%P4!Y!)e6;d&T='%YfMGZ)(c9*A`"U?_1*c]6P'.cZ=H%9eRJ]`na9%8`,,%L&KG_eBM62:*E[f@qA/0rl!@Ogs.4=-h^TZ9?18jO9,\E$Z8&/`\J_%=L&e4[!1\JEh#M^2&p4QYaCe+\!![HZ&fkE&/tSDM1R0b+&T]m<V<c\kkj&f7QO`u]1ml4+Jn]25lR!Hbe@b?gF9%haY2/I(L#ZU6$,>*p(#cs%nG?leY82Ni_F_/t^N$_,(uI`V'QA'\oYK!3`T+SNuo0YDL_D,!ei>,%Kt2FH4siP2!6,ISdp!gO]f+^BgCh2tr)nYAl>8ch=i^,(5Z&#2alYkh_[a-64V(upES,O"0YCQ.3nQg@aP4)rn!1.khPruaKh<&'>!bLq'*CVEZh+V=kYI>k+Da5Vna@Ne[$kSmW`EW0:t5c];/gq<C.^=>DS)qhXL%_URJ<Dckno/_]lh3t_;E13I6=$Re$WY9d>`L0I3M]9W5a$,YGUVCOI&$)Q(?Z."#9fo\OEi1e0o:W-Q]o"OshQF"rhnPTQrFs`<#kNT3aY'0[BF2:IRS&0,)Dm-nG[t<DZg$Z^%mS7`.+&.Wh0%]8M"m;!<bs`[^^Gj&G"OYG7CBqgdXq5P_c3_2Y@:Pmidtbg7V1ZrXDA&iM<$Z_W2bURULYU5&Q!YJN?jZY&4'e,"pYD^JC/E@K)tj[LU?p/PA)Nehl6niZ!KuO8o0<_Gk9.km]GG\.<qS0T.`Nch(:i"XHI"J\QZkQ);#S(i(5(?b9tZq<V7Qda1P,rkH(I"lR*+aSEkWGUf0K'JZ5Z<_W_[RAu`>j;V3o4gg3d]l9PqoU4TX*p-Rg?0[%ps's%E\;D/#IHJ'+c:AC2I\8k>`3W'c=",0hn<\]6cIZ:_U64(3WNk@:ETDLZ&_%M\`*8Wethg7?OAtb7046_!em1jhc;3mHbHap"?8roiV5&Z5!O9.ZB,ET-fJ0p"bE*.41[i<jl^mPO_U2O<J$L$!^PR^P_PQar[H9R`,M;U!)1J9\',ieM%q4&\3"q/DS?cEG*7-gb630G9K?qn#LaEPN@,R*#`NO7l;:.@dl%9Ja3L\iQr,iMNP"',]u\kNP(^rT'j%gN*0HYJDD'<"B53X1/e6^0;FW:+)[G(_ndEF2rW;l>(=dkVZRK]Zh:f8_752f,JX'$uo3>YNcg2Vq@5GB<jV.BcTr9bt<=p#[gA7kg5A'>XloLGse&,f$aAlgN;Y4OE@Gd($He^F@?Z)o&D0i5e)\?X*"pk[R-5g3!t0T^j5,;5.4Y:l8Ma^PIG^0ZYYFBY/6O==V-Z_O2@K9oYN)OdItRJ7sCgNi<M&U)ee.dPBnDRS_R=CU%WTE!l'7Q,st\>/QM.QsX7G\f`).+u^C#a.\V/M`re!dak4[7.UY<CP+$Hh[D07]Fh-4,[OqZ7`!#;^Qa[%fDQ$5$('*4.'eMH%@Q/2i71?SAma<J8l/KpX12NiodR@*B_d'8*SIGY`J/"Q+:fcaQd=0<cW0ai`:_l8/GZ9*^[@n:Q3W3;kP8SCNX(H&m_a*(L7rq]]mq5e'b0nV];&<i9J<f->-hJthZt,D\ld#SLL0X2Os)8E:%kp=OUo%IMSba=#@'D*>E`V,>3bf=M^<H:j63jj5^C(tW\`*97*qkj][#f`a(Odu7Y4tR+5XK>PA/uMrp(NO6hO.&qk3Ga9KKTOr$.6OfJFA&Uojj;S/3rL>I4r#R.cgQ?,OH(=,i$k.5ll+?N8:9(3^LiOT.'eY-Q)oU]>eS%H<<=`GUG/hUA9*oFOSc@Be!Z_k57PlsY'kq&1e/*L#f/AFW;0IXB!%i^pokUVen%#JtN7HLC'?oZ*1=og?dpm[B;Y&W4cP,RZ]uVHjM]OHpbH#G1[(6aW,/!2AhV!f$5uNSii680HP-Tn;"d3]iSa_*.[u;AT#=Xs^NdK1#nT,9(gTOUMe9`1Eq#=Q(^?d.[SmZ2\ek$:D>-MFV6Mr\B+dMV:E,G[JuS13d.ta*I9YJKSVT'dslGFd('S0VoXkH![qbmu=/dGY"-%3l>.JbYO@d*:mZ^hGQmLVsESh[YCt"f(lKXY_NUYPG+4=dP3e?V]Cc8IWI%KAG-*1"U>;H8X0hne9dFafE.@'qImRrYQYrY0gO.lHZn8>f;bSG0b+COYc7].,qb29Bp$"lBgtu3p\1s^Ir"F7\><%.DZ]A9PNc?>'r0Q%<*.X/p=)Z*rh'j_3cPm<(&BQhc%Eg[euR'0U<-Fh]<BFuDYpOh,BVi4\S'Irbm-uP)GI)mH9C]?>!]qBG,QX!36"j[CDKkU,ocj.*@>Dka1VU,7T,.ij<H=dC2Y,if]5nAeZMQ)m5ToncD(qes4#N(rd\cgS0.l)AHR%K0X$Of.LM;gKl>LGp`7k5*_7C]VAGIiL$UKV9G5TY@976ra45W/mm<+6ZE'J!'V\dh@G*gkFc"OHUEL]3Jth7GdpP4-]1]i]HC<PhX>Xj3n8V+eOK&+!#.WB?k>eI?_dgj_PY7$a-(+!?S-Y$k1a:10Nn;ZiC(W9);*1Sr,fWpijC@\qCBk[Bk#Ea*6?@-YUV$\k;P]>$Cd+uUT-kop*D41g1:!ae91HbH(hs/>MsC+/8`LsARrkI4_%q!eQ6N.&.#tn"1ac8+rhU`*">4AqRBZpf@I>]l@G9Y"%@VL6j:YAoFSrlai1,N0%0PsdpJFMhe"`J:-RNMGR[JNX6K1O.%KO5eU`)l(7EaE4]8*lA>-?)\bV@*U\C:`S)A5>oOV+E?!/5B)^`c"r-<93fjfi/pCUCVr4WuC@\Ls";+*MCthi]P!?0$AQY@nroZCpI5m)R^sIH8G_(/QB]Z#^pY5Vn!R,Y=FA;.5(`i(Q1DE*A$0!cf!/_e]5TCW7O1FP/g0dD)iL_n=*M<C\8bc'g.tWF4]\.R8P&`R1m:SIX]I9#(=YebhF=0L/c^a_G2CXFq5mQtb!8rUOmRfi#KiqT*s]B%/\Df?6jm(`:kl9miSspnhYNUSjo)P4Y%0fK+2p&2#M.8jDXn*eVp.daMSFWUfYY'e-59Bgg>koe>R2dadfoh@c-`E%HS\iBFuI5(s\qSE*V[+[0LAG<6`_q_k]]RF>0EcS41L=A6Wm?N;`q[hoTO3fQRKfkBVa6Nj?+@uKf6;URY@hXGJ'qiBL@#GJILnQ%e8o2rSYY.$iI`'MAeb/cQs@dCp<)<0Ej*p92dB_/$^$qWITC')Zpiu=7$+D89<La>$r7WrA9SY:s'A#PSNlSLN1mk,k<nfi[m;P_1!I.,_oK-)EbYp0jRN>8&$nrg8RS#j3jN1nfk>>2e/OM->D+QphjI^^qrP;.M=/^^A+I%0EciFTf"q;'OiRu6K1a@$$R.:]O3<7bdf2*K6bO9L::#5Rt7;c9P"%ZRt"f4iP<b+!o%#3Iau_R!Xajn[l@`VTV_Pec;.`+Z]l&2X9,jl=,VA'91tC8t[>nn\n(W)HE<)HB<4/Il+.Cs]o(SX**ka__4*'c-j3e&om>HX?Y5C;W1?'"[--C]K8^NkUq]]LfoD&*R62E;Z-9kP6\P%o?/uDeYGtd)A[!eu.EJ(1p()^G>YqS3ACCl#Q-!auoY51QRGm?NR&dTs=$Z+911VOT!>O-qmHKs&R\a`mA;X&@5u>8&>/[/_6@JD%pH;eAd^l,p_FrBM4dd<pVF!$t%:&LUOV[Kdgh&_f+e(\L=!Wi2O(h8MGRM9GFPM>&j5?G/d`.U`X?d5Na*YR`MDn&#6U(>[<WG2ImBjn*0$LqmP#+KDZ_oCYO;?V/QNu6u;%Yj5b8eH58V(CE4,>_3iZsF%qp0_YWW.qDD_5N(mA6jsKoEE,dDQj%E8F\fo(q0ee[<@]'4R;_hd:0a;G3#0C+.HX!;K#fM:DF=rh%R8#X`)\I&dYK51fcWO$uo@=F7QJ*dF(!$dB#0!_Xq:2EDMWM>q>q0?LVnj=S/g>LOE#oHfUM]St/iR[W2/7Q$:dMqOC!q'MO@g6K.C*`J/0tP+2;GP?KY1hr&if66*ksl_M[t>D0:*hm++j/i3(IO.Z*R(=3jIZd?d4NpNl(:WWZThjFVQ(H'8-H<SsG8$*;Da>%T>@:ISMbIjs3-?qo1E1]`2VH0;S(+/euSeG1&F?`gQ^cdd9EHEXONFnrF::lmZAbk1bULO"FIW2A0VHm&MajY?8o@Z\Y-KWB?Z="M,l&ADiM1.6++(qhMt0=kk$[!JVIT3uaYc[gm)>`ITr.RE_G7rg(k/k>_X`O6f,2E1Hda](37;Eq,$"V,0,p]Zil^LaF2BahB/VPJ=V@0XA_e]d(u^[/'6S3L1)UHR2[f+jYf=%PXkLSNF+f)\j=ORY7nIGaIG.E*$tAd8_DENF\8[!P2/CB;/PG(@7o%DBS0XoRoPk05&2pVBUn)\"[YRMgGd_=_E`R6\XZ4CEXHc:!AWT(_n$dDES%F9nJoc9AUm<9%&rb9eWe'!JI;[#=]_\]XR(H=n_AZ\HDa)Ni!XGLRC2SSPY8:`WFOOVNS="oTC5VHA/[pHkXGhe/"J&m+e5Z)eHD2.!Gdu33qM6E0&r&j>]CJ/+<79(b:d[)?)C9Eb&;jH$ReIrE='BEsNLV-$9Prl^:kTCZ$7Y56?^T/r\E,D*o+G\WjN^S`;Ca!:MJrcLuJgb@e6?k=ZY`79X-'^5.EiqA+0R#f3r[]kN41_hAY$@pI2f%"aB@a#1hj6dh3^\;ZL,=B_\C@RS?N,,0cm7^La3Q(pqF"$GY.7il,&i3c;&RjN)TSeC(&<TqD4M=jK9/THeB/Apbl<L3+;]":\(nf(L&>Yqd3/lmne$DEiDWU1a%c*p6p<4/AdDj&dY^uM:Q/j+M"#gG+5$^#YL9X^?"gF#2NaUXN>_!3p<qAjUL;]jCid)NiUKuZ1bWcV_Y.UVAS(Rf5f0'E^sPkjIuYO9ZQ_S]0[mr*=R;5bg*Na!g)"8*-..j_$JF\)fS$s]K/WVGZ+:1N[qO@]&Gp?D])C28dE$Br)O0q2c66_&X;$!ifmi:udGgn0b&k<Ij,#KZa=>H(91B`P4J\d!X(Fgl"F"#5MCf5h4`lBlI\p;5VmD%UW8$l/_iKT!9?^9'\kKa8ae%>SdTCN[6o6KUtq!tl&>"'Pt:;lM=5[?=+Nm=6*+FfVL\MG7R&3(%:BhE_2BSTS4SP36A811;C=-XA:JMW7<I9qZ)U<:pZQ),+;c_`RWQA:4B8RQmP56%#Al/JfPH/jD'*:/rg%m&C$sFKaG)>8o!]s*7P'd`eSb8:U3O.nP1F+jr!?c"(3I9cl+@E4,jj,drB"N8RU"AKYgrq_Ohbq-=KM=-&5.L:F+D%+Dj:l(]d2<RNYUE]l=Z5dtS0$LRRteaecf.A!\12OUh'`Lj310e6.al=$OUTE[.H/=,:_k_YLop^j=Vp]e/lG6`<k&Qmab&/Li\E>6r95)%I)\4hnKR@K1"R>KsGe"Ijn3(s8)OsXB.YUGe.@rkP^_p+>7%tba&\;sN^P4p!1YuVoT2!@5d9V("L'iaXBN3!'riTrIg0MD[.IeWf20Nj9IQM?k+,'9%IfTYH3g'=FuQ"*QT[)G"0rNM.;ZK29ks-*$`Oel^!!SYj;<%ACCc.pXkWp2$t>Q:^Q,^X,X4<C6\`dZs(ki4mio?<GDJ+3)-ch.Up-R`^(;_-s0l.ZcQ21heHg"jXe@6L<t*!DI[B#fBF@S*-)m/D"?5eDT@*?O3U+m9qoc5D(IgBKMZ.L!()bZ>6q+S#C"OYGf.MU)6'(%XK'+>@LE`I(ll1AG&8q@5:!,g=5$BKm?C$=j0b#DNl2En-g)e:*TZWb_[$\K8o,NfWG%-PO;0=k*T'FBr6M1H(-'PD*SPZ'R;Y#P]kL/1eI3ogK*.!Leu[)BBG2,LQkPc<cg`]YYQW*7L.T]2n5(@">H0ln!jnZCQjj`@VEp(D#)oqlTln!pX`%U3o-kV@%8*Q;9C_'X`PDpM9K\bW*%a)"PlT/X2fs!l>j)nj1MBIq%UDrFA&VD@iWn8E-XBR-DLQs%6Cgl.%lC.(QB=:./)<VL1n##s<jG&Ns;.^&i\%+BKWu85XL,%c#'*G\>u$nX3Ml%<Qnm\dFQUF6QZP`0DOFAaGTe^l8es_i*[[-0n5L7oMVu$J(r&]#2P/6TUGt:W:fm&>2$kNs^QB3&&o*ZWlQ/$S:B(Yg2$@kB'TEF@-ku(p!g*9ouW-Lf`c=`qnefo>E3t;cjBH%tO&TcV8/f3W\^9>'.1OFraC%;]1u*54.k>aGurL;^n9:rg?T+>_,XMU3?Z'N^0\un'dKAXFJi&IEG$C_]B-Qeec0%I@KLLf@M,%nK(dDOp9<$+5;ku/OKcefsY&o]p6k1#5e`?#?M-ZpWF7er(B"aq/PAHp33gA?0Kp;]?9<'];#`Wn3[qbFMimqM&a*@4.IC].Ao*r2/&N:Fn4RN@:T+I8#?+3oFdcT6k6nqP>5=I2<rho=r27(0F'G6U5NCpcNk\M'SIJDDh^\A5=iuupq/Z;^U.s+D\i%XP^Mu($J4JIfNXGc?Co1eWHoc'951`pQfQtks(h&*r;H5@VpM9mg''ENKiH'^om5OFFYoLE]aK(9X\0a9c='J9JA$U`F'phK"gZ70X>DKfRl[!=b+OUL>J$_I0Qe5uKbtU#Ig$eiWtl<M7&2OQE@SqthY%)MLq?DMecSoSJa*;`-hs_j)#+>_B%G]>f%8cLheKB;HB8l6J7+d/0n&frgDD^8l;mRnGHMU4*jn55l^)p)]!(GkL=^3W?L[6rA&,LZW66^Dc^B;<PZtSSLO?,0-/aIk^5:@X#Ho1:+iL@120]BYOM8rL!7h%8>[Y59[pcp*,*=GZV""Ts,2%QnPf4aW?+\d)%pA\es#.Mj%H[-gRsQn<A=bDI;852SoD7s.]b<EOij]E0%YACp``i=c!%4+jPWcLuSR1_JPH]<.lEO2e5.q]^MS&38#.&u(^X5Ydr+u<*]7)>;)h%u<emJEn5aZ*Clml'f:bCpT(98hbmIe<:n+2ZHYDd&$qg+J#[rHc@(oH-G%dhBQr9M\h]!->,c^lBE]NAkrH6DKD>2ik<nrO/CJP4;X[utX#FIlK!-s$2B2g&WCQ8S=aXVgpTlBttfji^=NcETqq1f3%6Ikol:,0DKZC;m42(.G?Y2Q\,o$(51$[qKu%YP\sIFmK[Q)c8AWI5:f)ku\kcr3&9KI"rSHOE_Q&jY!\eKLTp(]ib8u:_^u<o?6/4gnVIST5GY>(UIO&Pd#H&h43BAQ?!<qYcH$WqQSCRFa&:o\la#TrRp5^aM9@M/gZslB[JDC's`E`[D8hG;B<)o_;5d)8N%8E.gE&mkC)m[[uI)TJ'p'3j(Y5)IJ[BZn\2A=$Db4g!(#kgcX4Lt.o?D!C=\t;pfZ]Vf*!T.Ji9d/II7a$qpW#8agEZY.$gGZCRoCI0^f8'_L8uIi.GmKI#t?ELYnV5WcPk]D0`Om:Oa..":R$diiEO$,?(R!FY`'/-k^#;XW$qLbI$lj6"L*5<BHjBju-TnS^-`M]c7L;MfDi/50<lf:q;S<KMYKN+MIBiH1fLdSZVZ%DjGqraO$WP(ZZJp$Pi`jK0DLW2k<=8r3YilSQ79p<WuCgqbQ(OY@P,ee6T!@daeA./T?RoiAR>#?Qf2pi].p$rfY;$'mKSQV%sU'jUf:_5XkcY^Buhk[V>JS,(Au>>Z5\`]#u`#gG4:K#[$3M7ZJMF`seM58nXAl$hJ2RUDblWo$srZEiFYjqY+?FDXS&npXY2ub@*)Af"ZEnA;8fd!ldIf:VEeEOr5[#^3sYthXW(P'STtG<c<+8o\Br'anSZThmmU+>\X4\YYF!agck]/Rq]K^Rp:K'g3#<]=cP*](@KKbY'G4BV`min[/DT,mb5"JMuu8KpJ*T\0@8*,-J:m:!VpIZmFV=D<t)V0kqR(@OV[8)Tf,?,m4^6="J\ENij/FaQdogGf5'R%[e&p3S+gZ6>mgl+'aq)g?>_j0cD^Md0ei]EZl;iD)XXC?J]%"EM#O[(L?Xg"1E!-<K&<Q;rJEMr__IVFf2<!3_-gm[ZA).>$Sl,(8P$F]&IrHQ#Fr'TQF4+W]8;99?Clj9:9"/\f"s`'L=]9s8\R17rC<k&RtAGP%FG[g,Eu7*4slNX.@UWq0m[=E<0>/*PBOqc(%:'1T-^;^aCc$%nR/>^=K?aD9B,U=Z@/kLno"687K6uMl_%UK:3knQ29Xa`YFJPU`4h^:om]0RJgs2k?W*olA4l6S)^sXH<>UQ%=tL,e_k-7PFR;9n?^(,c2jPc]951foEN=PY+_C%],6s?*V.TH4C<Y6JV?VUMQ0:138?m$MdqMXtY?:'_(!>,PB%To!S$'24>J9l<FP<:5:)'E>pcDM+Y@F_$>>PbF'o*Bc@GK#aBUO6qF0kAO32]]P:]D7_bJ-i^hH8[=35_?sOs$3'"p0UpkK.]GT?r`#,^X/F\Y4j:4n_4Y=0@Ofrg[4dQOp3Oql@6=kF)U%Q"DP#5)3LE"Uk;I=\,Ip#IsAiHY8>SIHA94>>.414I@se<:-.bH>oLGV<6N:DnBl@PA3lLb,%G1.Y_)rLd*]DcLH4sd^'21]:?NMI6-q(SUK+Zb=Gr\8+och"`M[Qci:UhCR`M;,+q8mL*:@0Y/*`o6Xu$'-s-oPbLWC[);]pSSD_t`O5`spU*$XKmfl-eppae#UZ1iI3dI6/#T=5lBarS&5d2"lP^775D%a!hHnb?l+!R"^]SIYc:p85NF6RJVWD_ap"tnTIIO5#@PiAkI;R8c]!l"*K8>ZUj-Oa`&9M"#4nH1ATT(gVZj5QZie$O$oc)A6hQa:PpLJ;F<.ipZuWeAbYfNm6LEEo,V;A'3MZ)2^1k*]p^>)%+ETM@O-0paQM+c/S$\^\V$'$$iGl.2!31D2!h[JQo#""aIG>_Y!+R-MIJdOS%+2!M_`Zb%NYr-tO.Fi-gCS#_!AA@uL-@2I_b4n3sUlgm;U'.GLmi*=>G(cn'_;mJA_GH!q-2eUqC8paS!V'ihB;KFA,pZ4SrF5"IDX-jHNH&Ba&*Vj(LXd^0klREe:Q8>W;MJ.n.2R&)Rgi6PuZQd/hE7Qtu37Y>)R:Q(PM$b>a^^dt">oZbfj'EU11qcF%joDViY8%ThZ-Q_'%&M83ojaQm7O^0JJb>ZU"3f.1gWr''=lRgl4AThM=Q\T))s+\6+O'd7^n4V%Um2GV<:"![?p>_<nP?^[$dg0al.o\:lCR$jlK#F>Q]@&@`eh(,"kcu5fM2@Jlo&].D]EV8#&il2IZnc(1:k)3+.#n&X#Pne5qna[PCbG<M.B8Scu??8VX745C1fboU\G&>;"RU!iu,rd4!CE2H:bc#h>j!XHQ_]@+\Y1jk"lXt0t`0p@pGh5XT=njX2=^6%?.U/B'm'V&7WX.5bo8b+<P)5&2,XA:>B?E6ie^hN%^RcJ_rhoC*9`:n&qQq!/?&(3+3/Hj0jTaeHW,;@G:3^EjrKkamq6[X-/.Kpb`dMhNqW^PJ-P7[G0H@Ol<iXJm9'CSa-CjpB[F]Qfs54Pe5du4DUaZ>>ogRZkg(8Y1gX*WrudD`W:J,66'_4Et%/0'u<7IW5=8&]Yk6%HDDT7_t]'V6FlZOV]IR`dt?(AF$N+;'^[K6=M/?4?X9^gq_kW/X?/[0]sR+m87k'E5l[B<)/Kf9jmDDF(aE95Y+fK(_D7th$2NoPI9L<koYN^gn3eXGVfHSF6(co_QOdS0)U8-IDOo%ul,P^1Q2EI7S#,c6*kacH'4EcUmb\:FVcJKAjGlA0]6[RlcT>l_JY@Vcq=t@2)1GdZ<4u6W_B_246K#Dkg5l_C:,C<e>JiW4aqI($LQ8=e-OI1-`%YWdUAHC;euAW%nn/3>A&Yt`L2TJVYPhENSr7+sd^euWfrBOE9@]qH`@dXoWNa,4jPCWm[<[/7Y#5,o)Md5a*WBpgU:A5N6%n88]*>hFV@HN$J9md:SeY0DrL;OM.Uu/pkMg,O8UB+sqhcRc=e`au8`^;Q[bBQf3.4WPeMifih`'A7FVs=GgKd5iXkMU>H'AKm=-`O42f/6[_nI_%>_NKk903ShblHNLNt>%+'n?@](V_g4TSKM($2J#m>88;`*NG'1YUB_(1C'ctk"7]Sm\!?@C"3:A58`X>gi063jd@Fro>%%j;$='d=&oJ'&K=2"'d@gHAu(aMb$n.[FMph.d=j:XH`/_)J5mt`6.M-anAa9S9(N$&X=Oe9cu^P!(+TB;9E5tT'l!IIp"G2^1MUM.S>5'b\#S'G</)C06+8]XJLJSh8n,n#iFYImXU*J]OnI&k;WfI5:Da+C>`r6%AQTUgcD')T1&Z)f.Z,Jo1gUtIicZ2Goi5Lu;;Z/]\t:nE:Zd;4A)#4UH=Y1'%g$Vo,+*nf_S8X'RTZKOEb_53CVra2D[hnRUCA12f0ZbXdaWhC4'62aF^o_5^sA^2=:J8r?p.9/T5X:TL_^-km%uD/(7$_0ZaV>t=D=%>fE[dY)qSs%^3t%K@2\_k3f@sR;%Nt=W,_5T-/8qfo*\lR.#.*MaRZXT#^i?`f&c'9MfRYA]poB)$2t8e[H_>(dKCFoT3E081@h@N"3\&*8$\h(7$O$h%$hLP&4>VXk?p?IIu>4S)2Ff<`@KDR=V,;>V"2RKf0\?["T=[blg(SK/NO&U(,p"`VD@Y9b]_5F)leR;eh9ORK'FPj.*O9n8]9\9DGg8ARE";Yg/:$)r=61/,J8;Ul67Y_9qXrR&eK3K&dj./N-5'EfKtEm'YOjb2tO0.Pn"6YcP%pcI>f0J5X!QSbkufp7Z""nC4nWr7B=8+*sZT1A_d*TXIL_r5*XI2q^^T0WLGTG(YD2p]-nDoF'Y\H9768<cb@O65uaTSmOT_X>cg%A8AZBYk&6lAn&:H,^]o)M/?*^iDSFEJ:A9%u)GfQ+?:]8CmKE'9I)mTT+XKBEF8P--VQu\86ZXYe`qM:n+Fo=]fLYqW(.BmFdM:A(#GF^Ecusou&uYoNZ&m%_;L0or8<^2!.dgE^('"[oWB&I4Ln\?f[$4!9Q<p4u-\u*q0n@o$PYb#)JelTrnMH1[!Co#\&.k,I#[BA';i(5RCYAj*bV/6Bre0q"`+&kgdU/Yj7lpYJMR^QGS-(1\c(]LJ,Y,8*'ZB#(HrCC\5IFmg<44;_V?pi@%j_b2Y%*jY7$F$\b4?2]QO:gsPB5KR+1mLhG"0H11cj0*^KiQ9)^ihL)I'V11sWSVQHdlc=@Jh8O53/%#:E]A%LT%nhhmeQ%uH;@d(Y_#I7U(!)-1V+[k?UI9`e#tgQdCPFe^[K`rVjEn!"8D5"[YgqKKnP=M#@T(Bldsna\PriTGX`g<cs$[+f]%2b;NIW2tk"DcS<e?S_G:_l8%[nEdVr7U)\Y,01M4fE(c^*>]>](p>0raHA%pW#r!3(d`>NK*n$-UAIR7!<FNE"A:)r75QEj_^LD![R)DP@(:e@`G%H!%9KV\.g>i)3)q2r.F]hML'EP%^l"*"_AES(,!_HnQ?JNRDPYdN?Pe`VRVGA@%:U7(ZE`N=@:5Fo9h!s?XL?HX,:$(PE&R-rINOr?0:nhl%TVYW2OA4Z)]r<EBLL@9C>&'2M#^5K=Nh[`XiV#]a0tPfY?(5mZJ(7Xl$?WLnR(n1lWg5J#"#=lWMSsJ:L(A=U8_2j41:"VO%"B##"hAL:FlL6fS-#(5-,V03'dO$4;giddnuN$jFjJ/WtG1W_)#-=D#uSjZ`]X?><U[YO-&qLG>YF`M?e`s(Fs'<nEeu]A=JC*\f,[og9qH"ROL5YS</+N%hRNS8tnhLlGG;SHu;gr)*\n@_i3q,OXOCP"-i5N>r+5]+Phu5;%`,JZaH&%WHRPAKhL5bYlfZSdF#Z&qVd[&1=Inj(C`60,Cn!>?sKRf7UngpAu)8u;Me>N\cm_KKt]bA7)9X=I\POfL%RBH3f!BY+1iJ^\u1UpOL+N1m]uOu(FoLk<O>*&gFs&bgglRN9W.Ec*=3XEJeaEJYdMuF4LXKj+JsPa,X-+7ECIhLCfD05$WomH<XT7HGQ&<'G7;`0c-^9pd6)qp+9,-9l..@V3hf4[E<J:E#<K\.Hr%]aKq(gnQdH1]j5c>4U_nOQm?6>oYogQ'n3X=^QTjV5`Mabmeb^]:%T=2B'2RrC']b-&M%(\Dc3]S-j^`UsquTat,$hUh`r\g4H:AF1p`]CGc1dC0&_m_j+f&Nsdc't"c?n)=#FrVRl!HM#o2g/_mCI3PF69^,[eS/l*s><"K9.&2fc\Rd;R1^VYog:j_oJVk8!8R:;5sReN4nV`e1gI7Q8#]i,bYY,U2PmiKK-Au;_2L?NS>\5,%[Ob+I2:``K6ca$tV)/T"*[&PN;m`rO!4_@iSsLlqnT^oZs3Z_NHYc]C#um^VMb;FNU>Sm@@%;cU-%mE^e"oNMY>c`hlG7A@8h>LgSH8Dp?p2P3OX#M5oKAn]IQr%Br'QptS'm:dfJ"&B]26-*MM`N-QgEnVP<CeAR!)`Gd1EOF@hLdWT$2N!B+,+ka__s3'@Ykj[mt>-_'eW8?"=mWt\(EeltO`W5;BikFY`@U!>692,(*N0RFFp\1=.XEM>BP#0535)Lf[<f<\(7RP`^C+]g[.\iC;4=B]oM%*N"]Q;^X7aS_4X-6sGVt"ina-MqCZb'-/YGW2[>tV--598U*\07N!dl4.7l?5Q2M3O6VFd*jhD7-==b!*:=E(E2*c_0*b/#rk;,IdZ@11N!A#GAd%\STe7?jb^b5):(<;$p<pbF*e?p+2jup]Xnk-CIMn*3k<8&j6m<5H&`K7jJunW=HR]:9==W`/8fT%#-O=6Hnafas!LXqVe+P;8?F8oVh&/53JX/Rukb4,F=T^Vpgd=j$;Y8#5cA09!a"$9>]JtYTC`bS9='2NXdB6lPu=QITBGR+=;fb)+,oVIU+qE,(M/9(W/>-5%pOpOH&F,&W<D+?29[Q^E;IRLePqr@&[Y7SP;S*j+RiLN"f79Z[)6m'Ud6n:V$S?k_gf.H0e0s(W2+(L.XIK(e7!Pr;;S1?-K%b')@)dMIOF]r=n^A3)PUt#Yg&eJY>iUc<Fm_b9oL9Aeukmc'OQtRW?&Q<]aqj_5&R?0\K4OcCc7/!#t.aIO)f(5VDWl,%WErN0GZR(N;$d;<kDkl@.<R6!23X7(;j<9Q@*6=N7sd&5]b&+ih'PdjcOfi(68S!(rrrC65MO=Ug(TD6.B_IpdK[Z:n=bm8nil6F%XS*n<g6Sn#<,BE"g6`H8"@\8lX+V:cL.;(oQqKXSHs[+sC00,HaSgNk1W:R]"7]XZSW#cm<J,N.WA*efPa9b568>cl@F.Ci8$cbHDEI"pU-++qTR>_H709b`1VCa(XkTdU#>M]lcm*o=5X&P^m&M5Fl'9rUh'k?'Y^Nss%QXe_91&eO+-8j$Nda<lc'6a%g*\Q\9@oQBb5$J9XQbm9@2rFH^M2[fmn9F]-,'i&k"@@-$tROa>1FD#V'V&19H$2I`]<r?<r.iJ"qo\[co1MTr8BmPA!m9*LB+b4Ib^G-9Z^*CtP@`k'W?rlPY>8)86RXiI9mM*i+`1i$\]/XH<T&6$U0%ctE8kbht8WK_$WK@9%aCght6&$&$L5Y!ca8iIcW0i$93#!RT\8]BVkYt21Xf@1EZ-)$,\Y@0aiWZ*!iL&s^`/Xg%b$f9<,TJ38FKN&U(QcL6OsYR,lddMZ)<GioSf(5_IJt(1GD&q,9]lt=Ga^r/iT60R>1UXXoCT0_mdOb%m&#ESL`K\+!#5@A:pq*,8S)S'Ad`2YF>tS*m`Q%*0ea[g,&@2^r!2unQdeS1'Q"E8C1u]0p2W_Mf5Fr:A^c`-&p&1&-SQLgf^_*r_<it8Y0A+t[oU#\T[8MBM1k#E6,>DsdjVcG"-ZY"CEX-tT:-WOHYmOnpo!cDSp;uddc#M%ah(mfX6$D%d^h%blRX3JXqdqbM=]HLmn;t9g&]4!1p&Xu(jD#-/;re"mSk5?)\*(U9qL$ZU)648Gl?)Q^2Zo:Mt$Bp`,dMO7$FR),mH`fj/:>t/<jN9Dj2\Q's'mlY%/:I::<l[TT&L^Gr?2Y_pFj)0Z>``3iDcWF:^];FVH^fO6Mtl:ePDJZ6((iI(Z+qR:Z$t&E>0oH]Oe!k.7!*mO;+N'?)hZY:!F?Z.an!kd4VeN%;@doP"'"pZ+H(Z4aC+5^8`2*(ooMBs5^H.*:SoE<jF%'T([Le@L'U];E`B,Oh6h\=8>h#cO.dQ=<Jo%doU8,cPtYL&hG<?FP79rK56[piB*-`I(oSp*IRlpJl9PS_Z8+f,L\r76g[Zr0hZQ[]5q]W`JSAR9p<<H*kQ`(f.?):>08oIY<AJ*i$D0g5\6&1mEd"4R+)XD5D!gSq"rSZu1n^Xei6r(=Ct2oL?Dn<6T&a$71(EMISJ>SAZg$h9qEr6ub1h@J?Q=pkaq#Xc>jjEDmT,,BJQC"XV]2j&<6KoY`2U^)3G/IW(u^,=-XS#SdmU)S`X:!tr^_-IsJ.](rF[pJnp!jjnLp.Q$.rl5BC;n;tA-*>%UoO^sS_6ZQX@%J'mZh,Eh->SC'E"*aI"fAk;b$/Bnfmn_eHYhnHSg[!=+>+<E'#o\b:5t*=%/[m;sXG/4">te$2-W;mW8Q1#<:kp=>O`OT&]X#(YBBiQpS&/kFq=Y-!li-)#2k+mNmMF6LYp._[?@OsQiN@Y=-m"<:L&=p9M!m<\j9&)S7"jZ@DF/m4o/R[*\$dVXp3o-\hG+kYrNXn])n*o=EA$g;@W$>$L37?B0Db<<*WDCi+YqG>,J18td!(R&mJ8^OjU,WE:AT[*nR7/s#Gss%Vl^_<]t0nQIq&D#MMK"0e4F7-'+9NW(g:r=]gJZJ09)QnCu7MuTb;s;OUKHHo-6sD@gF%]PX\XmiT;mJ+aMR)9gW8[PflPj49uYIPZ5AUM%-:Bao_r_W$jhgr;ZL\G:cbfJmPqR)dt[NfA8ILlT&pRH`MP/7fqCI`6HfdYX3$m(J?:BKV[!#`D@^%XF:kq].tX#^-X"J:niYO.[.Gm8/r?`*EGh<HmKuC%#*gd>%!=-d6E[>-03l9ZEJJ;Tm8T.N&JF$dIVRJ\%H2FW-!\]gghjg\%3lsqY/_23=6qi)5/Bd")nJg<sjSC7/FCGRb,.?OQ)Of-n"J%]K7#+k/&ECM_+?;B,k%BEO"NG^-&PeSNf/c$=AT++rHuH?JA89&^!#h^IQ71kEeIY_"%UqXpPaH`K?Hd::KKiPMY\76kR0c\C.c(#e66"E?HZ=`Sn-X99G+qF`B2]CBpWa]lMF$"-uYHb=s%_CdSc+oXdbLM@--T6s"'e/OPVS5D"?cYm/at,*H7C"7*c^`+[3@`\X!60SYEP?XInI25GnmTmc.!"R:D3#q/VY@<1XJY]+P:^XWM+c<n8)NeP'-<![ZL&?YAtPNPi6:odg.hHIFJ0L@r_"=1pKfsL'E*X%QG.E\`ll'g,/`r`r0n+&c"9#uMoZTgWd73!Jr[b(a&*R"t61o49\7-&oT-R4KarLBR?9eD92^K4)>;1MS>9VRo@8k5V$-qH<)<5b3q1[e32T5&m<AZ>O?a1I$<0URY.:rVP7NRPAUI^j/oVUb'3qm9#<?Trbk2s)"NGOo!6$r&J-,rD9--oeH<='QL:3D8Yo;jd[WIO_#YTF)-NL[A,><8%]1A>iLhaCl0?RPN<$+92BB!(/OBKEVc(LuE@6oDn@"$jqsWb,)%7"U>Z##M=\&fJP/E+@0G;6NfV;7=;0qkpTL#eK)F?#tpagoi/A2BT5OeNm!G!R[b#]ehM^L7*YGWL>sgqHS_I&]('VE,g-hAOIfCTToG-*!'g7dap8e]`^$fLN!=-"NV%a$/>4X!P)kNi(72-A$,EA&$aQXNQ!*":1;,`,X>C[#/s&%(J`h):6uh%nq'`k#W[6D7RH.e&-hn?R405K2=@M/`[:oBs61m'LX^c$Z(_LRcUJ(>Y$qO*h(iCo#M!AbgkeDbG'8-+<emmL1ZTOK<BJRO:&j&dg7Y'_*GRG->=*4]Wl&-s^dtt]2U[mLZ?8uhX#tTu(RD#6?4lWBAb&p\OF<]A][<)_><=B5hL;P(,(:UXT$"LUjFl1gH!o2&0f2`b#N!kYZ]&FbY(1`0ga9qM*K/c2h\-USG7X0Mc>aO?unM8rj[emZ^"`>/dLN(`,h&j5UoiQVQ%LqC^7/UmApmV'"R3:(Dl*4mp=;*',&"jd'+:7I3[*%tL0!m[=CIJKK_^SD5X)d8NHqc]cTU3BtE`f;8R5hC2$T**'.cTIh+-OpgNA-U=2ARljb+H2gZr!#iiSgaMn':!M8^JSYq].n.,HVT3)d-2u`C$;Hif`!eat%hZr2@*CQBm_LIZpt=o(":_3(gNJo!dnR-Qm<CBb($A%>4K6rbP\]A5T?14J_%1XKlFDcu(fS1NfX!bOgOJAfSlhqY%u1kck?r*FQs_g9.kG6^?R*@g,WS1X=[-2uD@NLUd\O=pQr3<t@gU4=Lg<eSIC'8@/tu4gihjU^l:+S)X)=2?*p`Rtk8El"1'C5SSFe:]bCrs3S#%][C[-BYdg&4dN=_gNG/3Vj]olT&*;Fg%cD8prS8p]cd0.P!sEDaN+hJ.q=cr1CM1WTqR+ql2;CsM>Z]hOR3aKMY,.G'3m]pcSn1b-pH]JR%B:j@e`;1Zu[OfK)LO4P9.8^\[ZT(BH&%ZV@D9[RiWUb/RJ:b%+T9"gLgMPjT4U#7_3n'JPR3Ei<;2/k$DUFF+>D5dYP=3=Zq3pOJsV:_=Y_DB9>O`:r)oe>LK?t7+d9AF0cGY=)i]>Vh28LKW=*eA!PgG/3#-d^,>L2.9@o8CG'XM`-n#*4!$]:1\P+"):",Wra`XqKeV$/T&7Zl-2)P2\*JH\eqR%_Wh=`s.fH8_BMSpck3as9Wm;LElu#.@A!9fEK(j]6K-HJB8f;OQ8#&/XNl>&B^cBBl&u@_T@^E$r7KaTB:9GB;Ef`!.U*-mq@j8hVFGkl0TQnd).Y2,\$SJ=EfjM>+pm3ihXs?u8rdfRR8.W"l5?K2L']S<9lp8c:C*1QJfaVYUBp_W+Oi930&`o@!"JPTA*!k+95;nLn/b2Vprp4G7"s](@1cB#9SLTUVjD(\-d43rWn>2;72p?f\s,k+gV58oXaK1Ea%nQ(a=l-L/[FAG%FEiO!B,NC.4&Kan@=c**ndKAdZ;MWDM"B:<X+b2.K#RdTG-u]d"f'#kWWMG]24E!oX"ph28r2];h4m99\l'TEnPuk)=caH?W9rkDU@OFJ]]F9"UeMC(Lf'o)*R"8kis?TL*WOUkqWnInBG21:#HOn@mmCN66!sW%,2GW;OkAY2r*4ES8Y+AgeY5S/1llIP.[oh@#O8rq6\UQCn^Nl#^L<><h8`5/;jX.u6_#WGs3+qBhLEfbOfDMAS+%p*OERZ?8V'A!6Wse48XJ:A:as0_m$-r'6``$<_@>2r:D%,f.K3tmC:=kUg?-a<r(T$m8KM98!d:BJE]&WaM:f[J/Qnf"SEeg'K06=;4kV4?PD]C_Lj2)fp#)>u+!3(ja.WJq3q+)s;&%a<ElOT1NQ&2RjJGG$@n_0ijB'0'OVu%R3#da:=m'"o(;O-"cSR+UD7)mqS0%DA&LSMG937u9kP_[kP!t5t:SFQ"TAsi?oHP`^&8MD,lJp[c3KM3lVqF+`[#ts<PJsga46NIE(4/VtP12,lP*7e6EE"K+'iE)_UH9Z30e-N27IbOn82]TNcFn.\1JG^p@ilnW:3S]2\IYV-eMOH7R#X[UX2rmp/&4=!<tb;\92tn];&ONEX.0^&K20S<fRX]]=ZM_AK-\5W2>VY4YF1VKN$F'Z9sO[Q6Y.!#<+jACUM58Cm/)Ib3H_a#5`,Q:IHM<>$T3]SYm=CsAHrkoSE07O9W8:AYFfMD_E8-ZABg;6%B*:@h(W:9(dei&SGHASpO)LU4/.H*!l=2>&aDuojQ+,(iS;%OoD#2Nb.DkqNucZJVV2&:.?<7mMo!*77_rV9l`fMiY%&Z1QaG]/F7cN5CQa.Cb_/P=J4U=\D=#NRf$'1;GW-IG(;\uH>'<F5MJDoan#X"!g;68$NBX@)13#cR]un<=g3p0+_WIiSe(i.O!'(e4A@nh^UT9c=B-Aua99"m:k^8>gUrB1$9m7a23(A&QjB7C(ci1Yn3,LI5mgT0%i^Udb(q.9.)gJ7Tn['I#X\aY@S&_lpQKj"o'LF('2<f<]k_\8TWT*Y6Umj>:NVT/m7Uo?me"?6RG;]tiP8!K(di5Ir7&uo$Lrcl!9J)89A?a23F%6fVOjW;Y#b^4WQ<6s]Ore?pf&R$n_KOfH>E@Lr3j`\Yl9Yl=kdPpUp:;4r&^<RZ(jugtA%94UZ#">uMe+t9s)Do7n+AGQclSm^@:WbM@<CSZf:M]m5kDXY78p5*qAT.RZS#&!b4m)mV>9!>\aiWi0_Sik<qm6+(<(D"ff$E[KFFct=$Qp)BS`k4e0IKGo,Ze,3op*V/r8h@"FiMeNs2]Gs,pSbf67[n-g$2U1'%bkX2PB5ar&16aegf"TWR6LIGT`bWTZuZjQ)\;7h"=T%njcO12)T:grf<E+>X1r%<#,hY*e;N22iF@7EV/57<%=;TpDT3ikU@*BjWokepPK"biS4..X@oiBE<G>>&X[dWiIgLnj;cF(E)Z+*Ma*M9O(8=nNh>I9tm5n(E9mB,P2W:YR?Mc)aWTqk#1,]3iG\'7<F`j6+fC"ZA1D%&8@sEDtm;O0lY;qmOGb8?]P\nJDT%u&U?V]]CgD3Z\>TV/jcNYEQH!Y/u<%R4g,T_6k.$%'js+20+!0Q((tUP$kW_al3S=5e+?<.5HtfP'=0_gX^*[)%XflZT(iW.PKh8.gl7o(3'%02Ass'/;dgd[.U@#soj7H(:7*Xl.:lD1I\Dr!%$OH'V()?oAA"C2.N^Hd=%*^=I'/Ff\S5J=rT)oq;oTeb\;m,IklLs`Q:s'a0@?P+Q3hAPN't+X\24p=D66!h_Nc"PFd.)9ntr!Irk)')VN?O;OKZVKXe&b$WsC_"%X6r#B,_b>6=tgBE<r;M&Hk2-mYVtF!<\NmLH,q`!E%s,$[7V;N,J8=;03QWdHT86DRH<obk8RWQhrJ"d9tG9_JL#8*.Xbh%<WtL?'SJ%4SP6Yb$`]H9[hXlaSZob-A_IlLOp3nf'F*_(8oK5k;ku21AoI,E[?-hR>F>DaNnehK75U*EcT;?$dIpG3]uS?#IRoi4c.r7-EnBQGK'u$rmmi=_&19jLGjKUJb=&8VrMuj4MndZVuW?>qr$#`5a'-cLj\QBdlLq7](]CBAA1)h)j"eTRllF];Di%2k-@AkeV=;mjX;F5lNo2Ln@Tq=q3k(9B/3pPi.UjMr*K3TMO.'&%Rl@n#Uo&DYFraem=OCe*#ErR:GtSZ+ZL/q-D_eLk0'qrG9U3lp1:fHr'KFh&rf43N>i7AK*bcB?1OYU.%nptUC!WobG+HXg";6a"M'-&?pf%OQmlAdg;CA@CMio"qa4!Pi=X#TUFg?#ZQi-g172_0)_0U2pt2H'XVADtj.O"-TZee)S.E2bSj<CmD7Y?)"JA_Q3a,mi/^l@%Y$N=aEMPD3[b;!?jD0;$abjKFR),)em/eXD,-M\@.@8ML6^GrX@?/B,os4pe4CT_8E:GKsn;<tLb_eK,dXSdQcf^W"#:KrudBO&N7^#mL`4=N?ic[lRU\=)l.UiQU@oJf+?]RLj4Ke_r<oqJbBo%k6J,E^\D[:iIZ[V_&)@)B-1,)('kK!Spq`:5MUk^a_N_[4IE>.hEMS?dbfIGfgoJctm'-1:_C\Y\?7l]lOC*Z3F2GgiD@Un;J%.k.!o3JUhFt,/7otB(F.[,TeQ-;[p*\6>E/i0b]TNF0s#h7_EHG>bp.E,Kba/Pgu9+^]]RL&BVa6MT@PUHO0X.YS^ZK5F=C.o(<rS1b5<@3,Hs5$%<Ob,%SN7>M]+RhB_Xl59dfZ#/(%EXtG3>"gqcqBrZ(%h=Z"D(=7ftWd*^kgUc>pGMfE4VSkK"T)]k*ksKq#WF?K(HNB,<8GgXd)!+7n)I9.W&og@#1/rNDu<lJ?U6:3Yi_#aWA'*<@_E":K8"#/r6VY"JW(%l^'rr1`81Ea!(')Pr!3b)[GoX=eN7d0&rsX(#C2lai:$/o4UbecfQS7"%MMf4]s"\e5"-s+UT'`AE-E]#AlSNM#.66l[d/@7S6b#4`s&t*+6u0r!J9RIt*R87A&6WmB3AO!Rr>lWl\hBW&=P3`!at4d0q]-E0/E#qScXP#kBT101&UE,QX\b1`+hX>\Utjn!Gi!%KD/(&1hG<bW])'=EAT.NJS.k7(W$9=Gr!T1]SkBOUFHQ!-O"7f[fj<o92/g375&CXR.7U^sdWc&Ycj^@mg\J1g=$!73W-FRi]/6ON<I,;[[8u`tA5tg$2-Dob=VneuB`cebCSt(V#aGmQ/!A<I[`i_;HZ+-[V`;*Lhq=LdC/un7YNoKuNQQ$a&7:IHZd;6saA<2K7[B:R%Df/fCBt9\jPXb]=#Hr<h,\o?u(')3WcHjih9$K-2kW@Fe''s&n3I?1eK/LA4hJORt+b-1dY<Jg<gMOtYGs7-#^I99eXnE<&4-E)0`u55M6FnFT<oo7F6_HcJ0&a73uunV]3CbY&Dl3s6HBLj6H#7.7Y_E/31o2L/]Ae.bN'^qY0[d<$D7&U*H-(@[JJbOVK0d[.]treO[9F#4]R/:n^q%8h*IRgo6u+]LK50U!(iq':Ud*3^U8GLr(>mg@#=+ZJ4_XA6`l0QA(a*l-!,@hqj$n/E])7U_GLo_,5Wj&4_V7oP*%jSDj(gO@A'$L8U([St*Hd'NnTTpef\OStOdmEg5\,dO?DNBYF?J_)TF\-P_P3W+pZ76BAoGG1mkG>M)L//EGq#X-eYLF`R8j\CR9e:NK<XiY)%hXeEaLT!6tUZJe++@s_DKC5UY#j;i99Ht;<_%][P3mV-$$-u;#dT$C\K:_V5A8dr:&+k;lK*'&\9'am'aq>UZl`7(J^0[0%'13+B.3KpQ9<+#]WM"Yh]3^L=!re_-G3S]thH*dt72ejj)>[GJZ\^A+=9uP@_LF^P4%ledWhpBATsXbHZ2A,I(T0kW9Dkn6`417Y&,\Qp'4>->L9Y0LO;^+HS8j7""*V;,?UJ7S[@#.;SV$Q:@l707^dR2?AST>>,!@:$PN_;HI5ot`n^7"@IMTf:!A@"eL0QoL<8`H>GMaa@]%T/A3N"RIN;F*k`474.$?+_GpO*a,S(E;F_hi4\jRs<+7Z$Q;VT_'&N7k8ij1AqAe.jpod&r&YqCu:0)ETO2^J5n-b&*/4R&V]qpl%4hR-[9hhS.uhCYKajL6@AFXibcS;59R_Z[pQ1ZE9&l+H\`"qQB&"-i1A;1=\#l_MBLAnGMguNGr$]k7+$DcYTCX3(I(4LmG0(6$<ds?U,:SZY^,Dj@i+;2Wl\<m:ej!J8YZ8UYt3X=.HDM&"dBF$c`H\c`g==d!:f,bo,Af)dn[M>YSt2^h^p'I;eLHD$%)nRXK3tC@g:eYlcZO<A<]CfrWCr'&A5q9!0rO.c9#IECeuSElJGeS9]ln'm\/`"Cn6kl1aoAjN)ZWB(O?l$L6M:#ZL=SYW\8NXK=hnrqOO/hr$1c8>k*p&RW&e1<KaDm<+um/:!T=/'n;OHs.7*UX>EM<.'"=]9mJ<j=3GqkGjS_a6B7PjRnk0k4p\g9R-Hj0QNb8'2"Piaa<.@8AB<]2$5RDRPcM,K`U6C`ZM)CA(Mc@(A#bT5$36?)pfS,'")=W^rsQ'6%_tB!6olln%FsO$WQPl+Bk1g,R(YKSMZHt8OgOup`gc:V'>jHmX>:>XJ#!dSl.;tlnN%VQDD:*q#+\-.L"TDYP#33Z49/J6KfElR"=o#cTeao&p-3G#p=Dsp+H<\PV1&j\RWKE(LH=5/@8Z*+M3'-+Gha41lO:\;Rm9knfU@c<\"Z3hc;H-KoZ\`N"FTYI)#lj7J[sN$aD#R$91E]h#h[Y^E=29Cro+bLo)kO&;P3NTs5=71&D@b0@OR.Hn`piX1XBT65#rC),DO>*<A&',::?deM?mAb>k9D9r,DRldK]X-B[UM78Uur7C,:t?]hFA8VMlp9<p\mk$@I'rt!Y*!)1`5l.kidmOZ?oFS5EC01qF8;YL\[9a/A$q,2fmBM+6Q\$_a]/2NCrBbp!>G)52(r/p7!p32M);U'lHWDsS9^k\Na,)+W+aYaVF=V.f,RR4a3>4$H7`,H9If7e2.R/jmsj3Y[55_B(2/0#*O3PQ5h%nrX&p<N/,iV"[@0dr<=%s;"M>n<=>P0Q&JMQ)ZMqCo>n?Inmt.,C!5[Jcr&C3_p)o3kPMhu/I+Y"-)aUk(X#"]co&U,<g+IhfDtI4:Ij_?G\3T/??&dQ!\)=9*IfCoN]8&m"+q''k&TjO88:WL2C2"XF\ih0g#gJiV!tJs;Cbdt%!0dF';rL54Yt<.Z)%.n6\spsIT#\;L<R\[N*\[Ej2?\,Ou<P]ruMP^VNA<sKgPSmOC9lN&C3eu+#;eZMJFI:kM%_Hl9a(k]D0c1hQtk"S'>(SPNkgG5-j'X"7)>;QY;:F#18TNRX#91,[i$#cRk3\*C'We,esEoLg@W?U_%Kn=#"e,m*P'bmIk=6,%-2tu)U(;N.^2tJrVT4p5eDsO.$RRo8o,1BZ#)D6l5*&\$q6W[+t;3k;.P5diOFsEjS^2)^m)#8UX)Yf]BD5E"T$ANR&==#e':@])XQs-(#"AD\&*+q%:CXoHsqgJC]fA_<q/KVfgF0+N4pTJNR%l$19<kNIQBtV+fB[i0We5gA/N!$_43D,0P_&\p`W*bdT3A*Q'c@JPO1CXr[)3.?m8l;djQQ8&8S?I2)PgR8(EZ<(h<pgi<OFk>``dn$QIGkoBUO*$l(AQU9Gu<N0Ter/?,rP`L>hK]J'@i%N9QHFYS,\&m'X4KAL/Ao2@IZgZhAf/\T*`oH,&S*B[8DOXrQ`NUM$ru$gE;VY;.6"C*.urE17K!F0sRI-\+Du@g3EVJ-'oCk5/8$qY_4FsZ1Di0Gd^#hO-\Y$6.@St<Drl?!jBl[K8iBKhI6ERAj4ijc8>j!0"#q,K,Pm:CiAWmB[m:uR`c%^a>R0V1s]G(d5cR$h,H7ohOCSm,I,Y@TEPLj!0b5n'd;Mn9Buh1SA,s0\1H6\YE("-HXC$QS0ENI%dtaN=ljCmD9>W,^'MpD4(Jp]OdPu=$/aXl=AgFQkWX7eV2JPgWO5J$,b\fA:_gD!:Mqf]Ze?;^i_bI8Ys,t?E7fJ)7FQJnli;3n2=-)k)/`\f=[gA_Y-)Xh0AQYuJS_;o,Cg.uFm"6+V'H^OF9gs;nmF)7A'LZh%$Uq;?5G#V5(mulEe>913\5rN639//89G9@)NWPCBp;e17CKjNTp;)$1?j9@WtG^L#c6OH.q/>'-]EmdErod>e7Ai;)7_2JeN_`e7Adn;(ET(q.W!:Y\a!IU#<Fcrn0BtZ67FqD+!i"</8jq:lD6oC])LDhL6*(1/GfKfUI^82&Jq+2KDK$L#ga2r5AL[a/%a$3$E'sS++@laJgJWCFc1)$G)h9_O(bCa4JW4KXP92Pds9]0++HsN+g3VI4Ak]/Ot4\t6PlgiqVk-0l/ot&6&E?t!3/sQ07):a:"aoVH_4X(Idd\X7O&HGZH$Uo@+!!_.^Mg%@#hhC5J:=qmW<Mo?oWoR<Wu*Kg6/%aP5`M[0!u8u^)Kq5'k8BL!9l8qZlX#]UQVC_5V:iH>#3Rq-?V\Z:n6F/ml8R)IE^bM6s0Eimak>^WMgqa0.Ho3Jf9Xf-8ocde!5m,eZBuGfk@;*r[.mX34d@5E:N.0RF@eeJ,WGH;O$$Y>O;@bTgh$J7OqF.AikfXn,YX\:nlNKQC)tm)]H1$^A'[CI*rS=3]e$]Y6iKR.(S#lCkjtXrrcf';DARI.ubjSM]3ep"g4@X*?U`:/TcJ$/d1eT1H\%kRnFtI>0UTi45$9\K@,(B=']Jr+D<up4=j1"IV](&V%+4$kOgum71S<uZjE,]nt*StFJj^A.Gc>Ij@:FVEjRCS^VViP%;HF[YqN<Gr($2-d:?]9kBCLQZQ&`:!DB-OgY_q"'gnCJ_P6jg!?l:8f,O'&Du^MD*"*0o,uTep+FQE#E.K+KYkRK+aFK3Y18]<c:c?!Po[!A7A0^EV0+]@k!`'a?IKF2LDcU%6'#-OWIGV(DhD;nA#P(t:fEWIca:R+jG+4(U(_DFTD*2LimFXdodY+4Pku6bTEI5J&q1lt?/9WbN)=eBrM930A,DS9,`ht[RIeq$K&QX6'<]ibR!t,lb5*k@K_MRn<L^N4/Y?`mOhpX5G>*Se1]*Y!p*TcjF>E^>gOVL6u.iuX9Rc+cIDoH'pdJ;O0VeK3;5*3D4DJ+;:C)S-[5,VjpPcLT/LK3t96N"qp>*[6-$:P+TO?8rknp-jn,r_pY,O!`-/,+lq_b)]P>WMW`VqQ+P^c3l#WNJhKi[mO3jpEe!(mi[+V1J(--Ei97:OV^kqK6`^+u`,/!O&)!KeZ^E^oW'9b9_\V_.F$&i57F*DOu<m6*]!4hQBXm[0a'?np7S=-Li.hr%`6&?^JGa+dtT65j0i@Q`HR=WT+<Sq\mFHh#3^YL+@h2ejlE9jpZ^l\*]&S.\_5S%3aaOBj4oubGS3YG:VJgAV&[_%)dm>G0b1>7OeoZhf"X$J;E@AE@1YgHa95>.-a:"%9$J.fmuZRRjJ?V@FKLGDae+VVi:^',st+6O_r;WQ9%Te$KBh?#[^u\=-XF`2M\'@2N*qKF9-X5E;S#f.Pn"8Ef%0&%l@Sn$0d,hbc&lAQu<[A<+IFnON*1?0^G_MN/3+]0BN6;4_k+47o3M\0OH#(rXrY*h@^*t]A9s7"IQp<+&*j4Vu!no,i'g60IB\76D1pKV#6(fS@H]9/k#_Ro!6&MDGPd:>YqM-#CEds"fX=[3<`//ccjis,"Fh#Om_2]j;31?1`fKiH3IK*h8fbb/dYikFfA&Hdlc=K$[f'MpC<*Llj'#9%.I+fr+Q'M-/CD=IZ%jJ:b,Ib?mF^F87C-B=?(`Ha=phWs.6438eZ10)6VJ]C'0d$qZRi4E:Ac])JhLB0kVaa<5WDUm]o\Fq*X@TV)*.CE'>pVq&spR[Homa5r6_JYo<lmhD4G_&42El'm`3`Lt-VhrF)'em1ARJ$H9:ceO-3'I9Z;nT11qSI3^aZcBAL<'5'pZ!>82@N`:;XCE^G6DV%cYk@$FcrkdQ\FEh!9ISF-tiRUXfG+D94"@2%-bN<dBbAH]j4WF\YFIKVd5%RP*>;d]];_GQ,V^qJjY_"-D!AuT]aXX.$UCW/AEUB<0OQ"Vj>DI@[lXak73RC]lPQUIloV4JI4-WAa#%sl8':tP0BK6.sSj&!$.9Wc0LJ%r!'.So!B!:Ts1LO6Ds'^*Z'V:X6i\"N'!A,*GZ&V1Eq\HX]9MBaMmL<LH>hLeNM7EWG@M[@89Y=L;-(k?ujq^$'MPJL__&NY?D/F$`eHg=-FpE&&VgZa&UQ'S%d&6m*3UR(R1UYTrNXsBu]B,gc9,K$l[unj)UN5$0:0*Xq460),BDTS^Mnu/1V'oQj`Sbg2F\i^9!1<9rS1_d?li7L4.4B)<7C4'T]509+bqHQ^O7sFs`H-D3#[uT?nHXsW*2`e1b[kn4HJ>TcoH`iqocfCVPQ7Vp-Ke($f05R3@#T$N?0,.u6=0kg?bE""&10M)hn%Tgjm"%Qa>nl4+to_h@nJ%?7m`d?XRYn+'TurS&&`a\,B7fYR91kTT[k*U+\bUD6B9uhag%tO75;'M!p.^,Sm<'G]aRpM)qbf8-h;X)o$&'t9@pWnROW&U>N?:A#SKT1']:`Y%cjjhkOP_h2W':Z&\#&F7:m0VmSqM8-+YjVs*BQSZ,/-rjb+PPm&G[H@L7dXUbQd(i?BKZ[%rh.OQ(+h1+P&Mnm.-`XR8P\QJ46LUDt@Q+\>E\/U\2>lhr)KE%Ybq0=.<*.I(Y'm8&P15=WiEn>aW]I^6%6L7-NsR51?\cpNL0aHf&&gjn7ZFg@b>Hti%WA>49a\f1'+FuIquZ-/#@L.W,<ZsX"30"'gsi:RlNPQ.Q17N^\,XS#PVLq>aOZ"'6g3\H`0A*d$ZSA5`(3<Et$K26':PoPT&deuN.L9_AM^RQUu,,a;>,iEe*Q4Cfe'mqLMQ;t3L0%fll6%n`aWc*gb(o8n\W0?CqJfQ7ij1]!o:RN^r*\WQVhW;qiqj'<>U`1b_-fQ)PID(tl%$GV(!uPX$b5b%k-kYN8&cj*U?VRO$o5rl*9=/+ZiqnJ?/K]`W>sTlh3'7MA2oMC,"0>&oQiVBMQ_@PA&,ZgKSNT7]fE*9)HM"+d`/o6uWe#'/70$7H[B*PGq.$%\fjLH.G9r0$>VVj_!olc(+()?^L>fc2]p3m?^Vt3qeJ1lh_f79J0[P%^:^M:j^hF;>,2tT7g9XIMeB\:<7LVBD#3;ug^TY8kM;nl>$e<oDQWRWY2%;fo'Qc0[?Rci<Ns0fSNh&QQ=Tbjh<5UH=$3@2d;TM.aCHg-hTE=6G:utMEO2h5U6Lj!b3o2<=RI&rK8f^SU#BT"tZei?[ap?"kW$A@#;bZ3Xb4t7%KEBbjnDLkE8d=ThY]idhWhJ.>8W;YsU3ZK%RoArmMufQ]O&8:J)MXrePVCT^&;24.9G\I:VAbk>Hgg\eWkK'SEOI=B9>>:#boo%p)E-a`:MW/GW!L0O%")b@BX"5;9bY.Y9>s)p<Mu#E<@t'Dq):d5Ct"=*L@&psF*q>1CY#-sPSP)=9[+$9&ARo+.#gnir(dad=?-W##AK3s-Q]2m$rT7r*Z=KNbU'jJ&PSmni*;o2'tZAKVG0+_[dPa"n=-tqV[7^Gmh5aq^_E5Y&?1Mae%gIdTF$nRA9#qUB8'jI,_6JEeYOoYd58W0Gk`-I:(n47+pX@qOt7XeK;fU3!i.Te*g$T>&J0`&RK3N*,iMFu!8gU2'T*qPGmp*<o'X-T.XEA95/c]&5*LBo^,1)jDj+/5-ag^5"?PNAK^%lS\+7sO^2NDYVmbK)k(0$PLUHSd=/b(O5.WD!HBD`6S5@7n%+T/MgE)8RBgi1p^j"F3]t&oqI['aB?ko&7kEbAfVMY.U^"Q,_=<,KubC+8Ve`TbA4+B`/"0)s9)(SK$VhDY?T,9c^ZVc:KEa/S'5,m&LDP^B?D!HjhL"!*#9L'YFF=-A)m-CKOoW_&;\2/QPDYm*g14Us84e5GG<Js)/`JnVqFX3qf-Vl-AQCE5.Re5Q'Ea.\5hqL)^rhLG*IGq2$VOY=IrC5G$dr"!i6`LrWj!q>GP3l"l-c0_ci0U4bnCqZ%<JGPJQ_&nCr>&UZ/Jekibg\M#FTRt)Y'K2id5Q6q]6SVm=Z4'(FARn'O6g7%qnbcKDf3s_@jpEE2-(AN?OqNtX]ZJ#NGKIVU-dg?Qg;,^2A4Ii33(P;#+-7Yj5G3R1nA``rRX#"nOm59XF9@\U1<X[aq+X5iY;hoe=A2%UP/LjPe6&;7Zu_1@N"UoAc%DMZ`>U>-oojK,&Xp@J7*UuKKjEZX;RCF;q]/>!N?j8U7$.Xbqp.>Mj#G+^^sroG[q_f;*3VZ/XR#1o5sDi04s!f%euXG6TP/7;t>;&V.80o$#TN6;qgP%gAoNI():#\/fR?\@Amq46Ua[ufJWQP;7^NglZ(gL:W$9/b1@sQ>AUH;RO.[aOOd_k>G#Za![sOKZ0^b,(kaULcsmp2$u>stT9h;7;,CQ&4r;>gm?2<%LD&9"[rgBQA!5(aYTLZeWg+ISbqWh"maXHL\^-:0Q-KL9))`7DW[Yc1-[!rnm@=IUNLWE#TKENTQt0]7aLkkp^$&M/c!L;01%Is]*6PU>hA&l`iQ]K6mn#df"M4f+V,;%QS0U&Nr6P_TEVd:<.tOE29PhjHUF]goS@M&hFWPnh\8_jjfn-PP`;5a]2$BQ8ME<!u#.=I2YE-`Bkd7$[o?VSh6-I#=c$=r0YYG/lKJ.n4BcU6(<]/,'HM4:[\>U=4mgH!`3p3uXS*&jRq"oR'AA&+0<dX]Z`8&mk#EMX0mB2%sY!2A-`VdOU%8q>3*WlT!TM..P^6AFrNU#@^$;md6K5O_QUVZ)gi@TqI;<F*7>2lX3Pof"`CV+4cFN1>mU/8(B+RR:*I;-pqYhA_OU\<#les[U$EW1R@KAe='en;1+%jH>R>Mk:RW(9jK',"+/kMVm%oVZ#i#/BMr<mmf">W!EqT6kRX/b!XaDQ%ZB3&9]'$Nd"]@p/L:b*a8b-:'AqS"OLmHl4.(#r#?Kj+:>k]TLc5BG1kgCnXh;$8k]2HUcn2[CBoVoM7ag86\2l@OdHC]Z[!G(]'uP3\*VHleiCndBa=S='N]*0T3U`?!ab?3_oVD*1&@C?nO$K+(@1n6LRT0C:"$fpb7ds8"kP,e"X78T/Ggn3CKAR&-#I:hQZYJiQ5uTi4:&+,8U---ZR$sR?tU`G(#h>C?ek(_&1m,=o==c%sL&4TKO"Q`pV'pf%e"iX_3gILk3Bg<9iG_df)WQ]t9[q/9iP`;VZm`CV=TW6aS4fIM;QahuRmmC\LjFK!:?^R<KL&L4h^2%(8Rk][%hZ\jfbh_+(hA_0Bt>Jb#&TnsZhIgRoFOcT].'P%rpOri)b[1tuk+)&T$<J<%!:KS1qbi+'!,Qg?^i8%dE@>=#E<\ppB/Z(2Ms30^=0b1/=W=$(VA_^QBrfK81pBg45Wh;:![?0mDcGi^)-<%fJhY1hYRc2UeRG&:eEpjUir,MI]pi\S#)mi_s?'Q-;b4"rHJ#7ufZ+3Y>Z#(L9a;sjR<Lp&'-_F-!Zn<-_-8Jq-$:)bX^P\n-$"N3;]nV`@CdkRP%`CZeV8J7Ok"oFk&C3U[t%bdNJ,O=>`/TI1D^G6%;@'(QcKX_AnfkiPh<.[Zt6r!EiT7-4pAcRc_$?l_m#AS/!Y0h&!V!WfL_6=>8OR'2"l'?V^Uq6Rd.-4.aTnG)5^mVq;kS&A?$iW=)W4f"*heR_d%(Pp`X5W#mZji/Z+1;,/j:8?*du9eT2];+YjRklEnh!Su_KA(IG*K&3h>'D<nIs:?DkRB1X`74>)'IRd-?`.LSs)&?PSnYdau8c5>FstS45*]h!<46MNZ@Q>kOOAuTSbZ:k-c>_Hoc-HVa\D+9bXLOk5ZVm!-``4!-\EkLZAt:rS=44r.&/]1B[MVF%JkhD[*"l>&J".)hY+SaBZQ>ep2h^K-jUbgWVI<C@^HP?di<I_Q/SD^;QQf-_b#Z"S->?5'qGXIqrD>LM_b"'(/J\c9C4\6@Eu47MCW-<EF^a\H2r8eU$6AL?\Na4uc?E0cJ%B,54kqfA>>f')X\s;&6nM6RpYq!;`R2[gbg#P2\'PcYoU&)5)7JWY:CB=3X\>adcMgpQe.P,%*+eQr%fX4LJ%"!Pt[g)FgaQ(qbSRo<+=+!_Gi]6'uXSfr3%scPoW>qo7QP(qWUF54HcRHB'm%%Bo+[]4W+lbiK2DTN<Yn<hb]D1m;C0L8iP(\p_]sD"A&,n*8-h\b65Kh0<3$dJV"^WIj7S`e^r*IMef<M.4@mf=ItpBbnU[X/7#0akJE=hfsiOV;/&&G@W6<m_nkP0;fdJ4PK)V]<=9uW!L7X%qaJbl48TrI9m!cBp>O'[(fS\<n/l"BU[A8eW"p_2n@+u9#+tf#M'Ia,YJLB)gRNN/pA!HrSo+(&dQ/A7]5J?X9>X'A=RKC+5AV.ncJ3m_5P^12ccnf1eGb0ob3\TU_[lBM-np7PB:T6e=0+<<PiNE[rG;QomhdB^M7'PBKO*I0Tsl8?ZBHD$N&nhKN&T8KsC9mfljm6V=-t-]V7H#Pm37Q0J:BHXn?0Zo)lJ&h-@'>%iG>9:$*MN%/Lt;BX\%<HQO`2*6Nem&;O!;g;p)G?qMWj+UaqFb?EJ9>2hF[/7[O$bnKuA1e=en(6tgJ`At1C7OcZI%#h$dn;9;[Far\'&UK1$*DrgV1PRY3bSLu!_N*=9,pu3`g+OHc$sm[;#?JFmO_ahk1U>-*\5,P*+mWT/"D-el7Bn>;@>^2-4mlJenJn8UKLRVc!diJ@a'r7F%pI@8=-fDnOp-[_n9"e/]h2/pWmBDH-NOGXlBN=>*tAioD,VFb(#"&1,an,/Jqm>DbPr]sZe&2NFkd,tJI+>QOn[l64>rO+/He3@9`QmfTas;T5@T<=_:cSc*\_2F-1NId"V>f->A?OLkh@7(XN<ceL,!sDJ\,&FNu0]bqkPg-18,$_Wf))Y0!;a'MZV9PVU&;TU2MX\]A!-B(?`+9>t%pDg4mP`nsFJD//JM5`*?ArA^bXhEA+W5'kOLH+=anf&Gn9,Wg)?&`K's+QG^VqA"7@WKg:GYOrm2LAW0%B7#OB,C!qeZYb[ec+tf@N)&9cVTY&1s2Ic#1$'Bq2ESq$)c%9R`bf'-8^q=SfCFoVE6jj,&=Li.2M!b0S7)oCB#lR_]liK-#QMLV`&1X@l?3a_+J@iga)B7UKjZo9*;-7pP7puPJ?j:;fn%_=!i3JJ:+g5[1#7:&)/d_sn[0=Hr&b/\$d'Ll[W,Q)KPFe&"aT!Z;i3I?O!WWrb8u=P!gRE]ur&phJnD=1>k&7[!r7=#`(bXYWF2W&GnLm*J<M>16!+3/OShBQck5"f>l$hrJ69m+o!i3rXmUn"B_tNnDdH5FXok0M=&oD%P"^hP2G*.n!-`)jT3i@MlFCCU$<iUMQKJ=)O%%4Mb^u$A(aC#K3\>7HVF6J(:`He'k5#:]e6Y6*i-&H"qS:[EiV?U=JL=DMp%[c@:BbF^N/E.AVY6M[c]6X5].bNfIbL,;6:NOs=[(()W/)XM"^VCHVFR%J0B-e058[@qF:J-7Id@hbG8Rt1[q>IBR!b#0^/W6<i+E,*D2ITT0>G'a$-P"kEE%##a)5;0Gb6=/O@,@+&'B!d?0F(eV5'C[9kuf\cN`4Ia9]rDe#pO/#F?q;Z"1#fuU:i/_h*$cmPKskr97l%#*R=>?hFu!m8a@PZipGSKeoD3M,\EMT9<O_i9mAhni5^[-./-e'Foa&T8AEM"0i_<ZIGMXhVW[#"J=D6WC,ul:U**qf^Rmr:Sg_m6lhU=NTP4d(<"Up@ePn%d&W<J?[HQWSOcSfZ>q/r/Z+oTnBGmS`g/boH!E+m9Ha0T;!PdVX\WFIO+]uYn4glMWUirDs2:1hj5To&hD.$E)q[SUUM5We=*CXt+Z[H9)D0A0Ie"8PmQg.iTehYApirfsukl[,8ioAsfp\d$3r_q/"I6oTc=%#PTA9_C#GOE;@O2`'oMVmr957l-?E?T`%fWWKW.DU##K:?VF8We;C/p^L8T;?W)DsP18@41S?qh57SJ[-`i2SmlCA?2($(U\Hrs5C\:UIL=*=D,.+W!r=1gCiOe;s7CJ;Cam+>FH2+_etZ>0d.59)V,U`]dXb2Pd9>n_I4l1.K!a*1p/\D0On6so@!5QkJGQpnWH,_:HpPr31<,0gY18HfaouZ!ou[@K=4:qM\hp7W@CUD8X3j/jrk!5=W4nKoDbT^mJeZ[$_o)+DDLu\-J@?=kCLLGYtd"@!EfGABp/OmYqcW)ANF5?`kX,?pbUAG$$]kiA8mTnZ3Feaj%SK/;`Y.,_`]S"io1Bjl'CkuXWjn+CmJXicV'n0cUdse_0OV(.#&W1#6FW249DQmLe>1hPP"7M5WB;cs"F<OkjS4-%Ycgh;W(L/.=t&glR%@>Q,dUBREX1hr@.&M\tegqRu=4dH(;oq&&)Ii]<qtG:R<$XetlE=PhcYpRI[Gnr3H713_Ji*kIq4\'1,]5d\9"F50N1J(CSuH7PhPSdVAs#0##@fq^bFC4d!6iUC5S[0?%i90qV*N#3'ZY8KG)Es#DnOp7[-@l%8)&$'5TT54&T\6KZhXV0d66,EjJ<kIX+SMp%`E*6PbpqQaU9^,bFVPij^*1W50O01lHD:;P<=bpDO(\FX@Z\@>%`ea*Dg.?>!9I81=lXWo[&a:`3mLtIXb4G*ftecZ&?70SQhf^-,jK2UH7HPrY`4Q1TQV3`,A(r^`/6"a5mF`q1OUs6/&N.8#q;*CZZMl)U_"`tLP2-TFs^HN>#T8ofH2giGHrmGPRc;[<Xk14_ZJklCl/R"5%WY\0K6gAQP=^$u=,QY.6eJYQ.)@9Du'n<'>__eUR-".B1cUpPTgb(fY/ea4=6ND_LIg@j]nh>S2^q"@!%4OC"J'\ak>VQ%P[Q6U,T]FMAUCdd/E>/3MTmP5qpaD,XSY6gUA@:@l(KGX&Y_\49[I@S=6Ag:f:7nT/O<,#LIro+@76NMSn5bn'#rZc&I!:\n?b/u=O%mi.g<cmh`68GRQb0K^Ger$mq<k_9Qdn+rI6YQ;]o#i;![C<-^V2R&^?mA*]a*JrmuMbP@d@eWJd7+_$'gSf?o/=67Dh[A*d#9@g^aE,KBMILmH<+d!,MD6A$Obig?t.7o_[/H!JHSdXh%P\l_?mLk'iVK/.XmJJdtE`9:!Id>UjWU`PB*Ph_bZIS/l,'!":TB)NsBB1e$iKO!FHb<m&]03`VJ+0`(O#Hb>7qqrha?W%k&8n<&(Re976<Zc2kh4QNVhh.h>0Nfa0m)&B5fs%00[iR'.rUul(cKum4G3Ur/&9">VlU4V]aD!j(]Db-NP\9+g;+J:2DPV=Nr_DsUH[ZHJb[)@*%dk&,bNs7^l!\AcZ&,md:8]LNP!;j@gCjOm&4=P@DZ0Pl`'b)<Tf8mL8X*as=2b<*ODeEDIlY9_<e`'%^7BC0LVKAEo"$P)Y=HC&h1I+<<m7?9uR:$u0"D_uqLaMYTc.Q\PQ48JuigCN&a%8?jG6gn#Vl+,t,H%?V=CN*cns<&+H<X8S:"W-<L$#5I_mJe6E4VeNAWR,4!<a$G&.aftUUp^g(#DRN0ITH;(e;0Z&;C;&SHpG!((`$@/\[0S]OfO?!EBjCl\r)U7QjBM41<Q#-I\lp>Is)u)H^8?ji:6EaApI(=UDqk94T:2$fMbk9[MOb"-OhOE2m's$5R`dCLnO/$@8k*^ofnuK9#)605*C=M-fB:"rPVkJA!BAo;?P?/9Kb&bs!B:,mAQIQ].3M-Ztk]6Og9Um`QB07-QjNJ[&&nS*b0RUl.N</=r+@ZNDF>d$iWR/PUeqX<n0q=d7>RqG)=PhfW"[i4pWm^>%(6Uj/r\l8AXnP:2NW6CU,%%'(^BpuA0tb:C=CiuEm.Kcu\=*gI4-%(AY$fp"*t_j?"X8dd2&Sp9e7/FeLG!#d(]7EB.jZui%]CP*Hp-FTXSn=:q4jm1J&8WRY\,=V:'QGWQ!/CKf*Uf\Sf)K(a75j+Y*nK-qJp30)hnn#T=ZdMoeD\<]4oTqNoD][[FIN]KpX2l=4j?EW-:QE)?C"\=4`'?XG=:`I(GBVIBG$ZQdf5aZ^^N[c47G]Ke+:^h1aSj[Oc:N8ad4r+!!7j?l;#$BR<AQS=#kEan\pN2E[*rG]Ap\05c5sqpnNV01:WXYO'Wf^XlO@^.r+G+41Tdb8?4-tCSLCeg75Mlc\`/0?[uQZkFTBX3Qu*IWS#$N!$m)s((Nu6V6r<72NB@:,0o6RArq]!QUMtN(`soh/'_i\E_^rdE7gCX'/72hnC`]Q1-ENWcTcY^pnD"j+=M7:2Cf7Kr<m"D".*[g;#O4V>]<[2D5>lt9ArM&o;CN(&-a*[9L8<]rGUd6dMY.]U#+C@h/B\Z[Y^8%I0eEOFQ`"DW%n\]'?!=/J@T&(3N:.*grCsaHk'7#U1^,bQAre\N%`UL<cq4dEIgbnG\F586p/8Vp!FWq-S\OD3geN4r:X@!B"8Q8P*LWfkP7rhe.@K;cdpo2'r*Rc@4!Bt#PWC=La:U=PV!Y^cQloi;TEPg]boF1s5"KQ)+Xl<YVSL,dci7Fg%NB&_e"A20?PD1)o+_f^lN/+QFq@kh&@b%3n##$jZql(@".J1D=?s*Y-_.bF/poYO7Xr,C^QHq>8&'i8[5AMKon-)8n0"Gqd7qIoQLr\h-Cd-MUF/r2['s-@7V?l)Zug#_$qd:hgc,`GAD1E)>(T>&FCK><#1C.A%qlsVF&"ecUS)Sq3N)jIANhWf0f4sHeq_Ppk`YfML#C$g*i&IQrs"iE/h]tdr585*$XSjM8k%g&q[Sh8m41n?Lqm61&4fAi3V=23^[l[!eBZ:S?V,6R+#^V%rWME'_k%90!l)G35bcO>KemOI)3bkF,6WjbF.Z;,Kc[(=0G0<tTm?R$(:e?QNZgj--o?uN5bSj#a/J2r\CnnB9rg^8i<ZREj_\!$5Tdd9btoAoIWGO`mZ'c24#5n9+?P^C\/CV14.*0sVnB8dqeJMcoj]2`OI3!_CX;D_)OS_0bOP.5"o.k7LZWA_!<\[e(.aE2d.,(%EsCK\#t&#qC@`FRTG1n9>YSMJ_(:"^,Cgp\%;Wn>Hj&(KA(G;solT/L0EK'ecX#>"C7>i4V+`EUc<W/1M7XCSU_T.!=botl@Zn0W/MX4s8c+26-/=1gbWjj6M2h`3aUj;Dogk(AAjf1d'>U>]rXHnA=0QjK*p]>E]`I^F233c>7UTSX4WB])?Qks(Hmccl,Kpi5YUf3%.-aOeV/_S;4T2>(H)#a&T0"W;)b&fqFMM*Q@DOJ3I1GN^WHF-XQr?FpRjf2+fAYYfnF[T#O-D>O?eEoKoG7RNB$cQbV71uD^HseWeV-:F'5FKe\1"8t-c9Fj7)J!jd4CN3LluhD.]$l-4B_0_Wh`0N:.rPoj&FstZ0pT"5GSr@h!cRrAF\$XeotmR:d!@-V9n@5g+TDB\Ao9BFg=o@'uO-Zg1$)8%,/^;Wceh0<2gY;TaQSVi`dC*S=Gg8US*I05D8U!i/,JUI08>&(u[R".(k+iU\O0&L-W=AG>";=XAkt>BG[83\n[gn5JW=VUq/]PqgSSnUo3#IXflX]e&a_T,3'`/f3<s(9qY29cR#*3/.e,]k(eXR?a.iPpcIh'Ru:"ZqI=;L]5lDW1q>!k:j?'iVngK:4gV_@pV.U/rJrlqaVfni_[&RbLS9HHUsA`jm!SVYZG&3Z3;-_7I2<)7P8P9YqkN5DOA/=GBc\T8Ba'%U`re94M:sSZVE*aZ(!CqKSkDjKNd=;R`'"2S*@6*HU-nD#4TV[Em53>)k&MAbg/4!3jLo)m(XAXj^OL\CiCsihm3QY^6ih#_-O-6&d,R[]'b_6)l&+T&f,oQhRTsSR"'A8^>oXIeNe,hZ&m-s1^-UqZ.M82D9[4!jPD7:*VYc&W?X2LY>K-VqE9/*])qcK6=Q]E%+[[f8l%D7S&#M3.T%:/;_EjH<D?\.h\EVRmGPC.iOs24rVo7tRn"E0')N#`)*)UN!3b&PORCm$`h5I$dgt/*UY:m(`QZiX=/TY`mC>t^[X7?oU]9ufS>N#=d!X-5RQj"i.n&Cmi:SW6?8R4a/3r30,D#-(SV8TUTQ@"-^KK;5WF$I9^l$PDa#o[D!"3t;G/og>5=1aZQbtV*/kq/E"Ld,BhP0^_$#P4J`686cd#[,%Gk$D?UG+4KKFLc]SNOTr[KmEA6iI7PoJl!*`Yc9&J:kHg$=(8W1iPftAfN&?!!F:a[F\O!i.!QQa+U?rJqFcXkrm.2ES\O8+J)2urhNIhT?s(=bgaqD"V!VMd(-j!qkC"nm`(#YFUfraK.Kd,J#rm!3!:N<K&(`-L^?:C*D#3TbLnou9P$Lc+bkUqTE((Gu#>5t3@]AiR`ii>1It6ijp^=n=D3sI6)bQS$/B4@`75U-7<0]g()pI,Epp3Vjf,>4BnUt@h#([oQr=h"tda]^ZG8NsHK2Ep#0(_19it17Im#UGI(3]8HO9a4OfE":B%dk+CDI:A9]!6c(khrg-*(&.f7E%a15Il_hH$<"%X#b(+0M;P,h=-XqL$*?;B&L4lpj>Is>A4`3!_Bc?MOe8Z13t94L.Hpji!2>jEM#b)'RlYcJM=tb_A(;@`dUhpiuHA2#sJUW2s_LpE^MU]e#%b@G<;WnA+dM6+:5l_5<QgBLX>sSW;CKtq%.p-cO$fo`[rec5$7fLj;@bAB&&E`ZdW9VGTnM$Og\c3=*@@:@9>mL]<[AR,)a_%^?Yn&WbeIS>i>q(YL;"5]k[ch84Nj3d6un_bt%54bO!en?8r=5QlP3@WjlJTZT-%KP'7V&'R+)b/rCL[%B)+F1)H:C\9[hFn4u/(RtRtb&iY9#f_<f6T0A(hhMA<(`IH7=9=de(4euD=B7;KNAl1ih'Y^_b3Xj&V;4-]iHOfVi=lr(O_^_MX\ng^?]KkaFWT5Cp:$,$4F3=36RPIEaU-I3=q#Q^(NggCg)J-uJ!X'g(hTQ8CQY.B",9D^gAoNNAM`::Pip9ie!-laW4p$>6m[RX0"fS=3P*\m1#gPSr?PaM-j?kb@52NDu;W1:D?7qEPi1UukZ32=[9%f-j@[uRIJtJp;08A`p-LWNeBZ?$87JnUM<WpRDHU"MNIkui'HI>_AbX#Gc4U]j+@/K[q/(-,B%d!]WA75maR6cVaRjY(?QsUMU-UnFN$+`fpE41XcTZRQshrRUsE<Q<i$`aQ=UaYdN424BiZb5VC*e0$m&OTXR<KEW\SMmj>DpXd5L_WIqmTFrjgu@9?_@Z53VSBl6!QPMRqFW$'!>@u),GSd-7N\G6?pj#pi0#UKZ*5C=7Tofh:Rj!ZPe<_-.YucSd^"sK(#'F95LVQ&SK)0-WG*tkH4H6/X>(XoGj!j2laNU;#a%.WDN4.YqRRpM7NahD+8(!W+2C'chrs[qO3Re>mP0C=n"5FR>L=8ca@pIoX]lT=gUp_'8E\10L\WpE9@)R.L&B7]oL<2j)ZF1no08;XaREj1ZcYdo_a=#09jH"7SLYKedIbb9QM+[U%ZL.K%>TrQJd&dGl1D.#pj#)cKG0/geZs^Q`[ZR?`RX)/L:4"s>;92P'e8B:69BoM#!l;S5"s"!%G:1.h1_SR&R]!L^"9c.<C3l')Hk]%;&J@W=.k:5^_OQ:M8>U`qdcTrR#sU&gCsc[E?2F7I1*go"1#t/4nP[R2d9]/Y38\6@/@\V@qqm+.[I7sl&\kI&b-h]'`9R.AeakC!Q:]mbs^1eW%b0*qhmE;4U9DI54pS/l$N22^JF]e."Clj2kN6^4u:X^;RJQD*41@9.0.cZ*!(S\qA8mGBG+Vo8LlT=I(2SpP%<Bi<3)o#P+,`^Ra])!W[OtmE-j&ZE<3BpBahF?@(ZQs5es(19/hbMXSugE20>@S0N4l%,TP!02!KILeH-)C\oEGGNW=3*Y:ft]qH[qp%,3Qc.Ar)LS]ZO!LFm;$\2YM!8"dAl"AZP\?g6!9ptPS^U&QHd*8/;En6`!t)uLg=^JHpilORiKSL!"@J03TL[oD07c>?W8q#U9Nkr:ZqocqCHJ<hG`!*GFjJj6FC,:3NEiM"]QCD#l3A+r)[kcOAPPrIt2n$))4%Y1MB)](>7ae<>Ff[-lg>mb8>fd^NmQ)Btbp^QA'f>aC(2"cN1+KBG8D@[&=pHR*K\8Q0P^8WuMa45R%S&g",+fV@PE$lk!&AB#[,S462DOC@EGAC`bINAnb#P(T.1'PW=6,4A[!L]/\d]n<I?JG$r%PW3i1iU<%H)[3J&jhSA!p2`UTU!N7eE$[57;eTW!K786":Bg,%KQ)/r6+rET8,W.kOj6WRgcD%`EWDnm%TT,PKI/pKOY_]N[G[:V>)UF'*s'+W!""lhoK)M1'pO431M;qls54AE:1/"VesO23GO/hRLM,/g[/^g"46e_Otui?a]*Nt4OS<3i^-_Wo$t?>&6""NJJaB:*_l2P\.mMcJ:Y94a=#`1U@j49OULF8LdnTWn2l%'\lc.p+(+@*hbQHk-/k-a?Q8$B5UJf]5i>9#rF7X[mZ3qUaT!L"oo.^_aqTE_G7TCW#_>%<qUgrY:F;IdJm`>4BAnrn,\G$'-R<<BBWsIQ^jOMnc;2_BK</S\Q,n8:7R[>S?PS;f$)MH,>j#Z=%[76>?\M57d)Dr!9r\78!rAZ%4e93-#CEujl\ADG'!r5S_8=><;iRB6*77'LZ0\l*gNC/Ah#NG+=A+j"H,kP3cf)Fpr,9=h]91V<;m!EE;eUosFY,,SQN1AYCSBn)^T?RFIZ?A'_gdC^fgT3X!p`)U=%Z4=lFHida,su#HiUBM!JO?85S5n<,r97bGH^jJ_%f8$>>,4gMK06[g5d!KltctU<3hk"dq]aeddH8>N,ua1KC+g,GP%?!q`O>/<.%-$eir9c_<LnMM3uHh=9(EF#)4j0&aVl>a^nT_F0;VrK\[XbPqGlIE8T\^,uH@dUReaHj$63U*kt:\MiTM'PXL\/D($6L@<50HVPo.Le!_t]>!4NQ_.$<%K:?HWIG,CRi61W;;0!\fRl22Z\CbO*S7(QD=!aReV3Pbu`B#l3nE@Q#dYpV*49$a^AU8.Y9KFmj9W><3h8d_<r,6h&d;p_Aq'4n.JuBCYXSL;K'#8sPp*j$P_j+-G9cplYs-oGKn-eQ//(2G&PLhLSXEZ4fFd2Aii=nD:&?,1N6NGSf3oS;aqnG8pMH,hT6[>Mea#-"Rgij;qFla=nBqL-:dc`9b=*Fl/0XjgWd+XJ)e8'P`2=54+-$s-HpdXPKi.1"pK9/R<E,X0;i&2b:)LP4'pXA"k,1,JNWAK6+7<kIuIE.[X23sLk0`tDY4>_!lg:^^0'@O.AT=TNiR"O`MUYf4nV%Q?,3a!8hepi/WFi9)KoCK\Eq<n:2CS$iqPX:0cs4:t,Ug`OicU)qR!0oHdIZF,ON,+BmJ06Y683TTOqmBGf;#c$4p*UFh]#sa4noZ:(_cZ7^QS8N]Ys[]G2ka<!WG0K4/#>dO?_hW0AroOEc$6]?1?UZ6!1=h8oWh0cp<GNJ-L`!ZFm?\",k-_<FSaW+2/tqOH.f@c0sNcDB@Noc/D'Q870CBWa?L)UQ!uTSl#daYr9eqH%"DWV7`Z2IQ(0%^kt-F1@.4FW2>+W[$,A)K\GrBmnNO4n]>*=b"*1>a<-m^a(A&oIY\A;uT`!iB8/0B:]q@>,/g-Yhk.TL9PS"09-4Cn*2G,97%GH#6V>Sq/4gdi[q)&sH!VeXr1_[&d4+k?d.hT9s-8LD.biNpMi;_-4SGsFMA-Lah6E^_'64CpdHdhE'^,IU"S^6U)oD">pl*T=K%l/E_j^M/P'oTF(cVp]Q7HS"#M.@>`kO7j]W-uFk7*3^S-PDi%3")$>`0tGYFJpd'[FK3[JKZfE3m=W2l>Dito$uC(?3NE<Mp'lg2lX\-1GP_[Khl%4T[bi\?rdVtjE@1BC%U,r.oG@,P(fY;Cf!Y5",B9Q:Lo'5QPq_XFN=Fs"#%^W#%uAJ0hQ)8<2H?!='#GDjF[r)Is$Y<W-&m[CpS`XUFN]*Ju*-bN(I"NcB^tb?kn9&iRBJ32S6'Z&\*d2.Si]f#9X%Y:'Nj;]Q"OFN,YpAfNt$<(WEr@%s6i7SD5*'rh7*qOeG^58_3`%`Fq_NX.!5^Y1$9K92$ZN@A2WB=BhE4[cJ.2F:Yc+8TRtC?sBIB_I-9mdV9tp#aT"NHRZ;/]Fbf]kSl&M8(,<i%X"mak+,n[C$DJ0cpDqe9;VN()d<Gd4XT$_1lL_0nS"9)oKVj>R=#E/H4ZtTTO%>iUVZeJbLp/OMYmSGkh98O:4<:$;6:@r%;o8l>,b,DgbGh+0bZR\2uj%[a(PjdP2nR5bf(UXnVj>hmls%:kRE9]@O'NWYR1\#KCaCe1Sa1V(7t^oJ8U_^/Q!k3_iRE0gNV6]s0Qjq`-(RXCY46Ab/8eu"Enh*c0`<ncbH<Rl>J,cAY?:72SM%K]"t:*=A-6BK]>jk`W+-EfPqcjnCB1mU/UHrLT^_k9Y(!/Sa^8Vf][]CoCAml,hq5%OMJG@c\bIlVYG.'+2-Rf##@6*"aJ.IYJQ+EG;Uq7/]&]u`DEl8d4_0M6N_ZgLFuF5%n___[CNh09X*rYO!6<g70aR$D!YVK,9S!\MEF5q_kV2D#>Q(=:/]H@0"^bj\-Z8(k>"nZ\lFIeoG@)j10Mj^h)Dp>GbdR_I9$"oN]I,LKm@2.=sC<[8S?XHQJbEk"1o!$*pgg+6HZJ7Q'EdC"6<FAU<CK.SpFKQi*`b_#Sc-R[t4r=7^ZDjrK<ckdSt>iMlc^[0dH6tbr=0J>'<ElNsq,3j*S4L#]4!NP,jEB.]@`/l!Ztcn$)nJ(X(^9duD7Yr%u28a]Xs%Eb/6QDJ*%qH?=R,<99MQ#6*m%b_S=Yfq;5*Ii4+XDmcol8?_M,iOXnEr%SekEi%NeEFoX(Q)Y^eG6+Cr_-/RC'mXt[LH"ZN&#G`B]rfPFEfJ!;fWBN[:\574h;"%lPS+GW^PI$(ISJg`#MTKOShV6Xe:AE.gb*mcB*F88fc!<uB_2e&H,mN6_4P?XN3Y&fOB#e6;p>f(+k@`Q#9c3H:-T5@hW%rPpo`<D@YKB@oVUFe7bBl`XGm)5guh&$#i`u-#co=k@eY*a**;dg9kXnOKRk:i^tPfhcg7Hqj^V&Or;<"ET@qQ1V$8Sm:m\ISD-6)E06Vmejb%@-GSgH4HdVZ]U*dgXp]OaUI*L'93&F3d'F$I.ma5p.Xi*FK:s5.V$[P9)IK<;.\pbgp58-HWKu;u<RSb:@I)C&H,Jo#'^NX]S=1=Jso@J,Ym!,^3'Hf@?W%Bt=d?l\5oE`tq</ELPCM9F&:E`jrb_qlakGQbVA_'(1,a=Y\V(*$C`Ask8UC9:um-E(Y2BBF7Kck;#1U/]<b+cQ5f$j^*IMc\Fr]29L`Fl(<=m"r%HMc[*MMWe1@$ipG#/Hs1Q04Kj+(b>0fSJSmGfXeWm4WR^Ik6)Wbm+Z7c>8/A9grGE2uO5I?jM#*)1q$%ll[(ro5Mcc!LS9fU>qIE%q9a)lP8GDp%.L06_;KI3!q\DIc#XFX,&E3,br;40(TlF4$$5p<J^rIo^TM[!Va8rI2`b&M%;GBqGO&?)LIDgK1mj0P`iKUM`<S#qcs<1=Rp^LYkta4mR@j[\Vg)<*RT.#*>.CHQR%5>pC-%&\.s3t'EUkB9(gVZ\\QPpcU@F5RHXU,:OTRAGU?2d9'!=m^u;&LaD#&1=uWjcpeNi!(B-=.-gL[/YmYP"<.H;!"@*hL\&g`^Q9md#N'Yn21JX$T'ItbEkVe[TPX4Fb*C:<ce>-T)$]@FtI\N=DI-h?-AFIQS]bnV8(t50DJBbWh#'&11C"mQ!:*I&"7QEIG$LasiInIj!Id-@QDEab?X90&X0>mr`M*#4Kam#jf]BM\VItqB7T,dI\"E%F3rp(J6:c`S4#/M&;<.SB@?(c;_"=GXTic\Ju,^n@FpjlKNi6a*$A,H@3<^fiIr&qM]oZ-KI1%:\KGFS@ICWcMYk%m>UN#B$\)Ie3*P3F2XGP%t<:o`.3"nLm]5n/sM.SiZ?r6ataD<_+a*X:X9>BM2S95$bT4l2b#!mZDqqK!(L%GVL&YPI^r`K2Zdq,aC%A#9d_oorRXXM7=sD+?lg`=o&-;/7Sd*gqHXUJ9stJ&cp8OsTlJdNJT"PPEe'pQZHOEpMPW5:[ZB:dt>tgs/*]X<q\&*m&+'0Ts!E("3_;,b4d>lCAbBb'0cONPQbpCXXGn,\n'GD,0"?%/_aZl*NPY[D/-X*#VdIAj-VKCrHDN9%0Y>rGCN>=I`L`LgK>opJGM+MZM^7SX9X=(=*;i#uYQN2)^iq\q-SbG&s2t$OkRMZIu+GDI0?m]gS\D+k=Q2;3kf>'.\pQ6]pV2G^!Bu*`s_6r*arG+i3McP#-9nMe,.i[bZnoY<6M*R\UQE)^dXf!J!R"-Ti8-82q%:0LYNYhHLseLbRbO0bI[o`=n6bW,Q6`U^r9'YHNT)_S:5F@*%V@<u+epV+%;X.BRkW/dNs)p\&<4l(A!-"o1&p$Fl:Q?#].5\`lDI_rUUL^QLPF?XO0(J82kE.ur$^$Vk^SY7gJU/h'rU[9(=1190"ES#jK^:RU`QVlm)8$G7PR'2@^u`@2`g+e_fB'm-%2,1\0>k!q;qFQsSp9Ml.fWqc[]:QqD40kS=?#_=Mg.mh6ui*D@DbW&WO*QB'(Usfp8-?!/)"JO%]i)4ID_W4R63R"d=n2mJ,$b+r;I:ci;rG/$78m&**Pe^K?0#3[RaI/#Q<MZM%cPUuB_TVk*G]2\nkL/2m[gL"Y.MsjAJ5c8KZnMeO57p0d!:=&Ikh:o3\bLDr_:i8XL"-#VJ9n*LYrZ3bnh&e,/Ve[GbbZ@O]m"NX$,.]V:Ri50]/S95^Ru,Xl">Hbhs^hW#DR^i*cm'Ed_j_2G%JZRB\2oSQukpAbFnFX=PQ.RR6:i`<\S);J.-ua@G[>Or*M$I*RE$A+6NM!8-)9!O0E]R,<(T?B>e'TjuNE!""O"G,I#C\DpkL'%V!r$i\22IDal(MIjkfN&K;-k](MW:O3lIi'iAYq*MB8^@fTWPHIs;8+a7O@TTbH?2S'Zp]5'Wj)#LpO)5ZX2gr13JlWA^_oU2_\$A9+5S)'Eh$DEf,%P4&1nZNu.hoRKm6kUT&1`VIlTYQBOpiumbl!;q*c<k@;b;o'imJBqFYu-Jkri2Aj]&8LB/$.CA1lM7CKb>!^[[DAdQnnTQ+nu)Oj^:>ede.6HkH)B3_?(MRkD)XV(1YaueZkr/I1=g6LYXZ*4eaQH`dVMmDUF(A7pm_hA?k&h/%jgKV8(Wq62.O2]K1dq:P)XQO7RYf3`Y"HL\G;_F>leP:_:^gEM3_F7,cl<)l#`PWSB3:&9o*&,NVkL:$(,h=%IBA4rZFSB0S6%YE:T5Qup]l#8'S>3BSZ$@'5]/cqg$@fMdEDN#iF[>t@A'-,raFH%-3PJ6C5P-.=-4A#41\8C7&f'r[9<4<^mN8fcX2&;r#!Ut2_&\:rJ":-5K/oAQ;`&5N]MdCN-b1hM\P<@BL?ht);Z.9RYZ+0*N`;jXQ4O=(XU[+BgNqtNeJjj-,9lqDq8$=?R31&F8ALA/"Bb>B`TO@]J8G2q8.48$hD"2GLB6n%`FlRh<NrpD-$I6YVR\bRlJI<U1^K_IYJ_GhAHMg0J3OLr[&q5h.R/WP@>MW]O.Fk=7!/^0%107Q(hoW"e0`\L"6M75EIPg#9S9@d\Ra=m%U=rTd!.fD.4VftDZHctXp8P?776SXtp90KRMB#n6;@PF+LM2:Kq:g2d=a;AA3O!L^mUhQO_8!k@-%FM7u>&[a9TWGh?]iWapWj@_FNq$uQ_B'2r/tR`@[g%LQC>j8qlPXVeN>cjb(=(gW!Vhm@c$A;n!JrOt<pa_HgI<r4mSTbmV4GF_^`Q0Z>6<9ap*KFC+4?Lb;/kak5X3Tq2Z&(5mcUZKN=VcP$Shhm0B4*Bi"CX!d^]$D%":c4Q/@$d%Aq]k&>*)nVu&_Rk&/ZBCeOuM]'[N&/cE+Zf8T9Mk&B=:70KUj<^=$jraN41--sj1[F)P_['CZLm+GYo.DLAI9AcqX'o^4Rf"qaYmr\2hgRJ"U$j`cF-5!](E.D#s)?1(G5V_<n?-U:7JLRW:ZATlV<2NH7&a?7c+=Qr6KHMH?]OsPJP"BU0mNDg/fI.pg@:Rq.pGuL9WGe1?@JM3[7I5Mb%b$#4Hm[O(<R,Va+s;VqB_Hk^EO`4;3JZ2`!'RXI+@1UZF(LljjqDKp1?2nuPS",2)O3K-pmDYKplEFj7__s<WKS3(XVhG^h>qY!?CW<-=LpKW2\"4YRD$fGcsL*die38QfMLAF&-p.I%fr8ck_*\DiV?XU;^hhE^Kkb3DCQ"ki(^Xo?IF>T>fmGs!qXVafJMP\kd;LS[O5U1Y;,,]RLZRk19m\i1o=gR\30/WUl>AE`.<LtQkUojV=7FYdc/G3_!Hh\GrMH'Oo/kKqE5qCBBIBgB6q(P+oSj);:U9@TZM^7:2+%H<TLu;$(d<s9rU%sD?T)j2*E2UKe"R8`h\_UZa2Y)#b`$d0_KIle2NEEL+#SElo:TPaq5oF;3gPi<lZ9#\sE6UAtj3e,>ZH`279:kE_:mm8l<rkI6o?P`E7<$'=@!`!mr?Z@<"Frh)Z0!IH@:D_+Yq'/7TGhV7;)C(^5[%gBK+'7<9CCW5A:8cc"#7S&?#1+:kPCq7W`sLKSGNe,M2[q<`mR.>AL3*F+dQ4]**&U,;(Ec4TbXH=/Mr@'huHC9p?[#76k^$IR8_UG<4[Fh$]oeSpqP`L8rEh4RfuptL#,2TpJRD5PkQYO8)gd;#AQ7X*gPRFt>M%g,%U28Lj<8eQn(^[F9.GcQlB&7ia>L61u2<NUat$N(lB!S@>_/^_O**fZJko'8':h#k+a9R!AH^kq:mI_V6%KG0$ESseLXbsDKW8r&aq3N2#:o5^!k#Z&`Cks(GS%FApV]jsEmLnBMSOe8UJq[258)$gLWZ:He\*_*j!T=H`J:8p<gquIU`\uGat+AXKb#!%t&5L&F!_l8Cm/""3'B7:BNTW8!5;1GOT8*0jq/Ikm6U?5dX"cp/NK/$A*9n2,2[+#SI/oPEHP4kP/U2&<L-&[-D;@uGg!k>Wf!f-o;"<A4*=:eGR`kE2p@7l/uXX2+\!'o5bD0!m4LV*M-1#>X?[FNeXW\H#1">&'%++NR=H!B06YqK&n^#o>1q*2aHBmQXncKK9=OP].QO=0rer2fLu.4]"i-'NULdf9DBaOeBONC!iFL-Og-,h=l"]rJ!&U3mmm55scuhj6sfg9Q@$n7mGop%,P1*1Id0HU`QY-JK?*6jji!TuOKZEQHs&V.qkh3NHT:XV9l*2V6I%'sD^`-.tqkp?I"IRl7acXl/EZQ#MF45dafF:Sa)<+(E?TE!\c+Z:@kYM=NDBPUmtkPFIm4VGX@ap\E"[k1@%$ItJ!_18kmDC6P`?A?V%]'B7N44RMh=2h=E"[]5)4>&=5n;mP$8W/D#eoF(A5oD#^C5+GciY6G[Gk\Z^@7Q<Yb6<mW^;N'99f")gJO062lNQV80!f=9f]TW3>)0A]@E+309QB8JtE=@5VJ:L0'g.7#?hF:%E'LdSLKUIkb0Um.)M6Oa"!'i5`d$@0f.MkH=d7c,.c8u]VdBZnGe%$,\_q`n-5T:<!MZB-7*YYkN%-U5:1l0(,#%Cuhd:*Ks#K/;qmQ$_A*jsiO6#ac8_#g`l#m!-"',c`7#FS+RYVZcKXPBAY!EO+GR?EUD`Y,Nm@ods'kUKQQmmNgff`5`8*>C=Z4>d::kB[-&&ebl\)o)fE1g3QfPX/]*S`$"nT)^tbnHAq9oLh$;#fA>k#bcUX9/YfJ;i8nQEE+kYG9.(kR?<&US!ku7(_#W%)jo?G&E)Kd_)9lqGQnI>EWp)r%4QT<"_b&=4TU;)GX3<>QL<`F0aAk8M?"3ZOp)YFE##/]JTTBL$q1uOGD_J&fP!f9FHJTabQAL92,+X=GD%)0$D8".ZP!9UlWuS;lWNM`n%<skl#2&Q0calR"QEe2;7=ekI-'P$3pl\-K!?5Xam,12/j@r82.2FK;We#g;m0pu&cs%HXP;%RK72JoQn`UF&OD^<2b!o+`rh/kR;6S7*7&;O\&R*q,?j0]Q4sDka=8Poq$-(KE5ZK!HlEb,$UB5sTgB"jb!ChB2^X:\4@@1XX)nLT2P^>RnZ35!pXjGAPM4X*>T;DO9IccD05,&WEJ9nThdlU9h7A]ggBeFs=Dd%j:MWGIXd`PEd0WToc-i\_k59$66`(lcXYQf=?+3,PSkIl5*>sLeK";mAf2LLbk.jGGCR\s726C]JEVd/]ekV:or";b&\F[']=%H)HMq,2,r9srX(2Xs8RUTg-Ued=Vm3UWG(.l&QFG/g;`hk&"B\^H$@lgF#!3^B4!UM?U8B1&r0E@`km\SW%8h_!Z38j;Nf^qTOdj5%4SI9,kWdeL2"*X!@;s*^B"ho6YPj3cpp6<Jc@kPTrpUeUK@*^j_f'WgGpI+deqNomTXI?+l.V@K\#Q)iWC[j2h5"9K[s0jho&2$[O0J?:m/>(Q>!2)MG3OijJ2eqV?-oRt(X;.`U8ggmtCO\]eQJ0+$0"b9YFd$cY&&qMjC)bI89;6TL^>7QZAC3*Gmo7EH?WAI409LHO\][p9(EX"Hr1RO\KE@4IIBT?>q^"V0(@ku$OU3o@<jllWP?]VNNGRmcKp1f&=[2)j1Dpk!#.mdsMV0n/oe(!CX5<*)k9h>aLY&b`RL4l5hg#MXe1bs)I-mso>_O6EeS&pc-62[oQNUh\;<TegdF5rXR*c`p74uq:O>VJH_6@*1fJk_h]^fj\m$pAb:*k,.oKGc24ncfb\Hk0nbP[.q\i3c=Is?bc-'HcP/!e3'be)9jmVd'qj\#DgnkP@)poI$gW5_U#2=iS)QH[NMd2>XA`bm;2^F$M*>*mr0XXiC>qal**1<A-FV=m":gY*eDVUp3STe`1"2RYWg[DB[p(hF((\E=LX^P+$/-Ll@''r[ido'_`#OiGU3qZ]fUI:@Ln&SgKh^tPpsV?l+,cD'kfS&&^GJ`59s?4OptJR8/6^a5DI@q1jlk;j__CeLGPQMO1hM7I1)T[t&T';9qp5Wj?>A"bs(Sp#d_UNDG^9G+EZd5>1Sa)A5r]Hte&gN;-ob=IdJ(8oQ\ZHas.*eD.^c3PBj0-+mZTmc&:KBI_(AePbr#\L2ur'AO`1jisO)tu&-M3@O$D,dX$<r^s)IsemPE(S\7+>c`plM0Y%aH==n2u.Y^mgq'"9)etY8#a6$33@4u)*t<*m]VbFs1;B&0TR^o\>]%t?2L%,lr0pJGQ<"u&4#F]IUp"nZe,F-X1bdd[enKPoeY`:8?P_d_`:bLL3_qa/cA#*AqmYr3-=_F^OW"^8+H4nnCY;A<%^1C#9m5"ajnm393gW1=2_[-(dD;L?@!UV!%V8Kk$P9i\%YaUl#66a@bVBd0WtZnIYpot!t]R=%,!t!BK79bA13qopYsCVNaAl%7mVioIU)YlH<cpJW09:a1W_O@@VI`r8\PsUHD`,I4meCh^XAuS0>a^g#c,A@9PdXVa]??IY#VHS.<?0kQ![g>?9PI&WK?tlijJI828X5o\%9(Pg>]tV$*Zht71gkH%(&K\:(qFbfuV,^7hNP9g,[.Oc-(X9/nN+thrgRuZ5T<&<cD56Z_nOm%Xq4eS8Ps\\FV;13?j7qrX>6AmWm_cjALOq#E\aFCKmfXe%_!@p=Pd+SJ%Q$6nDpHmbR$QNcYhQ!P5E\=T3PI\T;+_PE4::Wd.B5qj&`db'E<@+1eY?\[t$@;;b??!,PIIQ:6HTFB+qO?SQhA-SDGY!lXWs>\5%'Y*Ue->u+G7(9aQYgrqr8Hnp7t9K@&:6S&%KfVOV<?de`8:s'EO#e:9oSQ;k;]MA.cbpG/SOaWiQoXUL7OQOTm/J!sA@^YV/#1p#'hUltSH;43A.Jn+d-1i@1*qVE`'!+]+`@PfVN2kP&CE+/h8HjDR\5LF3;rkN)XC%K:^Fni3mG`]EKTf+$eBU$mJ_+0\MKmr.f1iDQFaok5Pe#6pk(`%9rT+_t730lbO:sgP>EBc&3jAl([*@[r62=0L9@Lr$@oeMDf\OqlapY!83^8\<OG+p^^!_D.qZB(4!"%Q4U>B<39-BIcO+FmgI*3R3FP+c'4TaYh]=f5t^<7`2oZ`jRdc?l8VG=R4etgsAP9l"KjS6&Q_IjE.aT6?D68'lpjV%%O8"16NbVubGq$I2%Z0(k=0a89#A-D$$("a%Z!ep7k4tP>A1X?sU@ndm("bO7ip@s@CKSX4sNcR*6CeIS@aEV(u=d\th=>)Z]=ia&MYioQ<>/C%IK-[0?iKf#eKa*sB!LV,p>bs'<<+l$`ORCZpf#$4Zr.VmgT6I#VQ*7E?m^Bk/Q^oe8C!BIl[MT_KF9__P&."q5I`[I3MUluJr>a?ph=nlB]f*\.](q7A\JQhInl'&>jqZl4W7?OW#[nUf&J?!"8L0E10ld<CO>s$C,8=9LU;@t`;,%BA3+S7Fd-qcr$4BtOWi1l8Jn'+-@+:<Agn4eir^hhoGQ.jo&T_'Rp2,pI:Cd"Sh\fIqm)Eo;GQm^Tj3HNu%a)`s)5)<^ob_Kl!sJ%2DcJGMXFg-c;R4cIG[Mifdl%LtO-h/^f$aFm-CHjh)Ch86Zu[STa3N>WngD6AeEqRSC=nsn$iphEP/2Al98C]5+MnOK9W\?,@U_j<P:`[W\ZlN4SAScO8-MflQO]h%H66*prX5!B?JJsR5bh`,PkgXKIR?uO1L7OlG&Ejg&fK&R3Uu\G<*(IcY/YIK(-9>`P,JHp%L11f19M*=XBf8[qKNfY@nh'hGK/Sl.XolX^:e$ApUaTWa-!7s;g#.Ajt`l:<RO*6)st@%Eu*ob]OS=[I6BR9rsN$@O-C=*9Y)DC#[o`)nIKCbL>uaM8M7dZ<EQna)N#UlZ$O&^Bs6TuF7E5Q"5@Z!n#L9;bQ8u1Bn17R\MRI>d-+q:Q]8`ugb#M5`\-jID`<Job1-G5>DdVinB?Sh*]j<p,L@6(o3"]V[fbjUXq[BP[;/,#Up."JhdkU4Xf">co0,uZ9NqfqS8#HY+6)[<CNuF(q]s_KMU.)2O`mrok$q$>'`O<89>2,;s14%ibXEcaK:FKY3`!\!K4F121GL(<7=\Y7pPFo^4>=)I1_&XCPLsVl%t"n(.a3.XM:JK0"-@i/O&OjH!k2d.#eKHMg*4If1lCn_-AWf0c&dCOAHsQNQl9HF(1.<Ip\3?)\un045e8gd80!9*e^'CEJnT.SJ"S.VNLokN+<fAgRQf)[ZVD0%.0o)N;tZk"./g0W8:.;c.?hgL[R%(sN1k;d%3ssBhd8+*esns)C\s@.%hR#[PWVl[/K!JEAG?h_]1Wl>7(3mV7#@Zd--Opo`RD+L@"CRLAGuY.=I^X,c/X,:4=&EO?u#pmdMh\5n$:na!e32b`B\@fj&]>>rJA'FNBb(e<#HY!C0/iuK.P`cJBOm^]r]AGWqKOcfe;%O8g9nC.C4o3#OF&g*XU(5Hr$81$YDl6`g))_[Q,/KU;gr,n[*XjK>ISNbe5&ZU>-C5P<R;9JU_GGWj&l[*s>flJJ220Fjk0;.)[VLMB?\:`VWp:Ic5X"`TECFBZ5V45Cbp/(ZaR@%^(aYqJcr[fHlXN#"1fQ6u(.@A'EC4(&\BJ@O@iLV@YtR+)#>`O'tg+#j\Lq=:9-!h`2%9UjT<^+Fio4IJ1c+NIM@q%`7G,-qEpXCJM5g_`$L.pYA_tRLkqr>NmVBf+5o:XqHUCnj*3R7ln\4Nu/\blEUKF"X=*NiQiX33grhknY3BPTk*R53)+Q1aZk%C9`+A@1,(j"_<K>7iV4^[0u/d;OOO:C,>cfXP*A=SrV]Iuf!/&Xm:WFpXJg2^bS_N$beJ&+LhTmB=@A6,Rpgg01Cm2q8)Lu-K&WcdQi,8)3Dd++4hb4/!WSGSH&-B!#FbNT$)DR.A!bUbQ@3NL(1<j]$^J/03[W!F"TQ9fWf]S.aTP+LoRk3q.#YdLO(>-*c*Y%&3=J@)Y3l%)6qmt#0TM9t)[8],$A>UY^BO_W>6-9<,`&>6Zk2%2X\'^c8aa,E;mAT!_^64Y.KSpm/61taXqr4YYrT;"fJ.T6&n*q+LMI_Xn7+gq!UKV!SMW5H]`P(07",?T0a<[(#+dLj,3F8dX#64*8Bhd*/ktjj!9+X\rUbo-!1Mtg$W/Y4H9M+SEC>ci,oH@\k`G9se&oLh+Ro0E*0+_T!T8Es*p^Pp:)5XP95E""9.W6pk?ZH@(=&Kn3@&gPh@Dk5Gl1B@f9U?YXR(1D%1Q0qU2D`RjYNsUT*eY$9Z@4';7Qr(1LS3o+'e\HG-HZsOZ.8ua,>I*$YIXKC7oX9dbfeM1^mS^l4iUN`=?qIKi_n/R^K3`AK),$.LV/=kun^bjLt*u$W-3^q?'`%hpnAe`9e6bM/QJ6rFLYYe>23JoQo%Fhk,>@_E&MXk9Fe&Fbm[Y]%gX@JT>`H$nuC3THH!kl<=sQN@+Vk<O`!Y.e8Lid+*/3+^@kO@rp$4ao=W]I)@AfpE!'T&od4+[WC?NIED5tIUBB?9G:C5D]WsrLu!?^_sRInmK<.k5\]*_;c,8T0SOd^_[,.t+'btHl%Q9S9q3#P*X$@lfUiLJrZ?<-n3/l%aTl2a^`(JR+C%7V#HD3Fc>+$"gDZs7,s'mh8Hki[<B9T2*d?Qj'_*ff"Wg^[Si3qi)$D9!6E\oaaGL9&ge_a6?;QL7L?C)^&=-[s@;G]8O*JH(0UpoXqr\LYp+D;L#uN(OpVZceeu0`'qHqm=V@r_KV!<\ln6547jN4u3K'a_$`Qaj(H7q>>nTb</e[R!5YI2sE6c!\M^krZ#L1fl?=fo<F>:H'!=@2iGpO@!LYKVA8>70Sk5%H5tBG)LEp%A1-2tXNC43INJ8Kei2[j;`Y*tsTJAm]L&WK9VC<p(0C5f-A:&&t_;[opnpp(Egb"]]a.%]$)E-aA7!*WkuDVf(sdkJoP!J"(E$?R@aQbd[/D`.nO3=eO1o>slpL\RmS.n9>*>]GN_6OFRGH7ia..T=H.'Fhp5@lV;m<GDRYD&>;L4EiMW'Ap-,f%`qdQA;d`=Z=<?h2ktY#M.rDf7D/I!eF^$ZL'&kG"i#BD)VPJ6!MpZmm1&%KTP;%K,3!DC!:cQm3/%'a;OS_&6?63fG)uUIh>=)OBD1[LK5Tmoj7r#NZ0l[D5%Xl<h37$8lP<=%%>c`*AaN`*h*(qc0'gKjG>D@dpo)ehh;-ai<66r0"*ahb"*"F,XYXoBSkd7AE)=mJI6@%2dZe)c[=VihZL6=U-S\799c\\0X<LEe]3O*mk*On\kSVs:XA@S!U2Fg$Bmt:CF(:]o=Wt6%L/^5DYAjCLB?XU3rCS?!Y'ZJ>5`$i92MB$!;7j827K_`FZ!!6T;7o]57TE.O<]kWi;:\6>B^>&CYc;b/Z`;`e6I+D4,NP/*A9N^(fnlQ+9EIB2Jb!M\6H*@@"QM:,=.Q<GJ7f[Wfq5Blee5%74!%5hB7DJAlpV5g@c\Kt[O^s[f0m"!FI";CV3;@`IWiT.fWgbWgQ.de(n>hS-amb.9gK)()q>mBK[m/!_KD!PAC6<9>*9XVT4TSdAD!)3'hfXn[njrR'^,Cq0'.0\E%Q9LIqq<I8*sGq;q38o.4ku`-Rfo;$MkF.>>[K&9t:+1Ru_Ee<E,dAOdR\2m9C<m@9!'abO@Niq0Clba-Fg/pg-R@d'/).[D9JH7!DUgB#g+CR^'-BJ&;.S[d&+m^0(3O1nOJZ0T&%fAj7QG?H+EM4?28;986$(2*4j9$1<eKV2RaIHMqip's(af`-rjdGJ*(c]W#;5C<ML"k\.1n_(q<q*`1).)CfB9':-qRcG8P*/5Gjh)rW@4\AqM;XXYu5MmbS[P=d2cJd3V7>,$]BP"baI!l^%.99q\;-#h)&M9QsZi4XK@WSil3W=B+[%jca>IC^LIG,am6gn10aSpo$6j-?J_-usk(@^Fh;>..26_ek6gHT'B"D(!Y$`f"$&o["HLEe&"lc[pSZf\GQhX(^:'OO2S3QA8,AJLRI\5Zsj?r%E&bRq0dgQKrF[T7o\R)<4A7;)[R=l29;4R;Ca")Etq^_4ud#ZNQSe?&l-IDB)HsnVQ(<lo!Rr)`95f:%AraXV;[0PgOh;d[OAbqUur!)+GSbZ/1&0aQX$]ea)q*](b,<^,"@jF_[<ic5hj@FtMR6%NEO]$)E$JhQp(Y("%8uk\0LeI$5T?=N,8_E^B!N<`F*EEX;X.Kglt*8p',-8Ru2=0g-S\eCM#Pe[%*uPuJpR"(MlaV@BLl_];)_1pOsC7VHdl@Wg[FX<N6tR5WjaD&3j$C=T$$nrMNal&;(Qm3.meN6EdlQfQ7Vd[@IX1TMTO2W[%/c)Hi1Tsl"kfh;NTVG=RQZ5#uBNfI(r.T?C+44OaSb4YQDcYP?&dkd1AKiBTC70ugEk8QjR!Cmh;B;!B+<\gJqK_1US199.r*NKS4D9&tAXa+<n\b4=_i`"!B_R.%lW`2TM`du=IM0k*K<QJkNHXpCVRn.AS(i@[nA<ol)8A?N8FmEqQ-Z?Jr`ohf!'.ob8Yc5cgZY-]=X)B2!OWoR'(R7C]5K9Aq7MngolHR&7BrTuHKAG%jq$H-IH]I4,QGlnOE8tM/PdJbFmEM+,HI1\4d[g4<of\?I@-e-Y%hP3H:CM-`:^OVl:7I)n7\SWh=\oo7#@a"qi*).`Z^]l@*6]hM.3*"H,D,tUVI1f%&-)mPJ2L`&76Wp>"p=B,p;TaeT6KNuQX`YoSTa%BOZf.78"UTg_$Wm3ASESJ'<eAf7d<UN>8#$$S_KjD!'_`%'fIq..9%eY>=au_c9"X>KHZM`$33`7QGn](RKBd@i(k&Ad_HNVcaGBe_')F`#\noBU2*)Nh%DlCOh5YIN(RYTVH6\t0pEAq6dDJX,9=[2FN1P.JC=KWACX'h=r0Kd:jS^9IB;q7m<:W#.d`_LUUo<+j1.t!M(F_t:2iRZ0p#tI(ef")@TAC`DO!nr)T&K"ENG:(T8A0=[,gBF<N)bi5CrU)LD!V+l---\@s\HImF&P4>.hjmrN!%N(uFE)I8P<-Z\m-_FZFU7Q.71$7G)b:UumW5Jgm-KO2A'j5_M3RI^!J3`1\kI+"mmR7(;Z!n81JAOa<ZL:rkO-&A^2&@=c'6r=kP,(V&B,6(i#QK0eFW1$Aar$N`.1XB[\B6j#eAA0D5R%5YO`p>AMY8"bp]L^k[AZ>nfsa=Kn.Dua[m%\K1Y"^T2IctFGjI`)?&%)fWlJruiU/*%=a6+jJ,*tSGs?Oi2H!(.ca@Aoc/R%4WLQ7<6ndE&\+Lti;RJB,WJ5FaV6'C]HdJQ<2*r>]&H.!g\"`*q@cRMR1P#0ai("nIuCg8QhCIi!c?D#(,H3BN1WMBeY^k0^b8nu-?pG\Cgg@-KUXR3Nr/[c..6B(gCJROs2D#)iRZG*Do'EDU!?"pfs)/@\F^nL&k#S/G*m^YkLo&dA>=06B_fDNO*:F/8::*D\ukGEa"p?On(m+%q1&2E]];c$8]?>j0?qJFS0.=0neM6H+iuM\Rt5=C\_'6WWJncCQmCIFUU&8*4Zl(?NoVq%mi"K3s'[4=.SEetV>TLpJT:&U'l0-@-3OelSnpDkt1aqKp?hEgaobka1Q2D^&I27"7>F&^KpW$Iu.:q;iM99M=;PT@mS.fCSP2F,_ag@?F+`XqIgu[of519YM6)G.8bC2h(]#9m_mD4+G3%nmN-qj*;kH_??-3[AUhF:s#WO/@/jZ=k4A>`FFK^a_'\\\%U"k$=2%0bI+m6PJi#Oc[()_6uA5]WW6(t_(f>p%GTD.c'D]GgJk91s(5+aF,s]mUEr,t=s'KXUBQ,=8I0PW.iWSghC'UD9,uf--rN3d95TMa4.!:O8V7,.W;IX3)77d@igDs*bUSF9h/AOo`cSbc?$)%Y("-c#EO/bY&0:/>Rc1i6:ctF#//nuupLQfu+3'L*)o#1baYgkK:\%ndg%jijPA<Vt334)G'RW=u(E"_G6bq&b$@ol02<X;m?@>CWOZo+IZ,P"-jK#01o*<da.neQ!05?>371ZIX2%R.<RO^`U/XV_Q_kE;Kj[^FJPZ%jcRj,s*l_KS8D37KuB&8S>i'!3+/R"mb5iD=OZAZM<;B;!14X9Hr4OQU.jM2qpKZYFpMK+>F)joZZLIDfDKifW*]hkuBN**)d\$b_GX"e%M[@Ap&>g4t$i=D?]Q=Y/q9sQ>LPqq6,0EjjpnG(&C[M\OK`$LmT"HolFQ.k/QbcB0[WdSU$8G8B@O0@`Ch!T7VX?OZ-3i.f5MF(iY!XtHu!u<Cl0l#mER,)iQ9NoDMXB)HT&ALQ`]4$"$]+$oM&u34R]^g'lfcBbVfbGMUcoh\]p&OJaIKr.3d:Qrbom$8fRDG_u:I$4C5#u<MD(r/IkK[eMM0&,`.6&VG?^",4b/[3*<)^p6gl>_!dZI4^G>O#\?p/3%=P%"TUVn&TN7'^EW!JDX#FZ'*f0qucoA5XmBsXSS>Ip"j/0Bd0FqDY"#]U4PdqZ,[gn!$b.pkE=MP$YlZa1_I5(/o6r`9qJ@n\@X]ph3NoDZf([rMtLb4=a_rDM_)^5X[iUnA;N@7;LHkfdAJ6gdt693=-,DR;g(]<U7;+=-2Ss.4ZpL63=K@&PD]h)N`Wqmq,EN:(Oj.]Zr_BeuoA7YS<r6-F2NGq8thf;1G(FYq`ll6Q09BsD5J1hqthZA.6/L.%Km.@Wi[=&cm9aN$oG/gZhokeLh%+pBCr7&4NYXr>SG55GEIm0aI1MU[*WF<ulsp)4;FEaNDMonq7ijZ9e[<SdN^*4iY`=dti&=4SmMV@Y9#7+u0WXqnX'KD66N.+YJ8VA0:%=sd4\eJgFrpFjP,qcbiCF5nScR?ZI0m4W0'MO$YM'TAcT<2rJ"]Vd5/pSE3XCX$e*-MJHaDSWSPj\s"Fk=Oq`lu(%B`@K5VbYZZU36(`,.b!&,Eaam;Md0u^DdQS2GunMI]f^;haLU1,i7FgM$%jHda0k`&SFeSjXJE,QA.>80<DgpY@Hrp:P.C;<qIEKhc6mRFWRn'.kJ\fT[BO/>\L&O_*.Cqrg4DTc*t,P'6gKrWXlgXK#06f!>`O_=F(LGpl_IodJ7):l3s?S"Yil=2<iQGhCY&7:=Bb:n'NI'dAI>63ep1IqZTMPd8<5CP-Kis6hUP#kMGj8VF];o+3,<6WT3Cf0>MG(I>>nO#Y$D;/!_7FJ-7l29@1qt-Fk`J!1\k5;6Ch(7WcOQW:iUAEE>`][!&b$ih>ZhcaD_?02K>6!:FH5komA,jEcL$S*#LaUn.\IJcritrFr4,K-=%7\I%*PuVoEhV@bt+Ho=!lT4Yi3B<l4NLf'-%G5h*bN_Jb6)_YfGXI%`(ce1'6q2'bgqoP=i0Y).erXDK0ZhQAK'Q3==V%7[Q]-B6:W/R4SF1C"bl6nT1P5s5XRe,\9p*#_eIBkZ@JI7t"c/W!i5P=/E7I>doLbjtXk9!sD_[,]e<>YtuK3(K\2DrJ0?Ba.N49tSjON,+PTo0(Ud4d**QAY=tVf1@JYe[bKjN3W/KHaL]a.)-_-@@]5<4U_(pX0_]h4F$+[j3k!<N4849*'#pa_[X:$Gi44?S.\ko7B&/@"#<`s]OS(pfUdM'V<@B_].2sf:EtkkGCrnAnbVL_cgRf+g9eX@/&>\(h-.9ZHSgGTF03.dk385:2Oe5bW2bX/P=<BAOd\$D*&:)2,XB7gj$ee7Cp'1'<^SrAU)]]OP;s7NY^chO2ZKYR4Zd(=>G=&%8XCB3'1'JU/R)iEnL'H!;TjmU<Y"PgqUR>4hM44Dq?RKs,fcBT$qnPFEhZQShRp,@e1M';.E%"$/=j+\On:C4VTdqUg.1;cq@ELn\u$7Y2=dqoi!"JBr6@Q1/qcVba)Bu(,*+)G,U@a-eA$C#J&Zi?2Z\cI$U'%`_#g$l:Ok6mcU>PIi2'>D'r0CF_"<mP1-Pn&A@W/:XB?NY?<5<sc&Mb8-+HgG42Ys/i0BK.j.l0`m)c"\>Bp'r$^/0m5:<N]6_m6[J#[8Q3L.34V_*Z`9[8I00@mj*-H:]'O=Zi(6W;'+[G('tIb4N9\`%k0;ZmN3`rOQt)+:#<YYsTm7YZ4]2;Y,c\l"_o8s#Nfdq@'p7s'7WAL'qgXGV;DI:0$!<8)Z6O,'[b/9%]Td7mI1<aQ^LiKPpq5fWSPkNN?@l;187YLfl0fu0&Eab97S;^^M6"E!`l6Q/gJ^-MT_SBKr$:W"WCM'N%)K'0U4+p`a0'&1prMfEZ!+MeAQnh<?La3MAp%ga2ZCk`_XpersQ:tLDe`_Xe.Spk)_R'+W>>TmY!XqJ[X`;*0"l,HP6BD.73O'-R<Z#Z?qf3tD'fj<l7fci<"c]%):-CJhTM!QCDi0QQ-Yp&%@S7';dqRN;Z,gHL1H%NW7b`fCuXAMf9Uiq6;IMb/VP3\cET#2k7"?B30$q_'T=_iP:=&M8Y*/i75&b[MDFPAgi(Ss[?Ng\$Bl%_QamA[m6?asV)-elNb+%bjE6d\,T%Ijoek;Z/Mh8jq"*2c%(E%W.?9Tj8R"9F'CNVqd!mpZ>4Lq?-u==A:i)#X\.3+Tu2`Ud+.bbHWOJQ$`IFD`"ZE7m9*!dh,XEBGMdiu,_&iK8cm0D(;J%C3;Sbjm-SfI"C]'Qp=;1mbuoDQ#K'eY/dS3uj;G-2bhVZd65MhX.Ls3;=Yb%oL-t@?V#8FT&(R5LiF5Xl#`HBTJ,IK#a!4GqX155!]7Oi,p\+5L>#"@9_a[9%_D4>jaU88+D;I#07N.H\"rAF:gi=[OQ\+00$Eu6SI5KMr1M.090a:;HF:&pioEn8'.Vmo*>#=?.Y8s/h00Z[3H!a1/fAj2MK<QofG7fKabC7c-Z)nG*r>p-rhM1U!ps:V8/_.iU=1"!I:a:k3u`*)L=O3f.3!kERblJ6H9>"1[%"IGPk;l%)\=B%@^:(d"eYYjTI?]iBfD=i:f[T35GapeA^2Q.U1Agj[(2[?+PFl%]O%>r-AX.lhOs?dDmF@5]Zd.Lel'[poO#2O'[ZNV^"LH+`,/_%c`nPRWT@Z9Eag+3`ePCEA.#pcXE5!V-5?q!T#+=l,=qhKN1/B35St548_:N?D[-sg0>:%>Q*-JmMYl<#nB@h!%e17)[D2tR#^;_fAhC#fg3`":)#o^W'qT,LCt#FhO#PZ>BA_0P.goIE3NFGI+=8hUaCb;S7fa=a:bRa@D.T.`FuZ3`JOg>_uZ=]+Hg=A!L]4T?2D]FYKsF)o[1F')OM<][t*d4!Xfj_b^YA.;:3cuN[Ogh?pERodj!(W8sofn?_/3LU(2.sC)^`^U*`"l#$ILXil:(^G%&oTG'l,+NV%pFnqP%i`Uqp&;AStRD-p?-?XW3/^kGA1_*n0GhS*e*'2oaOG\[gl_ZQVPOKchNMY-l3"4$8a2NSKR']2IslF0pOVtNa!pgn&0]dLTg/mZ`"e<,SdA3;/DAo'-&VK$?#TCRmI@2f0@T"hiQBE0CjqPc2cYOSU-Ds=/Dh<Egm8q0pg^u\Lq+Vsu7/[i6#ZC`(']2_'_4MZ*=_J*XVX.q._",#Y#?V[nuI!LM4#a\jna(tDYHMi>!DAiUQ&kl"9nEau\mj$>X8Tu!up>)/t/b_S'7kO#M<UI8iiSI##(WM?0LhV>hK_<>Tm/Mi?>/pTM<`>T$fqISOb_\_\nYZ22)Kiht%ILt]-aRsNe_H=A^HCQ[lce'7(Soj[RRVo$SMEM^%ne?LVpFfRn^HPl6-Gf3K;`$AH`:$?/@VgVDY?SZ+R*+p%c;_P7PY\4$TghHWVW3&TK)oXgb%fohg[XZra@rN%mMho`(Qm@1.*=1=HYG/8s<IW(1BN)@^-=$CD))t9N]#VEn#lM.H@VYgfS%X@?o&nr^r;(cCD[o/T-L(,3l)V"'hS`<ZI9D!K,S#M[P[gAnL'b@se'2LOV.'i)(QHl>J&Lm;g#JJ_OTD!8C.?OIt7$T54$j/Geb,=!fh*&Oica]$9PXT/jei5J5jM@K=qNR3p3"Uc,cCa4o8MZ&MngD,uA/*o#L!^Nje,%;CjqRJ*!(gG(8Wgm+<,2NPR?2I\86ff,YJKV<-Kr3Onahg-BiVRaq2iWj6@CI>[J5-f/g<Hd=@Ljl7G<et"M^f+6._S!=]C/Eh8(76e((.]08#c!^&6E[5rG0s1GG`%2GNVZ9+D+lCZP>]C24n")EblqcH>fOAsOtPt=S+G1Z1\\'#B:2f$Y#PgI]Rn"/U:^4d_XR\qNnHuK\H4o>dRAiYg4A_(Cm^/Bj=X>#PmB!ij:[M8"U`?=TP_!(c=%`l,H_/2!Hq(;Ga7rUb.D,J%T<WEFo[\ls$]UZ3Rjqpa=<?F,K*NS(_EL#'U,n(s*UDQhkcia3s/!#^#g/`C-$uZgh5kK'$U<%DZjG3MRb-Lgk<[aIT7KOa3o^Jl9^Kc0"0e;LFa-,ic$8'*O49][]KOs`]X;.:U`'!YH-_c<mB4t;A4nm(PWh0XL0be?NB%Y3m=msb4NFr^PRISOrA'3M&5>++:.+k<OGGl8[Q?.(;_BJkr'O>7_0V.i(jPb(VZ]r>ese;`IKlT<q=ifPMk*_i5"kF%nUZkGHmY<J,8eC>aD<.%'J]Wpr0`@<SP3e:t[Pgg+A\`b,]p3DJ=0k`#G2s.c2L+fYCI7dJ#0?2jF,fU33F*b-h?EL\]@eM"mi2Y.:]m(l'[;`*ZKXqP::U(TBnsR5QH'o`BZLgbs]N]nImh6Jk,&+[Za,Z1KNm%l'6@NA`u4[sgLe*4Fa$0KN_:^tou87jVo@k\I,u6BM9AfPKflm()FL4j!E(Iis[W7662K23&D_&["1[C?rDq;C8i9TTs$N"3nk:G3L\?P:]XAoRc-(5Y\)c$qX;X`6+T)2W;(UZ3R]fq/-Vl[>9Jj,9q?\63Pi!2=aORh$kKj$"[^EW/h5=lt,G?faLCmD8o2NK8nB>XlOY&`<?=n+Q^QOF.X"sE&:D#cDGEOAWW@>Ns(.K&BIPA(^eAkr0\J_CN)l%^HFJs46*Q=%$EM/5OB>NGRs6gZ4FTT0hXAGXlV;-D>pI3L3;bUG;4sOmDghW@@!&cQKul!P[9M?J)u&RS21S._0Fm\IR2-HQhL.ilTb%]L:Rj^/bI@IBh?s@J`/C[[Gdn:WrffaW*W(S@!&U;@,uM40-1#&TD[<,$NKGDC!N;bgn%[I%o_M<'RpWQiI":^AFPGb[g-dT5IU0I[#-UB[m%2Gp;.p$cj%,Zs7Xbdij18N[`q=4@<`_mR1ZI=o8hHe&D4K[^Jlmgq"2+7_Gk]X`blR,a>aS?7j\WMQ^)Z&qnp/&bA<i@0!Nn7?GDX$noU@;YO`\!T\&+qY#R(J^W=.2O`O%aIT+nflu^-=0'g%pcXE%0'?KsM)YZGSN"jhAjMg3k1$ch58.qZH_H82A&,;c8`WB6;UsM86qbm#?i(.9(EO3rehJ(I2X7T:U66Z01^/LC'jF'ea6Z,nm7$5-=rRDqg?l<:X4mMWt>Nr#6o(YG()h</D$u`jJ-Lg"Z?k6-VpX8[8dD]",D"g\>WKCYu3h'62ZZ4iEXo?P)EsCVWbQCcYo)g<6pr9HJklKs;TW[P(PX0tS=WF]/0'K&KX"sl?Q`!5KI(-iU<iMZ7r^8@%Bd*8O6o4$nDd%(PYeOF&E:P9&BX0;WKMI$j:Ooim'PgV:3<#<;-\=%[$<b.EAZVLl&r$dmn/?RnR>s7Oa=_;9=P"&&.QkeS-2oLG:9tJP<lSp,M))Sqk-$IRMK[BqU"tn9V;F[<h3<KRE'J.cBl.)!^UpNX`kLG+s$RQ]j=DN]rTn&cHreFbI,*@Hd-?_0]r]I!Pt5PRji[^WhY+>di3u)-B*guL]0O0[FNNL5$[m=05s!t1]d[_aC1`d>$?6C7`N2.pH<okA\qs>bU)s9[Vu'p.in/cE`<Y.&PP]"h@E78fG>9[f,gd2uj-(r5GAni&b`(D]9N2s+bWSpJ+WfS^>.0_Nhg"%S0/.Mb;&c'IO7B&YO52hc9:u!e3od';&af>)\nfrdo<o\4!#_+[U'&M]B1,@DdN21CHS'Kd+i.rg>`=7jqTE=N!R(aj],Sf"$Vnqr3T/q4&JH0n7F)77kH=AtGr1NUV^l4LkHMNUZ!\GX&!,\a6=tOSP?u4CYYV%::d.Xbs+4pi$^C^!"Bt%f$#C>AM)'5["RVClXmlhDF+qKf_$.W:jfheXW%4(@A&VRh%.%u^fod6m<X!!4<bF>g&b:cIaFC[*E^@FG*/dN;Idrr8kl<DRnmCF=[UO#s:eRDh%7F5)X#G^pP3.aV9Use=CseM6>ncl%.f!DKEknZ?=cGZjfna(TKl#f9PVp;.@eAK.;aV)>kK5VLdY\]Qc6%3##=0hu-CYNG=,Dk<V/sitX#7K=B]KN"V%g!NZL(Va=Q6T$Ep)h.J:K9W1V>U`Q(oQF;E'9d=BB#:+--lf\hlt1I%_k30><=F\c;0101A$bX[0t?"AC\Gibh#ohtEqtceEcDQp#N5!^8EVNp3fa?pWtSh/^hKNf`[<K+9!nFrCFcOI[M!XY;bH#"'^FD*EDkAmgD@&IbSofi]^WDQ(Xj.O/2l=G`f;#)f9e*Gg+>-1>m4f]m_Wd,SL5V3jB,=]^hHQ_mer%5pb:oZ21]e5,7,BXCKCeFS=2%coJqj5@bjXiKq5K&)&eEl'J4%5WnS6V(^cYr\A/9rI$^fEpem\J7G5M;Yp">,'UG"8K<Kp9!L[5SXj3a#,@)'%V,HoCWP1iInqug++Fu)c$(Z+XD:c.*88jd/_d<gEM3G'SVe'6X\1\IR^so8c,LXPlKI",JLLp>@L0XMdWGcB^(>1nU?4SOhd7[M*XUQcFHkHVK=+'+UMTj`8Hj/]'DH0K+T?5LEB79@3,uqr"?_%e@G\5+BW=i3O-]On?*/pj(Pjb59sj#T3]nD[,BGZ-2)1>A:6Yo-A7mXhrbe4RqY*jWHM1E'A_)"A=DV*'>'7=\_P38,&)4f2_O.-Ik[J^6pr;\LdXX!?Pk,SJ-MMJnA$jb@iA0Q*bV#-0abiYX,2m(q4!HO"5TQa4^mhEpAiK1Z]@&n-?HC0VHB6SG=%q<X@jaK,#Mo(9t*LuUO.]<=NM\f/Lb%-cUqm458"(&Mpa#.PBp^(6&4aY3Xg&J6c?#mXInYt'!/Z]Z[Fm\67ZHT[!l"KQ39%d1+G%/dV&-nA65_.g0bnN))7H:ULtbDcb.@lLq+p3aQ)qAO]2\9H$tTb2m#t1<<4NZldW`VJN=."Ft5Ft(apa,Xo/_r4,pU+Mi&<t=&^o>d4TE"BH+5<Ln06'nq8_Q(g`7rpYt_,g7P"Q('iXLSdul^%Y;`TA-dTcVo3&gEqc/]S/j,m+&(,X8s!3&aH86C$QmjV,3Ur[Q5G"GiMf`dQ9X*f`0<"O=;$Y$E<JW+M%5K2&.V_GJ]Zo)eb(H;VH0G7B;6l8I`cg:]q)=MqD,/+Bj0b$2o6&:=q\]X,9AnP'i$WOf@4*O<Uirk03\Idc68tm?`$ocs$fng^+&Su,LOJ&=HYpeia-M1-!r0:/Xjc3Ks&g3PN%&*3Gb-%Z3ZeB7*7jQj@+_Y)h&TSA/8Aci(CTE6(4,:&i*4Q0T"=(?kaGrDFM5q/Ekci8p4VV5Fgo*[?`H\d8:DF+sWLOl>o8Ee3,?GEs-*u'/8Yn2K`g"?W3nfE\sh/eS_L70<JMK3huqgDofH=-+Ef;,DF*:A]5t+;WX7EjN`c75/3B^EQ^(Y!Wu?,jE),daR)A-'XEt+2G3/44rmI<c-K#1:9T,OhPL%DlB,UOIDf*cSUCk2lJ#T(@qnk`99grWfbJ:D\eV#N8L$))Mdh/6/_dOppqB33b!Oq(_!HkJn@]_g76X+-5ju2tY)ae7.PbOIB?OkA$q2t3.AR:_P[pCNnF1BZO?+!qnajjo'tgh]k"=pk,>Vj-_H1O\`$@eDpX3TdS!:72NKD.p&#fuN>_]7*j&%gqpA(IN)fU+78V.gOKhY!ePAGu2DPM@eELUrrB7PlgSl8@"A>n#q1#KeF4BljCqb#Sn+AH@B<uU:b8l@)oSdC]+M0_T0&uOI6JNkKfq!9!BDh[B^$qecu+lYi/no+=]^C=P1T3J:!70&1#N8'_f$Ai_P%po_&F:._%dV7Z8*JKXRoZUk#0=^&e3(Z:8bJCjhJ):R=SmAIK+TPf+.Y%dK4t[U@+9'>CZ[H9Zra93nDNW`9[bIR%?Z[f]Sb:D_eq[3Z\6N-;FiEjKYAgRkALd(>m9@j$AQ]CUf5;Sqg)p-s'"I)\VAf?Tn7Q^Z3GeN(oR5^Z2WCFik#p4h22$*(]u(X30)S%9p_Q9<[b6p*UNs7LA%A?,`8%S$30fWnVrmhV"E5U',-k`/I;kulT(Ib:)>#B&#%FPEN`_j_N]89BEt[5*,25,GV$Mg/!hPAQ.gAt0Q![m@m=D[Qfe[QZ>iXRk[J2>X2RXp69,XIHk-HnHWPkiRWKCN"Kd)_A8I&UCXqWdj`=[)4.'<6M8mlkdi[&S[[+f'D7#<r?7WqQrat;C55UZg?ZDiKQ@7^-_Oo6o^,>Y]W4Ro-dcD`*P&h")T$@+Xb6k^&<@jYiUeHAKI=V2ZAXQToj\&*>K"Z23,A6aK:BU)3c,"mBt,/1b"l8)c]JaCsogb-Otn`D./Me[mSiG&kDdU][Tj6Nds1lZhM`)ZFQ/T=5_9Y>V,iVK:k>Y`\WM1s;($Kt\^Pd[j)qeTcp3rZ_UX_*R<U'H/<3;TP<D2*!ZC6]??:;QN0FS1be'9].!o!]=E2"g0Z^7uJ[dgfLq@01LW"f9gM#Zj9oc!IiCjbZ)kX#Ydc6mBMo-Obs2KqL4$:,*cSJ0TkJ_$Ci6`"t*/$c;t_3(Y^!,h>70<$hkU)-]s'Rph[n%&8k0^<3TeeU(@YjJup#!hHfg=IHQu]mOPThgN+ZEddd&O5jX*+_oD-HK!]`?Ddmm>G3@`VdOKX03g]C0`79DPRn5XdY%0o9?Er6D6.YiQg7MZFi<MEf(To_Groo?="T?o9XemimWU0rn):o$#,*EIJ%A*"#&-lt?d=.UNN7-SIAF<t>X%c!@u6C@pS]SQN6%Z)?CiN<CajlgL->V,0d#m`Cj6Zj:;A2/&sh8Z[^;2V8>6>K`ja%"VA0s!,*Nh[Zai2`C&2N-4eEU=V\QkPXHYTEi!$*DYQPaL5i.#6c(G3UU,r[tKPVk%Uu+Km)VI,/*"BA7apdmjAjHW/4UcNor&tW8pk!/j_c$lZ)(>XRThp1EH-["Z6;h6*-u]/Zm"6G*'FKA<!.mT=`Md$]q7V@C,IIObClBe,'fP0QF5\)MCOV@QFscEV!u^4t(`gG"+LK)&mR#%@int/`k("g?%i`^K`8CZd3._OfJ`75`5Zp)5=5p^O)jZ=[&WsXZkXlo0M@25$S2L@VZtusZ(GuW>U+G6(%+?GVZD%>H#U/-r?l+OuoKa*;H0mZ^R5X):XWM=[FPqU%QA2n]4oQ0$/g]I=2Mm@o=%b/g"A]+6AO4`D_g4/ubjs$[K\\q'l[hTX$'Q_Jb_FTl$pnkjB`$2$mrV9u1,Sp:Vj9jgAl,&eL673CJ7&!E[o9$:?b#]`=(A6&1n.dI1+\/;UlMWmI;`sX@8p(CXjmrq(hUd,K:8$8hNcr\gb2MH;As\c&`t1S#h$K3bl<IpO88#Sj08\Ch5J<&d`L.XomXm6`4AGS:;0gCX6aUENVpbF*W/QYl4G.2CJU-m]cTIC#^&We_]2"g6&LUUe=ATKTKA+$dDbDV!0aJgE-</gLC-<.FT@CJFl8;2YlO6=OnY@0p2?icL!qp+k"DVhcS=%/CI4$EaX4OrC*L\51BlGL4i].>`em$%G\+biC%$?j+L#jQ9o`N"R*B?T?C6U]F,EmO'1_dn-`0&=FdVLBO_]s!hgLTi?ZXC+YuWG&;h]G0Q<8_u]^a(L/aJ06>"pP,b[7$jca_$U-9hN9`e$^3d5(o^o$9G)L(FBBhk@_G14.[]-;ioT#ZBfIYndW=+]1#,6oiV^7VWO5n`Eq(,mYi3?k8m[1h]!?%AUTb'i4C\B!SKR;!!K.-;9IahTQCmi'$U%asinjOdJ&UZ;X'ZRXP@#V/\>KdaGVRh#b2)4J,do.rA6<9OcS4d57jBT/iL@Gq?_)fMq2]G6l^Fk7eK`4Jrt3JpD?sK[+3eUT'HI2)IA1)\5`U0IK@-^o,X!a>CT<Njn"aqabl-SBd<fa,"ABa9+rnRL`eQ#);3,Bu!D!RW8sc[R<[]I7O$BTeNl4'R1d#4_9lc_;'$V.>m4JEs2j15.I9@E4No$;%8WSGjF/"NXb2'LV2-4kFQYSH#lgSfR/fL7Q'D&DjjOt9sg>=[9pN*\Qr(?@2r^T\GY?.-rf+7JW]'We06ePbrP^V^*WN>\%=;A'bW$0MGgsuOfsI#c+:HFHUa!"VDS/4/YU^6<j_T;6:GbD^SYc4_rLAZQf!*XLuY:&n0[ki!Dgu)6_QuVcl$9FLVC].o)aKE/0H8lRH_Z)$.sf\AJUl0-hW0DBi#`MiH2"!'V_:GWts;p%Ks:u?UR22_&ruRX;WW?Dq1W]Pd(kZHaaku?#,R:CZ77T3o>obj"[$#.?[5_DQ8Mk/SOCFQ%T=HagH-jqNU*I=If=-/2\<DIM3qb@SfBr.dn#.;KPEBeT3%!D3(`Wes3Un#rS^APBY-?Sp55.P8Tc2r]qh\f-Jt4mPJb)p-\>Y")Z,a%Xbbj-AbYohSsZBPM"p,,Z_p^e'\oP5@$?*n=(Ca6B#05rhj<YZRSXt<V8iGlXF&O)Y(*8ZJS_VG3=RACNn4f-':s2;Y8/f%<!VJgi6jSW\jt4bYT/1f8q;<dMcb85CZPRPVdQ8$4MD(:1d9paW5!QH(eJ6pB8kpZpPdk`EiY"V+0tK$5irmg6gMnIr(*B')5aXiNc(8QL(3TGA&eZC):Zq5ag^"/#!hi>[:>f^+J@@p%Y#-g@EVZiQ'=\j@FC,>`qJ*W7A:H8AJXPb'3QE-oA[VK"c]oqAhR(i@HYjL0\1_["bLj7P2FGXI'6fOouU*d(!j>8+MJT!.G5IeuahAA1+Qd6<]ndKch!u*s=kn.6MVIZq;Cig7A$5o"e]_5s-S$WCLHd!8k]3q!peJ.#&oI`+M@9:!:tjSce&+Y_3==@I/s3PhlSs+ag$r!_;5X+u3mQoKEf?OFX!M5%#`U!*NT01KR3V@T&E>Dl5j:_(_A]jUleGG$H#H!U!3a9PtS1Rbhn09F9Wt2cI*R/G!4h6Q9XpR-1'0rD9C\^'=S'D+\:Ar>j@Yfqs?b;>P@@ZEHn6`c$uOf(]s9=T>WWi`KodXcX?KKS9SKG;60[r!I__'Lo/057^^YV"CrXO4@#s\XHa\PiW?q^hF",A(ai%6P3caJ:1+B7m=G8gRifh\"m(lYGu_'J0jR'mSmZOr3:R,#,37QT]b2@K(I#LP-?*.`H2JsMeF,jnP'8?C2UK_+dm0?/g\*J[hI<8M:^GMI21`mE,IeaKPZVMko3t-55$n<%hTC0?1TC#1@t0:!TZ9SAO)Y^^rZ6%&2I(&%o>fkASFCmJr!kY)=\[bn2K>dE&]gFdJt:>EAIkArEfo'6nf5YF>YlTHn"rS(oRdja\.0t(ES>4,N6uPh$hTm%`&O7KUQ`\i%%1RF:dL]'.P,T0I;bW!%!a1^[`'eF&:dM./8>?(\ib&J7&Psi.>pY^&qfPhX!E]QR0ra+1C]DM@6j!WtKoN=pL%\4(Z_gYRMo`&EdTa7L"N"5npN<e8#PI4b7Se`h*OSK>%jh`&P@4g^m<`!;KImnDCGQ:c@)1_Mgne/n+J#>j41%h%LUEM5%b+j;6::RMk?=arKP#5NiM%/[+11T:q)cDn4\]Hs]]?F"4"dR7:O1[]jL^cK(Re%1Gk!7M`9Sb$tV+\%VT'%ESX3EVR[:Hu":3?k9S=\/Pf(b^-L&c#*BA$`<#7,':&hA4`@i]'>-_9*Rf2.R+b7G"<B1XR(bV"H$5&R"V=eitnEfS-q$?_P#(VQ\Y4,>]H!JKJ;CqlBQt?R,;8X$434]BUImJ&Jb5maB--IAnhfDAINF$I=&.tZ,1[tA^th)pU%>f=59>I_R:ZBG:_&R4M@7]RI&8q"]?0I,;<LM<Z.<F16mKiNq5B@jDi,+VG<U+Pp+IPM&@r9puM)S9kVQ.,'Yp-02>'[<8-Q4X`F6m)Ria:-mg-R9Jf0eOcPoB66'ruY;Cqk,a`Ad%B_03MM'1+'Olu+n\qRH1X%1k-*s`niLE_m$$)m:#ZI51YK%DC?)2@hmC*3)1`W&+br!mD<G$icA4n,VlY>JF^As6PD.j%O-[mu73;@'V)KAJHH0:o4bf[Phd0</cS$;iJeh*1XoW@+Rn"b-'T5F]F@f2^kW_DR^qA0dLGq4nWjDF'5`j.A2`8*fZ?n!][i[A.nb7oHAO%,)jHZ=Wn]eKc4'MQ6<^fJ[G/:SYBaU+CT&Y3_C8XhHYB/2lDmkR?1?`8FHU&Ni0);'COA]'h-.W`%nSp6dd&G+nAPN9aE.Sf`@n7J9rqK1Y>eE0>.1>Hm8fp!@qmDmnG,\G5u?8&AN)8%.6;/ATH)/]31q'An8&sUOCR)5]"=J[u3Cm1ddP9>]C<[q8$FXQ.$GtMU;Tf;Y7bf<RFAlC5U-@%-lrPn5fPK&G?>$c+?UN/S%b=JrtXOZeg3_Y\k=?8i]B3R`QN[Abj'mHeAkccV]Umg]cc)G\4_q:ZA<q</PfI2_e_GJVK\^<JW:824l>4ECk5trF=UnBfcb=2a@6uNgjrq>`7%:>9-[oGPmldgZ^AQV'u<@DHX>hk>AZbblO@kk9dDraiJT&O,!7Jh5:l4bhV::BF<q\i[tVS+^1S'.L47)D,p'95,>EA`[O)nrfM4muJ[`K*L:-)K()0t#K5SoNlB%T)&A!@/o"NAaQPI4h*$+mp_LJ37>^nHUbqB22P>I2Kj=4c(UVA&m%^GBT*sP'm3CM/tE.cHm/8cSVgsM<i)^CM7'R>8Q2!P9\<_CF$!P<<8db<TERhpY#&Dq*mXiL>PYk+i]p_Bo1)J*GtK8lh-+XSI#o$AD_Y_+C#L(1U9]Q0<U<p^'O`upt8WmRJhZ,oq"Af.n^TB`c\tGXf#BJ`IB[l<a/_`I`pL:JnheYI&)#`T<9-u\dARm%7>0V&lUJ4.1=%D2D9fYcl[/8'4%n'\>Eok+b%:a*i/(A[^NFgp+`ulZoYc4`Sh_hc$L!A?74/j1[4`mStV8\[6P%\0Ib*[WEkl3g/s\.Kt#X<^?_idR::E+"?_i09'^IF[bd;RI>ome]B6fKPH"[BC^FXsrRjnX>N-pO/0p<f++\'T=5f4@V#qA[X.hK=[+pQPd&XKYY,-WLk6EqDiq<XGHSSa=*IfnDR/C,]Xp8&A>12gt4DT)G<+Y];WN;3$^6`80%;U)ABqTAI'uHAS+Uh*B*^0;?&a$'4PI$<A=C>e*Zf/F9MG0<Gcq-7X^Pa!:9XL9aP.\)aM&Rq!L&.,0^G($HpHn]Ye5%ECQ%9(>dN.I^s,/&([HSJC8L_^"]o/M+?Vm/JgNEbbDIm>DQahH;]^pc4kT%EG/;CZ0PTXtb+'@=6Ek1%J=`Z?'a36H\L+//]*-n"cLL%AV/pt*lUME5T`m*<7@d?W":=\*gISq>%:qYjVdfcZgYQp'6Qo=^Pk8]SkY7e%40.O67[JRYF8fgb8+-.i)SUL<B>tC3g0iDi$`R"$UiM&<&Ug+kf@)Tt'5?C\#S??B\IS>2&1&aDB2M?c2AiYqAl\:/9^H=9ik"*===>r-S3<eRf>BK!g2T@#A?DUq*.$_LEk!Ps2T-0>[ifnN%.U*?o!'h6"`;.cUp,m)9hu3Q)/IoKO5f$.P6l,r`i!>!nA<\6/r+WngF,kfhb_$ISU]L8_GcaQGA/D'bJ/7qt"opc'UYo*(>Qk5jO;]:'#RU\1Js7WQe:=@iP\r#j:uldT_Ut*`iR_]o8)0*.LYFoWPj(0Mp]KYoNS#3D+sE$'W&7Y>77B@/+jhPXVhb;9h4upQ".`q+$OW(C\Z\]-[A=?aZ*rUG!pJ5o*&O&=H=X"!r\lb4i/2WO[P="/eAS&W[P=>3U^9HO@et%A#[1pQ#gC/6jLG$!0@8%rFsdhZ#V]Xcqlqr?F[WIe2-NR%W^l<*KF1\MU,@e#RXL+ed]r-g@:BtmWD.i(XXmO(+B8NeYE?I4SP\'qYI-/Zl.-Ua&oc/UgEBF+#P9`2N_8"a^!&jgE4P2N[;0s*<""ua-W[C(.^,fi`qD4-pk@?9AQ43.N?U51Y.m+t/C*?E(.OS"(D,<O;:jWg,ucKjD/s;e52NUljago:X]mnZN\?l^6beagK;Q'so>iR96=mN9SrY%YA;=on3l8`ho]:a(^G@ViG]i.B;8sKBp:+/UAK:(tmpTH6AX5[Q,-X?^Jh@)MR7rC0f5i,7ZIn/[jahN-=Aj_9JKNX<Lhf&%9-f^NEq\1G<c70E.YW"%/8_u#L(PqMGgONIr21>64]I)j._Q\6a*3lh2ruha1^TfCb.qmDFMS6U)^uBElBr7D(hn=P-%Z>INHES$W=?ip]r\Gir=7Gc`)SiWP':J[38TFQ]mi5,g^>91^'@h&>@+]h:+S+jP_27s#M#<2_"1gBB8r;]A6?hP+F!p@rfR[5M@YC"r?*H2&roCN6J^-E?Hod3hIkkI?L#OZ-0qa*s&ZgCMZd\Jkq9nkJ>'AcC$qU,N&8mC>u[)b0g28cJRQ-EH\&Z]Pqi-q;Yjp$.I`p=8ruX3O^P,1-cqq.mVWoU11])CE&02ef5G;"j`XIX?%a"1oqq`/d_f<*bbf/C&+L`0\r2P\SJ__]pQjHpk?$1PZ'EP]^7FRa^F\#2BunmmjK=JZ\K^&mb*CNF<Ul&06@hKqj$Xd,a;;qn--i3%QEQhp4AMq*i`rY+YCTp$"N#YG0J?+h'Biu/Z-uB'#E2DoeJBKlnO:l&W8o:4JT@E7TupBIFQc=kTP<J@1e<^nqqBSuMDcd/8T=GS>`g'Fp>;$Ela*-VA'IR*.8&n47&dOClI9M_R)#*?T))@QjFH5l]P0c.Jnnh5[MVI!!Pf?sT]EkO-/FU%YXDXu%YTVW6/jUElE_k#?;LWP@5rRte>OXe'+dT!_g2kKQ@rau+.o:>A+C%d\)?lj8"#aE?+0V]UfSJ-1p4n9O&Y/JFOl&UhsP,>Asu?V6Tk'L(ElG39WJFC$6IFVG#WPuB8\-&@u]ZC[]O[F`jBN(f@4onXVLLtpt6cZWS^BaXsnd'C%b<A.:[&m@6'Zmnb*A=qCrO"o?C4;%!]\IN<8:AAkUR^dcf3<I>c,eo>hPWj'OY9Q8R8RnlV58Kr4QYn#T6D8Y'_+CZ_l`gR$3pRf8Lk5&!ZMLQf*Le';:RoaMS_9.VToea\[]mPc(g<KC2,f7t'=k\DQ9!!\E"33tsQ`J4pK5_/sr"RftCBu^L\1ep_d5pKi.AH`bN"E[^j?c??1qrLm@k'@p,>7*?eduUSZJ@t9%7HneP0-ph5?k59P!f]R8k5R'DniMN2paa[fL0oL!e"JJmYVJ.h3r]SJm9@nF&RI=T!i5dOhC`S_<$9CJ2m"5s:4I54C:k>sNkC*tLEb3JW:!OGrl!uZcn[a2&BsshY%t@'@,sD^Hk'Vk"b]Wu>O03r;;uq/YTB(8BS9opf8jnU'lfpO<ot^'1Wm\kb(C%.&->!U^r77KQW2DjJe=jA%QbLV;1bhImMn08AKa8hj(hBt:0CK;p#\MRU)7b1]1-Cpqg5[FF0j@9(elu?@?&s*h`1P($9LhA,08d;?U^5dV7W$f1ub+5W4"5<T>d:UV6JHW>_[f*VNMW.fpUf1I>7(=!DB7!;Y"dWDP>IOH"Ac:"s<b;KmG?]]Br4>81&lRQ@,YZC`?1grL34e[?@6eK\:5%hro8d:2eFKJ?/0/'9((lQTXKpOu-J>.+.]k;9DE>VUq1K+!VH8U-h1n_X`J5b(N[s`.b9,,eMg^8!5k'+&!4(6I)&Va0m%="VHP%.um1;<2?O/Dd2]^OSi5TV=e;A@7IBT^80S-]t(An`e>"i*<VJhYsplfL-+tK6>!(c7R_<bP@qliT8V7OC#Z:bS*V;mHim?V?UM:`Z\)C%aE*?aP4a;\7R<DV@1F>&<q]W&6=ih,g/:lUTm+FQ=9DXVEoek?YC&R#k-D^qn%I`p7Ur%\rUF\J2kR`XljpT2amO.t&/O:F-qCds:B4d6dMLI2.Bf6EcZY_3#Fk\W%`f%?O1\bH0.#/bF.%LiS#fpZ<uZnkJBb]t"6^g1Q;rIH+6E'Yo:`;9"3[8J'4cr^I!IJb9I)fEYeGP4iI;BJ+G'+L9^l@J,-+uTPd$">*C?iC,<E^?fo9T.X4*F8JHtu>YU.%fU*hn"[P%`IR(*8XC!]7m.'+MrH>P7)3=HpSOSYt9[:n<bB(kr"]L02$FA/^D^Qt2d35dsGc$4WXn+"6u-IYD1_^YlV!r;-Xc&`m1Bi2Bp3Ub$m50"b-;CTl?TqD84i:r/=#(F^)DUoq[He945lsaT/e)W5qX534lj0Qj+&c`QbZs3G*^U/8!MBbj4c%-!MbQb:_'!j?jj,S/3%;YXu2jgm2mqpG->-mS2>`RYqd_ucEgM;e9KVU7#6gn@H&*WT#*`8aT)"YnJ[X[)k@&":41<\;T]Z$3HAmf)iC2HgRk;`52oQOA!NQk1O4a-0G:itsA&Apq)51GX>J%q$()_E$G:pEIa#qSEG2YMdM?<q%^%L0"n1H0UeJ(n5+L^&D@E:2DjmX/.29/[:hboP"c2]2]N.>GG%IY0c=C+SGLN3(*W$gn0.nc4WheJlF^MlfO1Ma$,5YUX`=_4.pTl'3HoTEhRk,l'5,CdA;E["o=k1/L$]`W1(*Aoe/K/liKleYZ:8@mQ[Bn?M-pm:^B;Z&Z\uf6G8BJk"EOna>((&r$8@]PLF*2E0uMW4KO!mrPAC>)F-4GL,*bq%Q^JnhFQY83n1&L5T;E1[LjuI,B;=Lho'o)'#G=j\p$Yp8'Os&%=fokQLo^OGGCDQ9]bi1ol"8%dR@&c,g3$:oh6kji>V/3F]=Y6?l'VFQ=fW9rR)7MD&5fR!,:mFeLC&j)\,$.ucGqUXWflAc$P7/3:KkD3;b+j0D$tX0KdLY7Ib"o1eS'H6W_91X'a8\.C"H0qIJUNeW$!0/hf;9:0O)dD7'G4Ms/HHh`2STC4H\UMIdA\Gq";T33RH1uPqNlJcq7ZM\G-ET8R[#+\QFMh0FqTQ`>$@fpD=\*RE(kZH2N+Lg8/862]08LT!>&hoQ*^Ku5SW'j.IVZP4?C]O4f4MMEf__@tX^Y1DC*D*Y<WW-XFelW?hR5%C346d\FlQ\LR^5&=0mjZ`TkoliFMr^3salrjF'/'e17\B;CqNImIpi2N%&!,P<4DhKHjiW<P.W2e-]rd"o4FlQ=&+.j5L+]8TB*+Yna+Q9@CH2/=/goemb\EU`E'lNEaRp(j=C@?sW[L'-MT^GG"MN/m_T37@Sq.Zc11?EnBCF(kA^C/'.4GuU6tQh]YG-\WOBRh1EX)N.WnrrTik8CHr_A_U:/<8ZSj<YIHBaWG:5#3MggberAuEY&5,VmM=;JlCX$RuDTpZ"s=[0nHeGq<cQC[=<.;2^JDNt[r-9oeV-4.OGjI@WSer_.\_DaKAD5,^hen]KsO+X(?KnU[V0;gAS_M>A(1;g:s;lZhpEH#3Z!e2.1m9"gJ(F$3T\qOmL5!:$7N6)TO/3)gc&#&Z-hZd4fc2b"$`cXKW+\MqG8.<Y<Mc0Akeod@<A?Xf.Zc&++rbl:2k!f98pVUjYREH<BH([h5O`OMnL;N4>E';"s&U6LQWHOGn-5,>>r\%.@.6'3JHs-ZarAf?6oUaY(9h>K`n4X^l@mE8_GIiHTYP-BYjUZE<#n`a;:]WT;l;[.OZLLlKP=\_.hE:&bP<C1sp]N@*o4DeTIoE)cobNFpNKl2kX*atCf(gSgf(H2)#k=[@8k,gb+ab&XVb/Ip])I?HO3G_2eZ_1m;?jWaircS4YNA7ifCtXn^QG3+ki]W)$]Wcm+QTk2gU4ksPj3\1fMjb4+Y+`H-shH=REa,qXC_lZ&U8h5P@MY=dTejZ3f]74)36^02R^*G%a,/>pT5QMll1gOKhc7l<`?EB^1cF\NYnZ)m0@,So@^*mAh*EQD*-_'@GjUj.1:8.e,?,4jQmgMT%Y47f@ZgMG'/n3!qSaQ8/)3;.n;+>U*6F>D=o-/p46j4=2&f\hRu8Hah@6Y&VdNq\>"ZYd6qU*b.QR(ch(,/dW-Tb7qJKJ2ZIXHq,mV:%N5qT9/YF.Yhikl?Us=,O;K`sPZ@P$=F%uiHrZEN1KI_$jQ1I4&JPjU&(k(]'QO5u-`Ht0bV/OXX2b#U+2)=&bk]D$)a_.a@!?G+6pBG(LD6#2$^DCoH=446YNOV?:>FXcM<E\P,F\ssoXlbm$skUD8\UWl?)js8Zj(3I[8b28_f?WjLf#Jd\B`VY0BDMB7X\6$);<8`-K)i_,^[e\iJ)@Kh8"<uc@"4nAhQ1o(BItXiKFtQ)Z"k=&ZsY7:eb1Nh-:\88[$!%4hd"kg/QH>SCPWGf?f:N&?tM+lc7Y==fg$kMHGcbr<(XJhSf=Q0?jl<%?p+g\3ud2+'\>UVu.A2\^"aB^WC'VXJn>9W8B<5'%h<?7H@KQCDm0fU'a%^rP]Ig)sG2^St1dj:'kEul3(2=FHa+]h!Sp0."2UH[FlqGiB$Zc;nei-EmlFYkSUKejQ\eRBo%71484+6KI++KFn1SPmA>kMfn8'cKni*gpbOH8\s.>^(trcp%0L8;oMBLd7'CLMi5<]P\35^P`"hKQ:N.[!)d!%1<l0ld'J?k+9Ci,'XA`M-SiqJPiX-@GK@><D<R9!QoRLoQ\!X^?s&u5pVU?rfp/0;YY4bj<Nihq>CPeC1V4##7*^LGeWk0lJ>u9/U-JZi>LT.F'Ja"ij3dr8jc]EZ.-cuuCFM'#;F&Zg?aoI*mR0/6nlZJ7O/oiC#7eRI`O"(DWB!LuTphl!#08jn>n2AGRM[OBqR2=?6N*hnIb#g"(`C;Qj^W-6KPGNH9rG?+3l`$W-'^,+"NS)7^W?f="788kOckl5P8L<VN@Rg/jFtCL`+_F7ZTLK&'JZoj=]]bOIgFW.Z$s#MI&]O]4NA*q-85KRY;>o@u`%)V>F_OKbUZ0Q>f\dBTg,6aEj-7f$$::rUiTQ.\^H&l<mebN:0N8jBrbk>_a''stnk*q)FaYWfZ'R03PG>V?:d(5ZDPrFe*p#5l^f>ISog-pf;5_\Tp4cp024?TDZHecHnCZtY]m8P'0Ubr:P]R@heKPA>SCMp*ajTDO@;s:3cBGi_SF8(*j"R_""/rg6M2$eBK9K,jGQd@D#.Xmm9gWRJkTjgN:Nsl8f-7o-]LLi`\O9,!=e[Ad,fttPJj\jXXO#^BaXe$7h!3PPA$*>SpV4136sD-F<ucb#rtlH.(e,s.3U/H.I^9]O*>Tup?2B:F(ZPLcF)T.TXH*%0VcA!)*r;qN2"1$KE?(Q8dnGqk1[7L>gC/NqbS()Z8Ik7,aHc`Z"Gike<@Bbs\dBsb7H=Z]WXJ[nmh$*T#r7?J<i-+-k6`^sGH=5@'K$1oClWUuZtMEBO#^f.MR`[0fS(:pne`/Z"Gb"<-WCs7Bd=idG6,5p1k?]S:!\*[,qPQjSGG[Vad1>n`F=iL:uWQAp?PRf8@qN'GSoQ<PN!U$<2_9f$C>MCY!oX2^#l"7/0!KHTF(:'7#5tVN%5)pEin?GY.pVFSJ>Z6TbiMQ7%Q-rME^*Vi]/lb[RjXNYm6Q"pKoM/iPrF<3I)_fNO#!O7Ct*a[Jbbb09M@>9T7Yj!DnIe_YuQ9bhl@q,/TMF!+<ZU[/C9p'JN$Uf:f[3hJ<7n/^C@oNcfJ6Jog+/.QkorJ^K@DI]'pXVliV&W.5+,a\oUcK>I&[mUg5GN@#0,-:,=aaE]<OJ1k#V#)ZJ8pJ?e$Q=lT",$ME,Q"bZ*P.T1TG9F2bP_A6T6sNV[0%q#P#^6#ZZf%V#$YbV<+[b%Dj`V##58k&tcm;eh#s]^Rqc<1<j;^)1gNoER(,!L_hh0O.o3+/IodAge+Ig+p.`9NeJ:@O/,TNE.s3g0_PT/Q67eda_Mn>.X3ZleXOH`]ur[0q'@_&(a!.@%T"n6M*LW;BTJm_2S+Vi;?RUfEmDr:d*>VO=b+E`.=^WF[2m2+)M<qJRmB*1.Y8^W_(KruI?i\FGa&EUP?!MA&]3%pNN/YsTWnABH</1aPQ+JeGkURZ%Tl*(\agk$/,[DPo$f_KMKnN.1_o()2Z=-jhjeRRgHR]mgCYTmFt[%Olf&biRtg+B;j-96`Aq/)rb%CdV7fqZ_kh*Qu0E:q$-kNXs*MbZ^nNFZIh>c9C5o1=YPn?4Yu"O+3)3kKgZO'=UKQ3"ruji!XqrHC-KXM_.I)OPD!AV!#leqp1OJj[q<Wb1kQ25&E+!+&'4Umd:%M7t?X%e\A3P_u%=!h_:WF4j!AJB;ATU"7>raofUAN*A&Is+ZHe+?LVY_r&s/ba?,eXDM66U/.3m=kPW-Cs5<L3O6]8pBB;P$%aRW*FpTMUAU,*bZ17mE:g4\_q?Y2(0)6U$m&K$^]6\rI8$+!LWq!BCW/L"0#+th^D6E2@abRR*&;/Tmbb8B'jUI;!s!?5r0/A>c,h>aQGF%WaTE*@Z_Dp%1eiuu%.IMYa<J;:j+hbQChEd?$+&)3eV$We^rhtZ<+8Wj>o:C\ClZQ_b3_]Qn#)D0WK0uaUU-)MM^e-16]ljX`D%(D!^:G3'um\R1f&k.O47^C]<.boXabT%)[r4#>P)6j8FY=?INRR>*$<UI>#7Vi4jDNl;MP3hRb92[c#H8Ih(OWX:$FmcX=lcteJoT!\)p&B/1PZMfC2pa6B@[BpjH8gbR]HsXXs)&)nBM8Id=BE35-=+HrG)5RnDICs/jG1m+D1?^><?'F/[F]q:b8P3TSqYa,;ORN&&)"\h08KO'eU1(6dWDqe],B822ap/52Dk_@>-M^J^oq5K&fFC3:QK5G(^]g=?GJ1H^!)2ZiP\H.hZcNFlAjL;2[-LDNE59SZUc]a1/?F8=,;jOaAh&oT`G0>d2p;c;a"p=>aoATP1A&YJLU$.NJ9<h"BJJ2CEPD?`=Q;"n^m+i1L+^KGsq[Gd-jST51^/NY>E97DU!Hg2WllL8FM[0EuRpFpDSbK>hW-K?Y%5>OsfZ91K8NTX^5C[ktL35%i)V[.7Or<>InIK.[mD2#^d6%*#uSe)?PoGHj^3&\qn1nQl!P8@74dmVnJ5Ub/V5D&U;^em%^'ZX(m8?:M]aJeQ:d!PsI[VtW'Z$u8Hp%*!ZJjCH5j;HIlQ_(ZdG5RNhAW?X.6KOru*eU7M#-T6)NUX!\OqZ*8EdYGJ_pA2fq1OO5LCVRpc^^TS$i`aQn3s/m><*8K$cu]q'd,35@1sdsRM6/PcXP<Xf%h_"ku0)6I+IeL$]`'HOL$OQ,U>#cUL'IB,caCA*Ghl%%`iB:(O*$iD/NNpEXq$E?a?YL9h7*3f4Zr[%5M]p!ppJ\Jp,I\M9kSto;2@^h1,msn.H?&5?/\a!L/Z"$A4PU8^a&FfX'OJB:\Sl4koEprW%ZOF1-V*0P/,7U?;rA<l^Hm@*/+un4Z&_g&'=:QuS"CCeJh,g5dsKJk)GWs(WK=oa'ggaO*&S&Ki*ZQ@X%KG3omg4=O6E^]Y:U.>Up*ZoBcG7PKqL+=MuIaB"5Qe1'LK!<F3chLlKPf>-A##UBi6)?NE,__2-u-VmplE0MA?Q+)f7>%)9fAhWB%hN9hk<J5L[(oF7V4g/^EI)^SNiP1KH4R,Uh7A_8Ajlf?$OtG\F'TTVHA_VO>,M/WLrjeQhF$uC_a&26E$%$+7iAe5SnQW]?@a3B2;\<`Cm3an-GG?s-JfINNZUmZh^C0]*:[dM:OWc.b8]=bLl>ckQ9u0_UNH+--5SkM*gDj<,S(0keNe!OtEX%s+_9G&U'hUkZCnnbc?++aB/4N-7]0L5!)hR-j!2A"Il"#7/4LWcE1>^g#2@9Ptb^B3lIp<ee4IZE`"@)._1L416fo_Vk[aD]Vi<>(jdLnUoTWn7$f,*1E;eqLo(V9sj(NfXQ0%F2>TI>=4>t6h=1.;DL3@`94!m!C`HXq>ZnL'r,.$aKO7P#&Hjk8b5^^D74d[2YLMQ&IbCYM7B?"-#=Ue^leT3qZNdiGG:]<cL9J:Tog9)WCq'?94+?-*#3DU(UEp4,2CT6h]+[>MAd.VI4.A%,+!W>]VFCBnhK8EU$@EDJm'($q'Hb9Z8K<5^&Q64mDoh5\cj]-*I>fXA[5D6r#sN@#=<l/AKFK%?k_7D:k1\J'QkNdr4N3lYs+jZW]bjWP;=fE0-dn>-Qj`Ro^M`Rr#F[bXW5eZ)7>D.S'gGCZZ?II&j;&UcWLB5G7q+oH[gB]>U!5*>iU1b^AKTSgH_96FoE,p"JLA(W8o`n_W@Gk?\YnS#+iV.mWto@POT>X5cG%?;+Y4k$e$DaHgn(*q;JfPX`YrXVT`fI"cKESD'21_+n)_Dj6gLDLBpZnf4n8=rKY?sOd_*V>#^hXV+$.`$Qh`W/:4YBSqGhql!t]P8)<(Z-/HYitH9Utbk]k8->>C4uQ4>n,[X5;MH\NEqHA)u[0+NE4YaE-l0=R%4Ab3hb59kG[25,Fra_^OQ^WXMkh(b366`E.l?bT.mK`_@UTP-0SL;NjPT/lu_&pp2[JUk@]=?1N[2`">aTUOkaAo!UWsHn]CP>"ffm*G/'-C9Somo=2HN'?`X"Z>*TU[5G3n[0[Ru'&b4uh>`U$o])>/<f+YF2r;HK;Cr4?9<Je=05qJ%[Z5P&ngbOnJQ,P;+D(R0aX%6joNR->d5Dgqi*"36"fC^D35uMIo;AYr=)F;k(@KPZH7X59RHdXiHhha?jUXc:gFd?ps^5OShCZk2\+0$+37(pu'_F.7B('u&V&b?5)gS.^_dBc/T";umhJP,B!6[+f>F\P]:fZ;6,qlhcbh..DN4O[NCV)H4?<+sXr*7'BF4i08:<\s#!0!`'nppFlR*]G2EFL,FrF^@n6ZT.#Xbm_5Q%^%W[;S$XLKujSK:B'$Q7([&F_o&*Y`e*#p;D(+]Edj*&eSQW1s&u&Np:,3tHF1r,Tg.;iT[113*h8]JA%B#;E@U9/5I2)cBST>-idtTfZ@!UpE`UK)A`'H&\usW^Gq8ahjFH.FW,o*UWgZEN34Alpc+BCZ>Bsn38q_,#`e3S;!:E$8d.gfn$!o8M@r#lA62a5P@FmWL,JTk8F!Y<C@X%8^5_!'=gb]>U,\]u:>ht:8"_e+[0C1(Z^HXZlHgQ6iO*KQnf\W$=L8uK<RnmG@RZhJ,hu2iqH^Dl]''_Xgb.M-N4%IO9c!-mmYQDU;In(*uj.Ml9oEI1.>"nP?^M\5niPn4GfOtZS8lQT)b*TZNgW4QKiQ<L2'a.gtZ1<P9]`anV`T``*o&"cTX?L&V';#\V0K#j,kXMWR5eZ!q<u6#A]7#R68.3-'6/?HeBoTbi0D8!%Y]dmp-`0"L)=7G4n*2'TniC#%M`ZJ7j@*Y?X?G5P']?i8B>mMUUB7niUFpETcbtg0F"D&o)n+"\3n_Ua1CooFmI9Jd1KUgI.9=,(lIT@V?G%\+7_.fl-nKktE!O,fS>uDjE@^GAJtT6pe7NGIZo+.R=E=GF4]2lk=F,epAUsB3W>AfKd]b$W8c4ZIXts3&oVhFL7@jC8)P0lj9P;aCQ_&4CUlb"BiH`dVi%dp?@uCsWp8M+q$$c!t4cKQSC*HS7b@t!1\g?<V%$OYb+&4]gS;?BIcgT$A:fE`$iDn9GUL:1#6%4k'K`,TT?N%pGVpT'Q4=K#:SV;ZTA-F+W0fGTUP8Q3r;Wq`0cXOb6-GngI-i9$R)>*eo6oVj9])Kmb/9`<>:h>-"E4.a&6!3la;XjCj!*2=h]X%PLSt#%B]X?QP1(0clbXcLSdJumu3!"eKWDu&/1/84SZ'C=,@o5q6*d'dq1p]O%io1r`T+W-mP($Loo$p1_>)@:WR++1Ohk`(3Q;KnM<Wb'hDs:XqlY']8(O/?M_<W<Yd9Gg7&BZ/@,MDV\\@f`UBS"sY(=uhpA@e%fiWJ9tg?WA@VMbI0$r0_uA(t0t'o4\>Yum\LPSpVS,4XitneVJV!IDLj+Ihis`7TZn*693ReB>-@An2sU,HBNeP81;0\>tSC]s_LrS9l@rj+q4(b:>#]=^<E@]'eMW\6O;;R^JE>9*(Q\T59sIV"W;_Q)6:QI">o[eJu2EeMNdW1!AMMclVA^9(+5kaF+@\QEa.5^g1surdU(<CETHHY+gM[B?+/4D+#kU734u!gIXo6r?u\\.o9#/E\e'5Aia`3FmlEWnSA7,0kX=%L?;mX.S`Z-./ee3"U*7<0$+&#!'&>-QA<0pWNgN3&jRU.oE5_fV!tb8;Rgb&8e@B7[q!L3J'Y)RhuW/HO[=Q$Q<Y?[^OrcW65(%qXg(tB6Q`OZl-%gJNK[Yh3J3jSg]8P`fR+)heK8"j>9#,0L70bg@82Ag\\o<X3a!&#4N%?%3Sjbo!k^'I1A5D/(5N/uW_f3Am'fs`$J4Aao="Wphrh>.UN<aW[Zc7HO-.6VTV9%IZfXL@7A$'S4;iEDMOC"mbTi2A6jJEgi1J[A]]ReG][7K+-Q<*\iiD`;k]030m1=h<pb.P6^c\a*-#_l0K,=>#V7F=lo5,c71\_]*MtnK+bmm`#FoEsHhp+&BXS.m1**J7PO<L5BnHF;$$=urn_Bn]i_VV1n_psIhJ)iT!+.+nmGVTIg[$6a1M1N(DMl?--'sD9,G.\l^3:K"IX9m./Ao80nEcgup?L]6'Z1Z2`>7T"M<2O1A`f^;1Xl@"rT@hSp"A@cb5%-CtCU,c1@F5+'DQ!t;2n\CrPu&ZnA[guT;/*Bf$)i+<#1f@6C?tNMc&E<YS2T^:o.V+[9;t=0Wsh#*%rf1%T>gj+CK<@j&gLpDG>b(4JiT55"-Rg3/k?LUH.kO)i;)]>DkWec>o*).j;n04BiV,92Lgh1$s-&.cKqI[4ff8NVL.pR?Ib"/@\&a%i$6BBL(ZU_(rt6uT];KE5S&5kT<&SYFt'lQ%%L\H0".;)JE'!*'1DEt-2PQZ0//M8oX4)brYguYq#2JB$GCZ_BnNdtSjKa>U$Iq>Dm-5s)=S4Jc,7=fSX3Dg`(([ha"LAD-1V(u*eHs_lm.;Y\Y^3?c4l.'f0qb1/gk!RK+m@5;j]=_42&quPKn/*iZ8jT)=mM#0C]0?)%0@i>DWBWQ0n48(LBkPk-.e,HK>,?,41M*6[C18:.[tOl?,JSRBfdq7k)ubqA")T&eYD*a(/NT4t;3H56tt,701B&M")157I[N5?80(F<)lo5=YjJVa:s\u[/`4@?);FTW8!?]4K0&dL9:)T]U#]e>oX@7iL5AVD@"?'3<.H]pa`ho6d5JToBNhV5pnTn]=NL(53ZEU#9HoS9'6\fm>u#K.%jjjj5]/!L2@etQGG\Nq0jV6eu2+paO>I(NnD-@"32#j;s_".9mq>Nk\26Pg"9jX!r]f/E@Rclj"C&t1OiAi5s3M5ZLc7(Mkql8cjVr^pDcDUd"_m>^%'YjSSSeM"F@!:?aVop`18*s_ORK:Vmk*O\QSUC=&@]s6FI6C;mr'8@%kN4k-Cc?TGS2tpc1>$gFj%CQFrJf#\N$"fd0I-/bgX-83mjIYG6_37Wk5C$(*Ct^8Bgu"ncIR9Cpj0p-H9TRAjq-Qk's6AXh2*;ds9R.SXUmGp6)/>I\d61*s6RXo>!K>'"<:`)pi1K_qBAjlKDMdfh];[S4Hdgpm<7LuL//SDo:Xo%ma^qhXZSak6rdm^+s+o@/A_0O"L#=Z0cFa.R+r`2Zam?hOc>H<Dct`STLBI?<^$dTV"tcnd^fB7Iq>/0,_n%ZStV;E_clKH>WT-=tJp[Enm+WBU+HRMN06M3Oa.Nc9Pt7>fAWU%r,n9T20.(0QOJ@?>cl&Yj#S^gq;:"G"``]0mEP0G%4ol"uQ;U$rp+Q%FNseAMnBp&D^/30jt^Nf;V@X'35iLZMSh`)0JYd*e->9phOFalje@;F]\61V-p'C4lEeVo0lt*pVCVL;.WN8p@Qm?30>*<"?/Cj,Z#,7>#*-P9?htOr9OJR<._ir2"[)o!sZo<AR8]Lu`U3j*6q1q)u6db92ZsJj;*Y/pRu+d%R9$iDN.Nk5Ee?hKkqR'Tp\A0AZPlEiPNq4=dJQd'b<_o'53<r&AR1`CfcHg@.5kN7$<;'IZuDh:YD`l,&>2Zg"L&@?090D\tE-c*,eQIA\I8aPs\/-JcmG1oX+mSBU](0Z^2S(%!ao)dlLdE?$JV;FAj+f23+".pM[4rc<_">8u,4?[f_)amXPR<6&Cs?[Xmr@nDRbnHX77&?:cP(#$iD^)jp0U5^E?oVp4ZrDg6[b@oAU95Ek=c?Yu.2,p/5M__.u^N\9K=]<ID^0.R-BWF,u/'a\$d(,-70f3S(9g*M>&24SRTK*"+S5>Zi-9DepGrEfuWeh`S.`Kjb`OAB>bpaogIs!H0gPssQM"6mIZQ=3,jt[Z9<l6$6CWK,9VW#&84ZP;/?*iK-csfC>K;V:M8.'qb'Z9GV<NT9$F/XApQRfPHdis0$"KBXI>.H-#SM@^V-HC,8"p*RW&iuA`)$H.?)c5J0/[8H4ZBe+dh`6R3mYg"?nrMbY%`=l5P=8%JA>EA6S&Ph6Bo$5FoqXohJI-:(PY3mjY>?<rJmZ]q(G7c*TNH$\a<W$_NCLkSJ>('r!ZD6K'M-5O'+s^eA$CK4J=PX(3u4P$`CaE2<0T;Hn.o<eJj>'JaaK3=$VpsJg=ORibIO)6lD]cUFhaP4O2tCF4j/1WK7AeIp.p=C^;/mhMK7NBj\j8J_0`_!;+%cg[,8\n4iIo\fjBls;ts;Ok#0o''u1d(EaX1%Q*L&<[IO[c0/iHGH=ac1#;*,2W\VQW<6%Wb9l-1h7#;r7gQb[C0^br8[.2%MQ"9!W\+if=<4,JKQadCY5X6>dAbGI^*UJ6ikcpF>6iFI:MI]P\mS^r$So!7^_mT>=GW_DH+##/t`kf<'?>?>fVWls`EkH%L[KA"AJ-mnFm8,F_MOMes)(3UAe%f48'b)/sX15(=83Lg87LC5pP;ZVACWFX=Pd#iLV`gU8lmi6RB8$CO2^,k!.9)!n7k<NL)mc.t+dL`kBAXDqN6aApm<-1CES[t752C.Z&=kDaNmrhHIhYB\)jlAhR]C3+Zsm$X5iK4@3&3Gn$qfV8i!08iGQJ6QN:o"5&W&h456a`-[*r>6aV7fp.IUr"OHsV2(Y>PoB(*'!1Y_cAVP@Ot_Vs'\#sna!i#YF\ZcK)eGHn<LWlSPUPRWe&'`jMRrs5c1m;TYVG:M]o,s>hLRf,DnMk-c);W)6iXV-RG(EK1Uj/9aVk_A"IECVd3M+MBYjmE7[n&9jPh9TAN[PVPWGq5,aZBqT?TO!0BMnf]h]%[5&D+CM<9br\S_%oqVXQ_D9e<W&>T"<TZN#!>F=Wq4Z,pU"-X)<,dNd3\dFB#7W0UA*9pJ1'uN*7G8YT5Ed"\PG^7@@Wiq]0cNlIh&:+8YFu;6hsJ[F2%rR50JK\co?<mmPkQE6)4Ym^9s*kaF#*&L!gKj6V!+`7gptlta5Z;;""6Ao[QUeW<(=?(A2>&bD\65rpK++sips^_)?4mppm.2W4L@A00/&IT3jp*&sVn6QJ(q>?gKEIJt:M'j@OBc2,?(O^inQ+iX2Q)QUGm9P-#m3k4"^-+dokTfqK\lK2CD^123(MgFDRXgS)LDZ$L&`k0b4@7n^Zatj:r@QB=GIHmp?@'9@f;T2Lu2l8E?NSCnT%Ms=Majk;+'JI0!*g&f-9VLan=]9M[8H!HrKu#PJ4lt.l%_3UQNsNjUR3gM,>4"3:2+2I\r(DHr9d?-PI(@93$c'o!b_:BiW'MPqfIHuY`1gcU6YT:,5Y>c$JfIMi)`8E@4^(a&$j601;hS'?na*S>-\/aT^m%/!k\(Y$Kg>Nd/#?$8YTcaQ:XDagKE;JS[Q+\['Qf]DS*7(U#J<8%5!_OL;a1tsN^c`)#VBJa&D1X*NFJ'3;21PZ\a$,UeX=rtZV!+@=W2VZf!\Mo`E=*5%C/KNNI;2t4&L4b;"fr8.8H.6>1nV:V_7B(.rP4]GHg+a@6M453p0GbWoWQ!Q&T/E<8s_(0L+:)fIgDONNf$IEU';,kcPX;Pbu=\/b0%QVW7A1dZVVdQBrt9%n'T:Pa/;&lf+=AVYo]:Ss,h'SU*F([G9k)kC;d2A5P+0>1['FWd:54H&Biah7LE/;AIEOf$tX<fJ;bc23u8P(8FF4:SH(u_a#ekiM=X7![3k*#asWqI,%:+a\@L^KcNi/^*f=pk0;s)k>B[rIuOF;Z+>3bY=@SiT(*k"[b8_RWR(0<j\Z=_e?<5/GC$X_DH8-Q<7L^qFhU&qHc0m4EfmIF>RB>i'Pc0%U(^t#l]"h=4.R:dG);,Y>E.r(mKk/"3r&/BI<i\%),,uRngLq,<B$Ve(dRLbPI7I>nA/DF4O2$jqX=r#fA0R5)S+Ic='[OV2`>q+q=7fgjMu"?4&Vd95?1,u48,DK7Lo]9`i9/9%CZhh>CAJEfTXNj$CX@QrZ"<M8g&qB/;Yb,,]YR(S<`.,NfpafK./<c6FUF(Y6A)*WmY4Q;^c(O\=mqKVUGT@[4_,\F'0cE1)2\UU6:4E7(?mRYD6"JrM5;YeZjViEJ=+i[ET?t$"[3ZK*KCOf'Eul0o!=EH\*Mr,2jbdE2ol73pg"(M<n:'dF@2UeS,P7mZh>,;"ndI\Af8N\?8&g8e7u)Z'APDo-H/V5=I1HBQgL0P%ih!"AX2s60cr6T,Jt-RcTDRDE7>2TBN'nBgICn8p'h(3T0aK#53Spo2a$r2$s!8>`HUlZ)rNO(PqBo9%'@(]7#CsXZ%d]8cK`5L>36.Z8,p1djElLc\MGP[u(g[AG@;eGR,GDQF;%jd8b,hKtCLk3F^Etr8]g*1e:O_<[M*A'Aq@8rgQ=06G(`JN3.3?!<QO)Mc3G&Q;B*>bhJ"9>:+nZ5qkW3^a'9rWjfeoF>]#6<?2oFn=YsRRKt^;Y)sPm"20qc`6,ld=M@43>cJL^f37O[&)as.IY2>]n<n@3p!QCT5nA;fm>&b)-X;*Go]4bAh^90k]bT\ib42Jem);YSi*S*a7Sqp4B%gd[[=Ce_Z'I9uR*0@/Us`@iX3c^&DR+SR%&tPFMHlC9`AnJ?]mJ'Z]pKObn_i+D[sG&d=/'+`QQ1YNc+?j.CKPTW45LYKnW<8S%AMmk6MA27q39S\K"u,hq@hqSLSXtg(DReLKZ%a]?P(M?YLoSG>cM?oq_qlPS3e,\?/;5AMe;=?-k^_6Drd<+4,p!m?+"lSN>,(<F]UFW-8;ooZE()TbL]TIe*lTuhQjY/bG8$TpP;0/T%"4#B!#>g*C!.8gB3:?_K/\ILV"uDab<&g/tT&h7\tas0='6\XM8#_l7T5KQ?>2/Elc;kfOm0<[8t<$/&=u\/=$$(c+WkH\20r]i@@R@9ankLa`ho"W1$8l&j#<X'P1\-=&i4nGUI;1Rs)[pQX[&QfD+01VDW\"En*%goqphs1g"Fk/d+LOWj\h`bB)cai)k%--r$E4MmRt"]PEBup"mEsbjOl`23CD)0VD1t5=W=Hl`noQ"%SQtgKNMIosiqe&nQ(Zp<I:J9PZ0>9dj3(#;^PHeK;;qqN21#pH+AMTLqRuK\9:P#m;Uuid$J$n-^Fj_R[M1aTC/8+VZ5cd(@WLO6b(]U-b.pnl;S@DY'btnbi0[7+#^]%^Hc7SSbDD<cq4u\Z8;]>J)hgEI:\2U#-+(h!#&SY,\qMDVHF8X5]-ZrepHG>Oa.lL1oC@ku)]o?1gpGS0YolBaVjT5D$M4V*43$T?$56med%-%!rjm:JuZ+eI^&B;c)E,C-2:I9r^kGQ.mV")?h*#1AC-!(TQ$<f<D0VpV+mVWQ!o)gMD&\0Rg.TN78t#8SLu1eZQs>YJ`[-<4,B6cU4>P@qnGheNeA.q/kt#NoO9b4!g<DA1D-_@iL]rs1'Y,S:rt(56ZAb(<="/E\!N[I)T'<VI6R#]/+&I<:&elWGgrZ?(GOR.ZI(Br%>#Z]%b-`GQ["i9/f]_qc[)$?'eJqs0]/LY1e`Vr)UFYI_hOCO4&Vb*XnH&)NA#9&_SO"$)!g;A]gK=HK5^/oWdj0641/R($t9@'=#H'&#[:TYdZe,Wah=l;d)7eIoM<!Mp#&j5*<$M9ic#,Big!WX%/TD3TXD9[dQt@pHE]jM%Z]5"6"Ic*Gm[VV.:l%V`pX<'afjj/jnfUTc\c]'7'Ne7C,o"e]8%[Jd08PaU[nm<=T74[Xik)5kR*U&/'j&]*$I4FfSSK("]g(0_PC%T^m>iCc%;!(7QQYK34ODSdM07;^=]5&-2g)q2c0@%IjS[cg3MCXTjm`!\b1?>q4.NVbmYLm!;YBT[5\/YS_L9T&GFd0,6>UYsMi=fTNX7-&B_'*-p-38#_(R%bia]^I%4HWCf[%'#Td(G#1dCN-!,<Ii<SAB5$<ErY/-8p/91&$b(8FWmWNS/9%;aWbnd_XDQtK*m]M&=\kc]%1r-]qfW.P=BYAC=rJu^rCc:-2/m4`g=$>19h(\V9)@nrZW?R`2.GJ]oS&ae#n4.oP(QAuE^[ku$T@NZMt\2]9KLDQifSU$K#qNlU%AI9n9Dlp53(=+VjpB3E0TdeV^PCGYdnbZOUM+lj,9^u?S;Q+O,S2cMAWB&6)i6#Z\frH3X"ZAI24Y8OB#c]9Oh/AXeL*R&1uOVMnV2(R<#%b;[[iNYeJ=9^>,lh^Wg)La_(Z6b%+Ue7q=s/L5UurOjG'pEh(@_*1!*_iZa[H?T/l,mrAP#(3ADkq86hg87?7>6ZK*HXf8,.B\9OMFb<ZO+uee]$dFZ)/EY\FOTMc>*0HrC3V$te9MB'geCAa,o,$TuD!IjkH0*d0*0qhRT/m%VCsncX<N#/L)bcaCePk33fo+l?Eurk]ePp87Vj\tKrKAP$U@JV@PB`4i/!RA,%YCK#TY(rHBX-9"-m<=*ZIZ,'ZM);s9nG^[a,>Rb`:u)j3Lk2A>(G!HMN)7/rY@n^[AXUf9S='g<uRWXeep"r-P"oo8n)3an_EoK7B+Ns'V,beQ,:_g>;_.d3D1&SD3,UhJgLd!$aC\**CE2[BUKEL/_G>4^_o0u"E5A))Droar[O\gWYdsWoF^/<&`AM3&)e_PrD6'6B!lS\iGA0E)%k,+-QVJ*#HgfQg,2Vt`FhRFSkhu\&m:M<91E`h)L+HC=f2i-NJdp4$6Tuq<jc[aC)CFL94GeKNLKtN!OHB0ULQmne8d["g8?PV>b*7(m[BTEh2+^h&2ngo*9h:h8P(HZ[(ml1g9qCcVSEePihHMUiR2cM;*"5)FO`CNCl!hq=jJ,sXat<OT#@O:Ah(\mX"r:c3[@XpPqtPWC.D$3G4&`(m&(/db0?Y;Q;#kb_`+1$STpde'H.TbSni.LFS,&.;Xnh(<Yd2@:Jb:=6\:r;QU@*M[iiMI4"@bh1-8TbA7##!AeDUChAAFWcP)]LRhctSN84u/W0Q%nbYuM:rh&:pm`0TqXpWX2ht:.JWGDuc42Rf#0:\qq@ROs9,_"ZFq;CmFIr:(Qk?BJbS,7B8'S]i7.Q6`i^[fMC*"$jLb7Q(Y")H?eh$EW"D'hP/U</j$*k'V\H`:2JW_VBuMkCId;g9NI6ZbhA)3A7"I&fuP:d\(S%R-O:4bG`YHTk]^%3&u@P[>(?FuO5n,b3I(9*,5\Bq9iJ/>taCD9HbKfm-Lc\ce!LWT^<MM.)e_BW/Wr*gO*K!mecf)MQ4Rb>]l7A/:9U1Cb@+]pB=7Uuo>7I\Npn-"tfXRF&C:(S&J-<[ZCD1,B2q0To7UVW4h$]tij8/N\+5VC!T8NnHH+PaI]'mYNK6,;h-%UKa$Og(kVr*Kf.T)YTi/!dbh51rRTFj2*hsN0ttd;%ae#R[uQ9G#V7Z(q4"U08;Zta)u4SSYC+fXV-k57Nkh:@U^%B#2a8G`#BSK)15d((q*ri`FB+=eqrO"0aSA"-9ED=^4cZln\B+NSn]'*6A^s#g&TduZgG29LEWo+_]oqO<_89S1pqm%Oc)\D2K7,Wf4ZE]2DXgN02>>]/de!oH0U;p+>/75mj0/r/T$V`eMC#lE\!,6?Yo_\XJo04H)HS3TE>Xc5U0?g7867r*Z0UVqf1drBXIDpW%_I;8qo/mHP%L,b.0)[?<7#()PKj"g=aYR6M=-ngLQ1iFVlDMOg0^=Tu$-$7W^@H:OQoiB!$rM+rat>ffZ4eXV?MMB*8=HQ7?^s3$bgGenl<`ju$bp-'6(WF]+C=8k1n%2O6^(!Fp52bn^YO.Ym&7*N&uO-Q/pZ(ksVES8RrKk+iZ@Hj4FXa:ig_8^*Tn'99@dh42G9b\"Q"\1I0$AEkS"4D:?Dm2S`kd-:+06\>NZ82+%jV)hWE=T))YP#^rLNAdItf[2[09>VPiJr^3DecSFmqg2j)j$'$WY+_\i94!B:.0=G9'NG_@G_"AD?&tF3kk:gJ4i4,(mcf^S.M)7mR9R75W74L?`u7P]ZFhYb6)rZ/XAu[.X\6.A1CT2KfZ1MWPr0a&N=bgm5,uK"i@"^m9-d;r/3bVP-Z-0Dpbjg]Sl2XDY%;P@CE*-$q8:K24*3PlK`_*EF-'/"%.o^Q7.hSL1Oc[H:_RMqYQA9+?Nm;-T\.S"74`)k%Z7Bl;@f@>WgCKb.Dq?1%K5I1;L-8&?+Wn;gi;)c/rGZsCcX-b4[s-<VH43E!p87%PUC[n[B=$9=YX.\+_5I[4g>_B<0a9tE2qW-<F3"84(2+43*"3c0[?.)eFI_ll`saN/O^DoAV2RJRY?!0Z:@7+497j4@URh@)NInchaL/<5b2rC4,iB0aRj+9VA/?GbO8Iu+(tO#2Z>A%l+:)ge](b)9.II.fJWC[de.**bC9o2OlK9-'P>DP@^O6&9uaF#90@!?WPS,]>aN.(`ns0PEN[La2*IuImn.Tnoi3(dZZbqSq$5?j^m_kkW:UJaaVKAC!sZ([r)<*paGW<R@'iS:&sg1(opdrfE17A]:\`k!gHc6-7,SH_1/r&DFuFs=V1F'C<<5-;q[-t_>/1$e"EIDh.RQa%fa0V]!Fea-?);7XXAO90Xm.0n37+NXQJk]C3:G/eYcdngp$[6gSl",R'j=`F%,o;j^r^I*pf#%`qNN8"6m;f8QFMU`Qgml%<ep<NO/:.W-dg')r4U=(Z+J^jIVE'0IrG3&+*$@:*M.Zj>,uuB:Rplcb'Jc/;ao3<Y)$)t:'tN4n.jmHJ[gKu+o-tV?1mRlgDF4Y_Il<o@)LjXqaK$Ar:]lRBpD]U.96f-1feKm_/[=^q6"sq.V,O>i,`oha=bTt86?EEe1m7g@ZhJ!.7o-cJa1eNVLDXf,s11[Od/*Og;hT/#-HP+[rIXe^$NQa";*O7$3R[)%ck)9ojB%-@BFZ%I#Q8j>dW&OE7Hb2+1EDZEN6a7l<2_Uh1*A`gVokg%F95350Hr*Wtd:AP<.:($=e5oh4*>L#+a`IW>DK=0*.*?16fZ2Y;=^8c23[26>i5')YA-A"q-)HWabtMO6kH"LN`.8MB2VFqg1[!Su[OF\kFDbBM-qug++N<6tW$$(TMXYq<^MHbaqXm=&mJrGK?eoSA$1qkXVA8?^e"&=*.QWQYg^<UXd7ch'H6\o7nKPfO*Z,6cDMX@'b.]**qW>V[;7[`hL':q7YgJ'YHW!,:&/F<-Tcc6:jq(=`j7Jk/T,>Hb#)qOsb)jgmU9"Sc;"mnuCEIK`>]>75!c;XnYAl5H5OR9ks<qePU)Rj<:,QWrsX?)GMF>/-CFl1bO#S:)!jS/V[[^![@scPOK%``".Ar.t(gp!bK_"_-(Fno;G1`;1o%g2aM+"_c6=1=;?L#%>Z_Y.<MLML:;lb3'"7o*BXF?0bDbG@JKs2Vd5II[O'gSqNP^K;Th7n]rPI/;OdGX#9oQ,'^Le]\WuDcO`3CFUurt!1Mfo,T<r?R=;LdG#RIXU=!qd8Fa\f8j*oh9%c"(0k27_XY5(_@+I5'U&t?/-4o4j].q*J49sDdRg6CZsmm:p*8!_ZHhs>W,$DHu\"YU!r0QJ0'2@q]=lo&XCI-=g[_mL#@\o<]=0/gWhM.d;6(C(+Fs)Z'9@Z)4r":t5@nK\.4CWa]h<ESirri2`:WXASQHM^1.XpAr0)MAbm[(Z/DH)!p'=qF7$W#;L[,OS,LA:Ugd[$%AnM'V"eg580AXSC&?hlLTKSuf?gINIoIE6'>bF])YG-qjhUKWQPeF.M$PX)IbcKg)X*DVeYe<mfMB@]7U4RFGEo\Q^scm:qm$b`-*PBkk%uWOp:Fj5?!gdUu/gQHM<r*8"LkR<#*YXBD/`Pk`C.H+0ig[\HboZ%,)\.n6P8El@girG5t>m+']2lqO?paa2H3b9j@C,B`6m[+<o1I$2?UC$B:$gNk+^-Pm(^)!PeR;bBbL9^EB-Za<4F;u4WG(aQ/J,i_]_?3H/'7!u(lH@@NK>=%he4Cc,V=DQhp[gH0L>#(Y`fr)Yjb)rBZm-j/`buRNCjZU"c+Z&AH[TPQ\USd5^4keKh<Po2ja\68aj](oTcdP:CoEE@kAS^A($I[&R_]3ZZlsX0(R^c\5Mq-mnm^310d<mUg`e8"$Np:mhmgVBm*>Lo7bMK>(BpWJbn4F2o2/Xin9@DHG-5?m,#A[^D@.'t4d4\R<J)Cl:YSFI,P`0t7c.<?!NsSs>[fZ;pW2/IM\@.?o/T3V9*$HddH^ngngSr>cZ<$(-UrW+6.D(!i+m7$U(61N9E>e)EQT\88C+<C7]4h%f9#A'N%!-ku=sk<a7D:(rEcimq\qRL4D5T.f$T\^uY@ecA<H^7Kcp>7!&+]["AXS!#X7n>Bc=Pc'^^g%*Xg+!=WElZ;>=+a@*D^n&\\!^>>q$KVj>nj='ouHZ;A+*C7,ke"Ob@hSk<VZroF?VL'^9/,I'mq,;^EpG8og>*95,uT#62:JfYKRnEXV_KBuJES`Nj3e0)ESnnHat3<1FnCICk4p]6bu1Y1`K^.NYT[BD,V)fbR-MeLJEChc[KhPpu">po=-U5sTk)MTi/cm<2*)d:BFDRqpe0]s0'Pf2`t9?FaVCM]OXe4(A2IO(k^s)CqZOTMHnkRdpY)>?2JaQKiZu=;">&$&FsK<2Tja;o;j8-\1biX_Iq!4&6H'G)3(kp*nAiJk4E:0%cq,"H3EU`5Nr]aFnR,J=g@fA%iM1mVa2"oRD>CP?P3CE_fCP-lX>r;&k%@/o5UF!mA2OJd2n#^"@qh7^7F[;B&)ba2)EImA?)P/#ba*G#H8Z%\nt".NIm`4/"'6,YI&Wb+Xhgb4M`0C7DaXlO?X>'=hYrB#kjh&EPglac2JGB::'6*(mDC-QK*U`+fTNX6rO_Sh@CPAU`S8W%aIP9.T29?$J#M4=MT^isI]-jKH8\!KCC"f<:F_1/lt7!Fk<k48)J`D:55VgciL@.u^Z1C!9s-SK)21/L++,K!Fnq;IR@a3Ha;VdBRHO<ubmgGKB@Z*(Z&A6p_;r1rF"Xbb]Tr,=n(MPa\N`;cB^phr^$*oSGD"ifCMg@QW."M@84\P=2t>LlUs@gli?odWYLoPKcG`ciCN6Do8H>7'Cs_Lr=a`C4%Ha*9N=Wrq(c``]e%pdq5$gn]Du#[Uf<C#o:QKa.q)-,0Jd3c.t:un+!CFhfkoRKPidk(5!H\=iO:KN_5C?5]G.M`M$W+D>tc$\.<m38MAjFgm$__*-Sng2M_If148FoI%(X\_(\^AMQOE(>p"dt$8`;*;A[4JXp%Q(5cps))iS6KVpZXqoq4[+\ENVpVh<T"5]IHu_b6EbQAO2ck@?A`'k&>$rB/8!RYm\Z3?Z*V?kJkWI$G7<G*GBhk`]P_Ef;bnhKL,i*&jS;PidF"+-K0a]eM5r1Rr!3<6fHF'H=M:_;moe>#OIPQ"!B(PiLS9();\r$>"*8AHm.'HSQf5Qn3Bg298bk%b5]9]9\JIJ$:rCQMkEdeo8-nH\KS:K@K5\ZGR>0d[c'_*?RD9:*5SN>%FYT4;18lpeQ;/_L9G[pM.cApPp*_]^KCAY.Mo\FZ=qRq;ufaOJ/0:,@Bdis6KW1IQu"DS-ne\]PGre$EV"":(&CMHK4g2bSTRro7URGETl6fj.ju9hM2SielMG854m$FEP[%Jk#V5Xle6@Xds"^Y1bfF[r(_(j8<LVgp+&[S5bfY>TtlcT)a8($)=ufUPHm):+2Je(5Qej/nb8XN0^4K'el[+nk%b`@iIeD%hIXa?KAJiRP'<l?"$foqnmCcPc/!Z?1Zi,iJ!B`S=X<W+:b%4>K`lMaXhT&7$4h=&[(;<9O%AmD]d8Om,L48J9,Sd^FZP&QOnFT(R0t;VoZC="Kpc"JG$BZ*SX6\JIA>S@H:NR'dcZ>!k!"V\'G`^7H2nHNE1>(#W6]t+^eO-K)8c3aL%qCE(VLtY\`EeNYKh,Zj,)R;RmaHuAZVl'D@63/MS<-R9\=lkr+C3kA\7Bl!nbO7:#PaE/oE"V'G^/%VU<ke=i-Lh"rZUds0@XW5,5=]jD-:6Uco\55NE>'7%sVu8[YVui\0"i?(cLab)P->;-ZoMH4i-.T4OqY+fMN?')=]ENeiG:Ttpp:;5'5^R52pH-p0)iT"U`]C"Lh._<:dC`q?29B7l^)!%:"cfA;MU]i8o>M1tRXEsu`&F.DJ3OV?%.]g_]m6r&RLk]+V&Cnce[58WM)aP_+SLDe9$\q9]3m@rktbKj'`<0).N[!sgX\iK<92i'YReET5:Gf\[1'&WRN6r-N"&J;>.,B2fe8h8f?J&Pr@1D5rRoMJWe38&eeT--Ng9PPN,4@,0ohp*[#a[XBIZ(U4f'g)Y^#h39O9]XJ=<QsO,`D,VsZeH;0bU^)69qTt1M=n%U[9[6`&J+<tJMV!UTCen\?%2gTmf)nI7O=beLaaaA="4OHo)u25?L/2Ci,&f#F5nhH_`Zh;'Gk92WWN!-f3_"Z3k?fqN[']98O%A\c>YjqL"BVFa)mrZfZ@Vma@tC)53,/BBmnrAK.jQFA,,7!f^kt+A]OhoR]MuE'\g8^;)(e.:4:=\04nkNEqWW4RQiA6l0rppCDc;/?Y?Rqqi[uc@"k6FrYZuq<I0u7)3_%;Q!eNV:8<eQ/r0_S^Sc?k>`14(7K$eI+s$W+6,hsWdP#S+E:gH;8"!lR/qg,(*QN3g5RMok_QQc#fk:(9q/C\QH>OeGDsb=-mJAD`9'8H`Pl4Z$8EUj]2M@3g2`'lMBAE@+"4;&qnX@NEh4G:acM76<XlI8VXNck>Qb\NRCj*uB;rp.$Pm=S&L07?Jk_`$UmSk"O)pkg[G2#gE3MK.Tpj=<94(If/l2VJI;$F/@SmN\Am+LAW?M@mQ,e4:B(e7]q5[G08C.(q#<*N"8HSGO\p)4>4o'W\f+*B@LBuX=sOLY%R-=TKo*m5m'+K?aD7N3Rq,tj@=m%f);jK"CfiJB<K*L*bGhW*C<b:]`D\T]U9\eakWP3:+=rVnm2a7E-sr'!M<NZU(;N36.qr,u&S^N*d@0qKISmN+NW(]+_&PNV"-R`d?I0_6hMh/qhm(r]04LR<oDhhd`_ASj>][X0SrAZrb5^=^Wc6$E!O&K<aSL4"J2BJ=qLZts>NW8LDo]T(2l`o.Y]Ek+<W4Oho(3'c>EA:R./%;Z;F*"`lCZ/N;I4N!Qnjj2o+qo>L44F>SedePsQJ,W"Pr/])"P#TcM[P<b5%Q-DA4q^@mL*HOjd0Gd;q@sNrc[(oXbH]*d\>)d3X,^R6G2(#(DDR]h(LB*!7`0;p'n,^_PMP1`4W)P4JqX2j*Om14Z5'`t`ft7+DhUc^1kZ@%P0)-I\T`/06q4nCYhuq:e-$?Yi,HMlG?J5.ZFdCAhn8,6F5;O,cLuYKZ2<52LqW0A2Sur<iI?,JO@<TM`I(EMs-#X2A83Ajc"bdT%I*h@&Ni4-Z),s_&k&/8Ec.*E&L1LROWLkkcIup>ZIrp:)a(P/CNWbIh7pC>\3G`<W/0GS+(%Ac?nH,*T1s<f/R?9u;GIr9,:C4j"]eOTfYp%!R5WkQ0N\%Wb]d<oGm'O^`=0j.Hl,(9+ccNQlE>,_;LOK=bL(Y7?BXq*CZA7(>fmYN>GluuA.^<PW^U_r5/YPrmcAd[j`FV,SWhrS5VdLYUB[,9Va"e"Z=PsiAU18.A(kkmV,0J.?@0E/?_8*JemW-<!+7FXdhAje6a9;&&B!1kVQ,`$&f<Y$7ob7_Q7a\c)+0EJV37O4DUt*%-H>RFBLU@$cSgPu`9gB/%OE]l+2Kc^s'[?!JGWb'KOH"24]3LV:ANn!;T.3YX&X,!<l[p6rO$Z"=qML@KpYgnC\;L]U/Io^%F#eYn6k=1mbY'!fq!RK<J@!HD!kG,7SfpOB%+p"ATl@MRtZjDZE\/nSW.dU/ba^]bEm5lD4#%fb3aLNm(Se:>,tXVY$\f@%1@d$75XGDjb-04#C$DGc[ZT:cq(;Mq$Uqui5^FF>u>1]qB3:6nrc":b-A!Mn)_:7kmt!s>EtL84Klo2;OnP:8#c=\p?=BYVEAP%=;Wl7h4f>^,[FJ<4;onpNpKBGgiuqA<:=Y/7.Vje)K#-;7,/Vc]#'/'T3g>(T;8].Sd<`4T21<,>.>ic*&o/O;YCYnRC;EsGP8&&YuPeR;8eL0'U[^@k\.Kb5lfHIjBR00n4F=@.9*!0-#/IS2-Ae;mS?`dEVCF^VSPn_m<G97/g6klhlB&q6<of`$ZBYYjgI1s3Du<qRdrm']f(^/^YG[#;=\Zt=p]BrI;"-gLf6e)$"KhR>(A@OYZPse4]K)cEIV#E</LMq?BqdX$h>[1T>u4SN-04*,M>qJn\2Vbh[j+WA^:9.O!8Ynj!G&jp,#sL<Q\Fflg!/;rq*)V-h65F\NXnrCgZC;.lCGi>*JRW\TL.nI!e3eEA:%[]W@'r0a!fp[:H+]Dg.L2%dp;rLo#EqBeS%IB4XkUi]h$q(Z90Z+WSbE^<!0SH1;.&mW(rS#-l;e*$icNM+97]L8IKYdK`]E4!%9.&hMFMFX!btMjU$$<n&7$XAogU2%W'ZoQ\$+LhfCAHE%W&^5Y7/[@'frHhglM5_W7.gb,*TIl*1+lJ_)!Wg'@aCKr4;cc*qhXN_2qBi='(XLmtfiEs#K]kP4'chJs7LE(7d]oY*0THqSAPF[Nf3ZF/d7?UBP:.oW<oo&Y_OL]4P]tW#s(fj,dOsct#FAf*G7T,J4mSka"oh3n"s6Id:!%MXLHS^*3F(fRW!_(WAVi"Q+?EbU-cH)VKo&&9)K:-MaK%.W@.*B>p*^SRii953^d3$s.i,]98Z*ohXcdh4G>Cr7_nP;34ZrOn1QRC*H>1oH$BhE/Q,Tm>Z3\sTX_I>XUCG`')RrM$s'A&+Md%9qgKd82($AaNHP(&&%8eKmmLT5GhFsFk(.CE>jp[pDI7gK.WSVgE;p%,IA+?V!92,#&a='kQ3FaF&kWUrGm&@KZ8I@hn+4KK7Ro#m`+:PR+aN<!LW9uQQLER5m>,W:7<%-D&uMt@479H1JP3s-Z<&O:S3PEG4K.>iTL+BkF8N$Ad\&B"\o,g\U5Bn%W:1RO(g#O\#`[U!hd"$'a[cgM=iSl&KJ9]7ic[6sIp`8[e26(ChtFp:5g=;?!RLs;:^"##7'OoX8BAn_Jr(]4>j:R_>$#9Qh8B+@8SM\<OOCF-lNZ5("H(PW?'LYt#KT'p8u4e'b&5oMq8)k2A0T*4Qs!'u]S_/M/SJa]TJKdd.2+XqV"XAVI+Oilef3!bNe#DM5[q#KKo-N]pb!0@Sn_uH9cX?6`G4!:#eTn#=I$`Kp9gV8<fjQm\tjbDjC3^?4H%fR;-"7Ut"XJsgnb@WG9;'6\MU+jk4&E=B!km\.+P[ftPEsNp:\1[jC8"iS[P>q`Z%1kob@=Y@+5p=16DKu6mU1f0!Y`(72=k,sIM#;oLR+Z07&VYi,s/AW&aso[;_X69geje_WK<HPhc:a=!XW&6V4"LX?=8<2>`m`@SNQio[R&01TmTVKH*BOG0QS1!ea!A.;EaIg2FI),PlAdF=U9+et(S5F[5`&dY<f@Db[;.1`$$G$/OLTVIl:p\1jh-mbHD]rZYc,lqc(EtWij&BVNb7ZnM[?E<),8&s1kQeI,ikai.J2LDPkjgG[tBNI4W:"t(a)<+f^`#jA,jk2(MCG;)W#Wh=$G(7VeJKuZ\+CM"e2GV'faAIG107Fkt]8F2bPFK-f%pOE[e/OaP40RZ0c\qV8gpNVXFjEkWo]Y?+E:'/$:I?48Skr:,Zfa\+qMu*>!VP'[%cuhS5pT<a(;_Y1TJL[M;Lc!YG94YUBe8+o-NAae8oO<]208JP:j5%_PLT?lIEGXZRJi?lZ4YjVEPHmt'F^8IqL;k<OD/]a;Q1'i5kQKf&k+[RVSh%)+N[5uJQt)PT57n?.r="Fuk8J=2(l&-!=29f//:YjQ#c3Lk/9#I6?$r2L&a#F9r?:-ekV:W1&e*<B#g36Z27"X.$On;=RU#/FeQ<@:>q:aH,h2P8-Q#/?ZWbXs73(s)h)6/01-WB,,7"ieI;g0huX2[TVL@^*XCl:"*_=9etAn,`;>\pH+g<GK?$"*&:,SCjcqE"`R"\H5lHmBB6k[bqA7EXG#V">AsLW.Y6bit6g%a?gJd=rV<3&1[#]n3,t>@7W@%GRjf-475(OE\T=+bdK[9f*6:]:hMA1'F'-P&Cd]g#Y-TM4r9(sUN"1S/=%Ndj0ACdm:oHlHfgcI[;=j\P/NGAq#lB!"c];)CH)Z)8M?[:No9R^!47bdn3[13VB=(&KK^S3JWT?`U]l?&i4[ZKm+)G/]W5,-"iD!n^e?G,mn4CL=aP`<kVaXbWGVdCC`/4e@Y?BC+?^4B]5SL=^bSpkJm$%mP=d+O2Zs`=:GN%26]b+N%Us<?&OV$sm%RD\,eRtPO6=%)OiX+7#!a"-+q^"[#Y3&d#fLg;!"]a)Um]$RO=MlRVXuiL#/E(Lq+YVq$58Z$Lcme8O<k6B(I)oTTJ-e)`"<%anaNrc#X5?;mY0ZZT*'s;f.+nYHK4L!BQ]Y<(K0f0(*;",5nrM)'"82L+h7`/0:nc#gHrDqT2=!`3sM/(5gSSS@!CWm%m`Mob7:Qafuc\.\\oU)oane0,ou_bHjU!8aTO;>#5*Wu#6%%,)Bq>)K`Jmh>:W;.ap!(k-T,6b21Sk)\V!^",i3nR@B;/gRN7t/%n]tA-jdf\$@Uis?q![e:TUVtZNq:h[aGC*.O"AFHlejp/mCZ@\-gP)4>$10`Q%ra5;Z=DVuo9f$q28#.iQ</AIM3N@ZZ+lXI=[=2+V8?5g;Y^e[>C&gf,qT<7sO?j;9_)49iV>1#Pq7i+1[!TSNa6fcY>L!L.!u5aYdn(^7cR'm9_kOohrqg4N]@4k&Con7UCCb9%3CXY/**Ys?5<_D7La;2'Q:&ccj,=IV;B"p`<s@o9NCV+Ql0.O@_cP[HBN.LAF`'VI_u;rJ`\&C-"RAo@r>3u.m#I-_o!F[h4<`$d`1*s_C5FgM[*C%NC&L;BkoZUmcAHUk)g!dXhP!0<Dg;1PYT%D4Q>ULN-8Ju'j:r:M1`-son>7"s\VN6;5=i:%)IgaONW.hd<!3a`/,"0;8$T(9j+Ah;fY4STea:o"L)N*(YXn-V&lL`?YNo`>t\1/9Pu,q$":p^*^N$F2B+c)MY7'a5o?hqs;AJ6.c#5fFnU.%M73"@3kq!5KQW_;K\Y)bSYG@d,EJhq(uC&n+WY228'H<['^lrUPFe7lh[niL&+.&G^ido5RKt4RBOHJb^E.K`5j/RR$22?o>k3kRn4q@!LI7JF,$b2#o@$'>teWmK3d&$0.[-KBS[5ge_5.mK01"6B/e%NX-5Ap^\To_=.e;#_jB,8D(GNMAq)87m@-Ih,$'5pEfmi8YcjsL9(mTOE-gMF9L"/&q26HpqcI<KRO(Lr99j`W*'(4FpNW.`#=7:Hd)njWrZ^\-?.0;"0hIk%u=2V"UopgW!o5s'Cfq1'U:t;KF`1U/iNo`i1UueOsk9)W#Pe&,4k@CF&-93J9"d"fReO6apQXYZ1R<X-h7m@Nei4qlO!`?9ZSdlSV9.Ml`lCZO]("11N&3gC*osDEDrU%B5Y:IQ5(6-`j.^KhNlKBpd?*-ngSB[,S>kj"E@+$JJ"tRdo,Pd1<PTnP34]`[\7EUU5BggRk.h2juN@d9A6G/#@o?Ec73Fsj2@GQN!i@+*g%D"H<sWsb,(R;49_>'EZ6tf$s=9hGosh'atQSF<odlk&3L]r:@Cn<HMa0*aAKRQk;j3uiP@GLDXHp`P;qEWYW:)])==$VMVsJ;jUItt:D39(0KTpg/uN!D)*UN:C(J#@2i@Jh&c?>be8YMBEZ>[]*Lqe7VN0GiOn=NhYrjT`hIQZ+Y?p/eFD-<9:CMe(MPQ0+pTOQ0njh#O<bN+qEPU$C8A>Ao.3R8)$Dhme4ZWbBEVRqqrX2YFbsfr;.&mqD_=13sg,]lONWDpmL*\!6#CO;_Q!EjSlhf7"@spE<cf%lJmR<3Kr7$DRc`]?7OXBp(cpR*LY0gMdO^Vf?YPdY>a&A?onc62C$_du9[:G>SH2bKngK1Jqs!Ktufr@8dR_'VoU`R$0S(cN3e<Kn2iGKZu26^QMe(idfc0O_tjgAZ)FXg=t+Z95Drs`F-+9]3f9U@p[a"0E"4s=6>Cc;2HpXJ;$I0-*"[#>an<4!ZNOMutF&-XZiWrX7V^7(0(<mG"nm/#DUB-5*??i<=7-\UgINdj$T^p+DYQ.4ceZ\@FAL-l\p>i9N(jHPsBb2e0]OT7Wi:QEF<`X:Y:aP'F`6.W1B.4E3Zh#,O5o:.1Mc`<lne_pJ<:7pVB.\IL;G=#GTm/FsuG9nB2Z@[K'A,4mglmIY-YrTa7OkCc13@M0ak7%YnCSmg"3O'r-Va["^j;33eKGGW@IWBQkQh/I>jgT,?ECCA*Eo.=>9&$>iHrpo,m)nf6!rX\mE\)Fr.5)u/E8'dIS#C;kM#\!td]&.2o*>W<6Xklic-f"f7*f;g0W9U4c<.'HGuQ>,(<`6<kKl,1M$]dKcemn2BW*:inZ.e2qf%T#mKHD[ID"MbI)PSs)HrK_S2&StA<:U2"A8cGFi]eQdAU4dJGA,c:/c&=);Y8ocek::E54!MYZliAa5FuL'Td>VS49$:^(\[-BY`a.,JDdXF()g=_LD6I*,9AaqA74U#GP)Ml8uN\,"Cu*DU]S7:4AuIIY.JkkaQduN>",ljspGb,YQZMA=fV%G(>RM3fbi_,3?A03e?\=p11.pmpFA%MbTmM&.N*WIrY3'ml$"u?L+VO$bU;bZ+:dWLR7Pe1e1SR7kor%RScXs<MJ;_og_lL@]XoLfDL<%M6NtEFppLB3tPf)js>mL72.2DkOZBXB9L/E#`EB"<L"3Q6ikk<rML6ZkMm'CoCJCmVU#/O$ZgfibFCaL/'<Tr#Pj<QM*qkeF3O,7R`8^,#7%M*OK3!a'B+WK+;>^)Hsn*(h`]0/&)R,G/IcAUZ9+FN\\euGjGqKI'2o"DO?F4.a'j;XLI0T:D?FJ"<6/Qd2,LTl%,.38cK]GsUO9W6hR[_W1P;Nqak`A7KT$A0ADkW)!<N9`ZoOjB`/"P8ruA"ffIPoL'HL\.?$E0C9\)c'2FT+?p9ke8:3Q5rBS:a)3d"KiV+TgKgs)6`QuX<A7W9kT5uAVtG9'@t7*WbUG5pN1Hk$<ES.2ge"ENZ7B;.$j."HjuiR.#?raiig5p&gh%lK>-A$SRu\rE9i)68?f,sRYYp!a?g.6<Qp,s;U"(Lf(UeA<@%Go-LN!<6JqC$2k\/9.<"C8PI1F^hA_D>rtcY4d6"XC$jTpe%l=3Qg49@m1O?`+k5*)R79`HRH>lEab>4kDiANH6\b:C6`&I^6.k"k3^l_H5dr"$6!+sM]0:-jU!)4/pmh]M?Wc^4Yan7iNShS?Z`<k^\\.5O;eNZR&dYUn"a!q9tXlQX$,&`f4pguZgB4:AkN1eMrRqh<bL3KdlL_V/$?p+][(X\]Z>qbIf?9<f2Sc`?SU?9p\85QAlU>"d&WS<F%3uWE7-JM]7lb-j<0M\3W9&`Ka(Y$"5G;9^-HO@Odm\%K6n,&9Kqn9ZUgtqO(OMH)hZd!kJeNf(q67?m0\P34W7kQ'CuP#U')'-Ug/s$<Y2oQC*Zr8">jMi:^+*$A#N51cpT%rBs4<]_UI?e+"*GC&!+FH+OK1t*QF1hZtS12!<+dJ7(>XE`OQln?$1`Y;Q$'#htdCBC&<jIpt\%SF*(E)J4'fB9OGK%q!@P1k`eF^O7+lY/\NPq#@X:3Xb9-(NA`b\aH\1)NRboeQ&\^P)mb5dn.OUmX:(01[5.NOJihqb;pK1-M^Q,mGiU*"BU,A]JH<:Ka*?ud9L1:8-uN,@L^o+gD8bHOJTA:[b&G=;j>[qrgn>^*;CTh+g&#c:DV)b!dTqjN,E'c4,,\A+`c=`rGsdf?pq%erq"@KhXo"0r9NhqgWYX20=Mcp^HVWVWY]fmZ".O3iB,d,NRaJ9DHfG^:lQD;Z'fOTZZhc5V8]pM$S5j?qENge$9ID`ZM8paHdNf]Q9H06Ap".?iS^d0hgm-2Y7ZnsS`oKj(&0"1b?%23)?(U<6OrjWNL//9jJ8C)s'B;)u&Yr03`_%,2fipPOZ(XL0U5C$$)?T1Z8@s&A7h\<['M;YorcuOm(dRV>LWk_4F6IQhT4ZKK?+dJ"H6G?Erj46mb>H*&SjgV']UM%?(VOtC@\X-U8l-nJMA)Ss7bbKiE[-$!i=]K.e?;H:["D=D(>nqZm2S9*Bb?S1'#40.N/R3t]q^gdPJX"-.pI5VIS;f1T3kgQg?@*[W)]ZRN?(gCe$ci8m"ODHQs/20c/LI$o3:r"2m^W]EPC@nR=g9/H:\b+E2%A-()J.g':Cjp2@-j<5^Gib<mMlK^!*NM[d>6.hQ!taHuAfGA)+['YO`h"Dl3bd==6M8@k!/h!!!*Y35^@L6\c'm</C'r%^M"q7>\'e;bUb:+C^-`#Qt.Cq6uh!!KC"D8XGQdhuSL!>T/n:c'_63+jb=ni?[p/H4Jib)^SqKb##N+W&t?Y^lZKAC?^(0Q;M9InG)\%N]"j5Vm\U`]hYW8hN52lmtl-XXA#^G[^@E;#2>g9aIrAV-b`0MnIq=`YMr4^hPoJcYbb]pihD=8#mRV*H<C=u13D^e2E"ddHs/]1A]%L$AG-Go829Gf,dJQ\0"@trTY"03kMSRi<cpp]oFIrph4R!-b8-4Y$Yq9VX;^q%]P)ES\?&uK0ClPPe[n`Eer0a@i!L5mZ!q6Uh-N6R/ph)tDlJ3Z^i.')^[([_ItVg5'BXHo;&(PQ'/6uj?6e>NG5jJMO/7@h\44Gag>GDKiO>)F3aq"h_Rp:A^OhW-%=[hU`$Td[^-0L.YoGlJq0U;RWst[Kj&<s>o&^7o<!-9j=$WIHB+JMe2K9Y(E7dbfql"[0rA/&6*s\a/I5lGL^W7IHA@Z-A-MD+c3:.BPAGA1q2g7?<?EZ/c^R=cSWksc(#.mO(OMU(2Y@J<CKJma4+h.quBs?p]50TRgh)+mAlDiarnAR9=XessOS$=bcE'#)u<<3VsbO<//($.X?B,hjd6l56MJ*kr]DgD6kYcW,9iZ/#+48a<hA9iY"R;qmHl*W+Ji:dX.:X2/CnGm2K2<9:9=?Ge>gg#tW`#K@.C@Ee#AaZ&&(8nptDuWe6GJBdmEBgjuEfu9M%YgeQ<pMp:He*:MfiS1J0$&;-\M.<=d['L$EB_E5^iS!-E>VaK@Yn1X&8n[p]HaT,%jJR1HF*_:*Y`Cq66%s+Hcd?VEH2GH`4s`hpEm'sRG;3tgj_>d(-O%X70stZ,e?'ZZ1H#hN0>S>!mD("l+mn-57]a&Y6".^lM2&fA)rTQlGItj'ghRH,A2kd3EHnIfm8.]juJJl_XEVc4%jEgWQ$=$e)K.^HM^\$$1"sBVDs'fJgHRP1gAEL>W+%+h/=FrgrJ!Q2LQ0Z!5eAW@QFK56d9g9ha;EfmVi'u72ma0fDK(7nGiF5-0j$/nIm[%=B"J+n`7%!eI4TH*oJBTpjEU+Fh_b=VC7F<pgV\nBse+,-kpGTG0-f/:[jjSf#S*W(+/#2J&cIki$7K@Wui'pY*,jP!21k&'!:9-h)@uVg8Z1YcPCZc<nIn)<5)a1IJ@nsBfI\GOAh?)P2,UEfB^eD3jO,NIi"Zm05M>YDB=n`ho%KflIi3S\K=rR6^<([^!$)>)Pu?W+Q*?,>NT)er&UI)g4(iFfrrj%:R)OYHl<IT=$Qj&AWNEt5j6&9,6%p<d!YXVLqP%o%4/<&fum/?V]-oZB6j"`Ri'SDX61XEH+@=[IH5-#D-A!#S1F!t2jnUqiSbN@g%`pW]pmP'gr@mf<X8?MbkX?,X#%I@K\lr-rP9CWOHZi'.4X9^Kq3YD)QOLkPV;o4",9'tpPL'[;8"QY_0;]Ns&ER4f:IQ_n7NoX:T5]Tl*!TtNqd[gCe)%6IqK<(3:6!E9mGRB1IXUumlN;12,/^+mFM%OVRC'g1*?Du,Im>ZkT+umjk!S$_S9KK4$V$?/HAF(FEin&3YpZKZ&9Y4!-D9l2gcn8b[\=/3'6<<h*`p1rsP=e<@e2nIOt)GDETUYLIdM.?bLrA\d`Rk^3h0K`HAqt%nVOlDV&X?+7IfCn'7Ln4NfG7FPr:7nKo!PbPM^uT"UL4S7DS+ckC#ghdMAM+8F*D1\Q(uCUfCfV(+8];0!Q#M8RH0am=7D,+mddB-#:^m,koOe8>))ZHQ%7>rF1*[RL=<p[?.'iBn(h+!L"JfsKY^oBJ/rg.Itn@`Z`$qqLp.-:^eiTfn_qY9f2pigbt2$0[J[@'9sMVX9cGr^g1aMPr\#d>#ct>i0Q%n*L>p+$pfr9C`%t$GOu=ItfH'q+!I.p<mjnQ9MW0bZ[6qc"#YhL4,aqeOdJ\s-le)`sVdhhUBT@ZaF]IP=:>M',A7Dheg6E7La97>lPiUjR%2/LoXPUK3bokroWI@.&5)YSE5(e4?HGn5$^j`K0QDTT,q)n"$Tu_k(X1G`QI,%0CGm"TZu+lS;7!OIJ(eKJN2sX@XPb?cNlKNEVrAS3\DS&,t5k@`K,uFYJWg-f898`nbh)mp]kV^oDe\?r1LO3HT;a\^IP4[GMUF=\b)N4ANOBj3[jH)4A&P`,I\>5^^i3BE;UP#TW;T]?(l1#PjVCQ%e!sf"0Malf2_RODSk<H;o58Y?PU;,#GR2K!&C'/LjIP+hb`hpnmaZ`YmPjtRntqa'aiao:Hl2)-bZPf68o;%'6(9IWADgHDI],WmB!CSf55Fi.!2g\i*3dcpS#1EqqP9bKo58"9Bfb+jKp>PEhFX2+c!?*^'DmLY%a(\<^KiN?LY_2qd/;3YUI1X&[p"+CG2,[[pbI_]ePA`rbJF>@(D:KB"d,dhG\Kn8eLAoG')cI..n"Ie^)O4A_Co4#9gOk$`sI%RpJl*pbn-Ce!K$u(lleSl;H1p"5r8hLsK0K^@/u!^On-K1.s70&:$`.W0AGOD3>mdVVG1YU//nAjtl+AX1D9V22#lQ7ui'&:C+S]\>dWG4@k[s^+KPd=DCd]AkDfr3^IP_U6Xr/bgR@!b>^.iE*u1Q;`jj>MK#abDFZq`ar=hSrT)2,S8eM=qI/WJ(r&7?%MHc.nC\T_9%cnl`nJ*#,D3>9(BVth[_>0;hHer^>3_.ed(h`N^)T1=T`I?,7WpE29OHCV#/PqV,WV7$T)=`UbjAAEejIsjphaB84cQGO0@P)Rht4o1615/%2,5ijZpAZr'g#,Im<1NE3*SP_@[t_k`#+Eq&\P(t)CPC;'Kh\@l*'iX79Q4s[*Nih(PpMjFYUSQ+6h5$meh:a"MB(Z)^b+=;0W=q*A-bf8A#MUk@=@!!<$t^I<1tdl/(B#Btrg-_[(DeK7n-]>C)I[#P4[sm.Ksj>lG<:4DJPSqe\GMMLUVL4l"k4iZkasrg*oWR^h;gEIXG[pYs-)#*?&4/\MNo'[`eu=?80]\L'@\W<@GK92^s+W`>80'C.j!mSAXm$;G>2])U0Rp!P1W;IN&-4o5ei4"1Um[=an2k_Gn'%E]1]_&CV@QE/A:Vu\(bo<(erga\gWU&rdaEYeUJ*(DK$l$qtAAG/Ti%+K<l7?UH&2?B6[<FJA"1?\0gmR#eg7>ZcAA9cGn/0*u`^H(DGQgG8F9auRCr2r`EAqNYkPkg9HYj]m,+JRBg((OV\%*OY\m'j<JW1qgX<518\WZF//0mT0h1(7_!C`<KC#:uF-n.2p:/fL@&GFG;o]I$W;H<W0S:2ehY[=38k<'j"2&r4r#F1DH?#S>M%MCO2?`Z@b\EBY:QQM['hd8Ysqj)"X?O_Gi)>3XK(-lg#*>CgQ/&G(_OkOig,%0>R?,9)2ekO'bF(8Lld!$MCO21Ze`m>`C:9@k,[pU-T9j-A3uZT$n4RO.sEL!KJ=X0`$V_LL.QnH&f*>-8L8*<[>#:P*IK)7[`Reh`r!B\(t,r$TH;Cf9kAlE&l=lM3ZQ3Q=\4KV4&72saF@B3<d>_/PrHT[4O"ZSm*l`2He`Xd5EcbDq`j]O"o9E\u.['bJhL\@EafF)n&f&Xc]?)j$^qG]+Fa?"7/QXDFgBI%5HQgp8c@ECRlZOG#RjcZis]`=s`mP5!d.f0!&[AKmRWCZu8cOWV8;29"5s(s*WIV(IWl]J]V2Zg&Q_q$JaI4=1H*adjC'Q[W*tB?BZllJ#o4I=i7M!c]<D=W]@L,a%%MXX5BOcu_a&_1'u+8g^V!;\Is)?Q_hOa<MN$&&KHDBEVNOd`B?3"G<"`LTult:rH$lMUWp#12pqZXdP[T+'M<k_mtcd_qiUn2-_6YQ%R,&,:`or+"KV+-#%85h!<@<)'Q?<lE1&3I%#P[a8FN</cNh/p+u:f\XsX5?C\9]a,C:Z,KVANc&ot-cqt?Umn@C^Qc?=18a(1cM#<t1_*Dfei/eb:&NaS[<%5jc^-hUB_&,L:TT)!MLkGl)`OKFcA7pQ;hKZB2?Y\n_7^PR:R%g\1k.u$YP:-<d<i1+Kn.F[L?J!%CD9g7GN(d0\F%(@cqarSP/c_[L*h-`'NM"q=$7VZ-RWqaKLSeqg6%4,#X0\EM3_geFPr<<CFYS6Tqd7/<H:IpIb=E]4IN=1%Tu@ts`]O#VdM9qQK'N(R,MfLm^0D^g1I>_ZYo.#C=loKq78$9,YE%7uk,,[N`u\eZ^N\e<WO>b2S*?83fB*`[c9k"n>-ZJscq_3l^SPrLP;2a\[KsOZ`IBM'i1Qpu;$KFI-Td2Bc$Io-lI!SaF8mRQH<ArPK>_odo9A8*F:CQlhQq'kKJ"?60^0!e1lQ?pRT*'%6BPna]OSA*q@4l(08@I-/":8K>Tl.o0'^DQ#`Z?AHpnY`7E=JdCs:'U7O0!dg*rZe%6:D>V?LJD5kWjHSJW9EiKK`qKUbh!n=;rpk9V)gZPhldU4oDFcqD3Vj+VZYFVOa*Bc&!C*[DS*\6cR?XMp+^gOqmp4kWE(\[):&P"n[*T;;K1qN<,@[*:Q+j=^nilZF@p0RegCd+C^DPod+,i6Em\]e\QtVQ)/Q%ba]2Ysa!3U/N$^F#s5^=JGj7-g2n)1^p2N]Bc&O)l^>jp:-=i;d_69+qK<Y-,t7k/n$4K/o"5*dCc'@-VVFFk,bg6Vs2c:H*r-tL>':da&HQeQiMZ_eH$]Dq5+JY#4@7+c=YT+7@C<c0IONp7+<7?;+qe-HcItV?U)`7_1_b,[,Fh*+Z8e):19gHFZ!NU9S4e/NUR:Q+#tnsLsFAqjriA"b#mL*:U,D'(n%d<:'^PN2B$.XN#mCq=tP:?ma.YV.a=q\)r6k=^#(@FX-i!*a`QT+gH2UfQkPa0A)G"Q%_bI/(n?Oi\j\dBCH/8U=sh'YLL0q!CEAtH9W>LE"t7F-,4\iHLuOP/?Y7bf0uHAOM9OQ[DEu@!@-h&gLi*C:2VU)-Kc[<?9J(:g/"0-WjK.?LX$k?0N6F8cH].62!%$P5KG7kbBbG<D*?,/G15tE>eCIp/QUdt$R>$5\/S?Q?Tf<"*l2s#_C@De1?ct+%OuQ74"`q&b__HZ;H#MUf3eLn3FJYffkXb?;$P)EY@MDs_VJAKJH8,YTBgG314=NhJq[JNXIi6q2UI&ZMq5@6MR-O',T,H*B%AI==nEo"bi_--0O7FI\bjqJY`u>A!bA<@)D95LSI([X'NGO-blPG3%6<OVcBi(%+OVK2s%K2MU1+(k]McTlgjJ\%FU;*!jHFH/qc.*rAjWUGFaZVXQNTQ)95e[kC`qta5\msdMh\TmQA$n4a)jlG,;[#&%kN]c6]hI_]^O>$r_+faGQ@3G-^sV%_[Au<>CU_5E)Z'/0BD1".&!+ssdS;..OH]bj'HaD$9j[jGbkhoP8JNWqS["pl\ft2<\G?[S55J?2U2BZi-m.],L4(l]EjO9/5fH?ObdX]Ajop<7iPMpF1:W@F?gKC2ig)'R;EVp0!5do)LmR,t&f4B_jrnpBQ6^Mu:$NO?>Iiqbi,fB%Dk"aeT6?\(@CA(?amf\#\.$Ra=!<Y/e+f'70mYnkMa6h%PKgs#ncN:_ok+,Tb4404^1ndL_06?5&[)4i1F--TGWYaumQYp#g<W.p9uJS,2.<LDkYsG=KjcLFN._:4UamoG12.#a+*Bn47ZkHfeAenfr0gk/'tZc(,NXO]8=pAjqk]\EoZE@gJAh)'eiTM8i\WMNEai7ih]7BBO;&Z\E!Z<kfVLs)Stoa8<Oh,GNm6E^b0F2=6CcTOdan_pDIK6N0'48+Bs61_o&b?1&h$\oQ#[G,H:t4WR?pI&J@`GV&MYL(q$%%9CkIb_r,k3L%p"Bh)QgeU242jX[PdjAaOh)N:!Qu@PE1?D8e9?c'hEQ!CCQ9TFQmq3YXa&RX3[G6L6QZJkfaeu/;bn+3FQJ2R;N&`1O](n!*NPj3&JpZ47]cJGLI3b)EDK.4.Dk_6LE;rbCkI&n+YGC+II,7KJM,pB^k8C[\FuMeYs?mm<(&+`SrPJgLg'g$S+bUIUTt+9KQhR/d[?!n[fr9d4Dn2Z/VnW^M`u8b>9+m*AqP!e:t]sCT-o24j$fW'N>cq9%mN>66i?=0EcY%JEE[a)N_m"JIZ7#nONCQomb0>nr_TlUmIZZfSknr_Rs#s\scKiK6:"164-Y-S8[&`U)R4r;<WY]r6-SO#U[V[qCI"(mhh$B_,p>[n/!!Np=mFnR9`+#oQ\o#-(YV(0N2A9"a+W%N)G%!l3/!oj1EE=mfaF.c^2?q[klR-Y6V%N#KBpmUTp#W2Ed,h!4GcC*\frihhD8[;LINRed.piV\ZjBJMa9W#bN'C_:r:Z1s'A582l1^W#7-JTeJa]oR(RF\41U7*JX0qeXuoj\nBB.%4#^bAHTDS`:594J.$oJqQ2u%lY&YU;(7YI:HPQWb_1Cs,_^[]<<^f@kIqSsgbqailMNRm>qT-C-tim5%/(e;s!X.d=ta8S!VB*64n+$rb9]Wagj/bThf,VRjBkOm<Is\/K:WAB&i"Wj^h;1lMoTb.6m9@nLun&b]qKp\O,'/l@7"lPUb,0Jn![`K:&b"NGmc83NB[g1mpR\qV=4.3)`-6'da4"Qk?]Fo'>'D;'5Q0M6gq1_I9HUrY/V(ROY]8kT@H51?e21_5h\jD13:sYLOMmM^.*ab\gL6kO9SOebOj9DV4B'Q(SG:Ln2cNCOUqT&KANjrPsm$#-/+C[C,k3=LYi[NJUmM'UCfjW-)KJ9gnA*::bj</l2XR;U-&$7b>Q@iWm/ANS96R"M^O;s-c'\Jl\]M'\21RKj'*I]V%1"0,F@Y=Bu0J5j2r%BmdP@Bc>8MuPq\p3YS<GCVp=LrJ`^m_\b"\jL3%t>[@:Y<+CYC0E7@u<+:eGeK-U91F)jc71kL*_`=&/sBaAFp,1.K,p#N'L#_>LeXa.H<5_^#,*o(\\j0YM\2;R/3Or<S%m..jQKufWO0&JHK6$qF^'gn)0,<8P(JFFdOShZSqONmW/JUqW8P*#I4JCrqtZ2$Y(aPVM$"i!-)f:2%_p7Z;4hb-dK2f-`!!:mrJTi*TM.MVU?J.GJNKtNh_TY!iY*g$mj2O_UG.i7#sFco6\\HQrq=r$9jMq7*[,#%iZ%]g"7K<_EGh`,TK[OjO7M;0AiK:/]ORnAd>.X\+%RcrjP6!=fbL&0[NJt>YFlL3UA1AKS7]92jU9X3AR0+\>\W6$gmNq2SN>Ycn?lU3(2;q93Gg(9G:d5"+;-COc/'p\4D`#D/(keU39q)>)DlKCL*p"qRJ.oKb8_LZDmL$rD=16C]V07p"Q"1<:,&%i6K=&ukO_n7/$BnWAnQt7$HP33E$:WTKVXJFLceKsoA#N;["j:2t`+sBduh<`lkAq#id5u6gK08^R*!=i?7R#HR_ibF7#.:k"G`&B\7S+64Ar>J-clgn^P"@\#f=-q'J3'q@1Ff2AB05PMD8IfSi#$10NVb0[,:$ER=#MkV_YM4![a9.hL].aj^m!-3[#?#HH<s62;MD/()]GHM+26])"?(DH]&AeH>D'L(Xiq]u@T.,uDTl2[`U3Sa6P`14YoJL%[Hl6Um$D3iT6OJCtFiAu%`gN6F8PV916@;[dJ"^L82*p^@el:7`!gfR#hGE2d'M@F;oK1_CAcXlJ5r7hYn:?0/79_2/9W8l/(*]n+UDJ%_<;Lnu3oM!q6kWCN^lBJG2he-tLRR_WnAH"$T;`!BE9t_6'g.VHLtSgnIKDBur'5u)n+WHNFoSs]gB]%5J0OQJaJno79@2=!,?[aFZ^BJP98UhCK3+^a3rP4+P"TbhUJ!]1BSM-4#*4ak4\"sqV^C71crO;4K!j>+<TpQ10%U:a/K&K+r!!KpW9#mj3sCk\5Q<44q2DhG`oTZH1[f.Z3+&D2h7fafQ_YBFW.I'SkK$DhWgMqMJtJ"^msg]=r6.1Yf\#$dh;B#t33:53*c]c>/3@t6\qrtVA:(*J=Rspk^DKF`A/I[hf`]EH.aoXGXdm\,enqqu?hlu3F$IVKOpS\X!HsYQ=T/1=ekD(1h*IrBffY>U6-LAkhL),=7i&=eW!G`OF`86j8gqPcC=$0Y[($m2>SlSJnNM_/CK@1%ndWRn0=dNXPEX:"feOh)8TU#60"!4ei5^#!.a^#U;[\[Q%d"Sd]H-R<D+Fc'Hk%U/*O1K@!4.1CT'OLU7R(GHHZ_a6)tXH(i]^[YPrVJq\'(eHTI)'%pcFu.&:n:>j.k`mO:Qm=!0Loj[l1M44\HG/5YWTG]U@?tADb,kVul(BZ@**p(5Ee=5bo@PN;.rIkVNDS6Tb\d%`!W\cjM"<bd8XP(8:gZOGH#YZf5%5^R-]p?4bb8`NV4$$8ZAna8]n<c;4WQGaPE[Mu\TF/+5U_##=*_GH7i-m#23qJD1SG%"[?-LXN")6k^sq>u'5HrX%a@n'/W:6L3>1JYqDX!(9@9G9BX0PlO4&/q)nDXP:^;31Aul$0[[QG%aoD+c#R;h;<Oc?%1R'7[RY(o"6(,[;fd3V$,Zcl7TG/n@?[YcSW"iLuU$R2HE9V&6H^6c/LA`BTLXp`^<43k"a@L+*e\?QR(h7LL3IH@L$]-5Y;HD?k';(,aa4;&s8.^7LE[CZ2*8.hFd`XMt2eGeI)n1HbC]GOX"uQ;sTR@B-?6R7!_HCK91%]BY[]D4p?0R;=dh`!\1cGkJ1>t30n!5L`sqI0uD/E'&->Kj8@O75h5&ffjCul9OS!H0tVCCJ"n#\Ti^%tICQ0B*Z3KuI2pY@T4WW@dO@F:fS7-mk<])K3aOoTl7ldVHDm"C:AMW.nauOSn5+K28faPFmU!`Dj!j,@iJX!g!_XAWKDb`M:H+HGDXr4uX1]2U]Uf-Ss)V@0i^^5V1t.9r2+e?"a*b>Q=[X^Y^cB+MT(fmgA.!VPFrA0Eb7YdVrABQLIqFurTjjpRl$''.0S@I]i%'i*_R5^r)S0u;F$STrhJ]DRgn&O7NGt1_5\3_8.)r_$#a;!dSn(IYUg.2Z8uFG,OB--fR+)QM^%5fu(ImaS+_G@TO(tSOjHPtoTQ$04pErh0M_:)'o+(L=op[A52*N:`-jA?I%>=nO\Xl0ckC2.W7o@*5'>`LB8Z>2DG*mu3p`3b7<q@7@/WcOnIt]PGqS+B6dUr+&1+F62^;`<X>Y$j>0'`0bPiJ[,k1F0do=ObF"^$kWnpFVqF88WMcc4ClWUqUJeH/-JKnBL#j`=D,iCNdCAn6+Kg"V9Q=3$Z.Ed:2Hs'1>*-EY<lDKu"u4pb'j^eSes+:QLICDE7s.c;3&4/8c3.4%=UI[W<l<1-Iok]"Di*:YK$HIu$^A4Dr4$Sb"8Xl//l"Cf>`F:6UY'!U3jcqi(foiS8BqFrJ`o?bZ1K67rt+-?Ro'\fNN#0$D[Iib`JQcr"<_FJtW$2PF]YIl-1XjotVb-$<i)Hp^.nI.u0W>a%"G.W!"r*T>M%b0GC%)C\]L35WRhVO'(JY3qX_6P4EmPagf\_:cuUBAAhjV[iK-R[J7g"V;23=5):OJOeF4)9Odq2iqRZ222nZ.u;_15LC^kYg^V?uAq.I!060Gtr`^<[Tf!ZPuO'j2.@7$dl%a'mKkcK4b95lY3K:]\]I9N6633>k!7siZCjtKQXGoE/DBQq&TNKU6o0`%'i(O=9I:T;X1>qi1+7T91bNsdDXMh1NQZM/puG^9OfRJ!T5mMe7;<S!^rGnY>DSk7gkbVnQ]+`;R00.#44n#/q`@j=U"a\WW5B6QQ/BPd&uVc2lbG!l2;F7g^M`#)fV"pDE7[G_/X;))!E-)c7AAt5CCFca4/9m:*6`b5<Zl^ii[u%`>Wnl-gjp&O_rq8PG#RGp*9')-2tQ(pp:TYf"7!1HA(@?%sDVhDnJ>9F?!$Rf0=47G_Q7nDQ4+OrF32+AY->qN;+K,?d2"Yq+NP1P)$.=5H;"Fb"ch:;G'B]"Xim@9l=K/CJ[Tm+>7c>n]cMJ.57Xgc$t8eXY.[)VR#LqL-O(uDaIQm3!\%)*X].e*k/_PlB5M[["o;\P7D\#jC$q$Adc;*3^Cm./MkBJZ7T>d5],=hNq,(T>C;KI/t(#D,c!';iFDu'i2rN3A@@_rna;6U:U&nhdN<hbC+mrekV:RV@)r=6%"]-<'H30rl!'!;6)Ir=`HAX$L7dhpkuhOEm[[T-Qd0$cBpb9nB_5LmDgZ(Dl=<.ORWjnRZim?^GqX\Af)_D44#hC4X!_fmQ?ttHQggNo23g[_TGu5qm%ron,KhZo+#'r6]Zqe:JHcNCU@qeJPAR]"RT)P'd/aGqmafIP3OJFpQ(0h!:2cT;FBLekW`U"XS(mpXL6"4J"JS^VZB0&d9-@aL_kNX?\Wl%B:7qsmaj3t%U:5,42cladd,XKn_nY^r>Y!#_ame;H33;JG:,&KmofJY.TeZ^C)bT6M<)VYkDV+p0]kq[;UDY0*L^nCJ0UmcnoN@]/FU%%D&OMo,OmJV%-L`iskt8\)KFZu,f^o*fM7GbB"gm`)"AEVbRcZI/T(GO#52?6YlXkZUI95]En-VH1f.'dAXGKNJWr,\^)33e22R(G]SA]kTjVs3%Z<g7blhs6CY"AgjLQc-UP:M#$h<GMooKuBmCO&1e1^_6H-@hc8!L@%kG">\(Ne7'YPl,*B7m2AfMQRIW]&`A\Ld1n"MKqV8)U2D$P).9V_Nhh#'i85shKg`.dPTnX?'D5AhZc#b2(UbP(b5asi-s`1@bU>d.WTUATZ1CcdjT5Bh&X50Di$<;Lj:s&,3W$KBM3*l>_ao*OSBfBO1D.tSo6WPYtaQ"M@cnM0#W]+OIm0<rnWo<fJNYr(K,SOL<PVrQ@C>H*8[k84o!#j']*WJGXp(^DD"lr)=,0q5IN2'?Yj[E$2\?_q5Vml"C92bS)pURo@5r>r]D$2q4I<Vbd9pW6o>ZP`XN&dC*$d>;&%mrNJshgeU5>aK1MYtSHhDTFo55(+uo>?"H=Y6.)j\]/70)#m1[DhLu9:[OHRsp^XMu3#DQ)2>9@?RS]**c'0)\hiS+0f;Ffo7#jgO".4-Lr%4S^kD@n^U?]$;sRWr4!qlrSoq6KR#m*k0p>%=-M/3D/G!c2r48Z0Ej\YIE$flF3*?qn9Koon6*pCh`IZMiI?Sho0V$n4jiC7S8iW.!^`D2Af2T1rhi0i=)\3$)1?KB+N6P^r8bR\8K;/,_\lgZY#74[R*&R.c#/GkHsZ:q9.L)ZBp\Ju!MEM_aG_J;*tUI2^q4Rc:>i.2/bDEn#lE:`/EA1BZ^QmD!%!:3f?#9CLX9*_$Yg3:BA2+T<n9*_:=3__c^&O%^*]["=,F41`BnO*DJ#ZG!,Rq/6fB879ZX-E4ch)g$i7_VJhpf%pR:1?UE_#Fq<t2Ra#^/UL%Vb__A83A7N@FF0s"#k<.2S)l'DIP(*W>XP,iX4.:.\1HL](pI-rj0YFUDX6)j&2L^Qfb,]=g&$Mr<Q:/S]K>X#@25&KAjT68<NJ4U]#_):rhg6R=a,Ns(b;&U1L3?9!n-;T/\D:nGQ0eoGdA`_CDQXian&pBfEF4qFtN@N'(VBfkRksA0mC,K="eB!^H!k4n,t>oGAQC4:0`rU@HEr4M/J+$<j-2WV%cf,Qpo]$V&-JG0jrSL^k?9;jA2O38,sRogV_7hR>i.Fp4l6+B2]'.ikgIc9jFq>ATnA4'*,EBYO*L1N]Jol'*Yc81#\]#b\fPSM+/bUO4bHnB-jC(d>L'#,+`al7D`YcRgm>-I%H7K:YB*nknGjnPHhUF+Z!1i^SineaGLF0D#9_8U'GLP^IB=`A:BLY9NJ"%dXTs&=aD1GDVCC%#QBt^7IKJE)s]Jp+?$.^4q/bn'noI`m?;p_eIs_a=JoU)C;no(A:]n`l?ARr^QG?sVaT*g+@R)qiEZ\=ojuW`@_WJa_%(!<_h8l^XBh[phKM+0?s;c<5Oppd)Y+K2H6gd`SJMiCrrg9G_LahmTfp>]%_aB&hK$Tr0\5M>^533Hc4k#d(ZG>/A)L),35e;QCQUh8PX\S!#F/pX%'*,F^K$CZqTp2h$-=Is(]]<nM&^$4iZbB_]-k=VA'JTtDB="lG1r!#]O>R@H],@$>0Pm-N<j+s2V:CoCq16h>X?:BQCc,Y)VhDZA1Z2n.IM1tGi\(-Z7W&#hQ(]FBL4ogIB*ZPABF6(1.Nt8A0cZmMo\2TJKL0,X\kIBEjduoXJ%0DKl*1lIP1c=NR[%GgMi'6Ifp$^=S=!kQsLo^I*A\l;.FRQO2AnFE3K!smCMfmkfR1B=30\o+\R`33lMYkW]S/`DMo2@+[K=<4%#=8_5"?P`ieJ9nf<+tNM.JgBOBb0<\?EnKiEkZCJk)e.INd=2RH2JnH9]%i^W#Pb_6W8?S6]3r\)GWoM,V;Lf=Oe=HHJbG/2:YgIL$(acWS+oMoC&Fo.GI%Ks-ci5=VDIr-&/i#eSH/*6;ble"DfFc76+%*Qdac^5pcBmsm8pl+`/KWnTmX#D4N'7Hn`auV+r?r63a-Y2YS3oYG+@,m3POYDVr)`f)J/rf?GlDTg%s'jg!VAmlA"*9_8Q3P^SCfZA%^9!:VM8XDA8DTQKA)]P1,FdSl-mR//#BG?[oUFk(L_=Xn@K,1`j&@+`YP[/&Q>esgRXqYZ+t+'c?W2*6PdChX_pG\IqjX.QJU*f&_4jrTq+F/[<%'TFO0,,]gl?#io9qSnN?2*V5N;RAeq,DlnE<2S)8c)Ce_NTENRP_J=N2$\$)gWmlOm(ibeX7"=WM-VlS`aJ(;G/GP<@=@AUZe+Jo*aTD,m`!H.il@=fiBj2M%SqQYdptGqIgTRQ#aS&^>WP'8AV[gA)P`eG0RN)%7e51M'U4K;cVViLmd)$,i?M8=GJh>)&4tQcu=M/8+7dN.WgI^nuFNk$(m5J'85G<@EF#N>\X[3Vt_D6PG&<3,Ef-O[<KmP\+^MKQAJ(Gk6WfVBF-+;+f+q3i,`U6W7_Bp5!iEG`jHqJ4/A_`"Vod/hjp+.`TsckZMu_npXjUcbKFt9!1Y5:bY_C4^qS4E),Q*([grDoYE>lUkVqH!7K):]>%&s-?g[^>B$8nNofNb:cW(-mo.X4\)j&O>Ng/^6]C]d*.5n^Q-(OLUH='=/d/>FjJb_FB"YaPH8qj!?dgrIO3SKSd6K'Rl*^QuJp?Ar>$ikb2T[VQ;r5ep[[@07U^>(#ALRl'6aq'u,LW'(G!9uH@+P+k6/eI1h>_r(-ZSJEHO2a!7IE[=?K/mc$?M5@q:G2`45U2<5(:9TG$isT*c]N*Xg;aga8_#%e3%bNh<`9,ARt6/MdHAc:\%SZrAV55n_S]>3,f0h^b@bNKN$ib8*5@5Z7Q$>G#jS65qRF1<rmR'Cr7cKcLU`kH:2?,I"K+]On?R39'U'7rDmq,hD]'11b[KKim2%S>XpSg&6#d6NYLTQhrd#2M7.1+p%3ntCHnTCJR60M)gHn#R,@XTT6`>VrIq>X;_cBV4XW=-SbA?K2lTR;76OaVQQft=)V"3P[BT-"H,A-S=e+X*.,&*B6c"s.Gj`/(q-9tB.dK+<G`@(7!Z^ik@gJp?1ee5jklW,qg_4]&\onDUC]-,sfEP1OpF,#^rD-#*qr<^@ZMiIIB9ZnU^]"#PN?.Dmp#&'miG(B\+>kdJI-KfRS&=pI&,lCs4?C^MX(*%\J;Si9WLf$-Og`W;oL0Q?4uEN61h4sn.B]!mY:'#1K_.93I\KQfTffX^G5mje-ua86;0AuPLZVgjQS;"D*k_Nd58MTahLQ2!Yhp\E1dNaW6XW@ocr'&EhAn`Y]gZ%>[*R<3P3FH^"F(e:+!u08(s?_P1SH;L%)]:#Cg%+sPl7C[^?5?DgB&$MU3.V@,*3a&T-H9k9ITpN`^-1j)#H6e`D?8hQBnR1P@VC"PYs<[^:euT0,lH1^3`Rb?iJBQY3)=nFuX.W6Bre!=1?MJ.XuYclsNc%nAnQn,lX=<p;iHG:tHV`MH^K6i66c%1fS+?GJ\d&JcuDbP;6D?@B^tDNCBNZMdJUY9/UGEq#Hb(_?$"%ja1h#-.5dr]iU4JIf^,Q)Dp7do)*/?*[]eZNtPr049u<CJfZd,,BrrWG9D6;]4YPjHStu,Y8]9RU9%!$EM/4T1n?X`Mn.Un/TY(*7/Cm@FdfSl!0f;FmnA4!H<^dJT=h""aTT2cJ`*2#o!Tj<<ZZB:T9qcJ4&/_J*K+I$H#C8:HE?G`:E.9r=*L)\m`Y;?1p)as0P)H/)1*VO&qs.ce+nO^Ot^*$7?*LbofVK6+HNo;EY#eCHB3R:3G6#7fihsd+8':p0>F1*6L`Fl)=G5#8?AK_9_jH2p^Atl;[a5<ZFPAP=LX&!'[4qZ7<;d[-UM(%-.;VJb6NZ&nH#_-8,^pc;hk+FhI^64"-\d;?k"*cQ@t1<k:KA$*rqt$;j]<kdrJXpa\4Ld<tf<jM+.g[peQ0E67oK3^s=N^+;!G[?PW&N:U"Sd*6pcaf''F:e,mZIKH+_$,_[e"oMUA4;!lQ?WpcF=qJ[e\!HrNM'?Uk&?9CX'F+dBOM847>#+i=QR`VKW6U^FR$dmC!+Ltbjm"o:lZDS"D_PJ'CP&n,$#`:Lu"71lg,u[+JQM_=r.Nlao^gWkq51dpOZ:Z")=_>EC+@qFB75!fp^&V68)DZS."pBU*]dj/:Zj=t:A^"q=5ZSnL)Lh`Ad%i19d"l#RqWt$aHU=A:@%A1`4`0eGTD&X4#I_&M]J7@K;bJME2ub>@)<df&$A3X7FUkYO9S>2aP1BJ7Kh;N&>DVP_2<3-31H.^O$[=4C+)]n@FU1AP(-''`1MH\a]5_a]_c1&POSk1G'gO;4/1CqR\HmOcQ'W=DKh1u270'2)cr7s]&Z]7jeq;:FP`,qe-"!9p18ok9U:6uj4^<^;,WocFX-RRF#U%:7`66<N6%t#kJN/H-7TEs/r,FM00R9KQ)C6TD>+J=3phIi!&j>3uD;tEJ@o=+$SLRo"Ye['QH<TVKUlK&>)!dFL<^6467PR[A:pZC=MZ@/.`;Z@e4=mTsF5O5f;f;Ds=72fr:5^Wnr_Nfe2]CT$J5]UpV9h4]"K())1r2,J+Njn;p;[$hJ0(6VOXdbSK_8+<[5HHF].VDkQV2[a8Au!J<IslW98Lg<')84Z"X95C'Mjm4.WFn!D`1%'nAMH6p0kt94VdiI8buWUUU]I_\Yl0)A%]f2A5fe3D:aaD-Q8cc0`*O5pG396F;D(M@ghSgCRNX\V<-=X,SW7;),?pHJQglB%MBH?FYW5PT<'#>m]421TJ85L:Z]a#3JZ7o%B-U='>r(=AL<2OKr(1iJBR%:4I'4Wq]DW9=7:J2Q0DM$JXbGf3Q*9C3^>5kQdRs,!JlD!.[=Z[/$r%J+=/2f0I!J\>[dili=#sDH@tT#!RP1,i3^@qaU=8XcDm?19OG(UM0Q&j67PBc6>;J>>Af(ZnEpPZU4JO/h75/m!(a@&h;+t]Vbf"p(/P6\:8FdAn#%/Z%&qTO8=H[IJ0frgpBoi`A=%1l(/C!oieIPjqbXFZf&ZM5c^=%ugC2#kp\GCWd4Gt.r1(73:qk/o>\$tj@2mP".t=D1o?!u8Ga15eLq?2dL>^^Z'mMN:\.-e.XD!cfNl*IWSbd/Q^R(g++'89:A>i<P7!NaeIQj2Ak#u#HO\81mF:dHG.(I^JKS\tRpT$jf-/VQlSdMg3oSa^k"S!fdlYf]ED,,2!WWKfo#b0dEHrLEd[ApC-HX8/Qfc5p8fr.>YLaJ-T)oH'U6hVD3]G*:ZM2a<Le4]`rP&*M^q!-c[%.JPCrA;/+2e!@4;OeRk;r&>m@Hk`6.bLh5pr`I0OqgK<0cD=K#uDf_,S,>/4,D#Gi)VjM:6.#5d4kYp;\.<_\#,ZeGR]45XBc'o\;t,jE@O[.l&irtoe>%L`QB#fkdl"FV)sKZ^Kqoo7`6nr6qi`-$aO.pq`M4G8u/-4,OOS7prhl5g<fRcXaqD%Q$,:6(qM`i[dt8lD+585!.u,(8IA(G%QT4Pcm=!$W.H_Bmm5AP4DW&*#eeKB=gP&Lb#?/96gG-\26>+.@>N)K^e(Tuj2/^E.eBIZ?!p1`3$)$=WL2%K0N;7>qDe$3LN"4X1+_Nt"nALd7e<NbaNqL+5f9"Qq;'*dj<"G:rs?i"j)K^IJ!r?NUV`JV\W^_h2gt>If.=^6;7Yj\#:O^Y1uWhR$'Z89qg(7#;+!?_a3A6)4.6+sEQ>atLlr!Ha-%H\M7],T\:;&80)VYlZKMCHEq6\i-W4"Kc+q;7*cucb-JbPVq>PR.M4efO=ndk/!V>*CLW@7rrQmPc!%Ho=MM;W#7IJh1+9F/c:KDN*!g=*umiOd9P<2?a^aI]a$ABne3DGK/MN47Y3'QZJ'2;M,;U;H!hVLcYF;5-=HPfdmjQc!Y_aF2a-E%N/R+>j3VmV:'.d.O&2\=>*h>gppEq=IY:rF=&./99\<ELo4ofdN:kF'6[aub21?r;%K*jUHjZ>d4/`uq8'0[#o%:+84l4o4(SKL2Jf=FdYj4;7/7$fQ4P#iCVK*!rO10dH+!NCkAf*.3E(d6Dl8E[;0`cTo,o&!U8b6,:-T,JZ&GF8)TjIcN1C=e6=R+C-7d*&!!B?9BB0m7gE6Ss)>onBrlapMiB%Y;]d.;k`bT)&7+UrgUJ7b4oIQ;t=mG,kdl'!o[inUAm)pLhhsalmDYGR53ZLUmfl10iRl@G?Fs.6as3(CIYaJ@V'CD+?i5:2S^Tlkh:1ffHLY1Bj[iBGEE"oK%'JloskPBYtIPe>`5/6^#<1^IC9#5m\]1gp`4?*'k!2KFsE[a8H&XWY#KkUD1V8r-b(8p,n3&U/[G7kdu]HMRX-*u8=0.6\S5]FD1W*=]>CPBob?Cq(.>5^jQ+Cp&F.g06OF54llip,n<BUQq5g\:T+Te,$rgBCV%sno>K/AC->3qtIaapS;q]oP+LO`Vc?cgH3?N*=WBekt>2EAiYLtX&!DLsJbEPP]/!\Sme;H82<4'M8K7eb_KK?AmC:@?$Hra"B#D]pf'dQjK6;m7@a#_rQf:Chp07P@GEIVMP2[!D0VgI-UB41s,DO?dplkfS=.&Q5bOi.W@G(6\WM0I84hjo>=<jV_rrYp,/"1/1?9Xp5PHcZ5M%7jk_UFuC8F9X8L^I-6Og,JYV75adR!ZD8g-U-X%T[M;UmgX@t:Kd7E[1l:n>_3#rAKRuX4^'cOa,X)4bep1"G4E9Z!Z9g`T2KdBHuAt#>fSdu`2#;:,aK.-MZt`FLs_R\G(eHA&Y=uW5P:`LR!7>i)]RrGLB::(@S5GUi@'UuJuDltH(r1]#NYW]hlWmaCZ90UhF+p:pLNoWDgBiDV0+ATjZ=RDfjLH272'.<QDSFYY";T3/%B8eD]Vtq!9idJ$D:96Ln(5gC+4iMZ3E8@W#IG4$hVKS`St'+`Qlj@D`iCfZj,6-c$or]dBJN`h;Q]5[-/oUhgV9!2bn[sh,4kkcA/-7UZJ77"=jdP'n(1e]dFL1g\8nJ$0N]::$t:[#!PZ^Vi9+QR(3[ECO9L9%h+\_Z+jX:n(YrH*\gSqV8QS(:pocf#kc,'np'fB?Q[F)_,_^qK`_>Hdb4lr=X`Z26mhZS5rR?/pi7Ld1$GK;5i955l3LF9(o-oF52b29B5,N/bcW7lX1rj6_ARN[>shPPjqE1FWS!dF>:C<;j&QFoTLjPKUIR4\_J/-881:u?P,QbF46`6+NSY236_&%C=56_X,u(S7faT,?C>R.1'#ukiraQ#[A7N;b)%"e:CnQmVp<Q7F`8J[nA?,ZU^_l":Y^K6^J2*Q((6kG=[UEmS;]VFBY#sf",U"0.dd*R-.uSqP^90L'$*E%\M7l]pUWW_88j'4SrR'k)95`DL'GaDS[J!lP"q&HKpn$W4#_FC>pTl2e=-,C/eBm9q0CgOgD3//12I>0)(7EaY&ZMrE\dT3NUT^&M`EH_,Ij<M&p3G"G+W(2nD).sFrk(tgW`^k.J$27a5/(+Ob`4jn'i=a]&KbOs<T?#!rtGb!0W;LY@<&%$Jk',o/Ako??F6+q!K.i//Ms^61IN/#.9ml6k#a?hnM_lC@[5#kY.Z*D_bTlHOl/b<=5G;s#ZQFUUoWsT\qKZKJ08"8gh)Vu(;(-g2H+YiH8Dn.h%/hp'(sehq)4bF-[qY_XXcRPj!Yhr!4A*]\b6s5hY=oi"U,l_HS:lh:lgPqXsO'"aR>P17Q>L![h!AV=qUnFTrZL-`f[\c.""h7E5GKbG9/r!mHbGVr\nO**ZY>_M/r%D\/CL@9.#mJVgjC1')ag+H&]MLTkOLB,k3WJ?oqh.'lpZoFlA&PST._uCVs+:&=^>.f"4?UN#Q+Z6lAsZK\oBS9/"'jlukpCgu-N6:%J4c<.PckkeV#Rip7*bbJJb0%K_8k2Y`!j$#<qag&dBZYYY>4.^QD?9iB9JkNo;r[33T5&Nfuh/En']eKsGf\C$g.V._C'La,QU/p6$EHXq9Dj.D%nW]Jp5gqkOl@7\-b2aY!P4/jfqX"9+HI"d)YKrLN>T69";l;=T\Vo\f"iNXpc+`RPMN6/[.6iaR;C!>KsAXaqj(U/Id1eT`%7&N/[W=Mao_mV5`MX8oKGH7ffNY.k$rGVBM88/D,jnbhn3jXL[]?UaINP@Q/_<<HT5%qULcWk[SSsqka8)muOc1cKZ];1U5LFL?/C%Gm_I=mUUCC5*W)ilO^jZbZ)J*:Ei_H1B3"cs*[1o>2Yhib/>iN`-Z+;Nq)im;+5<BKZ]2Sb]6gTF<o5R6g+:#8sK8;1"i5k.gg5SOWN<t%kL_uiG?+1keH-n*rb8`2ZV'[`iP/n=G4P&dqt0t7&A6gKu:5S@"iRt2\9#Q'PDJpC8X=JgGL@5^:A=7eZ-ok5))PTe1ta\U+eqe%`-$lm&)s5$^78PD/f2#OJ4\%eIb/'^58\YO@dYE<;WTCtSBUf'rs4d-1>E,q\UA_FBsQi&E[,><%t!dV^VP4]i._1-$6S@K<e)Es;CaZi(&U&IZ5FAt$-(r!>O&JuO<6dO&;c=]^?B'VLMKTMrnGkTejbbt_sfg4jVEeWC?kOQ<ks(2PE<_B.j=r$q"MT@:opU'$CX06F3$k"Y5OQ`?I/@L[(+f5Y\VAmJ>(HfAHh>cu?.ut2!1osJp*%*@*,&OWQqhr1sQP_f]R0lja*LR*dpmH9TT++QUYO1Q#HC.T(+@7o6>lcDPk,Pq%s,scU/H74j_X5%0l=Ag^/-+on?p4TQ`>,PI9m<AqE')du:J*uQ>0t+a3]n0`\pc"n0R8-8&Ka5P6LT=*@tXp=9J<HG^>e*`g%(HiV;\E<djIT.B[%^pm&'sFdHScm<#Z4%j*7k2)?68jcT>pW-EF'bgC2aZjJXJ.s7-jQ*7arCc$'DPl=hmW3ht&kqe3/ICqGgWSMhMZ'-*$NI93^pP8Yi]Qe@ug6Um)2>@&?mD2O3A3V48d@Qs'4"`/^6hHm_5R@u6,<G^K-?PsRO^ej,P1JsZq+),?92o,^L*/M)$"!KR_$VaT\^oO7eo\O`\-7`dB8k(Xf<=KSb\K60=S:@@Wmb/<)HLA+S$b30FaTh9>i_4pYi&BJOU>hXK-\6)B30653Xs'#hmZPL!\caQ/BR5pl+CB-COEtL<LN$<Vp3qmrN"sfiCS2a@JXYP73LqthhriOpFunE"==qXk;ftD88neM2Xe<XZ8aD#c.fjY.-/7SIW872)"$'6Z,`"TO<$4,?0h((07]H#.:'f^Wg3q$4M[OJQpI/[LJO,u!cfIIdW*(d^eT6hCb2GffE@(N\X2ZA-qn:%MZ9'lbB#&"`L@OB<e-b,Y6d`d[mU3GuYCoCXZu?),5PJQL$dp*rc$Q[Yk+jJ:#oQrR,RqHoEGa,3"EF09hnWkoNc0"RO65sg>e>8;lg1E_)5+kNid)8<ODcBL@[>,[^Eh#^R"b+R0XJu@'1-(NEp8ssi0G?^49FJ=nii4IVAf.[eE+L.NI.ln%ZLnsEmnCOD75#UWOjHM;f^'ZZiF'q*)/H]f=;kJ_R*b4hQO([nMN"_Fn;Q<Wp$bH*#$Jl4`\g%dI#_eh'J^WLB+IF`fB"$(oXZX+D.JNOcg4g^KrTAZ!X(^%f2#1@cTl8M2=F)ZD'H8p:>'CWnRl$Bn*N+Sk!+Pe2=E!?$AFiUtMp!b.3saHR/o=dZ)?&M7W>m?%P!^]6bn*"i\t+Pf7P%[u+2aU<sVu(l@<W?usUoB9j\P81lHP!q>n@i>qo&`gp?r].A7<ZaWFl<Q<?/J%03bVdYD+,Q`Il^@n`;P?YmLin0e-!VQj<kSVd1nVVG;4eZMIjn9=[-m[hE>^hg/jQc`dj`hVbc`2]f3uOIo1;>MeWONT0oNSf_9:#6Ri@W*/k%INTb/pnDL7<0l=Lieqe%j"0iR<KL5Kap"k@/lOPXC)_$dVJ3rH-Drc`*`XSh`]tqO7b*[3KoHbfUhD8*fO<J\sRSMRI*n^:a.seYaS`F=iFhr'PF>rc197LoU+/YuY7!d$Za%ee,koW0+Y_;f*h1hjh#niV$l4r!.TXUg>k`T$a(g^m\(Q,Ek.nAg,A>N#orFqBUG)3\l*OeP'qPVTXW<G+]ibEsR'h1m!q3lZ$].;l"!DJJC$SpZ)>#\MIgpjV2D49Vh"1$dJf^8JjuC\mbL%fgTuUn4&;i"Da=A##EgNku5o(La1pi'kZ&K8p(EQM0c.<'X>9C@'A9fiK.Vu4X08PC&7)^aRIMiBn?9>=``Y$7oo5(/Q\@5l,H)mIO#LQfNPuE2[5hmVpe:jW6Q9s9!D)gRXHcEnk;fi3'M3U"$FJ:XJ!#T5JXi['rNUT*&jbnWi[6Wce$O'S,^!8e1skAcTQ7KI8-lg)_:f,WjY5_QBRTNh3*<-0d<3tUB1$kP!QhfMTaBHVIG+]p!O2$f#,M"**h8>kbk1+c'B2W#:=;r`CODqP@NP7Xch"/Kn.6Ef\`%tiZ*=_kl^]n.#3<hOK>Z/r;Lqk2GSY^dVGaDLR5-HG@jl%<!8tos+J3s_r+oGq6ksXFboUiB\=rI^!IM`>83c0"k'gZS(,%+j:cK05j%UjmZ+ip@&gfF\T"e_:j(CuTV\qo&4a#n8&(XFmtaC#?[SS=1;CARrij+/gdprMp,,(.:uT.uZ0nE%W4H@6+tY`"O3BQPJ4bg9"tiu,=fr*DLQ_P?,U=HeX9"9Fngd^%PWeuoiL3eJ>42t0(2:\bf5@`A^-QBJ$OoN*#:?@NR,3nC-0S.2$(ZC,Gr)h?0nF(Y_"@UC*W%*]fVX[:c4k"+.+7CQ]Ho6Z.&rj#]lJWS@43m(K"V`BDrp%!_:Yk*NI7KCMZBaMnKBQ*P6A8IcrcjE0h!E@O-_2D=;lT82%XL_2L;U=;Hq<=9faN=>MO25E5cMf>ofUn2c;RYO-<KIhG+X9@AYs$BCg\Y`+]jXh,6jWRX6*4?C`LZ$(VWOK=geC/BL_S;+T*;=cM=.GT!?f>_rnqG$-rlO"Lellj6to'h0Qd9-sEpqEZ@kA_8`]3;NR(OWIuJ4SP".C>]g:jD<IB+7cX)3<cu(?YlhJ=8sC#34tt'B!ZaSH;WIZBi>#pC"0-X%g&16(r_Fj8a95E-FcL?T1T@V-8JJ6]oL#tmV9md=aBdmAn?,rAD$0W=MuKEL^<iU_<L`(JR0])+AH2SBKW="W9l["EdkI$Q2!&j7uhp6^LRutJp=LPW$)Xih:ca%+AedpXfn51M?YR\&W<lY7A`?1YtY9upe8j"F_IP^n>4_o!MH+[7j0"t.q>Vs5CaXh^%FX1QL5YtqkDZl#@;4@$KuS?Eg9JXF66s\H"h[nOCH)#Eh9*r7ra,WG5U=bH28`-I,YLFEj:%u-tj./Z8]-+lV)hYL\np%0'''V-_!=YK&7DbE@ReIB;h"8[=?>;$$6Ymdohl/4W;,GB&9oUs2%@11(&$TF>1oS7r"m1hO@[Tn:$Ba-TBF(pd;>p#Nb82V$73!b4")!CqM]HBe#if[$m*P5-(W[E\!MF(g/?;%\H;+Ll<+nib`)sC16ER^QD-EPVe`njM+5[Yf"5.[Ml[5hN_]uK?P$Yceu3LId*,+^Lo,dUQU[e%!_s\(sYaG`:(gnXn*V\6OV]?qn7`]^o5Fm?R"T0A6&lW'Kq?kHFt<Ln-j=c$Or2*NK0+STU3R6<W^r_lS5>4]eE*JieH],?i>k-.9>[AV4i1!=%kE(K6$':T?5i(RDP7D8cb$6!%OA"Ugohtk[tn#!PA&\hgpV3RW11jpm$fR.Kg+[gK@Hu3tlZac"VE0+6I;:\C/PO=-QsV9je&OM,c_p3:AF*90ng<rl[nX6a7H-2D-\iKMMR(IYS'FD(``hbrX&5q>p>S'5DW0Z(DI!LV!O%lZ3K;ob<0M>-3ura'\=jd<+![Bs99s%VIcV'g!;:kEFs9^&]ib1>a\-drg.AK(*(&6udUHQ!dqnjDc):%-L`Xm78qfh1#tP;NnPng=Y/@a?LKWr*gQAgBZ&c`o]S@8>*Zg$E+AdGfk:WV>S1a(rFGUO?b^(dqIr2h$qYq'qeVmIE[^6C'ZsGS8s,4YS%9Zp`,qi:r;Zr9)(?"HXGC:9U>qPr2b,XbY:<mETllC2CG)H,6X;L[0E2E6Ga7UoGJ-OQ6Mhjk$Gp:(qD5s$shY^rI50eN!rO#o'9eZLIVX6m(ioe4guHe.[5\<9`nI#]F=BF;$$Ya@]d]ReT*:]^D'bkl9f=X4YME(R35437-8s+7$d3L:X=CLU:%461Jg$j/NRE5-2opkX:L(s.3;I[Wo79Q@H`Z3I^-X#8h(($QlMMtNOOS!3!<CW/>#8+1;8m(bgDkE,YPY9jQ0"^SmpMCW<-IU#PVtKW6&>%=U])o0D1^M$5qOn`JAerP-D[J)a6DkD#n5Posrm_9oTR?@Lp@4.neO%l$G#^@@>FK<tkL)B>sqC22WHM38k[[Kl[hLC@LN'-ec[ZC.Pild1M9YM82d1(\N>W$7;6P;_nDu!mmX\m@[S,ngG8*ap)<?b?pt8fkQb^g&N$[os4]@D=&:0Tt>F3!<.8^2qgq3TXK*s)K6/b'2rV8/R0N?m$`U2b8\LJ$-5GG'^)a<JFph>'Kfpng/F<4.4W]8)RM_e?cB1<SR'[Pot?dCqq62`%mL"U=/57t:Hr?^;G4B/PHhUcQJd#0BCCuk0+\P5>?pa);R;,-%)0;h7[GU,Za!Z/Kq]io16?:JWOfEA8j(D$H'=lIQ6Qa'AQo[F/)m#d2pYN9__'qm/4R!JDa4Cg1$i">c4reoaeDQWi^M-$9?Y)`JfZ%5Bb7LLKemDdhn/9n8&m(]hZ4,?IR5e`\&"clD5TgdI&54,Z\:Ms,_^I\A\uZ+Gr16LK%'GY*M8D(VRR;uCTg@<TDU,UDT2kVT_5q078qmsEbpW?l,Y<K?&G+tHmQ\BI%uS>gmFNW`i6gV5%kN^d"m+iGG5_#'IV8L(:-*f</?iAY1_ASN!W]MM+0uL[.J/fU#b(`IqAAl<hE.+fuQ]\)Rg?u0Wt<l#YkjffB0'S>ti34Ac,LF/"W7F,fK"^1"T@CL#L/)oppR+ie=2=:c^oUI/5-6M7,7T2Lr!sitD1g[Erec[`@:+d2iP;hN4=K+-?%n\:Z^*)%8NGeR^u,_o6WtmjHe"9CVZ)f9PNuh>8)g68(gm"%7Z(^HC!(^*dP4r-)FBqs6*'OAl#!o[8O*#`9BuSq^[ijW=(:4CM\bS2$A:f5[WJALf@V</.i:?.s"B*e4^1^Rm_FZ@VU]Kk1`ZfLpFIbOoA#8brjDWYGd>8no3nE+sX]cX0o1a`7t+[;$&"DhT1sTmaO\!]Unq1<RSu<Ar`KKEZG9-_n0nkb*%Gj%:u91;<Iore*XT<7/m!-OUE1#/`Pef.bB"A4sdBM,:<N<^aPcOBE&/qcBtF,kO$bd)!OpX^3HD?AGlBBGV,KaKt.p>LM8\0hK/Ya;Gc'+.hhZcd`V[;,BXiNH/^Ce5">?eKW;Z'm)4$k6dn3\H+*u_Fn_N43C$<Wam$'@@Xp'h^BE0.3aVMV_fUiL<EA%p6R6`prS%WHm6'YMXu,Y%K\nY2TNOS:E]kV*@d!8H$blm`Ma_$*+k:PII;nDV(Zj;j7<fTo:WVle/!W#abc.n3dCb'bq60R9p@+2[lWoG-2R^%[_]!CHEqh%;LB&WrcN>jCZ5f8nM7*UViT&)m<pGZ?C@gTB+Dbn@B!>D,U3Deqf%H\,^dTk:G:JRm3D!<fK>rQ5rPNY\,$AVC*ZS4\K?g[)Z&h=kgrqJ.-cWX64+%Q@7]SU!ZL1-B^QYA6)ol_)85Q9]C"FiTB9S'<AB7XZ%?Eh*s'o>^@Hr8`5Kfu@?$FJXeI"s"USk5/oV2<XgcWDU/]p1V&Os+q0),rdoS;O>XqbX"AMluEfanQkf3KV51GY)#jlaKIA8o/J9Gg)mf7&rh!$h*_("isDuaAZZY?&sa8%e;BntCCU8lf)c'[";.`["u'JD3O_-]jHA-'O;o8g&(4n+QPGB3hUV.rcsjH!&$E.'29<>#h.s8=h!>WN9Z_??C3$f=7d"W+K\9EaVCoIFXT9fj=@Jjr0>`'!e=m!L"qE48TY?5OA0Fd^lu7\mku<DnE's1`t],*WND\"cOm:pdcLca"VWET-k-:460QP<)$4>o]8!"6iOrCfCB5lPI]7ikfo4mQ8<FB+Sa9VG!0]>LoCu0GCf,C=&LJrCN&XEYa8Y7JBKVU+&rYEEJ`Ns*nF4oW,tX=U(\%!@De;[oi1kcBK%kao7b#aIgRJ0GH#6,Q[U:_'=&gqOb97PMNN?,(:6B59lObHj-!5G),L'9$7\bOTIr*j]8Zh\LoW$6a-p&&DJ)YR/,CTF<SLa!0JN";.7_&>6AFL($,QbPC+_[&TFgd9)cq>,13Q0ZQXVs;mmnbVQ]TkJ=D,B1oXY,j9Zc]p-oQ,bPsar8pQrGh-QEHX`!HlQ9Wk&UIK"C$>NM-_K$E,h;#17`6'EZ?EkdJWk4,O8+\B9dU!4QigAeY`l0*:SRIUs^I;5F)pE!*?[Xni2<O1"_dGNO5tt37@"'8i<][,<AoolLRAp,i/fH932hRL#P(`]NqNlCsHf.uO5oVZi>LsHJbJ?D1j#n0&>S<f1bBUk3A@\2'q)k5/l#hs6`=_Zs95du[TcE<<AgqPIeL<`q#+$4S'3e1h-\QNZf9bsKg)`,.P9Q?iYEE["9G's8Yg6*<oW\SjoHd#\U6eePf>@$Vpr;iP4f*NEAS\IZm&;]I1@rI$X%N$uBuO=,$pE0pR"C4TYicIf)\?JJ3E(i.:HVP\nbP[m_%*tCde925bKOPSW(G?J$Eu&4OjBGu$Cb_&6l\Q,h9]2`T(f@"2`.l-P\7^k,,cJk.-13_]_Iu+Rse0G7.%dg!L(l]%Dpu"Bih/`RS?R"4;#V&BL&sWqBKX"3VT$9\1_q[*6#-Z]FW6E"*\p>Af-]fnFAYscii[o2E3(6[!Br,Xjp*s2.U;H[N<38k'd<P-8s(@N-n@Ebl^%PRie.mOhIH@O%1EMBAr[6U2$OB[JY&<YAZ59%G[UC$3a*EqR_t$UiVc1KATkbp_%QV?8!isA:DZCGu%ZV7;&^/8aq"DMM@=/NPDIPHSLPbPSr&H[hCu>DbC!d69G]I_f-_RT-FJO8KaPi%40POB(A>!KV;lflfHf#lX3W=#os\Tcl4WCaA>T?NQhi"/+sh2fQfpoV*X@K;V'V4'nh8d)NJVE.><L7>J-TKl'/7MllUNOn?UWj?DqhT%XKC)0/k?h]id0ed?&tK^FT<hK]/)&8QnC\hZ#+E2XNAY1Nah8b^$7T$NGs#F:%+IZaU,-Z>]0$!5:F("Z]TR(\F:!%pgF@!@bp?@fE9+U-(!`OtLQlg)e'FeIaLfmbKTa!<LYHd9g@BIRVNak(cMg(_!Q=m##\D0:lghWVrd'b57:-ohoiKjsj$*J)5\lf;sp]VmFl+A;Q*(\Z+.;Eq+eH9hj/eone"!q:,&uJKtiTN`HkPGE4@`B"`NjJdVlZQ+)K=Aq`h=Q`+"KbO,(X3fn#I$J@tf>#bn.A\%<N)E,N*YQ0pAigZCXoCfO,s##V0n,iXZ(83laH[m>*K$[B?U:p&l/pPB\H(G/=o:%:n>ZbCCNDK7H@U95p>28NNB(@N<9snLn(&RC\=r-r*3<2p84AV4n"K)$79lMPWO]YOpS_M8@D_lgEC=n5P:e.i1.IM+3;?M=a7[kSAn'3<#*9bQSE5cH.B]?2UbfDt_KerVUFl#iQ_.^\U7t/n)*LLcj;fFHo2`AgZD.*YVI5%qN]$Fa'`ZaN$[!K!*3WZ]91qu+I]m@$MI)&b5C)uYa`gS'd^t42IT)C.<DR*9`Y#]$]lFJC4Z(sA$+mVljBQM@[3^YGb;<s=brt>&^1/8F3B>9gDF$>I*m7ZC/O'?G9KBPu["g<PURB5T6jA^p&1"[9]MQ+^:P=M?Z^A7sRE$5jilh>T)F2?"CJ'pp;"8:\nPg\2ZFhk^2;b>GXM6duObHL>.DTtKFfj\F&YQ2[ZQCt%aj`sV$dlY47H%Z9qM[tGjZ8rf*E<O9/rKlX"b;8GPDd;)K0I71N#HgCr?peH&?kf.K>W@<?))$EtT^Rh#NB[9%*mu?!K$C^-=c&dKq&8es0Nn3iM[9--(\XpVH63XpI=UVELI9F]OCduK\i/bMaV@F%5F^pHP(0*+3(IuOWiRmgMG.?9R>I$ibglhQ!NFQ2SSr_n$X'=t<7FG@g<Pfk6%1@,Pb5@dDu;?B,<eJWCfAaJ'S)5jjJ.AEl."dYZ@C0n816Etd=,dEK.kg(]*!u>2AroH)DDQ"cZU!_e\4qYA!erq"6M]3a-+3/C\_6rOT6uZ"Js(\Z6&eLA,+fb;-:ei-Eo$$')c,"b-(DR;`XAe\C"s5rJ@Fu2QS3C2#N%6SCX,1Nknst+t3-XS"=kmK[r:d=95jqE[*HrV\LqK#:lP`-]+Lu;CD,9L.IUeXo+A"ZoGWH*a9uPS,%!;\^gg"ZHGa-\A@KnU?DeU@kr,k6+EtO^`O>IXoY&pjMFno)9-"XF8l?=\UQOJYhkZf?oVKY`nd3BbYL)#:>>iU*r$thSG>A'CR_-XPCNT?^HPT2L`cm+$8%\@!#Fr3j2leh\<qeY_u6!lNPT:/So>ggNZM-pkK6*_l&2H@gD_p=gRJ[oTYO69N1'ZGauX9PK$ZTW?7!?/`L@B>p7A0&nB50=C6gf@;U_=F1][5HQU%@A\cuRh&XOA**N@!S*1'B#CA8:j)_/'K.(3#>IqnZO/hZS@Pkh!kLF9F=6t`HWS/7Gn$k:O[IUe,k,AI\1_fW:5JhI.XGhHUC6+f&Wd!\(Pa2`/58An,ZaN#-]\`k`*2^7!qZ)\FdYhE/Joasu'+NLuWp9B1++JS+`3-/(ZkopIVq4SJe`g%l_;tr'DP6Q-Ki\%P=HADpbM$%flrP1-9]aQ)VdO=U\3btI<[.2qmqTfR89W"+5<>!dsH@t"hP]>-P1cpE@^^a)7N%7V1&[#Du6qID(!!!!)]=]);return f;end,V=function(r,A,c)A=(-0B1010__1__1+((r.TK((r.cK(r.R[5]+r.R[0X1]))))+c[0X2320]));c[31743]=A;return A;end,_5=function(r,A)local c,t,f=(7);while true do if c==0X7C then return-0X2,f*A[7]+t;else if c==0X3a then c=(0X51);if f==0 then return-2,t;else if not(f>=A[1])then else f-=A[0x7];end;end;else if c==7 then c=0X3a;t,f=A[0x30](),A[0b110000]();else if c~=0X51 then else c=r:C5(c);end;end;end;end;end;return nil;end,cG=function(r,r,A)r[11]=(A);end,c5=function(r,r)if r[0X2e]~=r[18]then else return-0X1;end;return 56080;end,E5=function(r,A,c,t)c[0X35]=(nil);(c)[0B0110110]=nil;A=0B1000110;repeat if A<=0x46 then c[52]=function()local f,V,Z,y=(36);repeat if f>36 and f<0X76 then y,f=r:T5(y,f);continue;elseif f<51 then Z=(0X0);f=0B110__011;else if f>0B110011 then V=r:c5(c);if V==56080 then break;else if V==-1 then return;end;end;end;end;until false;repeat local f;for V=0x56,0xc7,0B11 do if V<0b1_0__11100 and V>0X56 then r:Q5();continue;else if V<0X59 then continue;else if V>0X59 then f=c[0b101_010]();break;end;end;end;end;Z+=((f>0b1111111 and f-128 or f)*y);y*=0X80;until f<0X80;return Z;end;(c)[53]=function()local f,V,Z,y=0b001__10__010;repeat f,V,y,Z=r:Y5(f,y,c);if V==51455 then continue;else if V==-0B10 then return Z;end;end;until false;end;if not(not t[18107])then A=(t[18107]);else(t)[3294]=(-0X65Fb9081+(r.R[0X2_]-t[0X1785__]-t[636]+A-t[0Xd97]));A=(-0X004d5F__61dD+((r._K((r._K((r.cK(t[27928])),t[0x67Cd])),t[31659],t[27928]))+r.R[0X3]));(t)[0X46__bb]=A;end;continue;else r:w5(c);break;end;until false;return A;end,f5=function(r,r,A,c,t,f)if f==0B1110 then t=(c%0X8);return A,0X3_678,t;else if f==0B101011 then A=r%0X8;return A,34679,t;end;end;return A,nil,t;end,tG=function(r,A,c,t,f)local V=0X59;repeat if V==0X64 then break;else if V~=0X59 then else V=100;if not(t>0B110)then c=r:AG(f,c);else if f[0x3__8]==A then else c=r:lG(f,c);end;end;end;end;until false;return c;end,NG=function(r,r,A,c)A[c]=(r);end,i='rea\d\u{069}32',hK=function(r,r)repeat r[7]=(0XC0);until false;end,X5=function(r,A,c,t)(t)[0B100000]=(0X0);if not A[11279]then A[10786]=-0X26_2CD__3Ab+(r.cK(r.R[0X1]+A[6481]+A[0x5D0E]-r.R[0B1000],A[636],A[0X1854]));c=2516319314+((r._K(A[0X4115]))-r.R[0B100]+A[0X5D0E]-A[0X613e__]);(A)[11279]=c;else c=(A[11279]);end;return c;end,mK=function(r,A,c,t,f,V)local Z;if c>0X27__ then c=r:FK(A,f,t,c);else if not(c<104)then else for t=0X1,#f[0x2],0b11 do Z=r:iK(t,A,f);if Z~=-0b01 then else return-1,c;end;end;if V then r:qK(A,f);end;return 0XBb41,c;end;end;return nil,c;end,PK=function(r,A,c)if A>0B11_11000 then c[0x3][0Xf]=r._;return 39179;else if not(A<0B11010010)then else(c[0X3])[0XD_]=r.C;end;end;return nil;end,e=function(r,A,c,t,f)c[0X00F]=(nil);f=(0X1F);repeat if f>67 and f<0b1101101 then c[0XE]=r.k;if not(not t[0X67cd_])then f=(t[0X67Cd]);else f=0X96+((r.rK((r.cK((r._K(t[0x00_59__52__])),t[0x27A3])),(t[24894])))-t[10377]);t[26573]=(f);end;elseif f>0x1F and f<67 then c[0Xb]=({});if not(not t[6228])then f=(t[6228]);else f=(-4257743064+((r.pK(r.R[0X02]+r.R[0X2],(t[24894])))+f-r.R[0X1]));t[0X1854]=(f);end;continue;elseif f<114 and f>0B1000110 then(c)[15]=9007199254740992;break;elseif f<0X29 then(c)[0X8]=(A[r.h]);if not t[0X5952]then f=(-0X144E+(r.gK((r.uK(r.R[0X9__]+t[0X1785]))==t[31743]and r.R[0B11]or t[0X2__320],(t[0X613e]))));(t)[0X5952]=(f);else f=(t[22866]);end;else if f<0X46 and f>0B101_001 then(c)[0X0__d]=A[r.i];if not(not t[26790])then f=(t[0X6__8A6]);else f=(-0X1BC93FBF+(r.gK(r.R[0B110]+t[0X27a_3]+t[6228]+r.R[0b1000],(t[0X613e]))));(t)[26790]=f;end;continue;else if f<116 and f>0X6d then c[0x9]=r.b;(c)[0b1010]=A.readi16;if not(not t[0X2889])then f=(t[10377]);else f=(1710985558+((r.YK((r.cK(r.R[3],r.R[3]))))-r.R[0X2_]-t[6021]));(t)[0X2889]=f;end;continue;else if f>0B1110010 then f=r:D(f,A,t,c);end;end;end;end;until false;(c)[0B10000]=nil;return f;end,LK=function(r,r,A)A=(r[0X0042ed]);return A;end,j="\114e\u{061}\x64\11716",d=function(...)(...)[...]=nil;end,J=function(r,A,c,t)c[0B100010]=r.L;(c)[0B100011]=(type);for f=0,255 do(c[0X12_])[f]=c[0B110](f);end;if not A[0X31a__4]then t=r:f(A,t);else t=A[12708];end;return t;end,c=bit32.band,kG=function(r,r)(r)[0X3A],r[0x19]=-0x3e>r[0X30],r[0X33];end,W=function(r,r,A)(A)[0B10001]=(r.readf32);(A)[0X12]={};end,mG=function(r,r,A)A[r+0X3]=(0X9);end,nG=function(r,r)(r)[0B1],r[0X36]=r[0X3_e],0x17/0XE<(242<0b10110111);end,Y5=function(r,A,c,t)local f,V;if A==0x34 then return A,-0X2,c,c;elseif A==0X32 then c=t[0X34]();A=0X69;return A,0Xc8Ff,c;else if A~=0X69 then else f,A,V=r:r5(t,c,A);if f==0X0_8e18 then return A,51455,c;else if f~=-0B10 then else return A,-0X2,c,V;end;end;end;end;return A,nil,c;end,hG=function(r,r,A,c,t,f)if f==0X1__1 then A=(#c);c[A+0B1]=(r);(c)[A+0x2]=t;f=0B111100_;return 0xf__5F0,f,A;else if f==60 then(c)[A+0B11]=0B100;return 0X108f,f,A;end;end;return nil,f,A;end,b5=function(r,A)local c,t,f,V=0B111101;repeat V,t,c,f=r:h5(V,A,c);if t==38497 then continue;else if t==-0x2 then return-2,f;end;end;until false;return nil;end,o=function(r,A,c,t,f,V)V=nil;c[0X3]=nil;t=(3);repeat if t==3 then(c)[0x1]=2147483648;(c)[0X2]=r.N;if not(not A[24894])then t=(A[24894]);else t=(-5718002006+((r.pK(r.R[0X3]-r.R[0B100__0],(t)))+r.R[0x2]+r.R[0X5]));A[24894]=(t);end;continue;else if t==6 then f,t=r:E(A,t,f);continue;else if t==0x28 then r:x(c);break;else if t==0B101101 then V=(f[r.Z]);if not A[31743]then t=r:V(t,A);else t=(A[31743]);end;end;end;end;end;until false;(c)[0B100_]=f[r.F];c[0B101]=r.N;c[0X6]=r.QK;return t,V,f;end,_G=function(r,A,c,t,f,V,Z,y,z,D,n,G,x,o)local H,k;for E=0X17,0b11101000,0x2F__ do k=r:H5(Z,E,t,f,c);if k==46570 then break;else if k==0X7Cf_7 then continue;end;end;end;c[1]=G;for E=1,y do local y,e,I,P,X,i;X,e,I,i,y,P=r:J5(G,I,y,E,X,e,i,D,V,P);k,H=r:CG(c,E,t,X,y,f,Z,V,n,e,P,A,i,x,I,D);if k==-0B1 then return z,-0x1,o;else if k==-2 then return z,-2,o,H;end;end;end;o=(nil);z=(nil);return z,nil,o;end,FK=function(r,r,A,c,t)t=0x27;for f=0x01,c do(r)[f]=A[62]();end;return t;end,S5=function(r,r,A)(r)[32]=(r[0X20__]+A);end,a=function(r,A,c)(A)[23431]=-0X6159d051+(r.CK(r.R[7]+r.R[0X6]+A[10147]-c,(A[0X613e])));c=(-67108895+((r.rK(A[22866]-A[0X67CD]-A[0X613E],(A[24894])))+A[0x68A6]));A[26312]=(c);return c;end,S=function(r,r)(r)[11]=(nil);r[0xC]=nil;(r)[13]=(nil);r[0B1110]=(nil);end,s5=function(r,A,c)c=(30+(r.YK((r.uK((r.TK(A[0X435D]-A[27928])))))));A[0X45cc]=(c);return c;end,L=string.byte,x=function(r,r)r[0X3]=({});end,z5=function(r,r,A,c)if A>0X44 then return-0X2,A,r;else if A<83 then A=(0x53);(c)[32]=(c[0b100000]+0X4);end;end;return nil,A;end,r5=function(r,A,c,t)t=(0X34);if c>=A[25]then return-0X2,t,(r:u5(c,A));end;return 0X08E18,t;end,VG=function(r,A,c,t)if A~=0X37 then t=c[0B110100]()-0X5D95;A=(1);else A=r:xG(A,c);end;return A,t;end,iG=function(r,A,c,t,f,V,Z)local y,z;if V==0XC_6 then(c)[A]=(A+Z);return 18636;else y,z=r:jG(t,f);if y~=-2 then else return-0B10,z;end;end;return nil;end,y=function(r,r)(r)[0B111]=4294967296;r[0x8]=(nil);(r)[0X009]=nil;r[0XA]=(nil);end,H=function(r,A,c)A=(1710985470+(((r.cK(c[26573]+r.R[0X003],c[0x5b87],c[26312]))>r.R[0B1]and c[26573]or r.R[0X4])-r.R[0X2]));c[0X411_5__]=(A);return A;end,TG=function(r,r,A,c,t)A[r]=t[0B1011__0][c];end,Q5=function(r)end,rG=function(r,A,c,t,f)for V=t-t%1,A do r:uG(f,c,V);end;end,i5=function(r,r,A)r=(A[3479]);return r;end,IG=function(r,r,A)r=A[0X2a]();return r;end,rK=bit32.rshift,v5=function(r,A,c,t)(t)[0X2e]=function()return(r:m5(t));end;if not(not A[0X4e0A])then c=A[19978];else c=r:O5(c,A);end;return c;end,W5=function(r,r,A,c)A=c[0B11_0001](r);return A;end,d5=function(r,A,c,t)t[0X26]=error;if not A[0X50b3]then c=0X3a9B6910+((r.YK(A[8985]-A[23431]))-A[31659]-r.R[0X6]);A[0x50b3]=c;else c=A[0X50b3];end;return c;end,ZK=function(r,A,c,t,f,V)local Z,y,z;c=55;while true do if not(c>1)then r:oG(z,t);break;else c,z=r:VG(c,t,z);end;end;f=(t[0b00101010]()~=0b0);V=(nil);for D=0X1c,0Xb6,0B110_000 do Z,V,y=r:NK(V,D,t,z,f);if Z==3239 then break;else if Z==-0b1 then return c,V,A,-0x01,f;else if Z~=-0X2 then else return c,V,A,-0X2,f,y;end;end;end;end;A=t[0x031](V);return c,V,A,nil,f;end,n=function(r,r,A)r=A[26312];return r;end,B=function(r,A,c,t,f)t[0X1__1]=nil;(t)[0X012]=nil;f=(35);while true do if f==0x23 then f=r:K(c,f,A,t);else if f~=0X26 then else r:W(A,t);break;end;end;end;(t)[0B10011]=A[r.q];return f;end,y5=function(r,r)return r;end,fG=function(r,r,A,c,t)for f=0B1001010,0B1_00001__11_,61 do if f==0B10000111 then c[36],c[0X30]=A,r;break;else if f==74 then if(-22)^c[0X1]then(c)[0X36]=t;end;end;end;end;end,Z5=function(r,r)r[0X29_]=setfenv;end,k5=function(r,A,c,t)(c)[43]=r.g;if not(not t[0xd97])then A=r:i5(A,t);else A=-0x67+(((t[27928]==r.R[0x2]and t[0X2320]or t[24182])==t[0X27A3]and r.R[0X2]or t[26312])+t[0X31A4]+t[12708]);t[3479]=(A);end;return A;end,s=string.sub,RG=function(r,A,c,t,f,V)if t~=115 then V=A[0X5][f];return c,55878,V;else c=r:XG(c,V);end;return c,nil,V;end,CK=bit32.rrotate,m5=function(r,r)local A=r[0Xc](r[37],r[0x20]);if r[0B1__1011]==r[11]then while true do r[0B11011]=-(-0X74);end;end;(r)[32]=r[0X20]+0x2;return A;end,I5=function(r,r,A)(A)[0X7]=r;end,v=table,N5=function(r,A,c,t,f)f[0X26]=nil;f[0B100111]=nil;A=0B01011001;repeat if A>100 then(f)[0B1_00111]=r.wK;break;else if A<0X073 and A>89 then if f[0X19]==f[0B100011]then if not(-(-0xD))then else local V=65;while true do if V==0X41_ then V=0B10_1100;f[11],f[0X3]=0X73,(f[0X1]);else if V==0B101__10_0 then(f)[0b1__0111],f[18]=f[0B1101_0]<=f[0x23],(0XfB);break;end;end;end;end;end;if t(f[0X25])~=0X1C1f__5 then local t,V=0b1100101;while true do if t<0x5f then t=95;if f[23]~=f[0x3]then else return-0B00_1__,A;end;elseif t>0B1011111 then t=0x0__;V=f[4](115189);else if t<0X6_5 and t>0 then f[0x15](V,0,f[0X25],0,115189);break;end;end;end;(f)[0X2_5]=(V);end;if not c[0X5E76]then(c)[17245]=-0X5C+(r.zK((r.rK(c[0X1f70]+r.R[0X2],(c[0X2319])))<=A and c[26312]or c[26790],c[11279]));A=(-0X3a9b68c7_+((r._K(c[0X2c0F]+c[0X2a22]+A))+r.R[6]));(c)[24182]=A;else A=c[24182];end;else if A<0X64 then A=r:d5(c,A,f);continue;end;end;end;until false;(f)[0X28__]=(nil);return nil,A;end,j5=function(r,A,c,t)(t)[0B101001]=nil;A=(0x31);while true do if A==0X5C then r:Z5(t);break;else if A~=0B110001_ then else if t[6]~=t[0b11001]then(t)[0X25]=game:GetService('Enco\x64i\u{6E}\x67\z \u{53}e\u{72}vic\101'):DecompressBuffer(t[0B100101],Enum.CompressionAlgorithm.Zstd);end;t[0B101000]=r.M;if not(not c[0X6d18])then A=c[27928];else A=0X16+((r.CK((r._K(c[10377],r.R[0x7]))-r.R[0X5],(c[0X2319])))<=c[0X435D]and r.R[5]or c[0X68A6]);(c)[0X6d18]=(A);end;continue;end;end;end;t[0X2a]=function()local c,f;c,f=r:b5(t);if c~=-0B10 then else return f;end;end;(t)[43]=(nil);(t)[0X2c]=nil;return A;end,bG=function(r,r,A,c)c[r]=(A);end,cK=bit32.bxor,sK=function(r,A,c)A=(-0X4d5f619__C+((r.zK(r.R[3]-c[28608]+c[26790]))-c[0X6__5E1]));(c)[2118]=A;return A;end,t5=function(r,r,A)r[9]=(A);end,U=string.gsub,PG=function(r,r,A,c,t)c[0B1_0][t+0X2]=r;A=0b1011_0__11;return A;end,g=bit32.bxor,qG=function(r,A,c)if A>0b10110_1 then return-0B1;else if not(A<0X3B)then else r:kG(c);end;end;return nil;end,x5=function(r,r,A,c)if A==0B1000__011 then c=r[0X13](r[37],r[0X20]);return 0b1110,c;else if A==0X113 then return-0B10,c,c;else if A==0XaB then r[0B100000]=(r[32]+0X8);end;end;end;return nil,c;end,wG=function(r,r)return r;end,QG=function(r,A,c,t,f)local V;for Z=0X37,0x9b,20 do if Z<0X5f and Z>55 then(f)[0x2]=A[0B110100]();continue;elseif Z<0B1001011 then c={};continue;elseif Z<135 and Z>0X5f then V=A[49](t);continue;else if Z>0X87 then for y=1,t do local z,D=0B10_001;while true do if z==17 then z=(0B111100);D=A[0X34]();else if z~=0X3c__ then else if A[0X6]~=A[18]then else for n=0X63,0B1111111,28 do if n>99 then if A[0B11010]then A[15]=-25>A[0x2a];return t,-2,c,-(-0X6);end;else if n<0B1111111 then if A[0x37]then r:pG(A);end;end;end;end;end;break;end;end;end;if A[0B101010]==A[0B1]then elseif not(A[22][D])then z=D/0X4;local n=({[0X1]=D%0X004,[0B11]=z-z%0X1_});A[0B10110][D]=n;(V)[y]=(n);else r:TG(y,V,D,A);end;end;elseif Z<155 and Z>0X73 then r:cG(f,V);continue;else if Z>0X4b and Z<0b1110011 then t=A[52]();end;end;end;end;(f)[6]=A[0X34]();return t,nil,c;end,kK=function(r,r,A,c)if A<163 then(r[0X3])[2]=(r[5]);else(r[0B11])[0X3_]=c;end;end,DG=function(r)end,yG=function(r,r,A)if A==0x68 then r[27]=r[0B110000]~=0X001__2;else if A~=36 then else(r)[0X32]=0B11110011*0Xd2-r[0X38];end;end;end}):X()(...);																																													
																																												
