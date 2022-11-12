local Phone = {}
local Tweets = {}
local AppAlerts = {}
local MentionedTweets = {}
local Hashtags = {}
local Calls = {}
local Adverts = {}
local GeneratedPlates = {}
local WebHook = "https://discord.com/api/webhooks/975080672920223764/N04jRm2bFQEIbrevdAkdSbn5EpI0xNm8w5mIPtCkv5XfjlZWXVnrVcct90FuPCSvF8hk"
local bannedCharacters = {'%','$',';'}

-- Functions
local function GetPlayerByPhone(number)
    local players = MySQL.Sync.fetchAll('SELECT * FROM users')
    for k,v in pairs(players) do
        if v.phone_number == number then 
            return ESX.GetPlayerFromIdentifier(v.identifier)
        end
    end
end


function CreateWalletId()
    local UniqueFound = false
    local WalletId = 'LC-' .. math.random(11111111, 99999999)
    return WalletId
end

function getPhoneRandomNumber()
    return tonumber('0' .. math.random(600000000,699999999))
end

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier',{
      ['@identifier'] = xPlayer.identifier
    }, function(result)
        if result[1].phone_number then
            local phoneNumber = result[1].phone_number
            xPlayer.set('phone_number', phoneNumber)
        else 
            local phoneNumber = getPhoneRandomNumber()
            MySQL.Async.insert("UPDATE users SET phone_number = @myPhoneNumber WHERE identifier = @identifier", { 
                ['@myPhoneNumber'] = phoneNumber,
                ['@identifier'] = xPlayer.identifier
            }, function ()
                print("creating number:"..phoneNumber)
            end)
            xPlayer.set('phone_number', phoneNumber)
        end
        if result[1].walletid then
            local WalletId = result[1].walletid
            xPlayer.set('WalletId', WalletId)
        else 
            local WalletId = CreateWalletId()
            MySQL.Async.insert("UPDATE users SET walletid = @walletid WHERE identifier = @identifier", { 
                ['@walletid'] = WalletId,
                ['@identifier'] = xPlayer.identifier
            }, function ()
            end)
            xPlayer.set('WalletId', WalletId)
        end
        if result[1].metadata then
            local metadata = json.decode(result[1].metadata)
            xPlayer.set('phonedata', metadata)
        else 
            local metadata = {}
            xPlayer.set('phonedata', metadata)
        end
    end)
end)

local function GetOnlineStatus(number)
    local Target = GetPlayerByPhone(number)
    local retval = false
    if Target then
        retval = true
    end
    return retval
end

local function GenerateMailId()
    return math.random(111111, 999999)
end

local function escape_sqli(source)
    local replacements = {
        ['"'] = '\\"',
        ["'"] = "\\'"
    }
    return source:gsub("['\"]", replacements)
end

local function round(num, numDecimalPlaces)
    if numDecimalPlaces and numDecimalPlaces > 0 then
        local mult = 10 ^ numDecimalPlaces
        return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end

