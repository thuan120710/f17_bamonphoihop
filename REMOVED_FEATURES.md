# Các tính năng đã loại bỏ khỏi f17_gameracing

## ❌ Không áp dụng vào Triathlon

### 1. Fuel System (Hệ thống xăng)
**Lý do**: Minigame chỉ dùng xe đạp, không cần xăng
- ❌ `Config.Vehicle.unlimitedFuel`
- ❌ `exports['f17fuel']:SetFuel()`
- ❌ Dependency `f17fuel`

### 2. Vehicle Spawn System phức tạp
**Lý do**: Triathlon chỉ spawn 1 xe đạp duy nhất, không cần spawn nhiều xe theo checkpoint
- ❌ `Config.SpawnVeh` (spawn xe theo từng checkpoint)
- ❌ `DeletePoint` system (xóa xe theo checkpoint)
- ❌ Multiple vehicle spawning logic

### 3. Sprint/Boost Points
**Lý do**: Triathlon không có điểm tăng tốc
- ❌ `Config.SprintPoint`
- ❌ `ApplyForceToEntity()` boost logic
- ❌ Sprint marker drawing

### 4. Advanced Particle Effects
**Lý do**: Không cần thiết cho gameplay đơn giản
- ❌ Particle effects khi stunt
- ❌ `RequestNamedPtfxAsset()`
- ❌ `StartNetworkedParticleFxNonLoopedOnPedBone()`

### 5. NUI System
**Lý do**: Triathlon dùng native text drawing, không cần UI phức tạp
- ❌ `ui_page "html/ui.html"`
- ❌ `SendNUIMessage()` calls
- ❌ HTML/CSS/JS files
- ❌ Sound files trong NUI

### 6. Advanced Parking Integration
**Lý do**: Không cần hệ thống parking phức tạp
- ❌ `exports["AdvancedParking"]`
- ❌ Dependency `f17-assets` cho GeneratePlate

### 7. Multiple Game Modes
**Lý do**: Triathlon chỉ có 1 mode cố định (run-swim-bike)
- ❌ `Config['Mode_bike_lightstrack']`
- ❌ `Config['Mode_car']`
- ❌ `Config['Mode_jetski']`
- ❌ Multiple checkpoint configs

### 8. Webhook/Discord Integration
**Lý do**: Có thể thêm sau nếu cần
- ❌ `sendToDiscord()` function
- ❌ Discord webhook URLs
- ❌ Leaderboard posting to Discord

### 9. Complex Vehicle Management
**Lý do**: Xe đạp đơn giản, không cần quản lý phức tạp
- ❌ Vehicle health monitoring per checkpoint
- ❌ Vehicle deletion per checkpoint
- ❌ Multiple vehicle type handling

### 10. Advanced Countdown System
**Lý do**: Triathlon dùng countdown đơn giản
- ❌ Sound countdown files
- ❌ Complex NUI countdown display
- ❌ Multiple countdown timers

## ✅ Đã giữ lại và tối ưu

### Tính năng quan trọng được giữ:
1. ✅ Routing Bucket System
2. ✅ Ghost Mode (PassiveOnGame)
3. ✅ Respawn System (phím Y)
4. ✅ Auto-Revive khi chết
5. ✅ Vehicle validation (kiểm tra xe hợp lệ)
6. ✅ Auto-repair xe đạp
7. ✅ Screen effects (StartScreenEffect)
8. ✅ Sound effects (PlaySoundFrontend)
9. ✅ Reward system theo top
10. ✅ Integration với f17_level, f17_daotrentroi

## 📊 So sánh kích thước code

| Component | f17_gameracing | F17_bamonphoihop | Giảm |
|-----------|----------------|------------------|------|
| Client.lua | ~600 lines | ~450 lines | 25% |
| Config.lua | ~800 lines | ~150 lines | 81% |
| Dependencies | 8 resources | 4 resources | 50% |
| UI Files | HTML/CSS/JS | Không có | 100% |
| Sound Files | MP3 files | Native sounds | 100% |

## 🎯 Kết luận

Đã loại bỏ thành công các tính năng không cần thiết cho minigame Triathlon, giữ lại chỉ những gì quan trọng:
- Code gọn gàng hơn 50%
- Dependencies giảm 50%
- Dễ maintain và debug
- Performance tốt hơn
- Vẫn giữ được tất cả tính năng core từ gameracing

**Tổng kết**: Từ một racing system phức tạp với nhiều mode, đã tối ưu thành một triathlon system đơn giản, hiệu quả và dễ sử dụng.
