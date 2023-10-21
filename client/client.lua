local RSGCore = exports['rsg-core']:GetCoreObject()
local moonshinerGroup = GetRandomIntInRange(0, 0xffffff)
local CoolDown = 0
local SpawnedProps = {}
local isBusy = false
local isLoggedIn = false
local PlayerGang = {}
local moonshinekit = 0
local fx_group = "scr_adv_sok"
local fx_name = "scr_adv_sok_torchsmoke"
local smoke

isLoggedIn = false
PlayerJob = {}



--------------------------------------------------------------------------------------

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        PlayerGang = RSGCore.Functions.GetPlayerData().gang
    end
end)

RegisterNetEvent('RSGCore:Client:OnPlayerLoaded', function()
    PlayerGang = RSGCore.Functions.GetPlayerData().gang
end)

RegisterNetEvent('RSGCore:Client:OnJobUpdate', function(JobInfo)
    PlayerGang = InfoGang
end)

--------------------------------------------------------------------------------------

-- spawn props
Citizen.CreateThread(function()
    while true do
        Wait(150)

        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local InRange = false

        for i = 1, #Config.PlayerProps do
            local dist = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.PlayerProps[i].x, Config.PlayerProps[i].y, Config.PlayerProps[i].z, true)
            if dist >= 50.0 then goto continue end

            local hasSpawned = false
            InRange = true

            for z = 1, #SpawnedProps do
                local p = SpawnedProps[z]

                if p.id == Config.PlayerProps[i].id then
                    hasSpawned = true
                end
            end

            if hasSpawned then goto continue end

            local modelHash = Config.PlayerProps[i].hash
            local data = {}
            
            if not HasModelLoaded(modelHash) then
                RequestModel(modelHash)
                while not HasModelLoaded(modelHash) do
                    Wait(1)
                end
            end
            
            
            data.id = Config.PlayerProps[i].id
            data.obj = CreateObject(modelHash, Config.PlayerProps[i].x, Config.PlayerProps[i].y, Config.PlayerProps[i].z -1.2, false, false, false)
            SetEntityHeading(data.obj, Config.PlayerProps[i].h)
            SetEntityAsMissionEntity(data.obj, true)
            PlaceObjectOnGroundProperly(data.obj)
            Wait(1000)
            FreezeEntityPosition(data.obj, true)
            SetModelAsNoLongerNeeded(data.obj)

            -- veg modifiy
            local veg_modifier_sphere = 0
            
            if veg_modifier_sphere == nil or veg_modifier_sphere == 0 then
                local veg_radius = 3.0
                local veg_Flags =  1 + 2 + 4 + 8 + 16 + 32 + 64 + 128 + 256
                local veg_ModType = 1
                
                veg_modifier_sphere = Citizen.InvokeNative(0xFA50F79257745E74, Config.PlayerProps[i].x, Config.PlayerProps[i].y, Config.PlayerProps[i].z, veg_radius, veg_ModType, veg_Flags, 0)
                
            else
                Citizen.InvokeNative(0x9CF1836C03FB67A2, Citizen.PointerValueIntInitialized(veg_modifier_sphere), 0)
                veg_modifier_sphere = 0
            end

            SpawnedProps[#SpawnedProps + 1] = data
            hasSpawned = false

            ::continue::
        end

        if not InRange then
            Wait(5000)
        end
    end
end)

-- get closest prop
function GetClosestProp()
    local dist = 1000
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local prop = {}

    for i = 1, #Config.PlayerProps do
        local xd = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.PlayerProps[i].x, Config.PlayerProps[i].y, Config.PlayerProps[i].z, true)

        if xd < dist then
            dist = xd
            prop = Config.PlayerProps[i]
        end
    end

    return prop
end

-- trigger promps
Citizen.CreateThread(function()
    while true do
        local sleep = 0
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        for k, v in pairs(Config.PlayerProps) do
            if v.proptype == 'moonshinekit' then
                if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, v.x, v.y, v.z, true) < 1.3 and not IsPedInAnyVehicle(PlayerPedId(), false) then
                    lib.showTextUI('['..Config.MenuKeybind..'] -'..Lang:t('lang_15'), {
                        position = "top-center",
                        icon = 'fa-solid fa-bars',
                        style = {
                            borderRadius = 0,
                            backgroundColor = '#82283E',
                            color = 'white'
                        }
                    })
                    if IsControlJustReleased(0, RSGCore.Shared.Keybinds[Config.MenuKeybind]) then
                        TriggerEvent('rsg-moonshine:client:mainmenu', v.gang)
                    end
                else
                    lib.hideTextUI()
                end
            end
        end
        Wait(sleep)
    end
