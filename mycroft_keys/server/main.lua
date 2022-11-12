local RegisterCommand = RegisterCommand
local NetworkGetEntityFromNetworkId = NetworkGetEntityFromNetworkId

function givekeys(PlayerId, VehicleId)
    local xPlayer = ESX.GetPlayerFromId(PlayerId)
    local Vehicle = NetworkGetEntityFromNetworkId(VehicleId)
    local Keys = Entity(Vehicle).state.keys or {}
        Keys.Owner = xPlayer.identifier
        Keys[xPlayer.identifier] = true
        Entity(Vehicle).state:set("locked", false, true)
        Entity(Vehicle).state:set("keys", Keys, true)
end

exports("givekeys", givekeys)
RegisterNetEvent("mycroft_keys:givekeys", givekeys)

RegisterCommand("addkey", function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)

    local VehicleId = ESX.OneSync.GetClosestVehicle(xPlayer.coords)
    local Vehicle = NetworkGetEntityFromNetworkId(VehicleId)
    local closestPlayer = ESX.OneSync.GetClosestPlayer(GetEntityCoords(GetPlayerPed(source)), 5.0, {[source] = true})
    local xTarget = ESX.GetPlayerFromId(closestPlayer.id)

    local Keys = Entity(Vehicle).state.keys or {}

    if Keys.Owner then 
        if Keys.Owner == xPlayer.identifier then
            Keys[xTarget.identifier] = true
            Entity(Vehicle).state:set("keys", Keys, true)
        end
    end
end)

RegisterCommand("lock", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    local VehicleId = ESX.OneSync.GetClosestVehicle(xPlayer.coords)
    local Vehicle = NetworkGetEntityFromNetworkId(VehicleId)
    local Keys = Entity(Vehicle).state.keys or {}

    if Keys.Owner then 
        if Keys[xPlayer.identifier] then
            Entity(Vehicle).state:set("locked", true, true)
            xPlayer.showNotification("Vehicle Locked!", "success")
            TriggerClientEvent("mycroft:Keys:ToggleLock", source, VehicleId, true)
        end
    end
end)

RegisterCommand("unlock", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    local VehicleId = ESX.OneSync.GetClosestVehicle(xPlayer.coords)
    local Vehicle = NetworkGetEntityFromNetworkId(VehicleId)
    local Keys = Entity(Vehicle).state.keys or {}

    if Keys.Owner then 
        if Keys[xPlayer.identifier] then
            Entity(Vehicle).state:set("locked", false, true)
            xPlayer.showNotification("Vehicle unlocked!", "success")
            TriggerClientEvent("mycroft:Keys:ToggleLock", source, VehicleId, false)
        end
    end
end)


RegisterCommand("keyremove", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    local VehicleId = ESX.OneSync.GetClosestVehicle(xPlayer.coords)
    local Vehicle = NetworkGetEntityFromNetworkId(VehicleId)

    local Keys = Entity(Vehicle).state.keys or {}

    if Keys.Owner then 
        if Keys.Owner == xPlayer.identifier then
            Keys = {}
            Keys[xPlayer.identifier] = true
            Keys.Owner = xPlayer.identifier
            Entity(Vehicle).state:set("keys", Keys, true)
        end
    end
end)

function RemoveKeyFromPlayer(player, vehicle)
    local xPlayer = ESX.GetPlayerFromId(source)
    local Vehicle = NetworkGetEntityFromNetworkId(vehicle)
    local Keys = Entity(Vehicle).state.keys or {}
    Keys[xPlayer.identifier] = nil
    Entity(Vehicle).state:set("keys", Keys, true)
end

ESX.RegisterServerCallback("mycroft_keys:Hotwire", function(source, cb)
    local PlayerPed = GetPlayerPed(source)
    local Vehicle = GetVehiclePedIsIn(PlayerPed, false)

    if Vehicle then
        Entity(Vehicle).state:set("hotwired", true, true)
        cb(true)
    end
end)

ESX.RegisterServerCallback("mycroft_keys:CanLockpick", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local has = xPlayer.getInventoryItem("lockpick").count > 0

    if has then
        xPlayer.removeInventoryItem("lockpick", 1)
    end
    cb(has)
end)

