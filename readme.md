# QuickiePharm - FiveM Job Script

An optimized, production-ready QuickiePharm job script for FiveM servers. Faithfully recreates the GTA:O QuickiePharm job experience with full configurability for both vanilla and RP servers.

## ✨ Features

- **Authentic GTA:O Experience** - Replicates the QuickiePharm job from GTA Online
- **Server-Side State Management** - All job states and entities managed server-side for security and reliability
- **Highly Configurable** - Easily customize deliveries, payments, vehicles, and timers
- **RP-Friendly** - Optional extras designed specifically for roleplay servers
- **Multi-Language Support** - Built-in localization system (English & Hungarian included)
- **Cleanup on Disconnect** - Automatic resource cleanup when players leave or resource is stopped

## 🚀 Installation

1. Download or clone the repository to your resources folder
2. Add `ensure mester_quickiepharm` to your server.cfg
3. Configure `shared/config.lua` to match your server's needs
4. Configure `server/functions.lua` GiveMoney() function to match it with your server's framework
5. Restart your server or use `refresh` and `ensure mester_quickiepharm`

## 🔒 Security Features

- **Server-Side Validation** - All critical job data validated on server

## 🌍 Localization

Add new languages by creating new files in `locales/` folder:

```lua
-- locales/fr.lua (French example)
if Config.Language ~= "fr" then return end

Locales = {}

Locales.KeyMappingLabel = "QuickiePharm Touche Interact"
```

Then set `Config.Language = "fr"` in config.lua.

## 🐛 Support

For issues, questions, or suggestions, you can contact me trough my Discord server. [discord.mest3rdevelopment.com](https://discord.mest3rdevelopment.com)
