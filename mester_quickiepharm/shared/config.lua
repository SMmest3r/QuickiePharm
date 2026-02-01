Config = {}

--@type boolean
Config.Debug = true -- Toggle debug prints

--@type string
Config.Language = "en" -- Set the language. To see available languages, check the 'locales' folder.

--@type string
Config.DefaultInteractionKey = "E" -- Default key for interaction (players can rebind this in settings)

--@type vector3
Config.Location = vec3(-357.4647, -234.8997, 37.2721) -- Job location

--@type integer
Config.RoutePerJob = 6 -- Number of deliveries per job

--@type table
Config.BlipData = { -- The job's icon on the map
    --@type integer
    Sprite = 940, -- https://docs.fivem.net/docs/game-references/blips/
    --@type integer
    Color = 26, -- https://docs.fivem.net/docs/game-references/blips/#blip-colors
    --@type float
    Scale = 0.8, -- Size (0.0 - 1.0)
    --@type integer
    Display = 4, -- https://docs.fivem.net/natives/?_0x9029B2F3DA924928
    --@type boolean
    ShortRange = true, -- If true, blip will only show up when nearby
    --@type string
    Name = "QuickiePharm" -- Icon's label
}

--@type string
Config.JobProp = "w_am_weaponcasem51" -- Prop used to simulate carrying the delivery items, also can be seen in the job vehicle's backseats

--@type table
Config.JobVehicle = { -- Vehicle used for the job
    --@type string
    Model = "sentinel5", -- Vehicle model for the job
    --@type table|boolean
    Color = { primary = 111, secondary = 111 }, -- Vehicle colors (use false to ignore)
    --@type integer|boolean
    Livery = 10, -- Vehicle livery (paint job). false to ignore
    --@type string
    Plate = "  PH4RM", -- Vehicle plate text
    --@type boolean
    SetDirtLevel = true, -- If true, vehicle's dirt level is set to 0 on spawn'
    --@type boolean
    DeleteWhenUndriveable = true, -- If true, vehicle is deleted when vehicle becomes undriveable
    --@type table
    SpawnPoints = { -- Possible vehicle spawnpoints
        --@type vector4
        vec4(-358.0884, -223.2472, 37.2706, 55.0842),
    },
    --@type table
    Blip = { -- The job vehicle's icon on the map
        --@type integer
        Sprite = 225, -- https://docs.fivem.net/docs/game-references/blips/
        --@type integer
        Color = 26, -- https://docs.fivem.net/docs/game-references/blips/#blip-colors
        --@type float
        Scale = 0.8, -- Size (0.0 - 1.0)
        --@type integer
        Display = 4, -- https://docs.fivem.net/natives/?_0x9029B2F3DA924928
        --@type boolean
        ShortRange = true, -- If true, blip will only show up when nearby
        --@type string
        Name = "Medical Vehicle" -- Icon's label
    }
}

--@type table
Config.JobMarker = { -- Marker for the job start location
    --@type integer
    Type = 1, -- https://docs.fivem.net/docs/game-references/markers/
    --@type vector3
    Scale = vec3(1.0, 1.0, 0.6), -- Size of the marker (X, Y, Z)
    --@type table
    Color = { r = 255, g = 255, b = 255, a = 100 }, -- Color of the marker (R = Red, G = Green, B = Blue, A = Alpha)
    --@type float
    DrawDistance = 20.0 -- Distance at which the marker will be drawn
}

--@type float
Config.VehicleDestinationMarkerMultiplier = 1.5 -- Multiplier for the destination marker size compared to the default DestinationMarkers

--@type table
Config.DestinationMarkers = { -- Markers for delivery locations
    --@type integer
    Type = 1, -- https://docs.fivem.net/docs/game-references/markers/
    --@type vector3
    Scale = vec3(1.5, 1.5, 1.0), -- Size of the marker (X, Y, Z)
    --@type table
    Color = { r = 255, g = 255, b = 0, a = 100 }, -- Color of the marker (R = Red, G = Green, B = Blue, A = Alpha)
    --@type float
    DrawDistance = 20.0 -- Distance at which the marker will be drawn
}

--@type table
Config.Deliveries = { -- Delviery locations and messages
    --@type table
    ["hospitals"] = {
        --@type table
        { coords = vec3(362.4255, -590.9781, 28.6715), secondaryCoords = vec3(359.9487, -584.9711, 28.8197), label = "Pillbox Medical Center" },
        -- { coords = vec3(0, 0, 0), secondaryCoords = vec3(0, 0, 0), label = "Sandy Shores Medical Center" },
    },
    ["airports"] = {
        --@type table
        -- { coords = vec3(0, 0, 0), secondaryCoords = vec3(0, 0, 0), label = "LSIA" },
    },
    ["arcades"] = {
        --@type table
        -- { coords = vec3(0, 0, 0), secondaryCoords = vec3(0, 0, 0), label = "Wonderama Arcade" },
    },
}

--@type table
Config.PaymentAndTime = { -- Payment and time per delivery based on distance.
    --@type integer Distance in units
    --@type table Payment and time values
    [3000] = {payment = 5000, time = 230000}, -- If distance is less than or equal to 3000 units, pay 5000 and give 230 seconds to complete.
    [6000] = {payment = 7500, time = 300000}, -- If distance is less than or equal to 6000 units, pay 8000 and give 300 seconds to complete.
    [99999] = {payment = 10000, time = 400000}, -- If distance is less than or equal to 99999 units, pay 10000 and give 400 seconds to complete.
}

--@type boolean
Config.ShouldBringBackVehicle = true -- If true, player must return the vehicle to the starting location to complete the job. If false, vehicle is removed on delivery completion just like in GTA:O