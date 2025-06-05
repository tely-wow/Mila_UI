local _, MilaUI = ...
local MilaUI_CLASS_COLORS = MilaUI.CLASS_COLORS

local afterCombatQueue = {}
local maxUpdatesPerCircle = 5
local EMPTY = {}
local NIL = {}

local function CombatQueue_Initialize()
    C_Timer.NewTicker(0.1, function()
        if InCombatLockdown() then
            return
        end

        local func = tremove(afterCombatQueue, 1)
        local count = 0
        while func do
            if func.obj then
                func.func(unpack(func.obj))
            else
                func.func()
            end
            if InCombatLockdown() or count >= maxUpdatesPerCircle then
                break
            end
            func = tremove(afterCombatQueue, 1)
            count = count + 1
        end
    end)
end
MilaUI.CombatQueue_Initialize = CombatQueue_Initialize

local function CombatQueue_Queue(key, func, obj)
    local alreadyIn = false
    for _, v in pairs(afterCombatQueue) do
        if v.key == key and v.func == func and v.obj == obj then
            alreadyIn = true
        end
    end
    if not alreadyIn or key == nil then
        tinsert(afterCombatQueue, {key = key, func = func, obj = obj})
    end
end
MilaUI.CombatQueue_Queue = CombatQueue_Queue

local function StoreGameMenuButton()
    GameMenuFrame.GwMenuButtons = {}
    hooksecurefunc(GameMenuFrame, "Layout", function()
        for button in GameMenuFrame.buttonPool:EnumerateActive() do
            local text = button:GetText()
            GameMenuFrame.GwMenuButtons[text] = button
        end
    end)
end
MilaUI.StoreGameMenuButton = StoreGameMenuButton

if UnitIsTapDenied == nil then
    function UnitIsTapDenied()
        if (UnitIsTapped("target")) and (not UnitIsTappedByPlayer("target")) then
            return true
        end
        return false
    end
end

local function IsIn(val, ...)
    for i = 1, select("#", ...) do
        if val == select(i, ...) then return true end
    end
    return false
end
MilaUI.IsIn = IsIn

local function CountTable(T)
    local c = 0
    if T ~= nil and type(T) == "table" then
        for _ in pairs(T) do
            c = c + 1
        end
    end
    return c
end
MilaUI.CountTable = CountTable

MilaUI.ShortPrefixValues = {}
local function BuildPrefixValues()
    if next(MilaUI.ShortPrefixValues) then wipe(MilaUI.ShortPrefixValues) end

    MilaUI.ShortPrefixValues = MilaUI.copyTable(MilaUI.ShortPrefixValues, MilaUI.ShortPrefixStyles[MilaUI.settings.ShortHealthValuePrefixStyle])
    local shortValueDec = format("%%.%df", MilaUI.settings.ShortHealthValuesDecimalLength or 1)

    for _, style in ipairs(MilaUI.ShortPrefixValues) do
        style[3] = shortValueDec
    end
end
MilaUI.BuildPrefixValues = BuildPrefixValues

local function ShortValue(value)
    local abs_value = value<0 and -value or value
    local values = MilaUI.ShortPrefixValues

    for i = 1, #values do
        local arg1, arg2, arg3 = unpack(values[i])
        if abs_value >= arg1 then
            return MilaUI.GetLocalizedNumber(format(arg3, value / arg1)) .. arg2
        end
    end

    return MilaUI.GetLocalizedNumber(format("%.0f", value))
end
MilaUI.ShortValue = ShortValue

local function SetPointsRestricted(frame)
    if frame and not pcall(frame.GetPoint, frame) then
        return true
    end
end
MilaUI.SetPointsRestricted = SetPointsRestricted