end)

-- camp menu
RegisterNetEvent('rsg-moonshine:client:mainmenu', function(gang)
    local PlayerData = RSGCore.Functions.GetPlayerData()
    local playergang = PlayerData.gang.name
    if playergang == gang then
        lib.registerContext({
            id = 'moonshiner_mainmenu',
            title = Lang:t('lang_15'),
            options = {

                {   title = Lang:t('lang_16'),
                    icon = 'fa-solid fa-boxes-packing',
                    description = Lang:t('lang_17'),
                    event = 'rsg-moonshiner:client:moonmenu',
                    args = { gang = playergang },
                    arrow = true
                },
                {   title = Lang:t('lang_18'),
                    description = Lang:t('lang_19'),
                    icon = 'fa-solid fa-user-tie',
                    event = 'rsg-gangmenu:client:mainmenu',
                    arrow = true
                },
                {   title = Lang:t('lang_20'),
                    description = Lang:t('lang_21'),
                    icon = 'fa-solid fa-campground',
                    event = 'rsg-moonshine:client:campitemsmenu',
                    args = { gang = playergang },
                    arrow = true
                },
            }
        })
        lib.showContext("moonshiner_mainmenu")
    else
        lib.registerContext({
            id = 'moonshiner_robmenu',
            title = Lang:t('lang_22'),
            options = {
                {   title = Lang:t('lang_23'),
                    description = Lang:t('lang_24'),
                    icon = 'fa-solid fa-mask',
                    event = 'rsg-moonshine:client:robmoonshiner',
                    args = { gang = gang },
                    arrow = true
                },
            }
        })
        lib.showContext("moonshiner_robmenu")
    end
end)

-- camp deployed
RegisterNetEvent('rsg-moonshine:client:campitemsmenu')
AddEventHandler('rsg-moonshine:client:campitemsmenu', function(data)
    local options = {}
    for k, v in pairs(Config.PlayerProps) do
        if v.gang == data.gang then
            options[#options + 1] = {
                title = RSGCore.Shared.Items[v.proptype].label,
                icon = 'fa-solid fa-box',
                event = 'rsg-moonshine:client:propmenu',
                args = { propid = v.id },
                arrow = true,
            }
        end
        lib.registerContext({
            id = 'moonshiner_deployed',
            title = Lang:t('lang_25'),
            menu = 'moonshiner_mainmenu',
            onBack = function() end,
            position = 'top-right',
            options = options
        })
        lib.showContext('moonshiner_deployed')     
    end
end)

RegisterNetEvent('rsg-moonshine:client:propmenu', function(data)
    RSGCore.Functions.TriggerCallback('rsg-moonshine:server:getallpropdata', function(result)
        lib.registerContext({
            id = 'moonshiner_propmenu',
            title = RSGCore.Shared.Items[result[1].proptype].label,
            menu = 'moonshiner_deployed',
            onBack = function() end,
            options = {
                {
                    title = Lang:t('lang_26')..result[1].credit,
                    description = Lang:t('lang_27'),
                    icon = 'fa-solid fa-coins',
                },
                {
                    title = Lang:t('lang_28'),
                    description = Lang:t('lang_29'),
                    icon = 'fa-solid fa-plus',
                    iconColor = 'green',
                    event = 'rsg-moonshine:client:addcredit',
                    args = { 
                        propid = result[1].propid,
                        credit = result[1].credit
                    },
                    arrow = true
                },
                {
                    title = Lang:t('lang_30'),
                    description = Lang:t('lang_31'),
                    icon = 'fa-solid fa-minus',
                    iconColor = 'red',
                    event = 'rsg-moonshine:client:removecredit',
                    args = { 
                        propid = result[1].propid,
                        credit = result[1].credit
                    },
                    arrow = true
                },
                {
                    title = Lang:t('lang_32'),
                    description = Lang:t('lang_33'),
                    icon = 'fa-solid fa-box',
                    iconColor = 'red',
                    serverEvent = 'rsg-moonshine:server:destroyProp',
                    args = { 
                        propid = result[1].propid,
                        item = result[1].proptype
                    },
                    arrow = true
                },
            }
        })
        lib.showContext("moonshiner_propmenu")
        StopSmokeEffect()
    end, data.propid)
end)

