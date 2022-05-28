local QBCore = exports['qb-core']:GetCoreObject()

local xSound = exports.xsound
previousSongs = {}
CurrentBooths = {}

RegisterNetEvent('qb-djbooth:server:playMusic', function(song, zoneNum)
    local src = source
	local coords = GetEntityCoords(ped)
	local Booth = Config.Locations[zoneNum]
	local zoneLabel = Config.Locations[zoneNum].job..zoneNum
	if not previousSongs[zoneLabel] then previousSongs[zoneLabel] = { [1] = song, }
	elseif previousSongs[zoneLabel] then
		local songList = previousSongs[zoneLabel]
		--if not songList[#songList] == song then --Stopped adding NEW links to the list so disabled for now..
			songList[#songList+1] = song
			previousSongs[zoneLabel] = songList
		--end
	end
	local bCoords = Booth.coords
	if Booth.soundLoc then -- If soundLoc is found, change the location of the music
		bcoords = Booth.soundLoc
	end
    xSound:PlayUrlPos(-1, zoneLabel, song, Booth.DefaultVolume, bCoords)
    xSound:Distance(-1, zoneLabel, Booth.radius)
    Config.Locations[zoneNum].playing = true
    TriggerClientEvent('qb-djbooth:client:playMusic', src, { zone = zoneNum })
end)

RegisterNetEvent('qb-djbooth:server:stopMusic', function(data)
    local src = source
	local zoneLabel = Config.Locations[data.zoneNum].job..data.zoneNum
    if Config.Locations[data.zoneNum].playing then
        Config.Locations[data.zoneNum].playing = false
        xSound:Destroy(-1, zoneLabel)
    end
    TriggerClientEvent('qb-djbooth:client:playMusic', src, { zone = data.zoneNum })
end)

RegisterNetEvent('qb-djbooth:server:pauseMusic', function(data)
    local src = source
	local zoneLabel = Config.Locations[data.zoneNum].job..data.zoneNum
    if Config.Locations[data.zoneNum].playing then
        Config.Locations[data.zoneNum].playing = false
        xSound:Pause(-1, zoneLabel)
    end
    TriggerClientEvent('qb-djbooth:client:playMusic', src, { zone = data.zoneNum })
end)

RegisterNetEvent('qb-djbooth:server:resumeMusic', function(data)
    local src = source
	local zoneLabel = Config.Locations[data.zoneNum].job..data.zoneNum
    if not Config.Locations[data.zoneNum].playing then
        Config.Locations[data.zoneNum].playing = true
        xSound:Resume(-1, zoneLabel)
    end
    TriggerClientEvent('qb-djbooth:client:playMusic', src, { zone = data.zoneNum })
end)

RegisterNetEvent('qb-djbooth:server:changeVolume', function(volume, zoneNum)
    local src = source
	local Booth = Config.Locations[zoneNum]
	local zoneLabel = Config.Locations[zoneNum].job..zoneNum
    if not tonumber(volume) then return end
    if Config.Locations[zoneNum].playing then
        xSound:setVolume(-1, zoneLabel, volume)
    end
    TriggerClientEvent('qb-djbooth:client:playMusic', src, { zone = zoneNum })
end)

QBCore.Functions.CreateCallback('qb-djbooth:songInfo', function(source, cb) cb(previousSongs) end)

-- I was asked about adding support for a city blackout script
-- This is for that
RegisterNetEvent("qb-djbooth:server:DestoryAll", function()
	for i = 1, #Config.Locations do
		if Config.Locations[i].playing then
			local zoneLabel = Config.Locations[i].job..i
			xSound:Destroy(-1, zoneLabel)
		end
	end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
	TriggerEvent("qb-djbooth:server:DestoryAll")
end)