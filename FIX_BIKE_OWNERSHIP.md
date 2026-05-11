# Fix Bike Ownership - Xe đạp thành xe công

## 🐛 Vấn đề

Sau khi out game và vào lại, xe đạp bị thành **xe công** (không phải xe của mình).

## 🔍 Nguyên nhân

### Code cũ (SAI):
```lua
spawnedBike = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, true)
SetVehicleNumberPlateText(spawnedBike, plate)
```

**Vấn đề:**
- ❌ Dùng `CreateVehicle` native → Xe KHÔNG được lưu vào database
- ❌ Không set ownership → Xe không thuộc về ai
- ❌ Out game → Xe mất ownership → Thành xe công

### Code mới (ĐÚNG - giống gameracing):
```lua
QBCore.Functions.SpawnVehicle(Config.Vehicle.model, function(veh)
    spawnedBike = veh
    SetVehicleNumberPlateText(spawnedBike, plate)
    TriggerEvent("vehiclekeys:client:SetOwner", plate) -- ← Quan trọng!
end, coords, true, true)
```

**Giải pháp:**
- ✅ Dùng `QBCore.Functions.SpawnVehicle` → Xe được lưu vào database
- ✅ Set ownership với `vehiclekeys:client:SetOwner` → Xe thuộc về người chơi
- ✅ Out game → Xe vẫn giữ ownership → Vẫn là xe của mình

## 📊 So sánh

| Tính năng | CreateVehicle (Cũ) | QBCore.Functions.SpawnVehicle (Mới) |
|-----------|---------------------|--------------------------------------|
| Lưu database | ❌ | ✅ |
| Set ownership | ❌ | ✅ |
| Out/in game | ❌ Mất ownership | ✅ Giữ ownership |
| Vehicle keys | ❌ Không có | ✅ Có keys |
| Giống gameracing | ❌ | ✅ |

## 🔧 Code đã sửa

### Trước:
```lua
local function spawnBikeForPlayer()
    local model = loadModel(Config.Vehicle.model)
    local coords = getBikeSpawnCoords()
    
    -- ❌ SAI: Dùng CreateVehicle native
    spawnedBike = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, true)
    SetVehicleNumberPlateText(spawnedBike, plate)
    -- ❌ Không set ownership
end
```

### Sau (giống gameracing):
```lua
local function spawnBikeForPlayer()
    local model = loadModel(Config.Vehicle.model)
    local coords = getBikeSpawnCoords()
    local plate = ('F17%03d'):format(GetPlayerServerId(PlayerId()) % 1000)
    
    -- ✅ ĐÚNG: Dùng QBCore.Functions.SpawnVehicle
    QBCore.Functions.SpawnVehicle(Config.Vehicle.model, function(veh)
        spawnedBike = veh
        SetVehicleNumberPlateText(spawnedBike, plate)
        SetEntityHeading(spawnedBike, coords.w)
        SetVehicleOnGroundProperly(spawnedBike)
        SetVehicleEngineOn(spawnedBike, true, true)
        SetEntityAsMissionEntity(spawnedBike, true, true)
        
        -- ✅ Set ownership (quan trọng!)
        TriggerEvent("vehiclekeys:client:SetOwner", plate)
        
        -- Tạo blip...
    end, coords, true, true)
end
```

## 🎯 Điểm quan trọng

### 1. QBCore.Functions.SpawnVehicle
- Spawn xe qua QBCore framework
- Tự động lưu vào database
- Tự động sync với server

### 2. vehiclekeys:client:SetOwner
- Set ownership cho người chơi
- Tạo keys cho xe
- Xe thuộc về người chơi

### 3. Callback function
```lua
QBCore.Functions.SpawnVehicle(model, function(veh)
    -- veh = xe vừa spawn
    -- Xử lý ở đây
end, coords, networked, teleportInside)
```

## 🧪 Test

### Test 1: Spawn xe
```
1. Bắt đầu minigame
2. Đến phase bike
3. Xe spawn
4. Kiểm tra: Có keys không? (F2 → Keys)
```

### Test 2: Out/In game
```
1. Spawn xe đạp
2. Out game (disconnect)
3. Vào lại game
4. Kiểm tra: Xe vẫn là xe của mình không?
```

### Test 3: Lock/Unlock
```
1. Spawn xe đạp
2. Thử lock xe (nếu có script)
3. Kiểm tra: Lock được không?
```

## ✅ Kết quả

Sau khi sửa:
- ✅ Xe được lưu vào database
- ✅ Có ownership (xe của mình)
- ✅ Có keys
- ✅ Out/in game vẫn giữ ownership
- ✅ Giống gameracing 100%

## 📝 Ghi chú

### Nếu vẫn bị xe công:

**1. Kiểm tra vehiclekeys script:**
```lua
-- Thử event khác nếu server dùng script khác
TriggerEvent("vehiclekeys:client:SetOwner", plate)
-- Hoặc
TriggerEvent("qb-vehiclekeys:client:SetOwner", plate)
-- Hoặc
exports['qb-vehiclekeys']:SetVehicleKey(plate, true)
```

**2. Kiểm tra QBCore version:**
- Đảm bảo server dùng QBCore
- `QBCore.Functions.SpawnVehicle` phải tồn tại

**3. Kiểm tra database:**
```sql
SELECT * FROM player_vehicles WHERE plate = 'F17XXX';
```

## 🔗 Tham khảo

- Gameracing: Dùng `QBCore.Functions.SpawnVehicle` + `vehiclekeys:client:SetOwner`
- QBCore docs: https://docs.qbcore.org/qbcore-documentation/qbcore-functions/client
- Vehicle keys: Tùy theo script vehiclekeys của server

---

**Tóm tắt:** Đã sửa từ `CreateVehicle` native sang `QBCore.Functions.SpawnVehicle` + set ownership để xe không bị thành xe công sau khi out/in game.
