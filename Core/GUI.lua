local _, MilaUI = ...
local MilaUI_GUI = LibStub("AceGUI-3.0")
local GUI_WIDTH = 920
local GUI_HEIGHT = 720
local GUI_TITLE = C_AddOns.GetAddOnMetadata("MilaUI", "Title")
local GUI_VERSION = C_AddOns.GetAddOnMetadata("MilaUI", "Version")
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0") or LibStub("LibSharedMedia-3.0")
local NSM = C_AddOns.IsAddOnLoaded("NorthernSkyMedia") or C_AddOns.IsAddOnLoaded("NorthernSkyRaidTools")
if LSM then LSM:Register("border", "WHITE8X8", [[Interface\Buttons\WHITE8X8]]) end
local LSMFonts = {}
local LSMTextures = {}
local LSMBorders = {}
local GUIActive = false
local Supporters = {
    [1] = {Supporter = "", Comment = ""},
}

local MilaUI_GUI_Container = nil;

local function GenerateSupportOptions()
    local SupportOptions = {
        [1] = {SupportOption = "MILA AND ALEX DID IT!!"},
        [2] = {SupportOption = "BEST UNITFRAMES IN TOWN"},
    }

    local RandomIndex = math.random(1, #SupportOptions)
    local RandomSupportOption = SupportOptions[RandomIndex].SupportOption

    return "|cFFFFFFFF" .. RandomSupportOption .. "|r"
end

local PowerNames = {
    [0] = "Mana",
    [1] = "Rage",
    [2] = "Focus",
    [3] = "Energy",
    [4] = "Combo Points",
    [5] = "Runes",
    [6] = "Runic Power",
    [7] = "Soul Shards",
    [8] = "Lunar Power",
    [9] = "Holy Power",
    [11] = "Maelstrom",
    [13] = "Insanity",
    [17] = "Fury",
    [18] = "Pain"
}

local ReactionNames = {
    [1] = "Hated",
    [2] = "Hostile",
    [3] = "Unfriendly",
    [4] = "Neutral",
    [5] = "Friendly",
    [6] = "Honored",
    [7] = "Revered",
    [8] = "Exalted",
}

local StatusNames = {
    [1] = "Dead - Background Only",
    [2] = "Tapped - Foreground Only",
    [3] = "Disconnected - Foreground Only"
}

function MilaUI:GenerateLSMFonts()
    local Fonts = LSM:HashTable("font")
    for Path, Font in pairs(Fonts) do
        LSMFonts[Font] = Path
    end
    return LSMFonts
end

function MilaUI:GenerateLSMBorders()
    local Borders = LSM:HashTable("border")
    for Path, Border in pairs(Borders) do
        LSMBorders[Border] = Path
    end
    return LSMBorders
end

function MilaUI:GenerateLSMTextures()
    local Textures = LSM:HashTable("statusbar")
    for Path, Texture in pairs(Textures) do
        LSMTextures[Texture] = Path
    end
    return LSMTextures
end

function MilaUI:UpdateFrames()
    MilaUI:LoadCustomColours()
    if self.PlayerFrame then
        MilaUI:UpdateUnitFrame(self.PlayerFrame)
    end
    if self.TargetFrame then
        MilaUI:UpdateUnitFrame(self.TargetFrame)
    end
    if self.FocusFrame then
        MilaUI:UpdateUnitFrame(self.FocusFrame)
    end
    if self.FocusTargetFrame then
        MilaUI:UpdateUnitFrame(self.FocusTargetFrame)
    end
    if self.PetFrame then
        MilaUI:UpdateUnitFrame(self.PetFrame)
    end
    if self.TargetTargetFrame then
        MilaUI:UpdateUnitFrame(self.TargetTargetFrame)
    end
    MilaUI:UpdateBossFrames()
end

function MilaUI:CreateReloadPrompt()
    StaticPopupDialogs["MilaUI_RELOAD_PROMPT"] = {
        text = "Reload is necessary for changes to take effect. Reload Now?",
        button1 = "Reload",
        button2 = "Later",
        OnAccept = function() ReloadUI() end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("MilaUI_RELOAD_PROMPT")
end

function MilaUI:UpdateUIScale()
    if not MilaUI.DB.global.UIScaleEnabled then return end
    UIParent:SetScale(MilaUI.DB.global.UIScale)
end

local AnchorPoints = {
    ["TOPLEFT"] = "Top Left",
    ["TOP"] = "Top",
    ["TOPRIGHT"] = "Top Right",
    ["LEFT"] = "Left",
    ["CENTER"] = "Center",
    ["RIGHT"] = "Right",
    ["BOTTOMLEFT"] = "Bottom Left",
    ["BOTTOM"] = "Bottom",
    ["BOTTOMRIGHT"] = "Bottom Right",
}

local GrowthX = {
    ["LEFT"] = "Left",
    ["RIGHT"] = "Right",
}

local GrowthY = {
    ["UP"] = "Up",
    ["DOWN"] = "Down",
}

local CopyFrom = {
    ["Player"] = "Player",
    ["Target"] = "Target",
    ["Focus"] = "Focus",
    ["FocusTarget"] = "Focus Target",
    ["Pet"] = "Pet",
    ["TargetTarget"] = "Target Target",
}

local function GenerateCopyFromList(Unit)
    local CopyFromList = {}
    for k, v in pairs(CopyFrom) do
        if k ~= Unit then
            CopyFromList[k] = v
        end
    end
    return CopyFromList
end

local function CopyUnit(sourceUnit, targetUnit)
    if type(sourceUnit) ~= "table" or type(targetUnit) ~= "table" then return end
    for key, targetValue in pairs(targetUnit) do
        local sourceValue = sourceUnit[key]
        if type(targetValue) == "table" and type(sourceValue) == "table" then
            CopyUnit(sourceValue, targetValue)
        elseif sourceValue ~= nil then
            targetUnit[key] = sourceValue
        end
    end
    MilaUI:UpdateFrames()
    MilaUI:CreateReloadPrompt()
end

local function ResetColours()
    local General = MilaUI.DB.profile.General
    wipe(General.CustomColours)
    General.CustomColours = {
        Reaction = {
            [1] = {255/255, 64/255, 64/255},            -- Hated
            [2] = {255/255, 64/255, 64/255},            -- Hostile
            [3] = {255/255, 128/255, 64/255},           -- Unfriendly
            [4] = {255/255, 255/255, 64/255},           -- Neutral
            [5] = {64/255, 255/255, 64/255},            -- Friendly
            [6] = {64/255, 255/255, 64/255},            -- Honored
            [7] = {64/255, 255/255, 64/255},            -- Revered
            [8] = {64/255, 255/255, 64/255},            -- Exalted
        },
        Power = {
            [0] = {0, 0, 1},            -- Mana
            [1] = {1, 0, 0},            -- Rage
            [2] = {1, 0.5, 0.25},       -- Focus
            [3] = {1, 1, 0},            -- Energy
            [6] = {0, 0.82, 1},         -- Runic Power
            [8] = {0.3, 0.52, 0.9},     -- Lunar Power
            [11] = {0, 0.5, 1},         -- Maelstrom
            [13] = {0.4, 0, 0.8},       -- Insanity
            [17] = {0.79, 0.26, 0.99},  -- Fury
            [18] = {1, 0.61, 0}         -- Pain
        },
        Status = {
            [1] = {255/255, 64/255, 64/255},           -- Dead
            [2] = {153/255, 153/255, 153/255}, -- Tapped 
            [3] = {0.6, 0.6, 0.6}, -- Disconnected
        }
    }
end

function MilaUI:CreateGUI()
    if GUIActive then return end
    GUIActive = true
    MilaUI:GenerateLSMFonts()
    MilaUI:GenerateLSMTextures()
    -- MilaUI:GenerateLSMBorders()
    MilaUI_GUI_Container = MilaUI_GUI:Create("Frame")
    MilaUI_GUI_Container:SetTitle(GUI_TITLE)
    MilaUI_GUI_Container:SetStatusText(GenerateSupportOptions())
    MilaUI_GUI_Container:SetLayout("Fill")
    MilaUI_GUI_Container:SetWidth(GUI_WIDTH)
    MilaUI_GUI_Container:SetHeight(GUI_HEIGHT)
    MilaUI_GUI_Container:EnableResize(true)
    MilaUI_GUI_Container:SetCallback("OnClose", function(widget) MilaUI_GUI:Release(widget) GUIActive = false  end)

    local function DrawGeneralContainer(MilaUI_GUI_Container)
        local ScrollableContainer = MilaUI_GUI:Create("ScrollFrame")
        ScrollableContainer:SetLayout("Flow")
        ScrollableContainer:SetFullWidth(true)
        ScrollableContainer:SetFullHeight(true)
        MilaUI_GUI_Container:AddChild(ScrollableContainer)

        local General = MilaUI.DB.profile.General
        local UIScaleContainer = MilaUI_GUI:Create("InlineGroup")
        UIScaleContainer:SetTitle("UI Scale")
        UIScaleContainer:SetLayout("Flow")
        UIScaleContainer:SetFullWidth(true)

        local UIScale = MilaUI_GUI:Create("Slider")
        UIScale:SetLabel("UI Scale")
        UIScale:SetSliderValues(0.4, 2, 0.01)
        UIScale:SetValue(MilaUI.DB.global.UIScale)
        UIScale:SetCallback("OnMouseUp", function(widget, event, value) 
            if value > 2 then value = 1 print("|cFF8080FFUnhalted|rUnitFrames: UIScale reset. Maximum of 2 for UIScale.") end 
            MilaUI.DB.global.UIScale = value
            MilaUI:UpdateUIScale() 
            UIScale:SetValue(value)
        end)
        UIScale:SetRelativeWidth(0.25)
        UIScale:SetCallback("OnEnter", function(widget, event) GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPLEFT") GameTooltip:AddLine("Decimals are supported. They will need to be manually typed in.") GameTooltip:Show() end)
        UIScale:SetCallback("OnLeave", function(widget, event) GameTooltip:Hide() end)

        local TenEightyP = MilaUI_GUI:Create("Button")
        TenEightyP:SetText("1080p")
        TenEightyP:SetCallback("OnClick", function(widget, event, value) MilaUI.DB.global.UIScale = 0.7111111111111 UIScale:SetValue(0.7111111111111) MilaUI:UpdateUIScale() end)
        TenEightyP:SetRelativeWidth(0.25)

        local FourteenFortyP = MilaUI_GUI:Create("Button")
        FourteenFortyP:SetText("1440p")
        FourteenFortyP:SetCallback("OnClick", function(widget, event, value) MilaUI.DB.global.UIScale = 0.5333333333333 UIScale:SetValue(0.5333333333333) MilaUI:UpdateUIScale() end)
        FourteenFortyP:SetRelativeWidth(0.25)

        local ApplyUIScale = MilaUI_GUI:Create("Button")
        ApplyUIScale:SetText("Apply")
        ApplyUIScale:SetCallback("OnClick", function(widget, event, value) MilaUI:UpdateUIScale() end)
        ApplyUIScale:SetRelativeWidth(0.25)

        local UIScaleToggle = MilaUI_GUI:Create("CheckBox")
        UIScaleToggle:SetLabel("Enable UI Scale")
        UIScaleToggle:SetValue(MilaUI.DB.global.UIScaleEnabled)
        UIScaleToggle:SetCallback("OnValueChanged", function(widget, event, value) MilaUI.DB.global.UIScaleEnabled = value ReloadUI() end)
        UIScaleToggle:SetRelativeWidth(1)
        if not MilaUI.DB.global.UIScaleEnabled then
            UIScale:SetDisabled(true)
            TenEightyP:SetDisabled(true)
            FourteenFortyP:SetDisabled(true)
            ApplyUIScale:SetDisabled(true)
        end

        UIScaleContainer:AddChild(UIScaleToggle)
        UIScaleContainer:AddChild(UIScale)
        UIScaleContainer:AddChild(TenEightyP)
        UIScaleContainer:AddChild(FourteenFortyP)
        UIScaleContainer:AddChild(ApplyUIScale)
        
        ScrollableContainer:AddChild(UIScaleContainer)

        local LockFramesToggle = MilaUI_GUI:Create("CheckBox")
        LockFramesToggle:SetLabel("Lock Frames")
        LockFramesToggle:SetValue(MilaUI.DB.global.FramesLocked) 
        LockFramesToggle:SetCallback("OnValueChanged", function(widget, event, value)
            local DEBUG_PREFIX = MilaUI.Prefix or "MilaGUI DEBUG: "
            print(DEBUG_PREFIX .. "LockFramesToggle OnValueChanged - New Value: " .. tostring(value))
            MilaUI.DB.global.FramesLocked = value
            if value then
                print(DEBUG_PREFIX .. "Checkbox checked, calling MilaUI:LockFrames()")
                MilaUI:LockFrames()
            else
                print(DEBUG_PREFIX .. "Checkbox unchecked, calling MilaUI:UnlockFrames()")
                MilaUI:UnlockFrames()
            end
            -- Decide if a reload prompt is needed here. Usually not for frame locking.
            -- MilaUI:CreateReloadPrompt() 
        end)
        LockFramesToggle:SetRelativeWidth(0.5) 
        ScrollableContainer:AddChild(LockFramesToggle)

        -- Font Options
        local FontOptionsContainer = MilaUI_GUI:Create("InlineGroup")
        FontOptionsContainer:SetTitle("Font Options")
        FontOptionsContainer:SetLayout("Flow")
        FontOptionsContainer:SetFullWidth(true)

        local Font = MilaUI_GUI:Create("Dropdown")
        Font:SetLabel("Font")
        Font:SetList(LSMFonts)
        Font:SetValue(General.Font)
        Font:SetCallback("OnValueChanged", function(widget, event, value) General.Font = value MilaUI:CreateReloadPrompt() end)
        Font:SetRelativeWidth(0.5)
        FontOptionsContainer:AddChild(Font)
        
        local FontFlag = MilaUI_GUI:Create("Dropdown")
        FontFlag:SetLabel("Font Flag")
        FontFlag:SetList({
            ["NONE"] = "None",
            ["OUTLINE"] = "Outline",
            ["THICKOUTLINE"] = "Thick Outline",
            ["MONOCHROME"] = "Monochrome",
            ["OUTLINE, MONOCHROME"] = "Outline, Monochrome",
            ["THICKOUTLINE, MONOCHROME"] = "Thick Outline, Monochrome",
        })
        FontFlag:SetValue(General.FontFlag)
        FontFlag:SetCallback("OnValueChanged", function(widget, event, value) General.FontFlag = value MilaUI:UpdateFrames() end)
        FontFlag:SetRelativeWidth(0.5)
        FontOptionsContainer:AddChild(FontFlag)
        ScrollableContainer:AddChild(FontOptionsContainer)
        -- Texture Options
        local TextureOptionsContainer = MilaUI_GUI:Create("InlineGroup")
        TextureOptionsContainer:SetTitle("Texture Options")
        TextureOptionsContainer:SetLayout("Flow")
        TextureOptionsContainer:SetFullWidth(true)

        local ForegroundTexture = MilaUI_GUI:Create("Dropdown")
        ForegroundTexture:SetLabel("Foreground Texture")
        ForegroundTexture:SetList(LSMTextures)
        ForegroundTexture:SetValue(General.ForegroundTexture)
        ForegroundTexture:SetCallback("OnValueChanged", function(widget, event, value) General.ForegroundTexture = value MilaUI:UpdateFrames() end)
        ForegroundTexture:SetRelativeWidth(0.5)
        TextureOptionsContainer:AddChild(ForegroundTexture)

        local BackgroundTexture = MilaUI_GUI:Create("Dropdown")
        BackgroundTexture:SetLabel("Background Texture")
        BackgroundTexture:SetList(LSMTextures)
        BackgroundTexture:SetValue(General.BackgroundTexture)
        BackgroundTexture:SetCallback("OnValueChanged", function(widget, event, value) General.BackgroundTexture = value MilaUI:UpdateFrames() end)
        BackgroundTexture:SetRelativeWidth(0.5)
        TextureOptionsContainer:AddChild(BackgroundTexture)

        -- local BorderTexture = MilaUI_GUI:Create("Dropdown")
        -- BorderTexture:SetLabel("Border Texture")
        -- BorderTexture:SetList(LSMBorders)
        -- BorderTexture:SetValue(General.BorderTexture)
        -- BorderTexture:SetCallback("OnValueChanged", function(widget, event, value) General.BorderTexture = value MilaUI:UpdateFrames() end)
        -- BorderTexture:SetRelativeWidth(0.33)
        -- TextureOptionsContainer:AddChild(BorderTexture)

        -- local BorderSize = MilaUI_GUI:Create("Slider")
        -- BorderSize:SetLabel("Border Size")
        -- BorderSize:SetSliderValues(0, 64, 1)
        -- BorderSize:SetValue(General.BorderSize)
        -- BorderSize:SetCallback("OnValueChanged", function(widget, event, value) General.BorderSize = value MilaUI:UpdateFrames() end)
        -- BorderSize:SetRelativeWidth(0.5)
        -- TextureOptionsContainer:AddChild(BorderSize)

        -- local BorderInset = MilaUI_GUI:Create("Slider")
        -- BorderInset:SetLabel("Border Inset")
        -- BorderInset:SetSliderValues(-64, 64, 1)
        -- BorderInset:SetValue(General.BorderInset)
        -- BorderInset:SetCallback("OnMouseUp", function(widget, event, value) General.BorderInset = value MilaUI:UpdateFrames() end)
        -- BorderInset:SetRelativeWidth(0.5)
        -- TextureOptionsContainer:AddChild(BorderInset)
        
        ScrollableContainer:AddChild(TextureOptionsContainer)

        -- Colouring Options
        local ColouringOptionsContainer = MilaUI_GUI:Create("InlineGroup")
        ColouringOptionsContainer:SetTitle("Colour Options")
        ColouringOptionsContainer:SetLayout("Flow")
        ColouringOptionsContainer:SetFullWidth(true)

        local HealthColourOptions = MilaUI_GUI:Create("InlineGroup")
        HealthColourOptions:SetTitle("Health Colour Options")
        HealthColourOptions:SetLayout("Flow")
        HealthColourOptions:SetFullWidth(true)
        ColouringOptionsContainer:AddChild(HealthColourOptions)

        local ForegroundColour = MilaUI_GUI:Create("ColorPicker")
        ForegroundColour:SetLabel("Foreground Colour")
        local FGR, FGG, FGB, FGA = unpack(General.ForegroundColour)
        ForegroundColour:SetColor(FGR, FGG, FGB, FGA)
        ForegroundColour:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) General.ForegroundColour = {r, g, b, a} MilaUI:UpdateFrames() end)
        ForegroundColour:SetHasAlpha(true)
        ForegroundColour:SetRelativeWidth(0.25)
        HealthColourOptions:AddChild(ForegroundColour)

        local ClassColour = MilaUI_GUI:Create("CheckBox")
        ClassColour:SetLabel("Use Class / Reaction Colour")
        ClassColour:SetValue(General.ColourByClass)
        ClassColour:SetCallback("OnValueChanged", function(widget, event, value) General.ColourByClass = value MilaUI:UpdateFrames() end)
        ClassColour:SetRelativeWidth(0.25)
        HealthColourOptions:AddChild(ClassColour)

        -- local ReactionColour = MilaUI_GUI:Create("CheckBox")
        -- ReactionColour:SetLabel("Use Reaction Colour")
        -- ReactionColour:SetValue(General.ColourByReaction)
        -- ReactionColour:SetCallback("OnValueChanged", function(widget, event, value) General.ColourByReaction = value MilaUI:UpdateFrames() end)
        -- ReactionColour:SetRelativeWidth(0.25)
        -- HealthColourOptions:AddChild(ReactionColour)

        local DisconnectedColour = MilaUI_GUI:Create("CheckBox")
        DisconnectedColour:SetLabel("Use Disconnected Colour")
        DisconnectedColour:SetValue(General.ColourIfDisconnected)
        DisconnectedColour:SetCallback("OnValueChanged", function(widget, event, value) General.ColourIfDisconnected = value MilaUI:UpdateFrames() end)
        DisconnectedColour:SetRelativeWidth(0.25)
        HealthColourOptions:AddChild(DisconnectedColour)

        local TappedColour = MilaUI_GUI:Create("CheckBox")
        TappedColour:SetLabel("Use Tapped Colour")
        TappedColour:SetValue(General.ColourIfTapped)
        TappedColour:SetCallback("OnValueChanged", function(widget, event, value) General.ColourIfTapped = value MilaUI:UpdateFrames() end)
        TappedColour:SetRelativeWidth(0.25)
        HealthColourOptions:AddChild(TappedColour)

        local BackgroundColourOptions = MilaUI_GUI:Create("InlineGroup")
        BackgroundColourOptions:SetTitle("Background Colour Options")
        BackgroundColourOptions:SetLayout("Flow")
        BackgroundColourOptions:SetFullWidth(true)
        ColouringOptionsContainer:AddChild(BackgroundColourOptions)

        local BackgroundColour = MilaUI_GUI:Create("ColorPicker")
        BackgroundColour:SetLabel("Background Colour")
        local BGR, BGG, BGB, BGA = unpack(General.BackgroundColour)
        BackgroundColour:SetColor(BGR, BGG, BGB, BGA)
        BackgroundColour:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) General.BackgroundColour = {r, g, b, a} MilaUI:UpdateFrames() end)
        BackgroundColour:SetHasAlpha(true)
        BackgroundColour:SetRelativeWidth(1)
        BackgroundColourOptions:AddChild(BackgroundColour)

        local BackgroundColourMultiplier = MilaUI_GUI:Create("Slider")
        BackgroundColourMultiplier:SetLabel("Multiplier")
        BackgroundColourMultiplier:SetSliderValues(0, 1, 0.01)
        BackgroundColourMultiplier:SetValue(General.BackgroundMultiplier)
        BackgroundColourMultiplier:SetCallback("OnMouseUp", function(widget, event, value) General.BackgroundMultiplier = value MilaUI:UpdateFrames() end)
        BackgroundColourMultiplier:SetRelativeWidth(0.25)

        local BackgroundColourByForeground = MilaUI_GUI:Create("CheckBox")
        BackgroundColourByForeground:SetLabel("Colour By Foreground")
        BackgroundColourByForeground:SetValue(General.ColourBackgroundByForeground)
        BackgroundColourByForeground:SetCallback("OnValueChanged", function(widget, event, value) General.ColourBackgroundByForeground = value MilaUI:UpdateFrames() if value then BackgroundColourMultiplier:SetDisabled(false) else BackgroundColourMultiplier:SetDisabled(true) end end)
        BackgroundColourByForeground:SetRelativeWidth(0.25)
        BackgroundColourOptions:AddChild(BackgroundColourByForeground)


        BackgroundColourOptions:AddChild(BackgroundColourMultiplier)

        if General.ColourBackgroundByForeground then
            BackgroundColourMultiplier:SetDisabled(false)
        else
            BackgroundColourMultiplier:SetDisabled(true)
        end

        local BackgroundColourIfDead = MilaUI_GUI:Create("CheckBox")
        BackgroundColourIfDead:SetLabel("Colour If Dead")
        BackgroundColourIfDead:SetValue(General.ColourBackgroundIfDead)
        BackgroundColourIfDead:SetCallback("OnValueChanged", function(widget, event, value) General.ColourBackgroundIfDead = value MilaUI:UpdateFrames() end)
        BackgroundColourIfDead:SetRelativeWidth(0.25)
        BackgroundColourOptions:AddChild(BackgroundColourIfDead)

        local BackgroundColourByClass = MilaUI_GUI:Create("CheckBox")
        BackgroundColourByClass:SetLabel("Colour By Class / Reaction")
        BackgroundColourByClass:SetValue(General.ColourBackgroundByClass)
        BackgroundColourByClass:SetCallback("OnValueChanged", function(widget, event, value) General.ColourBackgroundByClass = value MilaUI:UpdateFrames() end)
        BackgroundColourByClass:SetRelativeWidth(0.25)
        BackgroundColourOptions:AddChild(BackgroundColourByClass)

        local BorderColourOptions = MilaUI_GUI:Create("InlineGroup")
        BorderColourOptions:SetTitle("Border Colour Options")
        BorderColourOptions:SetLayout("Flow")
        BorderColourOptions:SetFullWidth(true)
        ColouringOptionsContainer:AddChild(BorderColourOptions)

        local BorderColour = MilaUI_GUI:Create("ColorPicker")
        BorderColour:SetLabel("Border Colour")
        local BR, BG, BB, BA = unpack(General.BorderColour)
        BorderColour:SetColor(BR, BG, BB, BA)
        BorderColour:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) General.BorderColour = {r, g, b, a} MilaUI:UpdateFrames() end)
        BorderColour:SetHasAlpha(true)
        BorderColour:SetRelativeWidth(0.33)
        BorderColourOptions:AddChild(BorderColour)

        local MouseoverHighlight = MilaUI.DB.profile.General.MouseoverHighlight
        local MouseoverHighlightOptions = MilaUI_GUI:Create("InlineGroup")
        MouseoverHighlightOptions:SetTitle("Mouseover Highlight Options")
        MouseoverHighlightOptions:SetLayout("Flow")
        MouseoverHighlightOptions:SetFullWidth(true)
        ScrollableContainer:AddChild(MouseoverHighlightOptions)

        local MouseoverHighlightEnabled = MilaUI_GUI:Create("CheckBox")
        MouseoverHighlightEnabled:SetLabel("Enable Mouseover Highlight")
        MouseoverHighlightEnabled:SetValue(MouseoverHighlight.Enabled)
        MouseoverHighlightEnabled:SetCallback("OnValueChanged", function(widget, event, value) MouseoverHighlight.Enabled = value MilaUI:CreateReloadPrompt() end)
        MouseoverHighlightEnabled:SetRelativeWidth(0.33)
        MouseoverHighlightOptions:AddChild(MouseoverHighlightEnabled)

        local MouseoverHighlightColor = MilaUI_GUI:Create("ColorPicker")
        MouseoverHighlightColor:SetLabel("Color")
        local MHR, MHG, MHB, MHA = unpack(MouseoverHighlight.Colour)
        MouseoverHighlightColor:SetColor(MHR, MHG, MHB, MHA)
        MouseoverHighlightColor:SetCallback("OnValueChanged", function(widget, event, r, g, b, a) MouseoverHighlight.Colour = {r, g, b, a} MilaUI:UpdateFrames() end)
        MouseoverHighlightColor:SetHasAlpha(true)
        MouseoverHighlightColor:SetRelativeWidth(0.33)
        MouseoverHighlightOptions:AddChild(MouseoverHighlightColor)

        local MouseoverStyle = MilaUI_GUI:Create("Dropdown")
        MouseoverStyle:SetLabel("Style")
        MouseoverStyle:SetList({
            ["BORDER"] = "Border",
            ["HIGHLIGHT"] = "Highlight",
        })
        MouseoverStyle:SetValue(MouseoverHighlight.Style)
        MouseoverStyle:SetCallback("OnValueChanged", function(widget, event, value) MouseoverHighlight.Style = value MilaUI:UpdateFrames() end)
        MouseoverStyle:SetRelativeWidth(0.33)
        MouseoverHighlightOptions:AddChild(MouseoverStyle)

        local CustomColours = MilaUI_GUI:Create("InlineGroup")
        CustomColours:SetTitle("Custom Colours")
        CustomColours:SetLayout("Flow")
        CustomColours:SetFullWidth(true)
        ColouringOptionsContainer:AddChild(CustomColours)

        local ResetCustomColoursButton = MilaUI_GUI:Create("Button")
        ResetCustomColoursButton:SetText("Reset Custom Colours")
        ResetCustomColoursButton:SetCallback("OnClick", function(widget, event, value) ResetColours() MilaUI:ReOpenGUI() end)
        ResetCustomColoursButton:SetRelativeWidth(1)
        CustomColours:AddChild(ResetCustomColoursButton)

        local PowerColours = MilaUI_GUI:Create("InlineGroup")
        PowerColours:SetTitle("Power Colours")
        PowerColours:SetLayout("Flow")
        PowerColours:SetFullWidth(true)
        CustomColours:AddChild(PowerColours)

        local PowerOrder = {0, 1, 2, 3, 6, 8, 11, 13, 17, 18}
        for _, powerType in ipairs(PowerOrder) do
            local powerColour = General.CustomColours.Power[powerType]
            local PowerColour = MilaUI_GUI:Create("ColorPicker")
            PowerColour:SetLabel(PowerNames[powerType])
            local R, G, B = unpack(powerColour)
            PowerColour:SetColor(R, G, B)
            PowerColour:SetCallback("OnValueChanged", function(widget, _, r, g, b)
                General.CustomColours.Power[powerType] = {r, g, b}
                MilaUI:UpdateFrames()
            end)
            PowerColour:SetHasAlpha(false)
            PowerColour:SetRelativeWidth(0.25)
            PowerColours:AddChild(PowerColour)
        end

        local ReactionColours = MilaUI_GUI:Create("InlineGroup")
        ReactionColours:SetTitle("Reaction Colours")
        ReactionColours:SetLayout("Flow")
        ReactionColours:SetFullWidth(true)
        CustomColours:AddChild(ReactionColours)

        for reactionType, reactionColour in pairs(General.CustomColours.Reaction) do
            local ReactionColour = MilaUI_GUI:Create("ColorPicker")
            ReactionColour:SetLabel(ReactionNames[reactionType])
            local R, G, B = unpack(reactionColour)
            ReactionColour:SetColor(R, G, B)
            ReactionColour:SetCallback("OnValueChanged", function(widget, _, r, g, b) General.CustomColours.Reaction[reactionType] = {r, g, b} MilaUI:UpdateFrames() end)
            ReactionColour:SetHasAlpha(false)
            ReactionColour:SetRelativeWidth(0.25)
            ReactionColours:AddChild(ReactionColour)
        end

        local StatusColours = MilaUI_GUI:Create("InlineGroup")
        StatusColours:SetTitle("Status Colours")
        StatusColours:SetLayout("Flow")
        StatusColours:SetFullWidth(true)
        CustomColours:AddChild(StatusColours)

        for statusType, statusColour in pairs(General.CustomColours.Status) do
            local StatusColour = MilaUI_GUI:Create("ColorPicker")
            StatusColour:SetLabel(StatusNames[statusType])
            local R, G, B = unpack(statusColour)
            StatusColour:SetColor(R, G, B)
            StatusColour:SetCallback("OnValueChanged", function(widget, _, r, g, b) General.CustomColours.Status[statusType] = {r, g, b} MilaUI:UpdateFrames() end)
            StatusColour:SetHasAlpha(false)
            StatusColour:SetRelativeWidth(0.33)
            StatusColours:AddChild(StatusColour)
        end
        
        ScrollableContainer:AddChild(ColouringOptionsContainer)
    end

    local function DrawUnitContainer(MilaUI_GUI_Container, Unit)
        local ScrollableContainer = MilaUI_GUI:Create("ScrollFrame")
        ScrollableContainer:SetLayout("Flow")
        ScrollableContainer:SetFullWidth(true)
        ScrollableContainer:SetFullHeight(true)
        MilaUI_GUI_Container:AddChild(ScrollableContainer)

        local General = MilaUI.DB.profile.General
        local Frame = MilaUI.DB.profile[Unit].Frame
        local Portrait = MilaUI.DB.profile[Unit].Portrait
        local Health = MilaUI.DB.profile[Unit].Health
        local HealthPrediction = Health.HealthPrediction
        local Absorbs = HealthPrediction.Absorbs
        local HealAbsorbs = HealthPrediction.HealAbsorbs
        local PowerBar = MilaUI.DB.profile[Unit].PowerBar
        local Buffs = MilaUI.DB.profile[Unit].Buffs
        local Debuffs = MilaUI.DB.profile[Unit].Debuffs
        local TargetMarker = MilaUI.DB.profile[Unit].TargetMarker
        local CombatIndicator = MilaUI.DB.profile[Unit].CombatIndicator
        local LeaderIndicator = MilaUI.DB.profile[Unit].LeaderIndicator
        local TargetIndicator = MilaUI.DB.profile[Unit].TargetIndicator
        local FirstText = MilaUI.DB.profile[Unit].Texts.First
        local SecondText = MilaUI.DB.profile[Unit].Texts.Second
        local ThirdText = MilaUI.DB.profile[Unit].Texts.Third
        local Range = MilaUI.DB.profile[Unit].Range

        local function DrawFrameContainer(MilaUI_GUI_Container)
            local Enabled = MilaUI_GUI:Create("CheckBox")
            Enabled:SetLabel("Enable Frame")
            Enabled:SetValue(Frame.Enabled)
            Enabled:SetCallback("OnValueChanged", function(widget, event, value) Frame.Enabled = value MilaUI:CreateReloadPrompt() end)
            Enabled:SetRelativeWidth(0.5)
            MilaUI_GUI_Container:AddChild(Enabled)

            if Unit == "Player" or Unit == "Target" or Unit == "Focus" or Unit == "FocusTarget" or Unit == "Pet" or Unit == "TargetTarget" then
                local CopyFromDropdown = MilaUI_GUI:Create("Dropdown")
                CopyFromDropdown:SetLabel("Copy From")
                CopyFromDropdown:SetList(GenerateCopyFromList(Unit))
                CopyFromDropdown:SetValue(nil)
                CopyFromDropdown:SetCallback("OnValueChanged", function(widget, event, value)
                    if value == Unit then return end
                    local sourceUnit = MilaUI.DB.profile[value]
                    local targetUnit = MilaUI.DB.profile[Unit]
                    if not sourceUnit then print("|cFFFF0000Unhalted|r Error: No settings found for " .. value) return end
                    if not targetUnit then print("|cFFFF0000Unhalted|r Error: No settings found for " .. Unit) return end
                    CopyUnit(sourceUnit, targetUnit)
                    print("|cFF8080FFUnhalted|rUnitFrames: Copied settings from " .. value .. " to " .. Unit .. ".")
                    CopyFromDropdown:SetValue(nil)
                end)
                CopyFromDropdown:SetRelativeWidth(0.5)
                MilaUI_GUI_Container:AddChild(CopyFromDropdown)
                if not Frame.Enabled then CopyFromDropdown:SetDisabled(true) end
            end

            if Unit == "Boss" then
                local DisplayFrames = MilaUI_GUI:Create("Button")
                DisplayFrames:SetText("Display Frames")
                DisplayFrames:SetCallback("OnClick", function(widget, event, value) MilaUI.DB.profile.TestMode = not MilaUI.DB.profile.TestMode MilaUI:DisplayBossFrames() MilaUI:UpdateFrames() end)
                DisplayFrames:SetRelativeWidth(1)
                MilaUI_GUI_Container:AddChild(DisplayFrames)
                if not Frame.Enabled then DisplayFrames:SetDisabled(true) end
            end

            -- Frame Options
            local FrameOptions = MilaUI_GUI:Create("InlineGroup")
            FrameOptions:SetTitle("Frame Options")
            FrameOptions:SetLayout("Flow")
            FrameOptions:SetFullWidth(true)

            local HealthTexturePicker = MilaUI_GUI:Create("Dropdown")
            HealthTexturePicker:SetLabel("Health Texture")
            HealthTexturePicker:SetList(LSMTextures)
            HealthTexturePicker:SetValue(Health.Texture)
            HealthTexturePicker:SetCallback("OnValueChanged", function(widget, event, value) Health.Texture = value MilaUI:UpdateFrames() end)
            HealthTexturePicker:SetRelativeWidth(0.5)
            FrameOptions:AddChild(HealthTexturePicker)

            local CustomBorder = MilaUI_GUI:Create("CheckBox")
            CustomBorder:SetLabel("Custom Border")
            CustomBorder:SetValue(Health.CustomBorder.Enabled)
            CustomBorder:SetCallback("OnValueChanged", function(widget, event, value) Health.CustomBorder.Enabled = value MilaUI:UpdateFrames() end)
            CustomBorder:SetRelativeWidth(0.5)
            FrameOptions:AddChild(CustomBorder)


            local FrameAnchorFrom = MilaUI_GUI:Create("Dropdown")
            FrameAnchorFrom:SetLabel("Anchor From")
            FrameAnchorFrom:SetList(AnchorPoints)
            FrameAnchorFrom:SetValue(Frame.AnchorFrom)
            FrameAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) Frame.AnchorFrom = value MilaUI:UpdateFrames() end)
            FrameAnchorFrom:SetRelativeWidth(0.33)
            FrameOptions:AddChild(FrameAnchorFrom)

            local FrameAnchorTo = MilaUI_GUI:Create("Dropdown")
            FrameAnchorTo:SetLabel("Anchor To")
            FrameAnchorTo:SetList(AnchorPoints)
            FrameAnchorTo:SetValue(Frame.AnchorTo)
            FrameAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) Frame.AnchorTo = value MilaUI:UpdateFrames() end)
            FrameAnchorTo:SetRelativeWidth(0.33)
            FrameOptions:AddChild(FrameAnchorTo)

            local FrameAnchorParent = MilaUI_GUI:Create("EditBox")
            FrameAnchorParent:SetLabel("Anchor Parent")
            FrameAnchorParent:SetText(type(Frame.AnchorParent) == "string" and Frame.AnchorParent or "UIParent")

            FrameAnchorParent:SetCallback("OnEnterPressed", function(widget, event, value)
                local anchor = _G[value]
                if anchor and anchor:IsObjectType("Frame") then
                    Frame.AnchorParent = value
                else
                    Frame.AnchorParent = "UIParent"
                    widget:SetText("UIParent")
                end
                MilaUI:UpdateFrames()
            end)
            FrameAnchorParent:SetRelativeWidth(0.33)
            FrameOptions:AddChild(FrameAnchorParent)

            local FrameAnchorParentTooltipDesc = "|cFF8080FFPLEASE NOTE|r: This will |cFFFF4040NOT|r work for WeakAuras."
            FrameAnchorParent:SetCallback("OnEnter", function(widget, event) GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPLEFT") GameTooltip:AddLine(FrameAnchorParentTooltipDesc) GameTooltip:Show() end)
            FrameAnchorParent:SetCallback("OnLeave", function(widget, event) GameTooltip:Hide() end)

            local FrameWidth = MilaUI_GUI:Create("Slider")
            FrameWidth:SetLabel("Frame Width")
            FrameWidth:SetSliderValues(1, 999, 0.1)
            FrameWidth:SetValue(Frame.Width)
            FrameWidth:SetCallback("OnMouseUp", function(widget, event, value) Frame.Width = value MilaUI:UpdateFrames() end)
            FrameWidth:SetRelativeWidth(0.5)
            FrameOptions:AddChild(FrameWidth)

            local FrameHeight = MilaUI_GUI:Create("Slider")
            FrameHeight:SetLabel("Frame Height")
            FrameHeight:SetSliderValues(1, 999, 0.1)
            FrameHeight:SetValue(Frame.Height)
            FrameHeight:SetCallback("OnMouseUp", function(widget, event, value) Frame.Height = value MilaUI:UpdateFrames() end)
            FrameHeight:SetRelativeWidth(0.5)
            FrameOptions:AddChild(FrameHeight)

            local FrameXPosition = MilaUI_GUI:Create("Slider")
            FrameXPosition:SetLabel("Frame X Position")
            FrameXPosition:SetSliderValues(-999, 999, 0.1)
            FrameXPosition:SetValue(Frame.XPosition)
            FrameXPosition:SetCallback("OnMouseUp", function(widget, event, value) Frame.XPosition = value MilaUI:UpdateFrames() end)
            FrameXPosition:SetRelativeWidth(0.5)
            FrameOptions:AddChild(FrameXPosition)

            local FrameYPosition = MilaUI_GUI:Create("Slider")
            FrameYPosition:SetLabel("Frame Y Position")
            FrameYPosition:SetSliderValues(-999, 999, 0.1)
            FrameYPosition:SetValue(Frame.YPosition)
            FrameYPosition:SetCallback("OnMouseUp", function(widget, event, value) Frame.YPosition = value MilaUI:UpdateFrames() end)
            FrameYPosition:SetRelativeWidth(0.5)
            FrameOptions:AddChild(FrameYPosition)

            if Unit == "Boss" then
                local FrameSpacing = MilaUI_GUI:Create("Slider")
                FrameSpacing:SetLabel("Frame Spacing")
                FrameSpacing:SetSliderValues(-999, 999, 0.1)
                FrameSpacing:SetValue(Frame.Spacing)
                FrameSpacing:SetCallback("OnMouseUp", function(widget, event, value) Frame.Spacing = value MilaUI:UpdateFrames() end)
                FrameXPosition:SetRelativeWidth(0.25)
                FrameYPosition:SetRelativeWidth(0.25)
                FrameSpacing:SetRelativeWidth(0.25)
                FrameOptions:AddChild(FrameSpacing)

                local GrowthDirection = MilaUI_GUI:Create("Dropdown")
                GrowthDirection:SetLabel("Growth Direction")
                GrowthDirection:SetList({
                    ["DOWN"] = "Down",
                    ["UP"] = "Up",
                })
                GrowthDirection:SetValue(Frame.GrowthY)
                GrowthDirection:SetCallback("OnValueChanged", function(widget, event, value) Frame.GrowthY = value MilaUI:UpdateFrames() end)
                GrowthDirection:SetRelativeWidth(0.25)
                FrameOptions:AddChild(GrowthDirection)
            end

            MilaUI_GUI_Container:AddChild(FrameOptions)

            local PortraitOptions = MilaUI_GUI:Create("InlineGroup")
            PortraitOptions:SetTitle("Portrait Options")
            PortraitOptions:SetLayout("Flow")
            PortraitOptions:SetFullWidth(true)

            local PortraitEnabled = MilaUI_GUI:Create("CheckBox")
            PortraitEnabled:SetLabel("Enable Portrait")
            PortraitEnabled:SetValue(Portrait.Enabled)
            PortraitEnabled:SetCallback("OnValueChanged", function(widget, event, value) Portrait.Enabled = value MilaUI:CreateReloadPrompt() end)
            PortraitEnabled:SetRelativeWidth(1)
            PortraitOptions:AddChild(PortraitEnabled)

            local PortraitAnchorFrom = MilaUI_GUI:Create("Dropdown")
            PortraitAnchorFrom:SetLabel("Anchor From")
            PortraitAnchorFrom:SetList(AnchorPoints)
            PortraitAnchorFrom:SetValue(Portrait.AnchorFrom)
            PortraitAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) Portrait.AnchorFrom = value MilaUI:UpdateFrames() end)
            PortraitAnchorFrom:SetRelativeWidth(0.5)
            PortraitOptions:AddChild(PortraitAnchorFrom)

            local PortraitAnchorTo = MilaUI_GUI:Create("Dropdown")
            PortraitAnchorTo:SetLabel("Anchor To")
            PortraitAnchorTo:SetList(AnchorPoints)
            PortraitAnchorTo:SetValue(Portrait.AnchorTo)
            PortraitAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) Portrait.AnchorTo = value MilaUI:UpdateFrames() end)
            PortraitAnchorTo:SetRelativeWidth(0.5)
            PortraitOptions:AddChild(PortraitAnchorTo)

            local PortraitSize = MilaUI_GUI:Create("Slider")
            PortraitSize:SetLabel("Portrait Size")
            PortraitSize:SetSliderValues(1, 999, 0.1)
            PortraitSize:SetValue(Portrait.Size)
            PortraitSize:SetCallback("OnMouseUp", function(widget, event, value) Portrait.Size = value MilaUI:UpdateFrames() end)
            PortraitSize:SetRelativeWidth(0.33)
            PortraitOptions:AddChild(PortraitSize)

            local PortraitXOffset = MilaUI_GUI:Create("Slider")
            PortraitXOffset:SetLabel("Portrait X Offset")
            PortraitXOffset:SetSliderValues(-999, 999, 1)
            PortraitXOffset:SetValue(Portrait.XOffset)
            PortraitXOffset:SetCallback("OnMouseUp", function(widget, event, value) Portrait.XOffset = value MilaUI:UpdateFrames() end)
            PortraitXOffset:SetRelativeWidth(0.33)
            PortraitOptions:AddChild(PortraitXOffset)

            local PortraitYOffset = MilaUI_GUI:Create("Slider")
            PortraitYOffset:SetLabel("Portrait Y Offset")
            PortraitYOffset:SetSliderValues(-999, 999, 1)
            PortraitYOffset:SetValue(Portrait.YOffset)
            PortraitYOffset:SetCallback("OnMouseUp", function(widget, event, value) Portrait.YOffset = value MilaUI:UpdateFrames() end)
            PortraitYOffset:SetRelativeWidth(0.33)
            PortraitOptions:AddChild(PortraitYOffset)

            MilaUI_GUI_Container:AddChild(PortraitOptions)

            local HealthOptionsContainer = MilaUI_GUI:Create("InlineGroup")
            HealthOptionsContainer:SetTitle("Health Options")
            HealthOptionsContainer:SetLayout("Flow")
            HealthOptionsContainer:SetFullWidth(true)

            if Unit == "Pet" then
                local HealthGrowDirection = MilaUI_GUI:Create("Dropdown")
                HealthGrowDirection:SetLabel("Health Grow Direction")
                HealthGrowDirection:SetList({
                    ["LR"] = "Left To Right",
                    ["RL"] = "Right To Left",
                })
                HealthGrowDirection:SetValue(Health.Direction)
                HealthGrowDirection:SetCallback("OnValueChanged", function(widget, event, value) Health.Direction = value MilaUI:UpdateFrames() end)
                HealthGrowDirection:SetRelativeWidth(0.5)
                HealthOptionsContainer:AddChild(HealthGrowDirection)

                local ColourHealthByClass = MilaUI_GUI:Create("CheckBox")
                ColourHealthByClass:SetLabel("Colour By Player Class")
                ColourHealthByClass:SetValue(Health.ColourByPlayerClass)
                ColourHealthByClass:SetCallback("OnValueChanged", function(widget, event, value) Health.ColourByPlayerClass = value MilaUI:UpdateFrames() end)
                ColourHealthByClass:SetRelativeWidth(0.5)
                ColourHealthByClass:SetDisabled(not General.ColourByClass)
                HealthOptionsContainer:AddChild(ColourHealthByClass)
            else
                local HealthGrowDirection = MilaUI_GUI:Create("Dropdown")
                HealthGrowDirection:SetLabel("Health Grow Direction")
                HealthGrowDirection:SetList({
                    ["LR"] = "Left To Right",
                    ["RL"] = "Right To Left",
                })
                HealthGrowDirection:SetValue(Health.Direction)
                HealthGrowDirection:SetCallback("OnValueChanged", function(widget, event, value) Health.Direction = value MilaUI:UpdateFrames() end)
                HealthGrowDirection:SetFullWidth(true)
                HealthOptionsContainer:AddChild(HealthGrowDirection)
            end
            
            local AbsorbsContainer = MilaUI_GUI:Create("InlineGroup")
            AbsorbsContainer:SetTitle("Health Prediction Options")
            AbsorbsContainer:SetLayout("Flow")
            AbsorbsContainer:SetFullWidth(true)
            HealthOptionsContainer:AddChild(AbsorbsContainer)

            local AbsorbsEnabled = MilaUI_GUI:Create("CheckBox")
            AbsorbsEnabled:SetLabel("Enable Absorbs")
            AbsorbsEnabled:SetValue(Absorbs.Enabled)
            AbsorbsEnabled:SetCallback("OnValueChanged", function(widget, event, value) Absorbs.Enabled = value MilaUI:CreateReloadPrompt() end)
            AbsorbsEnabled:SetRelativeWidth(0.5)
            AbsorbsContainer:AddChild(AbsorbsEnabled)

            local AbsorbsColourPicker = MilaUI_GUI:Create("ColorPicker")
            AbsorbsColourPicker:SetLabel("Colour")
            local AR, AG, AB, AA = unpack(Absorbs.Colour)
            AbsorbsColourPicker:SetColor(AR, AG, AB, AA)
            AbsorbsColourPicker:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) Absorbs.Colour = {r, g, b, a} MilaUI:UpdateFrames() end)
            AbsorbsColourPicker:SetHasAlpha(true)
            AbsorbsColourPicker:SetRelativeWidth(0.5)
            AbsorbsContainer:AddChild(AbsorbsColourPicker)

            local HealAbsorbsContainer = MilaUI_GUI:Create("InlineGroup")
            HealAbsorbsContainer:SetTitle("Heal Absorbs")
            HealAbsorbsContainer:SetLayout("Flow")
            HealAbsorbsContainer:SetFullWidth(true)
            HealthOptionsContainer:AddChild(HealAbsorbsContainer)

            local HealAbsorbsEnabled = MilaUI_GUI:Create("CheckBox")
            HealAbsorbsEnabled:SetLabel("Enable Heal Absorbs")
            HealAbsorbsEnabled:SetValue(HealAbsorbs.Enabled)
            HealAbsorbsEnabled:SetCallback("OnValueChanged", function(widget, event, value) HealAbsorbs.Enabled = value MilaUI:UpdateFrames() end)
            HealAbsorbsEnabled:SetRelativeWidth(0.5)
            HealAbsorbsContainer:AddChild(HealAbsorbsEnabled)

            local HealAbsorbsColourPicker = MilaUI_GUI:Create("ColorPicker")
            HealAbsorbsColourPicker:SetLabel("Colour")
            local HAR, HAG, HAB, HAA = unpack(HealAbsorbs.Colour)
            HealAbsorbsColourPicker:SetColor(HAR, HAG, HAB, HAA)
            HealAbsorbsColourPicker:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) HealAbsorbs.Colour = {r, g, b, a} MilaUI:UpdateFrames() end)
            HealAbsorbsColourPicker:SetHasAlpha(true)
            HealAbsorbsColourPicker:SetRelativeWidth(0.5)
            HealAbsorbsContainer:AddChild(HealAbsorbsColourPicker)

            MilaUI_GUI_Container:AddChild(HealthOptionsContainer)

            local PowerBarOptionsContainer = MilaUI_GUI:Create("InlineGroup")
            PowerBarOptionsContainer:SetTitle("Power Bar Options")
            PowerBarOptionsContainer:SetLayout("Flow")
            PowerBarOptionsContainer:SetFullWidth(true)
            MilaUI_GUI_Container:AddChild(PowerBarOptionsContainer)

            local PowerBarEnabled = MilaUI_GUI:Create("CheckBox")
            PowerBarEnabled:SetLabel("Enable Power Bar")
            PowerBarEnabled:SetValue(PowerBar.Enabled)
            PowerBarEnabled:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.Enabled = value MilaUI:CreateReloadPrompt() end)
            PowerBarEnabled:SetRelativeWidth(0.33)
            PowerBarOptionsContainer:AddChild(PowerBarEnabled)

            local PowerBarSmooth = MilaUI_GUI:Create("CheckBox")
            PowerBarSmooth:SetLabel("Smooth")
            PowerBarSmooth:SetValue(PowerBar.Smooth)
            PowerBarSmooth:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.Smooth = value MilaUI:UpdateFrames() end)
            PowerBarSmooth:SetRelativeWidth(0.33)
            PowerBarOptionsContainer:AddChild(PowerBarSmooth)

            local PowerBarGrowthDirection = MilaUI_GUI:Create("Dropdown")
            PowerBarGrowthDirection:SetLabel("Power Bar Growth Direction")
            PowerBarGrowthDirection:SetList({
                ["LR"] = "Left To Right",
                ["RL"] = "Right To Left",
            })
            PowerBarGrowthDirection:SetValue(PowerBar.Direction)
            PowerBarGrowthDirection:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.Direction = value MilaUI:UpdateFrames() end)
            PowerBarGrowthDirection:SetRelativeWidth(0.33)
            PowerBarOptionsContainer:AddChild(PowerBarGrowthDirection)

            local PowerBarColourByType = MilaUI_GUI:Create("CheckBox")
            PowerBarColourByType:SetLabel("Colour Bar By Type")
            PowerBarColourByType:SetValue(PowerBar.ColourByType)
            PowerBarColourByType:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.ColourByType = value MilaUI:UpdateFrames() end)
            PowerBarColourByType:SetRelativeWidth(0.25)
            PowerBarOptionsContainer:AddChild(PowerBarColourByType)

            local BackgroundColourMultiplier = MilaUI_GUI:Create("Slider")
            BackgroundColourMultiplier:SetLabel("Multiplier")
            BackgroundColourMultiplier:SetSliderValues(0, 1, 0.01)
            BackgroundColourMultiplier:SetValue(PowerBar.BackgroundMultiplier)
            BackgroundColourMultiplier:SetCallback("OnMouseUp", function(widget, event, value) PowerBar.BackgroundMultiplier = value MilaUI:UpdateFrames() end)
            BackgroundColourMultiplier:SetRelativeWidth(0.5)

            local PowerBarBackdropColourByType = MilaUI_GUI:Create("CheckBox")
            PowerBarBackdropColourByType:SetLabel("Colour Background By Type")
            PowerBarBackdropColourByType:SetValue(PowerBar.ColourBackgroundByType)
            PowerBarBackdropColourByType:SetCallback("OnValueChanged", function(widget, event, value) PowerBar.ColourBackgroundByType = value 
            if value then BackgroundColourMultiplier:SetDisabled(false) else BackgroundColourMultiplier:SetDisabled(true) end
            MilaUI:UpdateFrames() end)
            PowerBarBackdropColourByType:SetRelativeWidth(0.25)
            PowerBarOptionsContainer:AddChild(PowerBarBackdropColourByType)

            local PowerBarColour = MilaUI_GUI:Create("ColorPicker")
            PowerBarColour:SetLabel("Foreground Colour")
            local PBR, PBG, PBB, PBA = unpack(PowerBar.Colour)
            PowerBarColour:SetColor(PBR, PBG, PBB, PBA)
            PowerBarColour:SetCallback("OnValueChanged", function(widget, event, r, g, b, a) PowerBar.Colour = {r, g, b, a} MilaUI:UpdateFrames() end)
            PowerBarColour:SetHasAlpha(true)
            PowerBarColour:SetRelativeWidth(0.25)
            PowerBarOptionsContainer:AddChild(PowerBarColour)

            local PowerBarBackdropColour = MilaUI_GUI:Create("ColorPicker")
            PowerBarBackdropColour:SetLabel("Background Colour")
            local PBBR, PBBG, PBBB, PBBA = unpack(PowerBar.BackgroundColour)
            PowerBarBackdropColour:SetColor(PBBR, PBBG, PBBB, PBBA)
            PowerBarBackdropColour:SetCallback("OnValueChanged", function(widget, event, r, g, b, a) PowerBar.BackgroundColour = {r, g, b, a} MilaUI:UpdateFrames() end)
            PowerBarBackdropColour:SetHasAlpha(true)
            PowerBarBackdropColour:SetRelativeWidth(0.25)
            PowerBarOptionsContainer:AddChild(PowerBarBackdropColour)


            PowerBarOptionsContainer:AddChild(BackgroundColourMultiplier)

            local PowerBarHeight = MilaUI_GUI:Create("Slider")
            PowerBarHeight:SetLabel("Height")
            PowerBarHeight:SetSliderValues(1, 64, 1)
            PowerBarHeight:SetValue(PowerBar.Height)
            PowerBarHeight:SetCallback("OnMouseUp", function(widget, event, value) PowerBar.Height = value MilaUI:UpdateFrames() end)
            PowerBarHeight:SetRelativeWidth(0.5)
            PowerBarOptionsContainer:AddChild(PowerBarHeight)

            if not Frame.Enabled then
                if FrameOptions then
                    for _, child in ipairs(FrameOptions.children) do
                        if child.SetDisabled then
                            child:SetDisabled(true)
                        end
                    end
                end
                if PortraitOptions then
                    for _, child in ipairs(PortraitOptions.children) do
                        if child.SetDisabled then
                            child:SetDisabled(true)
                        end
                    end
                end
                if HealthOptionsContainer then
                    for _, child in ipairs(HealthOptionsContainer.children) do
                        if child.SetDisabled then
                            child:SetDisabled(true)
                        end
                    end
                end
                if AbsorbsContainer then
                    for _, child in ipairs(AbsorbsContainer.children) do
                        if child.SetDisabled then
                            child:SetDisabled(true)
                        end
                    end
                end
                if HealAbsorbsContainer then
                    for _, child in ipairs(HealAbsorbsContainer.children) do
                        if child.SetDisabled then
                            child:SetDisabled(true)
                        end
                    end
                end
                if PowerBarOptionsContainer then
                    for _, child in ipairs(PowerBarOptionsContainer.children) do
                        if child.SetDisabled then
                            child:SetDisabled(true)
                        end
                    end
                end
                return
            end
        end

        local function DrawBuffsContainer(MilaUI_GUI_Container)
            local BuffOptions = MilaUI_GUI:Create("InlineGroup")
            BuffOptions:SetTitle("Buff Options")
            BuffOptions:SetLayout("Flow")
            BuffOptions:SetFullWidth(true)
            MilaUI_GUI_Container:AddChild(BuffOptions)
    
            local BuffsEnabled = MilaUI_GUI:Create("CheckBox")
            BuffsEnabled:SetLabel("Enable Buffs")
            BuffsEnabled:SetValue(Buffs.Enabled)
            BuffsEnabled:SetCallback("OnValueChanged", function(widget, event, value) Buffs.Enabled = value MilaUI:CreateReloadPrompt() end)
            BuffsEnabled:SetRelativeWidth(0.5)
            BuffOptions:AddChild(BuffsEnabled)

            local OnlyShowPlayerBuffs = MilaUI_GUI:Create("CheckBox")
            OnlyShowPlayerBuffs:SetLabel("Only Show Player Buffs")
            OnlyShowPlayerBuffs:SetValue(Buffs.OnlyShowPlayer)
            OnlyShowPlayerBuffs:SetCallback("OnValueChanged", function(widget, event, value) Buffs.OnlyShowPlayer = value MilaUI:UpdateFrames() end)
            OnlyShowPlayerBuffs:SetRelativeWidth(0.5)
            BuffOptions:AddChild(OnlyShowPlayerBuffs)

            local BuffAnchorFrom = MilaUI_GUI:Create("Dropdown")
            BuffAnchorFrom:SetLabel("Anchor From")
            BuffAnchorFrom:SetList(AnchorPoints)
            BuffAnchorFrom:SetValue(Buffs.AnchorFrom)
            BuffAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) Buffs.AnchorFrom = value MilaUI:UpdateFrames() end)
            BuffAnchorFrom:SetRelativeWidth(0.5)
            BuffOptions:AddChild(BuffAnchorFrom)
    
            local BuffAnchorTo = MilaUI_GUI:Create("Dropdown")
            BuffAnchorTo:SetLabel("Anchor To")
            BuffAnchorTo:SetList(AnchorPoints)
            BuffAnchorTo:SetValue(Buffs.AnchorTo)
            BuffAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) Buffs.AnchorTo = value MilaUI:UpdateFrames() end)
            BuffAnchorTo:SetRelativeWidth(0.5)
            BuffOptions:AddChild(BuffAnchorTo)
    
            local BuffGrowthX = MilaUI_GUI:Create("Dropdown")
            BuffGrowthX:SetLabel("Growth Direction X")
            BuffGrowthX:SetList(GrowthX)
            BuffGrowthX:SetValue(Buffs.GrowthX)
            BuffGrowthX:SetCallback("OnValueChanged", function(widget, event, value) Buffs.GrowthX = value MilaUI:UpdateFrames() end)
            BuffGrowthX:SetRelativeWidth(0.5)
            BuffOptions:AddChild(BuffGrowthX)
    
            local BuffGrowthY = MilaUI_GUI:Create("Dropdown")
            BuffGrowthY:SetLabel("Growth Direction Y")
            BuffGrowthY:SetList(GrowthY)
            BuffGrowthY:SetValue(Buffs.GrowthY)
            BuffGrowthY:SetCallback("OnValueChanged", function(widget, event, value) Buffs.GrowthY = value MilaUI:UpdateFrames() end)
            BuffGrowthY:SetRelativeWidth(0.5)
            BuffOptions:AddChild(BuffGrowthY)

            local BuffSize = MilaUI_GUI:Create("Slider")
            BuffSize:SetLabel("Size")
            BuffSize:SetSliderValues(-1, 64, 1)
            BuffSize:SetValue(Buffs.Size)
            BuffSize:SetCallback("OnMouseUp", function(widget, event, value) Buffs.Size = value MilaUI:UpdateFrames() end)
            BuffSize:SetRelativeWidth(0.33)
            BuffOptions:AddChild(BuffSize)

            local BuffSpacing = MilaUI_GUI:Create("Slider")
            BuffSpacing:SetLabel("Spacing")
            BuffSpacing:SetSliderValues(-1, 64, 1)
            BuffSpacing:SetValue(Buffs.Spacing)
            BuffSpacing:SetCallback("OnMouseUp", function(widget, event, value) Buffs.Spacing = value MilaUI:UpdateFrames() end)
            BuffSpacing:SetRelativeWidth(0.33)
            BuffOptions:AddChild(BuffSpacing)

            local BuffNum = MilaUI_GUI:Create("Slider")
            BuffNum:SetLabel("Amount To Show")
            BuffNum:SetSliderValues(1, 64, 1)
            BuffNum:SetValue(Buffs.Num)
            BuffNum:SetCallback("OnMouseUp", function(widget, event, value) Buffs.Num = value MilaUI:UpdateFrames() end)
            BuffNum:SetRelativeWidth(0.33)
            BuffOptions:AddChild(BuffNum)
    
            local BuffXOffset = MilaUI_GUI:Create("Slider")
            BuffXOffset:SetLabel("Buff X Offset")
            BuffXOffset:SetSliderValues(-64, 64, 1)
            BuffXOffset:SetValue(Buffs.XOffset)
            BuffXOffset:SetCallback("OnMouseUp", function(widget, event, value) Buffs.XOffset = value MilaUI:UpdateFrames() end)
            BuffXOffset:SetRelativeWidth(0.5)
            BuffOptions:AddChild(BuffXOffset)
    
            local BuffYOffset = MilaUI_GUI:Create("Slider")
            BuffYOffset:SetLabel("Buff Y Offset")
            BuffYOffset:SetSliderValues(-64, 64, 1)
            BuffYOffset:SetValue(Buffs.YOffset)
            BuffYOffset:SetCallback("OnMouseUp", function(widget, event, value) Buffs.YOffset = value MilaUI:UpdateFrames() end)
            BuffYOffset:SetRelativeWidth(0.5)
            BuffOptions:AddChild(BuffYOffset)

            local BuffCountOptions = MilaUI_GUI:Create("InlineGroup")
            BuffCountOptions:SetTitle("Buff Count Options")
            BuffCountOptions:SetLayout("Flow")
            BuffCountOptions:SetFullWidth(true)
            BuffOptions:AddChild(BuffCountOptions)

            local BuffCountAnchorFrom = MilaUI_GUI:Create("Dropdown")
            BuffCountAnchorFrom:SetLabel("Anchor From")
            BuffCountAnchorFrom:SetList(AnchorPoints)
            BuffCountAnchorFrom:SetValue(Buffs.Count.AnchorFrom)
            BuffCountAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) Buffs.Count.AnchorFrom = value MilaUI:UpdateFrames() end)
            BuffCountAnchorFrom:SetRelativeWidth(0.5)
            BuffCountOptions:AddChild(BuffCountAnchorFrom)

            local BuffCountAnchorTo = MilaUI_GUI:Create("Dropdown")
            BuffCountAnchorTo:SetLabel("Anchor To")
            BuffCountAnchorTo:SetList(AnchorPoints)
            BuffCountAnchorTo:SetValue(Buffs.Count.AnchorTo)
            BuffCountAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) Buffs.Count.AnchorTo = value MilaUI:UpdateFrames() end)
            BuffCountAnchorTo:SetRelativeWidth(0.5)
            BuffCountOptions:AddChild(BuffCountAnchorTo)

            local BuffCountXOffset = MilaUI_GUI:Create("Slider")
            BuffCountXOffset:SetLabel("Buff Count X Offset")
            BuffCountXOffset:SetSliderValues(-64, 64, 1)
            BuffCountXOffset:SetValue(Buffs.Count.XOffset)
            BuffCountXOffset:SetCallback("OnMouseUp", function(widget, event, value) Buffs.Count.XOffset = value MilaUI:UpdateFrames() end)
            BuffCountXOffset:SetRelativeWidth(0.25)
            BuffCountOptions:AddChild(BuffCountXOffset)

            local BuffCountYOffset = MilaUI_GUI:Create("Slider")
            BuffCountYOffset:SetLabel("Buff Count Y Offset")
            BuffCountYOffset:SetSliderValues(-64, 64, 1)
            BuffCountYOffset:SetValue(Buffs.Count.YOffset)
            BuffCountYOffset:SetCallback("OnMouseUp", function(widget, event, value) Buffs.Count.YOffset = value MilaUI:UpdateFrames() end)
            BuffCountYOffset:SetRelativeWidth(0.25)
            BuffCountOptions:AddChild(BuffCountYOffset)

            local BuffCountFontSize = MilaUI_GUI:Create("Slider")
            BuffCountFontSize:SetLabel("Font Size")
            BuffCountFontSize:SetSliderValues(1, 64, 1)
            BuffCountFontSize:SetValue(Buffs.Count.FontSize)
            BuffCountFontSize:SetCallback("OnMouseUp", function(widget, event, value) Buffs.Count.FontSize = value MilaUI:UpdateFrames() end)
            BuffCountFontSize:SetRelativeWidth(0.25)
            BuffCountOptions:AddChild(BuffCountFontSize)

            local BuffCountColour = MilaUI_GUI:Create("ColorPicker")
            BuffCountColour:SetLabel("Colour")
            local BCR, BCG, BCB, BCA = unpack(Buffs.Count.Colour)
            BuffCountColour:SetColor(BCR, BCG, BCB, BCA)
            BuffCountColour:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) Buffs.Count.Colour = {r, g, b, a} MilaUI:UpdateFrames() end)
            BuffCountColour:SetHasAlpha(true)
            BuffCountColour:SetRelativeWidth(0.25)
            BuffCountOptions:AddChild(BuffCountColour)
        end

        local function DrawDebuffsContainer(MilaUI_GUI_Container)
            local DebuffOptions = MilaUI_GUI:Create("InlineGroup")
            DebuffOptions:SetTitle("Debuff Options")
            DebuffOptions:SetLayout("Flow")
            DebuffOptions:SetFullWidth(true)
            MilaUI_GUI_Container:AddChild(DebuffOptions)
    
            local DebuffsEnabled = MilaUI_GUI:Create("CheckBox")
            DebuffsEnabled:SetLabel("Enable Debuffs")
            DebuffsEnabled:SetValue(Debuffs.Enabled)
            DebuffsEnabled:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.Enabled = value MilaUI:CreateReloadPrompt() end)
            DebuffsEnabled:SetRelativeWidth(0.5)
            DebuffOptions:AddChild(DebuffsEnabled)

            local OnlyShowPlayerDebuffs = MilaUI_GUI:Create("CheckBox")
            OnlyShowPlayerDebuffs:SetLabel("Only Show Player Debuffs")
            OnlyShowPlayerDebuffs:SetValue(Debuffs.OnlyShowPlayer)
            OnlyShowPlayerDebuffs:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.OnlyShowPlayer = value MilaUI:UpdateFrames() end)
            OnlyShowPlayerDebuffs:SetRelativeWidth(0.5)
            DebuffOptions:AddChild(OnlyShowPlayerDebuffs)

            local DebuffAnchorFrom = MilaUI_GUI:Create("Dropdown")
            DebuffAnchorFrom:SetLabel("Anchor From")
            DebuffAnchorFrom:SetList(AnchorPoints)
            DebuffAnchorFrom:SetValue(Debuffs.AnchorFrom)
            DebuffAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.AnchorFrom = value MilaUI:UpdateFrames() end)
            DebuffAnchorFrom:SetRelativeWidth(0.5)
            DebuffOptions:AddChild(DebuffAnchorFrom)
    
            local DebuffAnchorTo = MilaUI_GUI:Create("Dropdown")
            DebuffAnchorTo:SetLabel("Anchor To")
            DebuffAnchorTo:SetList(AnchorPoints)
            DebuffAnchorTo:SetValue(Debuffs.AnchorTo)
            DebuffAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.AnchorTo = value MilaUI:UpdateFrames() end)
            DebuffAnchorTo:SetRelativeWidth(0.5)
            DebuffOptions:AddChild(DebuffAnchorTo)
    
            local DebuffGrowthX = MilaUI_GUI:Create("Dropdown")
            DebuffGrowthX:SetLabel("Growth Direction X")
            DebuffGrowthX:SetList(GrowthX)
            DebuffGrowthX:SetValue(Debuffs.GrowthX)
            DebuffGrowthX:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.GrowthX = value MilaUI:UpdateFrames() end)
            DebuffGrowthX:SetRelativeWidth(0.5)
            DebuffOptions:AddChild(DebuffGrowthX)
    
            local DebuffGrowthY = MilaUI_GUI:Create("Dropdown")
            DebuffGrowthY:SetLabel("Growth Direction Y")
            DebuffGrowthY:SetList(GrowthY)
            DebuffGrowthY:SetValue(Debuffs.GrowthY)
            DebuffGrowthY:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.GrowthY = value MilaUI:UpdateFrames() end)
            DebuffGrowthY:SetRelativeWidth(0.5)
            DebuffOptions:AddChild(DebuffGrowthY)

            local DebuffSize = MilaUI_GUI:Create("Slider")
            DebuffSize:SetLabel("Size")
            DebuffSize:SetSliderValues(-1, 64, 1)
            DebuffSize:SetValue(Debuffs.Size)
            DebuffSize:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.Size = value MilaUI:UpdateFrames() end)
            DebuffSize:SetRelativeWidth(0.33)
            DebuffOptions:AddChild(DebuffSize)

            local DebuffSpacing = MilaUI_GUI:Create("Slider")
            DebuffSpacing:SetLabel("Spacing")
            DebuffSpacing:SetSliderValues(-1, 64, 1)
            DebuffSpacing:SetValue(Debuffs.Spacing)
            DebuffSpacing:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.Spacing = value MilaUI:UpdateFrames() end)
            DebuffSpacing:SetRelativeWidth(0.33)
            DebuffOptions:AddChild(DebuffSpacing)

            local DebuffNum = MilaUI_GUI:Create("Slider")
            DebuffNum:SetLabel("Amount To Show")
            DebuffNum:SetSliderValues(1, 64, 1)
            DebuffNum:SetValue(Debuffs.Num)
            DebuffNum:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.Num = value MilaUI:UpdateFrames() end)
            DebuffNum:SetRelativeWidth(0.33)
            DebuffOptions:AddChild(DebuffNum)
    
            local DebuffXOffset = MilaUI_GUI:Create("Slider")
            DebuffXOffset:SetLabel("Debuff X Offset")
            DebuffXOffset:SetSliderValues(-64, 64, 1)
            DebuffXOffset:SetValue(Debuffs.XOffset)
            DebuffXOffset:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.XOffset = value MilaUI:UpdateFrames() end)
            DebuffXOffset:SetRelativeWidth(0.5)
            DebuffOptions:AddChild(DebuffXOffset)
    
            local DebuffYOffset = MilaUI_GUI:Create("Slider")
            DebuffYOffset:SetLabel("Debuff Y Offset")
            DebuffYOffset:SetSliderValues(-64, 64, 1)
            DebuffYOffset:SetValue(Debuffs.YOffset)
            DebuffYOffset:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.YOffset = value MilaUI:UpdateFrames() end)
            DebuffYOffset:SetRelativeWidth(0.5)
            DebuffOptions:AddChild(DebuffYOffset)

            local DebuffCountOptions = MilaUI_GUI:Create("InlineGroup")
            DebuffCountOptions:SetTitle("Buff Count Options")
            DebuffCountOptions:SetLayout("Flow")
            DebuffCountOptions:SetFullWidth(true)
            DebuffOptions:AddChild(DebuffCountOptions)

            local DebuffCountAnchorFrom = MilaUI_GUI:Create("Dropdown")
            DebuffCountAnchorFrom:SetLabel("Anchor From")
            DebuffCountAnchorFrom:SetList(AnchorPoints)
            DebuffCountAnchorFrom:SetValue(Debuffs.Count.AnchorFrom)
            DebuffCountAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.Count.AnchorFrom = value MilaUI:UpdateFrames() end)
            DebuffCountAnchorFrom:SetRelativeWidth(0.5)
            DebuffCountOptions:AddChild(DebuffCountAnchorFrom)

            local DebuffCountAnchorTo = MilaUI_GUI:Create("Dropdown")
            DebuffCountAnchorTo:SetLabel("Anchor To")
            DebuffCountAnchorTo:SetList(AnchorPoints)
            DebuffCountAnchorTo:SetValue(Debuffs.Count.AnchorTo)
            DebuffCountAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) Debuffs.Count.AnchorTo = value MilaUI:UpdateFrames() end)
            DebuffCountAnchorTo:SetRelativeWidth(0.5)
            DebuffCountOptions:AddChild(DebuffCountAnchorTo)

            local DebuffCountXOffset = MilaUI_GUI:Create("Slider")
            DebuffCountXOffset:SetLabel("Buff Count X Offset")
            DebuffCountXOffset:SetSliderValues(-64, 64, 1)
            DebuffCountXOffset:SetValue(Debuffs.Count.XOffset)
            DebuffCountXOffset:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.Count.XOffset = value MilaUI:UpdateFrames() end)
            DebuffCountXOffset:SetRelativeWidth(0.25)
            DebuffCountOptions:AddChild(DebuffCountXOffset)

            local DebuffCountYOffset = MilaUI_GUI:Create("Slider")
            DebuffCountYOffset:SetLabel("Buff Count Y Offset")
            DebuffCountYOffset:SetSliderValues(-64, 64, 1)
            DebuffCountYOffset:SetValue(Debuffs.Count.YOffset)
            DebuffCountYOffset:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.Count.YOffset = value MilaUI:UpdateFrames() end)
            DebuffCountYOffset:SetRelativeWidth(0.25)
            DebuffCountOptions:AddChild(DebuffCountYOffset)

            local DebuffCountFontSize = MilaUI_GUI:Create("Slider")
            DebuffCountFontSize:SetLabel("Font Size")
            DebuffCountFontSize:SetSliderValues(1, 64, 1)
            DebuffCountFontSize:SetValue(Debuffs.Count.FontSize)
            DebuffCountFontSize:SetCallback("OnMouseUp", function(widget, event, value) Debuffs.Count.FontSize = value MilaUI:UpdateFrames() end)
            DebuffCountFontSize:SetRelativeWidth(0.25)
            DebuffCountOptions:AddChild(DebuffCountFontSize)

            local DebuffCountColour = MilaUI_GUI:Create("ColorPicker")
            DebuffCountColour:SetLabel("Colour")
            local DCR, DCG, DCB, DCA = unpack(Debuffs.Count.Colour)
            DebuffCountColour:SetColor(DCR, DCG, DCB, DCA)
            DebuffCountColour:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) Debuffs.Count.Colour = {r, g, b, a} MilaUI:UpdateFrames() end)
            DebuffCountColour:SetHasAlpha(true)
            DebuffCountColour:SetRelativeWidth(0.25)
            DebuffCountOptions:AddChild(DebuffCountColour)
        end

        local function DrawIndicatorContainer(MilaUI_GUI_Container)
            local IndicatorOptions = MilaUI_GUI:Create("InlineGroup")
            IndicatorOptions:SetTitle("Indicator Options")
            IndicatorOptions:SetLayout("Flow")
            IndicatorOptions:SetFullWidth(true)
            MilaUI_GUI_Container:AddChild(IndicatorOptions)

            local TargetMarkerOptions = MilaUI_GUI:Create("InlineGroup")
            TargetMarkerOptions:SetTitle("Target Marker Options")
            TargetMarkerOptions:SetLayout("Flow")
            TargetMarkerOptions:SetFullWidth(true)
            IndicatorOptions:AddChild(TargetMarkerOptions)

            local TargetMarkerEnabled = MilaUI_GUI:Create("CheckBox")
            TargetMarkerEnabled:SetLabel("Enable Target Marker")
            TargetMarkerEnabled:SetValue(TargetMarker.Enabled)
            TargetMarkerEnabled:SetCallback("OnValueChanged", function(widget, event, value) TargetMarker.Enabled = value MilaUI:CreateReloadPrompt() end)
            TargetMarkerEnabled:SetFullWidth(true)
            TargetMarkerOptions:AddChild(TargetMarkerEnabled)

            local TargetMarkerAnchorFrom = MilaUI_GUI:Create("Dropdown")
            TargetMarkerAnchorFrom:SetLabel("Anchor From")
            TargetMarkerAnchorFrom:SetList(AnchorPoints)
            TargetMarkerAnchorFrom:SetValue(TargetMarker.AnchorFrom)
            TargetMarkerAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) TargetMarker.AnchorFrom = value MilaUI:UpdateFrames() end)
            TargetMarkerAnchorFrom:SetRelativeWidth(0.5)
            TargetMarkerOptions:AddChild(TargetMarkerAnchorFrom)

            local TargetMarkerAnchorTo = MilaUI_GUI:Create("Dropdown")
            TargetMarkerAnchorTo:SetLabel("Anchor To")
            TargetMarkerAnchorTo:SetList(AnchorPoints)
            TargetMarkerAnchorTo:SetValue(TargetMarker.AnchorTo)
            TargetMarkerAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) TargetMarker.AnchorTo = value MilaUI:UpdateFrames() end)
            TargetMarkerAnchorTo:SetRelativeWidth(0.5)
            TargetMarkerOptions:AddChild(TargetMarkerAnchorTo)

            local TargetMarkerSize = MilaUI_GUI:Create("Slider")
            TargetMarkerSize:SetLabel("Size")
            TargetMarkerSize:SetSliderValues(-1, 64, 1)
            TargetMarkerSize:SetValue(TargetMarker.Size)
            TargetMarkerSize:SetCallback("OnMouseUp", function(widget, event, value) TargetMarker.Size = value MilaUI:UpdateFrames() end)
            TargetMarkerSize:SetRelativeWidth(0.33)
            TargetMarkerOptions:AddChild(TargetMarkerSize)

            local TargetMarkerXOffset = MilaUI_GUI:Create("Slider")
            TargetMarkerXOffset:SetLabel("X Offset")
            TargetMarkerXOffset:SetSliderValues(-64, 64, 1)
            TargetMarkerXOffset:SetValue(TargetMarker.XOffset)
            TargetMarkerXOffset:SetCallback("OnMouseUp", function(widget, event, value) TargetMarker.XOffset = value MilaUI:UpdateFrames() end)
            TargetMarkerXOffset:SetRelativeWidth(0.33)
            TargetMarkerOptions:AddChild(TargetMarkerXOffset)

            local TargetMarkerYOffset = MilaUI_GUI:Create("Slider")
            TargetMarkerYOffset:SetLabel("Y Offset")
            TargetMarkerYOffset:SetSliderValues(-64, 64, 1)
            TargetMarkerYOffset:SetValue(TargetMarker.YOffset)
            TargetMarkerYOffset:SetCallback("OnMouseUp", function(widget, event, value) TargetMarker.YOffset = value MilaUI:UpdateFrames() end)
            TargetMarkerYOffset:SetRelativeWidth(0.33)
            TargetMarkerOptions:AddChild(TargetMarkerYOffset)

            if Unit == "Player" then
                local CombatIndicatorOptions = MilaUI_GUI:Create("InlineGroup")
                CombatIndicatorOptions:SetTitle("Combat Indicator Options")
                CombatIndicatorOptions:SetLayout("Flow")
                CombatIndicatorOptions:SetFullWidth(true)
                IndicatorOptions:AddChild(CombatIndicatorOptions)

                local CombatIndicatorEnabled = MilaUI_GUI:Create("CheckBox")
                CombatIndicatorEnabled:SetLabel("Enable Combat Indicator")
                CombatIndicatorEnabled:SetValue(CombatIndicator.Enabled)
                CombatIndicatorEnabled:SetCallback("OnValueChanged", function(widget, event, value) CombatIndicator.Enabled = value MilaUI:CreateReloadPrompt() end)
                CombatIndicatorEnabled:SetRelativeWidth(1)
                CombatIndicatorOptions:AddChild(CombatIndicatorEnabled)

                local CombatIndicatorAnchorFrom = MilaUI_GUI:Create("Dropdown")
                CombatIndicatorAnchorFrom:SetLabel("Anchor From")
                CombatIndicatorAnchorFrom:SetList(AnchorPoints)
                CombatIndicatorAnchorFrom:SetValue(CombatIndicator.AnchorFrom)
                CombatIndicatorAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) CombatIndicator.AnchorFrom = value MilaUI:UpdateFrames() end)
                CombatIndicatorAnchorFrom:SetRelativeWidth(0.5)
                CombatIndicatorOptions:AddChild(CombatIndicatorAnchorFrom)

                local CombatIndicatorAnchorTo = MilaUI_GUI:Create("Dropdown")
                CombatIndicatorAnchorTo:SetLabel("Anchor To")
                CombatIndicatorAnchorTo:SetList(AnchorPoints)
                CombatIndicatorAnchorTo:SetValue(CombatIndicator.AnchorTo)
                CombatIndicatorAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) CombatIndicator.AnchorTo = value MilaUI:UpdateFrames() end)
                CombatIndicatorAnchorTo:SetRelativeWidth(0.5)
                CombatIndicatorOptions:AddChild(CombatIndicatorAnchorTo)

                local CombatIndicatorSize = MilaUI_GUI:Create("Slider")
                CombatIndicatorSize:SetLabel("Size")
                CombatIndicatorSize:SetSliderValues(-1, 64, 1)
                CombatIndicatorSize:SetValue(CombatIndicator.Size)
                CombatIndicatorSize:SetCallback("OnMouseUp", function(widget, event, value) CombatIndicator.Size = value MilaUI:UpdateFrames() end)
                CombatIndicatorSize:SetRelativeWidth(0.33)
                CombatIndicatorOptions:AddChild(CombatIndicatorSize)

                local CombatIndicatorXOffset = MilaUI_GUI:Create("Slider")
                CombatIndicatorXOffset:SetLabel("X Offset")
                CombatIndicatorXOffset:SetSliderValues(-64, 64, 1)
                CombatIndicatorXOffset:SetValue(CombatIndicator.XOffset)
                CombatIndicatorXOffset:SetCallback("OnMouseUp", function(widget, event, value) CombatIndicator.XOffset = value MilaUI:UpdateFrames() end)
                CombatIndicatorXOffset:SetRelativeWidth(0.33)
                CombatIndicatorOptions:AddChild(CombatIndicatorXOffset)

                local CombatIndicatorYOffset = MilaUI_GUI:Create("Slider")
                CombatIndicatorYOffset:SetLabel("Y Offset")
                CombatIndicatorYOffset:SetSliderValues(-64, 64, 1)
                CombatIndicatorYOffset:SetValue(CombatIndicator.YOffset)
                CombatIndicatorYOffset:SetCallback("OnMouseUp", function(widget, event, value) CombatIndicator.YOffset = value MilaUI:UpdateFrames() end)
                CombatIndicatorYOffset:SetRelativeWidth(0.33)
                CombatIndicatorOptions:AddChild(CombatIndicatorYOffset)
                
                -- Leader Indicator
                local LeaderIndicatorOptions = MilaUI_GUI:Create("InlineGroup")
                LeaderIndicatorOptions:SetTitle("Leader Indicator Options")
                LeaderIndicatorOptions:SetLayout("Flow")
                LeaderIndicatorOptions:SetFullWidth(true)
                IndicatorOptions:AddChild(LeaderIndicatorOptions)

                local LeaderIndicatorEnabled = MilaUI_GUI:Create("CheckBox")
                LeaderIndicatorEnabled:SetLabel("Enable Leader Indicator")
                LeaderIndicatorEnabled:SetValue(LeaderIndicator.Enabled)
                LeaderIndicatorEnabled:SetCallback("OnValueChanged", function(widget, event, value) LeaderIndicator.Enabled = value MilaUI:CreateReloadPrompt() end)
                LeaderIndicatorEnabled:SetRelativeWidth(1)
                LeaderIndicatorOptions:AddChild(LeaderIndicatorEnabled)

                local LeaderIndicatorAnchorFrom = MilaUI_GUI:Create("Dropdown")
                LeaderIndicatorAnchorFrom:SetLabel("Anchor From")
                LeaderIndicatorAnchorFrom:SetList(AnchorPoints)
                LeaderIndicatorAnchorFrom:SetValue(LeaderIndicator.AnchorFrom)
                LeaderIndicatorAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) LeaderIndicator.AnchorFrom = value MilaUI:UpdateFrames() end)
                LeaderIndicatorAnchorFrom:SetRelativeWidth(0.5)
                LeaderIndicatorOptions:AddChild(LeaderIndicatorAnchorFrom)

                local LeaderIndicatorAnchorTo = MilaUI_GUI:Create("Dropdown")
                LeaderIndicatorAnchorTo:SetLabel("Anchor To")
                LeaderIndicatorAnchorTo:SetList(AnchorPoints)
                LeaderIndicatorAnchorTo:SetValue(LeaderIndicator.AnchorTo)
                LeaderIndicatorAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) LeaderIndicator.AnchorTo = value MilaUI:UpdateFrames() end)
                LeaderIndicatorAnchorTo:SetRelativeWidth(0.5)
                LeaderIndicatorOptions:AddChild(LeaderIndicatorAnchorTo)

                local LeaderIndicatorSize = MilaUI_GUI:Create("Slider")
                LeaderIndicatorSize:SetLabel("Size")
                LeaderIndicatorSize:SetSliderValues(-1, 64, 1)
                LeaderIndicatorSize:SetValue(LeaderIndicator.Size)
                LeaderIndicatorSize:SetCallback("OnMouseUp", function(widget, event, value) LeaderIndicator.Size = value MilaUI:UpdateFrames() end)
                LeaderIndicatorSize:SetRelativeWidth(0.33)
                LeaderIndicatorOptions:AddChild(LeaderIndicatorSize)

                local LeaderIndicatorXOffset = MilaUI_GUI:Create("Slider")
                LeaderIndicatorXOffset:SetLabel("X Offset")
                LeaderIndicatorXOffset:SetSliderValues(-64, 64, 1)
                LeaderIndicatorXOffset:SetValue(LeaderIndicator.XOffset)
                LeaderIndicatorXOffset:SetCallback("OnMouseUp", function(widget, event, value) LeaderIndicator.XOffset = value MilaUI:UpdateFrames() end)
                LeaderIndicatorXOffset:SetRelativeWidth(0.33)
                LeaderIndicatorOptions:AddChild(LeaderIndicatorXOffset)

                local LeaderIndicatorYOffset = MilaUI_GUI:Create("Slider")
                LeaderIndicatorYOffset:SetLabel("Y Offset")
                LeaderIndicatorYOffset:SetSliderValues(-64, 64, 1)
                LeaderIndicatorYOffset:SetValue(LeaderIndicator.YOffset)
                LeaderIndicatorYOffset:SetCallback("OnMouseUp", function(widget, event, value) LeaderIndicator.YOffset = value MilaUI:UpdateFrames() end)
                LeaderIndicatorYOffset:SetRelativeWidth(0.33)
                LeaderIndicatorOptions:AddChild(LeaderIndicatorYOffset)
            end

            if Unit == "Boss" then
                local TargetIndicatorOptions = MilaUI_GUI:Create("InlineGroup")
                TargetIndicatorOptions:SetTitle("Combat Indicator Options")
                TargetIndicatorOptions:SetLayout("Flow")
                TargetIndicatorOptions:SetFullWidth(true)
                IndicatorOptions:AddChild(TargetIndicatorOptions)

                local TargetIndicatorEnabled = MilaUI_GUI:Create("CheckBox")
                TargetIndicatorEnabled:SetLabel("Enable Target Indicator")
                TargetIndicatorEnabled:SetValue(TargetIndicator.Enabled)
                TargetIndicatorEnabled:SetCallback("OnValueChanged", function(widget, event, value) TargetIndicator.Enabled = value MilaUI:CreateReloadPrompt() end)
                TargetIndicatorEnabled:SetRelativeWidth(1)
                TargetIndicatorOptions:AddChild(TargetIndicatorEnabled)
            end
        end

        local function DrawTextsContainer(MilaUI_GUI_Container)
            local TextOptions = MilaUI_GUI:Create("InlineGroup")
            TextOptions:SetTitle("Text Options")
            TextOptions:SetLayout("Flow")
            TextOptions:SetFullWidth(true)
            MilaUI_GUI_Container:AddChild(TextOptions)

            local FirstTextOptions = MilaUI_GUI:Create("InlineGroup")
            FirstTextOptions:SetTitle("First Text Options")
            FirstTextOptions:SetLayout("Flow")
            FirstTextOptions:SetFullWidth(true)
            TextOptions:AddChild(FirstTextOptions)

            local FirstTextAnchorTo = MilaUI_GUI:Create("Dropdown")
            FirstTextAnchorTo:SetLabel("Anchor From")
            FirstTextAnchorTo:SetList(AnchorPoints)
            FirstTextAnchorTo:SetValue(FirstText.AnchorFrom)
            FirstTextAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) FirstText.AnchorFrom = value MilaUI:UpdateFrames() end)
            FirstTextAnchorTo:SetRelativeWidth(0.5)
            FirstTextOptions:AddChild(FirstTextAnchorTo)

            local FirstTextAnchorFrom = MilaUI_GUI:Create("Dropdown")
            FirstTextAnchorFrom:SetLabel("Anchor To")
            FirstTextAnchorFrom:SetList(AnchorPoints)
            FirstTextAnchorFrom:SetValue(FirstText.AnchorTo)
            FirstTextAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) FirstText.AnchorTo = value MilaUI:UpdateFrames() end)
            FirstTextAnchorFrom:SetRelativeWidth(0.5)
            FirstTextOptions:AddChild(FirstTextAnchorFrom)

            local FirstTextXOffset = MilaUI_GUI:Create("Slider")
            FirstTextXOffset:SetLabel("X Offset")
            FirstTextXOffset:SetSliderValues(-64, 64, 1)
            FirstTextXOffset:SetValue(FirstText.XOffset)
            FirstTextXOffset:SetCallback("OnMouseUp", function(widget, event, value) FirstText.XOffset = value MilaUI:UpdateFrames() end)
            FirstTextXOffset:SetRelativeWidth(0.25)
            FirstTextOptions:AddChild(FirstTextXOffset)

            local FirstTextYOffset = MilaUI_GUI:Create("Slider")
            FirstTextYOffset:SetLabel("Y Offset")
            FirstTextYOffset:SetSliderValues(-64, 64, 1)
            FirstTextYOffset:SetValue(FirstText.YOffset)
            FirstTextYOffset:SetCallback("OnMouseUp", function(widget, event, value) FirstText.YOffset = value MilaUI:UpdateFrames() end)
            FirstTextYOffset:SetRelativeWidth(0.25)
            FirstTextOptions:AddChild(FirstTextYOffset)

            local FirstTextFontSize = MilaUI_GUI:Create("Slider")
            FirstTextFontSize:SetLabel("Font Size")
            FirstTextFontSize:SetSliderValues(1, 64, 1)
            FirstTextFontSize:SetValue(FirstText.FontSize)
            FirstTextFontSize:SetCallback("OnMouseUp", function(widget, event, value) FirstText.FontSize = value MilaUI:UpdateFrames() end)
            FirstTextFontSize:SetRelativeWidth(0.25)
            FirstTextOptions:AddChild(FirstTextFontSize)

            local FirstTextColourPicker = MilaUI_GUI:Create("ColorPicker")
            FirstTextColourPicker:SetLabel("Colour")
            local FTR, FTG, FTB, FTA = unpack(FirstText.Colour)
            FirstTextColourPicker:SetColor(FTR, FTG, FTB, FTA)
            FirstTextColourPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a) FirstText.Colour = {r, g, b, a} MilaUI:UpdateFrames() end)
            FirstTextColourPicker:SetHasAlpha(true)
            FirstTextColourPicker:SetRelativeWidth(0.25)
            FirstTextOptions:AddChild(FirstTextColourPicker)

            local FirstTextTag = MilaUI_GUI:Create("EditBox")
            FirstTextTag:SetLabel("Tag")
            FirstTextTag:SetText(FirstText.Tag)
            FirstTextTag:SetCallback("OnEnterPressed", function(widget, event, value) FirstText.Tag = value MilaUI:UpdateFrames() end)
            FirstTextTag:SetRelativeWidth(1)
            FirstTextOptions:AddChild(FirstTextTag)

            local SecondTextOptions = MilaUI_GUI:Create("InlineGroup")
            SecondTextOptions:SetTitle("Second Text Options")
            SecondTextOptions:SetLayout("Flow")
            SecondTextOptions:SetFullWidth(true)
            TextOptions:AddChild(SecondTextOptions)

            local SecondTextAnchorTo = MilaUI_GUI:Create("Dropdown")
            SecondTextAnchorTo:SetLabel("Anchor From")
            SecondTextAnchorTo:SetList(AnchorPoints)
            SecondTextAnchorTo:SetValue(SecondText.AnchorFrom)
            SecondTextAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) SecondText.AnchorFrom = value MilaUI:UpdateFrames() end)
            SecondTextAnchorTo:SetRelativeWidth(0.5)
            SecondTextOptions:AddChild(SecondTextAnchorTo)

            local SecondTextAnchorFrom = MilaUI_GUI:Create("Dropdown")
            SecondTextAnchorFrom:SetLabel("Anchor To")
            SecondTextAnchorFrom:SetList(AnchorPoints)
            SecondTextAnchorFrom:SetValue(SecondText.AnchorTo)
            SecondTextAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) SecondText.AnchorTo = value MilaUI:UpdateFrames() end)
            SecondTextAnchorFrom:SetRelativeWidth(0.5)
            SecondTextOptions:AddChild(SecondTextAnchorFrom)

            local SecondTextXOffset = MilaUI_GUI:Create("Slider")
            SecondTextXOffset:SetLabel("X Offset")
            SecondTextXOffset:SetSliderValues(-64, 64, 1)
            SecondTextXOffset:SetValue(SecondText.XOffset)
            SecondTextXOffset:SetCallback("OnMouseUp", function(widget, event, value) SecondText.XOffset = value MilaUI:UpdateFrames() end)
            SecondTextXOffset:SetRelativeWidth(0.25)
            SecondTextOptions:AddChild(SecondTextXOffset)

            local SecondTextYOffset = MilaUI_GUI:Create("Slider")
            SecondTextYOffset:SetLabel("Y Offset")
            SecondTextYOffset:SetSliderValues(-64, 64, 1)
            SecondTextYOffset:SetValue(SecondText.YOffset)
            SecondTextYOffset:SetCallback("OnMouseUp", function(widget, event, value) SecondText.YOffset = value MilaUI:UpdateFrames() end)
            SecondTextYOffset:SetRelativeWidth(0.25)
            SecondTextOptions:AddChild(SecondTextYOffset)

            local SecondTextFontSize = MilaUI_GUI:Create("Slider")
            SecondTextFontSize:SetLabel("Font Size")
            SecondTextFontSize:SetSliderValues(1, 64, 1)
            SecondTextFontSize:SetValue(SecondText.FontSize)
            SecondTextFontSize:SetCallback("OnMouseUp", function(widget, event, value) SecondText.FontSize = value MilaUI:UpdateFrames() end)
            SecondTextFontSize:SetRelativeWidth(0.25)
            SecondTextOptions:AddChild(SecondTextFontSize)

            local SecondTextColourPicker = MilaUI_GUI:Create("ColorPicker")
            SecondTextColourPicker:SetLabel("Colour")
            local STR, STG, STB, STA = unpack(SecondText.Colour)
            SecondTextColourPicker:SetColor(STR, STG, STB, STA)
            SecondTextColourPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a) SecondText.Colour = {r, g, b, a} MilaUI:UpdateFrames() end)
            SecondTextColourPicker:SetHasAlpha(true)
            SecondTextColourPicker:SetRelativeWidth(0.25)
            SecondTextOptions:AddChild(SecondTextColourPicker)

            local SecondTextTag = MilaUI_GUI:Create("EditBox")
            SecondTextTag:SetLabel("Tag")
            SecondTextTag:SetText(SecondText.Tag)
            SecondTextTag:SetCallback("OnEnterPressed", function(widget, event, value) SecondText.Tag = value MilaUI:UpdateFrames() end)
            SecondTextTag:SetRelativeWidth(1)
            SecondTextOptions:AddChild(SecondTextTag)

            local ThirdTextOptions = MilaUI_GUI:Create("InlineGroup")
            ThirdTextOptions:SetTitle("Third Text Options")
            ThirdTextOptions:SetLayout("Flow")
            ThirdTextOptions:SetFullWidth(true)
            TextOptions:AddChild(ThirdTextOptions)

            local ThirdTextAnchorTo = MilaUI_GUI:Create("Dropdown")
            ThirdTextAnchorTo:SetLabel("Anchor From")
            ThirdTextAnchorTo:SetList(AnchorPoints)
            ThirdTextAnchorTo:SetValue(ThirdText.AnchorFrom)
            ThirdTextAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) ThirdText.AnchorFrom = value MilaUI:UpdateFrames() end)
            ThirdTextAnchorTo:SetRelativeWidth(0.5)
            ThirdTextOptions:AddChild(ThirdTextAnchorTo)

            local ThirdTextAnchorFrom = MilaUI_GUI:Create("Dropdown")
            ThirdTextAnchorFrom:SetLabel("Anchor To")
            ThirdTextAnchorFrom:SetList(AnchorPoints)
            ThirdTextAnchorFrom:SetValue(ThirdText.AnchorTo)
            ThirdTextAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) ThirdText.AnchorTo = value MilaUI:UpdateFrames() end)
            ThirdTextAnchorFrom:SetRelativeWidth(0.5)
            ThirdTextOptions:AddChild(ThirdTextAnchorFrom)

            local ThirdTextXOffset = MilaUI_GUI:Create("Slider")
            ThirdTextXOffset:SetLabel("X Offset")
            ThirdTextXOffset:SetSliderValues(-64, 64, 1)
            ThirdTextXOffset:SetValue(ThirdText.XOffset)
            ThirdTextXOffset:SetCallback("OnMouseUp", function(widget, event, value) ThirdText.XOffset = value MilaUI:UpdateFrames() end)
            ThirdTextXOffset:SetRelativeWidth(0.25)
            ThirdTextOptions:AddChild(ThirdTextXOffset)

            local ThirdTextYOffset = MilaUI_GUI:Create("Slider")
            ThirdTextYOffset:SetLabel("Y Offset")
            ThirdTextYOffset:SetSliderValues(-64, 64, 1)
            ThirdTextYOffset:SetValue(ThirdText.YOffset)
            ThirdTextYOffset:SetCallback("OnMouseUp", function(widget, event, value) ThirdText.YOffset = value MilaUI:UpdateFrames() end)
            ThirdTextYOffset:SetRelativeWidth(0.25)
            ThirdTextOptions:AddChild(ThirdTextYOffset)

            local ThirdTextFontSize = MilaUI_GUI:Create("Slider")
            ThirdTextFontSize:SetLabel("Font Size")
            ThirdTextFontSize:SetSliderValues(1, 64, 1)
            ThirdTextFontSize:SetValue(ThirdText.FontSize)
            ThirdTextFontSize:SetCallback("OnMouseUp", function(widget, event, value) ThirdText.FontSize = value MilaUI:UpdateFrames() end)
            ThirdTextFontSize:SetRelativeWidth(0.25)
            ThirdTextOptions:AddChild(ThirdTextFontSize)

            local ThirdTextColourPicker = MilaUI_GUI:Create("ColorPicker")
            ThirdTextColourPicker:SetLabel("Colour")
            local TRTR, TRTG, TRTB, TRTA = unpack(ThirdText.Colour)
            ThirdTextColourPicker:SetColor(TRTR, TRTG, TRTB, TRTA)
            ThirdTextColourPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b, a) ThirdText.Colour = {r, g, b, a} MilaUI:UpdateFrames() end)
            ThirdTextColourPicker:SetHasAlpha(true)
            ThirdTextColourPicker:SetRelativeWidth(0.25)
            ThirdTextOptions:AddChild(ThirdTextColourPicker)

            local ThirdTextTag = MilaUI_GUI:Create("EditBox")
            ThirdTextTag:SetLabel("Tag")
            ThirdTextTag:SetText(ThirdText.Tag)
            ThirdTextTag:SetCallback("OnEnterPressed", function(widget, event, value) ThirdText.Tag = value MilaUI:UpdateFrames() end)
            ThirdTextTag:SetRelativeWidth(1)
            ThirdTextOptions:AddChild(ThirdTextTag)
            
        end

        local function DrawRangeContainer(MilaUI_GUI_Container)
            local RangeOptions = MilaUI_GUI:Create("InlineGroup")
            RangeOptions:SetTitle("Range Options")
            RangeOptions:SetLayout("Flow")
            RangeOptions:SetFullWidth(true)
            MilaUI_GUI_Container:AddChild(RangeOptions)

            local RangeEnabled = MilaUI_GUI:Create("CheckBox")
            RangeEnabled:SetLabel("Enable Range Indicator")
            RangeEnabled:SetValue(Range.Enable)
            RangeEnabled:SetCallback("OnValueChanged", function(widget, event, value) Range.Enable = value MilaUI:CreateReloadPrompt() end)
            RangeEnabled:SetFullWidth(true)
            RangeOptions:AddChild(RangeEnabled)

            local OOR = MilaUI_GUI:Create("Slider")
            OOR:SetLabel("Out of Range Alpha")
            OOR:SetSliderValues(0, 1, 0.01)
            OOR:SetValue(Range.OOR)
            OOR:SetCallback("OnMouseUp", function(widget, event, value) Range.OOR = value MilaUI:UpdateFrames() end)
            OOR:SetRelativeWidth(0.5)
            RangeOptions:AddChild(OOR)

            local IR = MilaUI_GUI:Create("Slider")
            IR:SetLabel("In Range Alpha")
            IR:SetSliderValues(0, 1, 0.01)
            IR:SetValue(Range.IR)
            IR:SetCallback("OnMouseUp", function(widget, event, value) Range.IR = value MilaUI:UpdateFrames() end)
            IR:SetRelativeWidth(0.5)
            RangeOptions:AddChild(IR)
        end

        local function SelectedGroup(MilaUI_GUI_Container, Event, Group)
            MilaUI_GUI_Container:ReleaseChildren()
            if Group == "Frame" then
                DrawFrameContainer(MilaUI_GUI_Container)
            elseif Group == "Texts" then
                DrawTextsContainer(MilaUI_GUI_Container)
            elseif Group == "Buffs" then
                DrawBuffsContainer(MilaUI_GUI_Container)
            elseif Group == "Debuffs" then
                DrawDebuffsContainer(MilaUI_GUI_Container)
            elseif Group == "Indicators" then
                DrawIndicatorContainer(MilaUI_GUI_Container)
            elseif Unit ~= "player" and Group == "Range" then
                DrawRangeContainer(MilaUI_GUI_Container)
            end
        end

        GUIContainerTabGroup = MilaUI_GUI:Create("TabGroup")
        GUIContainerTabGroup:SetLayout("Flow")
        local ContainerTabs = {
            { text = "Frame",            value = "Frame" },
            { text = "Texts",            value = "Texts" },
            { text = "Buffs",            value = "Buffs" },
            { text = "Debuffs",          value = "Debuffs" },
            { text = "Indicators",       value = "Indicators" },
        }
        if Unit ~= "Player" then
            table.insert(ContainerTabs, { text = "Range", value = "Range" })
        end
        if not Frame.Enabled then
            for i = 1, #ContainerTabs do
                if ContainerTabs[i].value ~= "Frame" then
                    ContainerTabs[i].disabled = true
                end
            end
        end
        GUIContainerTabGroup:SetTabs(ContainerTabs)
        
        GUIContainerTabGroup:SetCallback("OnGroupSelected", SelectedGroup)
        GUIContainerTabGroup:SelectTab("Frame")
        GUIContainerTabGroup:SetFullWidth(true)
        ScrollableContainer:AddChild(GUIContainerTabGroup)
    end

    local function DrawTagsContainer(MilaUI_GUI_Container)
        local ScrollableContainer = MilaUI_GUI:Create("ScrollFrame")
        ScrollableContainer:SetLayout("Flow")
        ScrollableContainer:SetFullWidth(true)
        ScrollableContainer:SetFullHeight(true)
        MilaUI_GUI_Container:AddChild(ScrollableContainer)

        local TagUpdateInterval = MilaUI_GUI:Create("Slider")
        TagUpdateInterval:SetLabel("Tag Update Interval")
        TagUpdateInterval:SetSliderValues(0, 1, 0.1)
        TagUpdateInterval:SetValue(MilaUI.DB.global.TagUpdateInterval)
        TagUpdateInterval:SetCallback("OnMouseUp", function(widget, event, value) MilaUI.DB.global.TagUpdateInterval = value MilaUI:SetTagUpdateInterval() end)
        TagUpdateInterval:SetRelativeWidth(1)
        ScrollableContainer:AddChild(TagUpdateInterval)

        local function DrawHealthTagContainer(MilaUI_GUI_Container)
            local HealthTags = MilaUI:FetchHealthTagDescriptions()

            local HealthTagOptions = MilaUI_GUI:Create("InlineGroup")
            HealthTagOptions:SetTitle("Health Tags")
            HealthTagOptions:SetLayout("Flow")
            HealthTagOptions:SetFullWidth(true)
            MilaUI_GUI_Container:AddChild(HealthTagOptions)

            for Title, TableData in pairs(HealthTags) do
                local Tag, Desc = TableData.Tag, TableData.Desc
                HealthTagTitle = MilaUI_GUI:Create("Heading")
                HealthTagTitle:SetText(Title)
                HealthTagTitle:SetRelativeWidth(1)
                HealthTagOptions:AddChild(HealthTagTitle)

                local HealthTagTag = MilaUI_GUI:Create("EditBox")
                HealthTagTag:SetText(Tag)
                HealthTagTag:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                HealthTagTag:SetRelativeWidth(0.25)
                HealthTagOptions:AddChild(HealthTagTag)

                HealthTagDescription = MilaUI_GUI:Create("EditBox")
                HealthTagDescription:SetText(Desc)
                HealthTagDescription:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                HealthTagDescription:SetRelativeWidth(0.75)
                HealthTagOptions:AddChild(HealthTagDescription)
            end
        end

        local function DrawPowerTagsContainer(MilaUI_GUI_Container)
            local PowerTags = MilaUI:FetchPowerTagDescriptions()

            local PowerTagOptions = MilaUI_GUI:Create("InlineGroup")
            PowerTagOptions:SetTitle("Power Tags")
            PowerTagOptions:SetLayout("Flow")
            PowerTagOptions:SetFullWidth(true)
            MilaUI_GUI_Container:AddChild(PowerTagOptions)

            for Title, TableData in pairs(PowerTags) do
                local Tag, Desc = TableData.Tag, TableData.Desc
                PowerTagTitle = MilaUI_GUI:Create("Label")
                PowerTagTitle:SetText(Title)
                PowerTagTitle:SetRelativeWidth(1)
                PowerTagOptions:AddChild(PowerTagTitle)

                local PowerTagTag = MilaUI_GUI:Create("EditBox")
                PowerTagTag:SetText(Tag)
                PowerTagTag:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                PowerTagTag:SetRelativeWidth(0.3)
                PowerTagOptions:AddChild(PowerTagTag)

                PowerTagDescription = MilaUI_GUI:Create("EditBox")
                PowerTagDescription:SetText(Desc)
                PowerTagDescription:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                PowerTagDescription:SetRelativeWidth(0.7)
                PowerTagOptions:AddChild(PowerTagDescription)
            end
        end

        local function DrawNameTagsContainer(MilaUI_GUI_Container)
            local NameTags = MilaUI:FetchNameTagDescriptions()

            local NameTagOptions = MilaUI_GUI:Create("InlineGroup")
            NameTagOptions:SetTitle("Name Tags")
            NameTagOptions:SetLayout("Flow")
            NameTagOptions:SetFullWidth(true)
            MilaUI_GUI_Container:AddChild(NameTagOptions)

            for Title, TableData in pairs(NameTags) do
                local Tag, Desc = TableData.Tag, TableData.Desc
                NameTagTitle = MilaUI_GUI:Create("Heading")
                NameTagTitle:SetText(Title)
                NameTagTitle:SetRelativeWidth(1)
                NameTagOptions:AddChild(NameTagTitle)

                local NameTagTag = MilaUI_GUI:Create("EditBox")
                NameTagTag:SetText(Tag)
                NameTagTag:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                NameTagTag:SetRelativeWidth(0.3)
                NameTagOptions:AddChild(NameTagTag)

                NameTagDescription = MilaUI_GUI:Create("EditBox")
                NameTagDescription:SetText(Desc)
                NameTagDescription:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                NameTagDescription:SetRelativeWidth(0.7)
                NameTagOptions:AddChild(NameTagDescription)
            end
        end

        local function NSMediaTagsContainer(MilaUI_GUI_Container)
            local NSMediaTags = MilaUI:FetchNSMediaTagDescriptions()

            local NSMediaTagOptions = MilaUI_GUI:Create("InlineGroup")
            NSMediaTagOptions:SetTitle("Northern Sky Media Tags")
            NSMediaTagOptions:SetLayout("Flow")
            NSMediaTagOptions:SetFullWidth(true)
            MilaUI_GUI_Container:AddChild(NSMediaTagOptions)

            for Title, TableData in pairs(NSMediaTags) do
                local Tag, Desc = TableData.Tag, TableData.Desc
                NSMediaTagTitle = MilaUI_GUI:Create("Heading")
                NSMediaTagTitle:SetText(Title)
                NSMediaTagTitle:SetRelativeWidth(1)
                NSMediaTagOptions:AddChild(NSMediaTagTitle)

                local NSMediaTagTag = MilaUI_GUI:Create("EditBox")
                NSMediaTagTag:SetText(Tag)
                NSMediaTagTag:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                NSMediaTagTag:SetRelativeWidth(0.3)
                NSMediaTagOptions:AddChild(NSMediaTagTag)

                NSMediaTagDescription = MilaUI_GUI:Create("EditBox")
                NSMediaTagDescription:SetText(Desc)
                NSMediaTagDescription:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                NSMediaTagDescription:SetRelativeWidth(0.7)
                NSMediaTagOptions:AddChild(NSMediaTagDescription)
            end
        end

        local function DrawMiscTagsContainer(MilaUI_GUI_Container)
            local MiscTags = MilaUI:FetchMiscTagDescriptions()

            local MiscTagOptions = MilaUI_GUI:Create("InlineGroup")
            MiscTagOptions:SetTitle("Misc Tags")
            MiscTagOptions:SetLayout("Flow")
            MiscTagOptions:SetFullWidth(true)
            MilaUI_GUI_Container:AddChild(MiscTagOptions)

            for Title, TableData in pairs(MiscTags) do
                local Tag, Desc = TableData.Tag, TableData.Desc
                MiscTagTitle = MilaUI_GUI:Create("Heading")
                MiscTagTitle:SetText(Title)
                MiscTagTitle:SetRelativeWidth(1)
                MiscTagOptions:AddChild(MiscTagTitle)

                local MiscTagTag = MilaUI_GUI:Create("EditBox")
                MiscTagTag:SetText(Tag)
                MiscTagTag:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                MiscTagTag:SetRelativeWidth(0.3)
                MiscTagOptions:AddChild(MiscTagTag)

                MiscTagDescription = MilaUI_GUI:Create("EditBox")
                MiscTagDescription:SetText(Desc)
                MiscTagDescription:SetCallback("OnEnterPressed", function(widget, event, value) return end)
                MiscTagDescription:SetRelativeWidth(0.7)
                MiscTagOptions:AddChild(MiscTagDescription)
            end
        end

        local function SelectedGroup(MilaUI_GUI_Container, Event, Group)
            MilaUI_GUI_Container:ReleaseChildren()
            if Group == "Health" then
                DrawHealthTagContainer(MilaUI_GUI_Container)
            elseif Group == "Power" then
                DrawPowerTagsContainer(MilaUI_GUI_Container)
            elseif Group == "Name" then
                DrawNameTagsContainer(MilaUI_GUI_Container)
            elseif Group == "NSM" and NSM then
                NSMediaTagsContainer(MilaUI_GUI_Container)
            elseif Group == "Misc" then
                DrawMiscTagsContainer(MilaUI_GUI_Container)
            end
        end

        GUIContainerTabGroup = MilaUI_GUI:Create("TabGroup")
        GUIContainerTabGroup:SetLayout("Flow")
        if NSM then
            GUIContainerTabGroup:SetTabs({
                { text = "Health",                              value = "Health"},
                { text = "Power",                               value = "Power" },
                { text = "Name",                                value = "Name" },
                { text = "Misc",                                value = "Misc" },
                { text = "Northern Sky Media",                  value = "NSM" },
            })
        else
            GUIContainerTabGroup:SetTabs({
                { text = "Health",                              value = "Health"},
                { text = "Power",                               value = "Power" },
                { text = "Name",                                value = "Name" },
                { text = "Misc",                                value = "Misc" },
            })
        end
        
        GUIContainerTabGroup:SetCallback("OnGroupSelected", SelectedGroup)
        GUIContainerTabGroup:SelectTab("Health")
        GUIContainerTabGroup:SetFullWidth(true)
        ScrollableContainer:AddChild(GUIContainerTabGroup)
    end

    local function ProfileContainer(MilaUI_GUI_Container)
        local ScrollableContainer = MilaUI_GUI:Create("ScrollFrame")
        ScrollableContainer:SetLayout("Flow")
        ScrollableContainer:SetFullWidth(true)
        ScrollableContainer:SetFullHeight(true)
        MilaUI_GUI_Container:AddChild(ScrollableContainer)
    
        -- Profile Options Section
        local ProfileOptions = MilaUI_GUI:Create("InlineGroup")
        ProfileOptions:SetTitle("Profile Options")
        ProfileOptions:SetLayout("Flow")
        ProfileOptions:SetFullWidth(true)
        ScrollableContainer:AddChild(ProfileOptions)
    
        local selectedProfile = nil
        local profileList = {}
        local profileKeys = {}
    
        for _, name in ipairs(MilaUI.DB:GetProfiles(profileList, true)) do
            profileKeys[name] = name
        end

        local NewProfileBox = MilaUI_GUI:Create("EditBox")
        NewProfileBox:SetLabel("Create New Profile")
        NewProfileBox:SetFullWidth(true)
        NewProfileBox:SetCallback("OnEnterPressed", function(widget, event, text)
            if text ~= "" then
                MilaUI.DB:SetProfile(text)
                MilaUI:CreateReloadPrompt()
                widget:SetText("")
            end
        end)
        ProfileOptions:AddChild(NewProfileBox)
    
        local ActiveProfileDropdown = MilaUI_GUI:Create("Dropdown")
        ActiveProfileDropdown:SetLabel("Active Profile")
        ActiveProfileDropdown:SetList(profileKeys)
        ActiveProfileDropdown:SetValue(MilaUI.DB:GetCurrentProfile())
        ActiveProfileDropdown:SetCallback("OnValueChanged", function(widget, event, value) selectedProfile = value MilaUI.DB:SetProfile(value) MilaUI:UpdateFrames() MilaUI:CreateReloadPrompt() end)
        ActiveProfileDropdown:SetRelativeWidth(0.33)
        ProfileOptions:AddChild(ActiveProfileDropdown)

        local CopyProfileDropdown = MilaUI_GUI:Create("Dropdown")
        CopyProfileDropdown:SetLabel("Copy From Profile")
        CopyProfileDropdown:SetList(profileKeys)
        CopyProfileDropdown:SetCallback("OnValueChanged", function(widget, event, value) selectedProfile = value MilaUI.DB:CopyProfile(selectedProfile) MilaUI:CreateReloadPrompt() end)
        CopyProfileDropdown:SetRelativeWidth(0.33)
        ProfileOptions:AddChild(CopyProfileDropdown)

        local DeleteProfileDropdown = MilaUI_GUI:Create("Dropdown")
        DeleteProfileDropdown:SetLabel("Delete Profile")
        DeleteProfileDropdown:SetList(profileKeys)
        DeleteProfileDropdown:SetCallback("OnValueChanged", function(widget, event, value)
            selectedProfile = value
            if selectedProfile and selectedProfile ~= MilaUI.DB:GetCurrentProfile() then
                MilaUI.DB:DeleteProfile(selectedProfile)
                profileKeys = {}
                for _, name in ipairs(MilaUI.DB:GetProfiles(profileList, true)) do
                    profileKeys[name] = name
                end
                CopyProfileDropdown:SetList(profileKeys)
                DeleteProfileDropdown:SetList(profileKeys)
                ActiveProfileDropdown:SetList(profileKeys)
                DeleteProfileDropdown:SetValue(nil)
            else
                print("|cFF8080FFUnhalted Unit Frames|r: Unable to delete an active profile.")
            end
         end)
        DeleteProfileDropdown:SetRelativeWidth(0.33)
        ProfileOptions:AddChild(DeleteProfileDropdown)

        local ResetToDefault = MilaUI_GUI:Create("Button")
        ResetToDefault:SetText("Reset Settings")
        ResetToDefault:SetCallback("OnClick", function(widget, event, value) MilaUI:ResetDefaultSettings() end)
        ResetToDefault:SetRelativeWidth(1)
        ProfileOptions:AddChild(ResetToDefault)
    
        -- Sharing Options Section
        local SharingOptionsContainer = MilaUI_GUI:Create("InlineGroup")
        SharingOptionsContainer:SetTitle("Sharing Options")
        SharingOptionsContainer:SetLayout("Flow")
        SharingOptionsContainer:SetFullWidth(true)
        ScrollableContainer:AddChild(SharingOptionsContainer)
    
        -- Import Section
        local ImportOptionsContainer = MilaUI_GUI:Create("InlineGroup")
        ImportOptionsContainer:SetTitle("Import Options")
        ImportOptionsContainer:SetLayout("Flow")
        ImportOptionsContainer:SetFullWidth(true)
        SharingOptionsContainer:AddChild(ImportOptionsContainer)
    
        local ImportEditBox = MilaUI_GUI:Create("MultiLineEditBox")
        ImportEditBox:SetLabel("Import String")
        ImportEditBox:SetNumLines(5)
        ImportEditBox:SetFullWidth(true)
        ImportEditBox:DisableButton(true)
        ImportOptionsContainer:AddChild(ImportEditBox)
    
        local ImportButton = MilaUI_GUI:Create("Button")
        ImportButton:SetText("Import")
        ImportButton:SetCallback("OnClick", function()
            MilaUI:ImportSavedVariables(ImportEditBox:GetText())
            ImportEditBox:SetText("")
        end)
        ImportButton:SetRelativeWidth(1)
        ImportOptionsContainer:AddChild(ImportButton)
    
        -- Export Section
        local ExportOptionsContainer = MilaUI_GUI:Create("InlineGroup")
        ExportOptionsContainer:SetTitle("Export Options")
        ExportOptionsContainer:SetLayout("Flow")
        ExportOptionsContainer:SetFullWidth(true)
        SharingOptionsContainer:AddChild(ExportOptionsContainer)
    
        local ExportEditBox = MilaUI_GUI:Create("MultiLineEditBox")
        ExportEditBox:SetLabel("Export String")
        ExportEditBox:SetFullWidth(true)
        ExportEditBox:SetNumLines(5)
        ExportEditBox:DisableButton(true)
        ExportOptionsContainer:AddChild(ExportEditBox)
    
        local ExportButton = MilaUI_GUI:Create("Button")
        ExportButton:SetText("Export")
        ExportButton:SetCallback("OnClick", function()
            ExportEditBox:SetText(MilaUI:ExportSavedVariables())
            ExportEditBox:HighlightText()
            ExportEditBox:SetFocus()
        end)
        ExportButton:SetRelativeWidth(1)
        ExportOptionsContainer:AddChild(ExportButton)
    end

    local function SelectedGroup(MilaUI_GUI_Container, Event, Group)
        MilaUI_GUI_Container:ReleaseChildren()
        if Group == "General" then
            DrawGeneralContainer(MilaUI_GUI_Container)
        elseif Group == "Player" then
            DrawUnitContainer(MilaUI_GUI_Container, Group)
        elseif Group == "Target" then
            DrawUnitContainer(MilaUI_GUI_Container, Group)
        elseif Group == "TargetTarget" then
            DrawUnitContainer(MilaUI_GUI_Container, Group)
        elseif Group == "Focus" then
            DrawUnitContainer(MilaUI_GUI_Container, Group)
        elseif Group == "FocusTarget" then
            DrawUnitContainer(MilaUI_GUI_Container, Group)
        elseif Group == "Pet" then
            DrawUnitContainer(MilaUI_GUI_Container, Group)
        elseif Group == "Boss" then
            DrawUnitContainer(MilaUI_GUI_Container, Group)
        elseif Group == "Tags" then
            DrawTagsContainer(MilaUI_GUI_Container)
        elseif Group == "Profiles" then
            ProfileContainer(MilaUI_GUI_Container)
        end
    end

    GUIContainerTabGroup = MilaUI_GUI:Create("TabGroup")
    GUIContainerTabGroup:SetLayout("Flow")
    GUIContainerTabGroup:SetTabs({
        { text = "General",                         value = "General"},
        { text = "Player",                          value = "Player" },
        { text = "Target",                          value = "Target" },
        { text = "Boss",                            value = "Boss" },
        { text = "Target of Target",                value = "TargetTarget" },
        { text = "Focus",                           value = "Focus" },
        { text = "Focus Target",                    value = "FocusTarget" },
        { text = "Pet",                             value = "Pet" },
        { text = "Tags",                            value = "Tags" },
        { text = "Profiles",                        value = "Profiles" },
    })
    GUIContainerTabGroup:SetCallback("OnGroupSelected", SelectedGroup)
    GUIContainerTabGroup:SelectTab("General")
    MilaUI_GUI_Container:AddChild(GUIContainerTabGroup)
