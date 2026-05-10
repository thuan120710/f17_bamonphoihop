# F17 Ba Môn Phối Hợp (Triathlon) - Enhanced Version v2.0.0

Minigame 3 môn phối hợp (chạy bộ, bơi, đạp xe) được nâng cấp với các tính năng học hỏi từ f17_gameracing.

## 🎮 Tính năng mới (v2.0.0)

### Gameplay Enhancements
- ✅ **Routing Bucket System**: Tách người chơi vào dimension riêng, tránh va chạm với người ngoài
- ✅ **Ghost Mode**: Chế độ xuyên qua người chơi khác (PassiveOnGame)
- ✅ **Respawn System**: Nhấn phím **Y** để quay lại checkpoint trước
- ✅ **Auto-Revive**: Tự động hồi sinh khi chết và đưa về checkpoint trước
- ✅ **Vehicle Protection**: Kiểm tra xe hợp lệ, tự động sửa xe, xăng không giới hạn
- ✅ **Sound & Effects**: Âm thanh checkpoint, hiệu ứng màn hình nâng cao
- ✅ **Vertical Markers**: Marker dạng cột dọc cao (giống gameracing) thay vì marker tròn, dễ nhìn thấy từ xa

### 🏆 Reward System
- **Top 1**: 20 điểm, 10,000 tiền khóa, 10x vatphamhoatdong, 1x homf17city, 20 XP
- **Top 2**: 15 điểm, 7,500 tiền khóa, 7x vatphamhoatdong, 1x hopquamayrui, 15 XP
- **Top 3**: 10 điểm, 5,000 tiền khóa, 5x vatphamhoatdong, 10 XP
- **Top 4**: 5 điểm, 5,000 tiền khóa, 3x vatphamhoatdong, 10 XP
- **Top 5+**: 0 điểm, 2,000 tiền khóa, 1x vatphamhoatdong, 5 XP

### 🔧 Technical Features
- Tích hợp với `f17_level` (XP system)
- Tích hợp với `f17_daotrentroi` (điểm xếp hạng, hình phạt)
- Tích hợp với `ox_inventory` (items)
- Export `StartMiniGame()` để gọi từ resource khác
- **Lưu ý**: Không cần `f17fuel` vì chỉ dùng xe đạp

## Cài đặt

1. Đặt folder `F17_bamonphoihop` vào `resources`
2. Thêm vào `server.cfg`:

```cfg
ensure F17_bamonphoihop
```

3. Start server và dùng command `/triathlon`

## Sử dụng

### Cách 1: Dùng lệnh trực tiếp (KHÔNG cần lên đảo)

```
/triathlon - Tham gia minigame ngay lập tức
/triathlontop - Xem bảng xếp hạng
/triathlon_cancel - Hủy minigame
Phím Y - Quay lại checkpoint trước (trong game)
```

**Cách hoạt động:**
1. Người đầu tiên gõ `/triathlon` sẽ mở lobby
2. Người khác gõ `/triathlon` trong 30 giây để tham gia cùng
3. Sau 30 giây, tất cả cùng xuất phát
4. Tự động teleport đến điểm start, không cần lên đảo

### Cách 2: Tích hợp với Đảo Trên Trời (CẦN lên đảo)

**Yêu cầu:** Đã cài đặt `f17_daotrentroi`

**Cách hoạt động:**
1. Lên đảo trên trời (dùng lệnh hoặc NPC)
2. Chờ hệ thống mở vote
3. Vote chọn "3 Môn Phối Hợp (Triathlon)"
4. Khi đủ vote, minigame tự động bắt đầu
5. Tất cả người trên đảo cùng tham gia

**Cấu hình trong `f17_daotrentroi/config.lua`:**
```lua
['triathlon'] = {
    loai = 'triathlon',
    label = '3 Môn Phối Hợp (Triathlon)',
    vote = 0,
    minplayer = 2, -- Tối thiểu 2 người
    key = {}
}
```

**Đã tích hợp trong `f17_daotrentroi/server/O-sv.lua`:**
```lua
elseif ketqua.loai == 'triathlon' then
    exports['F17_bamonphoihop']:StartMiniGame(GlobalState.lastPosition, ketqua.label)
end
```

