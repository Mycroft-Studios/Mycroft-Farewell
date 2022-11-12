fx_version 'cerulean'
game 'gta5'

author 'Sub-Zero Interactive'
description ''
version '0.0'

lua54 'yes'
shared_script '@es_extended/imports.lua'

server_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    'config.lua',
    'server/server.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    'config.lua',
    'client/client.lua'
}
