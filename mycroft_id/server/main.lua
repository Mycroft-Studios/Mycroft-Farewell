RegisterNetEvent("mycroft_id:useWeaponID", function(player, Mugshot)
    local xTarget = ESX.GetPlayerFromIdentifier(player)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xTarget then
        TriggerEvent('jsfour-idcard:open', xTarget.source, source, "weapon", Mugshot)
    else
        xPlayer.showNotification("ERROR: Player Not Online!")
    end
end)

RegisterNetEvent("mycroft_id:useDriverID", function(player, Mugshot)
    local xTarget = ESX.GetPlayerFromIdentifier(player)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xTarget then
        TriggerEvent('jsfour-idcard:open', xTarget.source, source, "driver", Mugshot)
    else
        xPlayer.showNotification("ERROR: Player Not Online!")
    end
end)

RegisterNetEvent("mycroft_id:useID", function(player, Mugshot)
    local xTarget = ESX.GetPlayerFromIdentifier(player)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xTarget then
        TriggerEvent('jsfour-idcard:open', xTarget.source, source, nil, Mugshot)
    else
        xPlayer.showNotification("ERROR: Player Not Online!")
    end
end)

RegisterCommand("id", function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem('idcard', 1, {player = xPlayer.identifier, description = "ID Card of ".. xPlayer.getName()})
    TriggerClientEvent("mycroft_id:RegisterMugshot", source)
end, true)

ESX.RegisterServerCallback("mycroft_id:BuyIdCard", function(src, cb)
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer.getMoney() < 200 then 
        cb(false)
        return 
    end
    cb(true)
    xPlayer.removeMoney(200)
    xPlayer.addInventoryItem('idcard', 1, {player = xPlayer.identifier, description = "ID Card of ".. xPlayer.getName()})
    TriggerClientEvent("mycroft_id:RegisterMugshot", src)
end)


RegisterNetEvent("mycroft_id:RecieveMugshot", function(mugshot)
    local _source = source 
    local xPlayer = ESX.GetPlayerFromId(_source)
    local ox_inventory = exports.ox_inventory

    local IDcard = ox_inventory:Search(_source, 1, 'idcard')
    for k, v in pairs(IDcard) do
        IDcard = v
    end

    if IDcard.metadata.player == xPlayer.identifier then 
        IDcard.metadata.mugshot = mugshot
    end
    ox_inventory:SetMetadata(_source, IDcard.slot, IDcard.metadata)
end)