local _, MilaUI = ...
local oUF = MilaUI.oUF

local unitIsTargetEvtFrame = CreateFrame("Frame")
unitIsTargetEvtFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
unitIsTargetEvtFrame:RegisterEvent("UNIT_TARGET")
unitIsTargetEvtFrame:SetScript("OnEvent", function()
    if not MilaUI.DB.profile.Boss.TargetIndicator.Enabled then return end
    for _, frameData in ipairs(MilaUI.TargetHighlightEvtFrames) do
        local frame, unit = frameData.frame, frameData.unit
        MilaUI:UpdateTargetHighlight(frame, unit)
    end
end)

function MilaUI:SpawnBossFrames()
    if not MilaUI.DB.profile.Boss.Frame.Enabled then return end
    oUF:RegisterStyle("MilaUI_Boss", function(self) MilaUI.CreateUnitFrame(self, "Boss") end)
    oUF:SetActiveStyle("MilaUI_Boss")
    MilaUI.BossFrames = {}
    for i = 1, 8 do
        local BossFrame = oUF:Spawn("boss" .. i, "MilaUI_Boss" .. i)
        MilaUI.BossFrames[i] = BossFrame
        MilaUI:RegisterTargetHighlightFrame(BossFrame, "boss" .. i)
        if MilaUI.DB.profile.Boss.Frame.CustomScale then BossFrame:SetScale(MilaUI.DB.profile.Boss.Frame.Scale) end
    end
    MilaUI:UpdateBossFrames()
end