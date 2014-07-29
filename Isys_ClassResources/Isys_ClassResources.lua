-----------------------------------------------------------------------------------------------
-- Client Lua Script for Isys_ClassResources
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- Isys_ClassResources Module Definition
-----------------------------------------------------------------------------------------------
local Isys_ClassResources = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
local nScreenWidth, nScreenHeight = Apollo.GetScreenSize()

local tDefaultSettings = {
	tSpellSlinger = {
		tPos = {
			l = (nScreenWidth / 2) - 165.5,
			t = (nScreenHeight / 2) + 250,
			r = (nScreenWidth / 2) + 165.5,
			b = (nScreenHeight / 2) + 250 + 34,
		},	
	}
}
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function Isys_ClassResources:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    self.tConfig = {}
    self.tConfig.tSpellSlinger = {}

    return o
end

function Isys_ClassResources:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		"Isys_Library",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- Isys_ClassResources OnLoad
-----------------------------------------------------------------------------------------------
function Isys_ClassResources:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("Isys_ClassResources.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- Isys_ClassResources OnDocLoaded
-----------------------------------------------------------------------------------------------
function Isys_ClassResources:OnDocLoaded()
	if GameLib.GetPlayerUnit() then
		self:OnCharacterCreated()
	else
		Apollo.RegisterEventHandler("CharacterCreated", "OnCharacterCreated", self)
	end
end

-----------------------------------------------------------------------------------------------
-- Save and load Functions
-----------------------------------------------------------------------------------------------
function Isys_ClassResources:OnSave(eType)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then return end
	local tSave = self.tConfig
	return tSave
end

function Isys_ClassResources:OnRestore()
	local iLib = Apollo.GetAddon("Isys_Library")
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then return end
	if tData then
		iLib:Merge(self.tConfig, tData)
	else
		iLib:Merge(self.tConfig, tDefaultSettings)
	end
end

-----------------------------------------------------------------------------------------------
-- Isys_ClassResources Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here
function Isys_ClassResources:OnCharacterCreated()
	local iLib = Apollo.GetAddon("Isys_Library")
	local classId = GameLib.GetPlayerUnit():GetClassId()
	if classId == GameLib.CodeEnumClass.Spellslinger then
		self:OnCreateSlinger()
	end
end

-----------------------------------------------------------------------------------------------
-- Spellslinger
-----------------------------------------------------------------------------------------------

function Isys_ClassResources:OnCreateSlinger()
	Apollo.RegisterEventHandler("VarChange_FrameCount", "OnSlingerUpdateTimer", self)
	Apollo.RegisterEventHandler("UnitEnteredCombat", "OnSlingerEnteredCombat", self)
	Apollo.RegisterSlashCommand("irreset", "Reset", self)

    self.wndSpellSlinger = Apollo.LoadForm(self.xmlDoc, "SpellSlinger", nil, self)
	self.wndSpellSlinger:ToFront()

	self.wndSlinger1 = self.wndSpellSlinger:FindChild("Node1")
	self.wndSlinger2 = self.wndSpellSlinger:FindChild("Node2")
	self.wndSlinger3 = self.wndSpellSlinger:FindChild("Node3")
	self.wndSlinger4 = self.wndSpellSlinger:FindChild("Node4")
	self.wndSlinger1:FindChild("NodeProgress"):SetProgress(250)
	self.wndSlinger1:FindChild("NodeProgress"):SetProgress(250)
	self.wndSlinger2:FindChild("NodeProgress"):SetProgress(250)
	self.wndSlinger3:FindChild("NodeProgress"):SetProgress(250)
	self.wndSlinger4:FindChild("NodeProgress"):SetProgress(250)

	self.nFadeLevel = 0
	self.xmlDoc = nil

	self:Reset()
end

function Isys_ClassResources:OnSlingerUpdateTimer()
	local unitPlayer = GameLib.GetPlayerUnit()
	local nResourceMax = unitPlayer:GetMaxResource(4)
	local nResourceCurrent = unitPlayer:GetResource(4)
	local nResourceMaxDiv4 = nResourceMax / 4
	local bSurgeActive = GameLib.IsSpellSurgeActive()
	local bInCombat = unitPlayer:IsInCombat()
	self.wndSpellSlinger:Show(true)

	-- Nodes
	local strNodeTooltip = String_GetWeaselString(Apollo.GetString("Spellslinger_SpellSurge"), nResourceCurrent, nResourceMax)
	for idx, wndCurr in pairs({ self.wndSlinger1, self.wndSlinger2, self.wndSlinger3, self.wndSlinger4 }) do
		local nPartialProgress = nResourceCurrent - (nResourceMaxDiv4 * (idx - 1)) -- e.g. 250, 500, 750, 1000
		local bThisBubbleFilled = nPartialProgress >= nResourceMaxDiv4
		wndCurr:FindChild("NodeProgress"):SetMax(nResourceMaxDiv4)
		wndCurr:FindChild("NodeProgress"):SetProgress(nPartialProgress, 100)
		if bSurgeActive then
			wndCurr:FindChild("NodeProgress"):SetBarColor("xkcdBloodOrange")
		else
			wndCurr:FindChild("NodeProgress"):SetBarColor("xkcdBrightBlue")
		end
	end
end

function Isys_ClassResources:ApplyPosition(wnd,tbl)
	local x = tbl.tPos
	wnd:SetAnchorOffsets(x.l, x.t, x.r, x.b)
end

function Isys_ClassResources:Reset()
	local iLib = Apollo.GetAddon("Isys_Library")
	self.tConfig = nil
	self.tConfig = {}
	iLib:Merge(self.tConfig, tDefaultSettings)
	self:ApplyPosition(self.wndSpellSlinger,self.tConfig.tSpellSlinger)
end

-----------------------------------------------------------------------------------------------
-- Isys_ClassResources Instance
-----------------------------------------------------------------------------------------------
local Isys_ClassResourcesInst = Isys_ClassResources:new()
Isys_ClassResourcesInst:Init()
