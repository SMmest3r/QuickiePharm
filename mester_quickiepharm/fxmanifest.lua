shared_script '@mester_skillsystem/ai_module_fg-obfuscated.lua'
shared_script '@mester_skillsystem/shared_fg-obfuscated.lua'
fx_version 'cerulean'
game 'gta5'
description "QuickiePharm job script, based on GTA:O by ᏕᎷ ᎷᏋᏕᏖ3Ꮢ. You can find my public scripts here: https://mest3rdevelopment.com "
author "smmest3r"
version "1.0"
lua54 'yes'
use_experimental_fxv2_oal "yes"

shared_scripts {
    'shared/config.lua',
    'shared/functions.lua',
    'locales/*.lua'
}

client_scripts {
    'client/functions.lua',
    'client/main.lua'
}

server_scripts {
    'server/functions.lua',
    'server/main.lua'
}