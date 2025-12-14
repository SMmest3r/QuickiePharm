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
    TaskGoStraightToCoord(ped, targetX, targetY, targetZ, 1.0, 1000, GetEntityHeading(ped), 0.0)
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
    DoScreenFadeIn(500)
    doorSceneActive = false
end