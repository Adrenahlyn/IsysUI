-----------------------------------------------------------------------------------------------
-- Client Lua Script for Isys_CastBars
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- Isys_CastBars Module Definition
-----------------------------------------------------------------------------------------------
local Isys_CastBars = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
local tDefaultSettings = {
	tPlayer = {
		tPos = {
			l = 0,
			t = 0,
			r = 0,
			b = 0,
		},
		bShowIcon = true,
		bShowCastTime = true,
	},
	tTarget = {
		tPos = {
			l = 0,
			t = 0,
			r = 0,
			b = 0,
		},
		bShowIcon = true,
		bShowCastTime = true,
	},
	tFocus = {
		tPos = {
			l = 0,
			t = 0,
			r = 0,
			b = 0,
		},
		bShowIcon = true,
		bShowCastTime = true,
	},
}
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function Isys_CastBars:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    self.tConfig = {}
    self.tConfig.tPlayer = {}
    self.tConfig.tTarget = {}
    self.tConfig.tFocus = {}

    return o
end

function Isys_CastBars:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		"Isys_Library",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- Isys_CastBars OnLoad
-----------------------------------------------------------------------------------------------
function Isys_CastBars:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("Isys_CastBars.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- Isys_CastBars OnDocLoaded
-----------------------------------------------------------------------------------------------
function Isys_CastBars:OnDocLoaded()
	self.wndPlayer = Apollo.LoadForm(self.xmlDoc, "PlayerCastBar", nil, self)
	self.wndTarget = Apollo.LoadForm(self.xmlDoc, "TargetCastBar", nil, self)
	self.wndFocus = Apollo.LoadForm(self.xmlDoc, "FocusCastBar", nil, self)

	Apollo.RegisterEventHandler("VarChange_FrameCount", "OnUpdate", self)
	Apollo.RegisterEventHandler("FrameLockToggle", "OnFrameLockToggle", self)
	Apollo.RegisterEventHandler("PreviewModeToggle", "OnPreviewModeToggle", self)
	Apollo.RegisterEventHandler("IsysMasterReset", "Reset", self)

	if GameLib.GetPlayerUnit() then
		self:OnCharacterCreated()
	else
		Apollo.RegisterEventHandler("CharacterCreated")
	end
end

-----------------------------------------------------------------------------------------------
-- Save and Load Functions
-----------------------------------------------------------------------------------------------
function Isys_CastBars:OnSave(eType)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then return end
	--local tSave = self.tConfig
	--return tSave
end

function Isys_CastBars:OnRestor(eType,tData)
	local iLib = Apollo.GetAddon("Isys_Library")
	if tData then
		--iLib:Merge(self.tConfig,tData)
	else
		--iLib:Merget(self.tConfig,tDefaultSettings)
	end
end

-----------------------------------------------------------------------------------------------
-- Isys_CastBars Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here
function Isys_CastBars:CharacterCreated()
	if self.tConfig.tPlayer.tPos.l then
		--self:ApplyPositions()
	else
		--self:Reset()
		--self:ApplyPositions()
	end
end

function Isys_CastBars:OnUpdate()
	if GameLib.GetPlayerUnit():IsCasting() then
		self:BuildCastBar(self.wndPlayer,1)
		self.wndPlayer:Show(true)
	else
		self.wndPlayer:Show(false)
	end
	if GameLib.GetTargetUnit() and GameLib.GetTargetUnit():IsCasting() then 
		self:BuildCastBar(self.wndTarget,2)
		self.wndTarget:Show(true)
	else
		self.wndTarget:Show(false)
	end
	if GameLib.GetTargetUnit():GetAlternateTarget() and GameLib.GetTargetUnit():GetAlternateTarget():IsCasting() then
		self:BuildCastBar(self.wndFocus,3)
		self.wndFocus:Show(true)
	else
		self.wndFocus:Show(false)
	end
end

function Isys_CastBars:BuildCastBar(wnd,unitType)
	-- body
end


-----------------------------------------------------------------------------------------------
-- Isys_CastBars Instance
-----------------------------------------------------------------------------------------------
local Isys_CastBarsInst = Isys_CastBars:new()
Isys_CastBarsInst:Init()
