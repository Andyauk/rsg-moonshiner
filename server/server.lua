local RSGCore = exports['rsg-core']:GetCoreObject()

-----------------------------------------------------------------------
-- version checker
-----------------------------------------------------------------------
local function versionCheckPrint(_type, log)
    local color = _type == 'success' and '^2' or '^1'

    print(('^5['..GetCurrentResourceName()..']%s %s^7'):format(color, log))
end

local function CheckVersion()
    PerformHttpRequest('https://raw.githubusercontent.com/Rexshack-RedM/rsg-moonshiner/main/version.txt', function(err, text, headers)
        local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')

        if not text then 
            versionCheckPrint('error', 'Currently unable to run a version check.')
            return 
        end

        --versionCheckPrint('success', ('Current Version: %s'):format(currentVersion))
        --versionCheckPrint('success', ('Latest Version: %s'):format(text))
        
        if text == currentVersion then
            versionCheckPrint('success', 'You are running the latest version.')
        else
            versionCheckPrint('error', ('You are currently running an outdated version, please update to version %s'):format(text))
        end
    end)
end

-----------------------------------------------------------------------

-- use moonshine kit
RSGCore.Functions.CreateUseableItem("moonshinekit", function(source, item)
    local Player = RSGCore.Functions.GetPlayer(source)
    if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent('rsg-moonshiner:client:moonshinekit', source, item.name)
    end
end)

-- brew moonshine
RegisterServerEvent('rsg-moonshiner:server:givemoonshine')
AddEventHandler('rsg-moonshiner:server:givemoonshine', function(amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if amount == 1 then
        Player.Functions.RemoveItem('sugar', 1)
        Player.Functions.RemoveItem('corn', 1)
        Player.Functions.RemoveItem('water', 1)
        Player.Functions.AddItem('moonshine', 1)
        TriggerClientEvent("inventory:client:ItemBox", src, RSGCore.Shared.Items['moonshine'], "add")
        RSGCore.Functions.Notify(src, Lang:t('success.you_made_some_moonshine'), 'success')
    else
        RSGCore.Functions.Notify(src, Lang:t('error.something_went_wrong'), 'error')
        print('something went wrong with moonshine script could be exploint!')
    end
end)

-- sell moonshine at vendor
RegisterServerEvent('rsg-moonshiner:server:sellitem')
AddEventHandler('rsg-moonshiner:server:sellitem', function(amount, data)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local amount = tonumber(amount)
    local checkitem = Player.Functions.GetItemByName(data.item)
    if amount >= 0 then
        if checkitem ~= nil then
            local amountitem = Player.Functions.GetItemByName(data.item).amount
            if amountitem >= amount then
                totalcash = (amount * data.price) 
                Player.Functions.RemoveItem(data.item, amount)
                TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[data.item], "remove")
                Player.Functions.AddMoney('cash', totalcash)
                TriggerClientEvent('RSGCore:Notify', src, Lang:t('success.you_sold',{amount = amount,totalcash = totalcash}), 'success')
            else
                TriggerClientEvent('RSGCore:Notify', src, Lang:t('error.you_dont_have_that_much_on_you'), 'error')
            end
        else
            TriggerClientEvent('RSGCore:Notify', src, Lang:t('error.you_dont_have_an_item_on_you'), 'error')
        end
    else
        TriggerClientEvent('RSGCore:Notify', src, Lang:t('error.must_not_be_a_negative_value'), 'error')
    end
end)

RegisterServerEvent('rsg-moonshiner:server:startsmoke')
AddEventHandler('rsg-moonshiner:server:startsmoke', function(coords)
    local src = source
    TriggerClientEvent('rsg-moonshiner:client:startsmoke', -1, coords)
end)

--------------------------------------------------------------------------------------------------
-- start version check
--------------------------------------------------------------------------------------------------
CheckVersion()
