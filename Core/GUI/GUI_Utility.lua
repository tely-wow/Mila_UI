local _, MilaUI = ...
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0") or LibStub("LibSharedMedia-3.0")
local LSMFonts = {}
local LSMBorders = {}
local LSMTextures = {}

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

local function GenerateCopyFromList(Unit)
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

function MilaUI:LockFrames()
    local DEBUG_PREFIX = MilaUI.Prefix or "MilaGUI DEBUG: "
    print(DEBUG_PREFIX .. "Attempting to Lock All Frames")
    if not MilaUI.LockFrame then print(DEBUG_PREFIX .. "MilaUI.LockFrame function NOT FOUND! Check Utility.lua") return end

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
        table.insert(framesToProcess, frame)
        print(DEBUG_PREFIX .. "  Checking global frame '" .. name .. "': Type is " .. type(frame))
    end

    print(DEBUG_PREFIX .. "Iterating framesToProcess (built from globals) for LOCKING (using ipairs):")
    for i, actualFrame in ipairs(framesToProcess) do
        local frameDisplayName = globalFrameNames[i]
        local frameNameForLog = "Frame (originally " .. frameDisplayName .. ") (Type: " .. type(actualFrame) .. ")"
        if actualFrame and type(actualFrame.GetName) == "function" then
            frameNameForLog = actualFrame:GetName() .. " (originally " .. frameDisplayName .. ")"
        end

        if actualFrame and type(actualFrame.SetMovable) == "function" then
            print(DEBUG_PREFIX .. "  Processing for Lock: " .. frameNameForLog)
            MilaUI:LockFrame(actualFrame)
        else
            print(DEBUG_PREFIX .. "  Skipping item for Lock (originally " .. globalFrameNames[i] .. "): Not a valid frame or is nil. Type: " .. type(actualFrame))
        end
    end
    if MilaUI.BossFrames then
        print(DEBUG_PREFIX .. "Processing BossFrames for Lock")
        for i, bossFrameContainer in ipairs(MilaUI.BossFrames) do
            if bossFrameContainer and bossFrameContainer.frame then
                local frameName = "Unknown/Nil BossFrame"
                if type(bossFrameContainer.frame.GetName) == "function" then frameName = bossFrameContainer.frame:GetName() end
                print(DEBUG_PREFIX .. "Locking BossFrame: " .. frameName)
                MilaUI:LockFrame(bossFrameContainer.frame)
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
                MilaUI:LockFrame(arenaFrameContainer.frame)
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
                MilaUI:LockFrame(partyMemberFrame.frame)
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
        table.insert(framesToProcess, frame)
        print(DEBUG_PREFIX .. "  Checking global frame '" .. name .. "': Type is " .. type(frame))
    end

    print(DEBUG_PREFIX .. "Iterating framesToProcess (built from globals) for UNLOCKING (using ipairs):")
    for i, actualFrame in ipairs(framesToProcess) do
        local frameDisplayName = globalFrameNames[i]
        local frameNameForLog = "Frame (originally " .. frameDisplayName .. ") (Type: " .. type(actualFrame) .. ")"
        if actualFrame and type(actualFrame.GetName) == "function" then
            frameNameForLog = actualFrame:GetName() .. " (originally " .. frameDisplayName .. ")"
        end

        if actualFrame and type(actualFrame.SetMovable) == "function" then
            print(DEBUG_PREFIX .. "  Processing for Unlock: " .. frameNameForLog)
            MilaUI:UnlockFrame(actualFrame)
        else
            print(DEBUG_PREFIX .. "  Skipping item for Unlock (originally " .. globalFrameNames[i] .. "): Not a valid frame or is nil. Type: " .. type(actualFrame))
        end
    end

    if MilaUI.BossFrames then
        print(DEBUG_PREFIX .. "Processing BossFrames for Unlock")
        for i, bossFrameContainer in ipairs(MilaUI.BossFrames) do
            if bossFrameContainer and bossFrameContainer.frame then
                local frameName = "Unknown/Nil BossFrame"
                if type(bossFrameContainer.frame.GetName) == "function" then frameName = bossFrameContainer.frame:GetName() end
                print(DEBUG_PREFIX .. "Unlocking BossFrame: " .. frameName)
                MilaUI:UnlockFrame(bossFrameContainer.frame)
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
                MilaUI:UnlockFrame(arenaFrameContainer.frame)
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
                MilaUI:UnlockFrame(partyMemberFrame.frame)
            else
                print(DEBUG_PREFIX .. "Skipping nil/invalid PartyFrame (Key: " .. tostring(i) .. ")")
            end
        end
    end
    print(DEBUG_PREFIX .. "Finished Unlocking All Frames")
end