function ErrPrint(msg)
    print("\27[31m [ERROR] \27[37m " .. msg)
end

function DebugPrint(msg)
    if Config.Debug then
        print("\27[33m [DEBUG] \27[37m " .. msg)
    end
end

function GiveMoney(player, amount)
    DebugPrint("Giving $" .. amount .. " to player " .. player)
    -- You should implement your framework's money-giving logic here.
    -- ESX Example:
    --[[ local xPlayer = ESX.GetPlayerFromId(player)
    if xPlayer then
        xPlayer.addMoney(amount)
        DebugPrint("Successfully gave $" .. amount .. " to player " .. player)
    else
        ErrPrint("Failed to find player with ID " .. player)
    end ]]
    ErrPrint("GiveMoney function is not implemented. Please add your money-giving logic.") -- Remove this line after implementation
end

function IsSpawnpointClear(x, y, z, radius)
    local vehicles = {}
    for k, v in pairs(GetGamePool('CVehicle')) do
        local vehicleCoords = GetEntityCoords(v)
        local distance = #(vector3(x, y, z) - vector3(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z))
        if distance < radius then
            table.insert(vehicles, v)
        end
    end
    local clear = false
    if not vehicles or #vehicles == 0 then
        clear = true
    end
    return clear
end