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
	},
	tEngineer = {
		tPos = {
			l = 960 - 140.5,
			t = 540 + 415,
			r = 960 + 140.5,
			b = 540 + 415 + 31
		},
	},
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
    self.tConfig.tSpellSlinger.tPos = {}
    self.tConfig.tEngineer = {}
    self.tConfig.tEngineer.tPos = {}

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
	elseif classId == GameLib.CodeEnumClass.Engineer then
		self:OnCreateEngineer()
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
	self.wndSlingerM = self.wndSpellSlinger:FindChild("Mana")
	self.wndSlinger1:FindChild("NodeProgress"):SetProgress(250)
	self.wndSlinger1:FindChild("NodeProgress"):SetProgress(250)
	self.wndSlinger2:FindChild("NodeProgress"):SetProgress(250)
	self.wndSlinger3:FindChild("NodeProgress"):SetProgress(250)
	self.wndSlinger4:FindChild("NodeProgress"):SetProgress(250)
	

	self.nFadeLevel = 0

	--self:Reset()
end

function Isys_ClassResources:OnSlingerUpdateTimer()
	local unitPlayer = GameLib.GetPlayerUnit()
	local nResourceMax = unitPlayer:GetMaxResource(4)
	local nResourceCurrent = unitPlayer:GetResource(4)
	local nResourceMaxDiv4 = nResourceMax / 4
	local bSurgeActive = GameLib.IsSpellSurgeActive()
	local bInCombat = unitPlayer:IsInCombat()
	self.wndSpellSlinger:Show(true)

	-- Mana
	self.wndSlingerM:FindChild("ManaBar"):SetMax(unitPlayer:GetMaxMana())
	self.wndSlingerM:FindChild("ManaBar"):SetProgress(unitPlayer:GetMana())

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
			wndCurr:FindChild("NodeProgress"):SetBarColor("ff00ffff")
		end
	end
end

-----------------------------------------------------------------------------------------------
-- Engineer
-----------------------------------------------------------------------------------------------

function Isys_ClassResources:OnCreateEngineer()
	Apollo.RegisterEventHandler("VarChange_FrameCount", 		"OnEngineerUpdateTimer", self)
	Apollo.RegisterEventHandler("ShowActionBarShortcut", 		"OnShowActionBarShortcut", self)
	Apollo.RegisterTimerHandler("EngineerOutOfCombatFade", 		"OnEngineerOutOfCombatFade", self)

    self.wndMain = Apollo.LoadForm(self.xmlDoc, "Engineer", nil, self)
	--self.wndMain:FindChild("StanceMenuOpenerBtn"):AttachWindow(self.wndMain:FindChild("StanceMenuBG"))

	for idx = 1, 5 do
		-- self.wndMain:FindChild("Stance"):FindChild("Stance"..idx):SetData(idx)
	end
	local wnd = self.wndMain

	wnd:FindChild("StanceFlyOut"):Show(false)
	wnd:FindChild("PetStanceFlyOut"):Show(false)

	--self:OnShowActionBarShortcut(1, IsActionBarSetVisible(1)) -- Show petbar if active from reloadui/load screen
	self.xmlDoc = nil

	self.bMousedOver = false

	if self.tConfig.tEngineer.tPos.l == nil then
		self:Reset("Engineer")
	end
end

function Isys_ClassResources:OnEngineerUpdateTimer()
	if not self.wndMain then
		return
	end

	local unitPlayer = GameLib.GetPlayerUnit()
	local bInCombat = unitPlayer:IsInCombat()
	local nResourceMax = unitPlayer:GetMaxResource(1)
	local nResourceCurrent = unitPlayer:GetResource(1)
	local nResourcePercent = nResourceCurrent / nResourceMax

	local wndMainResourceFrame = self.wndMain:FindChild("MainResourceFrame")

	if not wndMainResourceFrame then
		return
	end

	local wndResourceFrame = self.wndMain:FindChild("MainResourceFrame")
	local wndBar = wndResourceFrame:FindChild("ProgressBar")
	local wndBarText = wndResourceFrame:FindChild("ProgressText")

	wndBar:SetMax(nResourceMax)
	wndBar:SetProgress(nResourceCurrent)
	wndBarText:SetText(nResourceCurrent)

	if nResourceCurrent < 30 then
		wndBar:SetBarColor("ff0d0d0d")
	elseif nResourceCurrent >= 30 and nResourceCurrent <= 70 then
		wndBar:SetBarColor("ff00ffff")
	elseif nResourceCurrent > 70 then
		wndBar:SetBarColor("ff0d0d0d")
	end

	if GameLib.IsCurrentInnateAbilityActive() then
	end

	self:BtnVis()
