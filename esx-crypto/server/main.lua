-- Variables
local coin = Crypto.Coin
local bannedCharacters = {'%', '$', ';'}

-- Function
local function RefreshCrypto()
    local result = MySQL.Sync.fetchAll('SELECT * FROM crypto WHERE crypto = ?', {coin})
    if result ~= nil and result[1] ~= nil then
        Crypto.Worth[coin] = result[1].worth
        if result[1].history ~= nil then
            Crypto.History[coin] = json.decode(result[1].history)
            TriggerClientEvent('esx-crypto:client:UpdateCryptoWorth', -1, coin, result[1].worth,
                json.decode(result[1].history))
        else
            TriggerClientEvent('esx-crypto:client:UpdateCryptoWorth', -1, coin, result[1].worth)
        end
    end
end

local function ErrorHandle(error)
    for k, v in pairs(Ticker.Error_handle) do
        if string.match(error, k) then
            return v
        end
    end
    return false
end

local function GetTickerPrice() -- Touch = no help
    local ticker_promise = promise.new()
    PerformHttpRequest("https://min-api.cryptocompare.com/data/price?fsym=" .. Ticker.coin .. "&tsyms=" ..
                           Ticker.currency .. '&api_key=' .. Ticker.Api_key, function(Error, Result, _)
        local result_obj = json.decode(Result)
        if not result_obj['Response'] then
            local this_resolve = {
                error = Error,
                response_data = result_obj[string.upper(Ticker.currency)]
            }
            ticker_promise:resolve(this_resolve) --- Could resolve Error aswell for more accurate Error messages? Solved in else
        else
            local this_resolve = {
                error = result_obj['Message']
            }
            ticker_promise:resolve(this_resolve)
        end
    end, 'GET')
    Citizen.Await(ticker_promise)
    if type(ticker_promise.value.error) ~= 'number' then
        local get_user_friendly_error = ErrorHandle(ticker_promise.value.error)
        if get_user_friendly_error then
            return get_user_friendly_error
        else
            return '\27[31m Unexpected error \27[0m' --- Raised an error which we did not expect, script should be capable of sticking with last recorded price and shutting down the sync logic
        end
    else
        return ticker_promise.value.response_data
    end
end

local function HandlePriceChance()
    local currentValue = Crypto.Worth[coin]
    local prevValue = Crypto.Worth[coin]
    local trend = math.random(0, 100)
    local event = math.random(0, 100)
    local chance = event - Crypto.ChanceOfCrashOrLuck

    if event > chance then
        if trend <= Crypto.ChanceOfDown then
            currentValue = currentValue - math.random(Crypto.CasualDown[1], Crypto.CasualDown[2])
        elseif trend >= Crypto.ChanceOfUp then
            currentValue = currentValue + math.random(Crypto.CasualUp[1], Crypto.CasualUp[2])
        end
    else
        if math.random(0, 1) == 1 then
            currentValue = currentValue + math.random(Crypto.Luck[1], Crypto.Luck[2])
        else
            currentValue = currentValue - math.random(Crypto.Crash[1], Crypto.Crash[2])
        end
    end

    if currentValue <= Crypto.Lower then
        currentValue = Crypto.Lower
    elseif currentValue >= Crypto.Upper then
        currentValue = Crypto.Upper
    end

    if Crypto.History[coin][4] then
        Crypto.History[coin][1] = {
            PreviousWorth = prevValue,
            NewWorth = currentValue
        }
    else
        Crypto.History[coin][#Crypto.History[coin] + 1] = {
            PreviousWorth = prevValue,
            NewWorth = currentValue
        }
    end

    Crypto.Worth[coin] = currentValue

    MySQL.Async.insert(
        'INSERT INTO crypto (worth, history) VALUES (:worth, :history) ON DUPLICATE KEY UPDATE worth = :worth, history = :history',
        {
            ['worth'] = currentValue,
            ['history'] = json.encode(Crypto.History[coin])
        })
    RefreshCrypto()
end

-- Commands