### Trigger từ NPC/Menu
```lua
TriggerEvent('f17_triathlon:start')
```

### Gọi từ resource khác
```lua
exports['F17_bamonphoihop']:StartMiniGame(playerData, 'Triathlon Event')
```

## Cấu hình nâng cao

### Config.lua - Các tùy chọn mới

```lua
-- Advanced Features (học từ gameracing)
Config.UseRoutingBucket = true -- Bật/tắt routing bucket
Config.PassiveOnGame = true -- Ghost mode (xuyên người chơi)
Config.EnableSound = true -- Âm thanh checkpoint
Config.EnableEffects = true -- Hiệu ứng màn hình
Config.AllowRespawn = true -- Cho phép respawn (phím Y)
Config.RespawnCooldown = 2000 -- Cooldown respawn (ms)
Config.AutoReviveOnDeath = true -- Tự động hồi sinh khi chết
Config.CountdownSeconds = 10 -- Đếm ngược trước khi bắt đầu

-- Vehicle Settings (Xe đạp)
Config.Vehicle = {
    model = 'tribike3',
    checkValidVehicle = true, -- Kiểm tra xe hợp lệ
    autoRepair = true -- Tự động sửa xe đạp (không cần xăng)
}

-- Rewards (có thể tùy chỉnh)
Config.Rewards = {
    [1] = { 
        points = 20, 
        money = 10000, 
        moneyType = 'tienkhoa',
        items = {
            {name = 'vatphamhoatdong', amount = 10},
            {name = 'homf17city', amount = 1}
        },
        xp = 20
    }
    -- ... Top 2-5
}

-- Revive Function (tùy chỉnh theo server)
Config.ReviveFunction = function()
    TriggerEvent('ambulance:client:Revive', {Admin = true})
end
```

## Chỉnh tọa độ

Tất cả tọa độ trong `config/config.lua`:

- `Config.Phases.run.startCoords`: Điểm xuất phát chạy bộ
- `Config.Phases.run.markers`: Checkpoint chạy bộ
- `Config.Phases.run.finish`: Điểm kết thúc chạy bộ
- `Config.Phases.swim.markers`: Checkpoint bơi
- `Config.Phases.swim.finish`: Điểm kết thúc bơi
- `Config.Phases.bike.spawnCoords`: Điểm spawn xe đạp
- `Config.Phases.bike.markers`: Checkpoint đạp xe
- `Config.Phases.bike.finish`: Điểm kết thúc cuối cùng

## Tùy chỉnh Markers (Cột dọc)

Markers được thiết kế dạng **cột dọc cao** (vertical cylinder) giống gameracing để dễ nhìn thấy từ xa:

```lua
Config.Marker = {
    run = {
        type = 4, -- Cylinder vertical (cột dọc)
        size = vector3(5.0, 5.0, 150.0), -- width, depth, height (cột cao 150m)
        color = { 255, 190, 45, 100 }, -- R, G, B, Alpha (màu vàng)
        zOffset = -1.0, -- Offset từ mặt đất
        reachDistance = 4.0 -- Khoảng cách để pass checkpoint
    },
    swim = {
        type = 4,
        size = vector3(10.0, 10.0, 200.0), -- Cột cao 200m (dễ nhìn trong nước)
        color = { 35, 170, 255, 100 }, -- Màu xanh dương
        -- ...
    },
    bike = {
        type = 4,
        size = vector3(8.0, 8.0, 180.0), -- Cột cao 180m
        color = { 80, 255, 145, 100 }, -- Màu xanh lá
        -- ...
    },
    finish = {
        type = 4,
        size = vector3(12.0, 12.0, 250.0), -- Cột cao nhất 250m (nổi bật)
        color = { 255, 70, 70, 120 }, -- Màu đỏ
        -- ...
    }
}
```

### Giải thích Marker Settings:

- **type = 4**: Cylinder vertical (cột dọc), giống gameracing
- **size.x, size.y**: Đường kính cột (width/depth)
- **size.z**: Chiều cao cột (height) - càng cao càng dễ nhìn từ xa
- **color**: [R, G, B, Alpha] - Alpha thấp (100-120) để trong suốt, không che tầm nhìn
- **zOffset**: Offset từ tọa độ checkpoint (thường -1.0 để bắt đầu từ dưới đất)
- **reachDistance**: Khoảng cách để pass checkpoint