-- add credit
RegisterNetEvent('rsg-moonshine:client:addcredit', function(data)
    local PlayerData = RSGCore.Functions.GetPlayerData()
    local cash = tonumber(PlayerData.money['cash'])
    local input = lib.inputDialog(Lang:t('lang_28'), {
        { 
            label = Lang:t('lang_34'),
            type = 'input',
            required = true,
            icon = 'fa-solid fa-dollar-sign'
        },
    })
    
    if not input then
        return
    end
    
    if tonumber(input[1]) == nil then
        return
    end

    if cash >= tonumber(input[1]) then
        local creditadjust = data.credit + tonumber(input[1])
        TriggerServerEvent('rsg-moonshine:server:addcredit', creditadjust, tonumber(input[1]), data.propid )
    else
        lib.notify({ title = Lang:t('lang_35'), description = Lang:t('lang_36'), type = 'error' })
    end
end)

-- remove credit
RegisterNetEvent('rsg-moonshine:client:removecredit', function(data)
    local PlayerData = RSGCore.Functions.GetPlayerData()
    local cash = tonumber(PlayerData.money['cash'])
    local input = lib.inputDialog(Lang:t('lang_30'), {
        { 
            label = Lang:t('lang_34'),
            type = 'input',
            required = true,
            icon = 'fa-solid fa-dollar-sign'
        },
    })
    
    if not input then
        return
    end
    
    if tonumber(input[1]) == nil then
        return
    end
    if tonumber(input[1]) < tonumber(data.credit)  then
        local creditadjust = tonumber(data.credit) - tonumber(input[1])
        TriggerServerEvent('rsg-moonshine:server:removecredit', creditadjust, tonumber(input[1]), data.propid )
    else
        lib.notify({ title = Lang:t('lang_35'), description = Lang:t('lang_37'), type = 'error' })
    end
end)

-- Remove prop object with progress circle and animation
RegisterNetEvent('rsg-moonshine:client:removePropObject')
AddEventHandler('rsg-moonshine:client:removePropObject', function(prop)
    local player = PlayerPedId()
    local playerCoords = GetEntityCoords(player)

    -- Start the animation here
    RSGCore.Functions.RequestAnimDict('script_common@shared_scenarios@kneel@mourn@female@a@base')
    TaskPlayAnimAdvanced(player, 'script_common@shared_scenarios@kneel@mourn@female@a@base', 'base', 
        playerCoords.x, playerCoords.y, playerCoords.z, 0, 0, 0, 1.0, 1.0, Config.BrewTime, 1, 0, 0, 0)

    TriggerServerEvent('rsg-moonshiner:server:startsmoke', playerCoords)

    -- Start the progress circle
    if lib.progressCircle({
        duration = Config.BrewTime,
        position = 'bottom',
        label = 'Removing The Equipment...', -- Lang:t('lang_38'),
        useWhileDead = false,
        canCancel = false,
        anim = {
            dict = 'script_common@shared_scenarios@kneel@mourn@female@a@base',
            clip = 'empathise_headshake_f_001',
            flag = 15,
        },
        disableControl = true,
        text = 'Removing The Equipment...', -- Lang:t('lang_38'),
    }) then
        -- Code to execute if the progress circle is successfully started
        print("Removing prop object progress started.")

        -- Add your prop removal logic here
        for i = 1, #SpawnedProps do
            local o = SpawnedProps[i]

            if o.id == prop then
                SetEntityAsMissionEntity(o.obj, false)
                FreezeEntityPosition(o.obj, false)
                DeleteObject(o.obj)

                -- Call the function to stop the smoke effect
                StopSmokeEffect()
            end
        end
        -- Additional logic after prop removal can be added here
        Wait(1000)
        if lib.isTextUIOpen() then
            Wait(500)
            lib.hideTextUI()
        end
    else
        -- Handle cancelation or failure
        lib.notify({ title = Lang:t('lang_39'), description = Lang:t('lang_40'), type = 'error' })
    end
end)

-- update props
RegisterNetEvent('rsg-moonshine:client:updatePropData')
AddEventHandler('rsg-moonshine:client:updatePropData', function(data)
    Config.PlayerProps = data
end)

