--[[ ===================================================== ]] --
--[[           MH Walk When Cuffed by MaDHouSe79           ]] --
--[[ ===================================================== ]] --
local function SetData(data) TriggerClientEvent('mh-walkwhencuffed:client:SetData', -1, data) end
RegisterNetEvent('mh-walkwhencuffed:server:onjoin', function() TriggerClientEvent('mh-walkwhencuffed:client:onjoin', source, SV_Config) end)
RegisterNetEvent('mh-walkwhencuffed:server:syncData', function(data) TriggerClientEvent('mh-walkwhencuffed:client:syncData', -1, data) end)
exports('SetData', SetData)