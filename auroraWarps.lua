--[[ add require("custom.auroraWarps") to your customScripts.lua
A necrod script chunk from ccPerks Warp 

Added: feature to display gold cost and pids current gold
Added: custom command to tell current position

TODO: add logging
TODO: add checking if player is in an interior cell so the script can tell them the cell's description
Should we probably unload current cell during transition?
]]

local auroraWarpMain = {}
local config = {}
local auroraGUI = 423459

--=====================--
config.goldCost = 500 --Cost for warps
--=====================--


local auroraWarpWindow = {--Table for storing GUI warp cell and coordinates

    { "11, 16", 94408, 135404, 896, 2.52, name = "Ahemmusa Camp " },
    { "-3, 6", -16523, 54362, 1973, 2.73, name = "Ald'Ruhn " },
    { "-11, 15", -89353, 128479, 110, 1.86, name = "Ald Velothi " },
    { "-3, -3", -20986, -17794, 865, -0.87, name = "Balmora " },
    { "-2, 2", -12238, 20554, 1514, -2.77, name = "Caldera " },
    { "7, 22", 62629, 185197, 131, -2.83, name = "Dagon Fel " },
    { "2, -13", 20769, -103041, 107, -0.87, name = "Ebonheart " },
    { "13, -1", 109926, -3401, 553, -1.14, name = "Erabenimsun Camp " },
    { "-8, 3", -58009, 26377, 52, -1.49, name = "Gnaar Mok " },
    { "-11, 11", -86910, 90044, 1021, 0.44, name = "Gnisis " },
    { "-6, -5", -49093, -40154, 78, 0.94, name = "Hla Oad " },
    { "-9, 17", -69502, 142754, 50, 2.89, name = "Khuul" },
    { "-3, 12", -22622, 101142, 1725, 0.28, name = "Maar Gan " },
    { "12, -8", 103871, -58060, 1423, 2.2, name = "Molag Mar " },
    { "Mournhold, Royal Palace: Reception Area", 2.73, 997, -126.9, -3.08, name = "Mournhold Reception Area " },
    { "9, -10", 75345, -77120, 154, -2.73, name = "Mudcrab Merchant " },
    { "0, -7", 2341, -56259, 1477, 2.13, name = "Pelagiad " },
    { "17, 4", 141415, 39670, 213, 2.47, name = "Sadrith Mora " },
    { "-2, 9", -8680.6, -70136.4, 823, 0.3, name = "Seyda Neen " },
    { "6, -6", 52855, -48216, 897, 2.36, name = "Suran " },
    { "14, 4", 122576, 40955, 59, 1.16, name = "Tel Aruhn " },
    { "15, 1", 124386, 16281, 407, 3.13, name = "Tel Fyr " },
    { "14, -13", 119124, -101518, 51, 3.08, name = "Tel Branora " },
    { "13, 14", 106608, 115787, 53, -0.39, name = "Tel Mora " },
    { "-4, 18", -28334, 150373, 699, 1.34, name = "Urshilaku Camp " },
    { "-3, 16", -21634, -136440, 751, -3.07, name = "Urshilaku Burial " },
    { "3, -10", 36412, -74454, 59, -1.66, name = "Vivec " },
    { "4, -13", 34128, -98998, 1055, -2.097, name = "Vivec, Temple " },
    { "11, 14", 101402, 114893, 158, -2.03, name = "Vos " },
    { "9, 10", 77802, 84674, 791, -2.32, name = "Zainab Camp " }
}


showWarpWindow = function(pid)--display warp table GUI (auroraWarpWindow)
	local goldLoc = inventoryHelper.getItemIndex(Players[pid].data.inventory, "gold_001", -1)
    local list = ""
