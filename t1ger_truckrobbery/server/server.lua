-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

jobCooldown = {} 

RegisterServerEvent('t1ger_truckrobbery:jobCooldown')
AddEventHandler('t1ger_truckrobbery:jobCooldown',function(source)
	table.insert(jobCooldown,{cooldown = GetPlayerIdentifier(source), time = (Config.CooldownTimer * 60000)}) -- cooldown timer for doing missions
end)

Citizen.CreateThread(function() -- do not touch this thread function!
	while true do
	Citizen.Wait(1000)
		for k,v in pairs(jobCooldown) do
			if v.time <= 0 then
				RemoveCooldownTimer(v.cooldown)
			else
				v.time = v.time - 1000
			end
		end
	end
end)

ESX.RegisterServerCallback('t1ger_truckrobbery:copCount',function(source,cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()
	local CopsOnline = 0
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			CopsOnline = CopsOnline + 1
		end
	end
	cb(CopsOnline)
end)

ESX.RegisterServerCallback('t1ger_truckrobbery:getCooldown',function(source,cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not CheckCooldownTimer(GetPlayerIdentifier(source)) then
		cb(nil)
	else
		cb(GetCooldownTimer(GetPlayerIdentifier(source)))
	end
end)

ESX.RegisterServerCallback('t1ger_truckrobbery:getJobFees',function(source,cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local money = 0
	if Config.UseBankMoney then 
		money = xPlayer.getAccount('bank').money
	else
		money = xPlayer.getMoney()
	end
	if money >= Config.JobFees then
        cb(true)
    else
        cb(false)
    end
end)

-- server side function to accept the mission
RegisterServerEvent('t1ger_truckrobbery:startJobSV')
AddEventHandler('t1ger_truckrobbery:startJobSV', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerEvent('t1ger_truckrobbery:jobCooldown', source)
	if Config.UseBankMoney then 
		xPlayer.removeAccountMoney('bank', Config.JobFees)
	else
		xPlayer.removeMoney(Config.JobFees)
	end
	TriggerClientEvent('t1ger_truckrobbery:startJobCL', source)
end)

RegisterServerEvent('t1ger_truckrobbery:jobReward')
AddEventHandler('t1ger_truckrobbery:jobReward',function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local reward = math.random(Config.Reward.min,Config.Reward.max)
	
	if Config.Reward.dirty then
		xPlayer.addAccountMoney('black_money', tonumber(reward))
	else
		xPlayer.addMoney(reward)
	end
	TriggerClientEvent('t1ger_truckrobbery:ShowNotifyESX', xPlayer.source, (Lang['reward_notify']:format(reward)))
	
	if Config.ItemReward.enable then
		for k,v in pairs(Config.ItemReward.items) do
			if math.random(0,100) <= v.chance then 
				local itemAmount = math.random(v.min,v.max)
				local itemName = ''
				if Config.HasItemLabel then
					itemName = ESX.GetItemLabel(v.item)
				else
					itemName = tostring(v.item)
				end
				xPlayer.addInventoryItem(v.item,itemAmount)
				TriggerClientEvent('t1ger_truckrobbery:ShowNotifyESX', xPlayer.source, (Lang['you_received_item']:format(itemAmount,itemName)))
			end
		end
	end
end)

RegisterServerEvent('t1ger_truckrobbery:PoliceNotifySV')
AddEventHandler('t1ger_truckrobbery:PoliceNotifySV', function(targetCoords, streetName)
	TriggerClientEvent('t1ger_truckrobbery:PoliceNotifyCL', -1, (Lang['police_notify']):format(streetName))
	TriggerClientEvent('t1ger_truckrobbery:PoliceNotifyBlip', -1, targetCoords)
end)
  --[[  
██╗░░░██╗██████╗░██╗░░░░░███████╗░█████╗░██╗░░██╗░██████╗
██║░░░██║██╔══██╗██║░░░░░██╔════╝██╔══██╗██║░██╔╝██╔════╝
██║░░░██║██████╔╝██║░░░░░█████╗░░███████║█████═╝░╚█████╗░
██║░░░██║██╔═══╝░██║░░░░░██╔══╝░░██╔══██║██╔═██╗░░╚═══██╗
╚██████╔╝██║░░░░░███████╗███████╗██║░░██║██║░╚██╗██████╔╝
░╚═════╝░╚═╝░░░░░╚══════╝╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░
█████████████████████████████████████████████████████████
discord.gg/6CRxjqZJFB ]]--