local ESX, QBCore = nil, nil
local activeRace = false
local currentPhase = nil
local currentIndex = 1
local raceStart = 0
local oldSkin = nil
local spawnedBike = nil
local bikeBlip = nil -- Blip cho xe đạp
local isOnBike = false -- Đã lên xe chưa
local routeBlip = nil
local checkpointBlip = nil
local lastCheckpointAt = 0
local raceSlot = 1
local lastRespawnAt = 0
local isRaceEnding = false
local finishOrder = 0
local playerCheckpoint = 1

local function notify(message)
    if ESX and ESX.ShowNotification then
        ESX.ShowNotification(message)
    elseif QBCore and QBCore.Functions and QBCore.Functions.Notify then
        QBCore.Functions.Notify(message)
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(false, true)
    end
end

local function drawHelp(message)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandDisplayHelp(0, false, false, -1)
end

local function drawText(x, y, scale, text, alignRight)
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 230)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(false)
    if alignRight then
        SetTextRightJustify(true)
        SetTextWrap(0.0, x)
    end
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

local function formatTime(ms)
    local total = math.max(0, math.floor(ms / 1000))
    local minutes = math.floor(total / 60)
    local seconds = total % 60
    return string.format('%02d:%02d', minutes, seconds)
end

local function getFrameworks()
    if GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
    end

    if GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
    end
end

local function getPedSex(ped)
    return IsPedModel(ped, `mp_f_freemode_01`) and 'female' or 'male'
end

local function saveAndApplyOutfit()
    local ped = PlayerPedId()

    if GetResourceState('skinchanger') == 'started' then
        TriggerEvent('skinchanger:getSkin', function(skin)
            oldSkin = skin
            local outfit = Config.SportsOutfit[skin.sex == 1 and 'female' or 'male']
            TriggerEvent('skinchanger:loadClothes', skin, outfit)
        end)
        return
    end

    oldSkin = { components = {}, props = {} }
    for component = 0, 11 do
        oldSkin.components[component] = {
            drawable = GetPedDrawableVariation(ped, component),
            texture = GetPedTextureVariation(ped, component),
            palette = GetPedPaletteVariation(ped, component)
        }
    end
    for prop = 0, 7 do
        oldSkin.props[prop] = {
            drawable = GetPedPropIndex(ped, prop),
            texture = GetPedPropTextureIndex(ped, prop)
        }
    end

    local outfit = Config.SportsOutfit[getPedSex(ped)]
    SetPedComponentVariation(ped, 3, outfit.arms or 0, 0, 0)
    SetPedComponentVariation(ped, 4, outfit.pants_1 or 0, outfit.pants_2 or 0, 0)
    SetPedComponentVariation(ped, 6, outfit.shoes_1 or 0, outfit.shoes_2 or 0, 0)
    SetPedComponentVariation(ped, 8, outfit.tshirt_1 or 0, outfit.tshirt_2 or 0, 0)
    SetPedComponentVariation(ped, 11, outfit.torso_1 or 0, outfit.torso_2 or 0, 0)

    if outfit.helmet_1 and outfit.helmet_1 >= 0 then
        SetPedPropIndex(ped, 0, outfit.helmet_1, outfit.helmet_2 or 0, true)
    else
        ClearPedProp(ped, 0)
    end

    if outfit.glasses_1 and outfit.glasses_1 >= 0 then
        SetPedPropIndex(ped, 1, outfit.glasses_1, outfit.glasses_2 or 0, true)
    else
        ClearPedProp(ped, 1)
    end
end

local function restoreOutfit()
    if not oldSkin then return end

    local ped = PlayerPedId()
    if GetResourceState('skinchanger') == 'started' and oldSkin.sex ~= nil then
        TriggerEvent('skinchanger:loadSkin', oldSkin)
        oldSkin = nil
        return
    end

    for component, data in pairs(oldSkin.components or {}) do
        SetPedComponentVariation(ped, component, data.drawable, data.texture, data.palette)
    end

    for prop, data in pairs(oldSkin.props or {}) do
        if data.drawable and data.drawable >= 0 then
            SetPedPropIndex(ped, prop, data.drawable, data.texture or 0, true)
        else
            ClearPedProp(ped, prop)
        end
    end

    oldSkin = nil
