local _, MilaUI = ...
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0") or LibStub("LibSharedMedia-3.0")
local LSMFonts = {}
local LSMBorders = {}
local LSMTextures = {}
local CopyFrom = {
    ["Player"] = "Player",
    ["Target"] = "Target",
    ["Focus"] = "Focus",
    ["FocusTarget"] = "Focus Target",
    ["Pet"] = "Pet",
    ["TargetTarget"] = "Target Target",
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

function MilaUI:GenerateCopyFromList(Unit)
    local CopyFromList = {}
    for k, v in pairs(CopyFrom) do
        if k ~= Unit then
            CopyFromList[k] = v
        end
    end
    return CopyFromList
end

function MilaUI:CopyUnit(sourceUnit, targetUnit)
    if type(sourceUnit) ~= "table" or type(targetUnit) ~= "table" then return end
    for key, targetValue in pairs(targetUnit) do
        local sourceValue = sourceUnit[key]
        if type(targetValue) == "table" and type(sourceValue) == "table" then
            MilaUI:CopyUnit(sourceValue, targetValue)
        elseif sourceValue ~= nil then
            targetUnit[key] = sourceValue
        end
    end
    MilaUI:UpdateFrames()
    MilaUI:CreateReloadPrompt()
end

function MilaUI:ResetColours()
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

function MilaUI:UnlockFrame(frame)
    if not frame or type(frame.SetMovable) ~= "function" then
        return
    end
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
          self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
          self:StopMovingOrSizing()
    end)
 end
 
 function MilaUI:LockFrame(frame)
    if not frame or type(frame.SetMovable) ~= "function" then
        return
    end
    
    local frameName = frame:GetName()
    if frameName then
        local unitType = frameName:match("MilaUI_(%a+)")
        
        if unitType and MilaUI.DB and MilaUI.DB.profile and MilaUI.DB.profile[unitType] and MilaUI.DB.profile[unitType].Frame then
            local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
            if point then
                MilaUI.DB.profile[unitType].Frame.XPosition = xOfs
                MilaUI.DB.profile[unitType].Frame.YPosition = yOfs
                MilaUI.DB.profile[unitType].Frame.AnchorFrom = point
                MilaUI.DB.profile[unitType].Frame.AnchorTo = relativePoint
                
                if relativeTo and type(relativeTo.GetName) == "function" then
                    MilaUI.DB.profile[unitType].Frame.AnchorParent = relativeTo:GetName()
                end
            end
        end
    end
    
    frame:SetMovable(false)
    frame:SetScript("OnDragStart", nil)
    frame:SetScript("OnDragStop", nil)
 end


function MilaUI:LockFrames()
    local globalFrameNames = {
        "MilaUI_Player", 
        "MilaUI_Target",
        "MilaUI_Focus",
        "MilaUI_FocusTarget",
        "MilaUI_Pet",
        "MilaUI_TargetTarget"
    }
    local framesToProcess = {}
    for i, name in ipairs(globalFrameNames) do
        local frame = _G[name]
        table.insert(framesToProcess, frame)
    end
    for i, actualFrame in ipairs(framesToProcess) do
        local frameDisplayName = globalFrameNames[i]
        local frameNameForLog = "Frame (originally " .. frameDisplayName .. ") (Type: " .. type(actualFrame) .. ")"
        if actualFrame and type(actualFrame.GetName) == "function" then
            frameNameForLog = actualFrame:GetName() .. " (originally " .. frameDisplayName .. ")"
        end

        if actualFrame and type(actualFrame.SetMovable) == "function" then
            MilaUI:LockFrame(actualFrame)
        end
    end
    if MilaUI.BossFrames then
        for i, bossFrameContainer in ipairs(MilaUI.BossFrames) do
            if bossFrameContainer and bossFrameContainer.frame then
                MilaUI:LockFrame(bossFrameContainer.frame)
            end
        end
    end
    if MilaUI.ArenaFrames then
        for i, arenaFrameContainer in ipairs(MilaUI.ArenaFrames) do
            if arenaFrameContainer and arenaFrameContainer.frame then
                MilaUI:LockFrame(arenaFrameContainer.frame)
            end
        end
    end
    if MilaUI.PartyFrames then
        for i, partyMemberFrame in pairs(MilaUI.PartyFrames) do
            if partyMemberFrame and partyMemberFrame.frame then
                MilaUI:LockFrame(partyMemberFrame.frame)
            end
        end
    end
end

function MilaUI:UnlockFrames()
    local globalFrameNames = {
        "MilaUI_Player", 
        "MilaUI_Target",
        "MilaUI_Focus",
        "MilaUI_FocusTarget",
        "MilaUI_Pet",
        "MilaUI_TargetTarget"
    }
    local framesToProcess = {}
    for i, name in ipairs(globalFrameNames) do
        local frame = _G[name]
        table.insert(framesToProcess, frame)
    end

    for i, actualFrame in ipairs(framesToProcess) do
        local frameDisplayName = globalFrameNames[i]
        if actualFrame and type(actualFrame.SetMovable) == "function" then
            MilaUI:UnlockFrame(actualFrame)
        end
    end

    if MilaUI.BossFrames then
        for i, bossFrameContainer in ipairs(MilaUI.BossFrames) do
            if bossFrameContainer and bossFrameContainer.frame then
                MilaUI:UnlockFrame(bossFrameContainer.frame)
            end
        end
    end
    if MilaUI.ArenaFrames then
        for i, arenaFrameContainer in ipairs(MilaUI.ArenaFrames) do
            if arenaFrameContainer and arenaFrameContainer.frame then
                MilaUI:UnlockFrame(arenaFrameContainer.frame)
            end
        end
    end
    if MilaUI.PartyFrames then
        for i, partyMemberFrame in pairs(MilaUI.PartyFrames) do
            if partyMemberFrame and partyMemberFrame.frame then
                MilaUI:UnlockFrame(partyMemberFrame.frame)
            end
        end
    end
end