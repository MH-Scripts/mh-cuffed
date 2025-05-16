--[[ ===================================================== ]] --
--[[           MH Walk When Cuffed by MaDHouSe79           ]] --
--[[ ===================================================== ]] --
local config = nil
local searchSuspects = {}
local searchVehicles = {}
local isHandCuffing = false
local isSearchingSuspect = false
local isSearchingVehicle = false
local isReviveNpc = false
local suspectEntity = nil -- current entity you are working with at the moment.

local function Notify(message, type, length)
    if GetResourceState("ox_lib") ~= 'missing' then
        lib.notify({title = "MH Walk When Cuffed", description = message, type = type})
    else
        print(message)
    end
end

local function LoadDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(1)
        end
    end
end

local function HasItem(item, amount)
    return exports['qb-inventory']:HasItem(config.RevieItem, 1)
end

local function GetDistance(pos1, pos2)
    if pos1 ~= nil and pos2 ~= nil then
        return #(vector3(pos1.x, pos1.y, pos1.z) - vector3(pos2.x, pos2.y, pos2.z))
    end
end

local function CuffEntity(entity)
    if isHandCuffing then return end
    isHandCuffing = true
    LoadDict("mp_arrest_paired")
    if IsEntityPlayingAnim(PlayerPedId(), 'amb@world_human_drinking@coffee@female@base', 'base', 3) then
        StopAnimTask(PlayerPedId(), 'amb@world_human_drinking@coffee@female@base', 'base', -8.0)
    end
    SetEntityAsMissionEntity(entity, true, true)
    TaskSetBlockingOfNonTemporaryEvents(entity, true)
    SetPedFleeAttributes(entity, 0, 0)
    SetPedCombatAttributes(entity, 17, 1)
    ClearPedTasks(entity)
    ClearPedTasksImmediately(entity)
    SetPedFleeAttributes(entity, 0, false)
    Wait(200)
    AttachEntityToEntity(entity, PlayerPedId(), 11816, 0.38, 0.4, 0.0, 0.0, 0.0, 0.0, false, false, true, true, 2, true)
    TaskPlayAnim(PlayerPedId(), 'mp_arrest_paired', 'cop_p2_back_right', 3.0, 3.0, -1, 48, 0, 0, 0, 0)
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'Cuff', 0.5)
    TaskPlayAnim(entity, 'mp_arrest_paired', 'crook_p2_back_right', 3.0, 3.0, -1, 32, 0, 0, 0, 0, true, true, true)
    Wait(3500)
    TaskPlayAnim(PlayerPedId(), 'mp_arrest_paired', 'exit', 3.0, 3.0, -1, 48, 0, 0, 0, 0)
    Wait(100)
    SetEnableHandcuffs(entity, true)
    SetPedCanPlayGestureAnims(entity, false)
    if not IsEntityPlayingAnim(entity, 'mp_arresting', 'idle', 3) then
        TaskPlayAnim(entity, 'mp_arresting', 'idle', 8.0, -8, -1, 16, 0.0, false, false, false)
        SetPedKeepTask(entity, true)
    end
    Suspect:new(entity)
    Suspect:setCuffed(entity, true)
    Suspect:setEscorting(entity, true)
    suspectEntity = entity
    isHandCuffing = false
end

local function UnCuffEntity(entity)
    LoadDict("mp_arresting")
    LoadDict('amb@world_human_drinking@coffee@female@base')
    SetEntityAsMissionEntity(entity, true, true)
    FreezeEntityPosition(PlayerPedId(), true)
    StopAnimTask(PlayerPedId(), 'amb@world_human_drinking@coffee@female@base', 'base', -8.0)
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'Uncuff', 0.5)
    StopAnimTask(entity, 'mp_arresting', 'walk', -8.0)
    StopAnimTask(entity, 'mp_arresting', 'idle', -8.0)
    DetachEntity(entity)
    FreezeEntityPosition(entity, false)
    FreezeEntityPosition(PlayerPedId(), false)
    SetEnableHandcuffs(entity, false)
    SetPedCanPlayGestureAnims(entity, true)
    Suspect:setCuffed(entity, false)
    Suspect:setEscorting(entity, false)
    Suspect:delete(entity)
    suspectEntity = nil
    if not IsEntityPlayingAnim(entity, 'mp_arresting', 'idle', 3) then
        TaskPlayAnim(entity, 'mp_arresting', 'idle', 8.0, -8, -1, 16, 0.0, false, false, false)
        SetPedKeepTask(entity, true)
    end
