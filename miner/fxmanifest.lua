fx_version 'adamant'

game 'gta5'

description 'ProjectStarboy ft ESX: MinerJob'

version '1.0'
legacyversion '1.9.1'

lua54 'yes'

shared_script '@ProjectStarboy/imports.lua'

server_scripts {
    '@ProjectStarboy/locale.lua',
	'config.lua',
	'server/main.lua',
    'locales/*.lua',
}


client_scripts {
    '@ProjectStarboy/locale.lua',
	'config.lua',
	'client/main.lua',
    'locales/*.lua',
}