end

function MilaUI:ReOpenGUI()
    if GUIActive and MilaUI_GUI_Container then
        MilaUI_GUI_Container:Hide()
        MilaUI_GUI_Container:ReleaseChildren()
        MilaUI:CreateGUI()
    end
end

function MilaUI:LockFrames()
    local DEBUG_PREFIX = MilaUI.Prefix or "MilaGUI DEBUG: "
    print(DEBUG_PREFIX .. "Attempting to Lock All Frames")
    if not MilaUI.LockFrame then print(DEBUG_PREFIX .. "MilaUI.LockFrame function NOT FOUND! Check Utility.lua") return end

    -- Attempting to use direct global frame names based on user feedback
    local globalFrameNames = {
        "MilaUI_Player", 
        "MilaUI_Target",
        "MilaUI_Focus",
        "MilaUI_FocusTarget",
        "MilaUI_Pet",
        "MilaUI_TargetTarget"
    }
    local framesToProcess = {}
    print(DEBUG_PREFIX .. "Building framesToProcess from global names:")
    for i, name in ipairs(globalFrameNames) do
        local frame = _G[name]
        table.insert(framesToProcess, frame) -- Insert even if nil, ipairs will skip nil later
        print(DEBUG_PREFIX .. "  Checking global frame '" .. name .. "': Type is " .. type(frame))
    end

    print(DEBUG_PREFIX .. "Iterating framesToProcess (built from globals) for LOCKING (using ipairs):")
    for i, actualFrame in ipairs(framesToProcess) do
        -- actualFrame here will only be non-nil values from the framesToProcess table
        local frameDisplayName = globalFrameNames[i] -- Use the correct original name for logging
        local frameNameForLog = "Frame (originally " .. frameDisplayName .. ") (Type: " .. type(actualFrame) .. ")"
        if actualFrame and type(actualFrame.GetName) == "function" then
            frameNameForLog = actualFrame:GetName() .. " (originally " .. frameDisplayName .. ")"
        end

        if actualFrame and type(actualFrame.SetMovable) == "function" then -- Check if it looks like a frame
            print(DEBUG_PREFIX .. "  Processing for Lock: " .. frameNameForLog)
            MilaUI:LockFrame(actualFrame) -- USE COLON NOTATION
            -- if frameDisplayName == "MilaUI_Player" then
            --     MilaUI.LockFrame(actualFrame) -- Test with Player frame first
            -- else
            --     print(DEBUG_PREFIX .. "    WOULD CALL MilaUI.LockFrame for: " .. frameNameForLog) -- Keep others commented
            -- end
        else
            -- This else block might not be reached if actualFrame is nil due to ipairs behavior,
            -- but kept for robustness in case framesToProcess contains non-frame, non-nil items.
            print(DEBUG_PREFIX .. "  Skipping item for Lock (originally " .. globalFrameNames[i] .. "): Not a valid frame or is nil. Type: " .. type(actualFrame))
        end
    end
    -- The explicit nil check for each global frame name has been done above during table construction.
    -- ipairs will naturally skip any nil entries that resulted from _G[name] being nil.

    if MilaUI.BossFrames then
        print(DEBUG_PREFIX .. "Processing BossFrames for Lock")
        for i, bossFrameContainer in ipairs(MilaUI.BossFrames) do
            if bossFrameContainer and bossFrameContainer.frame then
                local frameName = "Unknown/Nil BossFrame"
                if type(bossFrameContainer.frame.GetName) == "function" then frameName = bossFrameContainer.frame:GetName() end
                print(DEBUG_PREFIX .. "Locking BossFrame: " .. frameName)
                MilaUI:LockFrame(bossFrameContainer.frame) -- USE COLON NOTATION
                -- print(DEBUG_PREFIX .. "    WOULD CALL MilaUI.LockFrame for BossFrame: " .. frameName) -- Adjusted log for clarity
            else
                print(DEBUG_PREFIX .. "Skipping nil/invalid BossFrame container at index: " .. i)
            end
        end
    end
    if MilaUI.ArenaFrames then
        print(DEBUG_PREFIX .. "Processing ArenaFrames for Lock")
        for i, arenaFrameContainer in ipairs(MilaUI.ArenaFrames) do
            if arenaFrameContainer and arenaFrameContainer.frame then
                local frameName = "Unknown/Nil ArenaFrame"
                if type(arenaFrameContainer.frame.GetName) == "function" then frameName = arenaFrameContainer.frame:GetName() end
                print(DEBUG_PREFIX .. "Locking ArenaFrame: " .. frameName)
                MilaUI:LockFrame(arenaFrameContainer.frame) -- USE COLON NOTATION
                -- print(DEBUG_PREFIX .. "    WOULD CALL MilaUI.LockFrame for ArenaFrame: " .. frameName) -- Adjusted log for clarity
            else
                print(DEBUG_PREFIX .. "Skipping nil/invalid ArenaFrame container at index: " .. i)
            end
        end
    end
    if MilaUI.PartyFrames then
        print(DEBUG_PREFIX .. "Processing PartyFrames for Lock")
        for i, partyMemberFrame in pairs(MilaUI.PartyFrames) do
            if partyMemberFrame and partyMemberFrame.frame then
                local frameName = "Unknown/Nil PartyFrame"
                if type(partyMemberFrame.frame.GetName) == "function" then frameName = partyMemberFrame.frame:GetName() end
                print(DEBUG_PREFIX .. "Locking PartyFrame (Key: " .. tostring(i) .. "): " .. frameName)
                MilaUI:LockFrame(partyMemberFrame.frame) -- USE COLON NOTATION
                -- print(DEBUG_PREFIX .. "    WOULD CALL MilaUI.LockFrame for PartyFrame: " .. frameName) -- Adjusted log for clarity
            else
                print(DEBUG_PREFIX .. "Skipping nil/invalid PartyFrame (Key: " .. tostring(i) .. ")")
            end
        end
    end
    print(DEBUG_PREFIX .. "Finished Locking All Frames")
