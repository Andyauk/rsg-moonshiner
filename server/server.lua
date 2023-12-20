local RSGCore = exports['rsg-core']:GetCoreObject()
local PropsLoaded = false
local CollectedPoop = {}

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

-- use moonshinekit
RSGCore.Functions.CreateUseableItem("moonshinekit", function(source)
    local src = source
    TriggerClientEvent('rsg-moonshine:client:placeNewProp', src, 'moonshinekit', `p_still04x`, 'moonshinekit')
end)

-- use fort post
RSGCore.Functions.CreateUseableItem("barricade_exp", function(source)
    local src = source
    TriggerClientEvent('rsg-moonshine:client:placeNewProp', src, 'barricade_exp', `mp009_p_mp_fort_modular_01x`, 'fortmodular')
end)

-- use camp fort mercer station
RSGCore.Functions.CreateUseableItem("barricade_avd", function(source)
    local src = source
    TriggerClientEvent('rsg-moonshine:client:placeNewProp', src, 'barricade_avd', `mp005_p_fortmercerbarricade01x`, 'campfortmercer')
end)

-- use camp barricade 
RSGCore.Functions.CreateUseableItem("barricade", function(source)
    local src = source
    TriggerClientEvent('rsg-moonshine:client:placeNewProp', src, 'barricade', `p_barricadewood_lrg01x`, 'campbarricade')
end)

-- use crafttable
RSGCore.Functions.CreateUseableItem("crafttable", function(source)
    local src = source
    TriggerClientEvent('rsg-moonshine:client:placeNewProp', src, 'crafttable', `p_table05x`, 'crafttable')
end)