function Phone.AddMentionedTweet(citizenid, TweetData)
    if MentionedTweets[citizenid] == nil then
        MentionedTweets[citizenid] = {}
    end
    MentionedTweets[citizenid][#MentionedTweets[citizenid]+1] = TweetData
end

function Phone.SetPhoneAlerts(citizenid, app, alerts)
    if citizenid ~= nil and app ~= nil then
        if AppAlerts[citizenid] == nil then
            AppAlerts[citizenid] = {}
            if AppAlerts[citizenid][app] == nil then
                if alerts == nil then
                    AppAlerts[citizenid][app] = 1
                else
                    AppAlerts[citizenid][app] = alerts
                end
            end
        else
            if AppAlerts[citizenid][app] == nil then
                if alerts == nil then
                    AppAlerts[citizenid][app] = 1
                else
                    AppAlerts[citizenid][app] = 0
                end
            else
                if alerts == nil then
                    AppAlerts[citizenid][app] = AppAlerts[citizenid][app] + 1
                else
                    AppAlerts[citizenid][app] = AppAlerts[citizenid][app] + 0
                end
            end
        end
    end
end

local function SplitStringToArray(string)
    local retval = {}
    for i in string.gmatch(string, "%S+") do
        retval[#retval+1] = i
    end
    return retval
end

-- Callbacks

ESX.RegisterServerCallback('esx-phone:server:GetCallState', function(source, cb, ContactData)
     local Target = GetPlayerByPhone(ContactData.number)
    if Target then
        if Calls[Target.source] then
            if Calls[Target.source].inCall then
                cb(false, true)
            else
                cb(true, true)
            end
        else
            cb(true, true)
        end
    else
        cb(false, false)
    end
end)

RegisterNetEvent("esx-phone:giveContactInfo", function(target)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)

    TriggerClientEvent("esx-phone:client:AddNewSuggestion", target, {name = xPlayer.getName(), number = xPlayer.get("phone_number")})
end)

-- ESX.RegisterServerCallback('GetContactInfo', function(source, cb, Target)
--     local target = ESX.GetPlayerFromId(Target)
--     cb({name = target.getName(), number = target.get("phone_number")})
-- end)

ESX.RegisterServerCallback('esx-phone:server:GetPhoneData', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.phone_number = xPlayer.get("phone_number")
        local PhoneData = {
            Applications = {},
            PlayerContacts = {},
            MentionedTweets = {},
            Chats = {},
            Hashtags = {},
            Invoices = {},
            Mails = {},
            Adverts = {},
            CryptoTransactions = {},
            Tweets = {},
            Images = {},
            InstalledApps = {}
        }
        PhoneData.Adverts = Adverts
        local result = MySQL.Sync.fetchAll('SELECT * FROM player_contacts WHERE citizenid = ? ORDER BY name ASC', {xPlayer.identifier})
        local Contacts = {}
        if result[1] ~= nil then
            for k, v in pairs(result) do
                v.status = GetOnlineStatus(v.number)
            end

            PhoneData.PlayerContacts = result
        end
        local messages = MySQL.Sync.fetchAll('SELECT * FROM phone_messages WHERE citizenid = ?', {xPlayer.identifier})
        if messages ~= nil and next(messages) ~= nil then
            PhoneData.Chats = messages
        end
        print(xPlayer.identifier)
        if AppAlerts[xPlayer.identifier] ~= nil then
            PhoneData.Applications = AppAlerts[xPlayer.identifier]
        end

        if MentionedTweets[xPlayer.identifier] ~= nil then
            PhoneData.MentionedTweets = MentionedTweets[xPlayer.identifier]
        end

        if Hashtags ~= nil and next(Hashtags) ~= nil then
            PhoneData.Hashtags = Hashtags
        end

        local Tweets = MySQL.Sync.fetchAll('SELECT * FROM phone_tweets WHERE `date` > NOW() - INTERVAL ? hour', {Config.TweetDuration})

        if Tweets ~= nil and next(Tweets) ~= nil then
            PhoneData.Tweets = Tweets
            TWData = Tweets
        end

        local mails = MySQL.Sync.fetchAll('SELECT * FROM player_mails WHERE citizenid = ? ORDER BY `date` ASC', {xPlayer.identifier})
        if mails[1] ~= nil then
            for k, v in pairs(mails) do
                if mails[k].button ~= nil then
                    mails[k].button = json.decode(mails[k].button)
                end
            end
            PhoneData.Mails = mails
        end

        local transactions = MySQL.Sync.fetchAll('SELECT * FROM crypto_transactions WHERE citizenid = ? ORDER BY `date` ASC', {xPlayer.identifier})
        if transactions[1] ~= nil then
            for _, v in pairs(transactions) do
                PhoneData.CryptoTransactions[#PhoneData.CryptoTransactions+1] = {
                    TransactionTitle = v.title,
                    TransactionMessage = v.message
                }
            end
        end

        local images = MySQL.Sync.fetchAll('SELECT * FROM phone_gallery WHERE citizenid = ? ORDER BY `date` DESC',{xPlayer.identifier})
        if images ~= nil and next(images) ~= nil then
            PhoneData.Images = images
        end

        local metadata = MySQL.Sync.fetchAll('SELECT metadata FROM users WHERE identifier = ?',{xPlayer.identifier})
        if metadata then
            PhoneData.metadata = json.decode(metadata[1].metadata)
            print(ESX.DumpTable(PhoneData.metadata))
        end

        cb(PhoneData, xPlayer)
end)

-- ESX.RegisterServerCallback('esx-phone:server:PayInvoice', function(source, cb, society, amount, invoiceId, sendercitizenid)
--     local Invoices = {}
--     local Ply = QBCore.Functions.GetPlayer(source)
--     local SenderPly = QBCore.Functions.GetPlayerByCitizenId(sendercitizenid)
--     local invoiceMailData = {}
--     if SenderPly and Config.BillingCommissions[society] then
--         local commission = round(amount * Config.BillingCommissions[society])
--         SenderPly.Functions.AddMoney('bank', commission)
--         invoiceMailData = {
--             sender = 'Billing Department',
--             subject = 'Commission Received',
--             message = string.format('You received a commission check of $%s when %s %s paid a bill of $%s.', commission, Ply.PlayerData.charinfo.firstname, Ply.PlayerData.charinfo.lastname, amount)
--         }
--     elseif not SenderPly and Config.BillingCommissions[society] then
--         invoiceMailData = {
--             sender = 'Billing Department',
--             subject = 'Bill Paid',
--             message = string.format('%s %s paid a bill of $%s', Ply.PlayerData.charinfo.firstname, Ply.PlayerData.charinfo.lastname, amount)
--         }
--     end
--     TriggerEvent('esx-phone:server:sendNewMailToOffline', sendercitizenid, invoiceMailData)
--     MySQL.Async.execute('DELETE FROM phone_invoices WHERE id = ?', {invoiceId})
--     local invoices = MySQL.Sync.fetchAll('SELECT * FROM phone_invoices WHERE citizenid = ?', {Ply.PlayerData.citizenid})
--     if invoices[1] ~= nil then
--         Invoices = invoices
--     end
--     cb(true, Invoices)
-- end)

-- ESX.RegisterServerCallback('esx-phone:server:DeclineInvoice', function(source, cb, sender, amount, invoiceId)
--     local Invoices = {}
--     local Ply = QBCore.Functions.GetPlayer(source)
--     MySQL.Async.execute('DELETE FROM phone_invoices WHERE id = ?', {invoiceId})
--     local invoices = MySQL.Sync.fetchAll('SELECT * FROM phone_invoices WHERE citizenid = ?', {Ply.PlayerData.citizenid})
--     if invoices[1] ~= nil then
--         Invoices = invoices
--     end
--     cb(true, Invoices)
-- end)

ESX.RegisterServerCallback('esx-phone:server:GetContactPictures', function(source, cb, Chats)
    for k, v in pairs(Chats) do
        v.picture = "default"
    end
    cb(Chats)
end)

ESX.RegisterServerCallback('esx-phone:server:GetContactPicture', function(source, cb, Chat)
    Chat.picture = "default"
    cb(Chat)
end)

ESX.RegisterServerCallback('esx-phone:server:GetPicture', function(source, cb, number)
        local metadata = MySQL.Sync.fetchAll('SELECT metadata FROM users WHERE phone_number = ?',{number})
        if metadata then
            if metadata.metadata and metadata.metadata.phone and metadata.phone.profilepicture then
                Picture = metadata.metadata.phone.profilepicture
            else
                Picture = "default"
            end
        end
        print(Picture)
        cb(Picture)
end)

-- ESX.RegisterServerCallback('esx-phone:server:FetchResult', function(source, cb, search)
--     local search = escape_sqli(search)
--     local searchData = {}
--     local ApaData = {}
--     local query = 'SELECT * FROM `players` WHERE `citizenid` = "' .. search .. '"'
--     -- Split on " " and check each var individual
--     local searchParameters = SplitStringToArray(search)
--     -- Construct query dynamicly for individual parm check
--     if #searchParameters > 1 then
--         query = query .. ' OR `charinfo` LIKE "%' .. searchParameters[1] .. '%"'
--         for i = 2, #searchParameters do
--             query = query .. ' AND `charinfo` LIKE  "%' .. searchParameters[i] .. '%"'
--         end
--     else
--         query = query .. ' OR `charinfo` LIKE "%' .. search .. '%"'
--     end
--     -- local ApartmentData = MySQL.Sync.fetchAll('SELECT * FROM apartments', {})
--     -- for k, v in pairs(ApartmentData) do
--     --     ApaData[v.citizenid] = ApartmentData[k]
--     -- end
--     -- local result = MySQL.Sync.fetchAll(query)
--     -- if result[1] ~= nil then
--     --     for k, v in pairs(result) do
--     --         local charinfo = json.decode(v.charinfo)
--     --         local metadata = json.decode(v.metadata)
--     --         local appiepappie = {}
--     --         if ApaData[v.citizenid] ~= nil and next(ApaData[v.citizenid]) ~= nil then
--     --             appiepappie = ApaData[v.citizenid]
--     --         end
--     --         searchData[#searchData+1] = {
--     --             citizenid = v.citizenid,
--     --             firstname = charinfo.firstname,
--     --             lastname = charinfo.lastname,
--     --             birthdate = charinfo.birthdate,
--     --             phone = charinfo.phone,
--     --             nationality = charinfo.nationality,
--     --             gender = charinfo.gender,
--     --             warrant = false,
--     --             driverlicense = metadata["licences"]["driver"],
--     --             appartmentdata = appiepappie
--     --         }
--     --     end
--         cb(searchData)
--     else
--         cb(nil)
--     end
-- end)

-- ESX.RegisterServerCallback('esx-phone:server:GetVehicleSearchResults', function(source, cb, search)
--     local search = escape_sqli(search)
--     local searchData = {}
--     local query = '%' .. search .. '%'
--     local result = MySQL.Sync.fetchAll('SELECT * FROM player_vehicles WHERE plate LIKE ? OR citizenid = ?',
--         {query, search})
--     if result[1] ~= nil then
--         for k, v in pairs(result) do
--             local player = MySQL.Sync.fetchAll('SELECT * FROM players WHERE citizenid = ?', {result[k].citizenid})
--             if player[1] ~= nil then
--                 local charinfo = json.decode(player[1].charinfo)
--                 local vehicleInfo = QBCore.Shared.Vehicles[result[k].vehicle]
--                 if vehicleInfo ~= nil then
--                     searchData[#searchData+1] = {
--                         plate = result[k].plate,
--                         status = true,
--                         owner = charinfo.firstname .. " " .. charinfo.lastname,
--                         citizenid = result[k].citizenid,
--                         label = vehicleInfo["name"]
--                     }
--                 else
--                     searchData[#searchData+1] = {
--                         plate = result[k].plate,
--                         status = true,
--                         owner = charinfo.firstname .. " " .. charinfo.lastname,
--                         citizenid = result[k].citizenid,
--                         label = "Name not found.."
--                     }
--                 end
--             end
--         end
--     else
--         if GeneratedPlates[search] ~= nil then
--             searchData[#searchData+1] = {
--                 plate = GeneratedPlates[search].plate,
--                 status = GeneratedPlates[search].status,
--                 owner = GeneratedPlates[search].owner,
--                 citizenid = GeneratedPlates[search].citizenid,
--                 label = "Brand unknown.."
--             }
--         else
--             local ownerInfo = GenerateOwnerName()
--             GeneratedPlates[search] = {
--                 plate = search,
--                 status = true,
--                 owner = ownerInfo.name,
--                 citizenid = ownerInfo.citizenid
--             }
--             searchData[#searchData+1] = {
--                 plate = search,
--                 status = true,
--                 owner = ownerInfo.name,
--                 citizenid = ownerInfo.citizenid,
--                 label = "Brand unknown.."
--             }
--         end
--     end
--     cb(searchData)
-- end)

-- ESX.RegisterServerCallback('esx-phone:server:ScanPlate', function(source, cb, plate)
--     local src = source
--     local vehicleData = {}
--     if plate ~= nil then
--         local result = MySQL.Sync.fetchAll('SELECT * FROM owned_vehicles WHERE plate = ?', {plate})
--         if result[1] ~= nil then
--             local player = MySQL.Sync.fetchAll('SELECT * FROM players WHERE identifier = ?', {result[1].owner})
--             vehicleData = {
--                 plate = plate,
--                 status = true,
--                 owner = player.firstname .. " " .. player.lastname,
--                 citizenid = result[1].identifier
--             }
--         elseif GeneratedPlates ~= nil and GeneratedPlates[plate] ~= nil then
--             vehicleData = GeneratedPlates[plate]
--         else
--             local ownerInfo = GenerateOwnerName()
--             GeneratedPlates[plate] = {
--                 plate = plate,
--                 status = true,
--                 owner = ownerInfo.name,
--                 citizenid = ownerInfo.citizenid
--             }
--             vehicleData = {
--                 plate = plate,
--                 status = true,
--                 owner = ownerInfo.name,
--                 citizenid = ownerInfo.citizenid
--             }
--         end
--         cb(vehicleData)
--     else
--         TriggerClientEvent('QBCore:Notify', src, 'No Vehicle Nearby', 'error')
--         cb(nil)
--     end
-- end)

ESX.RegisterServerCallback('esx-phone:server:HasPhone', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer ~= nil then
        local HasPhone = xPlayer.getInventoryItem("phone").count
        if HasPhone >= 1 then
            cb(true)
        else
            cb(false)
        end
    end
end)


ESX.RegisterServerCallback('esx-phone:server:CanTransferMoney', function(source, cb, amount, iban)
    -- strip bad characters from bank transfers
    amount = tonumber(amount) or 0
    local xPlayer = ESX.GetPlayerFromId(source)
    if tonumber(iban) == source then 
        cb(false)
        return 
    end
    if (xPlayer.getAccount("bank").money - amount) >= 0 then
        print(iban)
        print(amount)
            local Reciever = ESX.GetPlayerFromId(iban)
            if Reciever then
                xPlayer.removeAccountMoney('bank', amount)
                Reciever.addAccountMoney('bank', amount)
                Reciever.triggerEvent('esx-phone:client:TransferMoney', amount, Reciever.getAccount("bank").money)
                cb(true, xPlayer.getAccount("bank").money)
            else
                cb(false)
            end
    else
            cb(false)
    end
end)

ESX.RegisterServerCallback('esx-phone:server:GetCurrentLawyers', function(source, cb)
    local Lawyers = {}
    for _,xPlayer in pairs(ESX.GetExtendedPlayers()) do
        if xPlayer then
            if (xPlayer.job.name == "lawyer" or xPlayer.job.name == "realestateagent" or
            xPlayer.job.name == "tow" or xPlayer.job.name == "taxi") then
                Lawyers[#Lawyers+1] = {
                    name = xPlayer.getName(),
                    phone_number = xPlayer.get("phone_number"),
                    typejob = xPlayer.job.name
                }
            end
        end
    end
    cb(Lawyers)
end)

ESX.RegisterServerCallback("esx-phone:server:GetWebhook",function(source,cb)
	if WebHook ~= "" then
		cb(WebHook)
	else
		print('Set your webhook to ensure that your camera will work!!!!!! Set this on line 10 of the server sided script!!!!!')
		cb(nil)
	end
end)


RegisterNetEvent('esx-phone:server:AddAdvert', function(msg, url)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local CitizenId = xPlayer.identifier
    local url = url or ""
    local name = xPlayer.getName()
    local number = xPlayer.get("phone_number")
    print(url:gsub("[%<>\"()\' $]",""))
    if Adverts[CitizenId]  then
        Adverts[CitizenId].message = msg
        Adverts[CitizenId].name = "@" .. name 
        Adverts[CitizenId].number = number
        Adverts[CitizenId].url = url
    else
        Adverts[CitizenId] = {
            message = msg,
            name = "@" .. name ,
            number = number,
            url = url
        }
    end
    local embedData = {
        {
            ['title'] = "",
            ['color'] =  16506448,
            ["image"] = {
                ['url'] = url:gsub("[%<>\"()\' $]","")
            },
            ['footer'] = {
                ['text'] = os.date(),
            },
            ['description'] = msg,
        }
    }
    PerformHttpRequest(Config.AdsLog, function(err, text, headers) end, 'POST', json.encode({ username = name, embeds = embedData}), { ['Content-Type'] = 'application/json' })
    TriggerClientEvent('esx-phone:client:UpdateAdverts', -1, Adverts, "@" .. name)
end)

RegisterNetEvent('esx-phone:server:DeleteAdvert', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local citizenid = xPlayer.identifier
    Adverts[citizenid] = nil
    TriggerClientEvent('esx-phone:client:UpdateAdvertsDel', -1, Adverts)
end)

RegisterNetEvent('esx-phone:server:SetCallState', function(bool)
    local src = source
    local xPly = ESX.GetPlayerFromId(src)
    if Calls[src] then
        Calls[src].inCall = bool
    else
        Calls[src] = {}
        Calls[src].inCall = bool
    end
end)

RegisterNetEvent('esx-phone:server:RemoveMail', function(MailId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    MySQL.Async.execute('DELETE FROM player_mails WHERE mailid = ? AND citizenid = ?', {MailId, xPlayer.identifier})
    SetTimeout(100, function()
        local mails = MySQL.Sync.fetchAll('SELECT * FROM player_mails WHERE citizenid = ? ORDER BY `date` ASC', {xPlayer.identifier})
        if mails[1] ~= nil then
            for k, v in pairs(mails) do
                if mails[k].button ~= nil then
                    mails[k].button = json.decode(mails[k].button)
                end
            end
        end
        TriggerClientEvent('esx-phone:client:UpdateMails', src, mails)
    end)
end)

RegisterNetEvent('esx-phone:server:sendNewMail', function(mailData, player)
    local src = player or source 
    local xPlayer = ESX.GetPlayerFromId(src)
    if mailData.button == nil then
        MySQL.Async.insert('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES (?, ?, ?, ?, ?, ?)', {xPlayer.identifier, mailData.sender, mailData.subject, mailData.message, GenerateMailId(), 0})
    else
        MySQL.Async.insert('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES (?, ?, ?, ?, ?, ?, ?)', {xPlayer.identifier, mailData.sender, mailData.subject, mailData.message, GenerateMailId(), 0, json.encode(mailData.button)})
    end
    TriggerClientEvent('esx-phone:client:NewMailNotify', src, mailData)
    SetTimeout(200, function()
        local mails = MySQL.Sync.fetchAll('SELECT * FROM player_mails WHERE citizenid = ? ORDER BY `date` DESC',
            {xPlayer.identifier})
        if mails[1] then
            for k, v in pairs(mails) do
                if mails[k].button then
                    mails[k].button = json.decode(mails[k].button)
                end
            end
        end

        TriggerClientEvent('esx-phone:client:UpdateMails', src, mails)
    end)
end)

RegisterNetEvent('esx-phone:server:sendNewMailToOffline', function(citizenid, mailData)
    print("1")
    print(citizenid)
    print(ESX.DumpTable(mailData))
    local xPlayer = ESX.GetPlayerFromIdentifier(citizenid)
    if xPlayer then
        print(2)
        local src = xPlayer.source
        if mailData.button == nil then
            print(3)
            MySQL.Async.insert('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES (?, ?, ?, ?, ?, ?)', {xPlayer.identifier, mailData.sender, mailData.subject, mailData.message, GenerateMailId(), 0})
            TriggerClientEvent('esx-phone:client:NewMailNotify', src, mailData)
        else
            MySQL.Async.insert('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES (?, ?, ?, ?, ?, ?, ?)', {xPlayer.identifier, mailData.sender, mailData.subject, mailData.message, GenerateMailId(), 0, json.encode(mailData.button)})
            TriggerClientEvent('esx-phone:client:NewMailNotify', src, mailData)
        end
        SetTimeout(200, function()
            local mails = MySQL.Sync.fetchAll(
                'SELECT * FROM player_mails WHERE citizenid = ? ORDER BY `date` ASC', {xPlayer.identifier})
            if mails[1] ~= nil then
                for k, v in pairs(mails) do
                    if mails[k].button ~= nil then
                        mails[k].button = json.decode(mails[k].button)
                    end
                end
            end

            TriggerClientEvent('esx-phone:client:UpdateMails', src, mails)
        end)
    else
        if mailData.button == nil then
            MySQL.Async.insert('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES (?, ?, ?, ?, ?, ?)', {citizenid, mailData.sender, mailData.subject, mailData.message, GenerateMailId(), 0})
        else
            MySQL.Async.insert('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES (?, ?, ?, ?, ?, ?, ?)', {citizenid, mailData.sender, mailData.subject, mailData.message, GenerateMailId(), 0, json.encode(mailData.button)})
        end
    end
end)

RegisterNetEvent('esx-phone:server:sendNewEventMail', function(citizenid, mailData)
    local Player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
    if mailData.button == nil then
        MySQL.Async.insert('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES (?, ?, ?, ?, ?, ?)', {citizenid, mailData.sender, mailData.subject, mailData.message, GenerateMailId(), 0})
    else
        MySQL.Async.insert('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES (?, ?, ?, ?, ?, ?, ?)', {citizenid, mailData.sender, mailData.subject, mailData.message, GenerateMailId(), 0, json.encode(mailData.button)})
    end
    SetTimeout(200, function()
        local mails = MySQL.Sync.fetchAll('SELECT * FROM player_mails WHERE citizenid = ? ORDER BY `date` ASC', {citizenid})
        if mails[1] ~= nil then
            for k, v in pairs(mails) do
                if mails[k].button ~= nil then
                    mails[k].button = json.decode(mails[k].button)
                end
            end
        end
        TriggerClientEvent('esx-phone:client:UpdateMails', Player.PlayerData.source, mails)
    end)
end)

RegisterNetEvent('esx-phone:server:ClearButtonData', function(mailId)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    MySQL.Async.execute('UPDATE player_mails SET button = ? WHERE mailid = ? AND citizenid = ?', {'', mailId, xPlayer.identifier})
    SetTimeout(200, function()
        local mails = MySQL.Sync.fetchAll('SELECT * FROM player_mails WHERE citizenid = ? ORDER BY `date` ASC', {xPlayer.identifier})
        if mails[1] ~= nil then
            for k, v in pairs(mails) do
                if mails[k].button ~= nil then
                    mails[k].button = json.decode(mails[k].button)
                end
            end
        end
        TriggerClientEvent('esx-phone:client:UpdateMails', src, mails)
    end)
end)

RegisterNetEvent('esx-phone:server:MentionedPlayer', function(name, TweetMessage)
    for k, xPlayer in pairs(ESX.GetExtendedPlayers()) do
        if xPlayer.getName() == name then
                Phone.SetPhoneAlerts(xPlayer.identifier, "twitter")
                Phone.AddMentionedTweet(xPlayer.identifier, TweetMessage)
                TriggerClientEvent('esx-phone:client:GetMentioned', xPlayer.source, TweetMessage, AppAlerts[xPlayer.identifier]["twitter"])
           -- else
                -- local query1 = '%' .. firstName .. '%'
                -- local query2 = '%' .. lastName .. '%'
                -- local result = MySQL.Sync.fetchAll('SELECT * FROM users WHERE charinfo LIKE ? AND charinfo LIKE ?', {query1, query2})
                -- if result[1] ~= nil then
                --     local MentionedTarget = result[1].citizenid
                --     Phone.SetPhoneAlerts(MentionedTarget, "twitter")
                --     Phone.AddMentionedTweet(MentionedTarget, TweetMessage)
                -- end
            end
    end
end)

RegisterNetEvent('esx-phone:server:CallContact', function(TargetData, CallId, AnonymousCall)
    local src = source
    local Ply = ESX.GetPlayerFromId(src)
    local Target = GetPlayerByPhone(TargetData.number)
    if Target then
        TriggerClientEvent('esx-phone:client:GetCalled', Target.source, Ply.get("phone_number"), CallId, AnonymousCall)
    end
end)

-- RegisterNetEvent('esx-phone:server:BillingEmail', function(data, paid)
--     for k, v in pairs(QBCore.Functions.GetPlayers()) do
--         local target = QBCore.Functions.GetPlayer(v)
--         if target.PlayerData.job.name == data.society then
--             if paid then
--                 local name = '' .. QBCore.Functions.GetPlayer(source).PlayerData.charinfo.firstname .. ' ' .. QBCore.Functions.GetPlayer(source).PlayerData.charinfo.lastname .. ''
--                 TriggerClientEvent('esx-phone:client:BillingEmail', target.PlayerData.source, data, true, name)
--             else
--                 local name = '' .. QBCore.Functions.GetPlayer(source).PlayerData.charinfo.firstname .. ' ' .. QBCore.Functions.GetPlayer(source).PlayerData.charinfo.lastname .. ''
--                 TriggerClientEvent('esx-phone:client:BillingEmail', target.PlayerData.source, data, false, name)
--             end
--         end
--     end
-- end)

RegisterNetEvent('esx-phone:server:UpdateHashtags', function(Handle, messageData)
    if Hashtags[Handle] ~= nil and next(Hashtags[Handle]) ~= nil then
        Hashtags[Handle].messages[#Hashtags[Handle].messages+1] = messageData
    else
        Hashtags[Handle] = {
            hashtag = Handle,
            messages = {}
        }
        Hashtags[Handle].messages[#Hashtags[Handle].messages+1] = messageData
    end
    TriggerClientEvent('esx-phone:client:UpdateHashtags', -1, Handle, messageData)
end)

RegisterNetEvent('esx-phone:server:SetPhoneAlerts', function(app, alerts)
    local src = source
    local CitizenId = ESX.GetPlayerFromId(src).identifier
    Phone.SetPhoneAlerts(CitizenId, app, alerts)
end)

RegisterNetEvent('esx-phone:server:DeleteTweet', function(tweetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local delete = false
    local TID = tweetId
    local Data = MySQL.Sync.fetchScalar('SELECT citizenid FROM phone_tweets WHERE tweetId = ?', {id})
    if Data == xPlayer.identifier then
        local Data2 = MySQL.Sync.fetchAll('DELETE FROM phone_tweets WHERE tweetId = ?', {TID})
        delete = true
    end

    if delete then
        delete = not delete
        for k, v in pairs(TWData) do
            if TWData[k].tweetId == TID then
                TWData = nil
            end
        end
        TriggerClientEvent('esx-phone:client:UpdateTweets', -1, TWData)
    end
end)

RegisterNetEvent('esx-phone:server:UpdateTweets', function(NewTweets, TweetData)
    local src = source
    if Config.Linux then
        local InsertTweet = MySQL.Async.insert('INSERT INTO phone_tweets (citizenid, name, message, date, url, picture, tweetid) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            TweetData.citizenid,
            TweetData.name,
            TweetData.message,
            TweetData.date,
            TweetData.url:gsub("[%<>\"()\' $]",""),
            TweetData.picture,
            TweetData.tweetId
        })
        TriggerClientEvent('esx-phone:client:UpdateTweets', -1, src, NewTweets, TweetData, false)
    else
        local InsertTweet = MySQL.Async.insert('INSERT INTO phone_tweets (citizenid, name, message, date, url, picture, tweetid) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            TweetData.citizenid,
            TweetData.name,
            TweetData.message,
            TweetData.time,
            TweetData.url:gsub("[%<>\"()\' $]",""),
            TweetData.picture,
            TweetData.tweetId
        })
        TriggerClientEvent('esx-phone:client:UpdateTweets', -1, src, NewTweets, TweetData, false)
    end
end)

RegisterNetEvent('esx-phone:server:EditContact', function(newName, newNumber, newIban, oldName, oldNumber, oldIban)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    MySQL.Async.execute(
        'UPDATE player_contacts SET name = ?, number = ?, iban = ? WHERE citizenid = ? AND name = ? AND number = ?',
        {newName, newNumber, newIban, xPlayer.identifier, oldName, oldNumber})
end)

RegisterNetEvent('esx-phone:server:RemoveContact', function(Name, Number)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    MySQL.Async.execute('DELETE FROM player_contacts WHERE name = ? AND number = ? AND citizenid = ?',
        {Name, Number, xPlayer.identifier})
end)

RegisterNetEvent('esx-phone:server:AddNewContact', function(name, number, iban)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    MySQL.Async.insert('INSERT INTO player_contacts (citizenid, name, number, iban) VALUES (?, ?, ?, ?)', {xPlayer.identifier, tostring(name), tostring(number), tostring(iban)})
end)


RegisterNetEvent('esx-phone:server:LogTweet', function(tweetData)
    local webHook = Config.TwitterLog
    local text = tweetData.message
    -- if tweetData.url then 
    --     text = text .. " "..tweetData.url
    -- end
    local embedData = {
        {
            ['title'] = "",
            ['color'] =  2463966,
            ["image"] = {
                ['url'] = tweetData.url:gsub("[%<>\"()\' $]",""),
            },
            ['footer'] = {
                ['text'] = os.date(),
            },
            ['description'] = text,
        }
    }
    PerformHttpRequest(webHook, function(err, text, headers) end, 'POST', json.encode({ username = tweetData.name, embeds = embedData}), { ['Content-Type'] = 'application/json' })
end)

RegisterNetEvent('esx-phone:server:UpdateMessages', function(ChatMessages, ChatNumber, _)
    local src = source
    local SenderData = ESX.GetPlayerFromId(src)
    local Player = MySQL.query.await('SELECT * FROM users WHERE phone_number = ?', {ChatNumber})
    print(ChatNumber)
    if Player[1] ~= nil then
        local TargetData = ESX.GetPlayerFromIdentifier(Player[1].identifier)
        if TargetData ~= nil then
            local Chat = MySQL.query.await('SELECT * FROM phone_messages WHERE citizenid = ? AND number = ?', {SenderData.identifier, ChatNumber})
            if Chat[1] ~= nil then
                -- Update for target
                MySQL.update('UPDATE phone_messages SET messages = ? WHERE citizenid = ? AND number = ?', {json.encode(ChatMessages), SenderData.identifier, Player[1].phone_number})
                -- Update for sender
                MySQL.update('UPDATE phone_messages SET messages = ? WHERE citizenid = ? AND number = ?', {json.encode(ChatMessages), Player[1].identifier,SenderData.get("phone_number")})
                -- Send notification & Update messages for target
                TriggerClientEvent('esx-phone:client:UpdateMessages', TargetData.source, ChatMessages, SenderData.get("phone_number"), false)
            else
                -- Insert for target
                MySQL.insert('INSERT INTO phone_messages (citizenid, number, messages) VALUES (?, ?, ?)', {SenderData.identifier, Player[1].phone_number, json.encode(ChatMessages)})
                -- Insert for sender
                MySQL.insert('INSERT INTO phone_messages (citizenid, number, messages) VALUES (?, ?, ?)', { Player[1].identifier, SenderData.get("phone_number"), json.encode(ChatMessages)})
                -- Send notification & Update messages for target
                TriggerClientEvent('esx-phone:client:UpdateMessages', TargetData.source, ChatMessages, SenderData.get("phone_number"), true)
            end
        else
            local Chat = MySQL.query.await('SELECT * FROM phone_messages WHERE citizenid = ? AND number = ?', {SenderData.identifier, ChatNumber})
            if Chat[1] ~= nil then
                -- Update for target
                MySQL.update('UPDATE phone_messages SET messages = ? WHERE citizenid = ? AND number = ?', {json.encode(ChatMessages), Player[1].identifier, Player[1].phone_number})
                -- Update for sender
                Player[1].charinfo = json.decode(Player[1].charinfo)
                MySQL.update('UPDATE phone_messages SET messages = ? WHERE citizenid = ? AND number = ?', {json.encode(ChatMessages), SenderData.identifier, SenderData.get("phone_number")})
            else
                -- Insert for target
                MySQL.insert('INSERT INTO phone_messages (citizenid, number, messages) VALUES (?, ?, ?)', {Player[1].identifier, SenderData.get("phone_number"), json.encode(ChatMessages)})
                -- Insert for sender
                Player[1].charinfo = json.decode(Player[1].charinfo)
                MySQL.insert('INSERT INTO phone_messages (citizenid, number, messages) VALUES (?, ?, ?)', {SenderData.identifier, Player[1].phone_number, json.encode(ChatMessages)})
            end
        end
    end
end)



 RegisterNetEvent('esx-phone:server:AddRecentCall', function(type, data)
     local src = source
     local Ply = ESX.GetPlayerFromId(src)
     local Hour = os.date("%H")
     local Minute = os.date("%M")
     local label = Hour .. ":" .. Minute
     TriggerClientEvent('esx-phone:client:AddRecentCall', src, data, label, type)
     local Trgt = GetPlayerByPhone(data.number)
     if Trgt then
         TriggerClientEvent('esx-phone:client:AddRecentCall', Trgt.source, {
             name = Ply.getName(),
             number = 0,
             anonymous = data.anonymous
         }, label, "outgoing")
    end
 end)

RegisterNetEvent('esx-phone:server:CancelCall', function(ContactData)
    local Ply = GetPlayerByPhone(ContactData.TargetData.number)
    if Ply then
        TriggerClientEvent('esx-phone:client:CancelCall', Ply.source)
    end
end)

RegisterNetEvent('esx-phone:server:AnswerCall', function(CallData)
    local Ply = GetPlayerByPhone(CallData.TargetData.number)
    if Ply then
        TriggerClientEvent('esx-phone:client:AnswerCall', Ply.source)
    end
end)

RegisterNetEvent('esx-phone:server:SaveMetaData', function(MData)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local result = MySQL.Sync.fetchAll('SELECT * FROM users WHERE identifier = ?', {xPlayer.identifier})
    local MetaData = json.decode(result[1].metadata)
    MetaData.phone = MData
    MySQL.Async.execute('UPDATE users SET metadata = ? WHERE identifier = ?',
        {json.encode(MetaData), xPlayer.identifier})
    xPlayer.set("phonedata", MetaData)
end)

RegisterNetEvent('esx-phone:server:GiveContactDetails', function(PlayerId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local SuggestionData = {
        name = {
            [1] = xPlayer.get("firstname"),
            [2] = xPlayer.get("last_name")
        },
        number = xPlayer.get("phone_number"),
        bank = xPlayer.source
    }

    TriggerClientEvent('esx-phone:client:AddNewSuggestion', PlayerId, SuggestionData)
end)

RegisterNetEvent('esx-phone:server:AddTransaction', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    MySQL.Async.insert('INSERT INTO crypto_transactions (citizenid, title, message) VALUES (?, ?, ?)', {
        xPlayer.identifier,
        data.TransactionTitle,
        data.TransactionMessage
    })
end)

RegisterNetEvent('esx-phone:server:InstallApplication', function(ApplicationData)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    xPlayer.variables["phonedata"].InstalledApps[ApplicationData.app] = ApplicationData
    xPlayer.set("phonedata", xPlayer.variables["phonedata"])

    TriggerClientEvent('esx-phone:RefreshPhone', src)
end)

RegisterNetEvent('esx-phone:server:RemoveInstallation', function(App)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    xPlayer.variables["phonedata"].InstalledApps[App] = nil
    xPlayer.set("phonedata", xPlayer.variables["phonedata"])

    TriggerClientEvent('esx-phone:RefreshPhone', src)
end)

RegisterNetEvent('esx-phone:server:addImageToGallery', function(image)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.insert('INSERT INTO phone_gallery (`citizenid`, `image`) VALUES (?, ?)',{xPlayer.identifier, image})
end)

RegisterNetEvent('esx-phone:server:getImageFromGallery', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local images = MySQL.Sync.fetchAll('SELECT * FROM phone_gallery WHERE citizenid = ? ORDER BY `date` DESC',{xPlayer.identifier})
    TriggerClientEvent('esx-phone:refreshImages', src, images)
end)

RegisterNetEvent('esx-phone:server:RemoveImageFromGallery', function(data)
    local xPlayer = ESX.GetPlayerFromId(source)
    local image = data.image
    MySQL.execute('DELETE FROM phone_gallery WHERE citizenid = ? AND image = ?',{xPlayer.identifier,image})
end)

RegisterNetEvent('esx-phone:server:sendPing', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(source)
    print(src, data)
    if src ~= data then

    else
        xPlayer.showNotification("You cannot ping yourself", "error")
    end
end)

-- Command

--[[QBCore.Commands.Add("setmetadata", "Set Player Metadata (God Only)", {}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if args[1] then
        if args[1] == "trucker" then
            if args[2] then
                local newrep = Player.PlayerData.metadata["jobrep"]
                newrep.trucker = tonumber(args[2])
                Player.Functions.SetMetaData("jobrep", newrep)
            end
        end
    end
end, "god")

QBCore.Commands.Add('bill', 'Bill A Player', {{name = 'id', help = 'Player ID'}, {name = 'amount', help = 'Fine Amount'}}, false, function(source, args)
    local biller = QBCore.Functions.GetPlayer(source)
    local billed = QBCore.Functions.GetPlayer(tonumber(args[1]))
    local amount = tonumber(args[2])
    if biller.PlayerData.job.name == "police" or biller.PlayerData.job.name == 'ambulance' or biller.PlayerData.job.name == 'mechanic' then
        if billed ~= nil then
            if biller.PlayerData.citizenid ~= billed.PlayerData.citizenid then
                if amount and amount > 0 then
                    MySQL.Async.insert(
                        'INSERT INTO phone_invoices (citizenid, amount, society, sender, sendercitizenid) VALUES (?, ?, ?, ?, ?)',
                        {billed.PlayerData.citizenid, amount, biller.PlayerData.job.name,
                         biller.PlayerData.charinfo.firstname, biller.PlayerData.citizenid})
                    TriggerClientEvent('esx-phone:RefreshPhone', billed.PlayerData.source)
                    TriggerClientEvent('QBCore:Notify', source, 'Invoice Successfully Sent', 'success')
                    TriggerClientEvent('QBCore:Notify', billed.PlayerData.source, 'New Invoice Received')
                else
                    TriggerClientEvent('QBCore:Notify', source, 'Must Be A Valid Amount Above 0', 'error')
                end
            else
                TriggerClientEvent('QBCore:Notify', source, 'You Cannot Bill Yourself', 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', source, 'Player Not Online', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', source, 'No Access', 'error')
    end
end)--]]