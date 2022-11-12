local ESX = exports["es_extended"]:getSharedObject()

-- RegisterNetEvent("npwd:qb-garage:getVehicles", function()
-- 	local src = source
-- 	local Player  = QBCore.Functions.GetPlayer(src)
-- 	local garageresult = MySQL.query.await('SELECT vehicle, plate, garage, fuel, engine, body, state, hash FROM player_vehicles WHERE citizenid = ?', {Player.PlayerData.citizenid})
-- 	TriggerClientEvent('npwd:qb-garage:sendVehicles', src, garageresult)
-- end)

-- ESX.RegisterServerCallback('npwd:qb-garage:getVehicles', function(src, cb)
-- 	local xPlayer = ESX.GetPlayerFromId(src)
-- 	local garageresult = MySQL.query.await('SELECT * FROM owned_vehicles WHERE owner = ?', {xPlayer.identifer})
-- end)