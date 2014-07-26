-----------------------------------------------------------------------------------------------
-- Client Lua Script for Isys_TargetFrame
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- Isys_TargetFrame Module Definition
-----------------------------------------------------------------------------------------------
local Isys_TargetFrame = {}

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
local nScreenWidth,nScreenHeight = Apollo.GetScreenSize()

local tDefaultSettings = {
	tPlayer = {
		tPos = {
			l = ((nScreenWidth / 2) - 144) - 225,
			t = (nScreenHeight / 2) + 345,
			r = (nScreenWidth / 2) - 144,
			b = ((nScreenHeight / 2) + 345 ) + 52
		},
		bShowText = true
	},
	tTarget = {
		tPos = {
			l = (nScreenWidth / 2) + 144,
			t = (nScreenHeight / 2) + 345,
			r = ((nScreenWidth / 2) + 144) + 225,
			b = ((nScreenHeight / 2) + 345 ) + 52,
		},
		bShowText = true
	},
	tFocus = {
		tPos = {
			l = ((nScreenWidth / 2) - 371) - 128,
			t = (nScreenHeight / 2) + 370,
			r = (nScreenWidth / 2) - 371,
			b = ((nScreenHeight / 2) + 370) + 27,
		},
		bShowText = true
	},
	bFrameLock = false,
	bFirstRun = true,
}

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function Isys_TargetFrame:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here
    self.tConfig = {}
    self.tConfig.tPlayer = {}
    self.tConfig.tPlayer.bShowText = true
    self.tConfig.tPlayer.tPos = {}
    self.tConfig.tTarget = {}
    self.tConfig.tTarget.bShowText = true
    self.tConfig.tTarget.tPos = {}
    self.tConfig.tFocus = {}
    self.tConfig.tFocus.bShowText = true
    self.tConfig.tFocus.tPos = {}
    return o
end

