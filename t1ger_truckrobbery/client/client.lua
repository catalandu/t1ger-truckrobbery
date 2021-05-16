-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

jobPC = nil
Citizen.CreateThread(function()
    while true do
		Citizen.Wait(1)
		local player = GetPlayerPed(-1)
		local coords =  GetEntityCoords(player)
		for k,v in pairs(Config.JobSpot) do
			local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, v.pos[1], v.pos[2], v.pos[3], false)
			if jobPC ~= nil then
				distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, jobPC.pos[1], jobPC.pos[2], jobPC.pos[3], false)
				while jobPC ~= nil and distance > 2.0 do
					jobPC = nil
					Citizen.Wait(1)
				end
				if jobPC == nil then
					ESX.UI.Menu.CloseAll()
				end
			else
				if distance <= 2.0 then
					DrawText3Ds(v.pos[1], v.pos[2], v.pos[3], Lang['job_draw_text'])
					if IsControlJustPressed(0, Config.KeyToStartJob) then
						if not isCop then
							ESX.TriggerServerCallback('t1ger_truckrobbery:copCount', function(cops)
								if cops >= Config.RequiredCops then
									ESX.TriggerServerCallback('t1ger_truckrobbery:getCooldown', function(cooldown)
										if cooldown == nil then
											ESX.TriggerServerCallback('t1ger_truckrobbery:getJobFees', function(hasMoney)
												if hasMoney then
													jobPC = v
													OpenHackFunction(v)
												else
													ShowNotifyESX(Lang['not_enough_money'])
												end
											end)
										else
											ShowNotifyESX((Lang['cooldown_time_left']:format(cooldown)))
										end
									end)
								else
									ShowNotifyESX(Lang['not_enough_police'])
								end
							end)
						else
							ShowNotifyESX(Lang['not_for_police'])
						end
					end
				end
			end
        end
    end
end)

function OpenHackFunction(v)
	local player = GetPlayerPed(-1)
	local animDict = "mp_fbi_heist"
	local animName = "loop"
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do
		Citizen.Wait(10)
	end
	TaskPlayAnimAdvanced(player, animDict, animName, v.pos[1], v.pos[2], v.pos[3], 0.0, 0.0, v.heading, 3.0, 1.0, -1, 30, 1.0, 0, 0 )
	SetEntityHeading(player, v.heading)
	FreezeEntityPosition(player, true)
	exports['progressBars']:startUI((Config.HackDataTimer * 1000), Lang['progbar_hacking'])
	Citizen.Wait(Config.HackDataTimer * 1000)
	TriggerEvent("mhacking:show")
	TriggerEvent("mhacking:start",Config.HackingBlocks,Config.HackingSeconds,HackCallback) 
end

function HackCallback(success)
	local player = GetPlayerPed(-1)
	ClearPedTasks(player)
    FreezeEntityPosition(player,false)
	TriggerEvent('mhacking:hide')
	jobPC = nil
	if success then
		TriggerServerEvent('t1ger_truckrobbery:startJobSV')
	else
		ShowNotifyESX(Lang['hacking_failed'])
	end
end
	
ArmoredTruck = nil
StopTheJob = false
TruckDemolished = false
TruckIsExploded = false

