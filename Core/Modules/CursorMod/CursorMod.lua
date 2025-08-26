local _, MilaUI = ...
local MilaUIAddon = LibStub("AceAddon-3.0"):GetAddon("MilaUI")

-- Create the module if it doesn't exist
local CursorMod = MilaUIAddon:NewModule("CursorMod", "AceEvent-3.0")

-- Module variables
local cursorFrame, cursor
local config = {}

function CursorMod:OnInitialize()
    config = MilaUI.DB.profile.CursorMod
    self:InitializeDefaults()
    self:CreateCursorFrame()
    self:RegisterEvent("PLAYER_LOGIN", "OnLogin")
    self:RegisterEvent("UI_SCALE_CHANGED", "UpdateAutoScale")
    self:SetEnabledState(config.enabled)
end

function CursorMod:InitializeDefaults()
    local defaults = MilaUI.Defaults.CursorMod
    
    for key, value in pairs(defaults) do
        if config[key] == nil then
            if type(value) == "table" then
                config[key] = CopyTable(value)
            else
                config[key] = value
            end
        end
    end
    
    if config.size == 0 then
        local cursorSizePreferred = tonumber(GetCVar("cursorSizePreferred"))
        if config.sizes[cursorSizePreferred] then
            config.size = cursorSizePreferred
        else
            config.size = 0 -- 32x32 default
        end
    end
    
    if not config.lookStartDelta or config.lookStartDelta == 0.001 then
        config.lookStartDelta = tonumber(GetCVar("CursorFreelookStartDelta")) or 0.001
    end
end

function CursorMod:OnEnable()
    config.enabled = true
    MilaUI.DB.profile.CursorMod.enabled = true
    self:UpdateCursorSettings()
    self:SetCombatTracking()
    if self.cursorFrame then
        self.cursorFrame:RegisterEvent("PLAYER_STARTED_LOOKING")
        self.cursorFrame:RegisterEvent("PLAYER_STARTED_TURNING")
        self.cursorFrame:RegisterEvent("PLAYER_STOPPED_LOOKING")
        self.cursorFrame:RegisterEvent("PLAYER_STOPPED_TURNING")
        self.cursorFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
        self.cursorFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        self.cursorFrame:Hide()
    end
    hooksecurefunc(UIParent, "SetScale", function() 
        self:UpdateAutoScale() 
    end)
end

function CursorMod:OnDisable()
    config.enabled = false
    MilaUI.DB.profile.CursorMod.enabled = false
    if self.cursorFrame then
        self.cursorFrame:UnregisterAllEvents()
        self.cursorFrame:Hide()
    end
end

function CursorMod:CreateCursorFrame()
    cursorFrame = CreateFrame("FRAME", "MilaUI_CursorFrame", UIParent)
    cursorFrame:SetFrameStrata("TOOLTIP")
    cursorFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT")
    cursorFrame:Hide()
    
    -- Create cursor texture
    cursor = cursorFrame:CreateTexture(nil, "OVERLAY")
    cursor:SetPoint("CENTER")
    
    -- Initialize tracking  states
    cursorFrame[1] = true  -- looking state
    cursorFrame[2] = true  -- turning state
    cursorFrame[3] = false -- combat state
    
    -- Set up event handlers
    cursorFrame:SetScript("OnEvent", function(self, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end)
    
    -- Define event handler functions
    function cursorFrame:PLAYER_STARTED_LOOKING()
        self:ShowCursor(1)
    end
    
    function cursorFrame:PLAYER_STARTED_TURNING()
        self:ShowCursor(2)
    end
    
    function cursorFrame:PLAYER_STOPPED_LOOKING()
        self:HideCursor(1)
    end
    
    function cursorFrame:PLAYER_STOPPED_TURNING()
        self:HideCursor(2)
    end
    
    function cursorFrame:PLAYER_REGEN_DISABLED()
        self:ShowCursor(3)
    end
    
    function cursorFrame:PLAYER_REGEN_ENABLED()
        self:HideCursor(3)
    end
    
    -- Show/Hide cursor functions
    function cursorFrame:ShowCursor(n)
        self[n] = false
        if config.showOnlyInCombat and self[3] then return end
        
        local x, y = GetCursorPosition()
        local scale = self.scale or 1
        self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x / scale, y / scale)
        self:Show()
    end
    
    function cursorFrame:HideCursor(n)
        self[n] = true
        if (self[1] and self[2]) or (config.showOnlyInCombat and self[3]) then
            self:Hide()
        end
    end
    
    -- Store references
    self.cursorFrame = cursorFrame
    self.cursor = cursor
end

function CursorMod:OnLogin()
    -- Register movement events
    cursorFrame:RegisterEvent("PLAYER_STARTED_LOOKING")
    cursorFrame:RegisterEvent("PLAYER_STARTED_TURNING")
    cursorFrame:RegisterEvent("PLAYER_STOPPED_LOOKING")
    cursorFrame:RegisterEvent("PLAYER_STOPPED_TURNING")
    
    self:UpdateCursorSettings()
end

function CursorMod:SetCombatTracking()
    if config.showOnlyInCombat then
        cursorFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
        cursorFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        cursorFrame[3] = not InCombatLockdown()
    else
        cursorFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")
        cursorFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
        cursorFrame[3] = false
    end
end