end

----------
-- Pet 
----------

function Isys_ClassResources:OnPetStanceBtn(wndHandler, wndControl)
	local strName = wndHandler:GetName()
	local nLen = string.len(strName)
	local nStance = string.sub(wndName, nLen - 3, nLen - 3)
	Pet_SetStance(0, tonumber(nStance)) -- First arg is for the pet ID, 0 means all engineer pets
	self.wndMain:FindChild("PetStanceFlyOut"):Show(false)
	self.wndMain:FindChild("PetBar"):FindChild("StanceBtn"):SetCheck(false)
end

function Isys_ClassResources:OnPetBtn(wndHandler, wndControl)
	 local wndPetContainer = self.wndMain:FindChild("PetBarContainer")
	 wndPetContainer:Show(not wndPetContainer:IsShown())
end


function Isys_ClassResources:TogglePetStance( wndHandler, wndControl, eMouseButton )
	local bIsChecked = wndHandler:IsChecked()
	self.wndMain:FindChild("PetStanceFlyOut"):Show(bIsChecked)
end

function Isys_ClassResources:ToggleStanceFlyOut( wndHandler, wndControl, eMouseButton )
	local bIsChecked = wndHandler:IsChecked()
	self.wndMain:FindChild("StanceFlyOut"):Show(bIsChecked)
end

function Isys_ClassResources:TogglePetBar( wndHandler, wndControl, eMouseButton )
	local wnd = self.wndMain
	local bIsChecked = wndHandler:IsChecked()
	wnd:FindChild("PetActionBtns"):Show(bIsChecked)
	if bIsChecked then
		wnd:FindChild("PetBarToggle"):FindChild("PetBarToggleBtn"):ChangeArt("CRB_InterfaceMenuList:btn_InterfaceMenuList_DownArrowCentered")
	else
		wnd:FindChild("PetBarToggle"):FindChild("PetBarToggleBtn"):ChangeArt("HologramSprites:HoloArrowUpBtn")
	end
end

----------
-- Innate
----------
function Isys_ClassResources:OnInnateShowFlyoutClick( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY )
	if eMouseButton == 1 then
		self.wndMain:FindChild("StanceFlyOut"):Show(not self.wndMain:FindChild("StanceFlyOut"):IsShown())
		if self.wndMain:FindChild("StanceFlyOut"):IsShown() then
			self:InnateFlyout()
		end
	end
end

function Isys_ClassResources:InnateFlyout()
	local wndFlyoutFrame = self.wndMain:FindChild("StanceFlyOut")
	local wndStancePopout = self.wndMain:FindChild("StanceContainer")
	wndStancePopout:DestroyChildren()

	local nCountSkippingTwo = 0
	for idx, spellObject in pairs(GameLib.GetClassInnateAbilitySpells().tSpells) do
		if idx % 2 == 1 then
			nCountSkippingTwo = nCountSkippingTwo + 1
			local strKeyBinding = GameLib.GetKeyBinding("SetStance"..nCountSkippingTwo) -- hardcoded formatting
			local wnd = Apollo.LoadForm("Isys_ClassResources.xml", "InnateButtonTemplate", wndStancePopout, self)
			wnd:FindChild("StanceBtnIcon"):SetSprite(spellObject:GetIcon())
			wnd:SetData(nCountSkippingTwo)

			if Tooltip and Tooltip.GetSpellTooltipForm then
				wnd:SetTooltipDoc(nil)
				Tooltip.GetSpellTooltipForm(self, wnd, spellObject)
			end
		end
	end

	local nHeight = wndStancePopout:ArrangeChildrenVert(0)
	local nLeft, nTop, nRight, nBottom = wndFlyoutFrame:GetAnchorOffsets()
	wndFlyoutFrame:SetAnchorOffsets(nLeft, nBottom - nHeight, nRight, nBottom)
