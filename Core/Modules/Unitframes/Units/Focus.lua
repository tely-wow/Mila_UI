local _, MilaUI = ...
local oUF = MilaUI.oUF

function MilaUI:SpawnFocusFrame()
    if not MilaUI.DB.profile.Unitframes.Focus.Frame.Enabled then return end
    local Frame = MilaUI.DB.profile.Unitframes.Focus.Frame
    oUF:RegisterStyle("MilaUI_Focus", function(self) MilaUI.CreateUnitFrame(self, "Focus") end)
    oUF:SetActiveStyle("MilaUI_Focus")
    self.FocusFrame = oUF:Spawn("focus", "MilaUI_Focus")
    local AnchorParent = (_G[Frame.AnchorParent] and _G[Frame.AnchorParent]:IsObjectType("Frame")) and _G[Frame.AnchorParent] or UIParent
    self.FocusFrame:SetPoint(Frame.AnchorFrom, AnchorParent, Frame.AnchorTo, Frame.XPosition, Frame.YPosition)
    if Frame.CustomScale then self.FocusFrame:SetScale(Frame.Scale) end
    
    -- Dual castbar system integration
    local castbarSettings = MilaUI.DB.profile.castBars and MilaUI.DB.profile.castBars.focus
    if castbarSettings and castbarSettings.enabled then
        if MilaUI.NewCastbarSystem and MilaUI.NewCastbarSystem.CreateCleanCastBar then
            MilaUI.NewCastbarSystem.CreateCleanCastBar(self.FocusFrame, "focus", castbarSettings)
            if self.FocusFrame.Castbar then
                self.FocusFrame.Castbar:Hide()
            end
        end
    end
end