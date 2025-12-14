Config = {}

Config.Debug = true -- Toggle debug prints

Config.Language = "en" -- Set the language. To see available languages, check the 'locales' folder.

Config.DefaultInteractionKey = "E" -- Default key for interaction (players can rebind this in settings)

Config.Location = vec3(-357.4647, -234.8997, 37.2721) -- Job location

Config.RoutePerJob = 6 -- Number of deliveries per job

-- The job's icon on the map
Config.BlipData = {
    Sprite = 51, -- https://docs.fivem.net/docs/game-references/blips/
    Color = 26, -- https://docs.fivem.net/docs/game-references/blips/#blip-colors
    Scale = 0.8, -- Size (0.0 - 1.0)
    Display = 4, -- https://docs.fivem.net/natives/?_0x9029B2F3DA924928
    ShortRange = true, -- If true, blip will only show up when nearby
    Name = "QuickiePharm" -- Icon's label
}

Config.JobVehicle = {
    Model = "sentinel5", -- Vehicle model for the job
    Livery = 10, -- Vehicle livery (paint job). false to ignore
    Plate = "PH4RM", -- Vehicle plate text
    SpawnPoints = { -- Possible vehicle spawnpoints
        vec4(-358.0884, -223.2472, 37.2706, 55.0842),
    },
}

Config.JobMarker = { -- Marker for the job start location
    Type = 1, -- https://docs.fivem.net/docs/game-references/markers/
    Scale = vec3(1.0, 1.0, 0.6), -- Size of the marker (X, Y, Z)
    Color = { r = 255, g = 255, b = 255, a = 100 }, -- Color of the marker (R = Red, G = Green, B = Blue, A = Alpha)
    DrawDistance = 20.0 -- Distance at which the marker will be drawn
}

Config.DestinationMarkers = { -- Markers for delivery locations
    Type = 1, -- https://docs.fivem.net/docs/game-references/markers/
    Scale = vec3(1.5, 1.5, 1.0), -- Size of the marker (X, Y, Z)
    Color = { r = 255, g = 255, b = 0, a = 100 }, -- Color of the marker (R = Red, G = Green, B = Blue, A = Alpha)
    DrawDistance = 20.0 -- Distance at which the marker will be drawn
}

Config.Deliveries = { -- Delviery locations and messages
    { coords = vec3(0, 0, 0), text = "Here will be the little story thing, the sms from the QuickiePharm about the delivery." },
}

Config.PaymentAndTime = { -- Payment and time per delivery based on distance.
    [3000] = {payment = 5000, time = 230000}, -- If distance is less than or equal to 3000 units, pay 5000 and give 230 seconds to complete.
    [6000] = {payment = 7500, time = 300000}, -- If distance is less than or equal to 6000 units, pay 8000 and give 300 seconds to complete.
    [99999] = {payment = 10000, time = 400000}, -- If distance is less than or equal to 99999 units, pay 10000 and give 400 seconds to complete.
}