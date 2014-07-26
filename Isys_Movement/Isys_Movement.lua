-----------------------------------------------------------------------------------------------
-- Client Lua Script for Isys_Movement
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- Isys_Movement Module Definition
-----------------------------------------------------------------------------------------------
local Isys_Movement = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
local nScreenWidth,nScreenHeight = Apollo.GetScreenSize()

local tDefaultSettings = {
	tPos = {
		l = (nScreenWidth  / 2) - 85.5,
		t = (nScreenHeight / 2) + 345,
		r = (nScreenWidth  / 2) + 85.5,
		b = ((nScreenHeight / 2) + 345) + 29,
	},
	bHideWhenFull = false
}
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function Isys_Movement:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    self.tConfig = {}
    self.tConfig.tPos = {}
    self.tConfig.bHideWhenFull = false

    return o
end

function Isys_Movement:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		"Isys_Library",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- Isys_Movement OnLoad
-----------------------------------------------------------------------------------------------
function Isys_Movement:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("Isys_Movement.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- Isys_Movement OnDocLoaded
-----------------------------------------------------------------------------------------------
function Isys_Movement:OnDocLoaded()
	self.wndMovement = Apollo.LoadForm("Isys_Movement.xml", "MovementFrame", nil, self)
    Apollo.RegisterEventHandler("VarChange_FrameCount", "OnUpdate", self)
    Apollo.RegisterEventHandler("PreviewModeToggle", "OnPreviewModeToggle", self)
    Apollo.RegisterEventHandler("SprintToggleVisibility", "ToggleVisibility", self)
    Apollo.RegisterEventHandler("IsysToggle", "FrameToggle", self)
    Apollo.RegisterSlashCommand("reset", "Reset", self)

    self.tPreviewMode = {}
    self.tPreviewMode.bEnabled = false
    self.tPreviewMode.tMovement = {}
    self.tPreviewMode.tDodge = {}
    self.tPreviewMode.nSprint = 75
    self.tPreviewMode.nDodge1 = 25
    self.tPreviewMode.nDodge2 = 50

     -- player checker
    if GameLib.GetPlayerUnit() then
    	self:OnCharacterCreated()
    else
		Apollo.RegisterEventHandler("CharacterCreated",  "OnCharacterCreated", self)
	end
end

-----------------------------------------------------------------------------------------------
-- Isys_Movement Instance
-----------------------------------------------------------------------------------------------
local Isys_MovementInst = Isys_Movement:new()
Isys_MovementInst:Init()

-----------------------------------------------------------------------------------------------
-- Save and Load Functions
-----------------------------------------------------------------------------------------------
function Isys_Movement:OnSave(eType)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then return end
	self:SavePos(self.wndMovement,self.tConfig.tPos)
	self.tConfig.bFirstRun = false
	return self.tConfig
end

function Isys_Movement:OnRestore(eType, tData)
	iLib = Apollo.GetAddon("Isys_Library")
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then return end

	if tData then
		iLib:Merge(self.tConfig,tData)
	else
		iLib:Merge(self.tConfig,tDefaultSettings)
	end
	self.tConfig.bLoaded = true
end

function Isys_Movement:Load()
	Loader(self.wndMovement,self.tConfig.tPos)

	local function Loader(wnd,tbl)
		wnd:SetAnchorOffsets(tbl.l,tbl.t,tbl.r,tbl.b)
	end
end

function Isys_Movement:SavePos(wnd,tbl)
	tbl.l,tbl.t,tbl.r,tbl.b = wnd:GetAnchorOffsets()
end

function Isys_Movement:ApplyPositions()
	if self.tConfig.tPos.l ~= nil then
		self.wndMovement:SetAnchorOffsets(self:GetOffsets(self.tConfig))
	else
		self:Reset()
	end
end

function Isys_Movement:GetOffsets(tbl)
	local l,t,r,b = tbl.tPos.l, tbl.tPos.t, tbl.tPos.r, tbl.tPos.b
	return l,t,r,b
end

function Isys_Movement:Reset()
	iLib = Apollo.GetAddon("Isys_Library")
	self.tConfig = nil
	self.tConfig = {}
	iLib:Merge(self.tConfig,tDefaultSettings)
	self:ApplyPositions()
end
-----------------------------------------------------------------------------------------------
-- Isys_Movement Functions
-----------------------------------------------------------------------------------------------
function Isys_Movement:OnPreviewModeToggle(bool)
 	self.tPreviewMode.bEnabled = bool
end

function Isys_Movement:ToggleVisibility(bool)
	self.tConfig.bHideWhenFull = bool
end


function Isys_Movement:OnCharacterCreated()
	if self.tConfig.tPos.l == nil then
		self:Reset()
		self:ApplyPositions()
	else
		self:ApplyPositions()
	end
end

function Isys_Movement:BarPreview()
	-- locals
	local iLib = Apollo.GetAddon("Isys_Library")
	local pm = self.tPreviewMode

	if pm.nSprint >= 100 then
		pm.nSprint = 0
	else
		pm.nSprint = pm.nSprint + 1
	end
	if pm.nDodge1 >= 100 then
		pm.nDodge1 = 0
	else
		pm.nDodge1 = pm.nDodge1 + 1
	end
	if pm.nDodge2 >= 100 then
		pm.nDodge2 = 0
	else
		pm.nDodge2 = pm.nDodge2 + 1
	end

	-- player 
	iLib:UpdateBar(pm.nDodge1, 100, self.wndMovement, "DodgeBar1")
	iLib:UpdateBar(pm.nDodge2, 100, self.wndMovement, "DodgeBar2")
	iLib:UpdateBar(pm.nSprint, 100, self.wndMovement, "SprintBar")
end

-- Define general functions here
function Isys_Movement:OnUpdate()
	local iLib = Apollo.GetAddon("Isys_Library")
	
	if self.tPreviewMode.bEnabled then
		self:BarPreview()
		-- local l,t,r,b,w,h = iLib:GetSize(self.wndMovement)
		-- iLib:Print(l..","..t..","..r..","..b..","..w..","..h)
	else
		-- locals
		local unit = GameLib.GetPlayerUnit()
		local nRun = unit:GetResource(0)
		local nRunMax = unit:GetMaxResource(0)
		local bAtMaxRun = nRun == nRunMax or unit:IsDead()
		local nEvade = unit:GetResource(7)
		local nEvadeMax = unit:GetMaxResource(7)
		local bAtMaxEvade = nEvade == nEvadeMax or unit:IsDead()

		-- Update sprint bar
		iLib:UpdateBar(nRun,nRunMax,self.wndMovement,"SprintBar")

		-- Update evade bars
		if bAtMaxEvade then
			iLib:UpdateBar(1,1,self.wndMovement,"DodgeBar1")
			iLib:UpdateBar(1,1,self.wndMovement,"DodgeBar2")
		elseif nEvade < 200 and nEvade > 100 then
			iLib:UpdateBar(1,1,self.wndMovement,"DodgeBar1")
			iLib:UpdateBar(nEvade - 100,nEvadeMax - 100,self.wndMovement,"DodgeBar2")
		elseif nEvade <= 100 then
			iLib:UpdateBar(nEvade,100,self.wndMovement,"DodgeBar1")
			iLib:UpdateBar(0,0,self.wndMovement,"DodgeBar2")
		end

		-- If run and evade at max hide frame
		if self.tConfig.bHideWhenFull then
			if bAtMaxEvade and bAtMaxRun then
				self.wndMovement:Show(false)
			else
				self.wndMovement:Show(true)
			end
		else
			self.wndMovement:Show(true)
		end
	end
end