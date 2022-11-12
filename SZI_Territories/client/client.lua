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
]] 

local selling, inWarehouse = false, false

AddEventHandler('onClientResourceStart', function (resourceName)
	if (GetCurrentResourceName() ~= resourceName) then return end
	Citizen.CreateThread(function()
		while ESX == nil do
			TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
			Citizen.Wait(100) 
			StartClient()
		end
	end)
end)

function CanSell()
	local dict, anim = GetNPC("PlayerDict"), GetNPC("PlayerAnimName")
	ESX.Streaming.RequestAnimDict(dict)
	ESX.TriggerServerCallback('szi_territories:canSell', function(CanSell)
	    if CanSell then
			TaskPlayAnim(PlayerPedId(), dict, anim, 1.0, 1.0, 3000, 16, 0.0, false, false, false)
			TriggerServerEvent("szi_territories:sell")
			ESX.ShowHelpNotification("~g~ Sold!")
			Wait(2000)
			Selling = false
		else
			ESX.ShowHelpNotification("~r~ Nothing To Sell!")
			Wait(2000)
			Selling = false
		end
	end)
end

RegisterNetEvent("szi_territories:RefreshWareHouses")
AddEventHandler('szi_territories:RefreshWareHouses', function(data)
	Warehouses = data
end)

function GetWareHouses()
	Warehouses = nil
	ESX.TriggerServerCallback("szi_territories:GetWareHouses", function(warehouses) 
		if warehouses then 
			Warehouses = warehouses
		
		for k,v in pairs(warehouses) do
		exports["fivem-target"]:AddTargetPoint({
  	  name = "warehouse-enterance",
  	  label = "Enterance",
  	  icon = "fas fa-door-open",
  	  point = vector3(v.Positions.Entrance.x,v.Positions.Entrance.y,v.Positions.Entrance.z),
  	  interactDist = 4.5,
  	  onInteract = Interaction,
  	  options = {
   	   {
   	     name = "enter_warehouse",
   	     label = "Enter"
  	    },      
   	   {
    	    name = "Take",
    	    label = "Takeover"
    	  },  
				{
    	    name = "buy",
    	    label = "Buy"
    	  },  
				{
    	    name = "raid",
    	    label = "Raid"
    	  },     
   	 },
    	vars = {
  	    warehouse = k
  	  }
  	})
		exports["fivem-target"]:AddTargetPoint({
  	  name = "warehouse-storage",
  	  label = "Storage",
  	  icon = "fas fa-archive",
  	  point = vector3(v.Positions.Storage.x,v.Positions.Storage.y, v.Positions.Storage.z),
  	  interactDist = 1.0,
  	  onInteract = Interaction,
  	  options = {
   	   {
   	     name = "open",
   	     label = "Open"
  	    },      
   	 },
    	vars = {
  	    warehouse = k
  	  }
  	})
		exports["fivem-target"]:AddTargetPoint({
  	  name = "warehouse-power",
  	  label = "Power Generator",
  	  icon = "fas fa-power-off",
  	  point = vector3(v.Positions.PowerGen.x, v.Positions.PowerGen.y, v.Positions.PowerGen.z),
  	  interactDist = 1.5,
  	  onInteract = Interaction,
  	  options = {
   	   {
   	     name = "status",
   	     label = "Status"
  	    },      
   	   {
    	    name = "onoff",
    	    label = "Turn On/Off"
    	  },
				{
    	    name = "Add",
    	    label = "Add Power"
    	  },     
   	 },
    	vars = {
  	    warehouse = k
  	  }
  	})
		exports["fivem-target"]:AddTargetPoint({
  	  name = "warehouse-exit",
  	  label = "Exit Warehouse",
  	  icon = "fas fa-door-open",
  	  point = vector3(v.Positions.Exit.x,v.Positions.Exit.y, v.Positions.Exit.z),
  	  interactDist = 2.5,
  	  onInteract = Interaction,
  	  options = {
   	   {
   	     name = "exit",
   	     label = "Exit"
  	    },      
   	 },
    	vars = {
  	    warehouse = k
  	  }
  	})
		exports["fivem-target"]:AddTargetPoint({
  	  name = "warehouse-Processing",
  	  label = "Processing",
  	  icon = "fas fa-mortar-pestle",
  	  point = vector3(v.Processing.Position.x,v.Processing.Position.y,v.Processing.Position.z),
  	  interactDist = 2.5,
  	  onInteract = Interaction,
  	  options = {
   	   {
   	     name = "status",
   	     label = "Status"
  	    },      
   	   {
    	    name = "StartProcessing",
    	    label = "Start Processing"
    	  },
   	 },
    	vars = {
  	    warehouse = k
  	  }
  	})
		exports["fivem-target"]:AddTargetPoint({
  	  name = "warehouse-bagging",
  	  label = "Bagging",
  	  icon = "fas fa-shopping-bag",
  	  point = vector3(v.Bagging.Position.x,v.Bagging.Position.y,v.Bagging.Position.z),
  	  interactDist = 2.5,
  	  onInteract = Interaction,
  	  options = {
   	   {
   	     name = "status",
   	     label = "Status"
  	    },      
   	   {
    	    name = "StartBagging",
    	    label = "Start Bagging"
    	  },
   	 },
    	vars = {
  	    warehouse = k
  	  }
  	})
		exports["fivem-target"]:AddTargetPoint({
  	  name = "warehouse-Packaging",
  	  label = "Packaging",
  	  icon = "fas fa-box-open",
  	  point = vector3(v.Packaging.Position.x,v.Packaging.Position.y,v.Packaging.Position.z),
  	  interactDist = 2.5,
  	  onInteract = Interaction,
  	  options = {
   	   {
   	     name = "status",
   	     label = "Status"
  	    },      
   	   {
    	    name = "StartPackaging",
    	    label = "Start Packaging"
    	  },
   	 },
    	vars = {
  	    warehouse = k
  	  }
  	})
	end
		end
	end)

	for k,v in pairs(Config.Drugs) do
		exports["fivem-target"]:AddTargetModel({
			name = "drug-pickup",
			label = v.Field.itemlabel,
			icon = "fas fa-piggy-bank",
			model = GetHashKey(v.plants.model),
			interactDist = 2.0,
			onInteract = Interaction,
			options = {
					{
						name = "pick",
						label = "Pickup"
					}
			},
	vars = { drug = k}
		})
	end
	exports["fivem-target"]:AddTargetPoint({
		name = "npc-sell",
		label = "Dodgy Dave",
		icon = "fas fa-cash-register",
		point = GetNPC("Position"),
		interactDist = 2.5,
		onInteract = CanSell,
		options = {
			{
				name = "sell",
				label = "Sell Drugs"
			},      
		},
		vars = {}
	})
	
