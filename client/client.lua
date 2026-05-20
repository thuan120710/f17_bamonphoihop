local ESX, QBCore = nil, nil
local isStuntActive = false
local playerCheckpoint = 1
local raceEndPoint = 0
local dathamgia = false
local isRaceStopped = false
local isInVehicle = false
local isRaceEnding = false
local currentVehicle = nil
local isWaypointSet = false
local isRestarting = false

local currentPhase = 'swim'
local currentIndex = 1
local raceSlot = 1
local raceStart = 0
local oldSkin = nil
local bikeBlip = nil
local routeBlip = nil
local checkpointBlip = nil
local lastCheckpointAt = 0
local lastRespawnAt = 0
local Joined = false
local pressed = false
local bikePhaseCompleted = false

local phaseOrder = { 'swim', 'bike', 'run' }

local function notify(message, notifyType, length)
    if QBCore and QBCore.Functions and QBCore.Functions.Notify then
        QBCore.Functions.Notify(message, notifyType or 'primary', length or 3000)
    elseif ESX and ESX.ShowNotification then
        ESX.ShowNotification(message)
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(false, true)
    end
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
    if routeBlip and DoesBlipExist(routeBlip) then RemoveBlip(routeBlip) end
    if checkpointBlip and DoesBlipExist(checkpointBlip) then RemoveBlip(checkpointBlip) end
    routeBlip = nil
    checkpointBlip = nil
end

local function cleanupBike()
    if bikeBlip and DoesBlipExist(bikeBlip) then
        RemoveBlip(bikeBlip)
        bikeBlip = nil
    end

    if currentVehicle and DoesEntityExist(currentVehicle) then
        NetworkRequestControlOfEntity(currentVehicle)
        local timeout = GetGameTimer() + 1000
        while not NetworkHasControlOfEntity(currentVehicle) and GetGameTimer() < timeout do
            Wait(0)
            NetworkRequestControlOfEntity(currentVehicle)
        end

        SetEntityAsMissionEntity(currentVehicle, true, true)
        DeleteVehicle(currentVehicle)
        if DoesEntityExist(currentVehicle) then
            DeleteEntity(currentVehicle)
        end
    end

    currentVehicle = nil
    isInVehicle = false
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
    AddTextComponentString(isFinish and 'Ba mon phoi hop Finish' or 'Ba mon phoi hop Checkpoint')
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

local function getRaceEndPoint()
    local total = 0
    for _, phaseName in ipairs(phaseOrder) do
        local phase = Config.Phases[phaseName]
        total = total + #phase.markers + 1
    end
    return total
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

local function getStartCoordsForSlot(slot)
    local coords = Config.Phases.swim.startCoords
    return getGridCoords(coords, slot, Config.StartGridColumns or 5, Config.StartGridSpacing or 1.6)
end

local function getBikeSpawnCoords()
    local coords = Config.Phases.bike.spawnCoords
    if Config.Vehicle.useSpawnGrid == false then
        return coords
    end

    return getGridCoords(coords, raceSlot, Config.BikeGridColumns or 5, Config.BikeGridSpacing or 2.4)
end

local function setPhase(phaseName)
    currentPhase = phaseName
    currentIndex = 1
    isWaypointSet = false

    if phaseName ~= 'bike' then
        local target, isFinish = getTarget()
        addCheckpointBlip(target, currentPhase, isFinish)
    end

    notify(('Bat dau %s!'):format(Config.Phases[phaseName].label))
end

