local QRCore = exports['qr-core']:GetCoreObject()
local moonshinekit = 0
isLoggedIn = false
PlayerJob = {}

RegisterNetEvent('QRCore:Client:OnPlayerLoaded')
AddEventHandler('QRCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    PlayerJob = QRCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QRCore:Client:OnJobUpdate')
AddEventHandler('QRCore:Client:OnJobUpdate', function(JobInfo)
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

-- setup moonshine
RegisterNetEvent('rsg-moonshiner:client:moonshinekit')
AddEventHandler('rsg-moonshiner:client:moonshinekit', function(itemName) 
    if moonshinekit ~= 0 then
        SetEntityAsMissionEntity(moonshinekit)
        DeleteObject(moonshinekit)
        moonshinekit = 0
    else
		local playerPed = PlayerPedId()
		TaskStartScenarioInPlace(playerPed, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), 10000, true, false, false, false)
		Wait(10000)
		ClearPedTasks(playerPed)
		SetCurrentPedWeapon(playerPed, `WEAPON_UNARMED`, true)
		--local pos = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.75, -1.55))
		local pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.75, -1.55)
		--local modelHash = `p_still03x`
		local modelHash = GetHashKey(Config.Prop)
		if not HasModelLoaded(modelHash) then
			-- If the model isnt loaded we request the loading of the model and wait that the model is loaded
			RequestModel(modelHash)
			while not HasModelLoaded(modelHash) do
				Wait(1)
			end
		end
		local prop = CreateObject(modelHash, pos, true)
		SetEntityHeading(prop, GetEntityHeading(PlayerPedId()))
		PlaceObjectOnGroundProperly(prop)
		PlaySoundFrontend("SELECT", "RDRO_Character_Creator_Sounds", true, 0)
		moonshinekit = prop
	end
end, false)

-- create moonshine still / destroy (police only)
Citizen.CreateThread(function()
	while true do
		Wait(0)
		local pos, awayFromObject = GetEntityCoords(PlayerPedId()), true
		local moonshineObject = GetClosestObjectOfType(pos, 5.0, GetHashKey(Config.Prop), false, false, false)
		if moonshineObject ~= 0 and PlayerJob.name ~= Config.LawJobName then
			local objectPos = GetEntityCoords(moonshineObject)
			if #(pos - objectPos) < 3.0 then
				awayFromObject = false
				DrawText3Ds(objectPos.x, objectPos.y, objectPos.z + 1.0, "Brew [J]")
				if IsControlJustReleased(0, QRCore.Shared.Keybinds['J']) then
					TriggerEvent('rsg-moonshiner:client:menu')
				end
			end
		else
			local objectPos = GetEntityCoords(moonshineObject)
			if #(pos - objectPos) < 3.0 then
				awayFromObject = false
				DrawText3Ds(objectPos.x, objectPos.y, objectPos.z + 1.0, "Destroy [J]")
				if IsControlJustReleased(0, QRCore.Shared.Keybinds['J']) then
					local player = PlayerPedId()
					TaskStartScenarioInPlace(player, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), 5000, true, false, false, false)
					Wait(5000)
					ClearPedTasks(player)
					SetCurrentPedWeapon(player, `WEAPON_UNARMED`, true)
					DeleteObject(moonshineObject)
					PlaySoundFrontend("SELECT", "RDRO_Character_Creator_Sounds", true, 0)
					QRCore.Functions.Notify('moonshine destroyed!', 'primary')
				end
			end
		end
		if awayFromObject then
			Wait(1000)
		end
	end
end)

-- moonshine menu
RegisterNetEvent('rsg-moonshiner:client:menu', function(data)
    exports['qr-menu']:openMenu({
        {
            header = "| Moonshine |",
            isMenuHeader = true,
        },
        {
            header = "Make Moonshine",
            txt = "1 x Sugar 1 x Water and 1 x Corn",
            params = {
                event = 'rsg-moonshiner:client:moonshine',
				isServer = false,
            }
        },
        {
            header = "Close Menu",
            txt = '',
            params = {
                event = 'qr-menu:closeMenu',
            }
        },
    })
end)

-- make moonshine
RegisterNetEvent("rsg-moonshiner:client:moonshine")
AddEventHandler("rsg-moonshiner:client:moonshine", function()
	local hasItem1 = QRCore.Functions.HasItem('sugar', 1)
	local hasItem2 = QRCore.Functions.HasItem('corn', 1)
	local hasItem3 = QRCore.Functions.HasItem('water', 1)
	if hasItem1 and hasItem2 and hasItem3 then
		local player = PlayerPedId()
		TaskStartScenarioInPlace(player, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), Config.BrewTime, true, false, false, false)
		Wait(Config.BrewTime)
		ClearPedTasks(player)
		SetCurrentPedWeapon(player, `WEAPON_UNARMED`, true)
		TriggerServerEvent('rsg-moonshiner:server:givemoonshine', 1)
		PlaySoundFrontend("SELECT", "RDRO_Character_Creator_Sounds", true, 0)
	else
		QRCore.Functions.Notify('you don\'t have the ingredients to make this!', 'error')
	end
end)