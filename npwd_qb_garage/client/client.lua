local ESX = exports["es_extended"]:getSharedObject()

local function findVehFromPlateAndLocate(plate)
	local gameVehicles = ESX.Game.GetVehicles()
	for i = 1, #gameVehicles do
			local vehicle = gameVehicles[i]
			if DoesEntityExist(vehicle) then
					local Plate = GetVehicleNumberPlateText(vehicle)
					if ESX.Math.Trim(Plate) == plate then
							local vehCoords = GetEntityCoords(vehicle)
							SetNewWaypoint(vehCoords.x, vehCoords.y)
							return true
					end
			end
	end
end

RegisterNUICallback("npwd:qb-garage:getVehicles", function(_, cb)
	local Vehicles = {}
	ESX.TriggerServerCallback('szi_garage:GetVehicles', function(UserVehicles)
		for k,v in pairs(UserVehicles) do
			local type = GetVehicleClassFromName(v.model)
			if type == 15 or type == 16 then
				UserVehicles[k].type = "aircraft"
			elseif type == 14 then
				UserVehicles[k].type = "boat"
			elseif type == 13 or type == 8 then
				UserVehicles[k].type = "bike"
			else
				UserVehicles[k].type = "car"
			end
			Vehicles[#Vehicles+ 1] = {brand = GetLabelText(GetMakeNameFromVehicleModel(v.model)), vehicle = GetLabelText(v.model), name = v.name, plate = v.vehicle.plate, garage = v.garage,type = v.type, state = v.status, fuel = v.vehicle.fuel, engine = v.vehicle.engineHealth, body = v.vehicle.bodyHealth, stored = v.ingarage}
		end
		cb({ status = "ok", data = Vehicles })
	end)
end)

RegisterNUICallback("npwd:qb-garage:requestWaypoint", function(data, cb)
	local plate = data.plate
	if findVehFromPlateAndLocate(plate) then
		ESX.ShowNotification("Your vehicle has been marked", "success")
	else
		ESX.ShowNotification("This vehicle cannot be located", "error")
	end
	cb({})
end)
