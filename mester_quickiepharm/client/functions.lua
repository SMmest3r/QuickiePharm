local usedMissionVariants = {}

function ErrPrint(msg)
    print("^1[ERROR] " .. msg .. "^0")
end

function DebugPrint(msg)
    if Config.Debug then
        print("^3[DEBUG] " .. msg .. "^0")
    end
end

function ShowHelp(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

function Notify(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(msg)
    DrawNotification(false, false)
end

function DoorScene() --//TODO: Make this full GTA:O style
    local ped = PlayerPedId()
    if not ped or ped <= 0 then return end
    if doorSceneActive then
        DebugPrint("DoorScene already active; skipping.")
        return
    end
    DebugPrint("Starting door scene...")
    doorSceneActive = true
    CreateThread(function()
        while doorSceneActive do
            DisableAllControlActions(0)
            Wait(0)
        end
    end)
    ClearPedTasksImmediately(ped)
    local px, py, pz = table.unpack(GetEntityCoords(ped))
    local fx, fy = table.unpack(GetEntityForwardVector(ped))
    local targetX = px + fx * 1.2
    local targetY = py + fy * 1.2
    local targetZ = pz
    TaskGoStraightToCoord(ped, targetX, targetY, targetZ, 1.0, 600, GetEntityHeading(ped), 0.0)
    Wait(600)
    DoScreenFadeOut(500)
    local fadeTimeout = GetGameTimer() + 2000
    while not IsScreenFadedOut() and GetGameTimer() < fadeTimeout do
        Wait(10)
    end
    FreezeEntityPosition(ped, true)
    Wait(1000)
    FreezeEntityPosition(ped, false)
    ClearPedTasks(ped)
    doorSceneActive = false
    Citizen.SetTimeout(5000, function()
        DoScreenFadeIn(500)
    end)
end

function selectRoutes(numRoutes)
    DebugPrint("Selecting " .. numRoutes .. " routes for the job.")
    local routes = {}
    for category, locations in pairs(Config.Deliveries) do
        for _, location in pairs(locations) do
            table.insert(routes, {
                coords = location.coords,
                secondaryCoords = location.secondaryCoords,
                label = location.label,
                category = category
            })
        end
    end
    
    -- Cap numRoutes to available routes to prevent deadloop crash
    if numRoutes > #routes then
        ErrPrint("Requested " .. numRoutes .. " routes but only " .. #routes .. " available. Selecting all available routes.")
        numRoutes = #routes
    end
    
    local selectedRoutes = {}
    local usedIndices = {}
    for i = 1, numRoutes do
        local index
        repeat
            index = math.random(1, #routes)
        until not usedIndices[index]
        usedIndices[index] = true
        table.insert(selectedRoutes, routes[index])
    end
    return selectedRoutes
end

function getPaymentForDistance(distance)
    for maxDistance, data in pairs(Config.PaymentAndTime) do
        if distance <= maxDistance then
            return data
        end
    end
    return nil
end

function getRandomMissionVariant(category)
    local variants = {}
    local baseKey = "MissionText" .. category:sub(1,1):upper() .. category:sub(2, -2) -- Remove 's' and capitalize
    local i = 1
    while true do
        local key = baseKey .. i
        if Locales[key] then
            table.insert(variants, i)
            i = i + 1
        else
            break
        end
    end
    if #variants == 0 then
        return nil
    end
    if not usedMissionVariants[category] then
        usedMissionVariants[category] = {}
    end
    local availableVariants = {}
    for _, variantNum in ipairs(variants) do
        if not usedMissionVariants[category][variantNum] then
            table.insert(availableVariants, variantNum)
        end
    end
    if #availableVariants == 0 then
        availableVariants = variants
        usedMissionVariants[category] = {}
    end
    local selectedVariant = availableVariants[math.random(1, #availableVariants)]
    usedMissionVariants[category][selectedVariant] = true
    return selectedVariant
end

function showMissionText(deliveryNum, totalDeliveries, label, category)
    local text = string.format(Locales.Task, label)
    
    -- Check for special messages first (halfway and final)
    if deliveryNum == math.floor(totalDeliveries / 2) then
        text = string.format(Locales.HalfwayThereMissionText, label)
    elseif deliveryNum == totalDeliveries then
        text = string.format(Locales.FinalMissionText, label)
    else
        -- Select a random mission text variant for the category
        if category == "hospitals" or category == "arcades" or category == "airports" then
            local variantNum = getRandomMissionVariant(category)
            if variantNum then
                local baseKey = "MissionText" .. category:sub(1,1):upper() .. category:sub(2, -2)
                local key = baseKey .. variantNum
                if Locales[key] then
                    text = string.format(Locales[key], label)
                end
            end
        end
    end
    
    Notify(text)
end

function showReturnVehicleTask(deliveries, earned)
    DebugPrint("All deliveries complete, showing return vehicle task.")
    local returned = false
    CreateThread(function()
        while not returned do
            SetTextFont(4)
            SetTextScale(0.5, 0.5)
            SetTextColour(255, 255, 255, 255)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextDropShadow()
            SetTextOutline()
            SetTextCentre(true)
            SetTextEntry("STRING")
            AddTextComponentSubstringPlayerName(Locales.Task3)
            DrawText(0.5, 0.9)
            Wait(0)
        end
    end)
    Citizen.CreateThread(function()
        while not returned and inJob do
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local dist = #(pos - Config.Location)
            if dist < 3.0 then
                returned = true
                completeJob(deliveries, earned)
            end
            Citizen.Wait(500)
        end
    end)
end

function completeJob(deliveries, earned)
    DebugPrint("Job complete. Deliveries: " .. deliveries .. ", Total earned: $" .. earned)
    inJob = false
    usedMissionVariants = {}
    TriggerServerEvent("mester_quickiepharmEndedJob", true)
    Notify(string.format(Locales.CurrentData, deliveries, 0, earned))
end