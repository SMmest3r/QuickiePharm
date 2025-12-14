local res, err = CanLoad()
if not res then
    ErrPrint(err)
    return
end

local players = {}

RegisterNetEvent("mester_quickiepharmStartJob", function()
    local player = source
    if players[player] then
        if players[player].vehicle then
            local veh = NetworkGetEntityFromNetworkId(players[player].vehicle)
            if DoesEntityExist(veh) then
                DebugPrint("Player " .. player .. " already had a job vehicle, removing it...")
                DeleteEntity(veh)
            end
        end
        players[player] = nil
    end
    players[player] = { vehicle = nil, jobStartedAt = os.time(), jobState = 0 }
    local foundSpawn = false
    local chosenSpawnPoint = nil
    for _, spawnPoint in pairs(Config.JobVehicle.SpawnPoints) do
        if IsSpawnpointClear(spawnPoint.x, spawnPoint.y, spawnPoint.z, 3.0) then
            DebugPrint("Spawning job vehicle for player " .. player .. " at (" .. spawnPoint.x .. ", " .. spawnPoint.y .. ", " .. spawnPoint.z .. ")")
            foundSpawn = true
            chosenSpawnPoint = spawnPoint
            break
        else
            DebugPrint("Spawn point at (" .. spawnPoint.x .. ", " .. spawnPoint.y .. ", " .. spawnPoint.z .. ") is not clear.")
        end
    end
    if not foundSpawn then
        ErrPrint("No clear spawn points available for player " .. player .. "'s job vehicle.")
        TriggerClientEvent("mester_quickiepharmNotify", player, Locales.NoSpawnPoint)
        return
    end
    local veh = CreateVehicle(GetHashKey(Config.JobVehicle.Model), chosenSpawnPoint.x, chosenSpawnPoint.y, chosenSpawnPoint.z, chosenSpawnPoint.w, true, false)
    Citizen.Wait(500)
    SetVehicleNumberPlateText(veh, Config.JobVehicle.Plate)
    if DoesEntityExist(veh) then
        DebugPrint("Successfully created job vehicle for player " .. player)
        players[player].vehicle = NetworkGetNetworkIdFromEntity(veh)
        TaskWarpPedIntoVehicle(GetPlayerPed(player), veh, -1)
    else
        ErrPrint("Failed to create job vehicle for player " .. player)
        TriggerClientEvent("mester_quickiepharmNotify", player, Locales.FailedToCreateVehicle)
        return
    end
    TriggerClientEvent("mester_quickiepharmStartedJob", player)
end)

AddEventHandler("playerDropped", function(reason)
    local player = source
    if players[player] then
        if players[player].vehicle then
            local veh = NetworkGetEntityFromNetworkId(players[player].vehicle)
            if DoesEntityExist(veh) then
                DebugPrint("Player " .. player .. " disconnected, removing their job vehicle...")
                DeleteEntity(veh)
            end
        end
        players[player] = nil
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for player, data in pairs(players) do
            if data.vehicle then
                local veh = NetworkGetEntityFromNetworkId(data.vehicle)
                if DoesEntityExist(veh) then
                    DebugPrint("Resource stopping, removing job vehicle for player " .. player)
                    DeleteEntity(veh)
                end
            end
            players[player] = nil
        end
    end
end)