### So sánh với marker cũ:

| Thuộc tính | Marker cũ (tròn) | Marker mới (cột dọc) |
|------------|------------------|----------------------|
| Type | 1 (Cylinder) | 4 (Vertical Cylinder) |
| Chiều cao | 1-2m | 150-250m |
| Nhìn thấy từ xa | ❌ Khó | ✅ Dễ dàng |
| Giống gameracing | ❌ | ✅ |
| Alpha | 190-220 (đậm) | 100-120 (trong suốt) |

## Luật gameplay

- Teleport player đến điểm start khi bắt đầu minigame
- Không teleport giữa các phase
- Phải đi qua checkpoint theo thứ tự
- Đến finish chạy bộ → chuyển sang bơi
- Đến finish bơi → spawn xe đạp riêng
- Player phải tự leo lên xe (không warp)
- Bike phase chỉ tính checkpoint khi đang ngồi trên xe đạp riêng
- **MỚI**: Nhấn Y để quay lại checkpoint trước
- **MỚI**: Tự động hồi sinh khi chết
- **MỚI**: Ghost mode tránh va chạm
- Kết thúc hoặc resource stop sẽ restore outfit cũ
- Nhiều player có thể vào cùng lobby và xuất phát chung
- Server lưu best time và xếp hạng

## So sánh phiên bản

| Tính năng | v1.0.0 | v2.0.0 |
|-----------|--------|--------|
| Routing Bucket | ❌ | ✅ |
| Ghost Mode | ❌ | ✅ |
| Respawn System | ❌ | ✅ (Phím Y) |
| Auto-Revive | ❌ | ✅ |
| Vehicle Check | ❌ | ✅ |
| Auto Repair | ❌ | ✅ |
| Sound/Effects | Cơ bản | ✅ Nâng cao |
| Reward System | ❌ | ✅ Top 1-5 |
| XP Integration | ❌ | ✅ f17_level |
| Leaderboard Points | ❌ | ✅ f17_daotrentroi |

## Học hỏi từ f17_gameracing

Các tính năng được tích hợp thành công:

1. ✅ Routing Bucket System - Tách dimension
2. ✅ Spawn Grid System - Sắp xếp người chơi
3. ✅ Ghost Mode (PassiveOnGame) - Chống va chạm
4. ✅ Respawn về checkpoint (phím Y)
5. ✅ Auto-revive khi chết
6. ✅ Vehicle validation & auto-repair
7. ✅ Sound & screen effects
8. ✅ Reward system theo top
9. ✅ Integration với các resource khác
10. ✅ Export function để gọi từ bên ngoài

## Dependencies

### Required
- `qb-core` - Framework

### Optional
- `ox_inventory` - Inventory system (cho rewards)
- `f17_level` - XP system
- `f17_daotrentroi` - Leaderboard & punishment
- `skinchanger` - Outfit system (ESX)

### Không cần thiết
- ❌ `f17fuel` - Không cần vì chỉ dùng xe đạp
- ❌ `f17-assets` - Không sử dụng trong minigame này

## Lên production

- Nếu server dùng `skinchanger`, script sẽ lưu/restore full skin
- Nếu không có `skinchanger`, script fallback bằng native ped component/prop
- Model xe mặc định là `tribike3`, có thể đổi trong config
- Tất cả tính năng mới có thể bật/tắt trong config

## Credits

- **Original**: F17 Team
- **Enhanced**: Học hỏi từ f17_gameracing
- **Version**: 2.0.0
- **Author**: F17 Team

## Changelog

### v2.0.0 (2024)
- ✅ Thêm Routing Bucket System
- ✅ Thêm Ghost Mode
- ✅ Thêm Respawn System (phím Y)
- ✅ Thêm Auto-Revive
- ✅ Thêm Vehicle Protection
- ✅ Thêm Sound & Effects nâng cao
- ✅ Thêm Reward System theo top
- ✅ Tích hợp f17_level, f17_daotrentroi
- ✅ Export StartMiniGame()
- ✅ **Đổi marker sang dạng cột dọc cao (vertical cylinder) giống gameracing**

### v1.0.0
- Phiên bản gốc với 3 phase cơ bản
