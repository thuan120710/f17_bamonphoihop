Config = {}
QBCore = exports["qb-core"]:GetCoreObject()

Config.Debug = false
Config.Command = 'triathlon'
Config.TopCommand = 'triathlontop'
Config.StartEventName = 'f17_triathlon:start'
Config.Locale = 'vi'

-- Gameplay Settings
Config.MaxGameplayMinutes = 10
Config.MarkerDrawDistance = 5000.0 -- Giống gameracing (vẽ marker khi < 5000m)
Config.MarkerReachDistance = 7.0 -- Giống gameracing MarkerDist
Config.CheckpointBlipScale = 0.85
Config.RouteBlipScale = 0.7
Config.CountdownSeconds = 5 -- Đổi từ 10s sang 5s để phù hợp với âm thanh 5count
Config.CheckpointCooldownMs = 900
Config.LeaderboardLimit = 10
Config.SharedRaceJoinSeconds = 30
Config.SharedRaceTimeoutMinutes = 15
Config.StartGridColumns = 5
Config.StartGridSpacing = 1.6
Config.BikeGridColumns = 5
Config.BikeGridSpacing = 5.0 -- Tăng từ 2.4 lên 5.0 để xe cách xa nhau

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

-- Revive Function (giống gameracing)
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
     swim = {
        label = 'BOI',
        startCoords = vector4(2393.03, 4284.78, 32.12, 92.36), -- SWIM_START_COORDS
        markers = { -- SWIM_MARKERS
            vector3(2315.54, 4283.88, 30.01),
            vector3(2261.54, 4249.38, 30.29),
            vector3(2198.99, 4160.97, 29.96),
            vector3(2143.51, 4061.23, 29.46),
        },
        finish = vector3(2123.34, 3959.12, 29.26) -- SWIM_FINISH_MARKER
    },
        bike = {
        label = 'DAP XE',
        spawnCoords = vector4(2140.9, 3892.29, 33.18, 123.72), -- BIKE_SPAWN_COORDS
        markers = { -- BIKE_MARKERS
            vector3(2017.14, 3822.75, 32.31),
            vector3(1932.35, 3709.37, 32.47),
            vector3(1761.95, 3609.0, 34.79),
            vector3(1659.4, 3493.63, 36.54),
            vector3(1289.65, 3534.56, 35.29),
            vector3(1116.17, 3505.16, 33.78),
            vector3(1053.97, 3247.78, 37.82),
            vector3(916.33, 3179.67, 38.4),
            vector3(1012.38, 3030.35, 41.39),
            vector3(1098.75, 2901.4, 38.09),
            vector3(1133.15, 2763.25, 37.67),
            vector3(1220.25, 2678.47, 37.65),
            vector3(1391.56, 2692.8, 37.62),
            vector3(1542.53, 2775.77, 38.13),
            vector3(1793.82, 2929.29, 45.78),
            vector3(1882.08, 3039.24, 45.35),
            vector3(1884.37, 3183.15, 45.86),
            vector3(1809.2, 3316.13, 42.25),
            vector3(1734.62, 3449.69, 38.74),
        },
        finish = vector3(1663.97, 3568.79, 35.54), -- BIKE_FINISH_MARKER
    },
    run = {
        label = 'CHAY BO',
        markers = { -- RUN_MARKERS
            vector3(1697.69, 3681.86, 34.76),
            vector3(1697.69, 3681.86, 34.76),
            vector3(1723.25, 3790.94, 34.76),
        },
        finish = vector3(1643.95, 3874.23, 34.29) -- RUN_FINISH_MARKER
    }
}

-- Marker Settings (Giống gameracing nhưng có màu riêng cho từng phase)
-- Type 4 = Vertical Cylinder (cột dọc từ dưới lên cao)
-- Size: 15.0, 0.1, 300.0 (width, depth, height) - giống gameracing
-- Chỉ khác màu sắc cho từng bộ môn
Config.MarkerColors = {
    run = { 255, 190, 45, 70 },      -- Màu vàng - Chạy bộ
    swim = { 35, 170, 255, 70 },     -- Màu xanh dương - Bơi
    bike = { 80, 255, 145, 70 },     -- Màu xanh lá - Đạp xe
    finish = { 255, 70, 70, 100 }    -- Màu đỏ - Đích (nổi bật hơn)
}

Config.Blips = {
    run = { sprite = 126, color = 5 },
    swim = { sprite = 315, color = 3 },
    bike = { sprite = 376, color = 2 },
    finish = { sprite = 38, color = 1 }
}
