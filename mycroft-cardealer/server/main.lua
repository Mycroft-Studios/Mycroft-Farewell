local CarDealers = {}

CarDealers[1] = {
  Coords = vector3(-28.8918, -1103.6040, 26.422),
  VehSpawn = vector4(-31.2422, -1090.4177, 26.4222, 333.6772),
  slots = {
    {
      vehicle = {
        model = "adder",
        price = 1000000,
        Stock = 30,
        isAutoMobile = true,
        label = "Adder",
        description = "A fast car",
        image = "https://i.imgur.com/1ZQ3w9q.png"
      },
      spawned = false,
      coords = vector4(-40.1071, -1099.2559, 26.4223, 131.6982)
    },
    {
      vehicle = {
        model = "asbo",
        price = 1000000,
        Stock = 10,
        label = "Asbo",
        isAutoMobile = true,
        description = "A Compact, low-profile car, perfect for all adventures!",
        image = "https://i.imgur.com/1ZQ3w9q.png"
      },
      spawned = false,
      coords = vector4(-43.9070, -1096.5233, 26.4223, 182.5613)
    },
    {
      vehicle = {
        model = "sanchez",
        Stock = 1,
        price = 1000000,
        label = "Sanchez",
        isAutoMobile = false,
        description = "A fast car",
        image = "https://i.imgur.com/1ZQ3w9q.png"
      },
      spawned = false,
      coords = vector4(-50.2355, -1093.4447, 26.4223, 198.3397)
    },
  }
}

ESX.RegisterServerCallback("CarDealers:Refresh", function(src, cb)
  cb(CarDealers)
end)

ESX.RegisterServerCallback("CarDealers:BuyVehicle", function(src, cb, Dealer, Slot)
  print(Dealer, Slot)
  local Veh = CarDealers[Dealer].slots[Slot].vehicle
  local xPlayer = ESX.GetPlayerFromId(src)
  if xPlayer.getMoney() >= Veh.price and Veh.Stock >= 1 then
    xPlayer.removeMoney(Veh.price)
    ESX.OneSync.SpawnVehicle(joaat(Veh.model),CarDealers[Dealer].VehSpawn.xyz, CarDealers[Dealer].VehSpawn.w, Veh.isAutoMobile,nil, function(vehicle)
      Wait(10)
      TaskWarpPedIntoVehicle(GetPlayerPed(src), vehicle, -1)
    end)
    CarDealers[Dealer].slots[Slot].vehicle.Stock = CarDealers[Dealer].slots[Slot].vehicle.Stock - 1
    TriggerClientEvent("CarDealers:Refresh", -1, CarDealers)
    cb(true)
  else
    cb(false)
  end
end)