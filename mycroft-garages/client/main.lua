local CreateThread = CreateThread
local Wait = Wait
local CurrentAction = nil
local TextUIdrawing = {}
local GetEntityCoords = GetEntityCoords
local GetVehiclePedIsIn = GetVehiclePedIsIn
local DoesEntityExist = DoesEntityExist
local DrawMarker = DrawMarker

RegisterNetEvent("mycroft-garages:refresh", function(Garages)
  Config.Garages = Garages
end)

CreateThread(function()
  while true do
    local Sleep = 1500

    if ESX.PlayerLoaded then
      for i=1, #Config.Garages do
        local PlayerCoords = GetEntityCoords(ESX.PlayerData.ped)
        local retrieveDist = #(PlayerCoords - Config.Garages[i].coords.retrieve.xyz)
        local storeDist = #(PlayerCoords - Config.Garages[i].coords.store.xyz)
        local Vehicle = GetVehiclePedIsIn(ESX.PlayerData.ped, false)
        local CurrentGarage = Config.Garages[i]

          if retrieveDist <= Config.DrawDistance then
            Sleep = 0
            DrawMarker(1, Config.Garages[i].coords.retrieve.xyz, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.2, 2.2, 2.2, 50, 200, 50, 150, false, true, 2, false, false, false, false)
            if retrieveDist <= 2.8 then
              if TextUIdrawing ~= 'retrieve' then
                TextUIdrawing = DoesEntityExist(Vehicle) and 'retrievenil' or 'retrieve'
                ESX.TextUI(DoesEntityExist(Vehicle) and "This Action ~r~cannot~s~ be performed In a ~b~Vehicle" or "Press [E] To Retrieve Your Vehicle")
              end
                if IsControlJustPressed(0, 38) and not DoesEntityExist(Vehicle) then
                  ESX.TriggerServerCallback("mycroft-garages:GetStoredVehicles", function(Vehicles)
                    if Vehicles then
                      local Elements = {
                        {unselectable = true, title = CurrentGarage.label.. ": Stored Vehicles"}
                      }

                      for Vehicle=1, #Vehicles do
                        print(ESX.DumpTable(Vehicles[Vehicle]))
                        Elements[#Elements + 1] = {
                          title = GetLabelText(GetDisplayNameFromVehicleModel(Vehicles[Vehicle].model)),
                          description = "Plate: "..Vehicles[Vehicle].plate,
                          plate = Vehicles[Vehicle].plate,
                          index = Vehicle,
                        }
                      end
                      ESX.OpenContext("right", Elements, function(menu, SelectedVehicle)
                        if SelectedVehicle.plate then
                          local VehDetails = Vehicles[SelectedVehicle.index]
                          ESX.TriggerServerCallback("mycroft-garages:RetrieveVehicle", function(Retrieved)
                            if Retrieved then
                              ESX.ShowNotification("Vehicle ~b~Retrieved~s~!", "success")
                              ESX.Game.SpawnVehicle(VehDetails.model, CurrentGarage.coords.retrieve.xyz, CurrentGarage.coords.retrieve.w, function(Vehicle)
                                ESX.Game.SetVehicleProperties(Vehicle, VehDetails)
                                TaskWarpPedIntoVehicle(ESX.PlayerData.ped, Vehicle, -1)
                                ESX.CloseContext()
                              end)
                            end
                          end, SelectedVehicle.index, i)
                        end
                      end)
                    end
                  end, i)
                end
            elseif TextUIdrawing == 'retrieve' then
              TextUIdrawing = nil
              ESX.HideUI()
            end
          end
          if storeDist <= Config.DrawDistance then
            Sleep = 0
            DrawMarker(1, Config.Garages[i].coords.store.xyz, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.2, 2.2, 2.2, 200, 50, 50, 150, false, true, 2, false, false, false, false)
            if storeDist <= 2.8 then
                if TextUIdrawing ~= 'store' then
                  TextUIdrawing = DoesEntityExist(Vehicle) and 'store' or "storenil"
                  ESX.TextUI(DoesEntityExist(Vehicle) and "Press [E] To Store Your Vehicle" or "This Action Requires A ~b~Vehicle")
                end
                if IsControlJustPressed(0, 38) and DoesEntityExist(Vehicle) then
                  print("Store")
                  local VehicleProperties = ESX.Game.GetVehicleProperties(Vehicle)
                  ESX.TriggerServerCallback("mycroft-garages:store", function(Stored)
                    if Stored then
                      ESX.Game.DeleteVehicle(Vehicle)
                      ESX.ShowNotification("Your Vehicle Has Been Stored")
                    else
                      ESX.ShowNotification("You Cannot Store This Vehicle")
                    end
                  end, VehicleProperties, i)
                end
              elseif TextUIdrawing == 'store' or TextUIdrawing == 'storenil' then
                TextUIdrawing = nil
                ESX.HideUI()
             end
          end
      end
    end
    Wait(Sleep)
  end
end)

function CreateGarageMenu()
  local Elements = {
    {unselectable = true, title = "Create A Garage"},
    {title = "Label", input = true, inputType = "text", inputValue = nil, inputPlaceholder = "Set Garaga Label",
    value = "setLabel"},
    {title = "Retrieve Position", value = "retrieve",datas = {}, description = "Set The Position Where Vehicles Are Retrieved From"},
    {title = "Store Position", value = "store",datas = {}, description = "Set The Position Where Vehicles Are Stored"},
    {title = "Create", value = "create", description = "Create A New Garage!"},
  }

  local function OpenContextMenu()
    ESX.OpenContext("right", Elements, function(menu, element)
      if menu.eles[2].inputValue then 
          Elements[2].title = "Label: "..menu.eles[2].inputValue
          Elements[2].inputValue = menu.eles[2].inputValue
      end
      
      if element.value == "retrieve" then
        ESX.CloseContext()
        ESX.TextUI("Press [E] To Set The Retrieve Position")
        while true do
          Wait(0)
          if IsControlJustPressed(0, 38) then
            local PlayerPos = GetEntityCoords(ESX.PlayerData.ped) - vector3(0,0, 1.0)
            Elements[3].datas.pos = PlayerPos
            Elements[3].datas.heading = GetEntityHeading(ESX.PlayerData.ped)
            ESX.HideUI()
            OpenContextMenu()
            break
          end
        end
      end
      if element.value == "store" then
        ESX.CloseContext()
        ESX.TextUI("Press [E] To Set The Store Position")
        while true do
          Wait(0)
          if IsControlJustPressed(0, 38) then
            local PlayerPos = GetEntityCoords(ESX.PlayerData.ped) - vector3(0,0, 1.0)
            Elements[4].datas.pos = PlayerPos
            Elements[4].datas.heading = GetEntityHeading(ESX.PlayerData.ped)
            ESX.HideUI()
            OpenContextMenu()
            break
          end
        end
      end
      if element.value == "create" then
        if Elements[2].inputValue and Elements[3].datas.pos and Elements[4].datas.pos then
          ESX.TriggerServerCallback("mycroft-garages:create", function(Created)
            if Created then
              ESX.ShowNotification("Garage Created!", "success")
              ESX.CloseContext()
            else
              ESX.ShowNotification("Failed To Create Garage", "error")
            end
          end, Elements[2].inputValue, Elements[3].datas, Elements[4].datas)
        else
          ESX.ShowNotification("You Must Fill In All Fields")
        end
      end
    end)
  end
  OpenContextMenu()
end

RegisterCommand("garage:create", CreateGarageMenu)