end

function Isys_ClassResources:OnStanceBtn(wndHandler, wndControl)
	GameLib.SetCurrentClassInnateAbilityIndex(wndControl:GetData())
	wndControl:GetParent():GetParent():Show(false)
end


-----------------
-- Misc Functions
-----------------


function Isys_ClassResources:ApplyPosition(wnd,tbl)
	local x = tbl.tPos
	wnd:SetAnchorOffsets(x.l, x.t, x.r, x.b)
end

function Isys_ClassResources:Reset(class)
	local iLib = Apollo.GetAddon("Isys_Library")
	self.tConfig = nil
	self.tConfig = {}
	iLib:Merge(self.tConfig, tDefaultSettings)
	if class == "Engineer" then
		self:ApplyPosition(self.wndMain,self.tConfig.tEngineer)
	elseif class == "SpellSlinger" then
		self:ApplyPosition(self.wndMain,self.tConfig.tSpellSlinger)
	end
end

function Isys_ClassResources:OnGenPetTooltip( wndHandler, wndControl, eToolTipType, x, y )
	local iLib = Apollo.GetAddon("Isys_Library")
	local tPetStrings = {
		[1] = "Commands your pet to attack your target.",
		[2] = "Commands your pet to stop its actions and return to you.",
		[3] = "Commands your pet to move to a location.",
		[4] = "Commands your pet to stay at its location.",
		[5] = "Commands your pet to attack what you attack.",
		[6] = "Commands your pet to not attack.",
		[7] = "Commands your pet to attack what attacks you.",
		[8] = "Commands your pet to attack anything within range.",
	}

	wnd = wndHandler
	wndName = wndHandler:GetName()
	if wndName == "AttackBtn" then
		wnd:SetTooltip(iLib:HelperBuildTooltip(tPetStrings[1],"Attack","ffffffff"))
	elseif wndName == "StopBtn" then
		wnd:SetTooltip(iLib:HelperBuildTooltip(tPetStrings[2],"Return","ffffffff"))
	elseif wndName == "MoveToBtn" then
		wnd:SetTooltip(iLib:HelperBuildTooltip(tPetStrings[3],"Move To","ffffffff"))
	elseif wndName == "Stance1" then
		wnd:SetTooltip(iLib:HelperBuildTooltip(tPetStrings[8], "Aggressive", "ffffffff"))
	elseif wndName == "Stance2" then
		wnd:SetTooltip(iLib:HelperBuildTooltip(tPetStrings[7], "Defensive", "ffffffff"))
	elseif wndName == "Stance3" then
		wnd:SetTooltip(iLib:HelperBuildTooltip(tPetStrings[6], "Passive", "ffffffff"))
	elseif wndName == "Stance4" then
		wnd:SetTooltip(iLib:HelperBuildTooltip(tPetStrings[5], "Assist", "ffffffff"))
	elseif wndName == "Stance5" then
		wnd:SetTooltip(iLib:HelperBuildTooltip(tPetStrings[4], "Stay", "ffffffff"))
	end
end

function Isys_ClassResources:ShowHover( wndHandler, wndControl, x, y )
	self.bMousedOver = true
end

function Isys_ClassResources:HideHover( wndHandler, wndControl, x, y )
	self.bMousedOver = false
end

function Isys_ClassResources:BtnVis()
	local wnd = self.wndMain
	wnd:FindChild("PetStanceToggle"):Show(self.bMousedOver)
	wnd:FindChild("PetBarToggle"):Show(self.bMousedOver)
end

-----------------------------------------------------------------------------------------------
-- Isys_ClassResources Instance
-----------------------------------------------------------------------------------------------
local Isys_ClassResourcesInst = Isys_ClassResources:new()
Isys_ClassResourcesInst:Init()
