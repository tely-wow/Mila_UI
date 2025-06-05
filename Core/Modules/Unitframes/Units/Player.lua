local _, MilaUI = ...
local oUF = MilaUI.oUF

function MilaUI:SpawnPlayerFrame()
    if not MilaUI.DB.profile.Unitframes.Player.Frame.Enabled then return end
    local Frame = MilaUI.DB.profile.Unitframes.Player.Frame
    oUF:RegisterStyle("MilaUI_Player", function(self) MilaUI.CreateUnitFrame(self, "Player") end)
    oUF:SetActiveStyle("MilaUI_Player")
    self.PlayerFrame = oUF:Spawn("player", "MilaUI_Player")
    local AnchorParent = (_G[Frame.AnchorParent] and _G[Frame.AnchorParent]:IsObjectType("Frame")) and _G[Frame.AnchorParent] or UIParent
    self.PlayerFrame:SetPoint(Frame.AnchorFrom, AnchorParent, Frame.AnchorTo, Frame.XPosition, Frame.YPosition)
    if Frame.CustomScale then self.PlayerFrame:SetScale(Frame.Scale) end
end