local function spawnBikeForPlayer()
    if not QBCore then
        getFrameworks()
    end

    if not QBCore then return end

    cleanupBike()

    local coords = getBikeSpawnCoords()
    local plate = ('F17%03d'):format(GetPlayerServerId(PlayerId()) % 1000)

    QBCore.Functions.SpawnVehicle(Config.Vehicle.model, function(veh)
        if not veh then
            notify('Loi spawn xe dap!', 'error')
            return
        end

        currentVehicle = veh
        SetVehicleNumberPlateText(currentVehicle, plate)
        SetEntityHeading(currentVehicle, coords.w)
        SetVehicleOnGroundProperly(currentVehicle)
        SetVehicleEngineOn(currentVehicle, true, true)
        SetEntityAsMissionEntity(currentVehicle, true, true)
        TriggerEvent('vehiclekeys:client:SetOwner', plate)

        bikeBlip = AddBlipForEntity(currentVehicle)
        SetBlipSprite(bikeBlip, 226)
        SetBlipColour(bikeBlip, 2)
        SetBlipScale(bikeBlip, 1.0)
        SetBlipAsShortRange(bikeBlip, false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Xe dap cua ban')
        EndTextCommandSetBlipName(bikeBlip)

        isInVehicle = false
        notify('Xe dap da san sang! Hay leo len xe de tiep tuc.')
    end, coords, true, false)
end

local function getPreviousCheckpoint()
    local phase = Config.Phases[currentPhase]
    if not phase then return nil end

    if currentIndex > 1 then
        return phase.markers[currentIndex - 1]
    end

    if currentPhase == 'swim' then
        return phase.startCoords
    elseif currentPhase == 'bike' then
        return Config.Phases.swim.finish
    elseif currentPhase == 'run' then
        return Config.Phases.bike.finish
    end

    return nil
end

local function updateRaceUi(detailType, timeSeconds)
    local phase = Config.Phases[currentPhase]
    if not phase then return end

    SendNUIMessage({
        action = 'update',
        phase = currentPhase,
        checkpoint = currentIndex - 1,
        totalCheckpoints = #phase.markers + 1,
        time = timeSeconds or math.floor((GetGameTimer() - raceStart) / 1000)
    })
end

local function passCheckpoint()
    local now = GetGameTimer()
    if now - lastCheckpointAt < (Config.CheckpointCooldownMs or 900) then return end
    lastCheckpointAt = now

    local _, isFinish = getTarget()

    if Config.EnableEffects then
        StartScreenEffect('MinigameEndFranklin', 0, 0)
    end

    if Config.EnableSound then
        SendNUIMessage({
            transactionType = 'playSound',
            transactionFile = 'rightchose',
            transactionVolume = 0.5
        })
    end

    if not isFinish then
        currentIndex = currentIndex + 1
        playerCheckpoint = playerCheckpoint + 1
        isWaypointSet = false
        local target, nextIsFinish = getTarget()
        addCheckpointBlip(target, currentPhase, nextIsFinish)
        return
    end

    playerCheckpoint = playerCheckpoint + 1

    if currentPhase == 'swim' then
        spawnBikeForPlayer()
        setPhase('bike')
        return
    end

    if currentPhase == 'bike' then
        local ped = PlayerPedId()
        if currentVehicle and DoesEntityExist(currentVehicle) and IsPedInVehicle(ped, currentVehicle, false) then
            SetVehicleForwardSpeed(currentVehicle, 0.0)
            TaskLeaveVehicle(ped, currentVehicle, 0)
            Wait(1200)
        end

        bikePhaseCompleted = true
        isInVehicle = false
        setPhase('run')
        return
    end

    if currentPhase == 'run' and not isRaceStopped then
        isRaceStopped = true
        TriggerServerEvent('f17_bamonphoihop:sv:GotWinner')
        playerCheckpoint = raceEndPoint + 1
    end
end

local function finishLocal()
    cleanupBike()
    clearBlips()
    restoreOutfit()
    SendNUIMessage({ action = 'hide' })

    if Config.PassiveOnGame then
        SetLocalPlayerAsGhost(false)
    end

    if Config.UseRoutingBucket ~= false then
        TriggerServerEvent('f17_bamonphoihop:sv:setRoutingBucket', 0)
    end
end

RegisterNetEvent('f17_bamonphoihop:cl:StartGameBaMonPhoiHop', function(slot)
    if not QBCore then
        getFrameworks()
    end

    TriggerEvent('f17_bamonphoihop:cl:Restart', true)
    Joined = false

    if Config.EnableEffects then
        StartScreenEffect('MinigameEndFranklin', 0, 0)
    end

    TriggerServerEvent('f17_bamonphoihop:sv:Isjoining')
    Wait(1500)
    if not Joined then Wait(1000) end

    TriggerEvent('f17_bamonphoihop:cl:StartRaceGame', slot or 1)
end)

RegisterNetEvent('f17_bamonphoihop:cl:SetPlayerJoined', function()
    Joined = true
end)

RegisterNetEvent('f17_bamonphoihop:cl:StartRaceGame', function(slot)
    if not QBCore then
        getFrameworks()
    end

    local gameTimerSeconds = 0
    local gameTimerTicks = 0
    local ped = PlayerPedId()

    playerCheckpoint = 1
    raceEndPoint = getRaceEndPoint()
    raceSlot = slot or 1
    isRestarting = false
    isRaceStopped = false
    bikePhaseCompleted = false

    if Joined then
        dathamgia = true
        FreezeEntityPosition(ped, true)
    end

    Wait(100)
    if dathamgia then
        saveAndApplyOutfit()

        if Config.UseRoutingBucket ~= false then
            TriggerServerEvent('f17_bamonphoihop:sv:setRoutingBucket', 1)
        end

        local coords = getStartCoordsForSlot(raceSlot)
        DoScreenFadeOut(450)
        Wait(550)
        SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
        SetEntityHeading(ped, coords.w)
        ClearPedTasksImmediately(ped)
        DoScreenFadeIn(450)

        FreezeEntityPosition(ped, true)
        SendNUIMessage({ action = 'countdown', seconds = Config.CountdownSeconds or 5 })

        if Config.EnableSound then
            SendNUIMessage({
                transactionType = 'playSound',
                transactionFile = '5count',
                transactionVolume = 0.5
            })
        end

        Wait((Config.CountdownSeconds or 5) * 1000)

        FreezeEntityPosition(ped, false)
        if Config.PassiveOnGame then
            SetLocalPlayerAsGhost(true)
        end

        if Config.EnableEffects then
            StartScreenEffect('MinigameEndFranklin', 0, 0)
        end

        raceStart = GetGameTimer()
        setPhase('swim')
        SendNUIMessage({
            action = 'show',
            phase = 'swim',
            checkpoint = 0,
            totalCheckpoints = #Config.Phases.swim.markers + 1,
            time = 0
        })

        CreateThread(function()
            local updateCounter = 0
            local sleep = 1000

            while dathamgia do
                if not dathamgia then break end

                if updateCounter == 50 then
                    if not isRestarting then
                        updateRaceUi(2, gameTimerSeconds)
                    end
                    updateCounter = 0
                end
                updateCounter = updateCounter + 1

                local target, isFinish = getTarget()
                local playerCoords = GetEntityCoords(ped)

                local waitingBikeMount = false
                if currentPhase == 'bike' and not isInVehicle then
                    if currentVehicle and DoesEntityExist(currentVehicle) then
                        if IsPedInVehicle(ped, currentVehicle, false) then
                            isInVehicle = true
                            if bikeBlip and DoesBlipExist(bikeBlip) then
                                RemoveBlip(bikeBlip)
                                bikeBlip = nil
                            end
                            addCheckpointBlip(target, currentPhase, isFinish)
                            notify('Da len xe! Hay di den cac checkpoint.')
                        else
                            waitingBikeMount = true
                        end
                    else
                        waitingBikeMount = true
                    end
                end

                if waitingBikeMount then
                    sleep = 250
                else
                    if not isWaypointSet then
                        SetNewWaypoint(target.x, target.y)
                        isWaypointSet = true
                    end

                    local dist = #(playerCoords - vector3(target.x, target.y, target.z))
                    if dist < (Config.MarkerDrawDistance or 5000.0) then
                        sleep = 5
                        local markerColor = isFinish and Config.MarkerColors.finish or Config.MarkerColors[currentPhase]
                        DrawMarker(4, target.x, target.y, target.z - 1, 0, 0, 0, 0, 0, 0, 15.0, 0.1, 300.0, markerColor[1], markerColor[2], markerColor[3], markerColor[4], false, true, 2, false, false, false, false)

                        if dist < (Config.MarkerReachDistance or 7.0) then
                            if currentPhase ~= 'bike' or (currentVehicle and IsPedInVehicle(ped, currentVehicle, false)) then
                                passCheckpoint()
                            end
                        end
                    else
                        sleep = 150
                    end
                end

                PGT = gameTimerSeconds
                PCP = playerCheckpoint
                Wait(sleep)
            end
        end)

        RegisterCommand('exit', function()
            TriggerEvent('f17_bamonphoihop:cl:Restart')
            TriggerServerEvent('f17_bamonphoihop:sv:LogOutEvent')
        end)

        CreateThread(function()
            while dathamgia do
                if not dathamgia then break end
                Wait(100)

                if IsControlPressed(0, 246) and not pressed and Config.AllowRespawn then
                    pressed = true
                    local now = GetGameTimer()

                    if now - lastRespawnAt >= (Config.RespawnCooldown or 2000) then
                        lastRespawnAt = now
                        local previousCheckpoint = getPreviousCheckpoint()

                        if previousCheckpoint then
                            if currentPhase == 'bike' then
                                cleanupBike()
                                isInVehicle = false
                            end

                            SetEntityCoords(ped, previousCheckpoint.x, previousCheckpoint.y, previousCheckpoint.z + 0.5)

                            if currentPhase == 'bike' then
                                Wait(500)
                                spawnBikeForPlayer()
                            end
                        end
                    end

                    Wait(1000)
                    pressed = false
                end
            end
        end)

        CreateThread(function()
            while dathamgia do
                if not dathamgia then break end
                Wait(100)

                gameTimerTicks = gameTimerTicks + 1
                if gameTimerTicks == 10 then
                    gameTimerSeconds = gameTimerSeconds + 1
                    gameTimerTicks = 0
                end

                if playerCheckpoint == raceEndPoint + 1 then
                    playerCheckpoint = playerCheckpoint + 1
                    Wait(1100)
                    TriggerEvent('f17_bamonphoihop:cl:Restart', true)
                    break
                end
            end
        end)

        CreateThread(function()
            while dathamgia do
                if not dathamgia then break end
                Wait(5000)

                if Config.AutoReviveOnDeath and LocalPlayer.state.isDead then
                    Wait(1000)
                    local previousCheckpoint = getPreviousCheckpoint()
                    if previousCheckpoint then
                        SetEntityCoords(ped, previousCheckpoint.x, previousCheckpoint.y, previousCheckpoint.z)
                    end

                    Wait(500)
                    local playerCoords = GetEntityCoords(ped)
                    if IsEntityInWater(ped) then
                        if playerCoords.z <= 0 then
                            SetEntityCoords(ped, playerCoords.x, playerCoords.y, 5.0)
                        else
                            SetEntityCoords(ped, playerCoords.x, playerCoords.y, playerCoords.z + 5.0)
                        end
                    end

                    Wait(500)
                    Config.ReviveFunction()
                end
            end
        end)

        CreateThread(function()
            while dathamgia do
                if not dathamgia then break end
                Wait(1000)

                if currentPhase == 'bike' and currentVehicle and DoesEntityExist(currentVehicle) then
                    if IsPedSittingInAnyVehicle(ped) then
                        local playerVehicle = GetVehiclePedIsIn(ped, false)
                        if playerVehicle ~= currentVehicle then
                            ClearPedTasksImmediately(ped)
                            notify(Config.Lang.wrongVehicle or 'Day khong phai xe cua ban!', 'error')
                        end
                    end

                    local playerVehicle = GetVehiclePedIsIn(ped, false)
                    if playerVehicle == currentVehicle and Config.Vehicle.autoRepair then
                        SetVehicleBodyHealth(playerVehicle, 1000.0)
                        SetVehicleEngineHealth(playerVehicle, 1000.0)
                    end
                elseif bikePhaseCompleted and currentVehicle and DoesEntityExist(currentVehicle) then
                    if IsPedInVehicle(ped, currentVehicle, false) then
                        TaskLeaveVehicle(ped, currentVehicle, 16)
                        notify('Ban khong the su dung xe dap nua! Hay chay bo den dich.', 'error')
                    end
                end
            end
        end)
    end
end)

RegisterNetEvent('f17_bamonphoihop:sv:TimeEnding', function()
    if dathamgia then
        isRestarting = true
        isRaceEnding = true
        local timeBeforeEnd = Config.TimeBeforeEnd or 100

        CreateThread(function()
            while isRaceEnding do
                Wait(1000)

                if timeBeforeEnd > 0 then
                    timeBeforeEnd = timeBeforeEnd - 1
                    updateRaceUi(3, timeBeforeEnd)

                    if timeBeforeEnd == 0 then
                        TriggerServerEvent('f17_bamonphoihop:sv:LoseEvent')
                        TriggerEvent('f17_bamonphoihop:cl:Restart')
                        isRaceEnding = false
                    end
                end
            end
        end)
    end
end)

RegisterNetEvent('f17_bamonphoihop:cl:Restart', function(silent)
    finishLocal()

    if dathamgia and not silent then
        notify('[Minigame] Ban da roi khoi event.', 'error')
    end

    playerCheckpoint = 0
    dathamgia = false
    isRaceStopped = false
    isInVehicle = false
    Joined = false
    isRaceEnding = false
    isWaypointSet = false
    isRestarting = false
    pressed = false
    currentPhase = 'swim'
    currentIndex = 1
    bikePhaseCompleted = false
end)

RegisterNetEvent(Config.StartEventName, function()
    TriggerServerEvent('f17_bamonphoihop:sv:StartSolo')
end)

RegisterNetEvent('f17_triathlon:client:startRace', function(slot)
    TriggerEvent('f17_bamonphoihop:cl:StartGameBaMonPhoiHop', slot)
end)

RegisterNetEvent('f17_triathlon:client:notify', notify)
RegisterNetEvent('f17_triathlon:client:forceCancel', function()
    TriggerEvent('f17_bamonphoihop:cl:Restart')
    TriggerServerEvent('f17_bamonphoihop:sv:LoseEvent')
end)

RegisterCommand(Config.Command or 'triathlon', function()
    TriggerServerEvent('f17_bamonphoihop:sv:StartSolo')
end, false)

RegisterCommand('triathlon_cancel', function()
    TriggerEvent('f17_bamonphoihop:cl:Restart')
    TriggerServerEvent('f17_bamonphoihop:sv:LogOutEvent')
end, false)

CreateThread(function()
    getFrameworks()
end)

CreateThread(function()
    while true do
        Wait(1200)
        if isStuntActive then
            local particleDictionary = 'scr_rcbarry2'
            local particleName = 'scr_clown_appears'

            RequestNamedPtfxAsset(particleDictionary)
            while not HasNamedPtfxAssetLoaded(particleDictionary) do
                Wait(0)
            end

            SetPtfxAssetNextCall(particleDictionary)
            StartNetworkedParticleFxNonLoopedOnPedBone(particleName, PlayerPedId(), 0.15, -0.0000, 0.0000, 0.0, 180.0, 0.0, 18905, 1.0, false, false, false)
            SetPtfxAssetNextCall(particleDictionary)
            StartNetworkedParticleFxNonLoopedOnPedBone(particleName, PlayerPedId(), 0.15, -0.0000, 0.0000, 0.0, 180.0, 0.0, 57005, 1.0, false, false, false)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    finishLocal()
end)
