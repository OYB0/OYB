# 🌌 Universal Multi-Game Script Loader

Welcome to the **OYB Universal Multi-Game Script Loader**! Are you tired of sharing a different script link for every single Roblox game?

With this smart loader, you can combine all your map-specific scripts into **ONE single script**. It automatically detects which game the player has joined and executes the correct code instantly.

## 🔗 Script Location

You can find the main script located right here in this folder, or you can access it directly via this link:
👉 [**View TheScript.lua Here**](https://github.com/OYB0/OYB/blob/main/Roblox/Executor/Multi-GameScriptLoader/TheScript.lua)

## 🎥 Video Tutorial (Must Watch)

See exactly how this works and how to set it up perfectly by watching the full tutorial on my YouTube channel:
👉 [**Watch the Tutorial Here: ONE Script for EVERY Game!**](https://youtu.be/klf9EnL23So)

## ✨ Features

* 🧠 **Smart Auto-Detection:** Automatically identifies the current Roblox game using `PlaceId`.

* 🎨 **Custom Smooth UI Notifications:** Replaces the default, limited Roblox notifications with a clean, animated custom UI using `TweenService`. Notifications stack neatly and never disappear until closed.

* 🔗 **All-in-One Link:** Organize your scripting projects easily and provide your users with just one script to run anywhere.

* ⚙️ **Easily Customizable:** Change the `HubName` variable to rebrand the loader to your own script hub.

## 🚀 How to Use

1. Open the `TheScript.lua` file.

2. Edit the `SupportedGames` table with your games' `PlaceId` and the corresponding script URLs.

```lua
local SupportedGames = {
    [119579217517090] = "https://raw.githubusercontent.com/...", -- Game 1
    [131623223084840] = "https://raw.githubusercontent.com/...", -- Game 2
}
```

## 📜 Copyright & Terms of Use

Created by **OYB**.

* ✅ **Allowed:** Using this script to organize your own scripts and modifying it to fit your needs.

* ❌ **Prohibited:** Re-uploading this script as your own or claiming ownership of the source code.

*If you found this useful, please star ⭐ this repository and subscribe to the YouTube channel!*
