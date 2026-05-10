# Hướng dẫn Marker - Cột sáng tròn cao

## 🎯 Bí quyết tạo cột TRÒN (không vuông)

### Trong gameracing:
```lua
DrawMarker(4, x, y, z - 1, 0, 0, 0, 0, 0, 0, 15.0, 0.1, 300.0, 102, 178, 255, 70, ...)
--                                              ^^^^  ^^^  ^^^^^
--                                              width depth height
```

### Công thức:
- **Width (size.x)**: 15.0 - Đường kính cột
- **Depth (size.y)**: **0.1** ← **BÍ QUYẾT TẠO CỘT TRÒN!**
- **Height (size.z)**: 150-300 - Chiều cao cột

## 🔍 Tại sao depth = 0.1 tạo cột tròn?

### Depth = 5.0 (vuông):
```
Nhìn từ trên xuống:
┌─────────┐
│         │  ← Hình vuông
│         │
└─────────┘
```

### Depth = 0.1 (tròn):
```
Nhìn từ trên xuống:
    │  ← Rất mỏng, trông như đường tròn
    │
```

Khi depth rất mỏng (0.1), marker type 4 sẽ hiển thị như một **đường tròn dọc** thay vì hình vuông!

## 📐 Config trong F17_bamonphoihop

```lua
Config.Marker = {
    run = {
        type = 4,
        size = vector3(15.0, 0.1, 150.0), -- Giống gameracing
        color = { 255, 190, 45, 70 },
        zOffset = -1.0,
        reachDistance = 4.0
    },
    swim = {
        type = 4,
        size = vector3(15.0, 0.1, 200.0), -- Cao hơn vì trong nước
        color = { 35, 170, 255, 70 }
    },
    bike = {
        type = 4,
        size = vector3(15.0, 0.1, 180.0),
        color = { 80, 255, 145, 70 }
    },
    finish = {
        type = 4,
        size = vector3(15.0, 0.1, 300.0), -- Cao nhất
        color = { 255, 70, 70, 100 }
    }
}
```

## 🎨 Màu sắc & Alpha

### Màu sắc:
- 🟡 **Run**: RGB(255, 190, 45) - Vàng
- 🔵 **Swim**: RGB(35, 170, 255) - Xanh dương
- 🟢 **Bike**: RGB(80, 255, 145) - Xanh lá
- 🔴 **Finish**: RGB(255, 70, 70) - Đỏ

### Alpha (độ trong suốt):
- **70-100**: Trong suốt, không che tầm nhìn
- Gameracing dùng: **70**
- Finish dùng: **100** (nổi bật hơn)

## 📊 So sánh các giá trị

| Thuộc tính | Giá trị cũ | Giá trị mới (giống gameracing) |
|------------|------------|--------------------------------|
| Type | 1 | 4 |
| Width | 5.0 | **15.0** |
| Depth | 5.0 | **0.1** ← Tạo tròn |
| Height | 1-2m | 150-300m |
| Alpha | 100-120 | **70-100** |
| Hình dạng | Vuông | **Tròn** |

## 🔧 Tùy chỉnh

### Muốn cột to hơn:
```lua
size = vector3(20.0, 0.1, 300.0) -- Width = 20
```

### Muốn cột cao hơn:
```lua
size = vector3(15.0, 0.1, 500.0) -- Height = 500m
```

### Muốn cột đậm hơn:
```lua
color = { 255, 190, 45, 150 } -- Alpha = 150
```

### ⚠️ KHÔNG thay đổi depth!
```lua
size = vector3(15.0, 5.0, 300.0) -- ❌ Sẽ thành vuông!
size = vector3(15.0, 0.1, 300.0) -- ✅ Giữ 0.1 để tròn
```

## 🎮 Kết quả

Với config này, markers sẽ hiển thị như:
- ✅ Cột sáng **tròn** cao vút lên trời
- ✅ Nhìn thấy từ rất xa (hàng trăm mét)
- ✅ Trong suốt, không che tầm nhìn
- ✅ Giống hệt gameracing
- ✅ Màu sắc phân biệt rõ ràng

## 📝 Ghi chú

### DrawMarker parameters:
```lua
DrawMarker(
    type,           -- 4 = Vertical Cylinder
    x, y, z,        -- Vị trí
    dirX, dirY, dirZ, -- Direction (0, 0, 0)
    rotX, rotY, rotZ, -- Rotation (0, 0, 0)
    scaleX,         -- Width = 15.0
    scaleY,         -- Depth = 0.1 ← Tạo tròn
    scaleZ,         -- Height = 150-300
    r, g, b, a,     -- Color + Alpha
    bobUpAndDown,   -- false
    faceCamera,     -- true
    p19,            -- 2
    rotate,         -- false
    textureDict,    -- nil
    textureName,    -- nil
    drawOnEnts      -- false
)
```

### Tham khảo từ gameracing:
```lua
DrawMarker(4, x, y, z - 1, 0, 0, 0, 0, 0, 0, 15.0, 0.1, 300.0, 102, 178, 255, 70, false, true, 2, false, false, false, false)
```

## ✅ Checklist

- [x] Type = 4 (Vertical Cylinder)
- [x] Width = 15.0
- [x] **Depth = 0.1** ← Quan trọng nhất!
- [x] Height = 150-300m
- [x] Alpha = 70-100
- [x] zOffset = -1.0
- [x] faceCamera = true (trong DrawMarker)

Với config này, bạn sẽ có cột sáng tròn đẹp giống hệt gameracing! 🎉
