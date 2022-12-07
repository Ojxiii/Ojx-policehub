local HTML = ""
local CallSigns = {}
local radio = 0

local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand("policehub", function(source, args)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)

    if xPlayer.PlayerData.job.name == "police" then
        local type = "toggle"
        TriggerEvent("Ojx:officers:refresh")
        
        if args[1] == "0" then
            type = "drag"
        end

        TriggerClientEvent("Ojx:officers:open", src, type)
    end
end)

RegisterCommand("callsign", function(source, args)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(source)

    if xPlayer and (xPlayer.PlayerData.job.name == 'police') and args[1] then
        if args[1] == 'none' then
            CallSigns[xPlayer.PlayerData.license] = "NO TAG"
            TriggerEvent("Ojx:officers:refresh")
            SaveResourceFile(GetCurrentResourceName(), "callsigns.json", json.encode(CallSigns))
            TriggerEvent("Ojx:officers:refresh")
            TriggerClientEvent('QBCore:Notify', source, "Restored Callsign", "success")
        else
            CallSigns[xPlayer.PlayerData.license] = args[1]
            TriggerEvent("Ojx:officers:refresh")
            SaveResourceFile(GetCurrentResourceName(), "callsigns.json", json.encode(CallSigns))
            TriggerEvent("Ojx:officers:refresh")
            TriggerClientEvent('QBCore:Notify', source, "Updated Callsign: " .. args[1], "success")
        end
    end
end)

RegisterServerEvent("Ojx:officers:refresh")
AddEventHandler("Ojx:officers:refresh", function()
    local new = ""

    for k,v in pairs(QBCore.Functions.GetPlayers()) do
        local xPlayer = QBCore.Functions.GetPlayer(v)
        if xPlayer and (xPlayer.PlayerData.job.name == 'police') then
            local name = GetName(v)
            local dutyClass = ""
            local duty = ""
            
            if xPlayer.PlayerData.job.onduty then
                dutyClass = 'duty'
                duty = "🔵"
            else
                dutyClass = 'offduty'
                duty = "🔴"
            end
            
            local radioChannel = GetRadioChannel(v)
            local radioLabel = ""

            if radioChannel == 0 then
                radioLabel = "Off"
            else
                radioLabel = radioChannel .. 'hz'
            end

            local callSign = CallSigns[xPlayer.PlayerData.license] ~= nil and CallSigns[xPlayer.PlayerData.license] or "NO TAG"

            if (callSign >= Config.Command_Min and callSign <= Config.Command_Max) then
                new = new .. '<div class="officer"><span class="callsign-command">' .. callSign .. '</span> <span class="name">' .. name .. '</span> | <span class="grade">' .. xPlayer.PlayerData.job.grade.name .. '</span> <span class="' .. dutyClass .. '">' .. duty .. '</span>'
            elseif (callSign >= Config.Detective_Min and callSign <= Config.Detective_Max) then
                new = new .. '<div class="officer"><span class="callsign-detective">' .. callSign .. '</span> <span class="name">' .. name .. '</span> | <span class="grade">' .. xPlayer.PlayerData.job.grade.name .. '</span> <span class="' .. dutyClass .. '">' .. duty .. '</span>'
            elseif (callSign >= Config.Swat_Min and callSign <= Config.Swat_Max) then
                new = new .. '<div class="officer"><span class="callsign-swat">' .. callSign .. '</span> <span class="name">' .. name .. '</span> | <span class="grade">' .. xPlayer.PlayerData.job.grade.name .. '</span> <span class="' .. dutyClass .. '">' .. duty .. '</span>'
            elseif (callSign >= Config.Bcso_Min and callSign <= Config.Bcso_Max) then
                new = new .. '<div class="officer"><span class="callsign-bcso">' .. callSign .. '</span> <span class="name">' .. name .. '</span> | <span class="grade">' .. xPlayer.PlayerData.job.grade.name .. '</span> <span class="' .. dutyClass .. '">' .. duty .. '</span>'
            elseif (callSign >= Config.Troopers_Min and callSign <= Config.Troopers_Min) then
                new = new .. '<div class="officer"><span class="callsign-troopers">' .. callSign .. '</span> <span class="name">' .. name .. '</span> | <span class="grade">' .. xPlayer.PlayerData.job.grade.name .. '</span> <span class="' .. dutyClass .. '">' .. duty .. '</span'
            elseif (callSign >= Config.Rangers_Min and callSign <= Config.Rangers_Min) then
                new = new .. '<div class="officer"><span class="callsign-rangers">' .. callSign .. '</span> <span class="name">' .. name .. '</span> | <span class="grade">' .. xPlayer.PlayerData.job.grade.name .. '</span> <span class="' .. dutyClass .. '">' .. duty .. '</span>'
            else
                new = new .. '<div class="officer"><span class="callsign">' .. callSign .. '</span> <span class="name">' .. name .. '</span> | <span class="grade">' .. xPlayer.PlayerData.job.grade.name .. '</span> <span class="' .. dutyClass .. '">' .. duty .. '</span>'
            end
        end
    end

    HTML = new
    TriggerClientEvent("Ojx:officers:refresh", -1, HTML)
end)

function GetName(source)
    local xPlayer = QBCore.Functions.GetPlayer(source)

    if xPlayer ~= nil and xPlayer.PlayerData.charinfo.firstname ~= nil and xPlayer.PlayerData.charinfo.lastname ~= nil then
         return xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname
    else
        return ""
    end
end

function GetRadioChannel(source)
    return Player(source).state['radioChannel']
end

CreateThread(function()
    local result = json.decode(LoadResourceFile(GetCurrentResourceName(), "callsigns.json"))

    if result then
        CallSigns = result
    end
end)
