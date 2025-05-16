--[[ ===================================================== ]] --
--[[           MH Walk When Cuffed by MaDHouSe79           ]] --
--[[ ===================================================== ]] --
local config = nil
local cop = nil
local suspect = nil
local isHandCuffing = false
local isLoggedIn = false
local isSearchingSuspect = false
local isSearchingVehicle = false
local isReviveNpc = false
local searchSuspects = {}
local searchVehicles = {}
local cuffedSuspects = {}
local suspectEntity = nil -- current entity you are working with

local function SyncData()
    local data = {searchSuspects = searchSuspects, searchVehicles = searchVehicles, cuffedSuspects = cuffedSuspects}
    TriggerServerEvent('mh-walkwhencuffed:server:syncData', data)
end

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

local function SuspectExsist(entity)
    for key, suspect in pairs(cuffedSuspects) do
        if suspect.entity == entity then return true end
    end
    return false
end

local function SetSuspectCuffed(entity, state)
    for key, suspect in pairs(cuffedSuspects) do
        if suspect.entity == entity then suspect.isCuffed = state end
    end
end

local function SetSuspectEscorting(entity, state)
    for key, suspect in pairs(cuffedSuspects) do
        if suspect.entity == entity then suspect.isEscorting = state end
    end
end

local function IsSuspectCuffed(entity)
    for key, suspect in pairs(cuffedSuspects) do
        if suspect.entity == entity and suspect.isCuffed then return true end
    end
    return false
end

local function IsSuspectEscorting(entity)
    for key, suspect in pairs(cuffedSuspects) do
        if suspect.entity == entity and suspect.isEscorting then return true end
    end
    return false
end

local function AddSuspect(entity)
    if not SuspectExsist(entity) then
        cuffedSuspects[#cuffedSuspects + 1] = {entity = entity, isCuffed = true, isEscorting = true}
        SyncData()
    end
end

local function RemoveSuspect(entity)
    if SuspectExsist(entity) then
        for key, suspect in pairs(cuffedSuspects) do
            if suspect == entity then
                suspect = nil
                SyncData()
            end
        end
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
    AddSuspect(entity)
    SetSuspectCuffed(entity, true)
    SetSuspectEscorting(entity, true)
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
    SetSuspectCuffed(entity, false)
    SetSuspectEscorting(entity, false)
    RemoveSuspect(entity)
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
    if not IsSuspectEscorting(entity) then
        DetachEntity(entity)
        suspectEntity = nil
        StopAnimTask(PlayerPedId(), 'amb@world_human_drinking@coffee@female@base', 'base', -8.0)
        if IsSuspectCuffed(entity) then
            suspectEntity = entity
            SetSuspectEscorting(entity, false)
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

local function SetSuspectInVehicle(entity, vehicle)
    for key, suspect in pairs(cuffedSuspects) do
        if suspect.entity == entity then
            suspect.isEscorting = false
            suspect.isInVehicle = true
            suspect.vehicle = vehicle
            SyncData()
            break
        end
    end
end

local function TakeSuspectOutVehicle(entity, vehicle)
    for key, suspect in pairs(cuffedSuspects) do
        if suspect.entity == entity and suspect.vehicle == vehicle then
            suspect.isEscorting = true
            suspect.isInVehicle = false
            suspect.vehicle = nil
            SyncData()
            break
        end
    end
end

local function PlaceEntityInVehicle(entity, vehicle)
    for i = 1, 7, 1 do
        if IsVehicleSeatFree(vehicle, i) then
            SetEntityAsMissionEntity(entity, true, true)
            SetEntityAsMissionEntity(vehicle, true, true)
            DetachEntity(entity, true, false)
            SetSuspectEscorting(entity, false)
            SetSuspectCuffed(entity, true)
            EscortEntity(entity)
            SetPedIntoVehicle(entity, vehicle, i)
            SetSuspectInVehicle(entity, vehicle)
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
            SetSuspectEscorting(entity, true)
            SetSuspectCuffed(entity, true)
            CuffEntity(entity)
            EscortEntity(entity)
            TakeSuspectOutVehicle(entity, vehicle)
            break
        end
    end
end

local function SetSuspectInJail(entity)
    UnCuffEntity(entity)
    DetachEntity(entity, true, false)
    RemoveSuspect(entity)
    Wait(10)
    DeleteEntity(entity)
    StopAnimTask(PlayerPedId(), 'amb@world_human_drinking@coffee@female@base', 'base', -8.0)
    suspectEntity = nil
end

local function LoadTarget()
    for k, v in pairs(config.Vehicles) do
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
                }, { -- Search Vehicle
                    icon = "fas fa-handcuffs",
                    label = Lang:t('search_vehicle'),
                    action = function(entity)
                        SearchVehicle(entity)
                    end,
                    canInteract = function(entity)
                        if searchVehicles[entity] then return false end
                        return true
                    end,
                },
            },
            distance = 3.0
        })
    end

    for k, v in pairs(config.Peds) do
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
                        if IsPedDeadOrDying(entity) then return false end
                        if IsSuspectCuffed(entity) then return false end
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
                        if IsPedDeadOrDying(entity) then return false end
                        if not IsSuspectCuffed(entity) then return false end
                        if IsSuspectEscorting(entity) then return false end
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
                        SetSuspectEscorting(entity, true)
                        Wait(10)
                        EscortEntity(entity)
                    end,
                    canInteract = function(entity, distance, data)
                        if IsPedDeadOrDying(entity) then return false end
                        if not IsSuspectCuffed(entity) then return false end
                        if IsSuspectEscorting(entity) then return false end
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
                        SetSuspectEscorting(entity, false)
                        Wait(10)
                        EscortEntity(entity)
                    end,
                    canInteract = function(entity, distance, data)
                        if IsPedDeadOrDying(entity) then return false end
                        if not IsSuspectCuffed(entity) then return false end
                        if not IsSuspectEscorting(entity) then return false end
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
                        if IsPedDeadOrDying(entity) then return false end
                        if not IsSuspectCuffed(entity) then return false end
                        if IsSuspectEscorting(entity) then return false end
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
                        if not IsPedDeadOrDying(entity) then return false end
                        if not HasItem(config.RevieItem, 1) then return false end
                        if isHandCuffing then return false end
                        if isReviveNpc then return false end
                        return true
                    end,
                }, { -- put in jail
                    icon = "fas fa-handcuffs",
                    label = Lang:t('put_in_jail'),
                    action = function(entity)
                        SetSuspectInJail(entity)
                    end,
                    canInteract = function(entity)
                        if IsPedDeadOrDying(entity) then return false end
                        if not IsSuspectCuffed(entity) then return false end
                        if not IsSuspectEscorting(entity) then return false end
                        local coords = GetEntityCoords(PlayerPedId())
                        local jail_distance = GetDistance(coords, config.JailCoords)
                        if jail_distance > 1.5 then return false end
                        return true
                    end,
                }
            },
            distance = 2.5
        })
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        isLoggedIn = false
        isSearchingSuspect = false
        cop = nil
        suspect = nil
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        TriggerServerEvent('mh-walkwhencuffed:server:onjoin')
    end
