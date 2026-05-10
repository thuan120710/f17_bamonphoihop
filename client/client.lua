local ESX, QBCore = nil, nil
local activeRace = false
local currentPhase = nil
local currentIndex = 1
local raceStart = 0
local oldSkin = nil
local spawnedBike = nil
local routeBlip = nil
local checkpointBlip = nil
local lastCheckpointAt = 0
local raceSlot = 1

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

    local target, isFinish = getTarget()
    addCheckpointBlip(target, currentPhase, isFinish)
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
    spawnedBike = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, true)
    SetEntityAsMissionEntity(spawnedBike, true, true)
    SetVehicleOnGroundProperly(spawnedBike)
    SetVehicleNumberPlateText(spawnedBike, ('F17%03d'):format(GetPlayerServerId(PlayerId()) % 1000))
    SetVehicleDoorsLocked(spawnedBike, Config.Vehicle.lockUntilOwnerMounts and 1 or 0)
    SetModelAsNoLongerNeeded(model)
    notify('Xe dap da san sang. Hay tu leo len xe de tiep tuc!')
end

local function cleanupBike(delay)
    if not spawnedBike or not DoesEntityExist(spawnedBike) then return end
    local bike = spawnedBike
    spawnedBike = nil

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

    if cancelled then
        notify('Ban da huy minigame 3 mon phoi hop.')
        TriggerServerEvent('f17_triathlon:server:finish', elapsed, true)
        return
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

    if not isFinish then
        currentIndex = currentIndex + 1
        local nextTarget, nextIsFinish = getTarget()
        addCheckpointBlip(nextTarget, currentPhase, nextIsFinish)
        PlaySoundFrontend(-1, 'CHECKPOINT_NORMAL', 'HUD_MINI_GAME_SOUNDSET', true)
        return
    end

    PlaySoundFrontend(-1, 'CHECKPOINT_PERFECT', 'HUD_MINI_GAME_SOUNDSET', true)

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
    saveAndApplyOutfit()

    DoScreenFadeOut(450)
    Wait(550)
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(ped, coords.w)
    ClearPedTasksImmediately(ped)
    DoScreenFadeIn(450)

    FreezeEntityPosition(ped, true)
    for i = Config.CountdownSeconds, 1, -1 do
        notify(('San sang... %s'):format(i))
        Wait(1000)
    end
    FreezeEntityPosition(ped, false)

    setPhase('run')
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
            local target, isFinish = getTarget()
            local distance = #(playerCoords - target)
            local markerConfig = isFinish and Config.Marker.finish or Config.Marker[currentPhase]

            if distance <= Config.MarkerDrawDistance then
                DrawMarker(
                    markerConfig.type,
                    target.x, target.y, target.z + (markerConfig.zOffset or -0.85),
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    markerConfig.size.x, markerConfig.size.y, markerConfig.size.z,
                    markerConfig.color[1], markerConfig.color[2], markerConfig.color[3], markerConfig.color[4],
                    markerConfig.bobUpAndDown or false,
                    markerConfig.faceCamera or false,
                    2,
                    markerConfig.rotate or false,
                    nil, nil, false
                )
            else
                wait = 150
            end

            local phase = Config.Phases[currentPhase]
            local total = #phase.markers + 1
            local checkpoint = math.min(currentIndex, total)
            local remaining = (Config.MaxGameplayMinutes * 60000) - (GetGameTimer() - raceStart)
            drawText(0.982, 0.70, 0.48, ('F17 TRIATHLON | %s'):format(phase.label), true)
            drawText(0.982, 0.735, 0.42, ('Checkpoint %d/%d | Timer %s'):format(checkpoint, total, formatTime(GetGameTimer() - raceStart)), true)
            drawText(0.982, 0.765, 0.36, ('Target pace: %s'):format(formatTime(remaining)), true)

            if currentPhase == 'bike' then
                if spawnedBike and DoesEntityExist(spawnedBike) and not IsPedInVehicle(ped, spawnedBike, false) then
                    drawHelp('Len xe dap cua ban de tiep tuc checkpoint bike.')
                elseif IsPedInAnyVehicle(ped, false) and GetVehiclePedIsIn(ped, false) ~= spawnedBike then
                    drawHelp('Ban phai dung xe dap rieng cua minh.')
                end
            end

            local reachDistance = markerConfig.reachDistance or (isFinish and Config.FinishReachDistance or Config.MarkerReachDistance)
            if distance <= reachDistance then
                if currentPhase ~= 'bike' then
                    passCheckpoint()
                elseif spawnedBike and IsPedInVehicle(ped, spawnedBike, false) then
                    passCheckpoint()
                end
            end

            if IsEntityDead(ped) then
                finishRace(true)
            end

            Wait(wait)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    restoreOutfit()
    cleanupBike(0)
    clearBlips()
end)
