fx_version 'cerulean'
game 'gta5'

name "mycroft_keys"
description "A key Management System"
author "Mycroft"
lua54 'yes'
version "0.0.1"

shared_scripts {
	'shared/*.lua',
	'@es_extended/imports.lua',
	'@ox_lib/init.lua'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}