end)

AddEventHandler("playerSpawned", function(spawn)
    TriggerServerEvent('mh-walkwhencuffed:server:onjoin')
end)

RegisterNetEvent('mh-walkwhencuffed:client:onjoin', function(data)
    isLoggedIn, cop, suspect = true, nil, nil
    config = data
    LoadTarget()
end)

RegisterNetEvent('mh-walkwhencuffed:client:syncData', function(data)
    searchSuspects = data.searchSuspects
    searchVehicles = data.searchVehicles
    cuffedSuspects = data.cuffedSuspects
end)

RegisterNetEvent('mh-walkwhencuffed:client:SetData', function(data)
    if data.cop ~= nil and data.cop == PlayerPedId() then cop = PlayerPedId() end
    if data.suspect ~= nil and data.suspect == PlayerPedId() then suspect = PlayerPedId() end
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
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- cop VS player
CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn and cop ~= nil and suspect ~= nil then
            if suspect == PlayerPedId() then
                LoadDict("mp_arresting")
                -- Movements for suspect
                local isCuffed = exports['qb-policejob']:IsHandcuffed()
                if isCuffed then
                    SetEnableHandcuffs(suspect, true)
                    SetPedCanPlayGestureAnims(suspect, false)
                    sleep = 0
                    if IsEntityAttachedToEntity(suspect, cop) then
                        if IsPedWalking(cop) then
                            if not IsEntityPlayingAnim(suspect, 'mp_arresting', 'walk', 3) then
                                TaskPlayAnim(suspect, 'mp_arresting', 'walk', 8.0, -8, -1, 1, 0.0, false, false, false)
                                SetPedKeepTask(suspect, true)
                            end
                        elseif not IsPedWalking(cop) then
                            if not IsEntityPlayingAnim(suspect, 'mp_arresting', 'idle', 3) then
                                TaskPlayAnim(suspect, 'mp_arresting', 'idle', 8.0, -8, -1, 1, 0.0, false, false, false)
                                SetPedKeepTask(suspect, true)
                            end
                        end
                    elseif not IsEntityAttachedToEntity(suspect, cop) then
                        if not IsEntityPlayingAnim(suspect, 'mp_arresting', 'idle', 3) then
                            TaskPlayAnim(suspect, 'mp_arresting', 'idle', 8.0, -8, -1, 16, 0.0, false, false, false)
                            SetPedKeepTask(suspect, true)
                        end
                    end
                elseif not isCuffed then
                    SetEnableHandcuffs(suspect, false)
                    SetPedCanPlayGestureAnims(suspect, true)
                    cop = nil
                    suspect = nil
                end
            elseif cop == PlayerPedId() then
                LoadDict("amb@world_human_drinking@coffee@female@base")
                -- Movements for cop
                if IsEntityAttachedToEntity(suspect, cop) then
                    DisableControlAction(0, 21)
                    if not IsEntityPlayingAnim(cop, 'amb@world_human_drinking@coffee@female@base', 'base', 3) then
                        TaskPlayAnim(cop, 'amb@world_human_drinking@coffee@female@base', "base", 8.0, 8.0, -1, 50, 0, false, false, false)
                        SetPedKeepTask(cop, true)
                    end
                elseif not IsEntityAttachedToEntity(suspect, cop) then
                    if IsEntityPlayingAnim(cop, 'amb@world_human_drinking@coffee@female@base', 'base', 3) then
                        StopAnimTask(cop, "amb@world_human_drinking@coffee@female@base", "base", 1.0)
                    end
                end
            end
        end
        Wait(sleep)
    end
end)