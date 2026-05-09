local waitingPlayers = {}
local activePlayers = {}
local bestTimes = {}
local raceState = 'idle'
local currentRaceId = 0
local finishOrder = 0

local function getPlayerKey(src)
    for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
        if identifier:find('license:', 1, true) then
            return identifier
        end
    end

    return ('source:%s'):format(src)
end

local function getName(src)
    return GetPlayerName(src) or ('ID %s'):format(src)
end

local function countTable(list)
    local count = 0
    for _ in pairs(list) do
        count = count + 1
    end
    return count
end

local function formatMilliseconds(ms)
    local total = math.max(0, math.floor(ms / 1000))
    local minutes = math.floor(total / 60)
    local seconds = total % 60
    return string.format('%02d:%02d', minutes, seconds)
end

local function notify(src, message)
    TriggerClientEvent('f17_triathlon:client:notify', src, message)
end

local function broadcast(message, color)
    TriggerClientEvent('chat:addMessage', -1, {
        color = color or { 255, 190, 45 },
        multiline = true,
        args = { 'F17 Triathlon', message }
    })
end

local function resetSharedRaceIfEmpty()
    if raceState == 'waiting' and countTable(waitingPlayers) == 0 then
        raceState = 'idle'
        return
    end

    if raceState == 'active' and countTable(activePlayers) == 0 then
        raceState = 'idle'
        finishOrder = 0
    end
end

local function getSortedLeaderboard()
    local leaderboard = {}
    for key, data in pairs(bestTimes) do
        leaderboard[#leaderboard + 1] = {
            key = key,
            name = data.name,
            elapsed = data.elapsed,
            at = data.at
        }
    end

    table.sort(leaderboard, function(a, b)
        if a.elapsed == b.elapsed then
            return a.at < b.at
        end

        return a.elapsed < b.elapsed
    end)

    return leaderboard
end

local function getLeaderboardRank(playerKey)
    local leaderboard = getSortedLeaderboard()
    for index, data in ipairs(leaderboard) do
        if data.key == playerKey then
            return index
        end
    end

    return nil
end