end

local function EscortEntity(entity)
    LoadDict("mp_arresting")
    LoadDict('amb@world_human_drinking@coffee@female@base')
    FreezeEntityPosition(entity, false)
    SetEntityAsMissionEntity(entity, true, true)
    if not Suspect:isEscorting(entity) then
        DetachEntity(entity)
        suspectEntity = nil
        StopAnimTask(PlayerPedId(), 'amb@world_human_drinking@coffee@female@base', 'base', -8.0)
        if Suspect:isCuffed(entity) then
            suspectEntity = entity
            Suspect:setEscorting(entity, false)
            StopAnimTask(PlayerPedId(), 'amb@world_human_drinking@coffee@female@base', 'base', -8.0)
            StopAnimTask(entity, 'mp_arresting', 'walk', -8.0)
            StopAnimTask(entity, 'mp_arresting', 'run', -8.0)
            if not IsEntityPlayingAnim(entity, 'mp_arresting', 'idle', 3) then
                TaskPlayAnim(entity, 'mp_arresting', 'idle', 8.0, -8, -1, 1, 0.0, false, false, false)
                SetPedKeepTask(entity, true)
            end
            FreezeEntityPosition(entity, true)
        else
            if not IsEntityAttachedToEntity(entity, PlayerPedId()) then
                AttachEntityToEntity(entity, PlayerPedId(), 11816, 0.38, 0.4, 0.0, 0.0, 0.0, 0.0, false, false, true, true, 2, true)
            end
        end
    end
end