-- get all prop data
RSGCore.Functions.CreateCallback('rsg-moonshine:server:getallpropdata', function(source, cb, propid)
    MySQL.query('SELECT * FROM moonshiner_props WHERE propid = ?', {propid}, function(result)
        if result[1] then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

-----------------------------------------------------------------------

-- update prop data
CreateThread(function()
    while true do
        Wait(5000)

        if PropsLoaded then
            TriggerClientEvent('rsg-moonshine:client:updatePropData', -1, Config.PlayerProps)
        end
    end
end)

CreateThread(function()
    TriggerEvent('rsg-moonshine:server:getProps')
    PropsLoaded = true
end)

RegisterServerEvent('rsg-moonshine:server:saveProp')
AddEventHandler('rsg-moonshine:server:saveProp', function(data, propId, citizenid, gang, proptype)
    local datas = json.encode(data)

    MySQL.Async.execute('INSERT INTO moonshiner_props (properties, propid, citizenid, gang, proptype) VALUES (@properties, @propid, @citizenid, @gang, @proptype)',
    {
        ['@properties'] = datas,
        ['@propid'] = propId,
        ['@citizenid'] = citizenid,
        ['@gang'] = gang,
        ['@proptype'] = proptype
    })
end)

-- new prop
RegisterServerEvent('rsg-moonshine:server:newProp')
AddEventHandler('rsg-moonshine:server:newProp', function(proptype, location, heading, hash, gang)
    local src = source
    local propId = math.random(111111, 999999)
    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid

    local PropData =
    {
        id = propId,
        proptype = proptype,
        x = location.x,
        y = location.y,
        z = location.z,
        h = heading,
        hash = hash,
        builder = Player.PlayerData.citizenid,
        gang = gang,
        buildttime = os.time()
    }

    local PropCount = 0

    for _, v in pairs(Config.PlayerProps) do
        if v.builder == Player.PlayerData.citizenid then
            PropCount = PropCount + 1
        end
    end

    if PropCount >= Config.MaxPropCount then
        lib.notify({ title = Lang:t('lang_0'), description = Lang:t('lang_1'), type = 'error' })
    else
        table.insert(Config.PlayerProps, PropData)
        Player.Functions.RemoveItem(proptype, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[proptype], "remove")
        TriggerEvent('rsg-moonshine:server:saveProp', PropData, propId, citizenid, gang, proptype)
        TriggerEvent('rsg-moonshine:server:updateProps')
    end
end)

-- destory prop
RegisterServerEvent('rsg-moonshine:server:destroyProp')
AddEventHandler('rsg-moonshine:server:destroyProp', function(data)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    for k, v in pairs(Config.PlayerProps) do
        if v.id == data.propid then
            table.remove(Config.PlayerProps, k)
        end
    end

    TriggerClientEvent('rsg-moonshine:client:removePropObject', src, data.propid)
    TriggerEvent('rsg-moonshine:server:PropRemoved', data.propid)
    TriggerEvent('rsg-moonshine:server:updateProps')
    Player.Functions.AddItem(data.item, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[data.item], "add")
end)

RegisterServerEvent('rsg-moonshine:server:updateProps')
AddEventHandler('rsg-moonshine:server:updateProps', function()
    local src = source

    TriggerClientEvent('rsg-moonshine:client:updatePropData', src, Config.PlayerProps)   
end)

-- update props
RegisterServerEvent('rsg-moonshine:server:updateCampProps')
AddEventHandler('rsg-moonshine:server:updateCampProps', function(id, data)
    local result = MySQL.query.await('SELECT * FROM moonshiner_props WHERE propid = @propid',
    {
        ['@propid'] = id
    })

    if not result[1] then return end

    local newData = json.encode(data)

    MySQL.Async.execute('UPDATE moonshiner_props SET properties = @properties WHERE propid = @id',
    {
        ['@properties'] = newData,
        ['@id'] = id
    })
end)

-- remove props
RegisterServerEvent('rsg-moonshine:server:PropRemoved')
AddEventHandler('rsg-moonshine:server:PropRemoved', function(propId)
    local result = MySQL.query.await('SELECT * FROM moonshiner_props')

    if not result then return end

    for i = 1, #result do
        local propData = json.decode(result[i].properties)

        if propData.id == propId then
            MySQL.Async.execute('DELETE FROM moonshiner_props WHERE id = @id',
            {
                ['@id'] = result[i].id
            })

            for k, v in pairs(Config.PlayerProps) do
                if v.id == propId then
                    table.remove(Config.PlayerProps, k)
                end
            end
        end
    end
end)

-- get props
RegisterServerEvent('rsg-moonshine:server:getProps')
AddEventHandler('rsg-moonshine:server:getProps', function()
    local result = MySQL.query.await('SELECT * FROM moonshiner_props')

    if not result[1] then return end

    for i = 1, #result do
        local propData = json.decode(result[i].properties)
        --print('loading '..propData.proptype..' prop with ID: '..propData.id)
        table.insert(Config.PlayerProps, propData)
    end
end)

-- add credit
RegisterNetEvent('rsg-moonshine:server:addcredit', function(newcredit, removemoney, propid)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    -- remove money
    Player.Functions.RemoveMoney("cash", removemoney, "moonshiner-credit")
    -- sql update
    MySQL.update('UPDATE moonshiner_props SET credit = ? WHERE propid = ?', {newcredit, propid})
    -- notify
    lib.notify({ title = Lang:t('lang_2'), description = Lang:t('lang_3'), type = 'success' })
    Wait(5000)
    lib.notify({ title = Lang:t('lang_4')..newcredit, description = Lang:t('lang_5'), type = 'inform' })
end)

-- remove credit
RegisterNetEvent('rsg-moonshine:server:removecredit', function(newcredit, addmoney, propid)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    -- remove money
    Player.Functions.AddMoney("cash", addmoney, "moonshiner-credit")
    -- sql update
    MySQL.update('UPDATE moonshiner_props SET credit = ? WHERE propid = ?', {newcredit, propid})
    -- notify
    lib.notify({ title = Lang:t('lang_6'), description = Lang:t('lang_7'), type = 'success' })
    Wait(5000)
    lib.notify({ title = Lang:t('lang_4')..newcredit, description = Lang:t('lang_5'), type = 'inform' })
end)

-- remove item
RegisterServerEvent('rsg-moonshine:server:removeitem')
AddEventHandler('rsg-moonshine:server:removeitem', function(item, amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    Player.Functions.RemoveItem(item, amount)

    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[item], "remove")
end)

--------------------------------------------------------------------------------------------------
-- moonshiner upkeep system
--------------------------------------------------------------------------------------------------
UpkeepInterval = function()
    local result = MySQL.query.await('SELECT * FROM moonshiner_props')

    if not result then goto continue end

    for i = 1, #result do
        local row = result[i]

        if row.credit >= Config.MaintenancePerCycle then
            local creditadjust = (row.credit - Config.MaintenancePerCycle)

            MySQL.update('UPDATE moonshiner_props SET credit = ? WHERE propid = ?',
            {
                creditadjust,
                row.propid
            })
        else
            MySQL.update('DELETE FROM moonshiner_props WHERE propid = ?', {row.propid})

            if Config.PurgeStorage then
                MySQL.update('DELETE FROM stashitems WHERE stash = ?', { 'gang_'..row.gang })
            end
            
            if Config.ServerNotify == true then
                print('object with the id of '..row.propid..' owned by the gang '..row.gang.. ' was deleted')
            end

            TriggerEvent('rsg-log:server:CreateLog', 'gangmenu', 'Gang Object Lost', 'red', row.gang..' prop with ID: '..row.propid..' has been lost due to non maintenance!')
        end
    end

    ::continue::

    print('moonshiner upkeep cycle complete')

    SetTimeout(Config.BillingCycle * (60 * 60 * 1000), UpkeepInterval) -- hours
    --SetTimeout(Config.BillingCycle * (60 * 1000), UpkeepInterval) -- mins (for testing)
end

SetTimeout(Config.BillingCycle * (60 * 60 * 1000), UpkeepInterval) -- hours
--SetTimeout(Config.BillingCycle * (60 * 1000), UpkeepInterval) -- mins (for testing)


----give moonshine and chance of breaking
RegisterServerEvent('rsg-moonshiner:server:givemoonshine')
AddEventHandler('rsg-moonshiner:server:givemoonshine', function(amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    if amount == 1 then
        Player.Functions.RemoveItem('wood', 1)
        Player.Functions.RemoveItem('moonshinemash', 1)
        
        Player.Functions.AddItem('moonshine', 2)
        TriggerClientEvent("inventory:client:ItemBox", src, RSGCore.Shared.Items['moonshine'], "add")
        lib.notify({ title = Lang:t('lang_8'), description = Lang:t('lang_9'), type = 'success' }) 
    else
        lib.notify({ title = Lang:t('lang_10'), description = Lang:t('lang_11'), type = 'error' })
        --print('something went wrong with moonshine script, could be an exploit!')
    end
end)

--start smoke
RegisterServerEvent('rsg-moonshiner:server:startsmoke')
AddEventHandler('rsg-moonshiner:server:startsmoke', function(pos)
    local src = source
    TriggerClientEvent('rsg-moonshiner:client:startsmoke', -1, pos)
end)


--------------------------------------------------------------------------------------------------
-- version check
--------------------------------------------------------------------------------------------------
CheckVersion()