--reference used from Nkfree and Atkana
    for i = 1, #auroraWarpWindow do--Gather all table data
        if auroraWarpWindow[i].name ~= nil then --begin populating table with entries  
            list = list .. auroraWarpWindow[i].name--listed entries
            list = list .. "\n"--used to separate GUI table entries so they dont end up crammed in 1 single line
        end
    end
	
    list = list .. "Cancel"
	
	  if goldLoc == nil then
		tes3mp.ListBox(pid, auroraGUI, color.Purple .. "+ Aurora Warps +\n" .. color.Green .. "Your Gold: " .. color.Error .. "None." .. "\n" .. color.Gray .. "Gold cost to warp: " .. color.Gold .. config.goldCost .. "\n" .. color.Default, list)
	  else
		tes3mp.ListBox(pid, auroraGUI, color.Purple .. "+ Aurora Warps +\n" .. color.Green .. "Your Gold: " .. color.Gold .. Players[pid].data.inventory[goldLoc].count .. "\n" .. color.Gray .. "Gold cost to warp: " .. color.Gold .. config.goldCost .. "\n" .. color.Default, list)
	end
end


function auroraWarpOnGUIAction(eventStatus, pid, idGui, data)--GUI pick warp handler

	local inventory = Players[pid].data.inventory
	local requiredGold = { refId = "gold_001", config.goldCost, charge = -1, enchantmentCharge = -1, soul = "" }
	local goldIndex = inventoryHelper.getItemIndex(inventory, requiredGold.refId)

	local pick = 0
	  	
	if tonumber(data) ~= nil then pick = tonumber(data) + 1 end
	  
	if idGui == auroraGUI then
	
	  if goldIndex then--does gold exist in player inventory?
	   if inventory[goldIndex].count >= config.goldCost then--does player have >= to config.goldCost
	    else
	     tes3mp.SendMessage(pid, color.Error .. "Insufficient gold.\n")--They are too broke
	  return auroraWarpMain end--shutdown	   
	  
      if pick <= #auroraWarpWindow then auroraFinalizeWarp(pid, pick)--Pick warp destination
	
    end
   end
  end
end


function auroraFinalizeWarp(pid, pick)--Remove gold and finalize warp

local positionTable = { auroraWarpWindow[pick][1], auroraWarpWindow[pick][2], auroraWarpWindow[pick][3], auroraWarpWindow[pick][4], auroraWarpWindow[pick][5] }


local inventory = Players[pid].data.inventory
local requiredGold = {refId = "gold_001", count = config.goldCost, charge = -1, enchantmentCharge = -1, soul = ""}
local goldIndex = inventoryHelper.getItemIndex(inventory, requiredGold.refId)

	  inventoryHelper.removeExactItem(inventory, requiredGold.refId, requiredGold.count)--approve gold removal client side
	  Players[pid]:LoadItemChanges({requiredGold}, enumerations.inventory.REMOVE)--approve gold removal server side
	  auroraTeleportHandler(pid, positionTable)
	
end

function auroraTeleportHandler(pid, positionTable)--stored cell and coordinate data for finalizing warps

    tes3mp.SetCell(pid, positionTable[1])
    tes3mp.SendCell(pid)
    tes3mp.SetPos(pid, positionTable[2], positionTable[3], positionTable[4])
    tes3mp.SetRot(pid, 0, positionTable[5])
    tes3mp.SendPos(pid)
end

local Methods = {}

local msgBox = 1171952

Methods.onPrintPlayerLoc = function(pid)

--[[
Interior cells will return 0,0 as the script dont care to snitch the cell's description. Just ignire this and use the cell's id for Interiors Only.
]]

    local message = "Coordinates: " .. tes3mp.GetExteriorX(pid) .. ", " .. tes3mp.GetExteriorY(pid) .. color.Red .. ", "
    .. tes3mp.GetPosX(pid) .. color.Green .. ", " .. tes3mp.GetPosY(pid) .. color.DodgerBlue .. ", " .. tes3mp.GetPosZ(pid) .. color.Yellow .. ", "
    .. tes3mp.GetRotZ(pid) .. ", " .. "\n"
    tes3mp.SendMessage(pid, message, false)
end

customEventHooks.registerHandler("OnGUIAction", auroraWarpOnGUIAction)
customCommandHooks.registerCommand("warp", showWarpWindow)
customCommandHooks.registerCommand("loc", Methods.onPrintPlayerLoc)