end

local function clearBlips()
    if routeBlip and DoesBlipExist(routeBlip) then
        RemoveBlip(routeBlip)
    end
    if checkpointBlip and DoesBlipExist(checkpointBlip) then
        RemoveBlip(checkpointBlip)
    end
    routeBlip = nil
    checkpointBlip = nil
end

local function addCheckpointBlip(coords, phaseName, isFinish)
    clearBlips()

    local phaseBlip = isFinish and Config.Blips.finish or Config.Blips[phaseName]
    checkpointBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(checkpointBlip, phaseBlip.sprite)
    SetBlipColour(checkpointBlip, phaseBlip.color)
    SetBlipScale(checkpointBlip, isFinish and Config.CheckpointBlipScale + 0.15 or Config.CheckpointBlipScale)
    SetBlipAsShortRange(checkpointBlip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(isFinish and 'Triathlon Finish' or 'Triathlon Checkpoint')
    EndTextCommandSetBlipName(checkpointBlip)

    routeBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(routeBlip, 1)
    SetBlipColour(routeBlip, phaseBlip.color)
    SetBlipScale(routeBlip, Config.RouteBlipScale)
    SetBlipRoute(routeBlip, true)
    SetBlipRouteColour(routeBlip, phaseBlip.color)
end

local function getTarget()
    local phase = Config.Phases[currentPhase]
    if currentIndex <= #phase.markers then
        return phase.markers[currentIndex], false
    end

    return phase.finish, true
end

local function setPhase(phaseName)
    currentPhase = phaseName
    currentIndex = 1

    -- Chỉ tạo blip checkpoint nếu KHÔNG phải bike phase
    -- Bike phase sẽ tạo blip sau khi lên xe
    if phaseName ~= 'bike' then
        local target, isFinish = getTarget()
        addCheckpointBlip(target, currentPhase, isFinish)
    end
    
    notify(('Bat dau %s!'):format(Config.Phases[phaseName].label))
end

local function loadModel(model)
    local hash = type(model) == 'number' and model or joaat(model)
    if not IsModelInCdimage(hash) then return nil end

    RequestModel(hash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(0)
    end

    return HasModelLoaded(hash) and hash or nil
end

local function getGridCoords(coords, slot, columns, spacing)
    local index = math.max((slot or 1) - 1, 0)
    local column = index % columns
    local row = math.floor(index / columns)
    local heading = math.rad(coords.w)
    local forward = vector3(-math.sin(heading), math.cos(heading), 0.0)
    local right = vector3(math.cos(heading), math.sin(heading), 0.0)
    local lateral = (column - ((columns - 1) / 2)) * spacing
    local back = row * spacing * 1.5

    return vector4(
        coords.x + right.x * lateral - forward.x * back,
        coords.y + right.y * lateral - forward.y * back,
        coords.z,
        coords.w
    )
end

local function getBikeSpawnCoords()
    local coords = Config.Phases.bike.spawnCoords
    if not Config.Vehicle.useSpawnGrid then
        return coords
    end

    return getGridCoords(coords, raceSlot, Config.BikeGridColumns or 5, Config.BikeGridSpacing or 2.4)
end

local function spawnBikeForPlayer()
    local model = loadModel(Config.Vehicle.model)
    if not model then
        notify('Khong load duoc xe dap.')
        return
    end

    local coords = getBikeSpawnCoords()
    local plate = ('F17%03d'):format(GetPlayerServerId(PlayerId()) % 1000)
    
    -- Dùng QBCore.Functions.SpawnVehicle để xe được lưu vào database
    QBCore.Functions.SpawnVehicle(Config.Vehicle.model, function(veh)
        if not veh then 
            notify('Loi spawn xe dap!')
            return 
        end
        
        spawnedBike = veh
        
        -- Set properties
        SetVehicleNumberPlateText(spawnedBike, plate)
        SetEntityHeading(spawnedBike, coords.w)
        SetVehicleOnGroundProperly(spawnedBike)
        SetVehicleEngineOn(spawnedBike, true, true)
        SetVehicleDoorsLocked(spawnedBike, Config.Vehicle.lockUntilOwnerMounts and 1 or 0)
        SetEntityAsMissionEntity(spawnedBike, true, true)
        
        -- Set ownership (quan trọng!)
        TriggerEvent("vehiclekeys:client:SetOwner", plate)
        
        -- Tạo blip cho xe đạp
        bikeBlip = AddBlipForEntity(spawnedBike)
        SetBlipSprite(bikeBlip, 226) -- Bike icon
        SetBlipColour(bikeBlip, 2) -- Green
        SetBlipScale(bikeBlip, 1.0)
        SetBlipAsShortRange(bikeBlip, false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Xe dap cua ban')
        EndTextCommandSetBlipName(bikeBlip)
        
        isOnBike = false
        notify('Xe dap da san sang. Hay leo len xe de tiep tuc!')
    end, coords, true, true) -- true, true = networked, teleportInside
    
    SetModelAsNoLongerNeeded(model)
end

local function cleanupBike(delay)
    if not spawnedBike or not DoesEntityExist(spawnedBike) then return end
    local bike = spawnedBike
    spawnedBike = nil
    isOnBike = false
    
    -- Xóa blip xe đạp
    if bikeBlip and DoesBlipExist(bikeBlip) then
        RemoveBlip(bikeBlip)
        bikeBlip = nil
    end

    CreateThread(function()
        Wait((delay or 0) * 1000)
        if DoesEntityExist(bike) then
            NetworkRequestControlOfEntity(bike)
            local timeout = GetGameTimer() + 1000
            while not NetworkHasControlOfEntity(bike) and GetGameTimer() < timeout do
                Wait(0)
                NetworkRequestControlOfEntity(bike)
            end

            SetEntityAsMissionEntity(bike, true, true)
            DeleteVehicle(bike)
            if DoesEntityExist(bike) then
                DeleteEntity(bike)
            end
        end
    end)
end

local function finishRace(cancelled)
    if not activeRace then return end

    local elapsed = GetGameTimer() - raceStart
    activeRace = false
    currentPhase = nil
    clearBlips()
    restoreOutfit()
    cleanupBike(0)
    isOnBike = false
    
    -- Ẩn UI
    SendNUIMessage({
        action = 'hide'
    })
    
    -- Xóa blip xe đạp nếu còn
    if bikeBlip and DoesBlipExist(bikeBlip) then
        RemoveBlip(bikeBlip)
        bikeBlip = nil
    end
    
    -- Tắt ghost mode
    if Config.PassiveOnGame then
        SetLocalPlayerAsGhost(false)
    end
    
    -- Trả về routing bucket 0
    if Config.UseRoutingBucket then
        TriggerServerEvent('f17_triathlon:server:setRoutingBucket', 0)
    end

    if cancelled then
        notify('Ban da huy minigame 3 mon phoi hop.')
        TriggerServerEvent('f17_triathlon:server:finish', elapsed, true)
        return
    end

    -- Hiệu ứng kết thúc
    if Config.EnableEffects then
        StartScreenEffect("MinigameEndFranklin", 0, 0)
    end
    
    -- Âm thanh hoàn thành (giống gameracing)
    if Config.EnableSound then
        SendNUIMessage({
            transactionType = 'playSound',
            transactionFile = 'rightchose',
            transactionVolume = 0.5
        })
    end

    notify(('Hoan thanh 3 mon phoi hop! Thoi gian: %s'):format(formatTime(elapsed)))
    TriggerServerEvent('f17_triathlon:server:finish', elapsed, false)
end

local function passCheckpoint()
    local now = GetGameTimer()
    if now - lastCheckpointAt < (Config.CheckpointCooldownMs or 900) then
        return
    end
    lastCheckpointAt = now

    local _, isFinish = getTarget()
    
    -- Hiệu ứng và âm thanh
    if Config.EnableEffects then
        StartScreenEffect("MinigameEndFranklin", 0, 0)
    end

    if not isFinish then
        currentIndex = currentIndex + 1
        playerCheckpoint = currentIndex
        local nextTarget, nextIsFinish = getTarget()
        addCheckpointBlip(nextTarget, currentPhase, nextIsFinish)
        
        -- Âm thanh checkpoint (giống gameracing)
        if Config.EnableSound then
            SendNUIMessage({
                transactionType = 'playSound',
                transactionFile = 'rightchose',
                transactionVolume = 0.5
            })
        end
        return
    end

    -- Âm thanh finish checkpoint
    if Config.EnableSound then
        SendNUIMessage({
            transactionType = 'playSound',
            transactionFile = 'rightchose',
            transactionVolume = 0.5
        })
    end

    if currentPhase == 'run' then
        setPhase('swim')
    elseif currentPhase == 'swim' then
        spawnBikeForPlayer()
        setPhase('bike')
    elseif currentPhase == 'bike' then
        finishRace(false)
    end
end

local function getStartCoordsForSlot(slot)
    local coords = Config.Phases.run.startCoords
    return getGridCoords(coords, slot, Config.StartGridColumns or 5, Config.StartGridSpacing or 1.6)
end

local function startRace(startSlot)
    if activeRace then
        notify('Ban dang tham gia minigame roi.')
        return
    end

    local ped = PlayerPedId()
    local coords = getStartCoordsForSlot(startSlot)

    activeRace = true
    raceStart = GetGameTimer()
    lastCheckpointAt = 0
    raceSlot = startSlot or 1
    playerCheckpoint = 1
    saveAndApplyOutfit()

    -- Chuyển sang routing bucket riêng
    if Config.UseRoutingBucket then
        TriggerServerEvent('f17_triathlon:server:setRoutingBucket', 1)
    end

    DoScreenFadeOut(450)
    Wait(550)
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(ped, coords.w)
    ClearPedTasksImmediately(ped)
    DoScreenFadeIn(450)

    FreezeEntityPosition(ped, true)
    
    -- Hiển thị countdown UI
    SendNUIMessage({
        action = 'countdown',
        seconds = 5
    })
    
    -- Phát âm thanh countdown 5 giây (giống gameracing)
    if Config.EnableSound then
        SendNUIMessage({
            transactionType = 'playSound',
            transactionFile = '5count',
            transactionVolume = 0.5
        })
    end
    
    -- Countdown 5 giây
    Wait(5000)
    
    FreezeEntityPosition(ped, false)
    
    -- Bật ghost mode
    if Config.PassiveOnGame then
        SetLocalPlayerAsGhost(true)
    end
    
    -- Hiệu ứng bắt đầu
    if Config.EnableEffects then
        StartScreenEffect("MinigameEndFranklin", 0, 0)
    end

    setPhase('run')
    
    -- Hiển thị UI
    SendNUIMessage({
        action = 'show',
        phase = 'run',
        checkpoint = 0,
        totalCheckpoints = #Config.Phases.run.markers + 1,
        time = 0
    })
end

local function requestSharedRace()
    if activeRace then
        notify('Ban dang tham gia minigame roi.')
        return
    end

    TriggerServerEvent('f17_triathlon:server:joinRace')
end

CreateThread(function()
    getFrameworks()
end)

RegisterNetEvent(Config.StartEventName, requestSharedRace)
RegisterNetEvent('f17_triathlon:client:startRace', startRace)
RegisterNetEvent('f17_triathlon:client:notify', notify)
RegisterNetEvent('f17_triathlon:client:forceCancel', function()
    finishRace(true)
end)

RegisterCommand(Config.Command, function()
    requestSharedRace()
end, false)

RegisterCommand('triathlon_cancel', function()
    finishRace(true)
end, false)

CreateThread(function()
    while true do
        if not activeRace or not currentPhase then
            Wait(500)
        else
            local wait = 0
            local ped = PlayerPedId()
            local playerCoords = GetEntityCoords(ped)
            
            -- Kiểm tra nếu đang ở bike phase và chưa lên xe
            if currentPhase == 'bike' and not isOnBike then
                -- Chỉ hiển thị blip xe đạp, không hiển thị marker checkpoint
                if spawnedBike and DoesEntityExist(spawnedBike) then
                    drawHelp('Hay leo len xe dap cua ban de bat dau checkpoint bike!')
                    
                    -- Kiểm tra xem đã lên xe chưa
                    if IsPedInVehicle(ped, spawnedBike, false) then
                        isOnBike = true
                        -- Xóa blip xe đạp khi đã lên xe
                        if bikeBlip and DoesBlipExist(bikeBlip) then
                            RemoveBlip(bikeBlip)
                            bikeBlip = nil
                        end
                        -- Hiển thị checkpoint blip
                        local target, isFinish = getTarget()
                        addCheckpointBlip(target, currentPhase, isFinish)
                        notify('Da len xe! Hay di den cac checkpoint!')
                    end
                end
                Wait(100)
            else
                -- Hiển thị marker bình thường cho run, swim, hoặc bike (đã lên xe)
                local target, isFinish = getTarget()
                local distance = #(playerCoords - target)

                if distance <= Config.MarkerDrawDistance then
                    -- Lấy màu marker theo phase
                    local markerColor = isFinish and Config.MarkerColors.finish or Config.MarkerColors[currentPhase]
                    
                    -- Vẽ marker dạng cột dọc cao (giống y hệt gameracing)
                    -- Type 4 = cylinder vertical, vẽ từ dưới lên cao
                    DrawMarker(4, target.x, target.y, target.z - 1, 0, 0, 0, 0, 0, 0, 15.0, 0.1, 300.0, markerColor[1], markerColor[2], markerColor[3], markerColor[4], false, true, 2, false, false, false, false)
                else
                    wait = 150
                end

                local phase = Config.Phases[currentPhase]
                local total = #phase.markers + 1
                local checkpoint = math.min(currentIndex, total)

                if currentPhase == 'bike' then
                    if spawnedBike and DoesEntityExist(spawnedBike) and not IsPedInVehicle(ped, spawnedBike, false) then
                        drawHelp('Len xe dap cua ban de tiep tuc checkpoint bike.')
                    elseif IsPedInAnyVehicle(ped, false) and GetVehiclePedIsIn(ped, false) ~= spawnedBike then
                        drawHelp('Ban phai dung xe dap rieng cua minh.')
                    end
                end

                -- Sử dụng MarkerDist giống gameracing
                if distance <= Config.MarkerReachDistance then
                    if currentPhase ~= 'bike' then
                        passCheckpoint()
                    elseif spawnedBike and IsPedInVehicle(ped, spawnedBike, false) then
                        passCheckpoint()
                    end
                end

                -- Đã xóa check IsEntityDead ở đây vì có thread auto-revive riêng

                Wait(wait)
            end
        end
    end
end)

-- Thread kiểm tra người chơi chết và auto-revive (giống gameracing)
CreateThread(function()
    while true do
        Wait(5000) -- Check mỗi 5 giây giống gameracing
        if activeRace and Config.AutoReviveOnDeath then
            local ped = PlayerPedId()
            if LocalPlayer.state.isDead then
                Wait(1000)
                
                local phase = Config.Phases[currentPhase]
                if not phase then
                    Wait(1000)
                    goto continue
                end
                
                -- Lấy checkpoint trước đó (giống gameracing)
                local previousCheckpoint
                if currentIndex > 1 then
                    previousCheckpoint = phase.markers[currentIndex - 1]
                else
                    -- Checkpoint đầu tiên
                    if currentPhase == 'run' then
                        previousCheckpoint = phase.startCoords
                    elseif currentPhase == 'swim' then
                        previousCheckpoint = Config.Phases.run.finish
                    elseif currentPhase == 'bike' then
                        previousCheckpoint = Config.Phases.swim.finish
                    end
                end
                
                if previousCheckpoint then
                    SetEntityCoords(ped, previousCheckpoint.x, previousCheckpoint.y, previousCheckpoint.z)
                    Wait(500)
                    
                    -- Kiểm tra nếu trong nước 
                    local playerCoords = GetEntityCoords(ped)
                    if IsEntityInWater(ped) then
                        if playerCoords.z <= 0 then
                            SetEntityCoords(ped, playerCoords.x, playerCoords.y, 5.0)
                        else
                            SetEntityCoords(ped, playerCoords.x, playerCoords.y, playerCoords.z + 5)
                        end
                    end
                    
                    Wait(500)
                    Config.ReviveFunction()
                end
                
                ::continue::
            end
        end
    end
end)

-- Thread update UI realtime (giống gameracing)
CreateThread(function()
    while true do
        Wait(100) -- Update mỗi 100ms
        if activeRace and currentPhase then
            local elapsed = GetGameTimer() - raceStart
            local timeSeconds = math.floor(elapsed / 1000)
            
            -- Tính tổng checkpoint
            local phase = Config.Phases[currentPhase]
            local totalCheckpoints = phase and (#phase.markers + 1) or 0
            
            -- Gửi update UI
            SendNUIMessage({
                action = 'update',
                phase = currentPhase,
                checkpoint = currentIndex - 1,
                totalCheckpoints = totalCheckpoints,
                time = timeSeconds
            })
        end
    end
end)

-- Thread kiểm tra xe không hợp lệ 
CreateThread(function()
    while true do
        Wait(1000)
        if activeRace and currentPhase == 'bike' and Config.Vehicle.checkValidVehicle then
            local ped = PlayerPedId()
            if IsPedSittingInAnyVehicle(ped) then
                local playerVehicle = GetVehiclePedIsIn(ped, false)
                if playerVehicle ~= spawnedBike then
                    ClearPedTasksImmediately(ped)
                    notify(Config.Lang.wrongVehicle or 'Day khong phai xe cua ban!')
                end
            end
        end
    end
end)

-- Thread tự động sửa xe đạp 
CreateThread(function()
    while true do
        Wait(1000)
        if activeRace and currentPhase == 'bike' and spawnedBike and DoesEntityExist(spawnedBike) then
            local ped = PlayerPedId()
            local playerVehicle = GetVehiclePedIsIn(ped, false)
            
            if playerVehicle == spawnedBike and Config.Vehicle.autoRepair then
                SetVehicleBodyHealth(playerVehicle, 1000.0)
                SetVehicleEngineHealth(playerVehicle, 1000.0)
            end
        end
    end
end)

-- Thread respawn về checkpoint trước (phím Y) 
CreateThread(function()
    while true do
        Wait(100)
        if activeRace and Config.AllowRespawn then
            if IsControlPressed(0, 246) then -- Phím Y
                local now = GetGameTimer()
                if now - lastRespawnAt >= (Config.RespawnCooldown or 2000) then
                    lastRespawnAt = now
                    
                    if currentIndex > 1 then
                        local ped = PlayerPedId()
                        local phase = Config.Phases[currentPhase]
                        local previousCheckpoint = phase.markers[currentIndex - 1]
                        
                        if previousCheckpoint then
                            -- Xóa xe nếu đang ở phase bike
                            if currentPhase == 'bike' and spawnedBike then
                                cleanupBike(0)
                            end
                            
                            SetEntityCoords(ped, previousCheckpoint.x, previousCheckpoint.y, previousCheckpoint.z + 0.5)
                            notify('Da quay lai checkpoint truoc')
                            
                            -- Spawn lại xe nếu cần
                            if currentPhase == 'bike' then
                                Wait(500)
                                spawnBikeForPlayer()
                            end
                        end
                    else
                        notify('Ban dang o checkpoint dau tien!')
                    end
                end
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    restoreOutfit()
    cleanupBike(0)
    clearBlips()
end)
