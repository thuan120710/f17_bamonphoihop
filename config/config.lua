Config = {}
QBCore = exports["qb-core"]:GetCoreObject()

Config.Debug = false
Config.Command = 'triathlon'
Config.TopCommand = 'triathlontop'
Config.StartEventName = 'f17_triathlon:start'
Config.Locale = 'vi'

-- Gameplay Settings
Config.MaxGameplayMinutes = 10
Config.MarkerDrawDistance = 650.0
Config.MarkerReachDistance = 4.0
Config.FinishReachDistance = 5.0
Config.CheckpointBlipScale = 0.85
Config.RouteBlipScale = 0.7
Config.CountdownSeconds = 10
Config.CheckpointCooldownMs = 900
Config.LeaderboardLimit = 10
Config.SharedRaceJoinSeconds = 30
Config.SharedRaceTimeoutMinutes = 15
Config.StartGridColumns = 5
Config.StartGridSpacing = 1.6
Config.BikeGridColumns = 5
Config.BikeGridSpacing = 2.4

-- Advanced Features (học từ gameracing)
Config.UseRoutingBucket = true -- Tách người chơi vào dimension riêng
Config.PassiveOnGame = true -- Ghost mode (chống va chạm)
Config.EnableSound = true -- Bật âm thanh checkpoint
Config.EnableEffects = true -- Hiệu ứng màn hình
Config.AllowRespawn = true -- Cho phép quay lại checkpoint trước (phím Y)
Config.RespawnCooldown = 2000 -- Cooldown giữa các lần respawn (ms)
Config.AutoReviveOnDeath = true -- Tự động hồi sinh khi chết
Config.TimeBeforeEnd = 100 -- Thời gian chờ người về đích đầu tiên (giây)

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
    useSpawnGrid = true,
    checkValidVehicle = true, -- Kiểm tra xe hợp lệ
    autoRepair = true -- Tự động sửa xe (xe đạp vẫn có thể hỏng)
}

-- Reward System (học từ gameracing)
Config.Rewards = {
    [1] = { -- Top 1
        points = 20,
        money = 10000,
        moneyType = 'tienkhoa',
        items = {
            {name = 'vatphamhoatdong', amount = 10},
            {name = 'homf17city', amount = 1}
        },
        xp = 20
    },
    [2] = { -- Top 2
        points = 15,
        money = 7500,
        moneyType = 'tienkhoa',
        items = {
            {name = 'vatphamhoatdong', amount = 7},
            {name = 'hopquamayrui', amount = 1}
        },
        xp = 15
    },
    [3] = { -- Top 3
        points = 10,
        money = 5000,
        moneyType = 'tienkhoa',
        items = {
            {name = 'vatphamhoatdong', amount = 5}
        },
        xp = 10
    },
    [4] = { -- Top 4
        points = 5,
        money = 5000,
        moneyType = 'tienkhoa',
        items = {
            {name = 'vatphamhoatdong', amount = 3}
        },
        xp = 10
    },
    [5] = { -- Top 5+
        points = 0,
        money = 2000,
        moneyType = 'tienkhoa',
        items = {
            {name = 'vatphamhoatdong', amount = 1}
        },
        xp = 5
    }
}

-- Revive Function
Config.ReviveFunction = function()
    TriggerEvent('ambulance:client:Revive', {Admin = true})
end

-- Language
Config.Lang = {
    title = 'TRIATHLON',
    start = 'Triathlon sắp bắt đầu',
    wait = 'Bạn đã tham gia, vui lòng chờ...',
    accept = 'Từ chối tham gia Event',
    notiwinner = 'Nhận được',
    respawn = 'Nhấn [Y] để quay lại checkpoint trước',
    wrongVehicle = 'Đây không phải xe của bạn!',
    countdown = 'Sẵn sàng...'
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
            vector3(-1853.34, -981.66, 0.59),
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

-- Marker Settings (Cột dọc cao giống gameracing)
-- Type 4 = Vertical Cylinder (cột dọc từ dưới lên cao)
-- Size.z = Chiều cao cột (150-250m để dễ nhìn từ xa)
-- Alpha thấp (100-120) để trong suốt, không che tầm nhìn
Config.Marker = {
    run = {
        type = 4, -- Cylinder vertical (cột dọc)
        size = vector3(5.0, 5.0, 150.0), -- width, depth, height (cột cao 150m)
        color = { 255, 190, 45, 100 }, -- Màu vàng, trong suốt hơn
        zOffset = -1.0,
        reachDistance = 4.0,
        bobUpAndDown = false,
        faceCamera = false,
        rotate = false
    },
    swim = {
        type = 4, -- Cylinder vertical
        size = vector3(10.0, 10.0, 200.0), -- Cột cao 200m cho dễ nhìn trong nước
        color = { 35, 170, 255, 100 }, -- Màu xanh dương
        zOffset = -1.0,
        reachDistance = 6.5,
        bobUpAndDown = false,
        faceCamera = false,
        rotate = false
    },
    bike = {
        type = 4, -- Cylinder vertical
        size = vector3(8.0, 8.0, 180.0), -- Cột cao 180m
        color = { 80, 255, 145, 100 }, -- Màu xanh lá
        zOffset = -1.0,
        reachDistance = 6.0,
        bobUpAndDown = false,
        faceCamera = false,
        rotate = false
    },
    finish = {
        type = 4, -- Cylinder vertical
        size = vector3(12.0, 12.0, 250.0), -- Cột cao nhất 250m
        color = { 255, 70, 70, 120 }, -- Màu đỏ, nổi bật hơn
        zOffset = -1.0,
        reachDistance = 7.0,
        bobUpAndDown = false,
        faceCamera = false,
        rotate = false
    }
}

Config.Blips = {
    run = { sprite = 126, color = 5 },
    swim = { sprite = 315, color = 3 },
    bike = { sprite = 376, color = 2 },
    finish = { sprite = 38, color = 1 }
}