local function FormatMoneyForChat(amount)
    local str, coppercolor, silvercolor, goldcolor = "", "|cffb16022", "|cffaaaaaa", "|cffddbc44"

    local value = abs(amount)
    local gold = math.floor(value / (COPPER_PER_SILVER * SILVER_PER_GOLD))
    local silver = math.floor((value - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
    local copper = mod(value, COPPER_PER_SILVER)

    if gold > 0 then
        str = format("%s%s |r|TInterface/AddOns/GW2_UI/textures/icons/Coins:12:12:0:0:64:32:22:42:1:20|t%s", goldcolor, MilaUI.GetLocalizedNumber(gold), " ")
    end
    if silver > 0 or gold > 0 then
        str = format("%s%s%d |r|TInterface/AddOns/GW2_UI/textures/icons/Coins:12:12:0:0:64:32:43:64:1:20|t%s", str, silvercolor, silver, (copper > 0 or gold > 0) and " " or "")
    end
    if copper > 0 or value == 0 or value > 0 then
        str = format("%s%s%d |r|TInterface/AddOns/GW2_UI/textures/icons/Coins:12:12:0:0:64:32:0:21:1:20|t", str, coppercolor, copper)
    end

    return str
end
MilaUI.FormatMoneyForChat = FormatMoneyForChat

local function GetDefaultClassColor(class)
    local color
    if MilaUI.settings.BLIZZARDCLASSCOLOR_ENABLED then
        color = RAID_CLASS_COLORS[class]
    else
        color = MilaUI.privateDefaults.profile.Gw2ClassColor[class]
    end
    if type(color) ~= "table" then return end
    if not color.colorStr then
        color.colorStr = MilaUI.RGBToHex(color.r, color.g, color.b, "ff")
    elseif strlen(color.colorStr) == 6 then
        color.colorStr = "ff" .. color.colorStr
    end

    return color
end
MilaUI.GetDefaultClassColor = GetDefaultClassColor

do
    local function GWGetClassColor(class, useClassColor, forNameString, alwaysUseBlizzardColors)
        if not class or not useClassColor then
            return RAID_CLASS_COLORS.PRIEST
        end
        
        -- Normalize class name to uppercase to ensure consistent lookups
        class = string.upper(class)
        
        local useBlizzardClassColor = alwaysUseBlizzardColors or MilaUI.DB.profile.Interface.BLIZZARDCLASSCOLOR_ENABLED
        local color = useBlizzardClassColor and RAID_CLASS_COLORS[class] or MilaUI_CLASS_COLORS[class]
        local colorForNameString

        if type(color) ~= "table" then return end

        if not color.colorStr then
            color.colorStr = MilaUI.RGBToHex(color.r, color.g, color.b, "ff")
        elseif strlen(color.colorStr) == 6 then
            color.colorStr = "ff" .. color.colorStr
        end

        if forNameString and not useBlizzardClassColor then
            colorForNameString = {r = min(1, color.r + 0.3), g = min(1, color.g + 0.3), b = min(1, color.b + 0.3), a = color.a, colorStr = MilaUI.RGBToHex(min(1, color.r + 0.3), min(1, color.g + 0.3), min(1, color.b + 0.3), "ff")}
        end

        return forNameString and colorForNameString or color
    end
    MilaUI.GWGetClassColor = GWGetClassColor
end


--RGB to Hex
local function RGBToHex(r, g, b, header, ending)
    r = r <= 1 and r >= 0 and r or 1
    g = g <= 1 and g >= 0 and g or 1
    b = b <= 1 and b >= 0 and b or 1
    return format("%s%02x%02x%02x%s", header or "|cff", r * 255, g * 255, b * 255, ending or "")
end
MilaUI.RGBToHex = RGBToHex

local function HexToRGB(hex)
    local rhex, ghex, bhex = strsub(hex, 1, 2), strsub(hex, 3, 4), strsub(hex, 5, 6)
    return tonumber(rhex, 16) / 255, tonumber(ghex, 16) / 255, tonumber(bhex, 16) / 255
end
MilaUI.HexToRGB = HexToRGB


local function GetUnitBattlefieldFaction(unit)
    local englishFaction, localizedFaction = UnitFactionGroup(unit)

    -- this might be a rated BG or wargame and if so the player's faction might be altered
    -- should also apply if `player` is a mercenary.
    if unit == "player" then
        if C_PvP.IsRatedBattleground() or IsWargame() then
            englishFaction = PLAYER_FACTION_GROUP[GetBattlefieldArenaFaction()]
            localizedFaction = (englishFaction == "Alliance" and FACTION_ALLIANCE) or FACTION_HORDE
        elseif UnitIsMercenary(unit) then
            if englishFaction == "Alliance" then
                englishFaction, localizedFaction = "Horde", FACTION_HORDE
            else
                englishFaction, localizedFaction = "Alliance", FACTION_ALLIANCE
            end
        end
    end

    return englishFaction, localizedFaction
end
MilaUI.GetUnitBattlefieldFaction = GetUnitBattlefieldFaction

local function FillTable(T, map, ...)
    wipe(T)
    for i=1,select("#", ...) do
        local v = select(i, ...)
        if map then
            T[v] = true
        else
            tinsert(T, v)
        end
    end
    return T
end
MilaUI.FillTable = FillTable

local function TimeParts(ms)
    local nMS = tonumber(ms)
    local nSec, nMin, nHr
    if nMS == nil then
        nMS = 0
    end

    nHr = math.floor(nMS / 1440000)
    nMS = nMS - (nHr * 1440000)

    nMin = math.floor(nMS / 60000)
    nMS = nMS - (nMin * 60000)

    nSec = math.floor(nMS / 1000)
    nMS = nMS - (nSec * 1000)

    return nHr, nMin, nSec, nMS
end
MilaUI.TimeParts = TimeParts

local function GetCIDFromGUID(guid)
    local type, _, playerdbID, _, _, cid = strsplit("-", guid or "")
    if type and (type == "Creature" or type == "Vehicle" or type == "Pet") then
        return tonumber(cid)
    elseif type and (type == "Player" or type == "Item") then
        return tonumber(playerdbID)
    end
    return 0
end

local function GetUnitCreatureId(uId)
    local guid = UnitGUID(uId)
    return GetCIDFromGUID(guid)
end
MilaUI.GetUnitCreatureId = GetUnitCreatureId

local fstr = "%.0fs"
local function TimeCount(numSec, com)
    local nSeconds = tonumber(numSec)
    if nSeconds == nil then
        nSeconds = 0
    end
    if nSeconds == 0 then
        return "0s"
    end
    if nSeconds >= 86400 then
        return ceil(nSeconds / 86400) .. "d"
    end
    if nSeconds >= 3600 then
        return ceil(nSeconds / 3600) .. "h"
    end
    if nSeconds >= 60 then
        return ceil(nSeconds / 60) .. "m"
    end
    if com ~= nil then
        local nMilsecs = math.max(math.floor((nSeconds * 10 ^ 1) + 0.5) / (10 ^ 1), 0)
        return nMilsecs .. "s"
    end
    -- inline this because we do it a lot
    return fstr:format(nSeconds)
end
MilaUI.TimeCount = TimeCount

local function RoundDec(number, decimals)
    return (("%%.%df"):format(decimals)):format(number)
end
MilaUI.RoundDec = RoundDec

local function GetLocalizedNumber(number, numberDecimal)
    local DECIMAL_DELIMITER = MilaUI.DB.profile.Interface.NumberFormat == "POINT" and "." or ","
    local LARGE_NUMBER_DELIMITER = MilaUI.DB.profile.Interface.NumberFormat == "POINT" and "," or "."
    local formattedNumber, integerPart, decimalPart

    -- Wandelt die Zahl in einen String um
    local zahlStr = tostring(number)

    -- Bestimme die Position des Dezimaltrennzeichens
    local decimalPos = string.find(zahlStr, "%.")

    if decimalPos then
        -- Teile die Zahl in Ganzzahl und Dezimalteil
        integerPart = string.sub(zahlStr, 1, decimalPos - 1)
        decimalPart = string.sub(zahlStr, decimalPos + 1)
    else
        -- Falls kein Dezimaltrennzeichen vorhanden ist, setze den Dezimalteil auf leer
        integerPart = zahlStr
        decimalPart = ""
    end

    -- Tausendertrennzeichen in der Ganzzahl hinzufügen
    local formattedInteger = {}
    local len = #integerPart

    -- Von rechts nach links durch die Ganzzahl laufen und in eine Tabelle speichern
    local count = 0  -- Zähler für Gruppen von 3 Ziffern
    for i = len, 1, -1 do
        local currentChar = integerPart:sub(i, i)

        -- Tausendertrennzeichen hinzufügen, wenn nötig
        if count > 0 and count % 3 == 0 then
            table.insert(formattedInteger, 1, LARGE_NUMBER_DELIMITER)
        end

        -- Füge das aktuelle Zeichen zur formatierten Ganzzahl hinzu
        table.insert(formattedInteger, 1, currentChar)
        count = count + 1
    end

    -- Wenn Dezimalteil vorhanden ist, füge ihn hinzu
    if numberDecimal then
        decimalPart = string.sub(decimalPart, 1, numberDecimal)
    end
    if #decimalPart > 0 then
        formattedNumber = table.concat(formattedInteger) .. DECIMAL_DELIMITER .. decimalPart
    else
        formattedNumber = table.concat(formattedInteger)
    end

    return formattedNumber
end
MilaUI.GetLocalizedNumber = GetLocalizedNumber
-- /dump GetLocalizedNumber2(5600000.345, 3)

local function CommaValue(n)
    n = RoundDec(n)
    local left, num, right = string.match(n, "^([^%d]*%d)(%d*)(.-)$")
    return left .. (num:reverse():gsub("(%d%d%d)", "%1,"):reverse()) .. right
end
MilaUI.CommaValue = CommaValue

local function RoundInt(v)
    if v == nil then
        return 0
    end
    local vf = math.floor(v)
    if (v - vf) > 0.5 then
        return vf + 1
    end
    return vf
end
MilaUI.RoundInt = RoundInt

local function Diff(a, b)
    if a == nil then
        a = 0
    end
    if b == nil then
        b = 0
    end

    if a > b then
        return a - b
    else
        return b - a
    end
end
MilaUI.Diff = Diff

local function lerp(v0, v1, t)
t = max(0,min(1,t))
    if v0 == nil then
        v0 = 0
    end
return (1 - t) * v0 + t * v1;
end
MilaUI.lerp = lerp
local function lerpEaseOut(v0,v1,t)
t = min(1,t)
t = math.sin(t * math.pi * 0.5);

return lerp(v0,v1,t)
end
MilaUI.lerpEaseOut = lerpEaseOut

local function signum(number)
if number > 0 then
    return 1
elseif number < 0 then
    return -1
else
    return 0
end
end

local function MoveTowards( current,  target,  maxDelta)
    if math.abs(target - current) <= maxDelta then
    return target;
    end
    return current + signum(target - current) * maxDelta;
end
MilaUI.MoveTowards = MoveTowards
local function Length(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end
MilaUI.Length = Length

do
    local splitTable = {}
    local function splitString(str, delim, returnTable)
        local start = 1
        wipe(splitTable)

        while true do
            local pos = strfind(str, delim, start, true)
            if not pos then
                break
            end
            tinsert(splitTable, strsub(str, start, pos -1))
            start = pos + strlen(delim)
        end

        tinsert(splitTable, strsub(str, start))

        if returnTable then
            return splitTable
        else
            return unpack(splitTable)
        end
    end
    MilaUI.splitString = splitString
end

local function FindInList(list, str, i, del)
    local dl = "([^%s" .. (del or ",;") .. ")]?)"
    local st = dl .. "(%s*)(" .. str .. ")(%s*)" .. dl
    i = i or 1
    while i do
        local s, e, a, b, m, c, d = list:find(st, i)
        if s and a == "" and d == "" then
            return s + #b, e - #c, m
        end
        i = e and e + 1
    end
end
MilaUI.FindInList = FindInList

-- String upper and lower that are noops for locales without letter case
local function StrUpper(str, i, j)
    if not str or IsIn(MilaUI.mylocal, "koKR", "zhCN", "zhTW") then
        return str
    else
        return (i and str:sub(1, i - 1) or "") .. str:sub(i or 1, j):upper() .. (j and str:sub(j + 1) or "")
    end
end
MilaUI.StrUpper = StrUpper

local function StrLower(str, i, j)
    if not str or IsIn(MilaUI.mylocal, "koKR", "zhCN", "zhTW") then
        return str
    else
        return (i and str:sub(1, i - 1) or "") .. str:sub(i or 1, j):lower() .. (j and str:sub(j + 1) or "")
    end
end
MilaUI.StrLower = StrLower

local function StartsWith(str, str2)
    return type(str) == "string" and str:sub(1, str2:len()) == str2
end
MilaUI.StartsWith = StartsWith

local function IsInf(n)
    --return tostring(n) == tostring(1/0)
    return false
end
MilaUI.IsInf = IsInf

local function IsNaN(n)
    --return tostring(n) == tostring(0/0)
    return false
end
MilaUI.IsNaN = IsNaN

local function IsFrameModified(f_name)
    if not MovAny then
        return false
    end
    return MovAny:IsModified(f_name)
end
MilaUI.IsFrameModified = IsFrameModified

local function Notice(...)
    local msg_tab = _G["ChatFrame1"]
    if not msg_tab then
        return
    end
    local msg = ""
    for i = 1, select("#", ...) do
        local arg = select(i, ...)
        msg = msg .. tostring(arg) .. " "
    end
    msg_tab:AddMessage(MilaUI.Gw2Color .. "GW2 UI|r: " .. msg)
end
MilaUI.Notice = Notice

local function securePetAndOverride(f, stateType)
    if InCombatLockdown() then
        return false
    end
    f:SetAttribute("gw_WasShowing", f:IsShown())
    f:SetAttribute(
        "_onstate-petoverride",
        [=[
        if newstate == "show" then
            if self:GetAttribute("gw_WasShowing") then
                self:Show()
            end
        elseif newstate == "hide" then
            self:SetAttribute("gw_WasShowing", self:IsShown())
            self:Hide()
        end
    ]=]
    )
    if stateType == "petbattle" then
        RegisterStateDriver(f, "petoverride", "[petbattle] hide; show")
    elseif stateType == "override" then
        RegisterStateDriver(f, "petoverride", "[overridebar] hide; [vehicleui] hide; show")
    else
        RegisterStateDriver(f, "petoverride", "[overridebar] hide; [vehicleui] hide; [petbattle] hide; [possessbar,@vehicle,exists] hide; show")
    end
    return true
end

local function secureHideDurinPetAndMountedgMounted(f)
    if InCombatLockdown() then
        return false
    end
    f:SetAttribute("gw_WasShowing", f:IsShown())
    f:SetAttribute(
        "_onstate-petoverride",
        [=[
        if newstate == "show" then
            if self:GetAttribute("gw_WasShowing") then
                self:Show()
            end
        elseif newstate == "hide" then
            self:SetAttribute("gw_WasShowing", self:IsShown())
            self:Hide()
        end
    ]=]
    )

    RegisterStateDriver(f, "petoverride", "[bonusbar:5] hide; [overridebar] hide; [vehicleui] hide; [petbattle] hide; [possessbar,@vehicle,exists] hide; show")
    return true
end

local function normPetAndOverride(f, stateType)
    local f_OnShow = function()
        f.gw_WasShowing = f:IsShown()
        f:Hide()
    end
    local f_OnHide = function()
        if f.gw_WasShowing then
            f:Show()
        end
    end

    if stateType ~= "petbattle" then
        OverrideActionBar:HookScript("OnShow", f_OnShow)
        OverrideActionBar:HookScript("OnHide", f_OnHide)
    end
    if stateType ~= "override" then
        PetBattleFrame:HookScript("OnShow", f_OnShow)
        PetBattleFrame:HookScript("OnHide", f_OnHide)
    end

    return true
end

local function MixinHideDuringPet(f)
    -- TODO: figure out how to do real mixins
    if f:IsProtected() then
        return securePetAndOverride(f, "petbattle")
    else
        return normPetAndOverride(f, "petbattle")
    end
end
MilaUI.MixinHideDuringPet = MixinHideDuringPet

local function MixinHideDuringOverride(f)
    if f:IsProtected() then
        return securePetAndOverride(f, "override")
    else
        return normPetAndOverride(f, "override")
    end
end
MilaUI.MixinHideDuringOverride = MixinHideDuringOverride

local function MixinHideDuringPetAndOverride(f)
    if f:IsProtected() then
        return securePetAndOverride(f)
    else
        return normPetAndOverride(f)
    end
end
MilaUI.MixinHideDuringPetAndOverride = MixinHideDuringPetAndOverride
local function MixinHideDuringPetAndMountedOverride(f)
    if f:IsProtected() then
        return secureHideDurinPetAndMountedgMounted(f)
    else
        return normPetAndOverride(f)
    end
end
MilaUI.MixinHideDuringPetAndMountedOverride = MixinHideDuringPetAndMountedOverride
local function getContainerItemLinkByNameOrId(itemName, id)
    local itemLink = nil
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local item = C_Container.GetContainerItemLink(bag, slot)
            if item and (item:find(itemName) or item:find(id)) then
                itemLink = item
                break
            end
        end
    end

    return itemLink
end
MilaUI.getContainerItemLinkByNameOrId = getContainerItemLinkByNameOrId

local function getInventoryItemLinkByNameAndId(name, id)
    for slot = 1, 17 do
        local itemLink = GetInventoryItemLink("player", slot)
        if itemLink and itemLink:find(name) and itemLink:find(id) then
            return itemLink
        end
    end

    return nil
end
MilaUI.getInventoryItemLinkByNameAndId = getInventoryItemLinkByNameAndId

local function frame_OnEnter(self)
    GameTooltip:SetOwner(self, self.tooltipDir, 0, self.tooltipYoff)
    GameTooltip:SetText(self.tooltipText, 1, 1, 1)
    if self.tooltipAddLine then
        GameTooltip:AddLine(self.tooltipAddLine)
    end
    GameTooltip:Show()
end
local function EnableTooltip(self, text, dir, y_off)
    self.tooltipText = text
    if not dir then
        dir = "ANCHOR_LEFT"
    end
    if not y_off then
        y_off = -40
    end
    self.tooltipDir = dir
    self.tooltipYoff = y_off
    self:HookScript("OnEnter", frame_OnEnter)
    self:HookScript("OnLeave", GameTooltip_Hide)
end
MilaUI.EnableTooltip = EnableTooltip

local function addChange(addonVersion, changeList)
    if not MilaUI.GW_CHANGELOGS then
        MilaUI.GW_CHANGELOGS = {}
    end
    MilaUI.GW_CHANGELOGS[#MilaUI.GW_CHANGELOGS + 1] = {version = addonVersion, changes = changeList}
end
MilaUI.addChange = addChange
-- create custom UIFrameFlash animation
local function SetUpFrameFlash(frame, loop)
    frame.flasher = frame:CreateAnimationGroup("Flash")
    frame.flasher.fadein = frame.flasher:CreateAnimation("Alpha", "FadeIn")
    frame.flasher.fadein:SetOrder(1)

    frame.flasher.fadeout = frame.flasher:CreateAnimation("Alpha", "FadeOut")
    frame.flasher.fadeout:SetOrder(2)

    if loop then
        frame.flasher:SetScript("OnFinished", function(self)
            self:Play()
        end)
    end
end

local function StopFlash(frame)
    if frame.flasher and frame.flasher:IsPlaying() then
        frame.flasher:Stop()
    end
end
MilaUI.StopFlash = StopFlash

local function FrameFlash(frame, duration, fadeOutAlpha, fadeInAlpha, loop)
    if not frame.flasher then
        SetUpFrameFlash(frame, loop)
    end

    if not frame.flasher:IsPlaying() then
        frame.flasher.fadein:SetDuration(duration)
        frame.flasher.fadein:SetFromAlpha(fadeOutAlpha or 0)
        frame.flasher.fadein:SetToAlpha(fadeInAlpha or 1)
        frame.flasher.fadeout:SetDuration(duration)
        frame.flasher.fadeout:SetFromAlpha(fadeInAlpha or 1)
        frame.flasher.fadeout:SetToAlpha(fadeOutAlpha or 0)
        frame.flasher:Play()
    end
end
MilaUI.FrameFlash = FrameFlash

local function setItemLevel(button, quality, itemlink, slot)
    button.itemlevel:GwSetFontTemplate(UNIT_NAME_FONT, MilaUI.TextSizeType.SMALL, "THINOUTLINE")
    if quality then
        local color = MilaUI.GetQualityColor(quality)
        if quality >= Enum.ItemQuality.Common and color then
            button.itemlevel:SetTextColor(color.r, color.g, color.b, 1)
        end
        local slotInfo = MilaUI.GetGearSlotInfo("player", slot, itemlink, false)
        button.itemlevel:SetText(slotInfo.iLvl)
        button.itemlevel:SetTextColor(color.r, color.g, color.b, 1)
        slotInfo = nil
    else
        local color = MilaUI.GetQualityColor(1)
        button.itemlevel:SetText("")
        button.itemlevel:SetTextColor(color.r, color.g, color.b, 1)
    end
end
MilaUI.setItemLevel = setItemLevel

local function GetQualityColor(quality)
    if quality == -1 then
        return {r = 0, g = 0, b = 0}
    end
    return ColorManager.GetColorDataForItemQuality(quality)
end
MilaUI.GetQualityColor = GetQualityColor

local function GetBagItemQualityColor(quality)
    if quality == -1 then
        return {r = 0, g = 0, b = 0}
    end
    return ColorManager.GetColorDataForBagItemQuality(quality)
end
MilaUI.GetBagItemQualityColor = GetBagItemQualityColor

local function GetScreenQuadrant(frame)
    local x, y = frame:GetCenter()
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()

    if not (x and y) then
        return "UNKNOWN"
    end

    local point
    if (x > (screenWidth / 3) and x < (screenWidth / 3) * 2) and y > (screenHeight / 3) * 2 then
        point = "TOP"
    elseif x < (screenWidth / 3) and y > (screenHeight / 3) * 2 then
        point = "TOPLEFT"
    elseif x > (screenWidth / 3) * 2 and y > (screenHeight / 3) * 2 then
        point = "TOPRIGHT"
    elseif (x > (screenWidth / 3) and x < (screenWidth / 3) * 2) and y < (screenHeight / 3) then
        point = "BOTTOM"
    elseif x < (screenWidth / 3) and y < (screenHeight / 3) then
        point = "BOTTOMLEFT"
    elseif x > (screenWidth / 3) * 2 and y < (screenHeight / 3) then
        point = "BOTTOMRIGHT"
    elseif x < (screenWidth / 3) and (y > (screenHeight / 3) and y < (screenHeight / 3) * 2) then
        point = "LEFT"
    elseif x > (screenWidth / 3) * 2 and y < (screenHeight / 3) * 2 and y > (screenHeight / 3) then
        point = "RIGHT"
    else
        point = "CENTER"
    end

    return point
end
MilaUI.GetScreenQuadrant = GetScreenQuadrant

do
    local a, d = "", {"|c[fF][fF]%x%x%x%x%x%x","|r","^%s+","%s+$","|[TA].-|[ta]"}
    local function StripString(s, ignoreTextures)
        for i = 1, #d - (ignoreTextures and 1 or 0) do s = gsub(s, d[i], a) end
        return s
    end
    MilaUI.StripString = StripString
end

local function ColorGradient(perc, ...)
    if perc >= 1 then
        return select(select("#", ...) - 2, ...)
    elseif perc <= 0 then
        return ...
    end

    local num = select("#", ...) / 3
    local segment, relperc = math.modf(perc * (num - 1))
    local r1, g1, b1, r2, g2, b2 = select((segment * 3) + 1, ...)

    return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
end
MilaUI.ColorGradient = ColorGradient

local function TextGradient(text, ...)
    local msg, total = "", string.utf8len(text)
    local idx, num = 0, select("#", ...) / 3

    for i = 1, total do
        local x = string.utf8sub(text, i, i)
        if strmatch(x, "%s") then
            msg = msg .. x
            idx = idx + 1
        else
            local segment, relperc = math.modf((idx / total) * num)
            local r1, g1, b1, r2, g2, b2 = select((segment * 3) + 1, ...)

            if not r2 then
                msg = msg .. MilaUI.RGBToHex(r1, g1, b1, nil, x .. '|r')
            else
                msg = msg .. MilaUI.RGBToHex(r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc, nil, x ..'|r')
                idx = idx + 1
            end
        end
    end

    return msg
end
MilaUI.TextGradient = TextGradient

local function StatusBarColorGradient(bar, value, max, backdrop)
    if not (bar and value) then return end

    local current = (not max and value) or (value and max and max ~= 0 and value / max)
    if not current then return end

    local r, g, b = ColorGradient(current, 0.8, 0, 0, 0.8, 0.8, 0, 0, 0.8,  0)
    bar:SetStatusBarColor(r, g, b)

    if not backdrop then
        backdrop = bar.backdrop
    end

    if backdrop then
        backdrop:SetBackdropColor(r * 0.25, g * 0.25, b * 0.25)
    end
end
MilaUI.StatusBarColorGradient = StatusBarColorGradient


local Fn = function (...) return not MilaUI.Matches(...) end

local function Tmp(...)
    local t = {}
    for i=1, select("#", ...) do
        local v = select(i, ...)
        t[i] = v == nil and NIL or v
    end
    return setmetatable(t, EMPTY)
end

local function Each(...)
    if ... and type(...) == "table" then
        return next, ...
    elseif select("#", ...) == 0 then
        return MilaUI.NoOp
    else
        return Fn, Tmp(...)
    end
end

local function Contains(t, u, deep)
    if t == u then
        return true
    elseif (t == nil) ~= (u == nil) then
        return false
    end

    for i,v in pairs(u) do
        if deep and type(t[i]) == "table" and type(v) == "table" then
            if not Contains(t[i], v, true) then
                return false
            end
        elseif t[i] ~= v then
            return false
        end
    end
    return true
end

local function IEach(...)
    if ... and type(...) == "table" then
        return Fn, ...
    else
        return Each(...)
    end
end

local function Get(t, ...)
    local n, path = select("#", ...), ...

    if n == 1 and type(path) == "string" and path:find("%.") then
        path = Tmp(("."):split((...)))
    elseif type(path) ~= "table" then
        path = Tmp(...)
    end

    for _, k in IEach(path) do
        if k == nil then
            break
        elseif t ~= nil then
            t = t[k]
        end
    end

    return t
end

local function Matches(t, ...)
    if type(...) == "table" then
        return Contains(t, ...)
    else
        for i=1, select("#", ...), 2 do
            local key, val = select(i, ...)
            local v = Get(t, key)
            if v == nil or val ~= nil and v ~= val then
                return false
            end
        end

        return true
    end
end
MilaUI.Matches = Matches

local function Join(del, ...)
    local s = ""
    for _, v in Each(...) do
        if not not (type(v) == "string" and v:trim() ~= "") then
            s = s .. (s == "" and "" or del or " ") .. v
        end
    end
    return s
end
MilaUI.Join = Join

local function EscapeString(s)
    return gsub(s, "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
end
MilaUI.EscapeString = EscapeString

do
    local cuttedIconTemplate = "|T%s:%d:%d:0:0:64:64:5:59:5:59|t"
    local cuttedIconAspectRatioTemplate = "|T%s:%d:%d:0:0:64:64:%d:%d:%d:%d|t"
    local s = 14

    local function GetIconString(icon, height, width, aspectRatio)
        if aspectRatio and height and height > 0 and width and width > 0 then
            local proportionality = height / width
            local offset = ceil((54 - 54 * proportionality) / 2)
            if proportionality > 1 then
                return format(cuttedIconAspectRatioTemplate, icon, height, width, 5 + offset, 59 - offset, 5, 59)
            elseif proportionality < 1 then
                return format(cuttedIconAspectRatioTemplate, icon, height, width, 5, 59, 5 + offset, 59 - offset)
            end
        end

        width = width or height
        return format(cuttedIconTemplate, icon, height or s, width or s)
    end
    MilaUI.GetIconString = GetIconString
end

local function GetClassIconStringWithStyle(class, width, height)
    if not class then
        return
    end


    if not width and not height then
        return format("|T%s:0|t", "Interface/Addons/GW2_UI/Textures/classicons/" .. class .. "_flat")
    end

    if not height then
        height = width
    end

    return format("|T%s:%d:%d:0:0:64:64:0:64:0:64|t", "Interface/Addons/GW2_UI/Textures/classicons/" .. class .. "_flat", height, width)
end
MilaUI.GetClassIconStringWithStyle = GetClassIconStringWithStyle

local function IsGroupMember(name)
    if name then
        if UnitInParty(name) then
            return 1
        elseif UnitInRaid(name) then
            return 2
        elseif name == MilaUI.myname then
            return 3
        end
    end

    return false
end
MilaUI.IsGroupMember = IsGroupMember

local function IsSpellTalented(spellID) -- this could be made to be a lot more efficient, if you already know the relevant nodeID and entryID
    local configID = C_ClassTalents.GetActiveConfigID()
    if configID == nil then return end

    local configInfo = C_Traits.GetConfigInfo(configID)
    if configInfo == nil then return end

    for _, treeID in ipairs(configInfo.treeIDs) do -- in the context of talent trees, there is only 1 treeID
        local nodes = C_Traits.GetTreeNodes(treeID)
        for _, nodeID in ipairs(nodes) do
            local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
            for _, entryID in ipairs(nodeInfo.entryIDsWithCommittedRanks) do -- there should be 1 or 0
                local entryInfo = C_Traits.GetEntryInfo(configID, entryID)
                if entryInfo and entryInfo.definitionID then
                    local definitionInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID)
                    if definitionInfo.spellID == spellID then
                        return true
                    end
                end
            end
        end
    end
    return false
end
MilaUI.IsSpellTalented = IsSpellTalented

local function moveFrameToPosition(frame, x, y)
    local pos = MilaUI.settings[frame.gwSetting]

    if x and y then
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point = "TOPLEFT"
        pos.relativePoint = "TOPLEFT"
        pos.xOfs = x
        pos.yOfs = y

        MilaUI.settings[frame.gwSetting] = pos
    end

    frame.ClearAllPoints = nil
    frame.SetPoint = nil
    frame:ClearAllPoints()
    frame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    frame.SetPoint = MilaUI.NoOp
    frame.ClearAllPoints = MilaUI.NoOp
end

local function MakeFrameMovable(frame, target, setting, moveFrameOnShow)
    if frame:IsMovable() then
        return
    end

    if not target then
        local point = MilaUI.settings[setting]
        frame:ClearAllPoints()
        frame:SetPoint(point.point, UIParent, point.relativePoint, point.xOfs, point. yOfs)
    end

    target = target or frame

    target.gwSetting = setting
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            target:StartMoving()
        end
    end)
    frame:SetScript("OnMouseUp", function()
        target:StopMovingOrSizing()

        local x, y = target:GetLeft(), target:GetTop() - UIParent:GetTop()

        moveFrameToPosition(target, x, y)
    end)
    if moveFrameOnShow then
        frame:HookScript("OnShow", function()
            moveFrameToPosition(target)
        end)
    end
end
MilaUI.MakeFrameMovable = MakeFrameMovable

local function UpdateFontSettings()
    for text in pairs(MilaUI.texts) do
        if text then
            text:GwSetFontTemplate(text.gwFont, text.gwTextSizeType, text.gwStyle, text.gwTextSizeAddition, true)
        else
            MilaUI.texts[text] = nil
        end
    end
end
MilaUI.UpdateFontSettings = UpdateFontSettings


local InstanceNameByID = {
    -- List of not matching instanceID from EJ_GetInstanceByIndex and from GetInstanceInfo
    [749] = C_Map.GetAreaInfo(3845) -- "The Eye" vs. "Tempest Keep"
}

if MilaUI.mylocal == "deDE" then
    InstanceNameByID[741] = "Geschmolzener Kern"        -- "Der Geschmolzene Kern"
    InstanceNameByID[1023] = "Belagerung von Boralus"   -- "Die Belagerung von Boralus"
    InstanceNameByID[1041] = "Königsruh"                -- "Die Königsruh"
    InstanceNameByID[1021] = "Kronsteiganwesen"	        -- "Das Kronsteiganwesen"
    InstanceNameByID[1186] = "Spitzen des Aufstiegs"    -- "Die Spitzen des Aufstiegs"
    InstanceNameByID[1198] = "Angriff der Nokhud"		-- "Der Angriff der Nokhud"
    InstanceNameByID[1203] = "Azurblaues Gewölbe"		-- "Das Azurblaube Gewölbe"
end
local function GetInstanceImages(raid)
    local index = 1
    local instanceID, name, _, _, buttonImage = EJ_GetInstanceByIndex(index, raid)
    while instanceID do
        MilaUI.instanceIconByName[InstanceNameByID[instanceID] or name] = buttonImage
        index = index + 1
        instanceID, name, _, _, buttonImage = EJ_GetInstanceByIndex(index, raid)
    end
end
MilaUI.GetInstanceImages = GetInstanceImages

local function BlizzardDropdownRadioButtonInitializer(button, description, menu)
    button.highlight:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/button_hover")
    button.highlight:SetDrawLayer("BACKGROUND")
    button.highlight:SetBlendMode("BLEND")
    button.highlight:SetAlpha(0.5)
    button.leftTexture1:SetSize(13, 13)
    button.leftTexture1:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/radio-unselected")
    button.leftTexture1:SetPoint("LEFT", 0, 0)
    if button.leftTexture2 then
        button.leftTexture2:SetSize(13, 13)
        button.leftTexture2:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/radio-selected")
        button.leftTexture2:SetPoint("CENTER", button.leftTexture1, "CENTER", 0, 0)
    end
    if not button.gwHooked then
        hooksecurefunc(button.highlight, "SetAlpha", function(self, a)
            if a ~= 0.5 then
                self:SetAlpha(0.5)
            end
        end)
        button.gwHooked = true
    end
end
MilaUI.BlizzardDropdownRadioButtonInitializer = BlizzardDropdownRadioButtonInitializer

local function BlizzardDropdownCheckButtonInitializer(button, description, menu)
    button.highlight:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/button_hover")
    button.highlight:SetDrawLayer("BACKGROUND")
    button.highlight:SetBlendMode("BLEND")
    button.highlight:SetAlpha(0.5)
    button.leftTexture1:SetSize(13, 13)
    button.leftTexture1:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkbox")
    if button.leftTexture2 then
        button.leftTexture2:SetSize(13, 13)
        button.leftTexture2:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked")
        button.leftTexture2:SetPoint("CENTER", button.leftTexture1, "CENTER", 0, 0)
    end
    if not button.gwHooked then
        hooksecurefunc(button.highlight, "SetAlpha", function(self, a)
            if a ~= 0.5 then
                self:SetAlpha(0.5)
            end
        end)
        button.gwHooked = true
    end
end
MilaUI.BlizzardDropdownCheckButtonInitializer = BlizzardDropdownCheckButtonInitializer

local function BlizzardDropdownButtonInitializer(button, description, menu)
    button.highlight:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/button_hover")
    button.highlight:SetDrawLayer("BACKGROUND")
    button.highlight:SetBlendMode("BLEND")
    button.highlight:SetAlpha(0.5)
    if not button.gwHooked then
        hooksecurefunc(button.highlight, "SetAlpha", function(self, a)
            if a ~= 0.5 then
                self:SetAlpha(0.5)
            end
        end)
        button.gwHooked = true
    end
end
MilaUI.BlizzardDropdownButtonInitializer = BlizzardDropdownButtonInitializer


