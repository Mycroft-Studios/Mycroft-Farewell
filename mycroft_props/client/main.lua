 local PropData = {}
function LoadPropDict(model)
	while not HasModelLoaded(GetHashKey(model)) do
	  RequestModel(GetHashKey(model))
	  Wait(10)
	end
  end

  function LoadAnim(dict)
	while not HasAnimDictLoaded(dict) do
	  RequestAnimDict(dict)
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

local UsingProp = false
local Prop = nil

function ToggleProp(data)
	local Ped = PlayerPedId()
	UsingProp = not UsingProp 
	LocalPlayer.state.UsingProp = UsingProp
	if not UsingProp then 
		ClearPedTasks(PlayerPedId())
		if Prop then
			DeleteEntity(Prop)
		end 
	else 
		if data.Type == "prop" then
			Prop = AddPropToPlayer(data.Prop, data.PropBone, data.PropPlacement[1], data.PropPlacement[2],data.PropPlacement[3],data.PropPlacement[4], data.PropPlacement[5], data.PropPlacement[6])
		elseif data.Type == "anim" then
			RequestAnimDict(data.anim.dict)
			while not HasAnimDictLoaded(data.anim.dict) do
				Wait(1)
			end
			TaskPlayAnim(PlayerPedId(), data.anim.dict, data.anim.name, data.anim.blendIn, data.anim.BlendOut, -1,data.anim.freezePlayer and 0 or 51, data.anim.freezePlayer, data.anim.freezePlayer, data.anim.freezePlayer)
		elseif data.Type == "scenario" then
			TaskStartScenarioInPlace(ESX.PlayerData.ped, data.scenario.name, data.scenario.delay, data.scenario.EnterAnim)
		elseif data.Type == "animProp" then
			Prop = AddPropToPlayer(data.Prop, data.PropBone, data.PropPlacement[1], data.PropPlacement[2],data.PropPlacement[3],data.PropPlacement[4], data.PropPlacement[5], data.PropPlacement[6])
			RequestAnimDict(data.anim.dict)
			while not HasAnimDictLoaded(data.anim.dict) do
				Wait(1)
			end
			TaskPlayAnim(PlayerPedId(), data.anim.dict, data.anim.name, data.anim.blendIn, data.anim.BlendOut, -1,data.anim.freezePlayer and 0 or 51, data.anim.freezePlayer, data.anim.freezePlayer, data.anim.freezePlayer)
			--TaskPlayAnim(PlayerPedId(), data.anim.dict, data.anim.name, 2.0, 2.0, data.anim.duration, -1, 0, false, false, false)
		end
	end
end

RegisterNetEvent("mycroft_props:UseProp", function(data)
	ToggleProp(data)
end)

RegisterCommand("clearprop" , function()
	if Prop then
		DeleteEntity(Prop)
	end 
	UsingProp = false
	LocalPlayer.state.UsingProp = UsingProp
	ClearPedTasks(PlayerPedId())
end)