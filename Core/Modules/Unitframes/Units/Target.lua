local _, MilaUI = ...
local oUF = MilaUI.oUF

function MilaUI:SpawnTargetFrame()
    if not MilaUI.DB.profile.Target.Frame.Enabled then return end
    local Frame = MilaUI.DB.profile.Target.Frame
    oUF:RegisterStyle("MilaUI_Target", function(self) MilaUI.CreateUnitFrame(self, "Target") end)
    oUF:SetActiveStyle("MilaUI_Target")
    self.TargetFrame = oUF:Spawn("target", "MilaUI_Target")
    local AnchorParent = (_G[Frame.AnchorParent] and _G[Frame.AnchorParent]:IsObjectType("Frame")) and _G[Frame.AnchorParent] or UIParent
    self.TargetFrame:SetPoint(Frame.AnchorFrom, AnchorParent, Frame.AnchorTo, Frame.XPosition, Frame.YPosition)
    if Frame.CustomScale then self.TargetFrame:SetScale(Frame.Scale) end
end