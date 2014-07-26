local Isys_ThreatMeter = Apollo.GetAddon("Isys_ThreatMeter")
local DaiGUI = Apollo.GetPackage("DaiGUI-1.0").tPackage

-- note: color picker based options are set in the ui.lua file

function Isys_ThreatMeter:ShowOptionsWindow()
	if not self.wndOptions or not self.wndOptions:IsValid() then
		self.wndOptions = self:CreateOptionsWindow()
	end
	self.wndOptions:FindChild("TPSSlider"):SetValue(self.db.nTPSWindow)
	self.wndOptions:FindChild("TPSEditBox"):SetText(string.format("%.0f", self.db.nTPSWindow))
	self.wndOptions:FindChild("WarningThresholdSlider"):SetValue(self.db.fWarningThreshold)
	self.wndOptions:FindChild("WarningThresholdEditBox"):SetText(string.format("%.0f", self.db.fWarningThreshold))
	self.wndOptions:FindChild("WarningOpacitySlider"):SetValue(self.db.fWarningOpacity)
	self.wndOptions:FindChild("WarningOpacityEditBox"):SetText(string.format("%.0f", self.db.fWarningOpacity))
	self.wndOptions:FindChild("HideWhenNotInCombat"):SetCheck(self.db.bHideWhenNotInCombat)
	self.wndOptions:FindChild("LockWindow"):SetCheck(self.db.bLockMainWindow)
	self.wndOptions:FindChild("WarningLock"):SetCheck(self.db.bLockWarningWindow)
	self.wndOptions:FindChild("MainWindowOpacitySlider"):SetValue(self.db.fMainWindowOpacity)
	self.wndOptions:FindChild("MainWindowOpacityEditBox"):SetText(string.format("%.0f", self.db.fMainWindowOpacity))
	self.wndOptions:FindChild("ArtWorkOpacitySlider"):SetValue(self.db.fArtWorkOpacity)
	self.wndOptions:FindChild("ArtWorkOpacityEditBox"):SetText(string.format("%.0f", self.db.fArtWorkOpacity))
	self.wndOptions:FindChild("ShowWhenInGroup"):SetCheck(self.db.bShowWhenInGroup)
	self.wndOptions:FindChild("ShowWhenInRaid"):SetCheck(self.db.bShowWhenInRaid)
	self.wndOptions:FindChild("ShowWhenAlone"):SetCheck(self.db.bShowWhenAlone)
	self.wndOptions:FindChild("ShowWhenHavePet"):SetCheck(self.db.bShowWhenHavePet)
	self.wndOptions:FindChild("HideWhenInPvP"):SetCheck(self.db.bHideWhenInPvP)
	self.wndOptions:FindChild("HideWhenNotInCombat"):SetCheck(self.db.bHideWhenNotInCombat)
	self.wndOptions:FindChild("WarningUseMessage"):SetCheck(self.db.bWarningUseMessage)
	self.wndOptions:FindChild("WarningUseSound"):SetCheck(self.db.bWarningUseSound)
	self.wndOptions:FindChild("WarningTankDisable"):SetCheck(self.db.bWarningTankDisable)
	self.wndOptions:FindChild("PlayerBarColor"):SetBGColor(self.db.crPlayer)
	self.wndOptions:FindChild("PlayerPetBarColor"):SetBGColor(self.db.crPlayerPet)
	self.wndOptions:FindChild("GroupMemberBarColor"):SetBGColor(self.db.crGroupMember)
	self.wndOptions:FindChild("NotPlayerBarColor"):SetBGColor(self.db.crNotPlayer)
	self.wndOptions:FindChild("ThreatTotalPrecision"):SetCheck(self.db.bThreatTotalPrecision)
	self.wndOptions:Show(true)
end

function Isys_ThreatMeter:OnOptionsClose( wndHandler, wndControl, eMouseButton )
	self.wndOptions:Show(false)
end

function Isys_ThreatMeter:OnTPSSliderBarChanged( wndHandler, wndControl, fNewValue, fOldValue )
	self.wndOptions:FindChild("TPSEditBox"):SetText(string.format("%.0f", fNewValue))
	self.db.nTPSWindow = fNewValue
