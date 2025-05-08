local _, MilaUI = ...
local Serialize = LibStub:GetLibrary("AceSerializer-3.0")
local Compress = LibStub:GetLibrary("LibDeflate")

function MilaUI:ExportSavedVariables()
    local SerializedInfo = Serialize:Serialize(MilaUI.DB.profile)
    local CompressedInfo = Compress:CompressDeflate(SerializedInfo)
    local EncodedInfo = Compress:EncodeForPrint(CompressedInfo)
    return EncodedInfo
end

function MilaUI:ImportSavedVariables(EncodedInfo)
    local DecodedInfo = Compress:DecodeForPrint(EncodedInfo)
    local DecompressedInfo = Compress:DecompressDeflate(DecodedInfo)
    local InformationDecoded, InformationTable = Serialize:Deserialize(DecompressedInfo)

    if not InformationDecoded then print("Failed to import: invalid or corrupted string.") return end

    StaticPopupDialogs["MilaUI_IMPORT_PROFILE_NAME"] = {
        text = "Enter A Profile Name:",
        button1 = "Import",
        button2 = "Cancel",
        hasEditBox = true,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        OnAccept = function(self)
            local newProfileName = self.editBox:GetText()
            if newProfileName and newProfileName ~= "" then
                MilaUI.DB:SetProfile(newProfileName)
                for k in pairs(MilaUI.DB.profile) do
                    MilaUI.DB.profile[k] = nil
                end
                for k, v in pairs(InformationTable) do
                    MilaUI.DB.profile[k] = v
                end

                MilaUI:CreateReloadPrompt()
            else
                print("Please enter a valid profile name.")
            end
        end,
    }

    StaticPopup_Show("MilaUI_IMPORT_PROFILE_NAME")
end

function MilaUI:ExportMilaUI(profileKey)
    local profile = MilaUI.DB.profiles[profileKey]
    if not profile then return nil end
    local SerializedInfo = Serialize:Serialize(profile)
    local CompressedInfo = Compress:CompressDeflate(SerializedInfo)
    local EncodedInfo = Compress:EncodeForPrint(CompressedInfo)
    return EncodedInfo
end

function MilaUI:ImportMilaUI(importString, profileKey)
    local DecodedInfo = Compress:DecodeForPrint(importString)
    local DecompressedInfo = Compress:DecompressDeflate(DecodedInfo)
    local success, profileData = Serialize:Deserialize(DecompressedInfo)
    if success and type(profileData) == "table" then
        MilaUI.DB.profiles[profileKey] = profileData
        MilaUI.DB:SetProfile(profileKey)
    end
end