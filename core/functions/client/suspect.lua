Suspect = {}
Suspect.__index = Suspect

cuffedSuspects = {}

function Suspect:exsist(entity)
    for key, suspect in pairs(cuffedSuspects) do
        if suspect.entity == entity then return true end
    end
    return false
end

function Suspect:new(entity)
    if not Suspect:exsist(entity) then
        cuffedSuspects[#cuffedSuspects + 1] = {entity = entity, isCuffed = true, isEscorting = true, isHostage = false}
        TriggerServerEvent('mh-walkwhencuffed:server:syncData', {searchSuspects = searchSuspects, searchVehicles = searchVehicles, cuffedSuspects = cuffedSuspects})
    end
end

function Suspect:delete(entity)
    if Suspect:exsist(entity) then
        for key, suspect in pairs(cuffedSuspects) do
            if suspect == entity then
                suspect = nil
                TriggerServerEvent('mh-walkwhencuffed:server:syncData', {searchSuspects = searchSuspects, searchVehicles = searchVehicles, cuffedSuspects = cuffedSuspects})
            end
        end
    end
end

function Suspect:setCuffed(entity, state)
    for key, suspect in pairs(cuffedSuspects) do
        if suspect.entity == entity then suspect.isCuffed = state end
    end
end

function Suspect:setEscorting(entity, state)
    for key, suspect in pairs(cuffedSuspects) do
        if suspect.entity == entity then suspect.isEscorting = state end
    end
end

function Suspect:toggleHostage(entity)
    for key, suspect in pairs(cuffedSuspects) do
        if suspect.entity == entity then
            suspect.isHostage = not suspect.isHostage
        end
    end
    return false
end

function Suspect:toggleSurender(entity)
    for key, suspect in pairs(cuffedSuspects) do
        if suspect.entity == entity then
            suspect.isSurender = not suspect.isSurender
        end
    end
    return false
end

function Suspect:isCuffed(entity)
    for key, suspect in pairs(cuffedSuspects) do
        if suspect.entity == entity and suspect.isCuffed then return true end
    end
    return false
end

function Suspect:isEscorting(entity)
    for key, suspect in pairs(cuffedSuspects) do
        if suspect.entity == entity and suspect.isEscorting then return true end
    end
    return false
end

function Suspect:isHostage(entity)
    for key, suspect in pairs(cuffedSuspects) do
        if suspect.entity == entity and suspect.isHostage then return true end
    end
    return false
end

function Suspect:isSurender(entity)
    for key, suspect in pairs(cuffedSuspects) do
        if suspect.entity == entity and suspect.isSurender then return true end
    end
    return false
end

function Suspect:setInVehicle(entity, vehicle)
    for key, suspect in pairs(cuffedSuspects) do
        if suspect.entity == entity then
            suspect.isEscorting = false
            suspect.isInVehicle = true
            suspect.vehicle = vehicle
            TriggerServerEvent('mh-walkwhencuffed:server:syncData', {searchSuspects = searchSuspects, searchVehicles = searchVehicles, cuffedSuspects = cuffedSuspects})
            break
        end
    end
end

function Suspect:takeOutVehicle(entity, vehicle)
    for key, suspect in pairs(cuffedSuspects) do
        if suspect.entity == entity and suspect.vehicle == vehicle then
            suspect.isEscorting = true
            suspect.isInVehicle = false
            suspect.vehicle = nil
            TriggerServerEvent('mh-walkwhencuffed:server:syncData', {searchSuspects = searchSuspects, searchVehicles = searchVehicles, cuffedSuspects = cuffedSuspects})
            break
        end
    end
end

function Suspect:setInJail(entity)
    UnCuffEntity(entity)
    DetachEntity(entity, true, false)
    Suspect:delete(entity)
    Wait(10)
    DeleteEntity(entity)
    StopAnimTask(PlayerPedId(), 'amb@world_human_drinking@coffee@female@base', 'base', -8.0)
    suspectEntity = nil
end