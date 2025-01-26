fx_version 'cerulean'
games { 'gta5' }

author 'Danboi - Edited By Chimera Development'
description 'Staff Clockin/Clockout'
version '1.0.0'
lua54 'yes'

dependency 'ox_lib'

shared_script 'config.lua'

client_scripts {
  "@ox_lib/init.lua",
  "client.lua",
  "functions.lua"
}

server_scripts {
  "@ox_lib/init.lua",
  "server.lua",
  "functions.lua"
}