local function sendLeaderboard(target)
    local leaderboard = getSortedLeaderboard()
    local limit = Config.LeaderboardLimit or 10

    if #leaderboard == 0 then
        if target == 0 then
            print('[F17 Triathlon] Chua co thanh tich nao tren bang xep hang.')
            return
        end

        TriggerClientEvent('chat:addMessage', target, {
            color = { 255, 190, 45 },
            args = { 'F17 Triathlon', 'Chua co thanh tich nao tren bang xep hang.' }
        })
        return
    end

    if target == 0 then
        print(('[F17 Triathlon] Top %d best time:'):format(math.min(limit, #leaderboard)))
        for index = 1, math.min(limit, #leaderboard) do
            local data = leaderboard[index]
            print(('#%d %s - %s'):format(index, data.name, formatMilliseconds(data.elapsed)))
        end
        return
    end

    TriggerClientEvent('chat:addMessage', target, {
        color = { 255, 190, 45 },
        args = { 'F17 Triathlon', ('Top %d best time:'):format(math.min(limit, #leaderboard)) }
    })

    for index = 1, math.min(limit, #leaderboard) do
        local data = leaderboard[index]
        TriggerClientEvent('chat:addMessage', target, {
            color = { 255, 255, 255 },
            args = { ('#%d'):format(index), ('%s - %s'):format(data.name, formatMilliseconds(data.elapsed)) }
        })
    end
end

local function startSharedRace(raceId)
    if raceState ~= 'waiting' or raceId ~= currentRaceId then return end

    local joinedCount = countTable(waitingPlayers)
    if joinedCount == 0 then
        raceState = 'idle'
        return
    end

    raceState = 'active'
    finishOrder = 0

    local slot = 0
    for src, data in pairs(waitingPlayers) do
        slot = slot + 1
        activePlayers[src] = {
            raceId = raceId,
            startedAt = os.time(),
            key = data.key,
            name = data.name
        }
        TriggerClientEvent('f17_triathlon:client:startRace', src, slot)
    end

    waitingPlayers = {}
    broadcast(('Race #%d bat dau voi %d nguoi thi dau. Chuc may man!'):format(raceId, joinedCount), { 80, 255, 145 })

    SetTimeout((Config.SharedRaceTimeoutMinutes or (Config.MaxGameplayMinutes + 5)) * 60000, function()
        if raceState ~= 'active' or raceId ~= currentRaceId then return end

        local remaining = countTable(activePlayers)
        if remaining == 0 then
            resetSharedRaceIfEmpty()
            return
        end

        local toCancel = {}
        for src, session in pairs(activePlayers) do
            if session.raceId == raceId then
                toCancel[#toCancel + 1] = src
            end
        end

        for _, src in ipairs(toCancel) do
            TriggerClientEvent('f17_triathlon:client:forceCancel', src)
            activePlayers[src] = nil
        end

        raceState = 'idle'
        finishOrder = 0
        broadcast(('Race #%d da het thoi gian va duoc dong lai.'):format(raceId), { 255, 90, 90 })
    end)
end

local function joinSharedRace(src)
    if activePlayers[src] then
        notify(src, 'Ban dang trong race roi.')
        return
    end

    if waitingPlayers[src] then
        notify(src, 'Ban da o trong lobby race roi.')
        return
    end

    if raceState == 'active' then
        notify(src, 'Race dang dien ra. Hay doi luot tiep theo.')
        return
    end

    if raceState == 'idle' then
        currentRaceId = currentRaceId + 1
        raceState = 'waiting'
        finishOrder = 0
        local raceId = currentRaceId
        broadcast(('Race #%d da mo lobby. Go /%s de tham gia trong %d giay.'):format(currentRaceId, Config.Command, Config.SharedRaceJoinSeconds or 30), { 80, 255, 145 })

        SetTimeout((Config.SharedRaceJoinSeconds or 30) * 1000, function()
            startSharedRace(raceId)
        end)
    end

    waitingPlayers[src] = {
        key = getPlayerKey(src),
        name = getName(src)
    }

    broadcast(('%s da tham gia lobby race #%d. Hien co %d nguoi.'):format(waitingPlayers[src].name, currentRaceId, countTable(waitingPlayers)), { 255, 190, 45 })
end

RegisterNetEvent('f17_triathlon:server:joinRace', function()
    joinSharedRace(source)
end)

RegisterNetEvent('f17_triathlon:server:start', function()
    joinSharedRace(source)
end)

RegisterNetEvent('f17_triathlon:server:finish', function(elapsed, cancelled)
    local src = source
    local session = activePlayers[src]
    if not session then return end

    activePlayers[src] = nil

    if cancelled then
        broadcast(('%s da roi khoi race. Con %d nguoi dang thi dau.'):format(session.name, countTable(activePlayers)), { 255, 90, 90 })
        resetSharedRaceIfEmpty()
        return
    end

    elapsed = tonumber(elapsed)
    if not elapsed or elapsed <= 0 then
        resetSharedRaceIfEmpty()
        return
    end

    finishOrder = finishOrder + 1

    local playerKey = session.key or getPlayerKey(src)
    local name = getName(src)
    local isPersonalBest = not bestTimes[playerKey] or elapsed < bestTimes[playerKey].elapsed

    if isPersonalBest then
        bestTimes[playerKey] = {
            name = name,
            elapsed = elapsed,
            at = os.time()
        }
    end

    local bestRank = getLeaderboardRank(playerKey)
    local topText = bestRank and (' | BXH #%d'):format(bestRank) or ''
    local bestText = isPersonalBest and ' | PB moi' or ''

    broadcast(('%s ve dich #%d trong race #%d: %s%s%s. Con %d nguoi dang thi dau.'):format(
        name,
        finishOrder,
        session.raceId,
        formatMilliseconds(elapsed),
        topText,
        bestText,
        countTable(activePlayers)
    ), { 255, 190, 45 })

    resetSharedRaceIfEmpty()
end)

RegisterCommand(Config.TopCommand or 'triathlontop', function(src)
    sendLeaderboard(src)
end, false)

AddEventHandler('playerDropped', function()
    waitingPlayers[source] = nil
    activePlayers[source] = nil
    resetSharedRaceIfEmpty()
end)
