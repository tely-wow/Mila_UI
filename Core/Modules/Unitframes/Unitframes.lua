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
    self:Tag(name, "[name]") -- Use oUF tag to display the unit's name
    self.Name = name

    -- Health Text (Current/Max)
    local healthText = health:CreateFontString(nil, "OVERLAY")
    healthText:SetPoint("RIGHT", health, "RIGHT", -5, 0)
    healthText:SetFontObject(GameFontNormalSmall)
    healthText:SetJustifyH("RIGHT")
    self:Tag(healthText, "[health:current-max]") -- Use oUF tag
    self.Health.Value = healthText

    -- Power Text (Current/Max)
    local powerText = power:CreateFontString(nil, "OVERLAY")
    powerText:SetPoint("CENTER", power, "CENTER", 0, 0)
    powerText:SetFontObject(GameFontNormalSmall)
    powerText:SetJustifyH("CENTER")
    self:Tag(powerText, "[power:current-max]") -- Use oUF tag
    self.Power.Value = powerText

    -- Apply unit-specific styles if defined
    if MilaUI.UF.UnitSpecificStyle and MilaUI.UF.UnitSpecificStyle[unit] then
        MilaUI.UF.UnitSpecificStyle[unit](self)
    end
end

-- Function to spawn a unit frame
function MilaUI.UF:SpawnUnit(unit, name)
    local frame = oUF:Spawn(unit, name or ("MilaUI_"..unit))
    if frame then
        MilaUI:print(string.format("Spawned %s frame.", unit))
    else
        MilaUI:print(string.format("Failed to spawn %s frame.", unit))
    end
    return frame
end

-- Register the style with oUF
oUF:RegisterStyle("MilaUI", SharedStyle)

-- Set the default style for new frames
oUF:SetActiveStyle("MilaUI")

-- Spawn Header for Boss Frames
-- This tells oUF how to create and manage boss1, boss2, etc.
local bossHeader = oUF:SpawnHeader(
    "MilaUI_BossHeader", -- Unique name for the header frame
    nil, -- Template (can be nil)
    "boss", -- Visibility condition (show when boss units exist)
    -- Attributes for the header and its children (boss frames)
    "showPlayer", false,
    "showBoss", true,
    "showArena", false,
    "showParty", false,
    "showRaid", false,
    "point", "TOPRIGHT", -- Anchor point of the header
    "xOffset", -150,     -- Horizontal offset from anchor
    "yOffset", -150,     -- Vertical offset from anchor
    "maxColumns", 1,     -- Arrange boss frames in a single column
    "unitsPerColumn", 5, -- Max 5 boss frames per column
    "columnSpacing", 10,  -- Spacing between columns (if more than 1)
    "unitSpacing", 10    -- Spacing between individual boss frames
)

MilaUI:print("Unitframe module loaded and style registered.")
