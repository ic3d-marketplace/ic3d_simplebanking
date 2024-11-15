fx_version 'cerulean'
game 'gta5'

Author 'IC3D'

lua54 'yes'

shared_script {'@ox_lib/init.lua'}

shared_script {'@es_extended/imports.lua'} -- Comment this if you are using QB

client_scripts {
  'config.lua',
  'client.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'config.lua',
  'server.lua'
}

escrow_ignore {
	"config.lua"
}