ESX.RegisterCommand('setcryptoworth', 'admin', function(xPlayer, args, showError)
    local crypto = args.crypto

    if crypto then
        if Crypto.Worth[crypto] then
            local NewWorth = math.ceil(args.value)

            if NewWorth then
                local PercentageChange = math.ceil(((NewWorth - Crypto.Worth[crypto]) / Crypto.Worth[crypto]) * 100)
                local ChangeLabel = "+"

                if PercentageChange < 0 then
                    ChangeLabel = "-"
                    PercentageChange = (PercentageChange * -1)
                end

                if Crypto.Worth[crypto] == 0 then
                    PercentageChange = 0
                    ChangeLabel = ""
                end

                Crypto.History[crypto][#Crypto.History[crypto] + 1] = {
                    PreviousWorth = Crypto.Worth[crypto],
                    NewWorth = NewWorth
                }

                xPlayer.showNotification("You have the value of " .. Crypto.Labels[crypto] .. "adapted from: ($" ..
                                             Crypto.Worth[crypto] .. " to: $" .. NewWorth .. ") (" .. ChangeLabel .. " " ..
                                             PercentageChange .. "%)")
                Crypto.Worth[crypto] = NewWorth
                TriggerClientEvent('esx-crypto:client:UpdateCryptoWorth', -1, crypto, NewWorth)
                MySQL.Async.insert(
                    'INSERT INTO crypto (worth, history) VALUES (:worth, :history) ON DUPLICATE KEY UPDATE worth = :worth, history = :history',
                    {
                        ['worth'] = NewWorth,
                        ['history'] = json.encode(Crypto.History[crypto])
                    })
            else
                xPlayer.showNotification("You have not given a new value .. Current values: " .. Crypto.Worth[crypto])
            end
        else
            xPlayer.showNotification("This Crypto does not exist :(, available: Lux Coin")
        end
    else
        xPlayer.showNotification("You have not provided Crypto, available: Lux Coin")
    end
end, false, {
    help = "Set crypto value",
    validate = true,
    arguments = {{
        name = 'crypto',
        help = "Name of the crypto currency",
        type = 'string'
    }, {
        name = 'value',
        help = "New value of the crypto currency",
        type = 'number'
    }}
})

ESX.RegisterCommand('checkcryptoworth', 'admin', function(xPlayer, args, showError)
    xPlayer.showNotification("The Lux Coin has a value of: $" .. Crypto.Worth["Lux Coin"])
end, false)

-- Events
RegisterServerEvent('esx-crypto:server:FetchWorth', function()
    for name, _ in pairs(Crypto.Worth) do
        local result = MySQL.Sync.fetchAll('SELECT * FROM crypto WHERE crypto = ?', {name})
        if result[1] ~= nil then
            Crypto.Worth[name] = result[1].worth
            if result[1].history ~= nil then
                Crypto.History[name] = json.decode(result[1].history)
                TriggerClientEvent('esx-crypto:client:UpdateCryptoWorth', -1, name, result[1].worth,
                    json.decode(result[1].history))
            else
                TriggerClientEvent('esx-crypto:client:UpdateCryptoWorth', -1, name, result[1].worth, nil)
            end
        end
    end
end)

RegisterServerEvent('esx-crypto:server:ExchangeFail', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local ItemData = xPlayer.getInventoryItem("cryptostick").count

    if ItemData >= 1 then
        xPlayer.removeItem("cryptostick", 1)
        xPlayer.showNotification("Cryptostick malfunctioned", 'error')
    end
end)

RegisterServerEvent('esx-crypto:server:Rebooting', function(state, percentage)
    Crypto.Exchange.RebootInfo.state = state
    Crypto.Exchange.RebootInfo.percentage = percentage
end)

RegisterServerEvent('esx-crypto:server:GetRebootState', function()
    local src = source
    TriggerClientEvent('esx-crypto:client:GetRebootState', src, Crypto.Exchange.RebootInfo)
end)

RegisterServerEvent('esx-crypto:server:SyncReboot', function()
    TriggerClientEvent('esx-crypto:client:SyncReboot', -1)
end)

RegisterServerEvent('esx-crypto:server:ExchangeSuccess', function(LuckChance)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local ItemData = xPlayer.getInventoryItem("cryptostick").count

    if ItemData >= 1 then
        local LuckyNumber = math.random(1, 10)
        local DeelNumber = 1000000
        local Amount = (math.random(611111, 1599999) / DeelNumber)
        if LuckChance == LuckyNumber then
            Amount = (math.random(1599999, 2599999) / DeelNumber)
        end

        xPlayer.removeInventoryItem("cryptostick", 1)
        xPlayer.addMoney('crypto', Amount)
        xPlayer.showNotification("You have exchanged your Cryptostick for: " .. Amount .. " Lux Coin(\'s)")
        TriggerClientEvent('esx-phone:client:AddTransaction', src, xPlayer, {},
            "There are " .. Amount .. " Lux Coin('s) credited!", "Credit")
    end
end)

-- Callbacks

