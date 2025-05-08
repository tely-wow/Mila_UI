local _, MilaUI = ...
local oUF = MilaUI.oUF

function MilaUI:SpawnFocusTargetFrame()
    if not MilaUI.DB.profile.FocusTarget.Frame.Enabled then return end
    local Frame = MilaUI.DB.profile.FocusTarget.Frame
    oUF:RegisterStyle("MilaUI_FocusTarget", function(self) MilaUI.CreateUnitFrame(self, "FocusTarget") end)
    oUF:SetActiveStyle("MilaUI_FocusTarget")
    self.FocusTargetFrame = oUF:Spawn("focustarget", "MilaUI_FocusTarget")
    local AnchorParent = (_G[Frame.AnchorParent] and _G[Frame.AnchorParent]:IsObjectType("Frame")) and _G[Frame.AnchorParent] or UIParent
    self.FocusTargetFrame:SetPoint(Frame.AnchorFrom, AnchorParent, Frame.AnchorTo, Frame.XPosition, Frame.YPosition)
    MilaUI:RegisterRangeFrame(self.FocusTargetFrame, "focustarget")
end