RegisterNetEvent('t1ger_truckrobbery:truckRobberyJob')
AddEventHandler('t1ger_truckrobbery:truckRobberyJob',function(num)
	local player = GetPlayerPed(-1)
	local job = Config.TruckSpawn[num]
	Config.TruckSpawn[num].inUse = true
	TriggerServerEvent('t1ger_truckrobbery:SyncDataSV',Config.TruckSpawn)

	local TruckRobbed = false
	local ArmoredTruckSpawned = false
	local SecuritySpawned = false
	local Guards = {}
	local truckBlip = nil

	while not TruckRobbed and not StopTheJob do
		Citizen.Wait(0)

		if not ArmoredTruckSpawned then 
			ClearAreaOfVehicles(job.pos[1], job.pos[2], job.pos[3], 15.0, false, false, false, false, false)
			ESX.Game.SpawnVehicle('stockade', {x = job.pos[1], y = job.pos[2], z = job.pos[3]}, 52.0, function(vehicle)
				SetEntityCoordsNoOffset(vehicle, job.pos[1], job.pos[2], job.pos[3])
				SetEntityHeading(vehicle, 52.0)
				SetVehicleOnGroundProperly(vehicle)
				ArmoredTruck = vehicle
				SetEntityAsMissionEntity(ArmoredTruck, true, true)
				--SetVehicleDoorsLockedForAllPlayers(ArmoredTruck, true)
			end)
			ArmoredTruckSpawned = true
		end

		if ArmoredTruckSpawned and ArmoredTruck ~= nil and not SecuritySpawned then
			local i = 0
			SecuritySpawned = true
			for k,v in pairs(job.security) do
				RequestModel(GetHashKey(v.ped))
				while not HasModelLoaded(GetHashKey(v.ped)) do
					Wait(1)
				end
				Guards[i] = CreatePedInsideVehicle(ArmoredTruck, 1, v.ped, v.seat, true, true)
				NetworkRegisterEntityAsNetworked(Guards[i])
				SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(Guards[i]), true)
				SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(Guards[i]), true)
				SetPedFleeAttributes(Guards[i], 0, 0)
				SetPedCombatAttributes(Guards[i], 46, 1)
				SetPedCombatAbility(Guards[i], 100)
				SetPedCombatMovement(Guards[i], 2)
				SetPedCombatRange(Guards[i], 2)
				SetPedKeepTask(Guards[i], true)
				GiveWeaponToPed(Guards[i], GetHashKey(v.weapon), 250, false, true)
				SetPedAsCop(Guards[i], true)
				SetPedDropsWeaponsWhenDead(Guards[i], false)
				TaskVehicleDriveWander(Guards[i], ArmoredTruck, 50.0, 443)
				SetPedArmour(Guards[i], 100)
				SetPedAccuracy(Guards[i], 60)
				SetEntityInvincible(Guards[i], false)
				SetEntityVisible(Guards[i], true)
				SetEntityAsMissionEntity(Guards[i])
				i = i +1
			end
		end

		if ArmoredTruck ~= nil then
			if DoesEntityExist(ArmoredTruck) then 
				if not DoesBlipExist(truckBlip) then
					truckBlip = AddBlipForEntity(ArmoredTruck)
				end
				SetBlipSprite(truckBlip, 477)
				SetBlipColour(truckBlip, 5)
				SetBlipDisplay(truckBlip, 2)
				SetBlipScale(truckBlip, 0.60)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString("Armored Truck")
				EndTextCommandSetBlipName(truckBlip)
			elseif DoesBlipExist(truckBlip) then
				RemoveBlip(truckBlip)
			end
		end

		if ArmoredTruckSpawned and ArmoredTruck ~= nil and SecuritySpawned then
			local pos = GetEntityCoords(player, false)
			local TruckPos = GetEntityCoords(ArmoredTruck) 
			local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, TruckPos.x, TruckPos.y, TruckPos.z, false)
			
			if distance > 40.0 then
				DrawMissionText(Lang['reach_the_truck'])
			end

			if distance <= 39.9 and distance > 5.0 and not TruckDemolished then
				local i = 0
				for k,v in pairs(job.security) do
					if DoesEntityExist(Guards[i]) then
						if not IsEntityDead(Guards[i]) then 
							DrawMissionText(Lang['kill_the_guards'])
						end
						if IsEntityDead(Guards[i]) and IsPedInAnyVehicle(Guards[i], true) then
							DeleteEntity(Guards[i])
						end
					end
					i = i + 1
				end
			end
			
			if distance <= 5.0 and not TruckDemolished then
				local closeVeh = GetClosestVehicle(pos.x, pos.y, pos.z, 20.0, 0, 70)
				if GetEntityModel(closeVeh) == GetHashKey('stockade') then
					local d1 = GetModelDimensions(GetEntityModel(closeVeh))
					local vehCoords = GetOffsetFromEntityInWorldCoords(closeVeh, 0.0,d1["y"]+0.60,0.0)
					local distVeh = GetDistanceBetweenCoords(vehCoords.x, vehCoords.y, vehCoords.z, pos.x, pos.y, pos.z, false);
					if distVeh < 2.0 then
						DrawText3Ds(vehCoords.x, vehCoords.y, vehCoords.z, Lang['open_truck_door'])
						if IsControlJustPressed(1, 47) then 
							SetVehicleDoorShut(closeVeh, 2, 1)
							SetVehicleDoorShut(closeVeh, 3, 1)
							SetVehicleDoorShut(closeVeh, 5, 1)
							SetVehicleDoorShut(closeVeh, 6, 1)
							Wait(200)
							BlowTheTruckDoor()
						end
					end
				end
			end
		
			if TruckIsExploded then
				local pos = GetEntityCoords(GetPlayerPed(-1), false)
				local TruckPos = GetEntityCoords(ArmoredTruck) 
				local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, TruckPos.x, TruckPos.y, TruckPos.z, false)

				if distance > 45.0 then
					Citizen.Wait(500)
				end

				if distance < 4.5 then
					local closeTruck = GetClosestVehicle(pos.x, pos.y, pos.z, 20.0, 0, 70)
					if GetEntityModel(closeTruck) == GetHashKey('stockade') then
						local d2 = GetModelDimensions(GetEntityModel(closeTruck))
						local truckCoords = GetOffsetFromEntityInWorldCoords(closeTruck, 0.0,d2["y"]+0.60,0.0)
						local truckDist = GetDistanceBetweenCoords(truckCoords.x, truckCoords.y, truckCoords.z, pos.x, pos.y, pos.z, false);
						if truckDist < 2.0 then
							DrawText3Ds(truckCoords.x, truckCoords.y, truckCoords.z, Lang['rob_the_truck'])
							if IsControlJustPressed(1, 38) then
								RobbingTheMoney()
							end
						end
					end
				end
				
			end
		
			if StopTheJob then
				
				Config.TruckSpawn[num].inUse = false
				Wait(150)
				TriggerServerEvent('t1ger_truckrobbery:SyncDataSV',Config.TruckSpawn)
				Citizen.Wait(500)
				SetEntityAsNoLongerNeeded(ArmoredTruck)
				if DoesBlipExist(truckBlip) then
					RemoveBlip(truckBlip)
				end
				local i = 0
                for k,v in pairs(job.security) do
                    if DoesEntityExist(Guards[i]) then
                        DeleteEntity(Guards[i])
                    end
                    i = i +1
				end

				ArmoredTruck = nil
				ArmoredTruckSpawned = false
				SecuritySpawned = false
				Guards = {}
				truckBlip = nil
				TruckDemolished = false
				TruckIsExploded = false
				StopTheJob = false
				TruckRobbed = true
				break
			end
		end
	end

