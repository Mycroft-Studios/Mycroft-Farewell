exports('openID', function(data, slot)
    Owner = slot.metadata.player
	Mugshot = slot.metadata.mugshot
	TriggerServerEvent("mycroft_id:useID", Owner, Mugshot)
end)

exports('openWeaponLicence', function(data, slot)
    Owner = slot.metadata.player
	Mugshot = slot.metadata.mugshot
	TriggerServerEvent("mycroft_id:useWeaponID", Owner, Mugshot)
end)

exports('openDriverLicence', function(data, slot)
    Owner = slot.metadata.player
	Mugshot = slot.metadata.mugshot
	TriggerServerEvent("mycroft_id:useDriverID", Owner, Mugshot)
end)


RegisterNetEvent("mycroft_id:RegisterMugshot", function()
	local mug = exports["MugShotBase64"]:GetMugShotBase64(PlayerPedId(),true)

	TriggerServerEvent("mycroft_id:RecieveMugshot", mug)
end)

CreateThread(function()
	CreateNPC({
		model = "u_m_y_rsranger_01",
		animation = {
			dict = "mini@strip_club@idles@bouncer@base",
			lib = "base"
		},
		pos = vector4(-552.369202, -202.800003, 37.227051, 340.1)
	})
end)

RegisterNetEvent("mycroft_id:talkToNacy", function()
	if not ESX.PlayerLoaded then 
		return 
	end 
	local Coords = GetEntityCoords(ESX.PlayerData.ped)
	
	if #(Coords - vector3(-552.369202, -202.800003, 37.227051)) > 3.5 then 
		return 
	end 
	local Elements = {
		{
			title = "Nancy",
			icon = "far fa-comment",
			unselectable = true
		},
		{
			title = "Buy Id Card",
			description = "Buy a new Identity Card - $200",
			index = "idcard",
			icon = "far fa-id-card"
		}
	}

	exports["esx_context"]:Open("right", Elements, function(menu, element)
		if element.index == "idcard" then 
			ESX.TriggerServerCallback("mycroft_id:BuyIdCard", function(bought)
				if bought then 
					ESX.ShowNotification("Bought Id Card", "success")
					exports["esx_context"]:Close()
				else 
					ESX.ShowNotification("Cannot Afford Id Card", "error")
				end
			end)
		end
	end)
end)

function CreateNPC(NPC)
	local dict, anim = NPC.animation.dict, NPC.animation.lib
	RequestModel(joaat(NPC.model))
	while not HasModelLoaded(joaat(NPC.model)) do
		Wait(10)
	end
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
	    Wait(10)
	end
	local ped = CreatePed(4, joaat(NPC.model) , NPC.pos.xyz, 3374176, false, true)
	SetEntityHeading(ped, NPC.pos.w)
	FreezeEntityPosition(ped, true)
	SetEntityInvincible(ped, true)
	SetBlockingOfNonTemporaryEvents(ped, true)
	TaskPlayAnim(ped, dict, anim, 8.0, 0.0, -1, 1, 0, 0, 0, 0)
	exports.qtarget:AddEntityZone("Nacy", ped, {
		name="Nacy",
		debugPoly=true,
		useZ = true
			}, {
			options = {
				{
				event = "mycroft_id:talkToNacy",
				icon = "far fa-comment",
				label = "Talk to Nacy",
				},
			},
			distance = 2.5
		})  
end
