fx_version 'cerulean'
game 'gta5'

description 'QB-Gabz-Locks'
version '1.0.0'

shared_scripts {
	'@qb-core/import.lua',
	'config.lua',
	'gabz-doorlocks/*.lua',
}

server_script 'server/main.lua'
client_script 'client/main.lua'
