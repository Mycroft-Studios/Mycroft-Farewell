RegisterNUICallback("npwd:qb-housing:getPlayerHouses", function(_, cb)
	ESX.TriggerServerCallback("npwd:qb-housing:getPlayerHouses", function(data)
		for k,v in pairs(data) do
			if v.label then
				data[k].label = GetStreetNameFromHashKey(GetStreetNameAtCoord(v.coords.enter.x, v.coords.enter.y, v.coords.enter.z))
			end
		end
		cb({ status = "ok", data = data })
	end)
end)

RegisterNUICallback("npwd:qb-housing:getPlayerKeys", function(_, cb)
	ESX.TriggerServerCallback("npwd:qb-housing:getPlayerKeys", function(data)
		for k,v in pairs(data) do
			if v.label then
				data[k].label = GetStreetNameFromHashKey(GetStreetNameAtCoord(v.coords.enter.x, v.coords.enter.y, v.coords.enter.z))
			end
		end
		cb({ status = "ok", data = data })
	end)
end)

RegisterNUICallback("npwd:qb-housing:removeKeyHolder", function(data, cb)
	print(ESX.DumpTable(data))
    TriggerServerEvent('p_houses:s:removekey', {
        PlayerId = data.HolderData.citizenid,
		id = data.house,
    })
    cb({status = "ok"})
end)

RegisterNUICallback("npwd:qb-housing:setWaypoint", function(data, cb)
	print(ESX.DumpTable(data))
	SetNewWaypoint(data.coords.x, data.coords.y)
	cb({status = "ok"})
end)




