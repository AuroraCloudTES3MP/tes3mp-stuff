--[[
§ Server Statistics Board §

By Aurora Cloud (IM NEW TO THIS)
My first public tes3mp server script.
================
INSTALLATION
server/scripts/custom/

Add to customScripts.lua in server/scripts

require("custom.auroraStatBoard")
require("custom.auroraStatFunc")

This script only serves as a statistics display/counter for servers
DISPLAY
|Current Hour
|Current Day
|Current Month
|Days Passed
|Total kills made by players
|Total level ups by players
|Total times players logged in
TODO: Total player sent messages
TODO: Total player journal updates
TODO: Total player custom items? Method, gather the data from recordstore itself
TODO: 
]]

local auroraStatFunc = {}
local auroraCounterConfig = {}
local methods = {}

auroraCounterConfig.loadData = function()
    auroraCounterConfig.data = jsonInterface.load("custom/aurora/auroraDatabase.json")--Vidi_Aquam
    if auroraCounterConfig.data == nil then
	
	auroraCounterConfig.data = {
		totalPlayerKills = 0,
		totalPlayerLevelUps = 0,
		totalPlayerLogins = 0
	}
 end
end

auroraCounterConfig.saveData = function()
	  jsonInterface.save("custom/aurora/auroraDatabase.json", auroraCounterConfig.data)
  end

methods.addKillData = function(pid)
	if totalPlayerKills == nil then totalPlayerKills = 0 end
		auroraCounterConfig.data.totalPlayerKills = auroraCounterConfig.data.totalPlayerKills + 1
		auroraCounterConfig.saveData()		
	end

methods.addLevelUpData = function(pid)
	if totalPlayerLevelUps == nil then totalPlayerLevelUps = 0 end
		auroraCounterConfig.data.totalPlayerLevelUps = auroraCounterConfig.data.totalPlayerLevelUps + 1
		auroraCounterConfig.saveData()
	end
	
methods.addPlayerLoginData = function(pid)
	if totalPlayerLogins == nil then totalPlayerLogins = 0 end
		auroraCounterConfig.data.totalPlayerLogins = auroraCounterConfig.data.totalPlayerLogins + 1
		auroraCounterConfig.saveData()
	end
			
auroraCounterConfig.saveDataCmd= function(pid, cmd)
--This was originally used for creating the json data for early testing
	if cmd == "savejson" and Players[pid].data.staffRank >= 1 then
	  jsonInterface.save("custom/aurora/auroraDatabase.json", auroraCounterConfig.data)
		else
		 tes3mp.SendMessage(pid, color.Error .. "Only Admins may use this command.\n")
	 end
end
customEventHooks.registerHandler("OnServerPostInit", auroraCounterConfig.loadData)

    customEventHooks.registerHandler("OnActorDeath", function(eventStatus, pid, cellDescription, actors)
		local pAccnt = Players[pid].data.accountName
        local cell = LoadedCells[cellDescription]
		
		--Do I need this stuff???
	tes3mp.ClearKillChanges()

	for uniqueIndex, actor in pairs(actors) do		
		if WorldInstance.data.kills[actor.refId] == nil then
			WorldInstance.data.kills[actor.refId] = 0
		end		
            table.insert(cell.unusableContainerUniqueIndexes, uniqueIndex)
        end

		tes3mp.SendWorldKillCount(pid, true)
			methods.addKillData(pid)--add kill count to database
              for id, _ in pairs(Players) do
                    if cellDescription == tes3mp.GetCell(id) then
			cell:LoadContainers(id, cell.data.objectData, {uniqueIndex})
		   end
		end
	end)
		
methods.auroraLevelUp = function(eventStatus, pid)

    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
       local levelUp = tes3mp.GetLevel(pid)
		if levelUp == 1 then return
		  end
		 methods.addLevelUpData(pid)--add level up count to database
	  end
	end

methods.auroraLogin = function(eventStatus, pid)
	methods.addPlayerLoginData(pid)--add login count to database
end

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

customCommandHooks.registerCommand("savejson", auroraCounterConfig.saveDataCmd)
customEventHooks.registerHandler("OnPlayerLevel", methods.auroraLevelUp)
customEventHooks.registerHandler("OnPlayerFinishLogin", methods.auroraLogin)
customEventHooks.registerHandler("OnServerPostInit", auroraCounterConfig.loadData)
customEventHooks.registerHandler("OnServerPostInit", auroraCounterConfig.saveData)
