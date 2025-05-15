--[[ ===================================================== ]] --
--[[           MH Walk When Cuffed by MaDHouSe79           ]] --
--[[ ===================================================== ]] --
config = nil
isLoggedIn = false

function Notify(message, type, length)
    if GetResourceState("ox_lib") ~= 'missing' then
        lib.notify({title = "MH Walk When Cuffed", description = message, type = type})
    else
        print(message)
    end
end

function LoadDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(1)
        end
    end
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        TriggerServerEvent('mh-walkwhencuffed:server:onjoin')
    end
end)

AddEventHandler("playerSpawned", function(spawn)
    TriggerServerEvent('mh-walkwhencuffed:server:onjoin')
end)

RegisterNetEvent('mh-walkwhencuffed:client:notify', function(message, type, length)
    Notify(message, type, length)
end)

RegisterNetEvent('mh-walkwhencuffed:client:onjoin', function(data)
    isLoggedIn, cop, suspect = true, nil, nil
    config = data
    LoadPedsTarget()
end)