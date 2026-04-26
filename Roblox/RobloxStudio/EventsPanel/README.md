# 🛡️ OYB Admin & Global Events System

Thank you for checking out the OYB Events System! This system provides a secure, cross-server admin panel and global events for your Roblox games.

## 🔗 Resources

* 📦 **Get the Model:** [OYB Events Panel on Roblox](https://create.roblox.com/store/asset/89740483068098/OYB-Events-Panel)
* 🎥 **Video Tutorial:** [Watch the Setup Guide on YouTube](https://youtu.be/Zx0taEAkBBM) *(Highly recommended to avoid errors)*

## 🛠️ Quick Installation Guide

To make the system work perfectly, unpack the downloaded model and place each item in its designated location within the **Explorer**:

1.  **ReplicatedStorage:** Place `OYB_AdminEvent` and `OYB_ClientEvent` (RemoteEvents).
2.  **ServerScriptService:** Place the `OYB_Brain` script.
    * *⚠️ Important:* Open this script and change `ROOT_OWNER_ID` to your own Roblox UserID!
3.  **ServerStorage:** Place the `OYB_Panel` (ScreenGui).
    * *Note:* The system clones this to admins only when they join to keep it secure from exploiters.
4.  **StarterPlayer > StarterPlayerScripts:** Place the `OYB_PlayerClient` (LocalScript).

## ⚙️ Security Requirements

For the Admin List to save your progress correctly using DataStores, you must enable these settings:
1. Open **Game Settings** in Roblox Studio.
2. Go to the **Security** tab.
3. Enable **"Allow HTTP Requests"** and **"Enable Studio Access to API Services"**.

## 📜 Copyright & Terms of Use

Created by **OYB**.

* ✅ **Allowed:** Using this script in your own games and modifying it for personal use.
* ❌ **Prohibited:** Publishing, distributing, or re-uploading this script/model (even if modified) to the Roblox Library or any other platform.
