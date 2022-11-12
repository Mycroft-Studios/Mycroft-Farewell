--[[
Copyright (C) 2021 Sub-Zero Interactive

All rights reserved.

Permission is hereby granted, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software with 'All rights reserved'. Even if 'All rights reserved' is very clear :

  You shall not sell and/or resell this software
  You Can use and modify the software
  You Shall Not Distribute and/or Redistribute the software
  The above copyright notice and this permission notice shall be included in all copies and files of the Software.
]] 

Config = {}

Config.Options = {
	{

	}
}

Config.NPC = {
    {
        Model = 'u_m_m_jesus_01',
        Position = vector3(-253.8, -986.4, 30.2),-- {x = -1457.3, y = -3044.9, z = 13.0},
        Heading = -90.0,
        PedDict = 'mini@strip_club@idles@bouncer@base',
        PedAnimName = 'base',
        SellItems = {
            {
                name = 'cokebag',
                price = math.random(10,30)
            },
            {
                name = 'cokebox',
                price = math.random(150, 250)
            }
        },
        PlayerDict = 'mp_common',
        PlayerAnimName = 'givetake1_a'
    }
}

Config.Drugs = {
    Cocain = {
        Processed = {
            name = 'cokeline',
            label = 'Cocaine Pile'
        },
        bag = {
            name = 'cokebag',
            label = 'Cocaine Bag'
        },
        box = {
            name = 'cokebox',
            label = 'Cocaine Box'
        },
        Field = {
            Name = 'Coca Leaves',
            Position = vector3(2220.72, 5582.52, 54.0),
            Blip = true,
            item = "cocaleaves",
            itemlabel = "Coca Leaves",
            Color = 25,
            Sprite = 496,
            Radius = 100.0
        },
        plants = {
            model = "prop_weed_02",
            objects = {},
            Count = 7,
            Timer = 300,
            delay = 0,
            spawned = 0
        } -- Don`t Change
    },
    -- Opium = {
    --     Processed = {
    --         name = 'bread',
    --         label = 'Bread'
    --     },
    --     bag = {
    --         name = 'bread',
    --         label = 'Bread'
    --     },
    --     box = {
    --         name = 'bread',
    --         label = 'Bread'
    --     },
    --     Field = {
    --         Name = 'Coca Leaves',
    --         Position = vector3(2220.72, 5582.52, 54.0),
    --         Blip = true,
    --         item = "bread",
    --         itemlabel = "Opium",
    --         Color = 25,
    --         Sprite = 496,
    --         Radius = 100.0
    --     plants = {}-- Don`t Change
    --     },
    -- }
}

Config.Gangs = {
    {
    name = "Gang1",
    JobName = "gang1",
    bossRank = "boss"
    }
}

GetNPC = function(NPC)
    for k,v in pairs(Config.NPC) do
        if v[NPC] then
            return v[NPC]
        end
    end
end

GetOptions = function(Option)
    for k,v in pairs(Config.Options) do
        if v[Option] then
            return v[Option]
        end
    end
end