RegisterNetEvent("mycroft_keys:search", function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local PlayerPed = GetPlayerPed(source)
    local Vehicle = GetVehiclePedIsIn(PlayerPed, false)

    if Vehicle and not Entity(Vehicle).state.searched then
        Entity(Vehicle).state:set("searched", true, true)
        local Found = false
        local chance = math.random(100)
        local SearchItems = Config.SearchItems
        for i =1, #SearchItems do 
            if SearchItems[i].chance >= chance then
                Found = true
                if SearchItems[i].item == "money" then 
                    xPlayer.addMoney(SearchItems[i].count)
                    xPlayer.showNotification("Found $".. SearchItems[i].count .. " hidden between the seats!", "success")
                elseif SearchItems[i].item == "keys" then 
                    local Keys = Entity(Vehicle).state.keys or {}
                    if Keys.Owner then 
                        Keys[xPlayer.identifier] = true
                        Entity(Vehicle).state:set("keys", Keys, true)
                    else 
                        Keys.Owner = xPlayer.identifier
                        Keys[xPlayer.identifier] = true
                        Entity(Vehicle).state:set("locked", false, true)
                        TriggerClientEvent("mycroft:Keys:ToggleLock", source, NetworkGetNetworkIdFromEntity(Vehicle), false)
                        Entity(Vehicle).state:set("keys", Keys, true)
                    end
                    xPlayer.showNotification("Found Hidden Keys!", "success")
                else
                    xPlayer.addInventoryItem(SearchItems[i].item, SearchItems[i].count)
                    xPlayer.showNotification("Found ".. SearchItems[i].count .. "x ".. SearchItems[i].item, "success")
                end
                break
            end
        end

        if not Found then 
            xPlayer.showNotification("Found Nothing!", "error")
        end
    else 
        xPlayer.showNotification("Vehicle Already Been Searched!", "error")
    end
end)

