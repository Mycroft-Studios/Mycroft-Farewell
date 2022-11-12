fx_version 'cerulean'
game 'gta5'

version '1.0.0'

client_script 'client/client.lua'

shared_scripts  {
	'@es_extended/imports.lua',
    	'config.lua'
}

server_script 'server/server.lua'

ui_page 'ui/ui.html'

files {
	'ui/ui.html'
}
