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

RegisterNetEvent("mester_quickiepharmStartedJob", function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local tries = 0

    -- Wait for the vehicle to be valid
    while not veh or veh <= 0 or tries > 50 do
        Citizen.Wait(100)
        veh = GetVehiclePedIsIn(ped, false)
        tries = tries + 1
    end

    -- If we have a valid vehicle, set the livery if configured
    if veh and veh > 0 then
        if Config.JobVehicle.Livery then
            DebugPrint("Setting job vehicle livery to " .. Config.JobVehicle.Livery)
            SetVehicleModKit(veh, 0)
            SetVehicleMod(veh, 48, Config.JobVehicle.Livery, false)
        end
    end
    DoScreenFadeIn(500)
end)