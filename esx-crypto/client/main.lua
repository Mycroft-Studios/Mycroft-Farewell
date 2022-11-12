-- -- Functions
-- local function DrawText3Ds(coords, text)
--     SetTextScale(0.35, 0.35)
--     SetTextFont(4)
--     SetTextProportional(1)
--     SetTextColour(255, 255, 255, 215)
--     SetTextEntry("STRING")
--     SetTextCentre(true)
--     AddTextComponentString(text)
--     SetDrawOrigin(coords.x, coords.y, coords.z, 0)
--     DrawText(0.0, 0.0)
--     local factor = (string.len(text)) / 370
--     DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
--     ClearDrawOrigin()
-- end

-- local function ExchangeSuccess()
--     TriggerServerEvent('esx-crypto:server:ExchangeSuccess', math.random(1, 10))
-- end

-- local function ExchangeFail()
--     local Odd = 5
--     local RemoveChance = math.random(1, Odd)
--     local LosingNumber = math.random(1, Odd)
--     if RemoveChance == LosingNumber then
--         TriggerServerEvent('esx-crypto:server:ExchangeFail')
--         TriggerServerEvent('esx-crypto:server:SyncReboot')
--     end
-- end

-- local function SystemCrashCooldown()
--     CreateThread(function()
--         while Crypto.Exchange.RebootInfo.state do
--             if (Crypto.Exchange.RebootInfo.percentage + 1) <= 100 then
--                 Crypto.Exchange.RebootInfo.percentage = Crypto.Exchange.RebootInfo.percentage + 1
--                 TriggerServerEvent('esx-crypto:server:Rebooting', true, Crypto.Exchange.RebootInfo.percentage)
--             else
--                 Crypto.Exchange.RebootInfo.percentage = 0
--                 Crypto.Exchange.RebootInfo.state = false
--                 TriggerServerEvent('esx-crypto:server:Rebooting', false, 0)
--             end
--             Wait(1200)
--         end
--     end)
-- end

-- local function HackingSuccess(success)
--     if success then
--         TriggerEvent('mhacking:hide')
--         ExchangeSuccess()
--     else
--         TriggerEvent('mhacking:hide')
--         ExchangeFail()
--     end
-- end

-- CreateThread(function()
--     while true do
--         local sleep = 5000
--         if ESX.IsPlayerLoaded() then
--             local ped = PlayerPedId()
--             local pos = GetEntityCoords(ped)
--             local dist = #(pos - Crypto.Exchange.coords)
--             if dist < 15 then
--                 sleep = 5
--                 if dist < 1.5 then
--                     if not Crypto.Exchange.RebootInfo.state then
--                         DrawText3Ds(Crypto.Exchange.coords, '~g~E~w~ - Enter USB')

--                         if IsControlJustPressed(0, 38) then
--                             ESX.TrigerServerCallback('esx-crypto:server:HasSticky', function(HasItem)
--                                 if HasItem then
--                                     TriggerEvent("mhacking:show")
--                                     TriggerEvent("mhacking:start", math.random(4, 6), 45, HackingSuccess)
--                                 else
--                                     ESX.ShowNotification('You have no Cryptostick', 'error')
--                                 end
--                             end)
--                         end
--                     else
--                         DrawText3Ds(Crypto.Exchange.coords,
--                             'Systeem is rebooting - ' .. Crypto.Exchange.RebootInfo.percentage .. '%')
--                     end
--                 end
--             end
--         end
--         Wait(sleep)
--     end
-- end)

-- Events

-- RegisterNetEvent('esx-crypto:client:SyncReboot', function()
--     Crypto.Exchange.RebootInfo.state = true
--     SystemCrashCooldown()
-- end)

RegisterNetEvent('esx:playerLoaded', function()
    TriggerServerEvent('esx-crypto:server:FetchWorth')
    TriggerServerEvent('esx-crypto:server:GetRebootState')
end)

RegisterNetEvent('esx-crypto:client:UpdateCryptoWorth', function(crypto, amount, history)
    Crypto.Worth[crypto] = amount
    if history ~= nil then
        Crypto.History[crypto] = history
    end
end)

-- RegisterNetEvent('esx-crypto:client:GetRebootState', function(RebootInfo)
--     if RebootInfo.state then
--         Crypto.Exchange.RebootInfo.state = RebootInfo.state
--         Crypto.Exchange.RebootInfo.percentage = RebootInfo.percentage
--         SystemCrashCooldown()
--     end
-- end)
