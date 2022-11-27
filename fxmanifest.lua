fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

author 'RexShack#3041'
description 'rsg-moonshiner'

client_script {
	'client/client.lua',
	'client/npc.lua',
}

server_script {
	'server/server.lua',
	'@oxmysql/lib/MySQL.lua',
}

shared_scripts {
	'config.lua'
}

dependency 'qr-core'
dependency 'qr-menu'
dependency 'qr-input'
dependency 'map-moonshineshacks'

lua54 'yes'