RegisterNetEvent('rsg-moonshine:client:placeNewProp')
AddEventHandler('rsg-moonshine:client:placeNewProp', function(proptype, pHash, item)
    local PlayerData = RSGCore.Functions.GetPlayerData()
    local playergang = PlayerData.gang.name

    if playergang == 'none' then
        lib.notify({ title = Lang:t('lang_41'), description = Lang:t('lang_42'), type = 'error' })
        return
    end

    local pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 3.0, 0.0)
    local heading = GetEntityHeading(PlayerPedId())
    local ped = PlayerPedId()

    if CanPlacePropHere(pos) and not IsPedInAnyVehicle(PlayerPedId(), false) and not isBusy then
        isBusy = true
        local anim1 = `WORLD_HUMAN_CROUCH_INSPECT`
        FreezeEntityPosition(ped, true)
        TaskStartScenarioInPlace(ped, anim1, 0, true)

        -- Start the progress circle
        if lib.progressCircle({
            duration = 10000, -- Adjust the duration as needed
            position = 'bottom',
            label = Lang:t('lang_43'),
            useWhileDead = false,
            canCancel = true, -- Allow the player to cancel the action
            disableControl = true,
            
        }) then
            -- The player completed the action

            ClearPedTasks(ped)
            FreezeEntityPosition(ped, false)
            TriggerServerEvent('rsg-moonshine:server:newProp', proptype, pos, heading, pHash, playergang)
            isBusy = false
        else
            -- The player canceled the action or it was interrupted
            lib.notify({ title = Lang:t('lang_44'), description = Lang:t('lang_45'), type = 'error' })

            ClearPedTasks(ped)
            FreezeEntityPosition(ped, false)
            isBusy = false
        end

        return
    end

    lib.notify({ title = Lang:t('lang_46'), description = Lang:t('lang_47'), type = 'error' })
    Wait(3000)
end)

-- check to see if prop can be place here
function CanPlacePropHere(pos)
    local canPlace = true

    local ZoneTypeId = 1
    local x,y,z =  table.unpack(GetEntityCoords(PlayerPedId()))
    local town = Citizen.InvokeNative(0x43AD8FC02B429D33, x,y,z, ZoneTypeId)
    if town ~= false then
        canPlace = false
    end

    for i = 1, #Config.PlayerProps do
        if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.PlayerProps[i].x, Config.PlayerProps[i].y, Config.PlayerProps[i].z, true) < 1.3 then
            canPlace = false
        end
    end
    
    return canPlace
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    for i = 1, #SpawnedProps do
        local props = SpawnedProps[i].obj

        SetEntityAsMissionEntity(props, false)
        FreezeEntityPosition(props, false)
        DeleteObject(props)
    end
end)

-- rob gang camp
RegisterNetEvent('rsg-moonshine:client:robmoonshiner')
AddEventHandler('rsg-moonshine:client:robmoonshiner', function(data)
    local PlayerData = RSGCore.Functions.GetPlayerData()
    local playergang = PlayerData.gang.name
    if playergang ~= data.gang then
        local hasItem = RSGCore.Functions.HasItem('lockpick', 1)
        if hasItem == true then
            TriggerServerEvent('rsg-moonshine:server:removeitem', 'lockpick', 1)
            local success = lib.skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 2}, 'hard'}, {'w', 'a', 's', 'd'})
            if success == true then
                TriggerServerEvent("inventory:server:OpenInventory", "stash", "gang_" .. data.gang)
            else
                lib.notify({ title = Lang:t('lang_48'), description = Lang:t('lang_49'), type = 'error' })
            end
        else
            lib.notify({ title = Lang:t('lang_50'), description = Lang:t('lang_51'), type = 'error' })
        end
    else
        lib.notify({ title = Lang:t('lang_52'), description = Lang:t('lang_53'), type = 'error' })
    end
end)



-- Start the smoke effect

smoke = nil

RegisterNetEvent('rsg-moonshiner:client:startsmoke')
AddEventHandler('rsg-moonshiner:client:startsmoke', function(smokecoords)
    if smoke == nil then
        UseParticleFxAsset(fx_group)
        smoke = StartParticleFxLoopedAtCoord(fx_name, smokecoords, -2, 0.0, 0.0, 2.0, false, false, false, true)
        Citizen.InvokeNative(0x9DDC222D85D5AF2A, smoke, 10.0)
        SetParticleFxLoopedAlpha(smoke, 1.0)
        SetParticleFxLoopedColour(smoke, 1.0, 1.0, 1.0, false)
    end
end)

-- Stop the smoke effect
function StopSmokeEffect()
    if smoke then
        StopParticleFxLooped(smoke, 0)
        smoke = nil
    end
end