end

function StartClient()
	local dict, anim = GetNPC("PedDict"), GetNPC("PedAnimName")
	RequestModel(GetHashKey(GetNPC("Model")))
	while (not HasModelLoaded(GetHashKey(GetNPC("Model")))) do
		Wait(10)
	end
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
	    Wait(10)
	end
	GetWareHouses()
	ped = CreatePed(4, GetHashKey(GetNPC("Model")) , GetNPC("Position"), 3374176, false, true)
	SetEntityHeading(ped, GetNPC("Heading"))
	FreezeEntityPosition(ped, true)
	SetEntityInvincible(ped, true)
	SetBlockingOfNonTemporaryEvents(ped, true)
	TaskPlayAnim(ped, dict, anim, 8.0, 0.0, -1, 1, 0, 0, 0, 0)
end

function EnterWareHouse(warehouse)
	if not inWarehouse then
		ESX.TriggerServerCallback("szi_territories:CanEnter", function(CanEnter)
			if CanEnter then 
			print("Entered Warehouse | ".. Warehouses[warehouse].name )
			inWarehouse = true
			TriggerServerEvent("szi_territories:enter", warehouse)
			else
				print("Cannot Enter".. Warehouses[warehouse].name)
			end
		end, warehouse)
 else
	print("Already In Warehouse")
	end
end

function StartTakeover(warehouse)
	print("Takingover | ".. Warehouses[warehouse].name )
end

function PowerStatus(warehouse)
	ESX.TriggerServerCallback('szi_territories:GetPowerStatus', function(Online, Level)
			print("[PowerStatus] | ".. Online .." | Level - ".. Level)
end, Warehouses[warehouse].name)
end

function TogglePower(warehouse)
	TriggerServerEvent("szi_territories:TogglePowerStatus", warehouse)
	print("Toggling Power At | ".. Warehouses[warehouse].name .." | ")
end

function AddPower(warehouse)
	TriggerServerEvent("szi_territories:AddPower", warehouse, 20)
	print("Adding Power To | ".. warehouse)
end