function CursorMod:UpdateAutoScale()
    if config.autoScale then
        local width
        if GetCVarBool("gxMaximize") then
            local sizes = C_VideoOptions.GetGameWindowSizes(GetCVar("gxMonitor"), true)
            if sizes and sizes[1] then
                width = sizes[1].x
            else
                width = GetPhysicalScreenSize()
            end
        else
            width = GetPhysicalScreenSize()
        end
        self.autoScale = WorldFrame:GetWidth() / width / UIParent:GetScale()
    else
        self.autoScale = nil
    end
    
    self:UpdateCursorSettings()
end

function CursorMod:GetTextureInfo(index)
    local texture = config.textures[index]
    if type(texture) == "table" then
        if type(texture[1]) == "table" then
            local sizeIndex = math.min(config.size + 1, #texture)
            return unpack(texture[sizeIndex])
        else
            return unpack(texture)
        end
    else
        return texture, 0, 1, 0, 1
    end
end

function CursorMod:UpdateCursorSettings()
    if not cursor or not cursorFrame or not config then return end
    
    local size = config.sizes[config.size] or 32
    local scale = self.autoScale or config.scale
    local texture, left, right, top, bottom = self:GetTextureInfo(config.texPoint)
    
    -- Handle potential atlas textures
    local atlasInfo
    if C_Texture and C_Texture.GetAtlasInfo then
        atlasInfo = C_Texture.GetAtlasInfo(texture)
    end
    
    -- Get color
    local r, g, b
    if config.useClassColor then
        local classColor = C_ClassColor.GetClassColor(select(2, UnitClass("player")))
        if classColor then
            r, g, b = classColor:GetRGB()
        else
            r, g, b = 1, 1, 1 -- fallback to white
        end
    else
        r, g, b = unpack(config.color)
    end
    
    -- Set texture and size
    if atlasInfo then
        cursor:SetTexCoord(0, 1, 0, 1)
        cursor:SetAtlas(texture)
        cursor:SetSize(left or size, right or size)
        cursor:SetPoint("CENTER", top or 0, bottom or 0)
        cursor:SetScale(size / 32)
    else
        cursor:SetTexture(texture)
        if left and right and top and bottom then
            cursor:SetTexCoord(left, right, top, bottom)
        else
            cursor:SetTexCoord(0, 1, 0, 1)
        end
        cursor:SetSize(size, size)
        cursor:SetPoint("CENTER")
        cursor:SetScale(1)
    end
    
    -- Set appearance
    cursor:SetAlpha(config.opacity)
    cursor:SetVertexColor(r, g, b)
    
    -- Set frame scale and size
    cursorFrame:SetScale(scale)
    cursorFrame.scale = scale * UIParent:GetScale()
    cursorFrame:SetSize(size, size)
    
    -- Update game cursor size if enabled
    if config.changeCursorSize then
        local cursorSizePreferred = tonumber(GetCVar("cursorSizePreferred"))
        if cursorSizePreferred ~= config.size then
            SetCVar("cursorSizePreferred", config.size)
        end
    else
        local cursorSizePreferred = tonumber(GetCVar("cursorSizePreferred"))
        if cursorSizePreferred ~= -1 then
            SetCVar("cursorSizePreferred", -1)
        end
    end
    
    -- Set cursor freelook delta
    SetCVar("CursorFreelookStartDelta", config.lookStartDelta)
end

-- Configuration functions
function CursorMod:SetTexture(textureIndex)
    config.texPoint = textureIndex
    self:UpdateCursorSettings()
end

function CursorMod:SetSize(sizeIndex)
    config.size = sizeIndex
    self:UpdateCursorSettings()
end

function CursorMod:SetScale(scale)
    config.scale = scale
    config.autoScale = false
    self:UpdateCursorSettings()
end

function CursorMod:SetAutoScale(enabled)
    config.autoScale = enabled
    self:UpdateAutoScale()
end

function CursorMod:SetOpacity(opacity)
    config.opacity = opacity
    self:UpdateCursorSettings()
end

function CursorMod:SetColor(r, g, b)
    config.color = {r, g, b}
    config.useClassColor = false
    self:UpdateCursorSettings()
end

function CursorMod:SetUseClassColor(enabled)
    config.useClassColor = enabled
    self:UpdateCursorSettings()
end

function CursorMod:SetShowOnlyInCombat(enabled)
    config.showOnlyInCombat = enabled
    self:SetCombatTracking()
end

function CursorMod:SetChangeCursorSize(enabled)
    config.changeCursorSize = enabled
    self:UpdateCursorSettings()
end

function CursorMod:SetLookStartDelta(delta)
    config.lookStartDelta = delta
    self:UpdateCursorSettings()
end

function CursorMod:ToggleModule()
    if self:IsEnabled() then
        -- If currently enabled, disable it
        MilaUIAddon:DisableModule("CursorMod")
    else
        -- If currently disabled, enable it
        MilaUIAddon:EnableModule("CursorMod")
    end
end

-- Debug function
function CursorMod:GetStatus()
    return {
        enabled = config.enabled,
        texture = config.texPoint,
        size = config.size,
        scale = config.scale,
        autoScale = config.autoScale,
        opacity = config.opacity,
        color = config.color,
        useClassColor = config.useClassColor,
        showOnlyInCombat = config.showOnlyInCombat,
        changeCursorSize = config.changeCursorSize,
        lookStartDelta = config.lookStartDelta
    }
end



-- Ensure module is available globally for debugging
_G.MilaUI_CursorMod = CursorMod