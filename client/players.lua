cop = nil
suspect = nil

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        cop = nil
        suspect = nil
    end
end)

RegisterNetEvent('mh-walkwhencuffed:client:SetData', function(data)
    if data.cop ~= nil and data.cop == PlayerPedId() then cop = PlayerPedId() end
    if data.suspect ~= nil and data.suspect == PlayerPedId() then suspect = PlayerPedId() end
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