function Status(stat, warehouse)
	if inWarehouse then
		if stat == "Processing" then
			if Warehouses[warehouse].Processing.Active then
				print("[Status] | Processing - True | TimeLeft - ".. timeLeft)
			else
				print("[Status] | Processing - false ")
			end
		end
		elseif stat == "Bagging" then
			if Warehouses[warehouse].Bagging.Active then
				print("[Status] | Bagging - True | TimeLeft - ".. timeLeft)
			else
				print("[Status] | Bagging - false ")
			end
		elseif stat == "Packing" then
			if Warehouses[warehouse].Packing.Active then
				print("[Status] | Packing - True | TimeLeft - ".. timeLeft)
			else
				print("[Status] | Packing - false ")
			end
		end
end

function Action(action,drug, amount, name, Warehouse)
	if action == "Process" then
	ESX.ShowNotification("Started Processsing | ~y~".. drug.Field.itemlabel)
	timeLeft = (Warehouse.Processing.Delay * amount) / 1000
  TriggerServerEvent('szi_territories:process', name, Warehouse, Warehouse.Processing.Delay * amount, amount)
	local playerPed = PlayerPedId()
	FreezeEntityPosition(PlayerPedId(), true) -- replace
	Citizen.CreateThread(function()
	while timeLeft > 0 do
		Citizen.Wait(1000)
		timeLeft = timeLeft - 1
			if not inWarehouse then
			ESX.ShowNotification("[ProccessStatus] stopped | Exited Warehouse")
			TriggerServerEvent('szi_territories:cancelProcessing', name)
			TriggerServerEvent('szi_territories:outofbound', name)
			timeLeft = 0
			FreezeEntityPosition(PlayerPedId(), false) -- replace
			print("[ProccessStatus] stopped | Exited Warehouse")
			break
		end
	end
end)
	elseif action == "Bagging" then
	ESX.ShowNotification("Started Bagging | ~y~".. drug.Processed.label)
	timeLeft = (Warehouse.Bagging.Delay * amount) / 1000
  TriggerServerEvent('szi_territories:bag', name, Warehouse, Warehouse.Bagging.Delay * amount, amount)
	local playerPed = PlayerPedId()

	Citizen.CreateThread(function()
	while timeLeft > 0 do
		Citizen.Wait(1000)
		timeLeft = timeLeft - 1
		if not inWarehouse then
			ESX.ShowNotification("[Status] Bagging stopped | Exited Warehouse")
			TriggerServerEvent('szi_territories:cancelBagging', name)
			TriggerServerEvent('szi_territories:outofbound', name)
			timeLeft = 0
			print("[Status] Bagging stopped | Exited Warehouse")
			break
		end
	end
end)
	elseif action == "Packing" then
		ESX.ShowNotification("Started Packing | ~y~".. drug.bag.label)
	timeLeft = (Warehouse.Packing.Delay * amount) / 1000
  TriggerServerEvent('szi_territories:pack', name, Warehouse, Warehouse.Packing.Delay * amount, amount)
	local playerPed = PlayerPedId()
	FreezeEntityPosition(PlayerPedId(), true) -- replace
	Citizen.CreateThread(function()
	while timeLeft > 0 do
		Citizen.Wait(1000)
		timeLeft = timeLeft - 1
		if not inWarehouse then
			ESX.ShowNotification("[Status] Packing stopped | Exited Warehouse")
			TriggerServerEvent('szi_territories:cancelPacking', name)
			TriggerServerEvent('szi_territories:outofbound', name)
			timeLeft = 0
			FreezeEntityPosition(PlayerPedId(), false) -- replace
			print("[Status] Packing stopped | Exited Warehouse")
			break
		end
	end
end)
end
end

