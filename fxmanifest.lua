fx_version 'cerulean'
games { 'gta5' }

author 'Chimera Development'
description 'Staff Clockin/Clockout'
version '1.5.0'
lua54 'yes'

dependency 'ox_lib'

shared_scripts {
  "@ox_lib/init.lua",
  "functions.lua"
}

client_scripts {
	'client.lua'
}

server_scripts {
  'config.lua',
	'server.lua'
}
