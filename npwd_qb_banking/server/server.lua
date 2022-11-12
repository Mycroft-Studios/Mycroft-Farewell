local bannedCharacters = { "%", "$", ";" }

local function round(num, numDecimalPlaces)
    if numDecimalPlaces and numDecimalPlaces > 0 then
        local mult = 10 ^ numDecimalPlaces
        return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end

ESX.RegisterServerCallback("npwd:qb-banking:GetBankBalance", function(source, cb)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local balance = tostring(xPlayer.getAccount("bank").money)
	cb(balance or false)
end)

ESX.RegisterServerCallback("npwd:qb-banking:getAccountNumber", function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local accountNumber = xPlayer.identifier
	cb(accountNumber or false)
end)

ESX.RegisterServerCallback("npwd:qb-banking:getContacts", function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local contacts = MySQL.query.await(
		"SELECT * FROM npwd_phone_contacts WHERE identifier = ? ORDER BY display ASC",
		{ xPlayer.identifier }
	)
	cb(contacts or false)
end)

ESX.RegisterServerCallback("npwd:qb-banking:getInvoices", function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local invoices = MySQL.query.await(
		"SELECT * FROM phone_invoices WHERE identifier = ?",
		{ xPlayer.identifier }
	)
	cb(invoices or false)
end)

ESX.RegisterServerCallback("npwd:qb-banking:declineInvoice", function(source, cb, data)
	local invoiceId = data
	local xPlayer = ESX.GetPlayerFromId(source)
	local result = MySQL.query.await(
		"DELETE FROM phone_invoices WHERE identifier = ? AND id = ?",
		{ xPlayer.identifier, invoiceId }
	)
	cb(result or false)
end)

ESX.RegisterServerCallback("npwd:qb-banking:payInvoice", function(source, cb, data)
	local Sender = ESX.GetPlayerFromIdentifier(data.senderidentifier)
	local xPlayer = ESX.GetPlayerFromId(source)
	local society = data.society:gsub("society_", "")
	local amount = tonumber(data.amount)
	local invoiceId = data.id
	local invoiceMailData = {}
	local balance = xPlayer.getAccount("bank").money
		if balance < amount then
			return cb(false) --not enough money
		end

		xPlayer.removeAccountMoney('bank', amount, "paid-invoice")

		if not Config.BillingCommissions[data.society] then
			invoiceMailData = {
				sender = 'Billing Department',
				subject = 'Bill Paid',
				message = string.format('%s paid a bill of $%s', xPlayer.getName(), amount)
			}
		end	

		if Config.BillingCommissions[data.society] then
			local commission = round(amount * Config.BillingCommissions[data.society])
			invoiceMailData = {
				sender = 'Billing Department',
				subject = 'Bill Paid',
				message = string.format('You received a commission check of $%s when %s paid a bill of $%s.', commission, xPlayer.getName(), amount)
			}
			if Sender then
				Sender.addAccountMoney('bank', commission)
			else
				local RecieverDetails = MySQL.query.await("SELECT accounts FROM users WHERE identifier = ?", { data.senderidentifier })
				local RecieverMoney = json.decode(RecieverDetails[1].accounts)
				for i=1, #RecieverMoney, 1 do
					if RecieverMoney[i].name == 'bank' then
						RecieverMoney[i].money += commission
						break
					end
				end
				MySQL.update(
					"UPDATE users SET accounts = ? WHERE identifier = ?",
					{ json.encode(RecieverMoney), data.senderidentifier }
				)
			end
			amount -= commission
		end
		invoiceMailData2 = {
			sender = society,
			subject = 'Paid Bill',
			message = string.format('You paid a bill of $%s.              Best Regards,\n%s.', amount, Sender.getName() or society)
		}
		TriggerEvent('qb-phone:server:sendNewMailToOffline', data.senderidentifier, invoiceMailData)
		TriggerEvent('qb-phone:server:sendNewMailToOffline', xPlayer.identifier, invoiceMailData2)
		MySQL.query('DELETE FROM phone_invoices WHERE id = ?', {invoiceId})
		local newBalance = xPlayer.getAccount("bank").money
		cb(newBalance)
	end)

