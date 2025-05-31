local _, MilaUI = ...
local oUF = MilaUI.oUF

function MilaUI:SpawnTargetTargetFrame()
    if not MilaUI.DB.profile.TargetTarget.Frame.Enabled then return end
    local Frame = MilaUI.DB.profile.TargetTarget.Frame
    oUF:RegisterStyle("MilaUI_TargetTarget", function(self) MilaUI.CreateUnitFrame(self, "TargetTarget") end)
    oUF:SetActiveStyle("MilaUI_TargetTarget")
    self.TargetTargetFrame = oUF:Spawn("targettarget", "MilaUI_TargetTarget")
    local AnchorParent = (_G[Frame.AnchorParent] and _G[Frame.AnchorParent]:IsObjectType("Frame")) and _G[Frame.AnchorParent] or UIParent
    self.TargetTargetFrame:SetPoint(Frame.AnchorFrom, AnchorParent, Frame.AnchorTo, Frame.XPosition, Frame.YPosition)
    if Frame.CustomScale then self.TargetTargetFrame:SetScale(Frame.Scale) end
end