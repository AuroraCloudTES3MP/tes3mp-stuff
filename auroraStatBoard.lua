--[[

|===================|
| Aurora Stat Board |
|===================|
requires auroraStatFunc
Changed command to /stats to bring up info
]]

local auroraStatBoard = {}
auroraStatFunc = require("custom.auroraStatFunc")
auroraStatBoard.GUI = 3889165
local auroraCounterConfig = {}

auroraCounterConfig.loadData = function()
    auroraCounterConfig.data = jsonInterface.load("custom/aurora/auroraDatabase.json")
    if auroraCounterConfig.data == nil then
	
	auroraCounterConfig.data = {
		totalPlayerKills = 0,
		totalPlayerLevelUps = 0,
		totalPlayerLogins = 0
	}
    end
end

auroraStatBoard.Main = function(pid, eventStatus)

local daysPassed = WorldInstance.data.time.daysPassed
local hour = WorldInstance.data.time.hour
local day = WorldInstance.data.time.day
local month = WorldInstance.data.time.month
local totalPlayerKills = auroraCounterConfig.data.totalPlayerKills
local totalPlayerLevelUps = auroraCounterConfig.data.totalPlayerLevelUps
local totalPlayerLogins = auroraCounterConfig.data.totalPlayerLogins
local list = ""         		
list = list .. "Close"
		  
	auroraCounterConfig.data = jsonInterface.load("custom/aurora/auroraDatabase.json")		  
	auroraStatBoard.Main = jsonInterface.load("custom/aurora/auroraDatabase.json")
	tes3mp.CustomMessageBox(pid, auroraStatBoard.GUI, color.Purple .. "{Aurora}\n" .. color.DodgerBlue .. "Server Statistics\n" .. color.Yellow .. "Current Hour " .. hour .. "\n" .. "Current Day: " .. day .. "\n" .. "Current Month: " .. month .."\n" .. "Days Passed: " .. daysPassed .. "\n" .. "Total Creatures Killed: "  .. totalPlayerKills .. "\n" .. "Total Player Logins: " .. totalPlayerLogins .. "\n" .. "Total Player Level-Ups: " .. totalPlayerLevelUps .. color.Default, list)                                      
		auroraCounterConfig.loadData()
end

customCommandHooks.registerCommand("stats", auroraStatBoard.Main)
customEventHooks.registerHandler("OnServerPostInit", auroraCounterConfig.loadData)
