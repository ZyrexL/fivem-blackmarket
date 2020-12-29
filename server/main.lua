ESX             = nil
local ShopItems = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

MySQL.ready(function()
	MySQL.Async.fetchAll('SELECT * FROM blackmarket LEFT JOIN items ON items.name = blackmarket.item', {}, function(shopResult)
		for i=1, #shopResult, 1 do
			if shopResult[i].name then
				if ShopItems[shopResult[i].store] == nil then
					ShopItems[shopResult[i].store] = {}
				end

				table.insert(ShopItems[shopResult[i].store], {
					label = shopResult[i].label,
					item  = shopResult[i].item,
					price = shopResult[i].price,
				})
			else
				print(('esx_blackmarket: invalid item "%s" found!'):format(shopResult[i].item))
			end
		end
	end)
end)

ESX.RegisterServerCallback('esx_blackmarket:requestDBItems', function(source, cb)
	cb(ShopItems)
end)

RegisterServerEvent('esx_blackmarket:buyItem')
AddEventHandler('esx_blackmarket:buyItem', function(itemName, amount, zone)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	amount = ESX.Math.Round(amount)

	if amount < 0 then
		print('esx_blackmarket: ' .. xPlayer.identifier .. ' attempted to exploit the shop!')
		return
	end

	local price = 0
	local itemLabel = ''

	for i=1, #ShopItems[zone], 1 do
		if ShopItems[zone][i].item == itemName then
			price = ShopItems[zone][i].price
			itemLabel = ShopItems[zone][i].label
			break
		end
	end

	price = price * amount

	if xPlayer.getAccount('black_money').money >= price then
		if xPlayer.canCarryItem(itemName, amount) then
			xPlayer.removeAccountMoney('black_money', price)
			xPlayer.addInventoryItem(itemName, amount)
			xPlayer.showNotification(_U('bought', amount, itemLabel, ESX.Math.GroupDigits(price)))
		else
			xPlayer.showNotification(_U('player_cannot_hold'))
		end
	else
		local missingMoney = price - xPlayer.getAccount('black_money').money
		xPlayer.showNotification(_U('not_enough', ESX.Math.GroupDigits(missingMoney)))
	end
end)