ESX.RegisterServerCallback("mycroft_keys:GiveKeys", function(source,cb , VehicleId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local Vehicle = NetworkGetEntityFromNetworkId(VehicleId)
    if DoesEntityExist(Vehicle) then
        local Keys = Entity(Vehicle).state.keys or {}
        if Keys.Owner then 
                Keys[xPlayer.identifier] = true
                Entity(Vehicle).state:set("keys", Keys, true)
        else 
            Keys.Owner = xPlayer.identifier
            Keys[xPlayer.identifier] = true
            Entity(Vehicle).state:set("locked", false, true)
            TriggerClientEvent("mycroft:Keys:ToggleLock", source, VehicleId, false)
            Entity(Vehicle).state:set("keys", Keys, true)
        end
        cb(true)
        return
    end
    cb(false)
end)

ESX.RegisterServerCallback("mycroft_keys:LockVehicle", function(source,cb , VehicleId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local Vehicle = NetworkGetEntityFromNetworkId(VehicleId)
    if DoesEntityExist(Vehicle) then
        local Dist = #(GetEntityCoords(Vehicle) - GetEntityCoords(GetPlayerPed(source)))
        if Dist <= 5.0 then
            local Keys = Entity(Vehicle).state.keys or {}
            if Keys.Owner then
                if Keys[xPlayer.identifier] then
                    Entity(Vehicle).state:set("locked", true, true)
                    TriggerClientEvent("mycroft:Keys:ToggleLock", source, VehicleId, true)
                    cb(true)
                    return
                end
            end
        end
    end
    cb(false)
end)

ESX.RegisterServerCallback("mycroft_keys:ToggleLock", function(source,cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local VehicleId = ESX.OneSync.GetClosestVehicle(xPlayer.coords)
    local Vehicle = NetworkGetEntityFromNetworkId(VehicleId)
    if DoesEntityExist(Vehicle) then
        local Dist = #(GetEntityCoords(Vehicle) - GetEntityCoords(GetPlayerPed(source)))
        if Dist <= 5.0 then
            local Keys = Entity(Vehicle).state.keys or {}
            if Keys.Owner then
                if Keys[xPlayer.identifier] then
                    local state = Entity(Vehicle).state.locked
                    Entity(Vehicle).state:set("locked", not state, true)
                    TriggerClientEvent("mycroft:Keys:ToggleLock", source, VehicleId, not state)
                    cb(true, state and "Unlocked" or "Locked")
                    return
                end
            end
        end
    end
    cb(false)
end)

ESX.RegisterServerCallback("mycroft_keys:CanPlayerLockpick", function(source,cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local VehicleId = ESX.OneSync.GetClosestVehicle(xPlayer.coords)
    local Vehicle = NetworkGetEntityFromNetworkId(VehicleId)
    if DoesEntityExist(Vehicle) then
        local Dist = #(GetEntityCoords(Vehicle) - GetEntityCoords(GetPlayerPed(source)))
        if Dist <= 5.0 then
            local Keys = Entity(Vehicle).state.keys or {}
            if Keys.Owner then
                if not Keys[xPlayer.identifier] then
                    cb(true)
                    return
                end
            end
        end
    end
    cb(false)
end)

ESX.RegisterServerCallback("mycroft_keys:LockpickSuccess", function(source,cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local VehicleId = ESX.OneSync.GetClosestVehicle(xPlayer.coords)
    local Vehicle = NetworkGetEntityFromNetworkId(VehicleId)
    if DoesEntityExist(Vehicle) then
        local Dist = #(GetEntityCoords(Vehicle) - GetEntityCoords(GetPlayerPed(source)))
        if Dist <= 5.0 then
            local Keys = Entity(Vehicle).state.keys or {}
            if Keys.Owner then
                if not Keys[xPlayer.identifier] then
                    if xPlayer.getInventoryItem("slimjim").count > 0 then 
                        xPlayer.removeInventoryItem("slimjim", 1)
                        TriggerClientEvent("mycroft:Keys:ToggleLock", source, VehicleId, false)
                        cb(true)
                        return
                    end
                end
            end
        end
    end
    cb(false)
end)

ESX.RegisterServerCallback("mycroft_keys:UnLockVehicle", function(source,cb , VehicleId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local Vehicle = NetworkGetEntityFromNetworkId(VehicleId)
    if DoesEntityExist(Vehicle) then
        local Dist = #(GetEntityCoords(Vehicle) - GetEntityCoords(GetPlayerPed(source)))
        if Dist <= 5.0 then
            local Keys = Entity(Vehicle).state.keys or {}
            if Keys.Owner then
                if Keys[xPlayer.identifier] then
                    Entity(Vehicle).state:set("locked", false, true)
                    TriggerClientEvent("mycroft:Keys:ToggleLock", source, VehicleId, false)
                    cb(true)
                    return
                end
            end
        end
    end
    cb(false)
end)

ESX.RegisterServerCallback("mycroft_keys:GiveKeysToPlayer", function(source, cb, VehicleId, Player)
    local xPlayer = ESX.GetPlayerFromId(source)
    local VehicleId = ESX.OneSync.GetClosestVehicle(xPlayer.coords)
    local Vehicle = NetworkGetEntityFromNetworkId(VehicleId)
    local closestPlayer = ESX.OneSync.GetClosestPlayer(GetEntityCoords(GetPlayerPed(source)), 5.0, {[source] = true})
    local xTarget = ESX.GetPlayerFromId(closestPlayer.id)
        local Dist1 = #(GetEntityCoords(Vehicle) - GetEntityCoords(GetPlayerPed(source)))
        local Dist2 = #(vector3(xPlayer.coords.x, xPlayer.coords.y,xPlayer.coords.z) - vector3(xTarget.coords.x, xTarget.coords.y, xTarget.coords.z))
        if Dist1 <= 5.0 and Dist2 <= 5.0 then
            local Keys = Entity(Vehicle).state.keys or {}
            if Keys.Owner then 
                if Keys.Owner == xPlayer.identifier then
                    Keys[xTarget.identifier] = true
                    Entity(Vehicle).state:set("keys", Keys, true)
                    cb(true)
                    return
                else
                    cb(false)
                end
            else 
                cb(false)
            end
        else 
            cb(false)
        end
end)