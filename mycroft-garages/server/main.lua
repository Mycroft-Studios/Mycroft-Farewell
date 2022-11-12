function LoadGarages()
  Garages = {}
  local GaragesList = LoadResourceFile(GetCurrentResourceName(), 'garages.json')
  if GaragesList then
    Garages = json.decode(GaragesList)
    for i=1, #Garages, 1 do
      for Pos in pairs(Garages.coords) do
        Garages.coords[Pos] = vector4(Garages.coords[Pos].x, Garages.coords[Pos].y, Garages.coords[Pos].z, Garages.coords[Pos].w)
      end
    end
    TriggerClientEvent("mycroft-garages:refresh", -1, Garages)
  else 
    print('[ERROR] Cannot load garages! - garages.json is missing!')
  end
end

AddEventHandler("esx:playerLoaded", function(playerId, xPlayer)
  Wait(500)
  TriggerClientEvent("mycroft-garages:refresh", playerId, Garages)
end)

ESX.RegisterServerCallback("mycroft-garages:store", function(source, cb, VehicleProperties, GarageIndex)
  local xPlayer = ESX.GetPlayerFromId(source)
  local Garage = Config.Garages[GarageIndex]
  local Ped = GetPlayerPed(source)
  local Vehicle = GetVehiclePedIsIn(Ped, false)
  if #(GetEntityCoords(Ped) - Garage.coords.store.xyz) <= 2.8 then
    VehicleProperties.Owner = xPlayer.identifier
    Config.Garages[GarageIndex].stored_vehicles[#Config.Garages[GarageIndex].stored_vehicles + 1] = VehicleProperties
    cb(true)
  else
   cb(false)
 end
end)

ESX.RegisterServerCallback("mycroft-garages:GetStoredVehicles", function(source, cb, GarageIndex)
  local Ped = GetPlayerPed(source)
  if #(GetEntityCoords(Ped) - Config.Garages[GarageIndex].coords.retrieve.xyz) <= 2.8 then
      cb(Config.Garages[GarageIndex].stored_vehicles)
  else
   cb(false)
 end
end)

ESX.RegisterServerCallback("mycroft-garages:create", function(source, cb, Label, Retrieve, Store)
  Garages[#Garages + 1] = {
    label = Label,
    coords = {
      retrieve = vector4(Retrieve.pos.xyz, Retrieve.heading),
      store = vector4(Store.pos.xyz, Store.heading),
    },
    stored_vehicles = {}
  }
  cb(true)
  TriggerClientEvent("mycroft-garages:refresh", -1, Garages)
end)

ESX.RegisterServerCallback("mycroft-garages:RetrieveVehicle", function(source, cb, VehicleIndex, GarageIndex)
  local xPlayer = ESX.GetPlayerFromId(source)
  local Garage = Config.Garages[GarageIndex]
  local Ped = GetPlayerPed(source)
  local Vehicle = GetVehiclePedIsIn(Ped, false)
  if #(GetEntityCoords(Ped) - Garage.coords.retrieve.xyz) <= 2.8 then
    local Vehicle = Config.Garages[GarageIndex].stored_vehicles[VehicleIndex]
    if Vehicle.Owner == xPlayer.identifier then
      Config.Garages[GarageIndex].stored_vehicles[VehicleIndex] = nil
      cb(true)
    else
      cb(false)
    end
  else
   cb(false)
 end
end)