local function SearchSuspect(entity)
    searchSuspects[entity] = true
    isSearchingSuspect = true
    LoadDict("random@shop_robbery")
    local searchitem = nil
    if math.random(1, 10) < 2 then searchitem = config.JailItems[math.random(1, #config.JailItems)] end
    TaskTurnPedToFaceCoord(PlayerPedId(), GetEntityCoords(entity), 5000)
    Wait(1000)
    StopAnimTask(PlayerPedId(), 'amb@world_human_drinking@coffee@female@base', 'base', -8.0)
    TaskPlayAnim(PlayerPedId(), 'random@shop_robbery', 'robbery_action_b', 3.0, 3.0, -1, 16, 0, false, false, false)
    Wait(3500)
    StopAnimTask(PlayerPedId(), 'random@shop_robbery', 'robbery_action_b', -8.0)
    if searchitem ~= nil then
        Notify(Lang:t('found_item', {item = searchitem}), "error", 5000)
    else
        Notify(Lang:t('found_noting'), "success", 5000)
    end
    isSearchingSuspect = false
end

local function ReviveNpc(entity)
    isReviveNpc = true
    LoadDict('mini@cpr@char_a@cpr_str')
    TaskPlayAnim(PlayerPedId(), 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest', 3.0, 3.0, -1, 33, 0, false, false, false)
    SetPedKeepTask(PlayerPedId(), true)
    Wait(5000)
    StopAnimTask(PlayerPedId(), 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest', -8.0)
    SetEntityHealth(entity, 200)
    CuffEntity(entity)
    isReviveNpc = false
end

local function SearchVehicle(entity)
    searchVehicles[entity] = true
    isSearchingVehicle = true
    LoadDict("random@shop_robbery")
    TaskPlayAnim(PlayerPedId(), 'random@shop_robbery', 'robbery_action_b', 3.0, 3.0, -1, 16, 0, false, false, false)
    Wait(3500)
    StopAnimTask(PlayerPedId(), 'random@shop_robbery', 'robbery_action_b', -8.0)
    isSearchingVehicle = false
end

local function PlaceEntityInVehicle(entity, vehicle)
    for i = 1, 7, 1 do
        if IsVehicleSeatFree(vehicle, i) then
            SetEntityAsMissionEntity(entity, true, true)
            SetEntityAsMissionEntity(vehicle, true, true)
            DetachEntity(entity, true, false)
            Suspect:setEscorting(entity, false)
            Suspect:setCuffed(entity, true)
            Suspect:setInVehicle(entity, vehicle)
            SetPedIntoVehicle(entity, vehicle, i)
            EscortEntity(entity)
            suspectEntity = nil
            break
        end
    end
end

local function TakeEntityOutVehicle(vehicle)
    for i = 0, 7, 1 do
        local seatFree = IsVehicleSeatFree(vehicle, i)
        local entity = GetPedInVehicleSeat(vehicle, i)
        if not seatFree and DoesEntityExist(entity) then
            SetEntityAsMissionEntity(entity, true, true)
            SetEntityAsMissionEntity(vehicle, true, true)
            TaskLeaveVehicle(entity, vehicle, 16)
            suspectEntity = entity
            Suspect:setEscorting(entity, true)
            Suspect:setCuffed(entity, true)
            CuffEntity(entity)
            EscortEntity(entity)
            Suspect:takeOutVehicle(entity, vehicle)
            break
        end
    end
end

local function SetNpcAsHostage(entity)
    LoadDict("anim@heists@fleeca_bank@hostages@intro")
    LoadDict("amb@world_human_drinking@coffee@female@base")
    Suspect:setEscorting(entity, false)
    DetachEntity(entity)
    if IsEntityPlayingAnim(PlayerPedId(), 'amb@world_human_drinking@coffee@female@base', 'base', 3) then
        StopAnimTask(PlayerPedId(), 'amb@world_human_drinking@coffee@female@base', 'base', -8.0)
    end
    LoadDict("anim@heists@fleeca_bank@hostages@intro")
    FreezeEntityPosition(entity, true)
    if not IsEntityPlayingAnim(PlayerPedId(), 'anim@heists@fleeca_bank@hostages@intro', 'intro_standing_ped_d', 3) then
        TaskPlayAnim(entity, 'anim@heists@fleeca_bank@hostages@intro', 'intro_standing_ped_d', 8.0, -8.0, -1, 1, 0, false, false, false)
    end
    SetPedKeepTask(entity, true)
    suspectEntity = nil
end

local function RemoveNpcAsHostage(entity)
    StopAnimTask(entity, 'anim@heists@fleeca_bank@hostages@intro', 'intro_standing_ped_d', -8.0)
    TaskPlayAnim(entity, 'mp_arresting', 'idle', 8.0, -8, -1, 1, 0.0, false, false, false)
    SetPedKeepTask(entity, true)
    CuffEntity(entity)
    FreezeEntityPosition(entity, false)
    suspectEntity = entity
end

local function LoadTarget()
    for k, v in pairs(config.Vehicles) do
        if GetResourceState("qb-target") ~= 'missing' then
            exports['qb-target']:AddTargetModel(v.model, {
                options = {
                    {
                        type = "client",
                        icon = "fas fa-car",
                        label = Lang:t('set_in_vehicle'),
                        action = function(entity)
                            PlaceEntityInVehicle(suspectEntity, entity)
                        end,
                        canInteract = function(entity)
                            return true
                        end,
                    }, {
                        type = "client",
                        icon = "fas fa-car",
                        label = Lang:t('get_out_vehicle'),
                        action = function(entity)
                            TakeEntityOutVehicle(entity)
                        end,
                        canInteract = function(entity, distance, data)
                            return true
                        end
                    },{ -- Search Vehicle
                        icon = "fas fa-handcuffs",
                        label = Lang:t('search_vehicle'),
                        action = function(entity)
                            SearchVehicle(entity)
                        end,
                        canInteract = function(entity)
                            if PlayerData.job.name ~= 'police' then return false end
                            if searchVehicles[entity] then return false end
                            return true
                        end,
                    },
                },
                distance = 3.0
            })
        elseif GetResourceState("ox_target") ~= 'missing' then
            exports.ox_target:addModel(v.model, {
                {
                    icon = "fas fa-car",
                    label = Lang:t('get_out_vehicle'),
                    onSelect = function(data)
                        PlaceEntityInVehicle(suspectEntity, data.entity)
                    end,
                    canInteract = function(data)
                        return true
                    end,
                    distance = 3.0
                }, {
                    icon = "fas fa-car",
                    label = Lang:t('get_out_vehicle'),
                    onSelect = function(data)
                        TakeEntityOutVehicle(data.entity)
                    end,
                    canInteract = function(data)
                        return true
                    end,
                    distance = 2.5
                }, {
                    icon = "fas fa-car",
                    label = Lang:t('search_vehicle'),
                    onSelect = function(data)
                        SearchVehicle(data.entity)
                    end,
                    canInteract = function(data)
                        if PlayerData.job.name ~= 'police' then return false end
                        if searchVehicles[data.entity] then return false end
                        return true
                    end,
                    distance = 2.5
                },
            })
        end
    end

    for k, v in pairs(config.Peds) do
        if GetResourceState("qb-target") ~= 'missing' then
            exports['qb-target']:AddTargetModel(v[2], {
                options = {
                    { -- Cuff
                        type = "client",
                        icon = "fas fa-handcuffs",
                        label = Lang:t('cuff'),
                        action = function(entity)
                            CuffEntity(entity)
                        end,
                        canInteract = function(entity, distance, data)
                            if not isLoggedIn then return false end
                            if not IsPedHuman(entity) then return false end
                            if IsPedAPlayer(entity) then return false end
                            if IsPedDeadOrDying(entity) then return false end
                            if Suspect:isCuffed(entity) then return false end
                            if Suspect:isHostage(entity) then return false end
                            if not HasItem(config.HandcuffItem, 1) then return false end
                            if isHandCuffing then return false end
                            if isReviveNpc then return false end
                            return true
                        end
                    }, { -- UnCuff
                        type = "client",
                        icon = "fas fa-handcuffs",
                        label = Lang:t('uncuff'),
                        action = function(entity)
                            UnCuffEntity(entity)
                        end,
                        canInteract = function(entity, distance, data)
                            if not isLoggedIn then return false end
                            if not IsPedHuman(entity) then return false end
                            if IsPedAPlayer(entity) then return false end
                            if IsPedDeadOrDying(entity) then return false end
                            if not Suspect:isCuffed(entity) then return false end
                            if Suspect:isEscorting(entity) then return false end
                            if Suspect:isHostage(entity) then return false end
                            if isHandCuffing then return false end
                            if isSearchingSuspect then return false end
                            if isReviveNpc then return false end
                            return true
                        end
                    }, { -- Start Escort
                        type = "client",
                        icon = "fas fa-handcuffs",
                        label = Lang:t('start_escort'),
                        action = function(entity)
                            Suspect:setEscorting(entity, true)
                            Wait(10)
                            EscortEntity(entity)
                        end,
                        canInteract = function(entity, distance, data)
                            if not isLoggedIn then return false end
                            if not IsPedHuman(entity) then return false end
                            if IsPedAPlayer(entity) then return false end
                            if IsPedDeadOrDying(entity) then return false end
                            if not Suspect:isCuffed(entity) then return false end
                            if Suspect:isEscorting(entity) then return false end
                            if Suspect:isHostage(entity) then return false end
                            if isHandCuffing then return false end
                            if isSearchingSuspect then return false end
                            if isReviveNpc then return false end
                            return true
                        end
                    }, { -- Stop Escort
                        type = "client",
                        icon = "fas fa-handcuffs",
                        label = Lang:t('stop_escort'),
                        action = function(entity)
                            Suspect:setEscorting(entity, false)
                            Wait(10)
                            EscortEntity(entity)
                        end,
                        canInteract = function(entity, distance, data)
                            if not isLoggedIn then return false end
                            if not IsPedHuman(entity) then return false end
                            if IsPedAPlayer(entity) then return false end
                            if IsPedDeadOrDying(entity) then return false end
                            if not Suspect:isCuffed(entity) then return false end
                            if not Suspect:isEscorting(entity) then return false end
                            if Suspect:isHostage(entity) then return false end
                            if isHandCuffing then return false end
                            if isSearchingSuspect then return false end
                            if isReviveNpc then return false end
                            return true
                        end
                    }, { -- Search Suspect
                        icon = "fas fa-handcuffs",
                        label = Lang:t('search_suspect'),
                        action = function(entity)
                            SearchSuspect(entity)
                        end,
                        canInteract = function(entity)
                            if not isLoggedIn then return false end
                            if not IsPedHuman(entity) then return false end
                            if IsPedAPlayer(entity) then return false end
                            if IsPedDeadOrDying(entity) then return false end
                            if PlayerData ~= nil and PlayerData.job.name ~= 'police' then return false end
                            if not Suspect:isCuffed(entity) then return false end
                            if Suspect:isEscorting(entity) then return false end
                            if Suspect:isHostage(entity) then return false end
                            if isHandCuffing then return false end
                            if isSearchingSuspect then return false end
                            if isReviveNpc then return false end
                            return true
                        end,
                    }, { -- Revive Suspect
                        icon = "fas fa-handcuffs",
                        label = Lang:t('revive_suspect'),
                        action = function(entity)
                            ReviveNpc(entity)
                        end,
                        canInteract = function(entity)
                            if not isLoggedIn then return false end
                            if not IsPedHuman(entity) then return false end
                            if IsPedAPlayer(entity) then return false end
                            if not IsPedDeadOrDying(entity) then return false end
                            if PlayerData ~= nil and PlayerData.job.name ~= 'ambulance' then return false end
                            if not HasItem(config.RevieItem, 1) then return false end
                            if isHandCuffing then return false end
                            if isReviveNpc then return false end
                            return true
                        end,
                    }, { -- put in jail
                        icon = "fas fa-handcuffs",
                        label = Lang:t('put_in_jail'),
                        action = function(entity)
                            Suspect:setInJail(entity)
                        end,
                        canInteract = function(entity)
                            if not isLoggedIn then return false end
                            if not IsPedHuman(entity) then return false end
                            if IsPedAPlayer(entity) then return false end
                            if IsPedDeadOrDying(entity) then return false end
                            if PlayerData ~= nil and PlayerData.job.name ~= 'police' then return false end
                            if not Suspect:isCuffed(entity) then return false end
                            if not Suspect:isEscorting(entity) then return false end
                            if Suspect:isHostage(entity) then return false end
                            local coords = GetEntityCoords(PlayerPedId())
                            local jail_distance = GetDistance(coords, config.JailCoords)
                            if jail_distance > 1.5 then return false end
                            return true
                        end,
                    }, { -- set npc as hostage
                        icon = "fas fa-handcuffs",
                        label = "Make Hostage",
                        action = function(entity)
                            Suspect:toggleHostage(entity)
                            SetNpcAsHostage(entity)
                        end,
                        canInteract = function(entity)
                            if not isLoggedIn then return false end
                            if not IsPedHuman(entity) then return false end
                            if IsPedAPlayer(entity) then return false end
                            if IsPedDeadOrDying(entity) then return false end
                            if PlayerData ~= nil and PlayerData.job.name == 'police' then return false end
                            if not Suspect:isCuffed(entity) then return false end
                            if Suspect:isHostage(entity) then return false end
                            return true
                        end,
                    }, { -- release npc as hostage
                        icon = "fas fa-handcuffs",
                        label = "Release Hostage",
                        action = function(entity)
                            Suspect:toggleHostage(entity)
                            RemoveNpcAsHostage(entity)
                            
                        end,
                        canInteract = function(entity)
                            if not isLoggedIn then return false end
                            if not IsPedHuman(entity) then return false end
                            if IsPedAPlayer(entity) then return false end
                            if IsPedDeadOrDying(entity) then return false end
                            if not Suspect:isHostage(entity) then return false end
                            return true
                        end,
                    },
                },
                distance = 2.5
            })
        elseif GetResourceState("ox_target") ~= 'missing' then
            exports.ox_target:addModel(v.model, {
                { -- Cuff
                    icon = "fas fa-handcuffs",
                    label = Lang:t('cuff'),
                    onSelect = function(data)
                        CuffEntity(data.entity)
                    end,
                    canInteract = function(data)
                        if not isLoggedIn then return false end
                        if not IsPedHuman(entity) then return false end
                        if IsPedAPlayer(entity) then return false end
                        if IsPedDeadOrDying(data.entity) then return false end
                        if Suspect:isCuffed(data.entity) then return false end
                        if Suspect:isHostage(data.entity) then return false end
                        if not HasItem(config.HandcuffItem, 1) then return false end
                        if isHandCuffing then return false end
                        if isReviveNpc then return false end
                        return true
                    end,
                    distance = 2.5
                }, { -- UnCuff
                    icon = "fas fa-handcuffs",
                    label = Lang:t('uncuff'),
                    onSelect = function(data)
                        CuffEntity(data.entity)
                    end,
                    canInteract = function(data)
                        if not isLoggedIn then return false end
                        if not IsPedHuman(entity) then return false end
                        if IsPedAPlayer(entity) then return false end
                        if IsPedDeadOrDying(data.entity) then return false end
                        if not Suspect:isCuffed(data.entity) then return false end
                        if Suspect:isEscorting(data.entity) then return false end
                        if Suspect:isHostage(data.entity) then return false end
                        if isHandCuffing then return false end
                        if isSearchingSuspect then return false end
                        if isReviveNpc then return false end
                        return true
                    end,
                    distance = 2.5
                }, { -- Start Escort
                    icon = "fas fa-handcuffs",
                    label = Lang:t('start_escort'),
                    onSelect = function(data)
                        Suspect:setEscorting(data.entity, true)
                        Wait(10)
                        EscortEntity(data.entity)
                    end,
                    canInteract = function(data)
                        if not isLoggedIn then return false end
                        if not IsPedHuman(entity) then return false end
                        if IsPedAPlayer(entity) then return false end
                        if IsPedDeadOrDying(data.entity) then return false end
                        if not Suspect:isCuffed(data.entity) then return false end
                        if Suspect:isEscorting(data.entity) then return false end
                        if Suspect:isHostage(data.entity) then return false end
                        if isHandCuffing then return false end
                        if isSearchingSuspect then return false end
                        if isReviveNpc then return false end
                        return true
                    end,
                    distance = 2.5
                }, { -- Stop Escort
                    icon = "fas fa-handcuffs",
                    label = Lang:t('stop_escort'),
                    onSelect = function(data)
                        Suspect:setEscorting(data.entity, false)
                        Wait(10)
                        EscortEntity(data.entity)
                    end,
                    canInteract = function(data)
                        if not isLoggedIn then return false end
                        if not IsPedHuman(entity) then return false end
                        if IsPedAPlayer(entity) then return false end
                        if IsPedDeadOrDying(data.entity) then return false end
                        if not Suspect:isCuffed(data.entity) then return false end
                        if not Suspect:isEscorting(data.entity) then return false end
                        if Suspect:isHostage(data.entity) then return false end
                        if isHandCuffing then return false end
                        if isSearchingSuspect then return false end
                        if isReviveNpc then return false end
                        return true
                    end,
                    distance = 2.5
                }, { -- Search Suspect
                    icon = "fas fa-handcuffs",
                    label = Lang:t('search_suspect'),
                    onSelect = function(data)
                        SearchSuspect(data.entity)
                    end,
                    canInteract = function(data)
                        if not isLoggedIn then return false end
                        if not IsPedHuman(entity) then return false end
                        if IsPedAPlayer(entity) then return false end
                        if IsPedDeadOrDying(data.entity) then return false end
                        if PlayerData ~= nil and PlayerData.job.name ~= 'police' then return false end
                        if not Suspect:isCuffed(data.entity) then return false end
                        if Suspect:isEscorting(data.entity) then return false end
                        if Suspect:isHostage(data.entity) then return false end
                        if isHandCuffing then return false end
                        if isSearchingSuspect then return false end
                        if isReviveNpc then return false end
                        return true
                    end,
                    distance = 2.5
                }, { -- Revive Suspect
                    icon = "fas fa-handcuffs",
                    label = Lang:t('revive_suspect'),
                    onSelect = function(data)
                        ReviveNpc(data.entity)
                    end,
                    canInteract = function(data)
                        if not isLoggedIn then return false end
                        if not IsPedHuman(entity) then return false end
                        if IsPedAPlayer(entity) then return false end
                        if not IsPedDeadOrDying(data.entity) then return false end
                        if PlayerData ~= nil and PlayerData.job.name ~= 'ambulance' then return false end
                        if not HasItem(config.RevieItem, 1) then return false end
                        if isHandCuffing then return false end
                        if isReviveNpc then return false end
                        return true
                    end,
                    distance = 2.5
                }, { -- put in jail
                    icon = "fas fa-handcuffs",
                    label = Lang:t('put_in_jail'),
                    onSelect = function(data)
                        Suspect:setInJail(data.entity)
                    end,
                    canInteract = function(data)
                        if not isLoggedIn then return false end
                        if not IsPedHuman(entity) then return false end
                        if IsPedAPlayer(entity) then return false end
                        if IsPedDeadOrDying(data.entity) then return false end
                        if PlayerData ~= nil and PlayerData.job.name ~= 'police' then return false end
                        if not Suspect:isCuffed(data.entity) then return false end
                        if not Suspect:isEscorting(data.entity) then return false end
                        if Suspect:isHostage(data.entity) then return false end
                        local coords = GetEntityCoords(PlayerPedId())
                        local jail_distance = GetDistance(coords, config.JailCoords)
                        if jail_distance > 1.5 then return false end
                        return true
                    end,
                    distance = 2.5
                }, { -- set npc as hostage
                    icon = "fas fa-handcuffs",
                    label = "Take Hostage",
                    onSelect = function(data)
                        Suspect:toggleHostage(data.entity)
                        SetNpcAsHostage(data.entity)
                    end,
                    canInteract = function(data)
                        if not isLoggedIn then return false end
                        if not IsPedHuman(entity) then return false end
                        if IsPedAPlayer(entity) then return false end
                        if IsPedDeadOrDying(data.entity) then return false end
                        if PlayerData ~= nil and PlayerData.job.name == 'police' then return false end
                        if not Suspect:isCuffed(data.entity) then return false end
                        if Suspect:isHostage(data.entity) then return false end
                        return true
                    end,
                    distance = 2.5
                }, { -- release npc as hostage
                    icon = "fas fa-handcuffs",
                    label = "Release Hostage",
                    onSelect = function(data)
                        Suspect:toggleHostage(data.entity)
                        RemoveNpcAsHostage(data.entity)
                    end,
                    canInteract = function(data)
                        if not isLoggedIn then return false end
                        if not IsPedHuman(entity) then return false end
                        if IsPedAPlayer(entity) then return false end
                        if IsPedDeadOrDying(data.entity) then return false end
                        if not Suspect:isHostage(data.entity) then return false end
                        return true
                    end,
                    distance = 2.5
                },
            })
        end
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        isLoggedIn = false
        cop = nil
        suspect = nil
        isHandCuffing = false
        isSearchingSuspect = false
        isSearchingVehicle = false
        isReviveNpc = false
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        TriggerServerEvent('mh-walkwhencuffed:server:onjoin')
    end
end)

if GetResourceState("es_extended") ~= 'missing' or GetResourceState("qb-core") ~= 'missing' then
    RegisterNetEvent(OnPlayerLoaded, function()
        TriggerServerEvent('mh-walkwhencuffed:server:onjoin')
    end)

    RegisterNetEvent(OnPlayerUnload, function()
        PlayerData = {}
        isLoggedIn = false
        isHandCuffing = false
        isSearchingSuspect = false
        isSearchingVehicle = false
        isReviveNpc = false
    end)

    RegisterNetEvent(OnJobUpdate)
    AddEventHandler(OnJobUpdate, function(job)
        PlayerData.job = job
    end)

elseif GetResourceState("es_extended") == 'missing' and GetResourceState("qb-core") == 'missing' then
    AddEventHandler("playerSpawned", function(spawn)
        TriggerServerEvent('mh-walkwhencuffed:server:onjoin')
        PlayerData = nil
    end)
end

RegisterNetEvent('mh-walkwhencuffed:client:onjoin', function(data)
    isLoggedIn, cop, suspect = true, nil, nil
    config = data
    Wait(10)
    LoadTarget()
end)

RegisterNetEvent('mh-walkwhencuffed:client:syncData', function(data)
    searchSuspects = data.searchSuspects
    searchVehicles = data.searchVehicles
    cuffedSuspects = data.cuffedSuspects
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn and config ~= nil then
            sleep = config.ResetTimer * 1000
            searchSuspects = {}
            searchVehicles = {}
        end
        Wait(sleep)
    end
end)

-- cop/player VS Npc
CreateThread(function()
    LoadDict("mp_arresting")
    LoadDict('amb@world_human_drinking@coffee@female@base')
    LoadDict('anim@move_m@trash')
    LoadDict("anim@heists@fleeca_bank@hostages@intro")
    while true do
        local sleep = 1000
        if isLoggedIn then
            for key, suspect in pairs(cuffedSuspects) do
                if suspect.entity ~= nil and DoesEntityExist(suspect.entity) then
                    sleep = 0
                    if suspect.isCuffed then
                        if suspect.isEscorting then
                            if config.DisableRunningWhenCuffed then DisableControlAction(0, 21) end
                            if not IsEntityAttachedToEntity(suspect.entity, PlayerPedId()) then
                                AttachEntityToEntity(suspect.entity, PlayerPedId(), 11816, 0.38, 0.4, 0.0, 0.0, 0.0, 0.0, false, false, true, true, 2, true)
                            elseif IsEntityAttachedToEntity(suspect.entity, PlayerPedId()) and not suspect.isInVehicle then
                                if not IsEntityPlayingAnim(PlayerPedId(), 'amb@world_human_drinking@coffee@female@base', 'base', 3) then
                                    TaskPlayAnim(PlayerPedId(), 'amb@world_human_drinking@coffee@female@base', "base", 8.0, 8.0, -1, 50, 0, false, false, false)
                                end
                            end
                            if IsPedWalking(PlayerPedId()) then
                                StopAnimTask(suspect.entity, 'anim@move_m@trash', 'run', -8.0)
                                if not IsEntityPlayingAnim(suspect.entity, 'mp_arresting', 'walk', 3) then
                                    TaskPlayAnim(suspect.entity, 'mp_arresting', 'walk', 8.0, -8, -1, 1, 0.0, false, false, false)
                                    SetPedKeepTask(suspect.entity, true)
                                end
                            elseif IsPedSprinting(PlayerPedId()) then
                                if not IsEntityPlayingAnim(suspect.entity, 'anim@move_m@trash', 'run', 3) then
                                    TaskPlayAnim(suspect.entity, 'anim@move_m@trash', 'run', 8.0, -8, -1, 1, 0.0, false, false, false)
                                    SetPedKeepTask(suspect.entity, true)
                                end
                            else
                                StopAnimTask(suspect.entity, 'mp_arresting', 'walk', -8.0)
                                StopAnimTask(suspect.entity, 'anim@move_m@trash', 'run', -8.0)
                                if not IsEntityPlayingAnim(suspect.entity, 'mp_arresting', 'idle', 3) then
                                    TaskPlayAnim(suspect.entity, 'mp_arresting', 'idle', 8.0, -8, -1, 1, 0.0, false, false, false)
                                    SetPedKeepTask(suspect.entity, true)
                                end
                            end
                        elseif not suspect.isEscorting then
                            if suspect.isInVehicle then
                                if not IsEntityPlayingAnim(suspect.entity, 'mp_arresting', 'sit', 3) then
                                    TaskPlayAnim(suspect.entity, 'mp_arresting', 'sit', 8.0, -8, -1, 1, 0.0, false, false, false)
                                    SetPedKeepTask(suspect.entity, true)
                                end
                            else
                                if not IsEntityPlayingAnim(suspect.entity, 'mp_arresting', 'idle', 3) then
                                    TaskPlayAnim(suspect.entity, 'mp_arresting', 'idle', 8.0, -8, -1, 1, 0.0, false, false, false)
                                    SetPedKeepTask(suspect.entity, true)
                                end
                            end
                        end
                        if suspect.isHostage then
                            suspect.isCuffed = false
                            if not IsEntityPlayingAnim(suspect.entity, 'anim@heists@fleeca_bank@hostages@intro', 'intro_standing_ped_d', 3) then
                                TaskPlayAnim(suspect.entity, 'anim@heists@fleeca_bank@hostages@intro', 'intro_standing_ped_d', 8.0, -8.0, -1, 1, 0, false, false, false)
                                SetPedKeepTask(suspect.entity, true)
                            end
                        elseif not suspect.isHostage then
                            if IsEntityPlayingAnim(suspect.entity, 'anim@heists@fleeca_bank@hostages@intro', 'intro_standing_ped_d', 3) then
                                StopAnimTask(suspect.entity, 'anim@heists@fleeca_bank@hostages@intro', 'intro_standing_ped_d', -8.0)
                            end
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

