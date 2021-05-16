-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 

Config = {}

-- Police Settings:
Config.PoliceJobs = {"police", "lspd"}	-- Jobs that can't do criminal things etc.
Config.RequiredCops = 0					-- required police online for players to do jobs
Config.NotfiyCops = true				-- Notify Cops on blowing the truck
Config.AlertBlipShow = true				-- enable or disable blip on map on police notify
Config.AlertBlipTime = 30				-- miliseconds that blip is active on map (this value is multiplied with 4 in the script)
Config.AlertBlipRadius = 50.0			-- set radius of the police notify blip
Config.AlertBlipAlpha = 250			-- set alpha of the blip
Config.AlertBlipColor = 5				-- set blip color

Config.KeyToStartJob = 38

Config.JobFees = 100			-- Amount of money to start a job
Config.UseBankMoney = false		-- Set to false to pay job fees with cash
Config.HackingBlocks = 4		-- amount of blocks u have to match
Config.HackingSeconds = 40		-- seconds to hack

Config.HackDataTimer = 3.5		-- time from pressed E to receving location on the truck
Config.DetonateTimer = 10			-- time until bomb is detonated
Config.RobTruckTimer = 10			-- time spent to rob the truck

Config.EnablePlayerMoneyBag = true   -- Enable or disable player wearing a 'heist money bag' after the robbery:

Config.CooldownTimer = 1		-- set cooldown time in minutes, before a player can start a job again

Config.HasItemLabel = true		-- set to false if your ESX vers. doesnt support item labels

Config.Reward = {min = 1000, max = 5000, dirty = true}
Config.ItemReward = {
	enable = true,
	items = {
		[1] = {item = 'goldbar', min = 1, max = 3, chance = 30},
		[2] = {item = 'goldwatch', min = 1, max = 3, chance = 75},
	}
}

Config.JobSpot = {
	[1] = {
		pos = {1275.68,-1710.32,54.77},
		heading = 302.12,
		blip = {enable = true, sprite = 47, display = 4, scale = 0.65, color = 5, name = "Truck Robbery Job"},
	},
}

Config.TruckSpawn = {
	[1] = {
		pos = {-1327.479736328,-86.045326232910,49.31},
		inUse = false,
		security = {
			[1] = {ped = 's_m_m_security_01', seat = -1, weapon = 'WEAPON_SMG'},
			[2] = {ped = 's_m_m_security_01', seat = 0, weapon = 'WEAPON_PUMPSHOTGUN'},
			[3] = {ped = 's_m_m_security_01', seat = 1, weapon = 'WEAPON_SMG'},
		},
	},
	[2] = {
		pos = {-2075.888183593,-233.73908996580,21.10},
		inUse = false,
		security = {
			[1] = {ped = 's_m_m_security_01', seat = -1, weapon = 'WEAPON_SMG'},
			[2] = {ped = 's_m_m_security_01', seat = 0, weapon = 'WEAPON_PUMPSHOTGUN'},
			[3] = {ped = 's_m_m_security_01', seat = 1, weapon = 'WEAPON_SMG'},
		},
	},
	[3] = {
		pos = {-972.1781616210,-1530.9045410150,4.890},
		inUse = false,
		security = {
			[1] = {ped = 's_m_m_security_01', seat = -1, weapon = 'WEAPON_SMG'},
			[2] = {ped = 's_m_m_security_01', seat = 0, weapon = 'WEAPON_PUMPSHOTGUN'},
			[3] = {ped = 's_m_m_security_01', seat = 1, weapon = 'WEAPON_SMG'},
		},
	},
	[4] = {
		pos = {798.184265136720,-1799.8173828125,29.33},
		inUse = false,
		security = {
			[1] = {ped = 's_m_m_security_01', seat = -1, weapon = 'WEAPON_SMG'},
			[2] = {ped = 's_m_m_security_01', seat = 0, weapon = 'WEAPON_PUMPSHOTGUN'},
			[3] = {ped = 's_m_m_security_01', seat = 1, weapon = 'WEAPON_SMG'},
		},
	},
	[5] = {
		pos = {1247.0718994141,-344.65634155273,69.08},
		inUse = false,
		security = {
			[1] = {ped = 's_m_m_security_01', seat = -1, weapon = 'WEAPON_SMG'},
			[2] = {ped = 's_m_m_security_01', seat = 0, weapon = 'WEAPON_PUMPSHOTGUN'},
			[3] = {ped = 's_m_m_security_01', seat = 1, weapon = 'WEAPON_SMG'},
		},
	},
}
  --[[  
██╗░░░██╗██████╗░██╗░░░░░███████╗░█████╗░██╗░░██╗░██████╗
██║░░░██║██╔══██╗██║░░░░░██╔════╝██╔══██╗██║░██╔╝██╔════╝
██║░░░██║██████╔╝██║░░░░░█████╗░░███████║█████═╝░╚█████╗░
██║░░░██║██╔═══╝░██║░░░░░██╔══╝░░██╔══██║██╔═██╗░░╚═══██╗
╚██████╔╝██║░░░░░███████╗███████╗██║░░██║██║░╚██╗██████╔╝
░╚═════╝░╚═╝░░░░░╚══════╝╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░
█████████████████████████████████████████████████████████
discord.gg/6CRxjqZJFB ]]--