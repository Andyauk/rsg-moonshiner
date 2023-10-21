local RSGCore = exports['rsg-core']:GetCoreObject()

local CoolDown = 0
local SpawnedProps = {}
local isBusy = false
local PlayerGang = {}
local isBusy = false
local moonshinemashkit = 0
isLoggedIn = false
PlayerJob = {}

-----------------------------------------------------------------------------
-- crafting moonshine
-----------------------------------------------------------------------------

RSGCore.Functions.CreateCallback('rsg-moonshiner:server:checkingredients', function(source, cb, ingredients)
    local src = source
    local hasItems = false
    local icheck = 0
    local Player = RSGCore.Functions.GetPlayer(src)
    for k, v in pairs(ingredients) do
        if Player.Functions.GetItemByName(v.item) and Player.Functions.GetItemByName(v.item).amount >= v.amount then
            icheck = icheck + 1
            if icheck == #ingredients then
                cb(true)
            end
        else
            lib.notify({ title = Lang:t('lang_10'), description = Lang:t('lang_12')..v.item..' !', type = 'error' })
            cb(false)
            return
        end
    end
end)

-- craftable

RSGCore.Functions.CreateCallback('rsg-crafttable:server:checkingredients', function(source, cb, ingredients)
    local src = source
    local hasItems = false
    local icheck = 0
    local Player = RSGCore.Functions.GetPlayer(src)
    for k, v in pairs(ingredients) do
        if Player.Functions.GetItemByName(v.item) and Player.Functions.GetItemByName(v.item).amount >= v.amount then
            icheck = icheck + 1
            if icheck == #ingredients then
                cb(true)
            end
        else
            lib.notify({ title = Lang:t('lang_10'), description = Lang:t('lang_12')..v.item..' !', type = 'error' })
            cb(false)
            return
        end
    end
end)

-- finish crafting
RegisterServerEvent('rsg-moonshiner:server:finishcrafting')
AddEventHandler('rsg-moonshiner:server:finishcrafting', function(ingredients, receive, giveamount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    local firstname = Player.PlayerData.charinfo.firstname
    local lastname = Player.PlayerData.charinfo.lastname
    -- remove ingredients
    for k, v in pairs(ingredients) do
        if Config.Debug == true then
            print(v.item)
            print(v.amount)
        end
        Player.Functions.RemoveItem(v.item, v.amount)
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[v.item], "remove")
    end
    -- add crafting item
    Player.Functions.AddItem(receive, giveamount)
    local labelReceive = RSGCore.Shared.Items[receive].label
    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[receive], "add")
    lib.notify({ title = Lang:t('lang_13'), description = Lang:t('lang_14')..labelReceive, type = 'success' })
    Wait(5000)
    TriggerEvent('rsg-log:server:CreateLog', 'crafting', 'looted cook 🌟'..labelReceive, 'orange', firstname..' '..lastname..' found Loot baby!')
end)

-- finish crafting
RegisterServerEvent('rsg-crafttable:server:finishcrafting')
AddEventHandler('rsg-crafttable:server:finishcrafting', function(ingredients, receive, giveamount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    local firstname = Player.PlayerData.charinfo.firstname
    local lastname = Player.PlayerData.charinfo.lastname
-- remove ingredients
    for k, v in pairs(ingredients) do
        if Config.Debug == true then
            print(v.item)
            print(v.amount)
        end
        Player.Functions.RemoveItem(v.item, v.amount)
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[v.item], "remove")
    end
    -- add crafting item
    Player.Functions.AddItem(receive, giveamount)
    local labelReceive = RSGCore.Shared.Items[receive].label
    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[receive], "add")
    lib.notify({ title = Lang:t('lang_13'), description = Lang:t('lang_14')..labelReceive, type = 'success' })
    Wait(5000)
    TriggerEvent('rsg-log:server:CreateLog', 'crafting', 'looted cook 🌟'..labelReceive, 'orange', firstname..' '..lastname..' found Loot baby!')
end)
