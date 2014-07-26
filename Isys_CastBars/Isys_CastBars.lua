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
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function Isys_CastBars:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function Isys_CastBars:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
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

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "Isys_CastBarsForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)


		-- Do additional Addon initialization here
	end
end

-----------------------------------------------------------------------------------------------
-- Isys_CastBars Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here


-----------------------------------------------------------------------------------------------
-- Isys_CastBarsForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function Isys_CastBars:OnOK()
	self.wndMain:Close() -- hide the window
end

-- when the Cancel button is clicked
function Isys_CastBars:OnCancel()
	self.wndMain:Close() -- hide the window
end


-----------------------------------------------------------------------------------------------
-- Isys_CastBars Instance
-----------------------------------------------------------------------------------------------
local Isys_CastBarsInst = Isys_CastBars:new()
Isys_CastBarsInst:Init()
