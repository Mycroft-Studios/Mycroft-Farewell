fx_version 'cerulean'
game 'gta5' 

author 'Mycroft'
lua54 ' yes'
description 'ID system'
version '1.0.0'


shared_scripts {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua'
}

client_scripts {
	'client/main.lua'
}

server_scripts {
	'server/main.lua'
}