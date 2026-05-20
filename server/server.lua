r = GetCurrentResourceName()
n = 0
totalplayer = 0
local labelMODS = ''
local nguoidangchoi = {}
local tablessavetop = {}

RegisterServerEvent('f17_bamonphoihop:sv:setRoutingBucket', function(dimension)
    if Config.UseRoutingBucket == false then return end

    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    if not xPlayer then return end

    local veh = GetVehiclePedIsIn(GetPlayerPed(src), false)

    if veh ~= 0 then
        SetEntityRoutingBucket(veh, dimension)
        SetPlayerRoutingBucket(src, dimension)
        TaskWarpPedIntoVehicle(GetPlayerPed(src), veh, -1)
    else
        SetPlayerRoutingBucket(src, dimension)
    end
end)

RegisterServerEvent('f17_bamonphoihop:sv:Isjoining', function()
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    if not xPlayer then return end

    local cid = xPlayer.PlayerData.citizenid
    local charinfo = xPlayer.PlayerData.charinfo or {}
    local nameplayer = ((charinfo.firstname or '') .. ' ' .. (charinfo.lastname or '')):gsub('^%s+', ''):gsub('%s+$', '')
    if nameplayer == '' then
        nameplayer = GetPlayerName(src) or ('ID ' .. src)
    end

    if not nguoidangchoi[tonumber(src)] then
        nguoidangchoi[tonumber(src)] = {
            cid = cid,
            namePlayer = nameplayer
        }
    end

    TriggerClientEvent('f17_bamonphoihop:cl:SetPlayerJoined', src)
end)

RegisterServerEvent('f17_bamonphoihop:sv:LogOutEvent', function()
    local src = source
    local playerKey = tonumber(src)
    if not nguoidangchoi[playerKey] then return end

    if GetResourceState('f17_daotrentroi') == 'started' then
        exports['f17_daotrentroi']:HinhPhatMinigame(src, '[BAMONPHOIHOP]', 'thoat')
    end

    nguoidangchoi[playerKey] = nil
end)

RegisterServerEvent('f17_bamonphoihop:sv:LoseEvent', function()
    local src = source
    local playerKey = tonumber(src)

    if nguoidangchoi[playerKey] then
        if GetResourceState('f17_daotrentroi') == 'started' then
            exports['f17_daotrentroi']:HinhPhatMinigame(src, '[BAMONPHOIHOP]', 'thoat')
        end
        nguoidangchoi[playerKey] = nil
    end
end)

local function addxpnhanvat(src, cid, xp)
    if GetResourceState('f17_level') == 'started' then
        exports['f17_level']:AddXP(src, xp)
    end
end

local function phanthuongtop(src, top)
    local xPlayer = QBCore.Functions.GetPlayer(src)
    if not xPlayer then return end

    local stt = math.min(math.max(tonumber(top), 1), 5)
    local reward = Config.Rewards and Config.Rewards[stt]
    if not reward then return end

    if reward.money and reward.money > 0 then
        xPlayer.Functions.AddMoney(reward.moneyType or 'tienkhoa', reward.money, 'Event: Ba Mon Phoi Hop Top ' .. stt)
    end

    if reward.items and GetResourceState('ox_inventory') == 'started' then
        for _, item in ipairs(reward.items) do
            if item.name and item.amount and item.amount > 0 then
                exports.ox_inventory:AddItem(src, item.name, item.amount)
            end
        end
    end

    if reward.xp and reward.xp > 0 then
        addxpnhanvat(src, xPlayer.PlayerData.citizenid, reward.xp)
    end

    if stt <= 5 then
        TriggerClientEvent('QBCore:Notify', src, string.format('[Ba mon phoi hop]: ~y~HANG %d~s~\nBan da nhan phan thuong tuong ung va cong: %d diem xep hang!', stt, reward.points or 0), 'success', 30000)
    end
end

