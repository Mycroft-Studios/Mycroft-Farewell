local PlayerPedId = PlayerPedId
local GetVehiclePedIsIn = GetVehiclePedIsIn
local CreateThread = CreateThread
local SetVehicleEngineOn = SetVehicleEngineOn
local IsControlJustPressed = IsControlJustPressed
local SetVehicleUndriveable = SetVehicleUndriveable
local IsPedInAnyVehicle = IsPedInAnyVehicle
local GetEntityCoords = GetEntityCoords
local World3dToScreen2d = World3dToScreen2d

local GetGameplayCamCoords = GetGameplayCamCoords
local SetTextScale = SetTextScale
local SetTextFont = SetTextFont
local SetTextProportional = SetTextProportional
local SetTextColour = SetTextColour
local SetTextEntry = SetTextEntry
local SetTextCentre = SetTextCentre
local AddTextComponentString = AddTextComponentString
local DrawText = DrawText
local DrawRect = DrawRect
local IsHotwiring = false


function DrawText3Ds(x, y, z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local factor = #text / 460
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	
	SetTextScale(0.3, 0.3)
	SetTextFont(6)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 160)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	DrawRect(_x,_y + 0.0115, 0.02 + factor, 0.027, 28, 28, 28, 95)
end
local PressedTime = 0
CreateThread(function()
    while true do 
        local Sleep = 1500
        local Ped = ESX.PlayerData.ped
        local IsIn = IsPedInAnyVehicle(Ped)
        if IsIn then 
            local Vehicle = GetVehiclePedIsIn(Ped, false)
            Sleep = 0
            local EntityState = Entity(Vehicle).state
            local hasBeenSearched = EntityState.searched

            if (EntityState.keys and EntityState.locked ~= nil) or EntityState.hotwired or EntityState.SecondHand then
                if (EntityState.keys[ESX.PlayerData.identifier] or EntityState.hotwired) then
                    if IsControlPressed(0, 23) then
                        PressedTime += 1 
                    else 
                        PressedTime = 0 
                    end 
                    --SetVehicleEngineOn(Vehicle, true, false, true)
                    SetVehicleUndriveable(Vehicle, false)
                    if PressedTime > 20 then
                        SetVehicleEngineOn(Vehicle, true, true, true)
                    elseif PressedTime > 1 then
                        SetVehicleEngineOn(Vehicle, false, false, true)
                    end
                else
                    local Pos = GetEntityCoords(Vehicle)
                    DrawText3Ds(Pos.x, Pos.y, Pos.z, 'Press ~y~H~w~ to hotwire')
                    if IsControlJustPressed(0, 74) and not IsHotwiring then
                        ESX.ShowNotification("hotwiring Player Car!", "success")
                        RequestAnimDict("veh@std@ds@base")
                        
                            while not HasAnimDictLoaded("veh@std@ds@base") do
                                Wait(100)
                            end
                        
                            SetVehicleLights(Vehicle, 0)
                            TaskPlayAnim(Ped, "veh@std@ds@base", "hotwire", 8.0, 8.0, -1, 1, 0.3, true, true, true)
                            exports["progressBars"]:startUI(3000, "Hotwiring Vehicle")
                            Wait(3000)
                            ClearPedTasks(Ped)
                            if exports["k5_skillcheck"]:skillCheck("easy") then 
                                if exports["k5_skillcheck"]:skillCheck("normal") then
                                    if exports["k5_skillcheck"]:skillCheck("normal") then
                                        ESX.ShowNotification("Succesfully Lockpicked!")

                                        ESX.TriggerServerCallback("mycroft_keys:Hotwire", function(HotWired)
                                            if HotWired then
                                                IsHotwiring = false
                                                SetVehicleEngineOn(Vehicle, true, true, true)
                                                SetVehicleUndriveable(Vehicle, false)
                                            end
                                        end)
                                    else 
                                        IsHotwiring = false
                                        ESX.ShowNotification("Failed Lockpicking!")
                                        SetVehicleAlarm(Vehicle, true)
                                        StartVehicleAlarm(Vehicle)
                                    end
                                else
                                    IsHotwiring = false
                                    ESX.ShowNotification("Failed Lockpicking!")
                                    SetVehicleAlarm(Vehicle, true)
                                    StartVehicleAlarm(Vehicle)
                                end
                            else 
                                IsHotwiring = false
                                ESX.ShowNotification("Failed Lockpicking!")
                                SetVehicleAlarm(Vehicle, true)
                                StartVehicleAlarm(Vehicle)
                            end
                    end
                    SetVehicleEngineOn(Vehicle, false, true, true)
                    SetVehicleUndriveable(Vehicle, true)
                end
            else
                local Pos = GetEntityCoords(Vehicle)
                Sleep = 0
                DrawText3Ds(Pos.x, Pos.y, Pos.z, hasBeenSearched and 'Press ~y~H~w~ to hotwire' or 'Press ~y~H~w~ to hotwire or ~g~G~w~ to search')
                if IsControlJustPressed(0, 74) and not IsHotwiring then
                    ESX.TriggerServerCallback("mycroft_keys:CanLockpick", function(can)
                        if can then
                            IsHotwiring = true
                            ESX.ShowNotification("hotwiring NPC Car!", "success")
                            RequestAnimDict("veh@std@ds@base")
                        
                            while not HasAnimDictLoaded("veh@std@ds@base") do
                                Wait(100)
                            end
                        
                            SetVehicleLights(Vehicle, 0)
                                local alarmChance = math.random(1, 100)
                                if alarmChance <= 30 then

                                end
                            TaskPlayAnim(Ped, "veh@std@ds@base", "hotwire", 8.0, 8.0, -1, 1, 0.3, true, true, true)
                            exports["progressBars"]:startUI(3000, "Hotwiring Vehicle")
                            Wait(3000)
                            ClearPedTasks(Ped)
                            if exports["k5_skillcheck"]:skillCheck("easy") then 
                                if exports["k5_skillcheck"]:skillCheck("normal") then
                                    if exports["k5_skillcheck"]:skillCheck("normal") then
                                        ESX.ShowNotification("Succesfully Lockpicked!")

                                        ESX.TriggerServerCallback("mycroft_keys:Hotwire", function(HotWired)
                                            if HotWired then
                                                IsHotwiring = false
                                                SetVehicleEngineOn(Vehicle, true, true, true)
                                                SetVehicleUndriveable(Vehicle, false)
                                            end
                                        end)
                                    else 
                                        IsHotwiring = false
                                        ESX.ShowNotification("Failed Lockpicking!")
                                        SetVehicleAlarm(Vehicle, true)
                                        StartVehicleAlarm(Vehicle)
                                    end
                                else
                                    IsHotwiring = false
                                    ESX.ShowNotification("Failed Lockpicking!")
                                    SetVehicleAlarm(Vehicle, true)
                                    StartVehicleAlarm(Vehicle)
                                end
                            else 
                                IsHotwiring = false
                                ESX.ShowNotification("Failed Lockpicking!")
                                SetVehicleAlarm(Vehicle, true)
                                StartVehicleAlarm(Vehicle)
                            end
                        else
                            ESX.ShowNotification("You Are Missing A lockpick!", "error")
                        end
                    end)
                end

                if IsControlJustPressed(0 ,113) and not IsHotwiring and not hasBeenSearched then
                    CreateThread(function()
                        exports["progressBars"]:startUI(3000, "Searching Vehicle")
                        Wait(3000)
                        TriggerServerEvent("mycroft_keys:search")
                    end)
                end
                SetVehicleEngineOn(Vehicle, false, true, true)
                SetVehicleUndriveable(Vehicle, true)
            end
        end
    Wait(Sleep)
    end
end)


