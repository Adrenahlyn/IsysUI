-----------------------------------------------------------------------------------------------
-- Client Lua Script for Isys_Settings
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- Isys_Settings Module Definition
-----------------------------------------------------------------------------------------------
local Isys_Settings = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
local tDefaultSettings = {
	tOptions = {
		bPreviewMode = false,
		bFrameLock = true,
	},
	tUnitFrames = {
		bShowPlayerTextMouseOver = false,
		bShowTargetTextMouseOver = false,
	},
	tSprintBar = {
		bHideWhenFull = false,
	},
	tResourceBar = {
		bShowInnateOnBar = true,
	},
}

local tContentWindows = {
	[1] = "Options",
	[2] = "UnitFrames",
	[3] = "SprintBar",
}
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function Isys_Settings:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    self.tSettings = {}
    self.tSettings.tOptions = {}
    self.tSettings.tUnitFrames = {}
    self.tSettings.tSprintBar = {}
    self.tSettings.tResourceBar = {}

    return o
end

function Isys_Settings:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		"Isys_Library",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- Isys_Settings OnLoad
-----------------------------------------------------------------------------------------------
function Isys_Settings:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("Isys_Settings.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- Isys_Settings OnDocLoaded
-----------------------------------------------------------------------------------------------
function Isys_Settings:OnDocLoaded()
	self.wndMain = Apollo.LoadForm("Isys_Settings.xml", "Isys_SettingsForm", nil, self)
	Apollo.RegisterSlashCommand("isys", "OpenOptions", self)
	Apollo.RegisterSlashCommand("id", "Debug", self)
	Apollo.RegisterSlashCommand("reset", "Reset", self)

	self.wndMain:Show(false)

	self.wndMain:FindChild("OptionsBtn"):SetCheck(true)
	self.wndMain:FindChild("Options"):Show(true)


	if GameLib.GetPlayerUnit() then
		self:OnCharacterCreated()
	else
		Apollo.RegisterEventHandler("CharacteCreated", "OnCharacterCreated", self)
	end
end

function Isys_Settings:Debug()
	iLib = Apollo.GetAddon("Isys_Library")
	local tTest = self.tSettings
	iLib:Print(iLib:table_tostring(tTest))
end

-----------------------------------------------------------------------------------------------
-- Isys_Save Functions
-----------------------------------------------------------------------------------------------
function Isys_Settings:OnSave(eType)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then return end
	local tSave = self.tSettings
	return tSave
end

function Isys_Settings:OnRestore(eType, tData)
	iLib = Apollo.GetAddon("Isys_Library")
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then return end

	if tData then
		iLib:Merge(self.tSettings,tData)
	else
		iLib:Merge(self.tSettings,tDefaultSettings)
	end
end

-----------------------------------------------------------------------------------------------
-- Isys_Settings Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here
function Isys_Settings:OnCharacterCreated()
	iLib = Apollo.GetAddon("Isys_Library")
	self:ApplyAllSettings()
	iLib:Print("[IsysUI]:Loaded.")
	iLib:Print("[IsysUI]: Type '/isys' to open the settings menu.")

	if self.tSettings.tResourceBar.bShowInnateOnBar == nil then
		self:Reset()
	end
end

function Isys_Settings:OpenOptions()
	self.wndMain:Show(true)
end

function Isys_Settings:CloseOptions()
	self.wndMain:Show(false)
end

function Isys_Settings:HideContentWindows()
	for _,v in pairs(tContentWindows) do
		self.wndMain:FindChild(v):Show(false)
	end
end

function Isys_Settings:Reset()
	iLib = Apollo.GetAddon("Isys_Library")
	self.tSettings = nil
	self.tSettings = {}
	iLib:Merge(self.tSettings,tDefaultSettings)
	self:ApplyAllSettings()

	Event_FireGenericEvent("UnitFrameToggleText", "Player", self.tSettings.tUnitFrames.bShowPlayerTextMouseOver)
	Event_FireGenericEvent("UnitFrameToggleText", "Target", self.tSettings.tUnitFrames.bShowTargetText)
	Event_FireGenericEvent("SprintToggleVisibility", self.tSettings.tSprintBar.bHideWhenFull)
	Event_FireGenericEvent("PreviewModeToggle", self.tSettings.tOptions.bPreviewMode)
	Event_FireGenericEvent("FrameLockToggle", self.tSettings.tOptions.bFrameLock)
	Event_FireGenericEvent("IsysReset")
end

function Isys_Settings:ApplyAllSettings()
	local wndOptions = self.wndMain:FindChild("Options")
	local wndUnitFrames = self.wndMain:FindChild("UnitFrames")
	local wndSprintBar = self.wndMain:FindChild("SprintBar")
	local wndResourceBar = self.wndMain:FindChild("Resources")
	local settings = self.tSettings

	wndOptions:FindChild("PreviewModeBtn"):SetCheck(settings.tOptions.bPreviewMode)
	wndOptions:FindChild("LockElementsBtn"):SetCheck(settings.tOptions.bFrameLock)
	wndUnitFrames:FindChild("TogglePlayerTextBtn"):SetCheck(settings.tUnitFrames.bShowPlayerTextMouseOver)
	wndUnitFrames:FindChild("ToggleTargetTextBtn"):SetCheck(settings.tUnitFrames.bShowTargetTextMouseOver)
	wndSprintBar:FindChild("ToggleVisibilityBtn"):SetCheck(settings.tSprintBar.bHideWhenFull)
	wndResourceBar:FindChild("InnateBarBtn"):SetCheck(settings.tResourceBar.bShowInnateOnBar)
end


---------------------------------------------------------------------------------------------------
-- Isys_Button Functions
---------------------------------------------------------------------------------------------------
function Isys_Settings:OptionsBtn( wndHandler, wndControl, eMouseButton )
	local bIsChecked = wndControl:IsChecked()
	self:HideContentWindows()
	self.wndMain:FindChild("Options"):Show(bIsChecked)
end

function Isys_Settings:UnitFramesBtn( wndHandler, wndControl, eMouseButton )
	local bIsChecked = wndControl:IsChecked()
	self:HideContentWindows()
	self.wndMain:FindChild("UnitFrames"):Show(bIsChecked)
end

function Isys_Settings:SprintBarBtn( wndHandler, wndControl, eMouseButton )
	local bIsChecked = wndControl:IsChecked()
	self:HideContentWindows()
	self.wndMain:FindChild("SprintBar"):Show(bIsChecked)
end

function Isys_Settings:ResourceBarBtn( wndHandler, wndControl, eMouseButton )
	local bIsChecked = wndControl:IsChecked()
	self:HideContentWindows()
	self.wndMain:FindChild("Resources"):Show(bIsChecked)
end

function Isys_Settings:PlayerTextToggle( wndHandler, wndControl, eMouseButton )
	local bIsChecked = not wndControl:IsChecked()
	local bSetting = wndControl:IsChecked()
	Event_FireGenericEvent("UnitFrameToggleText", "Player", bIsChecked)
	self.tSettings.tUnitFrames.bShowPlayerTextMouseOver = bSetting
end

function Isys_Settings:TargetTextToggle( wndHandler, wndControl, eMouseButton )
	local bIsChecked = not wndControl:IsChecked()
	local bSetting = wndControl:IsChecked()
	Event_FireGenericEvent("UnitFrameToggleText", "Target", bIsChecked)
	self.tSettings.tUnitFrames.bShowTargetTextMouseOver = bSetting
end

function Isys_Settings:ToggleSprintVisibility( wndHandler, wndControl, eMouseButton )
	local bIsChecked = wndControl:IsChecked()
	Event_FireGenericEvent("SprintToggleVisibility", bIsChecked)
	self.tSettings.tSprintBar.bHideWhenFull = bIsChecked
end

function Isys_Settings:TogglePreviewMode( wndHandler, wndControl, eMouseButton )
	local bIsChecked = wndControl:IsChecked()
	Event_FireGenericEvent("PreviewModeToggle", bIsChecked)
	self.tSettings.tOptions.bPreviewMode = bIsChecked
end

function Isys_Settings:ToggleFrameLock( wndHandler, wndControl, eMouseButton )
	local bIsChecked = wndControl:IsChecked()
	Event_FireGenericEvent("FrameLockToggle", bIsChecked)
	self.tSettings.tOptions.bFrameLock = bIsChecked
end

function Isys_Settings:ShowInnateOnBar( wndHandler, wndControl, eMouseButton )
	local bIsChecked = wndControl:IsChecked()
	Event_FireGenericEvent("InnateOnBarChange", bIsChecked)
	self.tSettings.tOptions.bShowInnateOnBar = bIsChecked
end

----------------------------------------------------------------------------------------------
-- Isys_Settings Instance
-----------------------------------------------------------------------------------------------
local Isys_SettingsInst = Isys_Settings:new()
Isys_SettingsInst:Init()


