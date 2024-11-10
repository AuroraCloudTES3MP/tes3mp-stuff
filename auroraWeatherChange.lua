--logicHandler.RunConsoleCommandOnPlayer(pid, "changeweather \"" .. currentRegion .. "\" " .. weather)
--will kick non evaluated pid, script is here for fun iguess
local aurora = {}
local WeatherGUI = 9891127


aurora.WeatherTable = {
    { 0, name = "Clear" },
    { 1, name = "Cloudy" },
    { 2, name = "Foggy" },
    { 3, name = "Overcast" },
    { 4, name = "Rain" },
    { 5, name = "Thunder" },
    { 6, name = "Ash" },
    { 7, name = "Blight" },
    { 8, name = "Snowing" },
    { 9, name = "Blizzard" }
}

aurora.DisplayWeatherTable = function(pid)

    local list = ""

    for i = 1, #aurora.WeatherTable do
        if aurora.WeatherTable[i].name ~= nil then
            list = list .. aurora.WeatherTable[i].name
            list = list .. "\n"
        end
    end
	
    list = list .. "Cancel"

		tes3mp.ListBox(pid, WeatherGUI, color.Purple .. "+ Aurora Weather Changer +\n" .. color.Default, list)
	end

function aurora.WeatherOnGUIAction(eventStatus, pid, idGui, data)

	local pick = 0
	  	
	if tonumber(data) ~= nil then pick = tonumber(data) + 1 end	  
	if idGui == WeatherGUI then	   
	  
      if pick <= #aurora.WeatherTable then aurora.FinalizeWeather(pid, pick)
	
    end
   end
  end

function aurora.FinalizeWeather(pid, pick)

	local currentRegion = tes3mp.GetRegion(pid)
	local playerName = string.lower(Players[pid].name)
	local weather = aurora.WeatherTable[pick][1]
	
	logicHandler.RunConsoleCommandOnPlayer(pid, "changeweather \"" .. currentRegion .. "\" " .. weather)
	eventHandler.OnWorldWeather(pid)
	tes3mp.SendMessage(pid, color.Peru .. "You have changed the local weather to " .. color.Default ..
	 aurora.WeatherTable[pick].name .. ".\n", false)
end

customCommandHooks.registerCommand("weather", aurora.DisplayWeatherTable)
customEventHooks.registerHandler("OnGUIAction", aurora.WeatherOnGUIAction) 