RegisterNetEvent("mycroft:Keys:ToggleLock", function(vehId, toggle)
    local Vehicle = NetworkGetEntityFromNetworkId(vehId)
    local tries = 0
    while not DoesEntityExist(Vehicle) do 
        Vehicle = NetworkGetEntityFromNetworkId(vehId)
        tries += 1
        if tries > 30 then 
            break
        end
        Wait(0)
    end
    SetVehicleDoorsLocked(Vehicle, toggle and 2 or 1)
    SetVehicleDoorsLockedForAllPlayers(Vehicle, toggle)
end)


local PlayerId = PlayerId
local GetEntityPlayerIsFreeAimingAt = GetEntityPlayerIsFreeAimingAt

CreateThread(function()
    while true do
        local Pid = PlayerId()
        local foundEnt, aimingEnt = GetEntityPlayerIsFreeAimingAt(Pid)
        local Sleep = 500
        local entPos = GetEntityCoords(aimingEnt)
        local pos = GetEntityCoords(ESX.PlayerData.ped)
        local dist = #(pos - entPos)
        local DrivingPed = GetPedInVehicleSeat(GetVehiclePedIsIn(aimingEnt, false), -1)
        if foundEnt and prevPed ~= aimingEnt and IsPedInAnyVehicle(aimingEnt, false) and DrivingPed == aimingEnt and IsPedArmed(ESX.PlayerData.ped, 7) and dist < 20.0 and not IsPedInAnyVehicle(ESX.PlayerData.ped) then
            Sleep = 0

            DrawText3Ds(entPos.x, entPos.y, entPos.z, 'Press ~y~[E]~w~ to rob')
            if not IsPedAPlayer(aimingEnt) then
                prevPed = aimingEnt
                Wait(math.random(300, 700))
                local dict = "random@mugging3"
                RequestAnimDict(dict)
                while not HasAnimDictLoaded(dict) do
                    Wait(0)
                end
                local rand = math.random(10)

                if rand > 4 then
                    prevCar = GetVehiclePedIsIn(aimingEnt, false)
                    TaskLeaveVehicle(aimingEnt, prevCar)
                    SetVehicleEngineOn(prevCar, false, false, false)
                    
                    while IsPedInAnyVehicle(aimingEnt, false) do
                        Wait(0)
                    end
                    SetBlockingOfNonTemporaryEvents(aimingEnt, true)
                    ClearPedTasksImmediately(aimingEnt)
                    TaskPlayAnim(aimingEnt, dict, "handsup_standing_base", 8.0, -8.0, 0.01, 49, 0, 0, 0, 0)
                    ResetPedLastVehicle(aimingEnt)
                    TaskWanderInArea(aimingEnt, 0, 0, 0, 20, 100, 100)
                    exports.progressBars:startUI(3000, "Stealing Keys")
                    Wait(3000)
                            ESX.ShowNotification("Successfully Stolen Keys!", "success")
                            TriggerServerEvent("mycroft_Keys:GiveKeys", NetworkGetNetworkIdFromEntity(prevCar))
                        ClearPedTasks(aimingEnt)
                        TaskWanderInArea(aimingEnt, 0, 0, 0, 20, 100, 100)
                        SetEntityAsNoLongerNeeded(aimingEnt)
                end
            end
        end
        Wait(Sleep)
    end
end)

