local QRCore = exports['qr-core']:GetCoreObject()

-- use moonshine kit
QRCore.Functions.CreateUseableItem("moonshinekit", function(source, item)
    local Player = QRCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent('rsg-moonshiner:client:moonshinekit', source, item.name)
    end
end)

-- brew moonshine
RegisterServerEvent('rsg-moonshiner:server:givemoonshine')
AddEventHandler('rsg-moonshiner:server:givemoonshine', function(amount)
	local src = source
    local Player = QRCore.Functions.GetPlayer(src)
	if amount == 1 then
		Player.Functions.RemoveItem('sugar', 1)
		Player.Functions.RemoveItem('corn', 1)
		Player.Functions.RemoveItem('water', 1)
		Player.Functions.AddItem('moonshine', 1)
		TriggerClientEvent("inventory:client:ItemBox", src, QRCore.Shared.Items['moonshine'], "add")
		QRCore.Functions.Notify(src, 'you made some moonshine', 'success')
	else
		QRCore.Functions.Notify(src, 'something went wrong!', 'error')
		print('something went wrong with moonshine script could be exploint!')
	end
end)