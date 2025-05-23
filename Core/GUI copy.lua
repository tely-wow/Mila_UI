







            local PortraitOptions = MilaUI_GUI:Create("InlineGroup")
            PortraitOptions:SetTitle("Portrait Options")
            PortraitOptions:SetLayout("Flow")
            PortraitOptions:SetFullWidth(true)

            local PortraitEnabled = MilaUI_GUI:Create("CheckBox")
            PortraitEnabled:SetLabel("Enable Portrait")
            PortraitEnabled:SetValue(Portrait.Enabled)
            PortraitEnabled:SetCallback("OnValueChanged", function(widget, event, value) Portrait.Enabled = value MilaUI:CreateReloadPrompt() end)
            PortraitEnabled:SetRelativeWidth(1)
            PortraitOptions:AddChild(PortraitEnabled)

            local PortraitAnchorFrom = MilaUI_GUI:Create("Dropdown")
            PortraitAnchorFrom:SetLabel("Anchor From")
            PortraitAnchorFrom:SetList(AnchorPoints)
            PortraitAnchorFrom:SetValue(Portrait.AnchorFrom)
            PortraitAnchorFrom:SetCallback("OnValueChanged", function(widget, event, value) Portrait.AnchorFrom = value MilaUI:UpdateFrames() end)
            PortraitAnchorFrom:SetRelativeWidth(0.5)
            PortraitOptions:AddChild(PortraitAnchorFrom)

            local PortraitAnchorTo = MilaUI_GUI:Create("Dropdown")
            PortraitAnchorTo:SetLabel("Anchor To")
            PortraitAnchorTo:SetList(AnchorPoints)
            PortraitAnchorTo:SetValue(Portrait.AnchorTo)
            PortraitAnchorTo:SetCallback("OnValueChanged", function(widget, event, value) Portrait.AnchorTo = value MilaUI:UpdateFrames() end)
            PortraitAnchorTo:SetRelativeWidth(0.5)
            PortraitOptions:AddChild(PortraitAnchorTo)

            local PortraitSize = MilaUI_GUI:Create("Slider")
            PortraitSize:SetLabel("Portrait Size")
            PortraitSize:SetSliderValues(1, 999, 0.1)
            PortraitSize:SetValue(Portrait.Size)
            PortraitSize:SetCallback("OnMouseUp", function(widget, event, value) Portrait.Size = value MilaUI:UpdateFrames() end)
            PortraitSize:SetRelativeWidth(0.33)
            PortraitOptions:AddChild(PortraitSize)

            local PortraitXOffset = MilaUI_GUI:Create("Slider")
            PortraitXOffset:SetLabel("Portrait X Offset")
            PortraitXOffset:SetSliderValues(-999, 999, 1)
            PortraitXOffset:SetValue(Portrait.XOffset)
            PortraitXOffset:SetCallback("OnMouseUp", function(widget, event, value) Portrait.XOffset = value MilaUI:UpdateFrames() end)
            PortraitXOffset:SetRelativeWidth(0.33)
            PortraitOptions:AddChild(PortraitXOffset)

            local PortraitYOffset = MilaUI_GUI:Create("Slider")
            PortraitYOffset:SetLabel("Portrait Y Offset")
            PortraitYOffset:SetSliderValues(-999, 999, 1)
            PortraitYOffset:SetValue(Portrait.YOffset)
            PortraitYOffset:SetCallback("OnMouseUp", function(widget, event, value) Portrait.YOffset = value MilaUI:UpdateFrames() end)
            PortraitYOffset:SetRelativeWidth(0.33)
            PortraitOptions:AddChild(PortraitYOffset)

            MilaUI_GUI_Container:AddChild(PortraitOptions)
            
            local AbsorbsContainer = MilaUI_GUI:Create("InlineGroup")
            AbsorbsContainer:SetTitle("Health Prediction Options")
            AbsorbsContainer:SetLayout("Flow")
            AbsorbsContainer:SetFullWidth(true)
            HealthOptionsContainer:AddChild(AbsorbsContainer)

            local AbsorbsEnabled = MilaUI_GUI:Create("CheckBox")
            AbsorbsEnabled:SetLabel("Enable Absorbs")
            AbsorbsEnabled:SetValue(Absorbs.Enabled)
            AbsorbsEnabled:SetCallback("OnValueChanged", function(widget, event, value) Absorbs.Enabled = value MilaUI:CreateReloadPrompt() end)
            AbsorbsEnabled:SetRelativeWidth(0.5)
            AbsorbsContainer:AddChild(AbsorbsEnabled)

            local AbsorbsColourPicker = MilaUI_GUI:Create("ColorPicker")
            AbsorbsColourPicker:SetLabel("Colour")
            local AR, AG, AB, AA = unpack(Absorbs.Colour)
            AbsorbsColourPicker:SetColor(AR, AG, AB, AA)
            AbsorbsColourPicker:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) Absorbs.Colour = {r, g, b, a} MilaUI:UpdateFrames() end)
            AbsorbsColourPicker:SetHasAlpha(true)
            AbsorbsColourPicker:SetRelativeWidth(0.5)
            AbsorbsContainer:AddChild(AbsorbsColourPicker)

            local HealAbsorbsContainer = MilaUI_GUI:Create("InlineGroup")
            HealAbsorbsContainer:SetTitle("Heal Absorbs")
            HealAbsorbsContainer:SetLayout("Flow")
            HealAbsorbsContainer:SetFullWidth(true)
            HealthOptionsContainer:AddChild(HealAbsorbsContainer)

            local HealAbsorbsEnabled = MilaUI_GUI:Create("CheckBox")
            HealAbsorbsEnabled:SetLabel("Enable Heal Absorbs")
            HealAbsorbsEnabled:SetValue(HealAbsorbs.Enabled)
            HealAbsorbsEnabled:SetCallback("OnValueChanged", function(widget, event, value) HealAbsorbs.Enabled = value MilaUI:UpdateFrames() end)
            HealAbsorbsEnabled:SetRelativeWidth(0.5)
            HealAbsorbsContainer:AddChild(HealAbsorbsEnabled)

            local HealAbsorbsColourPicker = MilaUI_GUI:Create("ColorPicker")
            HealAbsorbsColourPicker:SetLabel("Colour")
            local HAR, HAG, HAB, HAA = unpack(HealAbsorbs.Colour)
            HealAbsorbsColourPicker:SetColor(HAR, HAG, HAB, HAA)
            HealAbsorbsColourPicker:SetCallback("OnValueChanged", function(widget, _, r, g, b, a) HealAbsorbs.Colour = {r, g, b, a} MilaUI:UpdateFrames() end)
            HealAbsorbsColourPicker:SetHasAlpha(true)
            HealAbsorbsColourPicker:SetRelativeWidth(0.5)
            HealAbsorbsContainer:AddChild(HealAbsorbsColourPicker)

            MilaUI_GUI_Container:AddChild(HealthOptionsContainer)

    


