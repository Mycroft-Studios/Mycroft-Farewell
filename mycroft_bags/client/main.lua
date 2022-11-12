local IsWearing = false 
local BagData = {}
local CaseData = {}
function LoadPropDict(model)
	while not HasModelLoaded(GetHashKey(model)) do
	  RequestModel(GetHashKey(model))
	  Wait(10)
	end
  end

  function AddPropToPlayer(prop1, bone, off1, off2, off3, rot1, rot2, rot3)
	local Player = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(Player))
  
	if not HasModelLoaded(prop1) then
	  LoadPropDict(prop1)
	end
  
	prop = CreateObject(GetHashKey(prop1), x, y, z+0.2,  true,  true, true)
	AttachEntityToEntity(prop, Player, GetPedBoneIndex(Player, bone), off1, off2, off3, rot1, rot2, rot3, true, true, false, true, 1, true)
	SetModelAsNoLongerNeeded(prop1)
	return prop
  end
  
function WearBag()
	local Ped = PlayerPedId()
	if not BagData.ID then 
		BagData.ID = "Bag-"..ESX.GetRandomString(10)
	end
	IsWearing = not IsWearing 
	LocalPlayer.state.WearingBag = IsWearing
	if not IsWearing then 
		if GetPedDrawableVariation(Ped, 5) == 82 then
			SetPedComponentVariation(Ped, 5, 0, 0, 0)
		end 
	end
	while IsWearing do 
		local Ped = PlayerPedId()
		if GetPedDrawableVariation(Ped, 5) ~= 82 then
			local Index = 82
			SetPedComponentVariation(Ped, 5, Index, 0, 0)
		end
	Wait(0)
	end
end
local IsCarrying = false
local Prop = nil

function carrycase()
	local Ped = PlayerPedId()
	if not CaseData.ID then
		CaseData.ID = "Case-"..ESX.GetRandomString(10)
	end
	IsCarrying = not IsCarrying 
	LocalPlayer.state.CarryingCase = IsCarrying
	if not IsCarrying then 
			DeleteEntity(Prop)
	else 
		Prop = AddPropToPlayer("prop_security_case_01", 57005, 0.10, 0.0, 0.0, 0.0, 280.0, 53.0)
	end
end



