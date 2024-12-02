fx_version 'cerulean'
game 'gta5'

author 'talmidiel'
description 'A custom driving license addon made for cali-rp'
version '0.0.1'

client_scripts {
    'client/main.lua',
    'config.lua'
}

server_scripts {
    'server/main.lua',
    'config.lua'
}

dependencies {
    'es_extended',
    'esx_license'
}