end

function MilaUI:UnlockFrames()
    local DEBUG_PREFIX = MilaUI.Prefix or "MilaGUI DEBUG: "
    print(DEBUG_PREFIX .. "Attempting to Unlock All Frames")
    if not MilaUI.UnlockFrame then print(DEBUG_PREFIX .. "MilaUI.UnlockFrame function NOT FOUND! Check Utility.lua") return end

    -- Attempting to use direct global frame names based on user feedback
    local globalFrameNames = {
        "MilaUI_Player", 
        "MilaUI_Target",
        "MilaUI_Focus",
        "MilaUI_FocusTarget",
        "MilaUI_Pet",
        "MilaUI_TargetTarget"
    }
    local framesToProcess = {}
    print(DEBUG_PREFIX .. "Building framesToProcess from global names for UNLOCK:")
    for i, name in ipairs(globalFrameNames) do
        local frame = _G[name]
        table.insert(framesToProcess, frame) -- Insert even if nil, ipairs will skip nil later
        print(DEBUG_PREFIX .. "  Checking global frame '" .. name .. "': Type is " .. type(frame))
    end

    print(DEBUG_PREFIX .. "Iterating framesToProcess (built from globals) for UNLOCKING (using ipairs):")
    for i, actualFrame in ipairs(framesToProcess) do
        -- actualFrame here will only be non-nil values from the framesToProcess table
        local frameDisplayName = globalFrameNames[i] -- Use the correct original name for logging
        local frameNameForLog = "Frame (originally " .. frameDisplayName .. ") (Type: " .. type(actualFrame) .. ")"
        if actualFrame and type(actualFrame.GetName) == "function" then
            frameNameForLog = actualFrame:GetName() .. " (originally " .. frameDisplayName .. ")"
        end

        if actualFrame and type(actualFrame.SetMovable) == "function" then -- Check if it looks like a frame
            print(DEBUG_PREFIX .. "  Processing for Unlock: " .. frameNameForLog)
            MilaUI:UnlockFrame(actualFrame) -- USE COLON NOTATION
            -- if frameDisplayName == "MilaUI_Player" then
            --     MilaUI.UnlockFrame(actualFrame) -- Test with Player frame first
            -- else
            --     print(DEBUG_PREFIX .. "    WOULD CALL MilaUI.UnlockFrame for: " .. frameNameForLog) -- Keep others commented
            -- end
        else
            -- This else block might not be reached if actualFrame is nil due to ipairs behavior,
            -- but kept for robustness in case framesToProcess contains non-frame, non-nil items.
            print(DEBUG_PREFIX .. "  Skipping item for Unlock (originally " .. globalFrameNames[i] .. "): Not a valid frame or is nil. Type: " .. type(actualFrame))
        end
    end
    -- The explicit nil check for each global frame name has been done above during table construction.
    -- ipairs will naturally skip any nil entries that resulted from _G[name] being nil.

    if MilaUI.BossFrames then
        print(DEBUG_PREFIX .. "Processing BossFrames for Unlock")
        for i, bossFrameContainer in ipairs(MilaUI.BossFrames) do
            if bossFrameContainer and bossFrameContainer.frame then
                local frameName = "Unknown/Nil BossFrame"
                if type(bossFrameContainer.frame.GetName) == "function" then frameName = bossFrameContainer.frame:GetName() end
                print(DEBUG_PREFIX .. "Unlocking BossFrame: " .. frameName)
                MilaUI:UnlockFrame(bossFrameContainer.frame) -- USE COLON NOTATION
                -- print(DEBUG_PREFIX .. "    WOULD CALL MilaUI.UnlockFrame for BossFrame: " .. frameName) -- Adjusted log for clarity
            else
                print(DEBUG_PREFIX .. "Skipping nil/invalid BossFrame container at index: " .. i)
            end
        end
    end
    if MilaUI.ArenaFrames then
        print(DEBUG_PREFIX .. "Processing ArenaFrames for Unlock")
        for i, arenaFrameContainer in ipairs(MilaUI.ArenaFrames) do
            if arenaFrameContainer and arenaFrameContainer.frame then
                local frameName = "Unknown/Nil ArenaFrame"
                if type(arenaFrameContainer.frame.GetName) == "function" then frameName = arenaFrameContainer.frame:GetName() end
                print(DEBUG_PREFIX .. "Unlocking ArenaFrame: " .. frameName)
                MilaUI:UnlockFrame(arenaFrameContainer.frame) -- USE COLON NOTATION
                -- print(DEBUG_PREFIX .. "    WOULD CALL MilaUI.UnlockFrame for ArenaFrame: " .. frameName) -- Adjusted log for clarity
            else
                print(DEBUG_PREFIX .. "Skipping nil/invalid ArenaFrame container at index: " .. i)
            end
        end
    end
    if MilaUI.PartyFrames then
        print(DEBUG_PREFIX .. "Processing PartyFrames for Unlock")
        for i, partyMemberFrame in pairs(MilaUI.PartyFrames) do
            if partyMemberFrame and partyMemberFrame.frame then
                local frameName = "Unknown/Nil PartyFrame"
                if type(partyMemberFrame.frame.GetName) == "function" then frameName = partyMemberFrame.frame:GetName() end
                print(DEBUG_PREFIX .. "Unlocking PartyFrame (Key: " .. tostring(i) .. "): " .. frameName)
                MilaUI:UnlockFrame(partyMemberFrame.frame) -- USE COLON NOTATION
                -- print(DEBUG_PREFIX .. "    WOULD CALL MilaUI.UnlockFrame for PartyFrame: " .. frameName) -- Adjusted log for clarity
            else
                print(DEBUG_PREFIX .. "Skipping nil/invalid PartyFrame (Key: " .. tostring(i) .. ")")
            end
        end
    end
    print(DEBUG_PREFIX .. "Finished Unlocking All Frames")
end

function MilaUI_GUI.OpenMilaUI_GUI()
    if not GUIActive then
        MilaUI:CreateGUI()
    elseif MilaUI_GUI_Container then
        MilaUI_GUI_Container:Show()
    end
end

function MilaUI_GUI.CloseMilaUI_GUI()
    if MilaUI_GUI_Container then
        MilaUI_GUI_Container:Hide()
    end
end