end)

function BlowTheTruckDoor()
	if IsVehicleStopped(ArmoredTruck) then
		TruckDemolished = true
		
		RequestAnimDict('anim@heists@ornate_bank@thermal_charge_heels')
		while not HasAnimDictLoaded('anim@heists@ornate_bank@thermal_charge_heels') do
			Citizen.Wait(50)
		end
		
		if Config.NotfiyCops == true then
			NotifyPoliceFunction()
		end
		
		local playerPed = GetPlayerPed(-1)
		local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
		local itemC4prop = CreateObject(GetHashKey('prop_c4_final_green'), x, y, z+0.2,  true,  true, true)
		AttachEntityToEntity(itemC4prop, playerPed, GetPedBoneIndex(playerPed, 60309), 0.06, 0.0, 0.06, 90.0, 0.0, 0.0, true, true, false, true, 1, true)
		SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"),true)
		Citizen.Wait(500)
		FreezeEntityPosition(playerPed, true)
		TaskPlayAnim(playerPed, 'anim@heists@ornate_bank@thermal_charge_heels', "thermal_charge", 3.0, -8, -1, 63, 0, 0, 0, 0 )
		
		exports['progressBars']:startUI(5500, Lang['progbar_plant_c4'])
		Citizen.Wait(5500)
		
		ClearPedTasks(playerPed)
		DetachEntity(itemC4prop)
		AttachEntityToEntity(itemC4prop, ArmoredTruck, GetEntityBoneIndexByName(ArmoredTruck, 'door_pside_r'), -0.7, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
		FreezeEntityPosition(playerPed, false)
		Citizen.Wait(500)
		
		exports['progressBars']:startUI((Config.DetonateTimer * 1000), Lang['progbar_detonating'])	
		Citizen.Wait((Config.DetonateTimer * 1000))
		
		local TruckPos = GetEntityCoords(ArmoredTruck)
		SetVehicleDoorBroken(ArmoredTruck, 2, false)
		SetVehicleDoorBroken(ArmoredTruck, 3, false)
		AddExplosion(TruckPos.x,TruckPos.y,TruckPos.z, 'EXPLOSION_TANKER', 2.0, true, false, 2.0)
		ApplyForceToEntity(ArmoredTruck, 2, TruckPos.x,TruckPos.y,TruckPos.z, 0.0, 0.0, 0.0, 1, false, true, true, true, true)
		TruckIsExploded = true
		ShowNotifyESX(Lang['begin_to_rob'])
	else
		ShowNotifyESX(Lang['truck_not_stopped'])
	end
end

function RobbingTheMoney()
	
	RequestAnimDict('anim@heists@ornate_bank@grab_cash_heels')
	while not HasAnimDictLoaded('anim@heists@ornate_bank@grab_cash_heels') do
		Citizen.Wait(50)
	end
	
	local playerPed = GetPlayerPed(-1)
	local pos = GetEntityCoords(playerPed)
	
	local moneyBag = CreateObject(GetHashKey('prop_cs_heist_bag_02'),pos.x, pos.y,pos.z, true, true, true)
	AttachEntityToEntity(moneyBag, playerPed, GetPedBoneIndex(playerPed, 57005), 0.0, 0.0, -0.16, 250.0, -30.0, 0.0, false, false, false, false, 2, true)
	TaskPlayAnim(PlayerPedId(), "anim@heists@ornate_bank@grab_cash_heels", "grab", 8.0, -8.0, -1, 1, 0, false, false, false)
	FreezeEntityPosition(playerPed, true)
	
	exports['progressBars']:startUI((Config.RobTruckTimer * 1000), Lang['progbar_robbing'])
	Citizen.Wait((Config.RobTruckTimer * 1000))
	
	DeleteEntity(moneyBag)
	ClearPedTasks(playerPed)
	FreezeEntityPosition(playerPed, false)
	
	if Config.EnablePlayerMoneyBag == true then
		SetPedComponentVariation(playerPed, 5, 45, 0, 2)
	end
	
	TriggerServerEvent('t1ger_truckrobbery:jobReward')
	Citizen.Wait(1000)
	StopTheJob = true
end

AddEventHandler('esx:onPlayerDeath', function(data)
	StopTheJob = true
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