# Debug Auto-Revive (Giống gameracing)

## ✅ Đã sửa - Đơn giản hóa

### Vấn đề cũ:
- Thread chính check `IsEntityDead(ped)` → `finishRace(true)` (kết thúc game ngay)
- Quá phức tạp với nhiều cách revive

### Giải pháp (giống gameracing):
1. ✅ **Xóa** `IsEntityDead` check trong thread chính
2. ✅ **Thread auto-revive đơn giản**:
   - Check mỗi **5 giây** (giống gameracing)
   - Chỉ check `LocalPlayer.state.isDead`
   - Chỉ dùng 1 cách revive đơn giản
3. ✅ **Config đơn giản**:
   ```lua
   Config.ReviveFunction = function()
       TriggerEvent('ambulance:client:Revive', {Admin = true})
   end
   ```

## 🔧 Config ReviveFunction (Giống gameracing)

```lua
-- Đơn giản, chỉ 1 cách
Config.ReviveFunction = function()
    TriggerEvent('ambulance:client:Revive', {Admin = true})
end
```

## 🎮 Cách hoạt động

### Khi chết:
1. Thread auto-revive phát hiện (check mỗi **5 giây**)
2. Chờ 1 giây
3. Xác định checkpoint trước đó
4. Teleport về checkpoint
5. Kiểm tra nếu trong nước → Teleport lên cao
6. Gọi `Config.ReviveFunction()` để hồi sinh

## 🧪 Test

### Test cơ bản:
```
1. Bắt đầu minigame
2. Chạy qua checkpoint 1
3. Tự sát
4. Chờ 5 giây
5. Kết quả: Hồi sinh tại checkpoint 1
```

## 🔍 Debug

### Nếu không hồi sinh:
1. Check `Config.AutoReviveOnDeath = true` trong config
2. Tùy chỉnh `Config.ReviveFunction()` theo ambulance script của server:

```lua
-- QBCore
Config.ReviveFunction = function()
    TriggerEvent('hospital:client:Revive')
end

-- ESX
Config.ReviveFunction = function()
    TriggerEvent('esx_ambulancejob:revive')
end

-- Visn
Config.ReviveFunction = function()
    TriggerEvent('visn_are:resetHealthBuffer')
end
```

## ⚙️ Config Options

```lua
-- Bật/tắt auto-revive
Config.AutoReviveOnDeath = true -- true = tự động hồi sinh, false = kết thúc game

-- Tùy chỉnh hàm revive (đơn giản)
Config.ReviveFunction = function()
    TriggerEvent('ambulance:client:Revive', {Admin = true})
end
```

## 📊 So sánh với gameracing

| Tính năng | gameracing | bamonphoihop |
|-----------|------------|--------------|
| Check interval | 5 giây | 5 giây ✅ |
| Check method | `LocalPlayer.state.isDead` | `LocalPlayer.state.isDead` ✅ |
| Revive function | `VKConfig.reviveOnEndGame()` | `Config.ReviveFunction()` ✅ |
| Số cách revive | 1 | 1 ✅ |
| Xử lý trong nước | ✅ | ✅ |

## ✅ Kết luận

Giờ hoàn toàn giống gameracing:
- ✅ Check mỗi 5 giây
- ✅ Chỉ dùng 1 cách revive đơn giản
- ✅ Code gọn gàng, dễ maintain
- ✅ Tự động hồi sinh tại checkpoint trước
