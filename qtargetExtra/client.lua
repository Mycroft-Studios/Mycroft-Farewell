RegisterNetEvent("client:giveContactInfo", function(info)
    exports.npwd:fillNewContact({ name = info.name, number = info.number})
end)
RegisterNetEvent("mycroft_extra:RegisterMugshot", function()
	local mug = exports["MugShotBase64"]:GetMugShotBase64(PlayerPedId(),true)

	TriggerServerEvent("mycroft_extra:RecieveMugshot", mug)
end)

ESX.RegisterInput("panic", "(Police): Panic", "keyboard", "F9", function()
    if ESX.PlayerData.job.name == "police" then 
        exports['al_mdt']:TriggerPanicButton()
    end
end)
-- Fast Thread
CreateThread(function()

    exports['qtarget']:Player({
        options = {
            {
                icon = "fas fa-id-card",
                label = "search",
                action = function(entity)
                    ESX.Streaming.RequestAnimDict("combat@aim_variations@arrest", function()
                        local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                        exports["progressBars"]:startUI(4000, "Robbing Player")
                        TaskPlayAnim(PlayerPedId(), "combat@aim_variations@arrest", "cop_med_arrest_01", 8.0, 8.0, 4000, 1, true, true, true)
                        Wait(4000)
                        exports.ox_inventory:openInventory('player', targetId)
                        TaskPlayAnim(PlayerPedId(), "combat@aim_variations@arrest", "cop_med_arrest_01", 8.0, 8.0, 3000, 1, true, true, true)
                    end)
                end,
                canInteract = function(entity)
                        local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                        print(ESX.DumpTable(Player(targetId).state))
                        return (Player(targetId).state.handsup) or false
                end
            }
        },
        distance = 3.0
    })

    exports['qtarget']:Player({
        options = {
            {
                icon = "fas fa-id-card",
                label = "Give Number",
                action = function(entity)
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                    TriggerServerEvent("esx-phone:giveContactInfo", targetId)
                end,
            }
        },
        distance = 3.0
    })
end)

local function TackleAnim()
    local ped = PlayerPedId()
    if not IsPedRagdoll(ped) then
        if not HasAnimDictLoaded("swimming@first_person@diving") then
            RequestAnimDict("swimming@first_person@diving")
            while not HasAnimDictLoaded("swimming@first_person@diving") do
                Wait(10)
            end
        end
        if IsEntityPlayingAnim(ped, "swimming@first_person@diving", "dive_run_fwd_-45_loop", 3) then
            ClearPedTasksImmediately(ped)
        else
            TaskPlayAnim(ped, "swimming@first_person@diving", "dive_run_fwd_-45_loop" ,3.0, 3.0, -1, 49, 0, false, false, false)
            Wait(250)
            ClearPedTasksImmediately(ped)
            SetPedToRagdoll(ped, 150, 150, 0, false, false, false)
        end
    end
end

local function Tackle()
    local closestPlayer, distance = ESX.Game.GetClosestPlayer()
    if distance ~= -1 and distance < 2 then
        ESX.TriggerServerCallback("tackle:server:TacklePlayer", function(success)
            if success then
                TackleAnim()
            end
        end, GetPlayerServerId(closestPlayer))
    end
end

RegisterCommand("tackle", function()
    if not ESX.PlayerLoaded then return end
    if not IsPedInAnyVehicle(ESX.PlayerData.ped, false) and GetEntitySpeed(ESX.PlayerData.ped) > 2.5 then
        Tackle()
    end
end, false)

RegisterKeyMapping("tackle", "Tackle", "keyboard", "G")

RegisterNetEvent('tackle:client:GetTackled', function()
	SetPedToRagdoll(ESX.PlayerData.ped, math.random(1000, 6000), math.random(1000, 6000), 0, false, false, false)
	TimerEnabled = true
	Wait(1500)
	TimerEnabled = false
end)