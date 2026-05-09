# F17 3 Mon Phoi Hop

Resource FiveM minigame triathlon 3 phase: chay bo, boi, dap xe. Player duoc mac outfit the thao khi bat dau, outfit cu duoc luu lai va tra ve khi ket thuc hoac huy game.

## Cai dat

1. Dat folder `F17_bamonphoihop` vao `resources`.
2. Them vao `server.cfg`:

```cfg
ensure F17_bamonphoihop
```

3. Start server va dung command:

```txt
/triathlon
```

Nguoi dau tien dung command se mo lobby race chung. Nhung player khac dung `/triathlon` trong thoi gian cho de tham gia, sau do tat ca cung xuat phat.

Xem bang xep hang:

```txt
/triathlontop
```

Co the trigger tu NPC/menu bang client event:

```lua
TriggerEvent('f17_triathlon:start')
```

## Chinh toa do

Tat ca toa do nam trong `config/config.lua`:

- `Config.Phases.run.startCoords`: `RUN_START_COORDS`
- `Config.Phases.run.markers`: `RUN_MARKERS`
- `Config.Phases.run.finish`: `RUN_FINISH_MARKER`
- `Config.Phases.swim.markers`: `SWIM_MARKERS`
- `Config.Phases.swim.finish`: `SWIM_FINISH_MARKER`
- `Config.Phases.bike.spawnCoords`: `BIKE_SPAWN_COORDS`
- `Config.Phases.bike.markers`: `BIKE_MARKERS`
- `Config.Phases.bike.finish`: `FINAL_FINISH_COORDS`

Route mac dinh di tu beach vao city, gameplay nhanh va co marker/blip route de follow.

## Luat gameplay

- Chi teleport player den diem start khi bat dau minigame.
- Khong teleport giua cac phase.
- Phai di qua checkpoint theo thu tu.
- Den finish chay bo se chuyen sang boi.
- Den finish boi se spawn xe dap rieng cua player.
- Player phai tu leo len xe, script khong warp len xe.
- Bike phase chi tinh checkpoint khi player dang ngoi tren xe dap rieng.
- Ket thuc hoac resource stop se restore outfit cu.
- Nhieu player co the vao cung mot lobby va xuat phat chung de dua top.
- Server luu best time trong runtime va xep hang bang `/triathlontop`.
- Race chung co thoi gian cho lobby va timeout tai `Config.SharedRaceJoinSeconds`, `Config.SharedRaceTimeoutMinutes`.

## Len production

Neu server dung `skinchanger`, script se luu/restore full skin bang event cua skinchanger. Neu khong co `skinchanger`, script fallback bang native ped component/prop.

Model xe mac dinh la `tribike3`, co the doi tai:

```lua
Config.Vehicle.model = 'tribike3'
```
