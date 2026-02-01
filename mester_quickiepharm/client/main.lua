-- Check if the resource can load properly. (Does config exist, is it valid, etc.)
local res, err = CanLoad()
if not res then
    ErrPrint(err)
    return
end

local inJob = false
local inStartJobMarker = false

-- Create the blip on the map
Citizen.CreateThread(function()
    local blip = AddBlipForCoord(Config.Location.x, Config.Location.y, Config.Location.z)
    SetBlipSprite(blip, Config.BlipData.Sprite)
    SetBlipDisplay(blip, Config.BlipData.Display)
    SetBlipScale(blip, Config.BlipData.Scale)
    SetBlipColour(blip, Config.BlipData.Color)
    SetBlipAsShortRange(blip, Config.BlipData.ShortRange)
	BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.BlipData.Name)
    EndTextCommandSetBlipName(blip)
end)

-- Interaction key mapping and command registration for starting the job
RegisterCommand("mester_quickiepharmInteract", function()
    if inStartJobMarker then
        if inJob then
            DebugPrint("Already in job, cannot start another.")
            return
        end
        inJob = true
        DebugPrint("Starting job...")
        DoorScene()
        TriggerServerEvent("mester_quickiepharmStartJob")
    end
end, false)
RegisterKeyMapping("mester_quickiepharmInteract", Locales.KeyMappingLabel, "keyboard", Config.DefaultInteractionKey)

-- Job start marker display and inStartJobMarker check
Citizen.CreateThread(function()
    local wait = 500
    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        if #(pos - Config.Location) < Config.JobMarker.DrawDistance and not inJob then
            wait = 0
            DrawMarker(Config.JobMarker.Type, Config.Location.x, Config.Location.y, Config.Location.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.JobMarker.Scale.x, Config.JobMarker.Scale.y, Config.JobMarker.Scale.z, Config.JobMarker.Color.r, Config.JobMarker.Color.g, Config.JobMarker.Color.b, Config.JobMarker.Color.a, false, true, 2, nil, nil, false)
            if #(pos - Config.Location) < 1.5 then
                ShowHelp(Locales.HelpText)
                inStartJobMarker = true
            else
                inStartJobMarker = false
            end
        else
            wait = 500
            inStartJobMarker = false
        end
        Citizen.Wait(wait)
    end
end)

-- Event to receive notifications from the server
RegisterNetEvent("mester_quickiepharmNotify", function(msg)
    Notify(msg)
end)

