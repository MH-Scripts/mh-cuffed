--[[ ===================================================== ]] --
--[[           MH Walk When Cuffed by MaDHouSe79           ]] --
--[[ ===================================================== ]] --
Framework, CreateCallback = nil, nil
if GetResourceState("es_extended") ~= 'missing' then
    Framework = exports['es_extended']:getSharedObject()
    CreateCallback = Framework.RegisterServerCallback
    function GetPlayer(source) return Framework.GetPlayerFromId(source) end
    function Notify(src, message, type, length) TriggerClientEvent("mh-walkwhencuffed:client:notify", src, message, type, length) end
elseif GetResourceState("qb-core") ~= 'missing' then
    Framework = exports['qb-core']:GetCoreObject()
    CreateCallback = Framework.Functions.CreateCallback
    function GetPlayer(source) return Framework.Functions.GetPlayer(source) end
    function Notify(src, message, type, length) TriggerClientEvent("mh-walkwhencuffed:client:notify", src, message, type, length) end
end
----------------------------------------------------------------------------------------------------------
local function SetData(data) TriggerClientEvent('mh-walkwhencuffed:client:SetData', -1, data) end
RegisterNetEvent('mh-walkwhencuffed:server:onjoin', function() TriggerClientEvent('mh-walkwhencuffed:client:onjoin', source, SV_Config) end)
RegisterNetEvent('mh-walkwhencuffed:server:syncData', function(data) TriggerClientEvent('mh-walkwhencuffed:client:syncData', -1, data) end)
exports('SetData', SetData)