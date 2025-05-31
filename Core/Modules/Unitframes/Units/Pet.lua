local _, MilaUI = ...
local oUF = MilaUI.oUF

function MilaUI:SpawnPetFrame()
    if not MilaUI.DB.profile.Pet.Frame.Enabled then return end
    local Frame = MilaUI.DB.profile.Pet.Frame
    oUF:RegisterStyle("MilaUI_Pet", function(self) MilaUI.CreateUnitFrame(self, "Pet") end)
    oUF:SetActiveStyle("MilaUI_Pet")
    self.PetFrame = oUF:Spawn("pet", "MilaUI_Pet")
    local AnchorParent = (_G[Frame.AnchorParent] and _G[Frame.AnchorParent]:IsObjectType("Frame")) and _G[Frame.AnchorParent] or UIParent
    self.PetFrame:SetPoint(Frame.AnchorFrom, AnchorParent, Frame.AnchorTo, Frame.XPosition, Frame.YPosition)
    if Frame.CustomScale then self.PetFrame:SetScale(Frame.Scale) end
end