local cuffedSuspects = {}
local searchSuspects = {}
--
local isHandCuffing = false
local isSearchingSuspect = false
local isReviveNpc = false
local isRobNPC = false
local suspectEntity = nil -- current entity you are working with

local function SycnData()
    TriggerServerEvent('mh-walkwhencuffed:server:syncData', {cuffedSuspects = cuffedSuspects, searchSuspects = searchSuspects})
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
    SycnData()
end

local function SetSuspectEscorting(entity, state)
    for key, suspect in pairs(cuffedSuspects) do
        if suspect.entity == entity then suspect.isEscorting = state end
    end
    SycnData()
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
        SycnData()
    end
end

local function RemoveSuspect(entity)
    if SuspectExsist(entity) then
        for key, suspect in pairs(cuffedSuspects) do
            if suspect == entity then suspect = nil end
        end
        SycnData()
    end
end

local function CuffEntity(entity)
    if isHandCuffing then return end
    isHandCuffing = true
    LoadDict("mp_arrest_paired")
    SetEntityAsMissionEntity(entity, true, true)
    TaskSetBlockingOfNonTemporaryEvents(entity, true)
    SetPedFleeAttributes(entity, 0, 0)
    SetPedCombatAttributes(entity, 17, 1)
    ClearPedTasks(entity)
    ClearPedTasksImmediately(entity)
    SetPedFleeAttributes(entity, 0, false)
    FreezeEntityPosition(entity, true)
    Wait(200)
    FreezeEntityPosition(PlayerPedId(), true)
    TaskPlayAnim(PlayerPedId(), 'mp_arrest_paired', 'cop_p2_back_right', 3.0, 3.0, -1, 48, 0, 0, 0, 0)
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'Cuff', 0.5)
    TaskPlayAnim(entity, 'mp_arrest_paired', 'crook_p2_back_right', 3.0, 3.0, -1, 32, 0, 0, 0, 0, true, true, true)
    Wait(3500)
    TaskPlayAnim(PlayerPedId(), 'mp_arrest_paired', 'exit', 3.0, 3.0, -1, 48, 0, 0, 0, 0)
    Wait(100)
    FreezeEntityPosition(PlayerPedId(), false)
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
    if not IsEntityPlayingAnim(entity, 'mp_arresting', 'idle', 3) then
        TaskPlayAnim(entity, 'mp_arresting', 'idle', 8.0, -8, -1, 16, 0.0, false, false, false)
        SetPedKeepTask(entity, true)
    end
    suspectEntity = nil
end

local function EscortEntity(entity)
    LoadDict("mp_arresting")
    LoadDict('amb@world_human_drinking@coffee@female@base')
    FreezeEntityPosition(entity, false)
    SetEntityAsMissionEntity(entity, true, true)
    if not IsSuspectEscorting(entity) then
        DetachEntity(entity)
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

function LoadPedsTarget()
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
                        if isHandCuffing then return false end
                        if not exports['qb-inventory']:HasItem(config.HandcuffItem, 1) then return false end
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
                        return true
                    end
                },
            },
            distance = 2.5
        })
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        isHandCuffing = false
        isSearchingSuspect = false
        isReviveNpc = false
        suspectEntity = nil -- current entity you are working with
        cuffedSuspects = {}
        searchSuspects = {}
    end
end)

RegisterNetEvent('mh-walkwhencuffed:client:syncData', function(data)
    cuffedSuspects = data.cuffedSuspects
    searchSuspects = data.searchSuspects
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if isLoggedIn and config ~= nil then
            sleep = config.ResetTimer * 1000
            searchSuspects = {}
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    LoadDict("mp_arresting")
    LoadDict('amb@world_human_drinking@coffee@female@base')
    while true do
        local sleep = 1000
        for key, suspect in pairs(cuffedSuspects) do
            if suspect.entity ~= nil and DoesEntityExist(suspect.entity) then
                if suspect.isCuffed then
                    sleep = 0
                    if suspect.isEscorting then
                        DisableControlAction(0, 21)
                        if not IsEntityAttachedToEntity(suspect.entity, PlayerPedId()) then
                            AttachEntityToEntity(suspect.entity, PlayerPedId(), 11816, 0.38, 0.4, 0.0, 0.0, 0.0, 0.0, false, false, true, true, 2, true)
                        end
                        if not IsEntityPlayingAnim(PlayerPedId(), 'amb@world_human_drinking@coffee@female@base', 'base', 3) then
                            TaskPlayAnim(PlayerPedId(), 'amb@world_human_drinking@coffee@female@base', "base", 8.0, 8.0, -1, 50, 0, false, false, false)
                        end
                        if IsPedWalking(PlayerPedId()) then
                            if not IsEntityPlayingAnim(suspect.entity, 'mp_arresting', 'walk', 3) then
                                TaskPlayAnim(suspect.entity, 'mp_arresting', 'walk', 8.0, -8, -1, 1, 0.0, false, false, false)
                                SetPedKeepTask(suspect.entity, true)
                            end
                        elseif not IsPedWalking(PlayerPedId()) then
                            StopAnimTask(suspect.entity, 'mp_arresting', 'walk', -8.0)
                            if not IsEntityPlayingAnim(suspect.entity, 'mp_arresting', 'idle', 3) then
                                TaskPlayAnim(suspect.entity, 'mp_arresting', 'idle', 8.0, -8, -1, 1, 0.0, false, false, false)
                                SetPedKeepTask(suspect.entity, true)
                            end
                        end
                    else
                        if not IsEntityPlayingAnim(suspect.entity, 'mp_arresting', 'idle', 3) then
                            TaskPlayAnim(suspect.entity, 'mp_arresting', 'idle', 8.0, -8, -1, 16, 0.0, false, false, false)
                            SetPedKeepTask(suspect.entity, true)
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)