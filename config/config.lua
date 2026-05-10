Config = {}

Config.Debug = false
Config.Command = 'triathlon'
Config.TopCommand = 'triathlontop'
Config.StartEventName = 'f17_triathlon:start'
Config.Locale = 'vi'

Config.MaxGameplayMinutes = 10
Config.MarkerDrawDistance = 650.0
Config.MarkerReachDistance = 4.0
Config.FinishReachDistance = 5.0
Config.CheckpointBlipScale = 0.85
Config.RouteBlipScale = 0.7
Config.CountdownSeconds = 3
Config.CheckpointCooldownMs = 900
Config.LeaderboardLimit = 10
Config.SharedRaceJoinSeconds = 30
Config.SharedRaceTimeoutMinutes = 15
Config.StartGridColumns = 5
Config.StartGridSpacing = 1.6
Config.BikeGridColumns = 5
Config.BikeGridSpacing = 2.4

Config.SportsOutfit = {
    male = {
        ['tshirt_1'] = 15, ['tshirt_2'] = 0,
        ['torso_1'] = 178, ['torso_2'] = 0,
        ['arms'] = 30,
        ['pants_1'] = 77, ['pants_2'] = 0,
        ['shoes_1'] = 5, ['shoes_2'] = 0,
        ['helmet_1'] = -1, ['helmet_2'] = 0,
        ['glasses_1'] = 0, ['glasses_2'] = 0
    },
    female = {
        ['tshirt_1'] = 14, ['tshirt_2'] = 0,
        ['torso_1'] = 180, ['torso_2'] = 0,
        ['arms'] = 36,
        ['pants_1'] = 79, ['pants_2'] = 0,
        ['shoes_1'] = 5, ['shoes_2'] = 0,
        ['helmet_1'] = -1, ['helmet_2'] = 0,
        ['glasses_1'] = 5, ['glasses_2'] = 0
    }
}

Config.Vehicle = {
    model = 'tribike3',
    lockUntilOwnerMounts = true,
    cleanupSecondsAfterFinish = 0,
    useSpawnGrid = true
}

Config.Phases = {
    run = {
        label = 'CHAY BO',
        startCoords = vector4(-1434.45, -1018.41, 5.06, 109.02), -- RUN_START_COORDS
        markers = { -- RUN_MARKERS
            vector3(-1487.7, -1074.82, 3.74),
            vector3(-1573.89, -1022.69, 7.68),
            vector3(-1665.04, -963.27, 7.72),
            vector3(-1720.06, -1013.88, 5.28),
        },
        finish = vector3(-1746.15, -1037.48, 1.72) -- RUN_FINISH_MARKER
    },
    swim = {
        label = 'BOI',
        markers = { -- SWIM_MARKERS
            vector3(-1763.48, -1054.44, 0.59),
            vector3(-1829.37, -974.52, 0.12),
            vector3(-1905.76, -923.95, 0.05),
            vector3(-1983.78, -846.88, -0.66),
            vector3(-2127.57, -696.37, 0.06),
            vector3(-2186.78, -594.48, -0.67)
        },
        finish = vector3(-2268.05, -477.05, 0.83) -- SWIM_FINISH_MARKER
    },
    bike = {
        label = 'DAP XE',
        spawnCoords = vector4(-2148.15, -377.07, 13.13, 64.31), -- BIKE_SPAWN_COORDS
        markers = { -- BIKE_MARKERS
            vector3(-2023.81, -186.44, 26.6),
            vector3(-1802.85, -332.97, 43.64),
            vector3(-1675.84, -579.31, 33.64),
            vector3(-1542.53, -681.06, 28.73),
            vector3(-1457.23, -776.07, 23.65),
            vector3(-1600.91, -945.84, 13.18),
            vector3(-1630.86, -997.47, 13.02),
        },
        finish = vector3(-1612.01, -1040.28, 13.15) -- FINAL_FINISH_COORDS
    }
}

Config.Marker = {
    run = {
        type = 1,
        size = vector3(5.2, 5.2, 1.2),
        color = { 255, 190, 45, 190 },
        zOffset = -0.95,
        reachDistance = 4.0,
        bobUpAndDown = false,
        faceCamera = false,
        rotate = true
    },
    swim = {
        type = 1,
        size = vector3(10.0, 10.0, 2.0),
        color = { 35, 170, 255, 205 },
        zOffset = -1.15,
        reachDistance = 6.5,
        bobUpAndDown = false,
        faceCamera = false,
        rotate = true
    },
    bike = {
        type = 1,
        size = vector3(8.0, 8.0, 1.35),
        color = { 80, 255, 145, 195 },
        zOffset = -0.95,
        reachDistance = 6.0,
        bobUpAndDown = false,
        faceCamera = false,
        rotate = true
    },
    finish = {
        type = 1,
        size = vector3(10.0, 10.0, 1.8),
        color = { 255, 70, 70, 220 },
        zOffset = -1.0,
        reachDistance = 7.0,
        bobUpAndDown = false,
        faceCamera = false,
        rotate = true
    }
}

Config.Blips = {
    run = { sprite = 126, color = 5 },
    swim = { sprite = 315, color = 3 },
    bike = { sprite = 376, color = 2 },
    finish = { sprite = 38, color = 1 }
}
