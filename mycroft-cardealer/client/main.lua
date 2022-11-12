local CarDealers = {}

RegisterNetEvent("CarDealers:Refresh", function(Dealers)
  DeleteExisting()
  CarDealers = Dealers
end)

function DeleteExisting()
  for k,v in pairs(CarDealers) do
    for i=1, #v.slots do
      if v.slots[i].spawned then
        DeleteEntity(v.slots[i].vehicle.handle)
        CarDealers[k].slots[i].spawned = false
      end
    end
  end
end

CreateThread(function()
  ESX.TriggerServerCallback("CarDealers:Refresh", function(Dealers)
    CarDealers = Dealers
  end)
end)

AddEventHandler("onResourceStop", function(resource)
  if resource == GetCurrentResourceName() then
    DeleteExisting()
  end
end)

function OpenCarDetailsMenu(Dealer, Slot)
  local Vehicle = CarDealers[Dealer].slots[Slot].vehicle
  local Elements = {{unselectable = true, title = Vehicle.label .. " | ".. Vehicle.Stock .. " Left", description = Vehicle.description},
  {title = "Buy", disabled = Vehicle.Stock == 0, description = "Buy this vehicle for $"..Vehicle.price, icon = "fas fa-shopping-cart", value = "buy"},
  {title = "Close", description = "Close this menu", icon = "fas fa-times", value = "close"}}

  ESX.OpenContext("right", Elements, function(menu, data)
    if data.value == "buy" then
      ESX.TriggerServerCallback("CarDealers:BuyVehicle", function(success)
        if success then
          ESX.ShowNotification("You bought a ~b~"..Vehicle.label.."~s~ for ~g~$"..Vehicle.price)
          ESX.CloseContext()
        else
          ESX.ShowNotification("You don't have enough money to buy this vehicle")
        end
      end, Dealer, Slot)
    elseif data.value == "close" then
      ESX.CloseContext()
    end
  end)
end

CreateThread(function()
  while true do 
    local Sleep = 1500

    if ESX.PlayerLoaded then
      for k,v in pairs(CarDealers) do
        local PlayerCoords = GetEntityCoords(ESX.PlayerData.ped)
        local Distance = #(PlayerCoords - v.Coords.xyz)

        -- if Distance < 10 then
        --   Sleep = 0

        --   DrawMarker(2, v.Coords, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 255, 100, false, true, 2, false, false, false, false)

        --   if Distance < 2.0 then
        --     ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to open the car dealer menu")

        --     if IsControlJustReleased(0, 38) then
        --       OpenCarDealerMenu(k)
        --     end
        --   end
        -- end
        for vehicle=1,#v.slots do
          if v.slots[vehicle].vehicle then
            local distance = #(PlayerCoords - v.slots[vehicle].coords.xyz)
            if distance < 20 then
              if not v.slots[vehicle].spawned then
                v.slots[vehicle].spawned = true
                ESX.Game.SpawnVehicle(joaat(v.slots[vehicle].vehicle.model), v.slots[vehicle].coords.xyz, v.slots[vehicle].coords.w, function(veh)
                  SetEntityInvincible(veh, true)
                  SetVehicleDoorsLocked(veh, 2)
                  SetEntityAsMissionEntity(v.slots[vehicle].vehicle.handle, true, true)
                  SetVehicleDoorsLockedForAllPlayers(veh, true)
                  SetVehicleCanBreak(veh, false)
                  CarDealers[k].slots[vehicle].vehicle.handle = veh
                end, false)
              end
              Sleep = 0
              if distance < 4.0 then
                ESX.ShowFloatingHelpNotification('~INPUT_PICKUP~ - View Details', vector3(v.slots[vehicle].coords.xy, v.slots[vehicle].coords.z + 0.5))
                if IsControlJustReleased(0, 38) then
                  OpenCarDetailsMenu(k, vehicle)
                end
              end
            else
              if v.slots[vehicle].spawned then
                DeleteEntity(v.slots[vehicle].vehicle.handle)
                v.slots[vehicle].spawned = false
              end
            end
          end
        end
      end
    end
    Wait(Sleep)
  end
end)