RegisterNetEvent("mester_quickiepharmStartedJob", function(vehicle, props)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local tries = 0

    -- Wait for the vehicle to be valid
    while (not veh or veh <= 0) and tries < 50 do
        Citizen.Wait(100)
        veh = GetVehiclePedIsIn(ped, false)
        tries = tries + 1
    end

    if veh and veh > 0 then
        if Config.JobVehicle.Color then
            DebugPrint("Setting job vehicle colors to primary: " .. Config.JobVehicle.Color.primary .. ", secondary: " .. Config.JobVehicle.Color.secondary)
            SetVehicleColours(veh, Config.JobVehicle.Color.primary, Config.JobVehicle.Color.secondary)
        end

        -- Set livery if configured
        if Config.JobVehicle.Livery then
            DebugPrint("Setting job vehicle livery to " .. Config.JobVehicle.Livery)
            SetVehicleModKit(veh, 0)
            SetVehicleMod(veh, 48, Config.JobVehicle.Livery, false)
        end

        -- Attach props to the vehicle if server spawned them and provided their Net IDs correctly
        DebugPrint("Spawning job props in the vehicle's backseats.")
        for k, v in pairs(props) do
            local tries = 0
            while not NetworkDoesNetworkIdExist(v) and tries < 50 do
                Citizen.Wait(100)
                tries = tries + 1
            end
            local propEntity = NetworkGetEntityFromNetworkId(v)
            if DoesEntityExist(propEntity) then
                DebugPrint("Attaching prop with Net ID " .. v .. " to job vehicle.")
                AttachEntityToEntity(propEntity, veh, GetEntityBoneIndexByName(veh, "seat_pside_r"), 0.3 - (k * 0.1), 0.0, 0.5, 0.0, 0.0, 90.0, true, true, false, true, 1, true)
            else
                ErrPrint("Failed to find prop entity with Net ID " .. v .. " for attachment.")
            end
        end

        -- Set dirt level to 0 if configured
        if Config.JobVehicle.SetDirtLevel then
            SetVehicleDirtLevel(veh, 0.0)
        end
    end

    DoScreenFadeIn(500)

    -- Monitor the job vehicle's presence and driveability
    Citizen.CreateThread(function()
        local netId = vehicle
        local veh = NetworkGetEntityFromNetworkId(netId)
        while inJob do
            Citizen.Wait(500)
            local ped = PlayerPedId()
            if not DoesEntityExist(veh) then
                if NetworkDoesNetworkIdExist(netId) then
                    veh = NetworkGetEntityFromNetworkId(netId)
                end
                if not DoesEntityExist(veh) then
                    DebugPrint("Job vehicle no longer exists, ending job.")
                    inJob = false
                    for k, v in pairs(props) do
                        local propEntity = NetworkGetEntityFromNetworkId(v)
                        if DoesEntityExist(propEntity) then
                            DebugPrint("Removing job prop with Net ID " .. v)
                            DeleteEntity(propEntity)
                        end
                        Citizen.Wait(0)
                    end
                    TriggerServerEvent("mester_quickiepharmEndedJob", false)
                    return
                end
            end
            if not IsVehicleDriveable(veh, true) then
                DebugPrint("Job vehicle is no longer driveable, ending job.")
                inJob = false
                for k, v in pairs(props) do
                    local propEntity = NetworkGetEntityFromNetworkId(v)
                    if DoesEntityExist(propEntity) then
                        DebugPrint("Removing job prop with Net ID " .. v)
                        DeleteEntity(propEntity)
                    end
                    Citizen.Wait(0)
                end
                if Config.JobVehicle.DeleteWhenUndriveable then
                    DebugPrint("Deleting undriveable job vehicle.")
                    DeleteEntity(veh)
                end
                TriggerServerEvent("mester_quickiepharmEndedJob", not Config.JobVehicle.DeleteWhenUndriveable)
                return
            end
        end
    end)

    local routes = selectRoutes(Config.RoutePerJob)
    local currentDelivery = 1
    local totalDeliveries = #routes
    local totalEarned = 0
    local currentPayment = 0
    
    Notify(Locales.FragileWarning)
    Citizen.Wait(3000)
    
    local function nextDelivery()
        if currentDelivery > totalDeliveries then
            if Config.ShouldBringBackVehicle then
                -- Need to return vehicle
                showReturnVehicleTask(totalDelivered, totalEarned)
            else
                -- Job complete
                completeJob(totalDeliveries, totalEarned)
            end
            return
        end
        
        local delivery = routes[currentDelivery]
        local ped = PlayerPedId()
        local pedPos = GetEntityCoords(ped)
        local distance = #(pedPos - delivery.coords)
        
        -- Calculate payment and time based on distance
        local paymentData = getPaymentForDistance(distance)
        if not paymentData then
            ErrPrint("No payment data found for distance " .. distance .. ", ending job.")
            inJob = false
            TriggerServerEvent("mester_quickiepharmEndedJob", true)
            return
        end
        currentPayment = paymentData.payment
        local timeLimit = paymentData.time
        
        -- Show mission text
        showMissionText(currentDelivery, totalDeliveries, delivery.label, delivery.category)
        
        -- Create blip for destination
        local blip = AddBlipForCoord(delivery.coords.x, delivery.coords.y, delivery.coords.z)
        SetBlipSprite(blip, Config.JobVehicle.Blip.Sprite)
        SetBlipDisplay(blip, Config.JobVehicle.Blip.Display)
        SetBlipScale(blip, Config.JobVehicle.Blip.Scale)
        SetBlipColour(blip, Config.JobVehicle.Blip.Color)
        SetBlipAsShortRange(blip, false)
        SetBlipRoute(blip, true)
        SetBlipRouteColour(blip, Config.JobVehicle.Blip.Color)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(delivery.label)
        EndTextCommandSetBlipName(blip)
        
        -- Monitor delivery
        local delivered = false
        local inMarker = false
        local inSecondaryMarker = false
        
        Citizen.CreateThread(function()
            local wait = 500
            while not delivered and inJob do
                local ped = PlayerPedId()
                local pos = GetEntityCoords(ped)
                local veh = GetVehiclePedIsIn(ped, false)
                
                -- Check marker
                if veh and veh > 0 then
                    local distToVehicleMarker = #(pos - delivery.coords)
                    if distToVehicleMarker < Config.DestinationMarkers.DrawDistance then
                        wait = 0
                        local markerScale = Config.DestinationMarkers.Scale * Config.VehicleDestinationMarkerMultiplier
                        DrawMarker(Config.DestinationMarkers.Type, delivery.coords.x, delivery.coords.y, delivery.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, markerScale.x, markerScale.y, markerScale.z, Config.DestinationMarkers.Color.r, Config.DestinationMarkers.Color.g, Config.DestinationMarkers.Color.b, Config.DestinationMarkers.Color.a, false, true, 2, nil, nil, false)
                        
                        if distToVehicleMarker < 3.0 then
                            inMarker = true
                        else
                            inMarker = false
                        end
                    else
                        wait = 500
                        inMarker = false
                    end
                else
                    inMarker = false
                    
                    -- Check secondary marker
                    local distToSecondaryMarker = #(pos - delivery.secondaryCoords)
                    if distToSecondaryMarker < Config.DestinationMarkers.DrawDistance then
                        wait = 0
                        DrawMarker(Config.DestinationMarkers.Type, delivery.secondaryCoords.x, delivery.secondaryCoords.y, delivery.secondaryCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.DestinationMarkers.Scale.x, Config.DestinationMarkers.Scale.y, Config.DestinationMarkers.Scale.z, Config.DestinationMarkers.Color.r, Config.DestinationMarkers.Color.g, Config.DestinationMarkers.Color.b, Config.DestinationMarkers.Color.a, false, true, 2, nil, nil, false)
                        
                        if distToSecondaryMarker < 1.5 then
                            ShowHelp(string.format(Locales.Task2, delivery.label))
                            inSecondaryMarker = true
                        else
                            inSecondaryMarker = false
                        end
                    else
                        wait = 500
                        inSecondaryMarker = false
                    end
                end
                if inMarker then
                    RemoveBlip(blip)
                    blip = AddBlipForCoord(delivery.secondaryCoords.x, delivery.secondaryCoords.y, delivery.secondaryCoords.z)
                    SetBlipSprite(blip, 1)
                    SetBlipDisplay(blip, Config.JobVehicle.Blip.Display)
                    SetBlipScale(blip, Config.JobVehicle.Blip.Scale)
                    SetBlipColour(blip, 5)
                    SetBlipAsShortRange(blip, false)
                    SetBlipRoute(blip, true)
                    SetBlipRouteColour(blip, 5)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString(delivery.label)
                    EndTextCommandSetBlipName(blip)
                    inMarker = false
                    wait = 500
                end
                
                if inSecondaryMarker then
                    -- Delivery complete
                    delivered = true
                    RemoveBlip(blip)
                    totalEarned = totalEarned + currentPayment
                    TriggerServerEvent("mester_quickiepharmDeliveryComplete", currentPayment)
                    Notify(string.format(Locales.CurrentData, currentDelivery, currentPayment, totalEarned))
                    currentDelivery = currentDelivery + 1
                    Citizen.Wait(2000)
                    nextDelivery()
                    return
                end
                
                Citizen.Wait(wait)
            end
        end)
    end
    nextDelivery()
end)