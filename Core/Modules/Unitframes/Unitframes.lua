-- Modules/Unitframes/Unitframes.lua
local addonName, MilaUI = ...
local oUF = oUF

-- Ensure oUF is available
if not oUF then
    MilaUI:print("Error: oUF not found!")
    return
end

MilaUI.UF = {}

-- Shared Styling function for all unit frames
local function SharedStyle(self, unit)
    -- This function will define the common appearance (size, textures, bars)
    -- We will populate this later.

    self:SetSize(200, 50) -- Example size

    -- Basic background
    local bg = self:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(self)
    bg:SetTexture(0.1, 0.1, 0.1, 0.8)
    self.Background = bg

    -- Placeholder for Health Bar
    local health = CreateFrame("StatusBar", nil, self)
    health:SetHeight(35)
    health:SetPoint("TOPLEFT")
    health:SetPoint("TOPRIGHT")
    health:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    health:SetStatusBarColor(0, 1, 0)
    self.Health = health

    -- Placeholder for Power Bar
    local power = CreateFrame("StatusBar", nil, self)
    power:SetHeight(15)
    power:SetPoint("BOTTOMLEFT")
    power:SetPoint("BOTTOMRIGHT")
    power:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    power:SetStatusBarColor(0, 0, 1)
    self.Power = power

    -- Name Text
    local name = health:CreateFontString(nil, "OVERLAY")
    name:SetPoint("LEFT", health, "LEFT", 5, 0)
    name:SetFontObject(GameFontNormalSmall)
    name:SetJustifyH("LEFT")
    self:Tag(name, "[name]")
    self.Name = name

    -- Health Text (Current/Max)
    local healthText = health:CreateFontString(nil, "OVERLAY")
    healthText:SetPoint("RIGHT", health, "RIGHT", -5, 0)
    healthText:SetFontObject(GameFontNormalSmall)
    healthText:SetJustifyH("RIGHT")
    self:Tag(healthText, "[health:current-max]")
    self.Health.Value = healthText

    -- Power Text (Current/Max)
    local powerText = power:CreateFontString(nil, "OVERLAY")
    powerText:SetPoint("CENTER", power, "CENTER", 0, 0)
    powerText:SetFontObject(GameFontNormalSmall)
    powerText:SetJustifyH("CENTER")
    self:Tag(powerText, "[power:current-max]")
    self.Power.Value = powerText

    -- Apply unit-specific styles if defined
    if MilaUI.UF.UnitSpecificStyle and MilaUI.UF.UnitSpecificStyle[unit] then
        MilaUI.UF.UnitSpecificStyle[unit](self)
    end


end

-- Register the style with oUF
oUF:RegisterStyle("MilaUI", SharedStyle)
if MilaUI.DB.global.DebugMode then
    print("[Mila_UI] oUF MilaUI style registered.")
end
oUF:SetActiveStyle("MilaUI")
if MilaUI.DB.global.DebugMode then
    print("[Mila_UI] oUF MilaUI style set active.")
end

-- Spawn Header for Boss Frames
local bossHeader = oUF:SpawnHeader(
    "MilaUI_BossHeader", -
    nil, 
    "boss", -
    "showPlayer", false,
    "showBoss", true,
    "showArena", false,
    "showParty", false,
    "showRaid", false,
    "point", "TOPRIGHT",
    "xOffset", -150,
    "yOffset", -150,
    "maxColumns", 1,
    "unitsPerColumn", 5,
    "columnSpacing", 10,
    "unitSpacing", 10
)
if MilaUI.DB.global.DebugMode then
    print("[Mila_UI] Boss header spawned.")
end
-- Load the castbar module
if not MilaUI.DB.profile.Unitframes.Castbar then
    -- Initialize castbar settings in the DB if they don't exist yet
    MilaUI.DB.profile.Unitframes.Castbar = {
        enabled = true,
        -- Copy default settings to DB
        defaults = MilaUI.CastbarDefaults,
        units = MilaUI.UnitCastbarDefaults
    }
end

-- Load castbar module
loadfile("Interface\\AddOns\\Mila_UI\\Core\\Modules\\Unitframes\\Castbar.lua")()

if MilaUI.DB.global.DebugMode then
    print("[Mila_UI] Unitframe module loaded and style registered.")
end
