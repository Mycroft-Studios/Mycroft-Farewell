local Script = {}
Script.ActiveCallCount = 0
Script.Calls = {}
Script.RespondingCall = {}
Script.IsResponding = false

RegisterNetEvent('szi:interactions:CreateCall')
AddEventHandler('szi:interactions:CreateCall', function(Call)
  SetNewWaypoint(Call.Location.x,Call.Location.y)
  Call.Location = tostring(Call.Location)

  table.insert(Script.Calls, Call)
  Script.ActiveCallCount = Script.ActiveCallCount + 1
end)

Script.RespondOptions = function()
  ESX.UI.Menu.CloseAll()
  local elements = {}

  table.insert(elements, {label = ">> Finish <<", value = "Finish"})
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'ViewCall', {
		title    = "Call Information",
		align    = Config.MenuPlacement,
		elements = elements
	}, function(data, menu)
      if data.current.value == "Finish" then 
        for k,v in pairs(Script.Calls) do
          if v.ID == Script.RespondingCall.ID then
            Script.Calls[k] = nil
          end
        end
        Script.IsResponding = false
        TriggerServerEvent("szi:interactions:server:FinishCall",Script.RespondingCall)
        Script.RespondingCall = {}
        Script.ActiveCallCount = Script.ActiveCallCount - 1
        menu.close()
      end
		end, function(data, menu)
			Script.OpenInteractionMenu()
		end)
end

Script.ViewCall = function(Call)
  ESX.UI.Menu.CloseAll()
  local elements = {}

  if Script.ActiveCallCount > 0 then
    for k,v in pairs(Call) do
      table.insert(elements, {label = k .. " | "..v})
    end
  end

  table.insert(elements, {label = ">> Respond <<", value = "Respond"})
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'ViewCall', {
		title    = "Call Information",
		align    = Config.MenuPlacement,
		elements = elements
	}, function(data, menu)
      if data.current.value == "Respond" then 
        Script.IsResponding = true
        Script.RespondingCall = Call
        menu.close()
      end
		end, function(data, menu)
			Script.CallsMenu()
		end)
end


Script.CallsMenu = function()
  ESX.UI.Menu.CloseAll()

  local elements = {}

  if Script.ActiveCallCount > 0 then
    for k,v in pairs(Script.Calls) do
      table.insert(elements, {label = v.Incident, Call = Script.Calls[k]})
    end
  end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'CallList', {
		title    = "AI Calls",
		align    = Config.MenuPlacement,
		elements = elements
	}, function(data, menu)
			menu.close()
      Script.ViewCall(data.current.Call)
		end, function(data, menu)
			Script.OpenInteractionMenu()
		end)
end

Script.OpenInteractionMenu = function()
  ESX.UI.Menu.CloseAll()
  print(Script.ActiveCallCount)
  local elements = {}
  table.insert(elements, {label = "Active Calls", value = "Respond"})
  if Script.IsResponding then 
    table.insert(elements, {label = "Response Options", value = "Options"})
  end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'Interaction', {
		title    = "AI Interaction",
		align    = Config.MenuPlacement,
		elements = elements
	}, function(data, menu)
			menu.close()
      if data.current.value == "Respond" then
        Script.CallsMenu()
      elseif data.current.value == "Options" then
        Script.RespondOptions()
      end
		end, function(data, menu)
			menu.close()
		end)
end

RegisterCommand("interaction", function(source, args, rawCommand)
  Script.OpenInteractionMenu()
end)