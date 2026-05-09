local activePlayers = {}
local bestTimes = {}

RegisterNetEvent('f17_triathlon:server:start', function()
    local src = source
    activePlayers[src] = os.time()
end)

RegisterNetEvent('f17_triathlon:server:finish', function(elapsed, cancelled)
    local src = source
    if not activePlayers[src] then return end

    activePlayers[src] = nil
    if cancelled then return end

    elapsed = tonumber(elapsed)
    if not elapsed or elapsed <= 0 then return end

    local name = GetPlayerName(src) or ('ID %s'):format(src)
    if not bestTimes[src] or elapsed < bestTimes[src].elapsed then
        bestTimes[src] = {
            name = name,
            elapsed = elapsed,
            at = os.time()
        }
    end

    TriggerClientEvent('chat:addMessage', -1, {
        color = { 255, 190, 45 },
        multiline = true,
        args = { 'F17 Triathlon', ('%s da hoan thanh voi thoi gian %s.'):format(name, formatMilliseconds(elapsed)) }
    })
end)

AddEventHandler('playerDropped', function()
    activePlayers[source] = nil
end)

function formatMilliseconds(ms)
    local total = math.max(0, math.floor(ms / 1000))
    local minutes = math.floor(total / 60)
    local seconds = total % 60
    return string.format('%02d:%02d', minutes, seconds)
end