ESX.RegisterServerCallback('esx-crypto:server:HasSticky', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local Item = xPlayer.getInventoryItem("cryptostick").count

    if Item >= 1 then
        cb(true)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('esx-crypto:server:GetCryptoData', function(source, cb, name)
    local xPlayer = ESX.GetPlayerFromId(source)
    local WalletId = xPlayer.get("WalletId")
    local CryptoData = {
        History = Crypto.History[name],
        WalletId = WalletId,
        Worth = Crypto.Worth[name],
        Portfolio = xPlayer.getAccount("crypto").money,
    }
    print(WalletId)
    print(CryptoData["WalletId"])
    cb(CryptoData)
end)

ESX.RegisterServerCallback('esx-crypto:server:BuyCrypto', function(source, cb, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    print(ESX.DumpTable(data))
    local total_price = tonumber(data.Coins) * tonumber(Crypto.Worth["Lux Coin"])
    if xPlayer.getAccount("bank").money >= total_price then
        local CryptoData = {
            History = Crypto.History["Lux Coin"],
            Worth = Crypto.Worth["Lux Coin"],
            Portfolio = xPlayer.getAccount("crypto").money + tonumber(data.Coins),
            WalletId = xPlayer.get("WalletId")
        }
        xPlayer.removeAccountMoney('bank', total_price)
        TriggerClientEvent('esx-phone:client:AddTransaction', source, xPlayer, data,
            "You have " .. tonumber(data.Coins) .. " Lux Coin('s) purchased!", "Credit")
        xPlayer.addAccountMoney('crypto', tonumber(data.Coins))
        cb(CryptoData)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('esx-crypto:server:SellCrypto', function(source, cb, data)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getAccount("crypto").money >= tonumber(data.Coins) then
        local CryptoData = {
            History = Crypto.History["Lux Coin"],
            Worth = Crypto.Worth["Lux Coin"],
            Portfolio = xPlayer.getAccount("crypto").money - tonumber(data.Coins),
            WalletId = xPlayer.get("WalletId")
        }
        xPlayer.removeAccountMoney('crypto', tonumber(data.Coins))
        TriggerClientEvent('esx-phone:client:AddTransaction', source, Player, data,
            "You have " .. tonumber(data.Coins) .. " Lux Coin('s) sold!", "Depreciation")
        xPlayer.addAccountMoney('bank', tonumber(data.Coins) * tonumber(Crypto.Worth["Lux Coin"]))
        cb(CryptoData)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('esx-crypto:server:TransferCrypto', function(source, cb, data)
    local newCoin = tostring(data.Coins)
    local newWalletId = tostring(data.WalletId)
    for _, v in pairs(bannedCharacters) do
        newCoin = string.gsub(newCoin, '%' .. v, '')
        newWalletId = string.gsub(newWalletId, '%' .. v, '')
    end
    data.WalletId = newWalletId
    data.Coins = tonumber(newCoin)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getAccount('crypto').money >= tonumber(data.Coins) then
        local result = MySQL.Sync.fetchAll('SELECT * FROM `users` WHERE `walletid` = ?', {data.WalletId})
        if result[1] then
            local CryptoData = {
                History = Crypto.History["Lux Coin"],
                Worth = Crypto.Worth["Lux Coin"],
                Portfolio = xPlayer.getAccount("crypto").money - tonumber(data.Coins),
                WalletId = xPlayer.get("WalletId")
            }
            xPlayer.removeAccountMoney('crypto', tonumber(data.Coins))
            TriggerClientEvent('esx-phone:client:AddTransaction', source, xPlayer, data,
                "You have " .. tonumber(data.Coins) .. " Lux Coin('s) transferred!", "Depreciation")
            local Target = ESX.GetPlayerFromIdentifier(result[1].identifier)

            if Target then
                Target.addAccountMoney('crypto', tonumber(data.Coins))
                TriggerClientEvent('esx-phone:client:AddTransaction', Target.source, xPlayer, data,
                    "There are " .. tonumber(data.Coins) .. " Lux Coin('s) credited!", "Credit")
            else
                local MoneyData = json.decode(result[1].accounts)
                MoneyData.crypto = MoneyData.crypto + tonumber(data.Coins)
                MySQL.Async.execute('UPDATE users SET accounts = ? WHERE identifier = ?',
                    {json.encode(MoneyData), result[1].identifier})
            end
            cb(CryptoData)
        else
            cb("notvalid")
        end
    else
        cb("notenough")
    end
end)

-- Threads

CreateThread(function()
    RefreshCrypto()
    Wait(2000)
    while true do
        Wait(Crypto.RefreshTimer * 60000)
        HandlePriceChance()
    end
end)

-- You touch = you break
if Ticker.Enabled then
    Citizen.CreateThread(function()
        local Interval = Ticker.tick_time * 60000
        if Ticker.tick_time < 2 then
            Interval = 120000
        end
        while (true) do
            local get_coin_price = GetTickerPrice()
            if type(get_coin_price) == 'number' then
                Crypto.Worth["Lux Coin"] = get_coin_price
            else
                print('\27[31m' .. get_coin_price .. '\27[0m')
                Ticker.Enabled = false
                break
            end
            Citizen.Wait(Interval)
        end
    end)
end