end

function Isys_ThreatMeter:OnShowWhenInGroup( wndHandler, wndControl, eMouseButton )
	self.db.bShowWhenInGroup = wndControl:IsChecked()
	self:UpdateVisibility()
end

function Isys_ThreatMeter:OnShowWhenHavePet( wndHandler, wndControl, eMouseButton )
	self.db.bShowWhenHavePet = wndControl:IsChecked()
	self:UpdateVisibility()
end

function Isys_ThreatMeter:OnWarningThresholdSliderBarChanged( wndHandler, wndControl, fNewValue, fOldValue )
	self.wndOptions:FindChild("WarningThresholdEditBox"):SetText(string.format("%.0f", fNewValue))
	self.db.fWarningThreshold = fNewValue
end

function Isys_ThreatMeter:OnWarningOpacitySliderBarChanged( wndHandler, wndControl, fNewValue, fOldValue )
	self.wndOptions:FindChild("WarningOpacityEditBox"):SetText(string.format("%.0f", fNewValue))
	self.db.fWarningOpacity = fNewValue
	self:UpdateVisibility()
end

function Isys_ThreatMeter:OnMainWindowOpacitySliderBarChanged( wndHandler, wndControl, fNewValue, fOldValue )
	self.wndOptions:FindChild("MainWindowOpacityEditBox"):SetText(string.format("%.0f", fNewValue))
	self.db.fMainWindowOpacity = fNewValue
	self:UpdateVisibility()
end

function Isys_ThreatMeter:OnArtWorkOpacitySliderBarChanged( wndHandler, wndControl, fNewValue, fOldValue )
	self.wndOptions:FindChild("ArtWorkOpacityEditBox"):SetText(string.format("%.0f", fNewValue))
	self.db.fArtWorkOpacity = fNewValue
	self:UpdateVisibility()
end

function Isys_ThreatMeter:OnWarningUseMessage( wndHandler, wndControl, eMouseButton )
	self.db.bWarningUseMessage = wndControl:IsChecked()
	self:UpdateVisibility()
end

function Isys_ThreatMeter:OnWarningLock( wndHandler, wndControl, eMouseButton )
	self.db.bLockWarningWindow = wndControl:IsChecked()
	self:UpdateVisibility()
end

function Isys_ThreatMeter:OnMainWindowLock( wndHandler, wndControl, eMouseButton )
	self.db.bLockMainWindow = wndControl:IsChecked()
	self:UpdateVisibility()
end

function Isys_ThreatMeter:OnWarningUseSound( wndHandler, wndControl, eMouseButton )
	self.db.bWarningUseSound = wndControl:IsChecked()
	self:UpdateVisibility()
end

function Isys_ThreatMeter:OnHideWhenNotInCombat( wndHandler, wndControl, eMouseButton )
	self.db.bHideWhenNotInCombat = wndControl:IsChecked()
	self:UpdateVisibility()
end

function Isys_ThreatMeter:OnHideWhenInInstancedPvP( wndHandler, wndControl, eMouseButton )
	self.db.bHideWhenInPvP = wndControl:IsChecked()
	self:UpdateVisibility()
end

function Isys_ThreatMeter:OnShowWhenAlone( wndHandler, wndControl, eMouseButton )
	self.db.bShowWhenAlone = wndControl:IsChecked()
	self:UpdateVisibility()
end

function Isys_ThreatMeter:OnShowWhenInRaid( wndHandler, wndControl, eMouseButton )
	self.db.bShowWhenInRaid = wndControl:IsChecked()
	self:UpdateVisibility()
end

function Isys_ThreatMeter:OnWarningTankDisable( wndHandler, wndControl, eMouseButton )
	self.db.bWarningTankDisable = wndControl:IsChecked()
	self:UpdateVisibility()
end

function Isys_ThreatMeter:OnThreatTotalPrecision(wndHandler, wndControl, eMouseButton)
	self.db.bThreatTotalPrecision = wndControl:IsChecked()
	self:UpdateVisibility()
end
