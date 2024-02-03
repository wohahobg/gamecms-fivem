fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'GameCMS.ORG [Wohaho]'
description 'Script that connect GameCMS.ORG with FiveM Server.'
version '1.0.0'

shared_script 'config.lua'
server_scripts {
    'server/gamecms_main.lua',
    'server/gamecms_http.lua',
    'server/gamecms_commands.lua'
}

server_only 'yes'