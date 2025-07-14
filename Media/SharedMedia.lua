local LSM = LibStub("LibSharedMedia-3.0") 
local IsAddOnLoaded = _G.C_AddOns and _G.C_AddOns.IsAddOnLoaded or _G.IsAddOnLoaded

if LSM == nil then return end

-- Register the MilaUI logo
LSM:Register("background", "MilaUI-Logo", [[Interface\Addons\Mila_UI\Media\logo.tga]])
LSM:Register("font", "Expressway", [[Interface\Addons\Mila_UI\Media\Fonts\Expressway.ttf]])
LSM:Register("statusbar", "Solid", [[Interface\Addons\Mila_UI\Media\Statusbars\solid.tga]])
LSM:Register("statusbar", "AbsorbBar", [[Interface\Addons\Mila_UI\Media\Statusbars\AbsorbBar.tga]])
LSM:Register("statusbar", "Smooth", [[Interface\Addons\Mila_UI\Media\Statusbars\Smooth.tga]])
LSM:Register("statusbar", "Smoothv2", [[Interface\Addons\Mila_UI\Media\Statusbars\Smoothv2.tga]])
LSM:Register("statusbar", "MilaPlayerCastBar", [[Interface\Addons\Mila_UI\Media\Statusbars\Mila_player_castbar.tga]])
LSM:Register("statusbar", "g1", [[Interface\Addons\Mila_UI\Textures\g1.tga]])
LSM:Register("statusbar", "ArmorCastBar", [[Interface\Addons\Mila_UI\Textures\statusbar\ArmorCastBar.tga]])
LSM:Register("statusbar", "HPredHD2", [[Interface\Addons\Mila_UI\Textures\statusbar\HPredHD2.tga]])
LSM:Register("statusbar", "shield-fill", [[Interface\Addons\Mila_UI\Textures\statusbar\shield-fill.tga]])
LSM:Register("statusbar", "HPYellowHD", [[Interface\Addons\Mila_UI\Textures\statusbar\HPYellowHD.tga]])
LSM:Register("statusbar", "MirroredFrameSingleBG", [[Interface\Addons\Mila_UI\Textures\statusbar\MirroredFrameSingleBG.tga]])
LSM:Register("sound", "Whisper", [[Interface\Addons\Mila_UI\Media\Sounds\Whisper.ogg]])