function Start(action, warehouse)
	if inWarehouse then
		ESX.TriggerServerCallback('szi_territories:GetPowerStatus', function(Online, Level)
		if Online == "Online" and Level > 0 then
	ESX.UI.Menu.CloseAll()

	local elements = {}
	if action == "Processing" then
		exports["mf-inventory"]:getInventoryItems("szi_warehouse"..Warehouses[warehouse].name,function(items)
			for k, v in pairs(items) do
				for a,b in pairs(Config.Drugs) do
				if v.name == b.Field.item then
					table.insert(elements, {label = ('%s'):format(b.Field.itemlabel), drug = b, name = a, type = 'slider', value = 1, min = 1, max = v.count})
				end
				end
				end
		end)
	elseif action == "Bagging" then
		exports["mf-inventory"]:getInventoryItems("szi_warehouse"..Warehouses[warehouse].name,function(items)
			for k, v in pairs(items) do
				for a,b in pairs(Config.Drugs) do
				if v.name == b.bag.name then
					table.insert(elements, {label = ('%s'):format(v.bag.label), drug = b, name = a, type = 'slider', value = 1, min = 1, max = v.count})
				end
				end
				end
		end)
	elseif action == "Packing" then
		exports["mf-inventory"]:getInventoryItems("szi_warehouse"..Warehouses[warehouse].name,function(items)
			for k, v in pairs(items) do
				for a,b in pairs(Config.Drugs) do
				if v.name == b.box.name then
					table.insert(elements, {label = ('%s'):format(v.box.label), drug = b, name = a, type = 'slider', value = 1, min = 1, max = v.amount})
				end
				end
				end
		end)
end
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'Drug-Process', {
		title    = 'Warehouse Stock',
		align    = 'bottom-right',
		elements = elements
	}, function(data, menu)
			if action == "Processing" then
				Action("Process",data.current.drug, data.current.value, data.current.name, Warehouses[warehouse])
			elseif action == "Bagging" then
				Action("Bagging",data.current.drug, data.current.value, data.current.name, Warehouses[warehouse])
			elseif action == "Packing" then
				Action("Bagging",data.current.drug, data.current.value, data.current.name, Warehouses[warehouse])
			end		
			menu.close()
	end, function(data, menu)
		menu.close()
	end)
else
	print("ERROR: No Power!")
end
end, Warehouses[warehouse].name)
else
	print("ERROR: Not In A Warehouse!")
end
end

function ExitWareHouse(warehouse)
	if inWarehouse then
	print("Exiting | ".. Warehouses[warehouse].name )
	inWarehouse = false
	TriggerServerEvent("szi_territories:exit",warehouse)
	else
		print("Not In A warehouse")
	end
end

function OpenStorage(warehouse)
	exports["mf-inventory"]:openOtherInventory("szi_warehouse"..Warehouses[warehouse].name)
	print("Adding To | ".. Warehouses[warehouse].name )
end

function BuyWarehouse(warehouse)
	TriggerServerEvent("szi_territories:buy",warehouse)
end

function Interaction(targetName,optionName,vars,entityHit)
	if targetName == "warehouse-enterance" then
		if optionName == "enter_warehouse" then
			TriggerEvent('instance:create', 'Warehouse', {Warehouse = vars.warehouse, owner = ESX.GetPlayerData().identifier})
			EnterWareHouse(vars.warehouse)
		elseif optionName == "Take" then
			StartTakeover(vars.warehouse)
		elseif optionName == "Buy" then
			BuyWarehouse(vars.warehouse)
		end
	elseif targetName == "warehouse-power" then
		if optionName == "status" then
			PowerStatus(vars.warehouse)
		elseif optionName == "onoff" then
			TogglePower(vars.warehouse)
		elseif optionName == "Add" then
			AddPower(vars.warehouse)
		end
	elseif targetName == "warehouse-Processing" then
		if optionName == "status" then
			Status("Processing",vars.warehouse)
		elseif optionName == "StartProcessing" then
			Start("Processing",vars.warehouse)
		end
	elseif targetName == "warehouse-Bagging" then
		if optionName == "status" then
			Status("Bagging",vars.warehouse)
		elseif optionName == "StartProcessing" then
			Start("Bagging",vars.warehouse)
		end
	elseif targetName == "warehouse-Packing" then
		if optionName == "status" then
			Status("Packing",vars.warehouse)
		elseif optionName == "StartPacking" then
			Start("Packing",vars.warehouse)
		end
	elseif targetName == "warehouse-exit" then
		if optionName == "exit" then
			TriggerEvent('instance:leave')
			ExitWareHouse(vars.warehouse)
		end	
elseif targetName == "warehouse-storage" then
	if optionName == "oepen" then
		OpenStorage(vars.warehouse)
	end	
elseif targetName == "drug-pickup" then
	if optionName == "pick" then
		pickup(vars.drug)
	end	
end
end

-- Citizen.CreateThread(function()
-- 	while true do
-- 			Citizen.Wait(0)
-- 		local coords = GetEntityCoords(PlayerPedId())
-- 		if #(coords - GetNPC('Position')) < 3 then
-- 			if not selling then
-- 				ESX.ShowHelpNotification("Press [~b~E~s~] To Sell")
-- 				ESX.Game.Utils.DrawText3D(GetNPC("Position"), "Press [~b~E~s~] To Sell", 1.1, 1)
-- 				if IsControlJustReleased(0, 38) then
-- 					Selling = true
-- 					CanSell()
-- 				end
-- 			end
-- 		end
-- 	end
-- end)

