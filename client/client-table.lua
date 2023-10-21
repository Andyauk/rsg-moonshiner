local RSGCore = exports['rsg-core']:GetCoreObject()
local crafttableGroup = GetRandomIntInRange(0, 0xffffff)
local CoolDown = 0
local isBusy = false
local isLoggedIn = false
local PlayerGang = {}

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

local options = {}

local function craftRegAnim()
    local dict = "mech_inventory@crafting@fallbacks"
    lib.requestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
    local ped = PlayerPedId()
    TaskPlayAnim(ped, dict, "full_craft_and_stow", 1.0, -1.0, -1, 1, 0, false, false, false)
end

-- trigger promps
Citizen.CreateThread(function()
    while true do
        local sleep = 0
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        for k, v in pairs(Config.PlayerProps) do
            if v.proptype == 'crafttable' then
                if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, v.x, v.y, v.z, true) < 1.3 and not IsPedInAnyVehicle(PlayerPedId(), false) then
                    lib.showTextUI('['..Config.MenuKeybind..'] -'..Lang:t('lang_72'), {
                        position = "top-center",
                        icon = 'fa-solid fa-bars',
                        style = {
                            borderRadius = 0,
                            backgroundColor = '#82283E',
                            color = 'white'
                        }
                    })
                    if IsControlJustReleased(0, RSGCore.Shared.Keybinds[Config.MenuKeybind]) then
                        TriggerEvent('rsg-crafttable:client:CraftTableMenu', v.gang)
                    end
                else
                    lib.hideTextUI()
                end
            end
        end
        Wait(sleep)
    end
end)

--------------
-- MENUS
------------------------------------

local craftCategoryMenus = {}

for _, v in ipairs(Config.Crafting) do
    local craftIngredientsMetadata = {}

    for i, craftingredient in ipairs(v.ingredients) do
        table.insert(craftIngredientsMetadata, { 
            label = RSGCore.Shared.Items[craftingredient.item].label,
            value = craftingredient.amount
        })
    end
    local option = {
        title = v.title,
        icon = v.icon,
        --icon = 'fa-solid fa-pen-ruler',
        event = 'rsg-crafttable:client:checkingredients',
        metadata = craftIngredientsMetadata,
        args = {
            title = v.title,
            category = v.category,
            ingredients = v.ingredients,
            crafttime = v.crafttime,
            receive = v.receive,
            giveamount = v.giveamount
        }
    }

    if not craftCategoryMenus[v.category] then
        craftCategoryMenus[v.category] = {
            id = 'crafting_menu_' .. v.category,
            title = v.category,
            menu = 'crafting_main_menu',
            onBack = function() end,
            options = { option }
        }
    else
        table.insert(craftCategoryMenus[v.category].options, option)
    end
end

for category, craftMenuData in pairs(craftCategoryMenus) do
    RegisterNetEvent('rsg-crafttable:client:' .. category)
    AddEventHandler('rsg-crafttable:client:' .. category, function()
        lib.registerContext(craftMenuData)
        lib.showContext(craftMenuData.id)
    end)
end

RegisterNetEvent('rsg-crafttable:client:CraftTableMenu')
AddEventHandler('rsg-crafttable:client:CraftTableMenu', function(gang)
    local PlayerData = RSGCore.Functions.GetPlayerData()
    local playergang = PlayerData.gang.name
    if playergang == gang then
        local craftMenu = {
            id = 'crafting_main_menu',
            title = 'Crafting Menu',
            onBack = function() end,
            options = {}
        }

        for category, craftMenuData in pairs(craftCategoryMenus) do
            table.insert(craftMenu.options, {
                title = category,
                description = Lang:t('lang_63').. ' ' .. category,
                icon = 'fa-solid fa-pen-ruler',
                event = 'rsg-crafttable:client:' .. category,
                arrow = true
            })
        end
        lib.registerContext(craftMenu)
        lib.showContext(craftMenu.id)
    end
end)

------------------------------------
-- craft

RegisterNetEvent('rsg-crafttable:client:checkingredients', function(data)
    if isBusy then
    return
    else
        RSGCore.Functions.TriggerCallback('rsg-crafttable:server:checkingredients', function(hasRequired)
        if (hasRequired) then
            if Config.Debug == true then
                print("passed")
            end

            isBusy = not isBusy
            local player = PlayerPedId()
                Citizen.CreateThread(function()
                    LocalPlayer.state:set("inv_busy", true, true)
                    craftRegAnim()
                    if lib.progressCircle({
                        duration = data.crafttime,
                        position = 'bottom',
                        label = 'Crafting...', --Lang:t('lang_66'),
                        useWhileDead = false,
                        canCancel = false,
                        disableControl = true,
                        text = 'crafting...', --Lang:t('lang_66'),
                    }) then

                    TriggerServerEvent('rsg-crafttable:server:finishcrafting', data.ingredients, data.receive, data.giveamount)
                    LocalPlayer.state:set("inv_busy", false, true)
                    ClearPedTasks(player)
                    
                    -- Generate a random number between 0 and 1
                    local randomOdds = math.random()

                    -- Define a threshold for the police alert
                    local policeAlertThreshold = 0.0  -- Adjust this value as needed

                    if randomOdds < policeAlertThreshold then
                        TriggerServerEvent('police:server:policeAlert', Lang:t('lang_67'))
                    end

                    isBusy = not isBusy
                else
                    lib.notify({ title = Lang:t('lang_68'), description = Lang:t('lang_69'), type = 'error' })
                end
            end)
        else
                if Config.Debug == true then
                    print("failed")
                end
                lib.notify({ title = Lang:t('lang_70'), description = Lang:t('lang_71'), type = 'error' })
            end
        end, data.ingredients)
    end
end)