ESX.RegisterServerCallback("npwd:qb-banking:transferMoney", function(source, cb, amount, toAccount, transferType)
	local xPlayer = ESX.GetPlayerFromId(source)
	local balance = xPlayer.getAccount("bank").money
	local amount = tonumber(amount)
	local RecieverDetails

	if balance < amount then
		return cb(false) --not enough money
	end

	if transferType == "contact" then
		local phoneNumber = toAccount.number
		RecieverDetails = MySQL.query.await(
			"SELECT identifier, accounts FROM users where phone_number = ?",
			{ phoneNumber }
		)
	end

	if transferType == "accountNumber" then
		Reciever = ESX.GetPlayerFromId(toAccount)
		if Reciever then
			RecieverDetails = {{identifier = Reciever.identifier, accounts = json.encode(Reciever.accounts)}}
		end
	end
	if RecieverDetails[1] then
		invoiceMailData = {
            sender = xPlayer.getName(),
            subject = 'Money Tranfer',
            message = string.format('You Have Recived $%s.', amount)
		}
		TriggerEvent('qb-phone:server:sendNewMailToOffline', RecieverDetails[1].identifier, invoiceMailData)
		local Reciever = ESX.GetPlayerFromIdentifier(RecieverDetails[1].identifier)
		xPlayer.removeAccountMoney("bank", amount)
		if Reciever then
			Reciever.addAccountMoney("bank", amount)
		else
			local RecieverMoney = json.decode(RecieverDetails[1].accounts)
			for i=1, #RecieverMoney, 1 do
				if RecieverMoney[i].name == 'bank' then
					RecieverMoney[i].money += amount
					break
				end
			end
		end
		cb()
	else
		cb(false) --no account found
	end
end)

-- --qbcore bill command from qb-phone
-- QBCore.Commands.Add('bill', 'Bill A Player', {{name = 'id', help = 'Player ID'}, {name = 'amount', help = 'Fine Amount'}}, false, function(source, args)
--     local biller = QBCore.Functions.GetPlayer(source)
--     local billed = QBCore.Functions.GetPlayer(tonumber(args[1]))
--     local amount = tonumber(args[2])
--     if biller.PlayerData.job.name == "police" or biller.PlayerData.job.name == 'ambulance' or biller.PlayerData.job.name == 'mechanic' then
--         if billed ~= nil then
--             if biller.PlayerData.citizenid ~= billed.PlayerData.citizenid then
--                 if amount and amount > 0 then
--                     local invoiceId = MySQL.insert.await(
--                         'INSERT INTO phone_invoices (citizenid, amount, society, sender, sendercitizenid) VALUES (?, ?, ?, ?, ?)',
--                         {billed.PlayerData.citizenid, amount, biller.PlayerData.job.name,
--                          biller.PlayerData.charinfo.firstname, biller.PlayerData.citizenid})
-- 					local invoiceData = {
-- 						id = invoiceId,
-- 						citizenid = billed.PlayerData.citizenid,
-- 						amount = amount,
-- 						society = biller.PlayerData.job.name,
-- 						sender = biller.PlayerData.charinfo.firstname,
-- 						sendercitizenid = biller.PlayerData.citizenid
-- 					}
--                     TriggerClientEvent('npwd:qb-banking:newInvoice', billed.PlayerData.source, invoiceData)
--                     TriggerClientEvent('QBCore:Notify', source, 'Invoice Successfully Sent', 'success')
--                     TriggerClientEvent('QBCore:Notify', billed.PlayerData.source, 'New Invoice Received')
--                 else
--                     TriggerClientEvent('QBCore:Notify', source, 'Must Be A Valid Amount Above 0', 'error')
--                 end
--             else
--                 TriggerClientEvent('QBCore:Notify', source, 'You Cannot Bill Yourself', 'error')
--             end
--         else
--             TriggerClientEvent('QBCore:Notify', source, 'Player Not Online', 'error')
--         end
--     else
--         TriggerClientEvent('QBCore:Notify', source, 'No Access', 'error')
--     end
-- end)