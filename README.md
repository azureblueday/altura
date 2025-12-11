# Altura: Next-Generation UI ❄️
Altura is a new UI library for roblox

**How to use**
1. Copy the loadstring:
2. Paste it at the top of your script as "local Altura = LOADSTRING HERE"
3. Enjoy

## Usage Example:

local Altura = loadstring_here

local UI = Altura:Create("Altura V1")

local catch = UI:Tab("Catching", "rbxassetid://ICONID")
catch:Show()

UI:Section(catch, "Catching Features")

UI:Toggle(catch, "Magnets", function(state)
    print("Magnets:", state)
end)

UI:Slider(catch, "Magnet Radius", 0, 25, 10, function(v)
    print("Radius:", v)
end)

UI:Dropdown(catch, "Catching Mode", {"Regular", "Advanced"}, function(selected)
    print("Mode:", selected)
end)

UI:Keybind(catch, "Activate Catch", Enum.KeyCode.F, function()
    print("Keybind pressed")
end)

UI:ColorPicker(catch, "Hitbox Color", Color3.fromRGB(255, 100, 100), function(c3)
    print("Color:", c3)
end)
