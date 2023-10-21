local RSGCore = exports['rsg-core']:GetCoreObject()
local GangCampGroup = GetRandomIntInRange(0, 0xffffff)
local CoolDown = 0
local SpawnedProps = {}
local isBusy = false
local PlayerGang = {}
local isBusy = false
local moonshinemashkit = 0
isLoggedIn = false
PlayerJob = {}


RegisterNetEvent('RSGCore:Client:OnPlayerLoaded')
AddEventHandler('RSGCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    PlayerJob = RSGCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('RSGCore:Client:OnJobUpdate')
AddEventHandler('RSGCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

function DrawText3Ds(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(9)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str,_x,_y)
end

------------------------------------------------------------------------------------------------------
-- craft menu
------------------------------------------------------------------------------------------------------
local options = {}

-- Animation crafting
local function moonRegAnim()
    local dict = "mech_inventory@crafting@fallbacks@modify_arrows"
    lib.requestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
    local ped = PlayerPedId()
    TaskPlayAnim(ped, dict, "craft_trans_hold", 1.0, -1.0, -1, 1, 0, false, false, false)
end

--------------------------------
--- menus crafting
local categoryMoonMenus = {}

for _, v in ipairs(Config.MoonCrafting) do
    local moonIngredientsMetadata = {}

    for i, ingredient in ipairs(v.ingredients) do
        table.insert(moonIngredientsMetadata, { label = RSGCore.Shared.Items[ingredient.item].label, value = ingredient.amount })
    end 
    local option = {
        title = v.title,
        icon = 'fa-solid fa-kitchen-set',
        event = 'rsg-moonshiner:client:checkingredients',
        metadata = moonIngredientsMetadata,
        args = {
            title = v.title,
            category = v.category,
            ingredients = v.ingredients,
            crafttime = v.crafttime,
            receive = v.receive,
            giveamount = v.giveamount
        }
    }

    if not categoryMoonMenus[v.category] then
        categoryMoonMenus[v.category] = {
            id = 'mooncrafting_menu_' .. v.category,
            title = v.category,
            menu = 'monshine_main_menu', --'mooncrafting_mainmenu',
            onBack = function() end,
            options = { option }
        }
    else
        table.insert(categoryMoonMenus[v.category].options, option)
    end
end

for category, MoonMenuData in pairs(categoryMoonMenus) do
    RegisterNetEvent('rsg-moonshiner:client:' .. category)
    AddEventHandler('rsg-moonshiner:client:' .. category, function()
        lib.registerContext(MoonMenuData)
        lib.showContext(MoonMenuData.id)
    end)
end

RegisterNetEvent('rsg-moonshiner:client:moonmenu')
AddEventHandler('rsg-moonshiner:client:moonmenu', function()
    local MoonMenu = {
        id = 'monshine_main_menu',
        title = Lang:t('lang_62'),
        menu = 'moonshiner_mainmenu', --'mooncrafting_mainmenu',
        onBack = function() end,
        options = {}
    }

    for category, MoonMenuData in pairs(categoryMoonMenus) do
        table.insert(MoonMenu.options, {
            title = category,
            description = Lang:t('lang_63') .. category,
            icon = 'fa-solid fa-kitchen-set',
            event = 'rsg-moonshiner:client:' .. category,
            -- arrow = true,
        })
    end

    lib.registerContext(MoonMenu)
    lib.showContext(MoonMenu.id)
end)

--- check ingredient craft
RegisterNetEvent('rsg-moonshiner:client:checkingredients', function(data)
        if isBusy then
        return
        else
            RSGCore.Functions.TriggerCallback('rsg-moonshiner:server:checkingredients', function(hasRequired)
            if hasRequired then
                if Config.Debug == true then
                    print("passed")
                end
                --local success = lib.skillCheck({'easy', 'easy', {areaSize = 80, speedMultiplier = 1}, 'easy'}, {'w', 'a', 's', 'd'})
                --if success == true then
                
                    isBusy = not isBusy
                    Citizen.InvokeNative(0x239879FC61C610CC, smoke, 0.0, 0.0, 0.0, false)
                    local player = PlayerPedId()
                    local playerCoords = GetEntityCoords(player)

                    Citizen.CreateThread(function()
                        LocalPlayer.state:set("inv_busy", true, true)

                        -- Start your animation here 
                        moonRegAnim()
                        --RSGCore.Functions.RequestAnimDict('script_common@shared_scenarios@kneel@mourn@female@a@base')
                        --TaskPlayAnimAdvanced(player, 'script_common@shared_scenarios@kneel@mourn@female@a@base', 'base', 
                        --    playerCoords.x, playerCoords.y, playerCoords.z, 0, 0, 0, 1.0, 1.0, Config.BrewTime, 1, 0, 0, 0)
                        TriggerServerEvent('rsg-moonshiner:server:startsmoke', playerCoords)

                        -- Start the progress circle (similar a la animación de Moonshine)
                        if lib.progressCircle({
                            duration = data.crafttime,
                            position = 'bottom',
                            label = 'Mixing up some mash...', --Lang:t('lang_66'),
                            useWhileDead = false,
                            canCancel = false,
                            disableControl = true,
                            text = 'Mixing up some mash...', --Lang:t('lang_66'),
                        }) then
                            -- Give the player the crafted item immediately when the timer is done
                            TriggerServerEvent('rsg-moonshiner:server:finishcrafting', data.ingredients, data.receive, data.giveamount)
                            LocalPlayer.state:set("inv_busy", false, true)
                            ClearPedTasks(player)
                            
                             -- Generate a random number between 0 and 1
                            local randomOdds = math.random()

                             -- Define a threshold for the police alert
                            local policeAlertThreshold = 0.5  -- Adjust this value as needed

                             -- Check if the random number is below the threshold
                            if randomOdds < policeAlertThreshold then
                                TriggerServerEvent('police:server:policeAlert', Lang:t('lang_67'))
                            end

                            PlaySoundFrontend("SELECT", "RDRO_Character_Creator_Sounds", true, 0)
                            Citizen.InvokeNative(0x239879FC61C610CC, smoke, 1.0, 1.0, 1.0, false)
                            isBusy = not isBusy
                        else
                            -- Handle cancellation or failure
                            lib.notify({ title = Lang:t('lang_68'), description = Lang:t('lang_69'), type = 'error' })
                        end
                    end)
                --end
            else
                if Config.Debug == true then
                    print("failed")
                end
                lib.notify({ title = Lang:t('lang_70'), description = Lang:t('lang_71'), type = 'error' })
            end
        end, data.ingredients)
    end
end)
