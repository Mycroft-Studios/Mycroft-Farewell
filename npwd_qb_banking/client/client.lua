RegisterNUICallback("npwd:qb-banking:getBalance", function(_, cb)
  ESX.TriggerServerCallback("npwd:qb-banking:GetBankBalance", function(result)
    if result then 
      cb({ status = "ok", data = tostring(result) })
    else
      cb({status = "error"})
    end
  end)
end)

RegisterNUICallback("npwd:qb-banking:getAccountNumber", function(_, cb)
  cb({ status = "ok", data = "Bank ID: "..GetPlayerServerId(PlayerId()) })
end)

RegisterNUICallback("npwd:qb-banking:getContacts", function(_, cb)
  ESX.TriggerServerCallback("npwd:qb-banking:getContacts", function(result)
    if result then 
      cb({ status = "ok", data = result })
    else
      cb({status = "error"})
    end
  end)
end)

RegisterNUICallback("npwd:qb-banking:transferMoney", function(data, cb)
  ESX.TriggerServerCallback("npwd:qb-banking:transferMoney", function(result)
    if result then 
      cb({ status = "ok", data = "0"})
    else
      cb({status = "error"})
    end
  end, data.amount, data.toAccount, data.transferType)
end)

RegisterNUICallback("npwd:qb-banking:getInvoices", function(_, cb)
  ESX.TriggerServerCallback("npwd:qb-banking:getInvoices", function(result)
    if result then 
      cb({ status = "ok", data = result })
    else
      cb({status = "error"})
    end
  end)
end)

RegisterNUICallback("npwd:qb-banking:declineInvoice", function(data, cb)
  ESX.TriggerServerCallback("npwd:qb-banking:declineInvoice", function(result)
    if result then 
      cb({ status = "ok"})
    else
      cb({status = "error"})
    end
  end, data)
end)

RegisterNUICallback("npwd:qb-banking:payInvoice", function(data, cb)
  ESX.TriggerServerCallback("npwd:qb-banking:payInvoice", function(result)
    if result then 
      cb({ status = "ok", data = result})
    else
      cb({status = "error"})
    end
  end, data)
end)


RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
		if account.name == "bank" then
      exports.npwd:sendUIMessage({type = "npwd:qb-banking:updateMoney", payload = account.money})
    end
end)

RegisterNetEvent('npwd:qb-banking:newInvoice', function(data)
  exports.npwd:sendUIMessage({type = "npwd:qb-banking:newInvoice", payload = {data}})
end)