exports("givekeys", function(VehId)
    ESX.TriggerServerCallback("mycroft_keys:GiveKeys", function(Gave)
        if not Gave then 
            ESX.ShowNotification("Invalid Vehicle Found while Giving Keys!", "warning")
        end
    end, VehId)
end)

exports("givekeysToPlayer", function(VehId, Player)
    ESX.TriggerServerCallback("mycroft_keys:GiveKeysToPlayer", function(Gave)
        print(Gave)
        if Gave then 
            ESX.ShowNotification("You Have Given a pair of keys!", "success")
        else 
            ESX.ShowNotification("Cannot Give Keys!", "error")
        end
    end, VehId, Player)
end)


ESX.RegisterInput("carlock", "(Vehicle Lock) Toggle Lock", "keyboard", "L", function()
    ESX.TriggerServerCallback("mycroft_keys:ToggleLock", function(Toggled, state)
        if Toggled then 
            ESX.ShowNotification(state .. " Vehicle!", "success")
        else 
            ESX.ShowNotification("Cannot Toggle Lock!", "error")
        end
    end)
end)

exports("lockVehicle", function(VehId)
    ESX.TriggerServerCallback("mycroft_keys:LockVehicle", function(Gave)
        if Gave then 
            ESX.ShowNotification("Locked Vehicle!", "success")
        else 
            ESX.ShowNotification("Cannot Lock Vehicle!", "error")
        end
    end, VehId)
end)

exports("unlockVehicle", function(VehId)
    ESX.TriggerServerCallback("mycroft_keys:UnLockVehicle", function(Gave)
        if Gave then 
            ESX.ShowNotification("Unlocked Vehicle!", "success")
        else 
            ESX.ShowNotification("Cannot Unlock Vehicle!", "error")
        end
    end, VehId)
end)