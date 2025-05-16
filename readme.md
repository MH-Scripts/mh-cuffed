<p align="center">
    <img width="140" src="https://icons.iconarchive.com/icons/iconarchive/red-orb-alphabet/128/Letter-M-icon.png" />  
    <h1 align="center">Hi 👋, I'm MaDHouSe</h1>
    <h3 align="center">A passionate allround developer </h3>    
</p>

<p align="center">
    <a href="https://github.com/MH-Scripts/mh-walkwhencuffed/issues">
        <img src="https://img.shields.io/github/issues/MH-Scripts/mh-walkwhencuffed"/> 
    </a>
    <a href="https://github.com/MH-Scripts/mh-walkwhencuffed/watchers">
        <img src="https://img.shields.io/github/watchers/MH-Scripts/mh-walkwhencuffed"/> 
    </a> 
    <a href="https://github.com/MH-Scripts/mh-walkwhencuffed/network/members">
        <img src="https://img.shields.io/github/forks/MH-Scripts/mh-walkwhencuffed"/> 
    </a>  
    <a href="https://github.com/MH-Scripts/mh-walkwhencuffed/stargazers">
        <img src="https://img.shields.io/github/stars/MH-Scripts/mh-walkwhencuffed?color=white"/> 
    </a>
    <a href="https://github.com/MH-Scripts/mh-walkwhencuffed/blob/main/LICENSE">
        <img src="https://img.shields.io/github/license/MH-Scripts/mh-walkwhencuffed?color=black"/> 
    </a>      
</p>

# My Youtube Channel
- [Subscribe](https://www.youtube.com/@MaDHouSe79) 

# MH Walk When Cuffed (QB/ESX)
- When you get cuffed by a cop you don't walk or move, with this script you also walk with the cop while cuffed.
- so when the cop is walking you are also automaticly going to walk animation.
- you can arrest npc peds and searsh them.

# Add code in `qb-polivejob` (client side)
- in `qb-policejob/client/main.lua` at the bottom of the file.
```lua
local function GetIsHandcuffed() return isHandcuffed end
exports('GetIsHandcuffed', GetIsHandcuffed)
```

```lua
local function GetIsEscorted() return isEscorted end
exports('GetIsEscorted', GetIsEscorted)
```

# Replace code in `qb-policejob` (server side)
- in `qb-policejob/server/interactions.lua` around line 19
```lua
RegisterNetEvent('police:server:CuffPlayer', function(playerId, isSoftcuff)
    local src = source
    local playerPed = GetPlayerPed(src)
    local targetPed = GetPlayerPed(playerId)
    local playerCoords = GetEntityCoords(playerPed)
    local targetCoords = GetEntityCoords(targetPed)
    if #(playerCoords - targetCoords) > 2.5 then return DropPlayer(src, 'Attempted exploit abuse') end

    local Player = QBCore.Functions.GetPlayer(src)
    local CuffedPlayer = QBCore.Functions.GetPlayer(playerId)
    if not Player or not CuffedPlayer or (not Player.Functions.GetItemByName('handcuffs') and Player.PlayerData.job.type ~= 'leo') then return end
    TriggerClientEvent('police:client:GetCuffed', CuffedPlayer.PlayerData.source, Player.PlayerData.source, isSoftcuff)
    
    -- Add here
    if GetResourceState("mh-walkwhencuffed") ~= 'missing' then
        exports['mh-walkwhencuffed']:SetData({cop = Player.PlayerData.source, suspect = CuffedPlayer.PlayerData.source})
    end
end)
```

# LICENSE
[GPL LICENSE](./LICENSE)<br />
&copy; [MaDHouSe79](https://www.youtube.com/@MaDHouSe79)