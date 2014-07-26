-----------------------------------------------------------------------------------------------
-- Client Lua Script for Isys_Library
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- Isys_Library Module Definition
-----------------------------------------------------------------------------------------------
local Isys_Library = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
Isys_Library.factionNames = {
	[166] = "Dominion",
	[170] = "Dominion",
	[171] = "Exile",
	[189] = "redenemy",
	[167] = "Exile",
}

Isys_Library.pathNames = {
	[0] = "Soldier",
	[1] = "Settler",
	[2] = "Scientist",
	[3] = "Explorer"
}

Isys_Library.unitTypes = {
	[1] = "Player",
	[2] = "Target",
	[3] = "Focus",
	[4] = "ToT",
}

Isys_Library.wndIds = {
	[1] = "Player",
	[2] = "Target",
	[3] = "Focus",
	[4] = "ToT",
	[5] = "PlayerCastBar",
	[6] = "TargetCastBar",
	[7] = "Resource",
}

Isys_Library.raidMarkerToSprite = {
	"Icon_Windows_UI_CRB_Marker_Bomb",
	"Icon_Windows_UI_CRB_Marker_Ghost",
	"Icon_Windows_UI_CRB_Marker_Mask",
	"Icon_Windows_UI_CRB_Marker_Octopus",
	"Icon_Windows_UI_CRB_Marker_Pig",
	"Icon_Windows_UI_CRB_Marker_Chicken",
	"Icon_Windows_UI_CRB_Marker_Toaster",
	"Icon_Windows_UI_CRB_Marker_UFO",
}

Isys_Library.classIcons = {
	[GameLib.CodeEnumClass.Warrior] 	 = "AdrenahlineSprites:IconWarrior",
	[GameLib.CodeEnumClass.Engineer] 	 = "AdrenahlineSprites:IconEngineer",
	[GameLib.CodeEnumClass.Esper] 		 = "AdrenahlineSprites:IconEsper",
	[GameLib.CodeEnumClass.Medic] 		 = "AdrenahlineSprites:IconMedic",
	[GameLib.CodeEnumClass.Stalker] 	 = "AdrenahlineSprites:IconStalker",
	[GameLib.CodeEnumClass.Spellslinger] = "AdrenahlineSprites:IconSpellslinger",
}

Isys_Library.rankIcons = {}
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function Isys_Library:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function Isys_Library:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- Isys_Library OnLoad
-----------------------------------------------------------------------------------------------
function Isys_Library:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("Isys_Library.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- Isys_Library OnDocLoaded
-----------------------------------------------------------------------------------------------
function Isys_Library:OnDocLoaded()
    Apollo.RegisterSlashCommand("iui", "OnIsysUI", self)
    Apollo.RegisterSlashCommand("rl", "Reload", self)
end

local Isys_LibraryInst = Isys_Library:new()
Isys_LibraryInst:Init()

function Isys_Library:OnIsysUI()
	Event_FireGenericEvent("IsysToggle")
end

function Isys_Library:Reload()
	RequestReloadUI()
end

function Isys_Library:Print(msg,chan)
	local channel = chan or ChatSystemLib.ChatChannel_Command
	if msg ~= nil then
		ChatSystemLib.PostOnChannel(channel, msg)
	else
		ChatSystemLib.PostOnChannel(channel, "Error:Print() - Arg is nil")
	end
end

function Isys_Library:tablelength(tbl)
  local count = 0
  for _ in pairs(tbl) do count = count + 1 end
  return count
end

function Isys_Library:table_val_to_str ( v )
	if "string" == type( v ) then
		v = string.gsub( v, "\n", "\\n" )
		if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      		return "'" .. v .. "'"
    	end
    	return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  	else
    	return "table" == type( v ) and self:table_tostring( v ) or
      	tostring( v )
  	end
end

function Isys_Library:table_key_to_str ( k )
	if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
		return k
	else
		return "[" .. self:table_val_to_str( k ) .. "]"
	end
end

function Isys_Library:table_tostring( tbl )
	local result, done = {}, {}
	for k, v in ipairs( tbl ) do
		table.insert( result, self:table_val_to_str( v ) )
		done[ k ] = true
	end
	for k, v in pairs( tbl ) do
		if not done[ k ] then
			table.insert( result, self:table_key_to_str( k ) .. "=" .. self:table_val_to_str( v ) )
		end
	end
	return "{" .. table.concat( result, "," ) .. "}"
end

function Isys_Library:ConvertCurrency(nVal)
	local nCurrencyLen = string.len(tostring(nVal))
	local strCopper 	 = string.sub(tostring(nVal),-2)
	local strSilver 	 = string.sub(tostring(nVal),-4,-3)
	local strGold 		 = string.sub(tostring(nVal),-6,-5)
	local strPlatinum  = string.reverse(string.sub(string.reverse(tostring(nVal)), 7)) -- I put my thing down, flip it and reverse it
	return strCopper, strSilver, strGold, strPlatinum
end

function Isys_Library:UpdateBar(...)
  	local progress, max, wnd, child, parent = ...

  	if parent then
		wnd:FindChild(parent):FindChild(child):SetMax(max)
		wnd:FindChild(parent):FindChild(child):SetProgress(progress)
  	else
	    wnd:FindChild(child):SetMax(max)
	    wnd:FindChild(child):SetProgress(progress)
  	end
end

function Isys_Library:SetSprite(wnd, sprite)
	wnd:SetSprite("Isys:" .. sprite)
end

function Isys_Library:GetUnit(unitId)
	if type(unitId) == "number" then
		if unitId == 1 then
			return GameLib.GetPlayerUnit()
		elseif unitId == 2 then 
			return GameLib.GetTargetUnit()
		elseif unitId == 3 then
			return GameLib.GetPlayerUnit():GetAlternateTarget()
		end
	else
		self:Print("Error:GetUnit() - arg is not a number, arg is type: "..type(unitId))
	end
end

function Isys_Library:GetSize(wnd)
	local l,t,r,b = wnd:GetAnchorOffsets()
	local width = r - l
	local height = b - t
	return l,r,t,b,width,height
end

function Isys_Library:Merge(t1, t2)
    for k, v in pairs(t2) do
        if (type(v) == "table") and (type(t1[k] or false) == "table") then
            self:Merge(t1[k], t2[k])
        else
            t1[k] = v
        end
    end
    return t1
end