RegisterServerEvent('f17_bamonphoihop:sv:GotWinner', function()
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    if not xPlayer then return end

    if n == 0 then
        TriggerClientEvent('f17_bamonphoihop:sv:TimeEnding', -1)
        SendWebhook()
    end

    n = n + 1

    local discord = QBCore.Functions.GetIdentifier(src, 'discord') or 'undefined'
    tablessavetop[#tablessavetop + 1] = {
        id = discord:gsub('discord:', ''),
        top = n
    }

    if n < 5 then
        local reward = Config.Rewards and Config.Rewards[n]
        if reward and GetResourceState('f17_daotrentroi') == 'started' then
            exports['f17_daotrentroi']:AddPointsMinigame(src, '[BAMONPHOIHOP]', reward.points or 0, n)
        end
    else
        if GetResourceState('f17_daotrentroi') == 'started' then
            exports['f17_daotrentroi']:HinhPhatMinigame(src, '[BAMONPHOIHOP]', 'top', n)
        end
    end

    nguoidangchoi[tonumber(src)] = nil
    phanthuongtop(src, n)
end)

local webhook_linhtinh = ''

function sortByKey(key)
    return function(a, b)
        return tonumber(a[key]) < tonumber(b[key])
    end
end

function sendToDiscord(message, loai)
    if webhook_linhtinh == '' then return end

    local time = os.date('*t')
    local embed = {
        {
            color = 65352,
            author = {
                icon_url = 'https://cdn.discordapp.com/attachments/1168917436523876453/1168917462457270312/discord-logo-gta.png',
                name = 'F17 CITY',
            },
            title = '** ' .. loai .. '**',
            description = message .. '\n**So luong nguoi tham gia:** ' .. totalplayer .. '\nNhung nguoi ve dich va nhan duoc qua la nhung nguoi co trong TOP',
            footer = {
                text = time.year .. '/' .. time.month .. '/' .. time.day .. ' ' .. time.hour .. ':' .. time.min,
            },
        }
    }

    PerformHttpRequest(webhook_linhtinh, function() end, 'POST', json.encode({ username = name, embeds = embed }), { ['Content-Type'] = 'application/json' })
end

local function sendtowebhook()
    local shortMsg = ''
    table.sort(tablessavetop, sortByKey('top'))

    for k in pairs(tablessavetop) do
        if string.len(shortMsg) < 2000 then
            shortMsg = shortMsg .. '`TOP: ' .. k .. '. |` Nguoi choi <@' .. tablessavetop[k].id .. '>\n'
        else
            sendToDiscord(shortMsg, 'BXH EVENT: ' .. labelMODS)
            shortMsg = ''
            Wait(2000)
        end
    end

    sendToDiscord(shortMsg, 'BXH EVENT: ' .. labelMODS)
end

function SendWebhook()
    SetTimeout((Config.TimeBeforeEnd or 100) * 1000 + 50000, function()
        nguoidangchoi = {}
        sendtowebhook()
    end)
end

local function startPlayers(data, labelMiniGame)
    n = 0
    totalplayer = 0
    nguoidangchoi = {}
    labelMODS = labelMiniGame or 'Ba mon phoi hop'
    tablessavetop = {}

    for k in pairs(data or {}) do
        local Players = QBCore.Functions.GetPlayerByCitizenId(k)
        if Players then
            local src = Players.PlayerData.source
            totalplayer = totalplayer + 1
            TriggerClientEvent('QBCore:Notify', src, 'BA MON PHOI HOP sap bat dau', 'primary', 5000)
            TriggerClientEvent('f17_bamonphoihop:cl:StartGameBaMonPhoiHop', src, totalplayer)
        end
    end
end

RegisterServerEvent('f17_bamonphoihop:sv:StartSolo', function()
    local src = source
    n = 0
    totalplayer = 1
    nguoidangchoi = {}
    labelMODS = 'Ba mon phoi hop'
    tablessavetop = {}

    TriggerClientEvent('QBCore:Notify', src, 'BA MON PHOI HOP sap bat dau', 'primary', 5000)
    TriggerClientEvent('f17_bamonphoihop:cl:StartGameBaMonPhoiHop', src, 1)
end)

function StartMiniGame(dataOrMode, labelOrData, maybeLabel)
    if maybeLabel ~= nil then
        startPlayers(labelOrData, maybeLabel)
        return
    end

    startPlayers(dataOrMode, labelOrData)
end

exports('StartMiniGame', StartMiniGame)

AddEventHandler('playerDropped', function()
    local src = source
    local playerKey = tonumber(src)
    if not nguoidangchoi[playerKey] then return end

    if GetResourceState('f17_daotrentroi') == 'started' then
        exports['f17_daotrentroi']:HinhPhatMinigame(src, '[BAMONPHOIHOP]', 'thoat')
    end

    nguoidangchoi[playerKey] = nil
end)