function Isys_TargetFrame:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		"Isys_Library",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- Isys_TargetFrame OnLoad
-----------------------------------------------------------------------------------------------
function Isys_TargetFrame:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("Isys_TargetFrame.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- Isys_TargetFrame OnDocLoaded
-----------------------------------------------------------------------------------------------
function Isys_TargetFrame:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
		-- load frames
	   	self.wndPlayer = Apollo.LoadForm("Isys_TargetFrame.xml", "UnitFrame", nil, self)
	    self.wndTarget = Apollo.LoadForm("Isys_TargetFrame.xml", "UnitFrame", nil, self)
	    self.wndSimple = Apollo.LoadForm("Isys_TargetFrame.xml", "SimpleFrame", nil, self)
	    self.wndFocus = Apollo.LoadForm("Isys_TargetFrame.xml", "FocusFrame", nil, self)
	    
	    -- 
	    self.wndPlayer:Show(true)
	    --self.wndPlayer:FindChild("MouseCatch"):SetStyle("IgnoreMouse", false)
	    self.wndTarget:Show(false)
	    --self.wndTarget:FindChild("MouseCatch"):SetStyle("IgnoreMouse", false)

	    --auto events
	    Apollo.RegisterEventHandler("PlayerLevelChange", 	"OnPlayerUpdate", 		self)
		Apollo.RegisterEventHandler("TargetUnitChanged", 	"OnTargetUnitChanged", 	self)
	    Apollo.RegisterEventHandler("VarChange_FrameCount", "OnUpdate", 			self)
	    
	    -- manual events
	    Apollo.RegisterSlashCommand("ist", "Debug", self)
	    Apollo.RegisterSlashCommand("save", "Save", self)
	    Apollo.RegisterSlashCommand("load", "LoadIt", self)
	    Apollo.RegisterSlashCommand("reset", "Reset", self)

	    -- setting change events
	    Apollo.RegisterEventHandler("UnitFrameToggleText", "OnUnitFrameToggleText", self)
	    Apollo.RegisterEventHandler("FrameLockToggle", "OnFrameLockToggle", self)
	    Apollo.RegisterEventHandler("PreviewModeToggle", "OnPreviewModeToggle", self)
	    
	    -- vars
	    self.tPlayer = {}
	    self.bSimpleTarget = false
	    self.bTargetExist = false

	    -- editmode
	    self.tPreviewMode = {}
	    self.tPreviewMode.bEnabled = false
	    self.tPreviewMode.tHealth = {}
	    self.tPreviewMode.tHealth.Health = 75
	    self.tPreviewMode.tHealth.Shield = 25

	    -- player checker
	    if GameLib.GetPlayerUnit() then
	    	self:OnCharacterCreated()
	    else
			Apollo.RegisterEventHandler("CharacterCreated",  "OnCharacterCreated", self)
		end
	end
end

-----------------------------------------------------------------------------------------------
-- Isys_TargetFrame Instance
-----------------------------------------------------------------------------------------------
local Isys_TargetFrameInst = Isys_TargetFrame:new()
Isys_TargetFrameInst:Init()

-----------------------------------------------------------------------------------------------
-- Debug Functions
-----------------------------------------------------------------------------------------------
function Isys_TargetFrame:Debug()
	local iLib = Apollo.GetAddon("Isys_Library")
	-- self:SavePos(self.wndPlayer,self.tConfig.tPlayer.tPos)
	-- self:SavePos(self.wndTarget,self.tConfig.tTarget.tPos)
	-- self:SavePos(self.wndTarget,self.tConfig.tFocus.tPos)
	-- iLib:Print(iLib:table_tostring(self.tConfig.tPlayer.tPos))
	-- iLib:Print(iLib:table_tostring(self.tConfig.tTarget.tPos))
	-- iLib:Print(iLib:table_tostring(self.tConfig.tFocus.tPos))
	-- iLib:Print(tostring(self.tConfig.tPlayer.bShowText))
	self.wndPlayer:SetStyle("Moveable", true)
end



-----------------------------------------------------------------------------------------------
-- Isys Save and Load Functions
-----------------------------------------------------------------------------------------------
function Isys_TargetFrame:OnSave(eType)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then return end
	self:SavePos(self.wndPlayer,self.tConfig.tPlayer.tPos)
	self:SavePos(self.wndTarget,self.tConfig.tTarget.tPos)
	self:SavePos(self.wndFocus,self.tConfig.tFocus.tPos)
	return self.tConfig
end

function Isys_TargetFrame:OnRestore(eType, tData)
	local iLib = Apollo.GetAddon("Isys_Library")
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then return end

	if tData then
		iLib:Merge(self.tConfig,tData)
	else
		iLib:Merge(self.tConfig,tDefaultSettings)
	end
	self.tConfig.bLoaded = true
end

function Isys_TargetFrame:Load()
	Loader(self.wndPlayer,self.tConfig.tPlayer.tPos)
	Loader(self.wndTarget,self.tConfig.tTarget.tPos)
	Loader(self.wndFocus,self.tConfig.tFocus.tPos)

	local function Loader(wnd,tbl)
		wnd:SetAnchorOffsets(tbl.l,tbl.t,tbl.r,tbl.b)
	end
end

function Isys_TargetFrame:SavePos(wnd,tbl)
	tbl.l,tbl.t,tbl.r,tbl.b = wnd:GetAnchorOffsets()
end

-----------------------------------------------------------------------------------------------
-- Button and Tooltip Functions
-----------------------------------------------------------------------------------------------
function Isys_TargetFrame:OnMouseButtonUp( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY )
	local unit = wndHandler:GetData()
	if eMouseButton == 0 then
		GameLib.SetTargetUnit(unit)
	end
	if eMouseButton == 1 then
		Event_FireGenericEvent("GenericEvent_NewContextMenuPlayerDetailed", wndHandler, unit:GetName(), unit)
	end
end

function Isys_TargetFrame:Test2( wndHandler, wndControl, x, y )
	Print("test2")
	if wndControl:GetName() == "MouseCatch" then
		local id = wndHandler:GetData().id
		local frame,bool = self:ReturnFrame(id)
		if not bool then
			frame:FindChild("Text"):Show(true)
		end
	end
end

function Isys_TargetFrame:OnMouseEnter( wndHandler, wndControl, x, y )
	Event_FireGenericEvent("SendVarToRover", "wndControl", wndControl:GetName())
	Event_FireGenericEvent("SendVarToRover", "wndHandler", wndHandler)
	if wndControl:GetName() == "MouseCatch" then
		local id = wndHandler:GetData().id
		local frame,bool = self:ReturnFrame(id)
		if not bool then
			frame:FindChild("Text"):Show(true)
		end
	end
end

function Isys_TargetFrame:OnMouseExit( wndHandler, wndControl, x, y )
	if wndControl:GetName() == "MouseCatch" then
		local id = wndHandler:GetData().id
		local frame,bool = self:ReturnFrame(id)
		if not bool then
			frame:FindChild("Text"):Show(false)
		end
	end
end

function Isys_TargetFrame:GenerateUnitTooltip(wnd,unit)
	local iLib = Apollo.GetAddon("Isys_Library")
	local strName = unit:GetName()
	local strGuild = unit:GetGuildName()
	if unit:GetGuildName() == nil then
		strGuild = ""
	end
	local nHealth = unit:GetHealth()
	local nHealthMax = unit:GetMaxHealth()
	local nShield = unit:GetShieldCapacity()
	local nShieldMax = unit:GetShieldCapacityMax()
	local strTooltip = strGuild.."\n".."Health: "..nHealth.."/"..nHealthMax.."\n".."Shield: "..nShield.."/"..nShieldMax
	wnd:SetTooltip(self:HelperBuildTooltip(strTooltip,strName,"ffffffff"))
end

function Isys_TargetFrame:HelperBuildTooltip(strBody, strTitle, crTitleColor)
	if strBody == nil then return end
	local strTooltip = string.format("<T Font=\"CRB_InterfaceMedium\" TextColor=\"%s\">%s</T>", "ffffffff", strBody)
	if strTitle ~= nil then -- if a title has been passed, add it (optional)
		strTooltip = string.format("<P>%s</P>", strTooltip)
		local strTitle = string.format("<P Font=\"CRB_InterfaceMedium_B\" TextColor=\"%s\">%s</P>", crTitleColor or kstrTooltipTitleColor, strTitle)
		strTooltip = strTitle .. strTooltip
	end
	return strTooltip
end

-----------------------------------------------------------------------------------------------
-- Settings Functions
-----------------------------------------------------------------------------------------------
function Isys_TargetFrame:OnPreviewModeToggle(bool)
	-- locals
	local iLib = Apollo.GetAddon("Isys_Library")
	self.tPreviewMode.bEnabled = bool
end

function Isys_TargetFrame:BarPreview()
	-- locals
	local iLib = Apollo.GetAddon("Isys_Library")
	local pm = self.tPreviewMode.tHealth

	-- health/shield reset
	if pm.Health >= 100 then
		pm.Health = 0
	else
		pm.Health = pm.Health + 1
	end
	if pm.Shield >= 100 then
		pm.Shield = 0
	else
		pm.Shield = pm.Shield + 1
	end

	-- player 
	iLib:UpdateBar(pm.Health, 100, self.wndPlayer, "HealthBar")
	iLib:UpdateBar(pm.Shield, 100, self.wndPlayer, "ShieldBar")

	-- target
	iLib:UpdateBar(pm.Health, 100, self.wndTarget, "HealthBar")
	iLib:UpdateBar(pm.Shield, 100, self.wndTarget, "ShieldBar")
end

function Isys_TargetFrame:ReturnTable(x)
	if x == "Player" then
		return self.tConfig.tPlayer
	elseif x == "Target" then
		return self.tConfig.tTarget
	end
end

function Isys_TargetFrame:ReturnFrame(id)
	if id == 1 then
		local bool = self.tConfig.tPlayer.bShowText
		return self.wndPlayer,bool
	elseif id == 2 then
		local bool = self.tConfig.tTarget.bShowText
		return self.wndTarget,bool
	end
end

function Isys_TargetFrame:OnUnitFrameToggleText(unit,bool)
	local tbl = self:ReturnTable(unit)
	tbl.bShowText = bool
	self:OnPlayerUpdate()
	self:OnTargetUnitChanged()
end

function Isys_TargetFrame:OnFrameLockToggle(bool)
	Print("EventFired:"..tostring(bool))
	self.wndPlayer:SetStyle("Moveable", bool)
	self.wndTarget:SetStyle("Moveable", bool)
	self.wndFocus:SetStyle("Moveable", bool)
end
-----------------------------------------------------------------------------------------------
-- Char Functions
-----------------------------------------------------------------------------------------------
function Isys_TargetFrame:OnCharacterCreated()
	self.tPlayer.Unit = GameLib.GetPlayerUnit()
	self.tPlayer.bLoaded = true

	if GameLib.GetTargetUnit() then
		self:OnTargetUnitChanged()
	end

	if self.tConfig.tPlayer.tPos.l == nil then
		self:Reset()
		self:ApplyPositions()
	else
		self:ApplyPositions()
	end
	
	self:OnPlayerUpdate()
end

function Isys_TargetFrame:OnPlayerUpdate()
	self.tPlayer.strName = GameLib.GetPlayerUnit():GetName()
	self.tPlayer.nLevel = GameLib.GetPlayerUnit():GetLevel()
	self.wndPlayer:FindChild("InfoText"):SetText(string.format("%s | %s", self.tPlayer.nLevel, self.tPlayer.strName))
	if self.tConfig.tPlayer.bShowText then
		self.wndPlayer:FindChild("Text"):Show(true)
	else
		self.wndPlayer:FindChild("Text"):Show(false)
	end
end

-----------------------------------------------------------------------------------------------
-- Main Unitframe Functions
-----------------------------------------------------------------------------------------------
function Isys_TargetFrame:OnUpdate()
	--locals
	local iLib = Apollo.GetAddon("Isys_Library")

	if self.tPreviewMode.bEnabled then
		-- bar preview
		self:BarPreview()
	else
		-- player
		if self.tPlayer.bLoaded and GameLib.GetPlayerUnit():GetMaxHealth() ~= nil then
			self:BuildFrame(self.wndPlayer, 1)
		end
		-- target
		if self.bTargetExist then
			if not self.bSimpleTarget and GameLib.GetTargetUnit():GetMaxHealth() ~= nil then
				self:BuildFrame(self.wndTarget, 2)
			end
		end
		-- focus
		if GameLib.GetPlayerUnit():GetAlternateTarget() ~= nil then
		self.wndFocus:Show(true)
		self:BuildFrame(self.wndFocus, 3)
		local uNewFocus = GameLib.GetPlayerUnit():GetAlternateTarget()
		if uNewFocus ~= self.FocusUnit then
			self.FocusUnit = GameLib.GetPlayerUnit():GetAlternateTarget()
			self.wndFocus:FindChild("Icon"):SetSprite(iLib.classIcons[self.FocusUnit:GetAlternateTarget():GetClassId()])
			self.wndFocus:FindChild("InfoText"):SetText(string.format("%s | %s", uNewFocus:GetLevel(), uNewFocus:GetName()))
		end
		else
			self.wndFocus:Show(false)
		end
	end
end

function Isys_TargetFrame:BuildFrame(wnd,unitType)
	-- locals
	local iLib = Apollo.GetAddon("Isys_Library")	
	local unit = iLib:GetUnit(unitType)
	local nMarkerId = unit and unit:GetTargetMarker() or 0
	local tHealth, tShield, tAbsorb, tIntArmor = {}, {}, {}, {}
	local wndRaidMarker = wnd:FindChild("RaidMarker")
	local wndIntArmor = wnd:FindChild("IntArmor")

	-- set data and generate tooltip
	wnd:SetData(unit)
	self:GenerateUnitTooltip(wnd, unit)

	-- vars
	tHealth.val = unit:GetHealth()
	tHealth.max = unit:GetMaxHealth()
	tHealth.per = math.floor((tHealth.val / tHealth.max)*100)
	tShield.val = unit:GetShieldCapacity()
	tShield.max = unit:GetShieldCapacityMax()
	tShield.per = math.floor((tShield.val / tShield.max)*100)
	tAbsorb.val = unit:GetAbsorptionValue()
	tAbsorb.max = unit:GetAbsorptionMax()
	tAbsorb.per = math.floor((tAbsorb.val / tAbsorb.max)*100)
	tIntArmor.val = unit:GetInterruptArmorValue()
	tIntArmor.max = unit:GetInterruptArmorMax()

	-- bars
	if unitType ~= 3 then
		iLib:UpdateBar(tShield.val, tShield.max, wnd, "ShieldBar")
		iLib:UpdateBar(tAbsorb.val, tAbsorb.max, wnd, "AbsorbBar")
		iLib:UpdateBar(tHealth.val, tHealth.max, wnd, "HealthBar")
		wnd:FindChild("MouseCatch"):SetData({id = unitType, wnd = wnd,})
	else
		iLib:UpdateBar(tHealth.val, tHealth.max, wnd, "HealthBar")
	end

	-- raid markers
	if unit and nMarkerId ~= 0 then
		wndRaidMarker:SetSprite(iLib.raidMarkerToSprite[nMarkerId])
	else
		wndRaidMarker:SetSprite("")
	end

	-- int armor if not focus
	if unitType ~= 3 then
		if tIntArmor.val == 0 or nil then
			wndIntArmor:SetSprite("")
			wndIntArmor:FindChild("Value"):SetText("")
		elseif tIntArmor.max == -1 then
			wndIntArmor:SetSprite("HUD_TargetFrame:spr_TargetFrame_InterruptArmor_Infinite")
			wndIntArmor:FindChild("Value"):SetText("")
		elseif tIntArmor.val > 0 then
			wndIntArmor:SetSprite("HUD_TargetFrame:spr_TargetFrame_InterruptArmor_Value")
			wndIntArmor:FindChild("Value"):SetText(tIntArmor.val)
		end
	end	
end

function Isys_TargetFrame:OnTargetUnitChanged()
	-- locals
	local iLib = Apollo.GetAddon("Isys_Library")
	local wndSimple = self.wndSimple
	local wndTarget = self.wndTarget

	-- check if target exist after change
	if GameLib.GetTargetUnit() then
		-- if the new target doesn't match the old target then update
		local uNewTarget = GameLib.GetTargetUnit()
		if self.TargetUnit ~= uNewTarget then self.TargetUnit = uNewTarget end

		-- target exist set bool to true and setup shortcut
		self.bTargetExist = true
		local uTarget = self.TargetUnit

		-- unit type visibility
		if uTarget:GetType() == "Simple" then
			wndTarget:Show(false)
			wndSimple:Show(true)
			wndSimple:FindChild("InfoText"):SetText(uTarget:GetName())
		else
			wndSimple:Show(false)
			wndTarget:Show(true)
			
			if uTarget:GetLevel() == nil then
				wndTarget:FindChild("InfoText"):SetText(uTarget:GetName())
			else
				wndTarget:FindChild("InfoText"):SetText(string.format("%s | %s", uTarget:GetLevel(), uTarget:GetName()))
			end

			-- rank or class icon
			local eRank = uTarget:GetRank()
			local strClassIcon = ""
			local strRankIcon = ""
			if uTarget:GetType() == "Player" then
				strClassIcon = iLib.classIcons[uTarget:GetClassId()]
			else
				for k,_ in pairs(iLib.rankIcons) do
					if k == eRank then
						strRankIcon = v
					end
				end
			end

			if strClassIcon ~= "" then
				wndTarget:FindChild("ClassIcon"):SetSprite(strClassIcon)
			else
				wndTarget:FindChild("ClassIcon"):SetSprite(strRankIcon)
			end
			if self.tConfig.tTarget.bShowText then
				self.wndTarget:FindChild("Text"):Show(true)
			else
				self.wndTarget:FindChild("Text"):Show(false)
			end
		end
	else
		-- hide the frame
		self.bTargetExist = false
		wndTarget:Show(false)
		wndSimple:Show(false)
	end
end

function Isys_TargetFrame:ApplyPositions()
	self.wndPlayer:SetAnchorOffsets(self:GetOffsets(self.tConfig.tPlayer))
	self.wndTarget:SetAnchorOffsets(self:GetOffsets(self.tConfig.tTarget))
	self.wndFocus:SetAnchorOffsets(self:GetOffsets(self.tConfig.tFocus))
end
-----------------------------------------------------------------------------------------------
-- Misc Functions
-----------------------------------------------------------------------------------------------

function Isys_TargetFrame:GetOffsets(tbl)
	local l,t,r,b = tbl.tPos.l, tbl.tPos.t, tbl.tPos.r, tbl.tPos.b
	return l,t,r,b
end

function Isys_TargetFrameInst:Reset()
	local iLib = Apollo.GetAddon("Isys_Library")
	self.tConfig = nil
	self.tConfig = {}
	iLib:Merge(self.tConfig,tDefaultSettings)
end