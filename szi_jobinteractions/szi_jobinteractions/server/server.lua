local Script = {}
Script.Calls = {}
Script.ID = 0

Script.CreateCall = function(player)
  local Call = Config.CallTypes[math.random(#(Config.CallTypes))]
  Call.Location = Call.Locations[math.random(#Call.Locations)]
  Script.ID = Script.ID + 1
  Call.ID = Script.ID
  table.insert(Script.Calls, Call)
  TriggerClientEvent("szi:interactions:CreateCall", player ,Call)
end

RegisterCommand("CreateCall", function(source, args, rawCommand)
  Script.CreateCall(source)
end)

RegisterNetEvent('szi:interactions:server:FinishCall')
AddEventHandler('szi:interactions:server:FinishCall', function(Call)
  for k,v in pairs(Script.Calls) do
    if v.ID == Call.ID then
      Script.Calls[k] = nil
    end
  end
end)

Citizen.CreateThread(function() 
  while true do
    Wait(Config.WaitTimer)
   -- Fezz add thing here
    Script.CreateCall()
  end
end)