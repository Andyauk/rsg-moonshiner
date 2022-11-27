local npc = {}
local blip = {}

function modelrequest( model )
    Citizen.CreateThread(function()
        RequestModel( model )
    end)
end

AddEventHandler("onResourceStop",function(resourceName)
    for k, v in pairs(Config.MoonshineVendor) do
        DeleteEntity(npc[k])
        if v.blip.enable == true then
            RemoveBlip(blip[k])
        end
    end
end)

Citizen.CreateThread(function()
    for k, v in pairs(Config.MoonshineVendor) do
        if v.ped.enable == true then
            DeleteEntity(npc[k])
            while not HasModelLoaded( GetHashKey(v.ped.model) ) do
                Wait(500)
                modelrequest( GetHashKey(v.ped.model) )
            end
            npc[k] = CreatePed(GetHashKey(v.ped.model),v.ped.pos.x,v.ped.pos.y, v.ped.pos.z-1,v.ped.head, false, false, 0, 0)
            while not DoesEntityExist(npc[k]) do
                Wait(300)
            end
            Citizen.InvokeNative(0x283978A15512B2FE, npc[k], true)
            FreezeEntityPosition(npc[k], true)
            SetEntityInvincible(npc[k], true)
            TaskStandStill(npc[k], -1)
            Wait(100)
            SetModelAsNoLongerNeeded(GetHashKey(v.ped.model))
        end

        if v.blip.enable == true then
            RemoveBlip(blip[k])
            blip[k] = Citizen.InvokeNative(0x554D9D53F696D002,1664425300,v.ped.pos.x,v.ped.pos.y, v.ped.pos.z)
            SetBlipSprite(blip[k], GetHashKey(v.blip.blipSprite), true)
            SetBlipScale(blip[k], blipScale)
            Citizen.InvokeNative(0x9CB1A1623062F402, blip[k], v.blip.bliptext)        
        end
    end
end)