function BagUse(Data, slot)
	if BagData.ID ~= slot.metadata.ID then 
		BagData.ID = slot.metadata.ID 
	end
	--exports.ox_inventory:useItem(data, function(data)
		-- The item has been used, so trigger the effects
		--if data then
	ESX.TriggerServerCallback("usebag", function(use)
		if use then
			local Ped = PlayerPedId()
			IsWearing = not IsWearing 
			LocalPlayer.state.WearingBag = IsWearing
			if not IsWearing then 
				if GetPedDrawableVariation(Ped, 5) == 82 then
					SetPedComponentVariation(Ped, 5, 0, 0, 0)
				end 
			end
			while IsWearing do 
				local Ped = PlayerPedId()
				if GetPedDrawableVariation(Ped, 5) ~= 82 then
					local Index = 82
					SetPedComponentVariation(Ped, 5, Index, 0, 0)
				end
			Wait(0)
			end
		end
	end,slot.metadata.ID)
end

function CaseUse(Data, slot)
	if CaseData.ID ~= slot.metadata.ID then 
		CaseData.ID = slot.metadata.ID 
	end
	--exports.ox_inventory:useItem(data, function(data)
		-- The item has been used, so trigger the effects
		--if data then
	ESX.TriggerServerCallback("usecase", function(use)
		if use then
			local Ped = PlayerPedId()
			IsWearing = not IsWearing 
			IsCarrying = not IsCarrying 
			LocalPlayer.state.CarryingCase = IsCarrying
			if not IsCarrying then 
					DeleteEntity(Prop)
			else 
				Prop = AddPropToPlayer("prop_security_case_01", 57005, 0.10, 0.0, 0.0, 0.0, 280.0, 53.0)
			end
		end
	end,slot.metadata.ID)
end

exports('UseBag', BagUse)
exports('UseCase', CaseUse)


RegisterNetEvent("mycroft_bags:SetBag", function(id)
		BagData.ID = id
		WearBag()
end)

function GetCameraDirection()
    local rotation = GetGameplayCamRot() * (math.pi / 180)
    
    return vector3(-math.sin(rotation.z), math.cos(rotation.z), math.sin(rotation.x))
end

RegisterNetEvent("addtargettobag", function(bag, id)
	Wait(200)
	local object = NetworkGetEntityFromNetworkId(bag)
	PlaceObjectOnGroundProperly(object)
	FreezeEntityPosition(object, true)
	exports.qtarget:AddTargetEntity(object, {
		options = {
			{
				icon = "fas fa-box-circle-check",
				label = "Pick Up",
				action = function()
					ESX.TriggerServerCallback("pickup", function(pickup)
						DeleteEntity(object)
						WearBag()
					end, id)
				end
			},
			{
				icon = "fas fa-box-circle-check",
				label = "Open",
				action = function()
					local ox_inventory = exports.ox_inventory
					if ox_inventory:openInventory('stash', id) == false then
						TriggerServerEvent('mycroft_bags:Createbag', id)
						ox_inventory:openInventory('stash', id)
					end
				end
			},
			{
				icon = "fas fa-box-circle-check",
				label = "Pack-up",
				action = function()
					ESX.TriggerServerCallback("packup", function(pickup)
						if pickup then
							local attempt = 0
							while not NetworkHasControlOfEntity(object) and attempt < 100 and DoesEntityExist(object) do
								Wait(1)
								NetworkRequestControlOfEntity(object)
								attempt = attempt + 1
							end
					
							if DoesEntityExist(object) and NetworkHasControlOfEntity(object) then
								DeleteEntity(object)
							end
						else 
							ESX.ShowNotification("Cannot Pack-up This Bag!")
						end
					end, id)
				end
			},
		},
		distance = 2
	})
end)

RegisterNetEvent("addtargettocase", function(bag, id)
	Wait(200)
	local object = NetworkGetEntityFromNetworkId(bag)
	PlaceObjectOnGroundProperly(object)
	FreezeEntityPosition(object, true)
	exports.qtarget:AddTargetEntity(object, {
		options = {
			{
				icon = "fas fa-box-circle-check",
				label = "Pick Up",
				action = function()
					ESX.TriggerServerCallback("pickupcase", function(pickup)
						DeleteEntity(object)
						carrycase()
					end, id)
				end
			},
			{
				icon = "fas fa-box-circle-check",
				label = "Open",
				action = function()
					local ox_inventory = exports.ox_inventory
					if ox_inventory:openInventory('stash', id) == false then
						TriggerServerEvent('mycroft_bags:CreateCase', id)
						ox_inventory:openInventory('stash', id)
					end
				end
			},
			{
				icon = "fas fa-box-circle-check",
				label = "Pack-up",
				action = function()
					ESX.TriggerServerCallback("packupcase", function(pickup)
						if pickup then
							local attempt = 0
							while not NetworkHasControlOfEntity(object) and attempt < 100 and DoesEntityExist(object) do
								Wait(1)
								NetworkRequestControlOfEntity(object)
								attempt = attempt + 1
							end
					
							if DoesEntityExist(object) and NetworkHasControlOfEntity(object) then
								DeleteEntity(object)
							end
						else 
							ESX.ShowNotification("Cannot Pack-up This Bag!")
						end
					end, id)
				end
			},
		},
		distance = 2
	})
end)

function DropBag()
	WearBag()
	local direction = GetCameraDirection()
	local PCoords = GetEntityCoords(PlayerPedId()) + vector3(direction.x, direction.y, 0)
	ESX.TriggerServerCallback("dropbag", function()
	end,  BagData.ID, PCoords)
end


exports("DropBag",DropBag)

exports("DropCase", function()
	carrycase()
	local direction = GetCameraDirection()
	local PCoords = GetEntityCoords(PlayerPedId()) + vector3(direction.x, direction.y, 0)
	ESX.TriggerServerCallback("dropcase", function()
	end,  CaseData.ID, PCoords)
end)

RegisterCommand("wear", function()
	WearBag()
end)

RegisterCommand("DropBag", function()
	DropBag()
end)

RegisterCommand("carrycase", function()
	carrycase()
end)




