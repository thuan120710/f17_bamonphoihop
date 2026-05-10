fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'F17 Team'
description 'F17 3-mon-phoi-hop triathlon minigame - Enhanced with racing features'
version '2.0.0'

shared_scripts {
    'config/config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}

-- Export để start từ bên ngoài
server_exports {
    'StartMiniGame'
}

dependencies {
    'qb-core'
}

-- Optional dependencies
optional_dependencies {
    'ox_inventory',
    'f17_level',
    'f17_daotrentroi'
}
