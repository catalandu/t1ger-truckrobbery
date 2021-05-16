


-- Sync Config Data:
RegisterNetEvent('t1ger_truckrobbery:SyncDataCL')
AddEventHandler('t1ger_truckrobbery:SyncDataCL', function(data)
    Config.TruckSpawn = data
end)

AddEventHandler('playerSpawned', function(spawn)
    isDead = false
end)


-- Making sure that players don't get the same mission at the same time
RegisterNetEvent('t1ger_truckrobbery:startJobCL')
AddEventHandler('t1ger_truckrobbery:startJobCL', function()
    local num = math.random(1, #Config.TruckSpawn)
    local takenNum = 0
    while Config.TruckSpawn[num].InUse and takenNum < 100 do
        takenNum = takenNum + 1
        num = math.random(1, #Config.TruckSpawn)
    end
    if takenNum == 100 then
        ShowNotifyESX(Lang['no_available_jobs'])
    else
        TriggerEvent('t1ger_truckrobbery:truckRobberyJob', num)
        PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 0)
    end
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