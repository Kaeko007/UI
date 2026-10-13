--[[
    SpinachUI — Example Usage
    loadstring or require depending on your executor
]]

local SpinachUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/.../SpinachUI.lua"))()
-- OR if running locally via executor file system:
-- local SpinachUI = loadfile("SpinachUI.lua")()

local Window = SpinachUI.new({
    Title    = "My Script Hub",
    Subtitle = "v1.0  •  spinach",
    Name     = "MyScriptHub",
})

-- ══════════════════════════════
--  TAB 1 — Combat
-- ══════════════════════════════
local CombatTab = Window:addTab("Combat")

CombatTab:addSection("Aimbot")

CombatTab:addToggle("aimbot_enabled", "Aimbot", false, function(state)
    print("Aimbot:", state)
end)

CombatTab:addToggle("silent_aim", "Silent Aim", false, function(state)
    print("Silent Aim:", state)
end)

CombatTab:addSlider("aimbot_fov", "FOV Radius", {
    min     = 10,
    max     = 500,
    default = 120,
    step    = 5,
    suffix  = " px",
}, function(val)
    print("FOV:", val)
end)

CombatTab:addSlider("aimbot_smooth", "Smoothness", {
    min     = 1,
    max     = 20,
    default = 5,
    step    = 1,
}, function(val)
    print("Smooth:", val)
end)

CombatTab:addSection("Target")

CombatTab:addDropdown("target_part", "Aim Part", {
    "Head", "Torso", "HumanoidRootPart", "LeftArm", "RightArm"
}, function(val)
    print("Aim Part:", val)
end)

CombatTab:addMultiDropdown("target_team", "Ignore Teams", {
    "Red", "Blue", "Green", "Yellow", "None"
}, function(selected)
    print("Ignored teams:", table.concat(selected, ", "))
end)

CombatTab:addSection("Info")

CombatTab:addParagraph("Aimbot Notes",
    "FOV defines the screen radius for target lock. Lower smoothness = faster snap. Silent Aim bypasses camera direction.")

-- ══════════════════════════════
--  TAB 2 — Visual
-- ══════════════════════════════
local VisualTab = Window:addTab("Visual")

VisualTab:addSection("ESP")

VisualTab:addToggle("esp_box", "Box ESP", false, function(state)
    print("Box ESP:", state)
end)

VisualTab:addToggle("esp_name", "Name ESP", false, function(state)
    print("Name ESP:", state)
end)

VisualTab:addToggle("esp_health", "Health Bar", true, function(state)
    print("Health Bar:", state)
end)

VisualTab:addSlider("esp_distance", "Max Distance", {
    min     = 50,
    max     = 2000,
    default = 1000,
    step    = 50,
    suffix  = " studs",
}, function(val)
    print("ESP Distance:", val)
end)

VisualTab:addSection("Chams")

VisualTab:addDropdown("chams_style", "Chams Style", {
    "Flat", "Neon", "Glass", "Wireframe"
}, function(val)
    print("Chams:", val)
end)

-- ══════════════════════════════
--  TAB 3 — Settings
-- ══════════════════════════════
local SettingsTab = Window:addTab("Settings")

SettingsTab:addSection("Config")

SettingsTab:addParagraph("About",
    "SpinachUI — dark executor UI library. All settings are auto-saved to SpinachUI_Config.json via Save Config.")

SettingsTab:addButton("Reset All Settings", function()
    print("Resetting...")
end)

SettingsTab:addSaveConfig("MyScriptHub_Config.json")