-- START OF Plant CODE --
local isPickingUp = false
local isPlants = false 

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		local coords = GetEntityCoords(PlayerPedId())

		for k,v in pairs(Config.Drugs) do
			if #(coords - v.Field.Position) < 50.0 then
				if (v.plants.spawned < v.plants.Count) and v.plants.delay == 0 then
				Spawn(k)
				Citizen.Wait(1000)
				end
			else
				Citizen.Wait(1000)
			end

			if v.plants.delay > 0 then
				print(v.plants.delay)
				Config.Drugs[k].plants.delay = Config.Drugs[k].plants.delay - 1
			end
		end
	end
end)

function pickup(drug)
	local coords = GetEntityCoords(PlayerPedId())

			if #(coords - Config.Drugs[drug].Field.Position) < 50.0 then	
				for i=1, #(Config.Drugs[drug].plants.objects) do
					if #(coords - GetEntityCoords(Config.Drugs[drug].plants.objects[i])) < 2.0 then	
					if not isPickingUp then
						isPickingUp = true

								TaskStartScenarioInPlace(PlayerPedId(), 'world_human_gardener_plant', 0, false)
		
								Citizen.Wait(5000)
								ClearPedTasks(PlayerPedId())
								Citizen.Wait(1500)
				
								ESX.Game.DeleteObject(Config.Drugs[drug].plants.objects[i])
				
								table.remove(Config.Drugs[drug].plants.objects, i)
								Config.Drugs[drug].plants.delay =Config.Drugs[drug].plants.delay + Config.Drugs[drug].plants.Timer
								Wait(3)
								Config.Drugs[drug].plants.spawned = Config.Drugs[drug].plants.spawned - 1
								TriggerServerEvent('szi_territories:pickedUp', Config.Drugs[drug].Field.item)
							end
							isPickingUp = false
						else
				end
			end
		end
end

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for z,x in pairs(Config.Drugs) do
		for k, v in pairs(x.plants.objects) do
			ESX.Game.DeleteObject(v)
		end
		end
	end
end)

function Spawn(drug)
		local plantCoords = GeneratePlantCoords(drug)
		print(plantCoords)
		ESX.Game.SpawnLocalObject(Config.Drugs[drug].plants.model, plantCoords, function(obj)
			PlaceObjectOnGroundProperly(obj)
			FreezeEntityPosition(obj, true)

			table.insert(Config.Drugs[drug].plants.objects, obj)
			Config.Drugs[drug].plants.spawned = Config.Drugs[drug].plants.spawned + 1
		end)
end

function ValidatePlantCoord(plantCoord, drug)
	if Config.Drugs[drug].plants.spawned > 0 then
		local validate = true

		for k, v in pairs(Config.Drugs[drug].plants.objects) do
	--		print(GetEntityCoords(v))
			if #(plantCoord - GetEntityCoords(v)) < 5 then
				validate = false
			end
		end

			if #(plantCoord - Config.Drugs[drug].Field.Position) > 50 then
				validate = false
			end

		return validate
	else
		return true
	end
end

function GeneratePlantCoords(drug)
	while true do
		Citizen.Wait(1)
			local plantCoordX, plantCoordY

			math.randomseed(GetGameTimer())
			local modX = math.random(-90, 90)

			Citizen.Wait(100)

			math.randomseed(GetGameTimer())
			local modY = math.random(-90, 90)

			plantCoordX = Config.Drugs[drug].Field.Position.x + modX
			plantCoordY = Config.Drugs[drug].Field.Position.y + modY

			local coordZ = GetCoordZ(plantCoordX, plantCoordY)
			local coord = vector3(plantCoordX, plantCoordY, coordZ)
            -- local coord = Config.Drugs[drug].Field.Position

			if ValidatePlantCoord(coord, drug) then
				return coord
			end
	end
end

function GetCoordZ(x, y)
	local groundCheckHeights = { 48.0, 49.0, 50.0, 51.0, 52.0, 53.0, 54.0, 55.0, 56.0, 57.0, 58.0, 59.0,60.0,61.0,62.0,63.0,64.0,65.0,66.0,69.0,70.0, 71.0, 72.0, 73.0, 74.0, 75.0, 76.0, 77.0, 78.0, 79.0, 80.0 }

	for i, height in ipairs(groundCheckHeights) do
		local foundGround, z = GetGroundZFor_3dCoord(x, y, height)

		if foundGround then
			return z
		end
	end

	return 53.0
end