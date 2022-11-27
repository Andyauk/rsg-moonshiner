Config = {}

-- settings
Config.Prop = 'p_still03x' -- prop used for the moonshine
Config.LawJobName = 'police' -- job that can distroy moonshines
Config.BrewTime = 30000 -- brewtime in milliseconds

Config.MoonshineVendor = {
    
    { -- lemoyne moonshine vendor
        uid = "lemoyne-moonshine",  -- must be unique
        header = "Lemoyne Moonshine Vendor", -- menu header
        pos = vector3(1789.4877, -817.1411, 189.40167), -- location of sell shop
        ped = { -- npc settings
            enable = true,
            model = "CS_MP_MOONSHINER",
            pos = vector3(1790.744, -818.6369, 189.40165),
            head = 27.402536,
        },
        blip = { -- blip settings
            enable = false,
            blipSprite = 'blip_moonshine',
            blipScale = 0.2,
            bliptext = "Moonshine Vendor",
        },
        shopdata = { -- shop data
            {
                title = "Moonshine",
                description = "sell moonshine",
                price = 6,
                item = "moonshine",
				image = "moonshine.png"
            },
        },
    },
    { -- cattail pond moonshine vendor
        uid = "cattailpond-moonshine",  -- must be unique
        header = "Cattail Pond Moonshine Vendor", -- menu header
        pos = vector3(-1091.136, 711.75817, 81.036636), -- location of sell shop
        ped = { -- npc settings
            enable = true,
            model = "CS_MP_MOONSHINER",
            pos = vector3(-1091.696, 713.57281, 81.036384),
            head = 196.19924,
        },
        blip = { -- blip settings
            enable = false,
            blipSprite = 'blip_moonshine',
            blipScale = 0.2,
            bliptext = "Moonshine Vendor",
        },
        shopdata = { -- shop data
            {
                title = "Moonshine",
                description = "sell moonshine",
                price = 6,
                item = "moonshine",
				image = "moonshine.png"
            },
        },
    },
    { -- new austin moonshine vendor
        uid = "newaustin-moonshine",  -- must be unique
        header = "New Austin Moonshine Vendor", -- menu header
        pos = vector3(-2775.057, -3046.294, -11.89815), -- location of sell shop
        ped = { -- npc settings
            enable = true,
            model = "CS_MP_MOONSHINER",
            pos = vector3(-2773.838, -3044.387, -11.89815),
            head = 146.75404,
        },
        blip = { -- blip settings
            enable = false,
            blipSprite = 'blip_moonshine',
            blipScale = 0.2,
            bliptext = "Moonshine Vendor",
        },
        shopdata = { -- shop data
            {
                title = "Moonshine",
                description = "sell moonshine",
                price = 6,
                item = "moonshine",
				image = "moonshine.png"
            },
        },
    },
    { -- hanover moonshine vendor
        uid = "hanover-moonshine",  -- must be unique
        header = "Hanover Moonshine Vendor", -- menu header
        pos = vector3(1629.6535, 828.49346, 121.74415), -- location of sell shop
        ped = { -- npc settings
            enable = true,
            model = "CS_MP_MOONSHINER",
            pos = vector3(1631.6804, 827.44628, 121.74415),
            head = 60.735931,
        },
        blip = { -- blip settings
            enable = false,
            blipSprite = 'blip_moonshine',
            blipScale = 0.2,
            bliptext = "Moonshine Vendor",
        },
        shopdata = { -- shop data
            {
                title = "Moonshine",
                description = "sell moonshine",
                price = 6,
                item = "moonshine",
				image = "moonshine.png"
            },
        },
    },
    { -- manzanita post moonshine vendor
        uid = "manzanitapost-moonshine",  -- must be unique
        header = "Manzanita Post Moonshine Vendor", -- menu header
        pos = vector3(-1864.511, -1727.998, 86.057472), -- location of sell shop
        ped = { -- npc settings
            enable = true,
            model = "CS_MP_MOONSHINER",
            pos = vector3(-1866.421, -1726.562, 86.057472),
            head = 226.45497,
        },
        blip = { -- blip settings
            enable = false,
            blipSprite = 'blip_moonshine',
            blipScale = 0.2,
            bliptext = "Moonshine Vendor",
        },
        shopdata = { -- shop data
            {
                title = "Moonshine",
                description = "sell moonshine",
                price = 6,
                item = "moonshine",
				image = "moonshine.png"
            },
        },
    },
	
}