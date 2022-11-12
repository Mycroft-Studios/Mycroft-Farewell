RegisterNetEvent("esx-phone:giveContactInfo", function(target)
    local source = source
    xPlayer = ESX.GetPlayerFromId(source)
    local PlayerData = exports.npwd:getPlayerData({source = xPlayer.source})
    TriggerClientEvent("client:giveContactInfo", target, {name = xPlayer.name, number = PlayerData.phoneNumber})
end)

ESX.RegisterCommand('givewl', 'user', function(xPlayer, args, showError)
	if xPlayer.job.name == "police" or xPlayer.group == "admin" then
		TriggerEvent('esx_license:addLicense', args.playerId.source, 'weapon')
        args.playerId.addInventoryItem('weaponlicense', 1, {player = args.playerId.identifier, description = "Weapon Licence Registered To ".. args.playerId.getName()})
        TriggerClientEvent("mycroft_extra:RegisterMugshot", args.playerId.source)
    
        RegisterNetEvent("mycroft_extra:RecieveMugshot", function(mugshot)
        local _source = source 
        local xPlayer = ESX.GetPlayerFromId(_source)
        local ox_inventory = exports.ox_inventory
    
        local IDcard = ox_inventory:Search(_source, 1, 'weaponlicense')
        for k, v in pairs(IDcard) do
            IDcard = v
        end
    
        if IDcard.metadata.player == xPlayer.identifier then 
            IDcard.metadata.mugshot = mugshot
        end
        ox_inventory:SetMetadata(_source, IDcard.slot, IDcard.metadata)
        end)
	end
end, true, {help = "Give Licence To Player (Police Only)", validate = true, arguments = {
	{name = 'playerId', help = "Player Id", type = 'player'}
}})

ESX.RegisterCommand('removewl', 'user', function(xPlayer, args, showError)
	if xPlayer.job.name == "police"  or xPlayer.group == "admin" then
		TriggerEvent('esx_license:removeLicense', args.playerId.source, 'weapon')
        exports.ox_inventory:RemoveItem(args.playerId.source, 'weaponlicense', 1)
	end
end, true, {help = "Remove Licence From Player (Police Only)", validate = true, arguments = {
	{name = 'playerId', help = "Player Id", type = 'player'}
}})

ESX.RegisterServerCallback('tackle:server:TacklePlayer', function(source, cb, targetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then return end
    local TargetCoords = GetEntityCoords(GetPlayerPed(targetId))
    local PlayerCoords = GetEntityCoords(GetPlayerPed(source))
    local distance = #(TargetCoords - PlayerCoords)
    if distance > 2.0 then return cb(false) end
    cb(true)
    TriggerClientEvent("tackle:client:GetTackled", targetId)
end)
