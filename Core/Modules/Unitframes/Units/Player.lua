local _, MilaUI = ...
local oUF = MilaUI.oUF

function MilaUI:SpawnPlayerFrame()
    if not MilaUI.DB.profile.Unitframes.Player.Frame.Enabled then return end
    local Frame = MilaUI.DB.profile.Unitframes.Player.Frame
    print("[Mila_UI] Begin SpawnPlayerFrame")
    oUF:RegisterStyle("MilaUI_Player", function(self) MilaUI.CreateUnitFrame(self, "Player") end)
    oUF:SetActiveStyle("MilaUI_Player")
    self.PlayerFrame = oUF:Spawn("player", "MilaUI_Player")
    print("[Mila_UI] PlayerFrame spawned:", self.PlayerFrame and self.PlayerFrame:GetName() or tostring(self.PlayerFrame))
    local AnchorParent = (_G[Frame.AnchorParent] and _G[Frame.AnchorParent]:IsObjectType("Frame")) and _G[Frame.AnchorParent] or UIParent
    self.PlayerFrame:SetPoint(Frame.AnchorFrom, AnchorParent, Frame.AnchorTo, Frame.XPosition, Frame.YPosition)
    print("[Mila_UI] PlayerFrame positioned at", Frame.AnchorFrom, Frame.AnchorTo, Frame.XPosition, Frame.YPosition)
    if Frame.CustomScale then
        self.PlayerFrame:SetScale(Frame.Scale)
        print("[Mila_UI] PlayerFrame scaled to", Frame.Scale)
    end

    -- Mila_UI: Dual castbar system integration
    local castbarSettings = MilaUI.DB.profile.Unitframes.Player.Castbar
    print("[Mila_UI] Player Castbar Settings:", castbarSettings and (castbarSettings.useCleanCastbar and "useCleanCastbar=TRUE" or "useCleanCastbar=FALSE") or "nil")
    if castbarSettings and castbarSettings.useCleanCastbar then
        print("[Mila_UI] Spawning new castbar for player frame.")
        if MilaUI.NewCastbarSystem and MilaUI.NewCastbarSystem.CreateCleanCastBar then
            local result = MilaUI.NewCastbarSystem.CreateCleanCastBar(self.PlayerFrame, "player", castbarSettings)
            print("[Mila_UI] CreateCleanCastBar result:", result or "(no return value)")
            if self.PlayerFrame.Castbar then
                print("[Mila_UI] Hiding oUF castbar for player frame.")
                self.PlayerFrame.Castbar:Hide()
            else
                print("[Mila_UI] No oUF castbar found on player frame.")
            end
        else
            print("[Mila_UI] ERROR: NewCastbarSystem or CreateCleanCastBar missing!")
        end
    end
    print("[Mila_UI] End SpawnPlayerFrame")

end