--[[
Copyright (C) 2021 Sub-Zero Interactive

All rights reserved.

Permission is hereby granted, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software with 'All rights reserved'. Even if 'All rights reserved' is very clear :

  You shall not sell and/or resell this software
  You Can use and modify the software
  You Shall Not Distribute and/or Redistribute the software
  The above copyright notice and this permission notice shall be included in all copies and files of the Software.
--]] -- WAREHOUSE'S --
local Process = true
function WarehouseRefresh()
    Warehouses = nil
    local WarehouseList = LoadResourceFile(GetCurrentResourceName(), 'warehouses.json')
    if WarehouseList then
        Warehouses = json.decode(WarehouseList)
        TriggerClientEvent("szi_territories:RefreshWareHouses", -1, Warehouses)
    end
end

WarehouseRefresh()

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

ESX.RegisterServerCallback('szi_territories:canSell', function(source, cb, pos)
    local xPlayer = ESX.GetPlayerFromId(source)
    local itemcount = 0

    for k, v in pairs(GetNPC("SellItems")) do
        local item = xPlayer.getInventoryItem(v.name)
        if (item) and (item.count >= 1) then
            itemcount = itemcount + 1
        end
    end

    if itemcount <= #(GetNPC("SellItems")) and itemcount >= 1 then
        cb(true)
        itemcount = 0
    else
        cb(false)
        itemcount = 0
    end
end)

-- for k, v in pairs(Warehouses) do
--     CreateInventory(k)
-- end

function CreateInventory(Warehouse)
    local uniqueIdentifier = "szi_warehouse" .. Warehouses[Warehouse].name -- Unique identifier for this inventory.
    local inventoryType = "inventory" -- Inventory type. Default is "inventory", other types are "shop" and "recipe".
    local inventorySubType = "housing" -- Inventory sub-type, used to modify degrade modifiers by the config table.
    local inventoryLabel = "warehouse_storage" -- The inventorys UI label index (which will pull the translation value).
    local maxWeight = Warehouses[Warehouse].Weight -- Max weight for the inventory.
    local maxSlots = Warehouses[Warehouse].Slots -- Max slots for the inventory.
    local items = exports["mf-inventory"]:buildInventoryItems({})
    exports["mf-inventory"]:createInventory(uniqueIdentifier, inventoryType, inventorySubType, inventoryLabel,maxWeight, maxSlots, items) -- Construct table of valid items for the inventory from pre-existing ESX items table (OR a blank table/{}).
end

RegisterNetEvent("szi_territories:sell")
AddEventHandler('szi_territories:sell', function(pos)
  local xPlayer = ESX.GetPlayerFromId(source)
    for k, v in pairs(GetNPC("SellItems")) do
        local item = xPlayer.getInventoryItem(v.name)
        if item.count >= 1 then
            xPlayer.removeInventoryItem(v.name, item.count)
            xPlayer.addAccountMoney('money', v.price * item.count)
        end
    end
end)

RegisterNetEvent("szi_territories:process")
AddEventHandler('szi_territories:process', function(Drug, Warehouse, Time, count)
  Citizen.CreateThread(function()
    SetWarehouseProcessing(Warehouse, true)
    Citizen.Wait(Time)
    SetWarehouseProcessing(Warehouse, false)
    FreezeEntityPosition(GetPlayerPed(source), false)
    local inventory = exports["mf-inventory"]:getInventory("szi_warehouse" .. Warehouses[Warehouse].name)
    inventory:removeItem(Config.Drugs[Drug].Field.item, count)
    xPlayer.addInventoryItem(Config.Drugs[Drug].Processed.name, math.floor(count / 2))
  end)
end)

RegisterNetEvent("szi_territories:bag")
AddEventHandler('szi_territories:bag', function(Drug, Warehouse, Time, count)
    Citizen.CreateThread(function()
        SetWarehouseBagging(Warehouse, true)
        Citizen.Wait(Time)
        SetWarehouseBagging(Warehouse, false)
        FreezeEntityPosition(GetPlayerPed(source), false)
        local inventory = exports["mf-inventory"]:getInventory("szi_warehouse" .. Warehouses[Warehouse].name)
        inventory:removeItem(Config.Drugs[Drug].Processed.name, count)
        xPlayer.addInventoryItem(Config.Drugs[Drug].bag.name, math.floor(count / 2))
    end)
end)

RegisterNetEvent("szi_territories:box")
AddEventHandler('szi_territories:box', function(Drug, Warehouse, Time, count)
    Citizen.CreateThread(function()
        SetWarehousePacking(Warehouse, true)
        Citizen.Wait(Time)
        SetWarehousePacking(Warehouse, false)
        FreezeEntityPosition(GetPlayerPed(source), false)
        local inventory = exports["mf-inventory"]:getInventory("szi_warehouse" .. Warehouses[Warehouse].name)
        inventory:removeItem(Config.Drugs[Drug].bag.name, count)
        xPlayer.addInventoryItem(Config.Drugs[Drug].box.name, count)
    end)
end)

RegisterNetEvent("szi_territories:FinishProcessing")
AddEventHandler('szi_territories:FinishProcessing', function(Drug, amount)
end)

RegisterNetEvent("szi_territories:TogglePowerStatus")
AddEventHandler('szi_territories:TogglePowerStatus', function(Warehouse)
    if Warehouses[Warehouse].PowerStatus then
        Warehouses[Warehouse].PowerStatus = false
    else
        Warehouses[Warehouse].PowerStatus = true
    end
end)

