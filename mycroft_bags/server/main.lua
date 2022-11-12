local ox_inventory = exports.ox_inventory

RegisterNetEvent('mycroft_bags:Createbag', function(id)
    if id then
        ox_inventory:RegisterStash(id, "Bag", 50, 100000)
    end
end)

RegisterNetEvent('mycroft_bags:CreateCase', function(id)
    if id then
        ox_inventory:RegisterStash(id, "Case", 50, 100000)
    end
end)

RegisterCommand("addbag", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem("bag", 1, {ID = "Bag-"..ESX.GetRandomString(10)})
	--exports.ox_inventory:AddItem(source, "bag",1, {ID = "Bag-"..ESX.GetRandomString(10)}, nil)
end)

RegisterCommand("addcase", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem("suitcase", 1, {ID = "Case-"..ESX.GetRandomString(10)})
	--exports.ox_inventory:AddItem(source, "bag",1, {ID = "Bag-"..ESX.GetRandomString(10)}, nil)
end)

CreateThread(function()
    Wait(3000)
    local Players = ESX.GetExtendedPlayers()
    for k,v in pairs(Players) do 
        print(v.source)
        MySQL.query("SELECT `bag` FROM `users` WHERE `identifier` = ?", {v.identifier}, function(result)
            if result and result[1] and result[1].bag then 
                TriggerClientEvent("mycroft_bags:SetBag", v.source, result[1].bag)
            end
        end)
    end
end)

AddEventHandler("esx:playerLoaded", function(playerId, xPlayer)
    Wait(1000)
    MySQL.query("SELECT `bag` FROM `users` WHERE `identifier` = ?", {xPlayer.identifier}, function(result)
      if result then
        if result[1] and result[1].bag then 
            TriggerClientEvent("mycroft_bags:SetBag", playerId, result[1].bag)
        end
      end
    end)
end)

ESX.RegisterServerCallback("usebag", function(source,cb, BagID)
    local data = exports.ox_inventory:Search(source, "count", "bag", {ID = BagID})
    if data >=1 then 
        exports.ox_inventory:RemoveItem(source, "bag", 1, {ID = BagID})
        local xPlayer = ESX.GetPlayerFromId(source)
        MySQL.query("UPDATE `users` SET `bag` = ? WHERE identifier = ?", {BagID, xPlayer.identifier})
    end
    cb(data >= 1)
end)

ESX.RegisterServerCallback("usecase", function(source,cb, BagID)
    local data = exports.ox_inventory:Search(source, "count", "suitcase", {ID = BagID})
    if data >= 1 then 
        exports.ox_inventory:RemoveItem(source, "suitcase", 1, {ID = BagID})
        local xPlayer = ESX.GetPlayerFromId(source)
      --  MySQL.query("UPDATE `users` SET `bag` = ? WHERE identifier = ?", {BagID, xPlayer.identifier})
    end
    cb(data >= 1)
end)

ESX.RegisterServerCallback("pickup", function(source,cb, BagID)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.query("UPDATE `users` SET `bag` = ? WHERE `identifier` = ?", {BagID, xPlayer.identifier})
    cb()
end)

ESX.RegisterServerCallback("dropbag", function(source,cb, BagID, coords)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.query("UPDATE `users` SET `bag` = NULL WHERE `identifier` = ?", {xPlayer.identifier})
    ESX.OneSync.SpawnObject("prop_cs_heist_bag_02", vector3(coords.xy, coords.z - 0.98), GetEntityHeading(GetPlayerPed(source)), function(entity)
        FreezeEntityPosition(entity, true)
        Wait(100)
        TriggerClientEvent("addtargettobag", -1, NetworkGetNetworkIdFromEntity(entity), BagID)
    end)
    cb()
end)

ESX.RegisterServerCallback("dropcase", function(source,cb, BagID, coords)
    local xPlayer = ESX.GetPlayerFromId(source)
    --MySQL.query("UPDATE `users` SET `bag` = NULL WHERE `identifier` = ?", {xPlayer.identifier})
    ESX.OneSync.SpawnObject("prop_security_case_01", vector3(coords.xy, coords.z - 0.99), GetEntityHeading(GetPlayerPed(source)), function(entity)
        FreezeEntityPosition(entity, true)
        Wait(100)
        TriggerClientEvent("addtargettocase", -1, NetworkGetNetworkIdFromEntity(entity), BagID)
    end)
    cb()
end)


ESX.RegisterServerCallback("packup", function(source,cb, BagID)
    ox_inventory:RegisterStash(BagID, "Bag", 50, 100000)
    local data = exports.ox_inventory:CanCarryAmount(BagID, "idcard")
    if data == 100000 then 
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.addInventoryItem("bag", 1, {ID = BagID})
        cb(true)
    else 
        cb(false)
    end
end)

ESX.RegisterServerCallback("packupcase", function(source,cb, BagID)
    ox_inventory:RegisterStash(BagID, "Case", 50, 100000)
    local data = exports.ox_inventory:CanCarryAmount(BagID, "idcard")
    if data == 100000 then 
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.addInventoryItem("suitcase", 1, {ID = BagID})
        cb(true)
    else 
        cb(false)
    end
end)

