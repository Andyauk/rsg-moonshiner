Config = {}
Config = Config or {}
Config.PlayerProps = {}

-- settings
Config.Prop = 'p_still04x' -- prop used for the moonshine
Config.Prop2 = 'p_table05x' -- prop used for the crafttable
Config.BrewTime = 30000 -- brewtime in milliseconds
-- settings
Config.MenuKeybind          = 'J'
Config.MaxPropCount         = 5 -- maximum props
Config.MaintenancePerCycle  = 1 -- $ amount for prop maintenance
Config.PurgeStorage         = true
Config.BillingCycle         = 1 -- will remove credit every x hour/s
Config.ServerNotify         = true

-- blacksmith crafting


Config.MoonCrafting = {
    {   title =  'Moonshine',
        category = 'Alcohol',
        crafttime = 30000,
        icon = 'fa-solid fa-screwdriver-wrench',
        ingredients = {
            [1] = { item = "moonshinemash",   amount = 1 },
			[2] = { item = "wood",  amount = 1 },
        },
        receive = "moonshine",
        giveamount = 1
    },
    {   title =  'Mash moonshine',
        category = 'mash',
        crafttime = 30000,
        icon = 'fa-solid fa-screwdriver-wrench',
        ingredients = { 
            [1] = { item = 'water',   amount = 1 },
			[2] = { item = 'corn',  amount = 1 },
			[3] = { item = 'sugar',  amount = 1 },
			[4] = { item = "bottle", amount = 1 },
        },
        receive = 'moonshinemash',
        giveamount = 2
    }, }

Config.Crafting = {
    {   title = 'coal',
        crafttime = 5000,
        category =  'clasic',
        ingredients = {
            [1] = { item = 'wood', amount = 2 },
        },
        receive = 'coal',
        giveamount = 1
    }, }