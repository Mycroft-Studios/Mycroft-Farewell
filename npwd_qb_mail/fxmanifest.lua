fx_version "cerulean"
game "gta5"

client_script 'client/client.lua'

server_script {
    'server/server.lua',
    '@oxmysql/lib/MySQL.lua',
}

shared_script '@es_extended/imports.lua'

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/*.js',
}