RegisterNetEvent("szi_territories:AddPower")
AddEventHandler('szi_territories:AddPower', function(Warehouse, amount)
    if (Warehouses[Warehouse].PowerLevel < 100) then
        Warehouses[Warehouse].PowerLevel = Warehouses[Warehouse].PowerLevel + amount
    end
end)

ESX.RegisterServerCallback('szi_territories:item_count', function(source, cb, drug)
    local xPlayer = ESX.GetPlayerFromId(source)
    local itemcount = xPlayer.getInventoryItem(drug["Field"]["item"]).count
    if itemcount >= 1 then
        print(drug["Field"]["item"])
        cb(itemcount)
    else
        print("no")
        cb(nil)
    end
end)

ESX.RegisterServerCallback('szi_territories:GetWareHouses', function(source, cb, drug)
    if Warehouses then
        cb(Warehouses)
    else
        cb(nil)
    end
end)

ESX.RegisterServerCallback('szi_territories:GetPowerStatus', function(source, cb, Warehouse)
    local warehouse = GetWarehouseData(Warehouse)
    if warehouse then
        if warehouse.PowerStatus == true then
            cb("Online", warehouse.PowerLevel)
        else
            cb("Offline", warehouse.PowerLevel)
        end
    else
        cb(nil)
    end
end)

RegisterServerEvent('szi_territories:pickedUp')
AddEventHandler('szi_territories:pickedUp', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local amount = math.random(5, 10)

    for k, v in pairs(Config.Drugs) do
        if xPlayer.canCarryItem(v.name, amount) then
            xPlayer.addInventoryItem(v.name, amount)
        else
            -- xPlayer.showNotification(_U('weed_inventoryfull'))
        end
    end
end)

RegisterServerEvent('szi_territories:enter')
AddEventHandler('szi_territories:enter', function(warehouse)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getJob().name == Warehouses[warehouse].Owner then
        SetEntityCoords(GetPlayerPed(source), Warehouses[warehouse].Positions.Exit.x,
            Warehouses[warehouse].Positions.Exit.y, Warehouses[warehouse].Positions.Exit.z)
        SetEntityRoutingBucket(source, Warehouses[warehouse].BucketNumber)
    end
end)

RegisterServerEvent('szi_territories:buy')
AddEventHandler('szi_territories:buy', function(warehouse)
    if Warehouses[warehouse].Owner == "" then
        local xPlayer = ESX.GetPlayerFromId(source)
        for k, v in pairs(Config.Gangs) do
            if (xPlayer.getJob().name == v.JobName) and (xPlayer.getJob().grade_name == v.BossRank) then
                if xPlayer.GetMoney() >= Warehouses[warehouse].Price then
                    print("Bought Warehouse")
                    xPlayer.removeMoney(Warehouses[warehouse].Price)
                    Warehouses[warehouse].Owner = xPlayer.getJob().name
                    SaveResourceFile(GetCurrentResourceName(), 'warehouses.json', Warehouses)
                    Wait(2)
                    TriggerClientEvent("szi_territories:RefreshWareHouses", -1, Warehouses)
                end
            end
        end
    end
end)

RegisterServerEvent('szi_territories:exit')
AddEventHandler('szi_territories:exit', function(warehouse)
    SetEntityCoords(GetPlayerPed(source), Warehouses[warehouse].Positions.Entrance.x,Warehouses[warehouse].Positions.Entrance.y, Warehouses[warehouse].Positions.Entrance.z)
    SetEntityRoutingBucket(source, 0)
end)

RegisterServerEvent('szi_territories:pickedUp')
AddEventHandler('szi_territories:pickedUp', function(drug)
    local xPlayer = ESX.GetPlayerFromId(source)

        if xPlayer.canCarryItem(drug, 1) then
            xPlayer.addInventoryItem(drug, 1)
        else
            -- xPlayer.showNotification(_U('weed_inventoryfull'))
        end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(180000)
        for i = 1, #(Warehouses) do
            print(Warehouses[i].PowerStatus)
            if Warehouses[i].PowerLevel > 0 and Warehouses[i].PowerStatus then
                Warehouses[i].PowerLevel = Warehouses[i].PowerLevel - 5
            end
            if Warehouses[i].PowerLevel > 100 then
                Warehouses[i].PowerLevel = 100
            end

            while Warehouses[i].PowerLevel <= 0 do
                -- TimeTilPolice = TimeTilPolice - 1
            end
        end
    end
end)

ESX.RegisterServerCallback('szi_territories:canPickUp', function(source, cb, item, drug)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(xPlayer.canCarryItem(drug, 1))
end)

ESX.RegisterServerCallback('szi_territories:canEnter', function(source, cb, item, warehouse)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getJob().name == Warehouses[warehouse].Owner then
        cb(true)
    else
        cb(false)
    end
end)

function SetWarehouseProcessing(Warehouse, value)
    print(Warehouse.name)
    for i = 1, #(Warehouses) do
        if Warehouses[i].name == Warehouse.name then
            Warehouses[i].Processing.Active = value
            TriggerClientEvent("szi_territories:RefreshWareHouses", -1, Warehouses)
        else
            return nil
        end
    end
end

function GetWarehouseData(Warehouse)
    for k, v in pairs(Warehouses) do
        if v.name == Warehouse then
            return v
        else
            return nil
        end
    end
end
