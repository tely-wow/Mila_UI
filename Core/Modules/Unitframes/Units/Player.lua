local _, MilaUI = ...
local oUF = MilaUI.oUF

function MilaUI:SpawnPlayerFrame()
    if not MilaUI.DB.profile.Unitframes.Player.Frame.Enabled then return end
    local Frame = MilaUI.DB.profile.Unitframes.Player.Frame
    if MilaUI.DB.global.DebugMode then
        print("[Mila_UI] Begin SpawnPlayerFrame")
    end
    oUF:RegisterStyle("MilaUI_Player", function(self) MilaUI.CreateUnitFrame(self, "Player") end)
    oUF:SetActiveStyle("MilaUI_Player")
    self.PlayerFrame = oUF:Spawn("player", "MilaUI_Player")
    if MilaUI.DB.global.DebugMode then
        print("[Mila_UI] PlayerFrame spawned:", self.PlayerFrame and self.PlayerFrame:GetName() or tostring(self.PlayerFrame))
    end
    local AnchorParent = (_G[Frame.AnchorParent] and _G[Frame.AnchorParent]:IsObjectType("Frame")) and _G[Frame.AnchorParent] or UIParent
    self.PlayerFrame:SetPoint(Frame.AnchorFrom, AnchorParent, Frame.AnchorTo, Frame.XPosition, Frame.YPosition)
    if MilaUI.DB.global.DebugMode then
        print("[Mila_UI] PlayerFrame positioned at", Frame.AnchorFrom, Frame.AnchorTo, Frame.XPosition, Frame.YPosition)
    end
    if Frame.CustomScale then
        self.PlayerFrame:SetScale(Frame.Scale)
        if MilaUI.DB.global.DebugMode then
            print("[Mila_UI] PlayerFrame scaled to", Frame.Scale)
        end
    end
    if MilaUI.DB.global.DebugMode then
        print("[Mila_UI] PlayerFrame created.")
    end
    -- Mila_UI: Dual castbar system integration
    local castbarSettings = MilaUI.DB.profile.castBars and MilaUI.DB.profile.castBars.player
    if castbarSettings and castbarSettings.enabled then
        if MilaUI.DB.global.DebugMode then
            print("[Mila_UI] Spawning new castbar for player frame.")
        end
        if MilaUI.NewCastbarSystem and MilaUI.NewCastbarSystem.CreateCleanCastBar then
            local result = MilaUI.NewCastbarSystem.CreateCleanCastBar(self.PlayerFrame, "player", castbarSettings)
            if MilaUI.DB.global.DebugMode then
                print("[Mila_UI] CreateCleanCastBar result:", result or "(no return value)")
            end
            if self.PlayerFrame.Castbar then
                if MilaUI.DB.global.DebugMode then
                    print("[Mila_UI] Hiding oUF castbar for player frame.")
                end
                self.PlayerFrame.Castbar:Hide()
            else
                if MilaUI.DB.global.DebugMode then
                    print("[Mila_UI] No oUF castbar found on player frame.")
                end
            end
        else
            if MilaUI.DB.global.DebugMode then
                print("[Mila_UI] ERROR: NewCastbarSystem or CreateCleanCastBar missing!")
            end
        end
    end
    if MilaUI.DB.global.DebugMode then
        print("[Mila_UI] End SpawnPlayerFrame")
    end

end