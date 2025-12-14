fx_version 'cerulean'
game 'gta5'
description "QuickiePharm job script, based on GTA:O by ᏕᎷ ᎷᏋᏕᏖ3Ꮢ. You can find my public scripts here: https://mest3rdevelopment.com "
author "smmest3r"
version "1.0"
lua54 'yes'

shared_script 'config.lua'

client_scripts {
    'client/functions.lua',
    'client/main.lua'
}

server_scripts {
    'server/functions.lua',
    'server/main.lua'
}