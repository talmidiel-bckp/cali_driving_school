fx_version 'cerulean'
game 'gta5'

author 'talmidiel'
description 'A custom driving license addon made for cali-rp'
version '0.0.1'

shared_script '@es_extended/imports.lua'

client_scripts {
    'config.lua',
    'client/main.lua'
}

server_scripts {
    'config.lua',
    'server/main.lua'
}

dependencies {
    'es_extended',
    'esx_license'
}
