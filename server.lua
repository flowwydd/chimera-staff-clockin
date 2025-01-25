local playerClockIns = {}
local afkTimeout = Config.AFKClockoutTime * 60
local playerLastActivity = {}

RegisterCommand("clockin", function(source, args, rawCommand)
    playerClockIns[source] = {time = os.time(), dept = dept}
    playerLastActivity[source] = os.time()
    if IsPlayerAceAllowed(source, Config.AcePerm) then
        SendNotification(source, "You have clocked in.", 'success')
        local discordId
        for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
            if string.sub(identifier, 1, string.len("discord:")) == "discord:" then
                discordId = string.gsub(identifier, "discord:", "")
            end
        end
        local data = {
            staff = true,
        }
        TriggerClientEvent('chimera-staff', source, data)
        if discordId then
            local webhookURL = Config.Webhook
            local embedData = {
                ["color"] = 5763719,
                ["title"] = "Clockin",
                ["description"] = "\n**Discord**: <@" .. discordId .. ">",
                ["footer"] = {
                    ["text"] = "Chimera Labs",
                },
            }
            sendHttpRequest(webhookURL, {username = "Staff API", embeds = {embedData}})
        end
    else
        SendNotification(source, "No Permission", 'error')
    end
end)

RegisterCommand("clockout", function(source, args, rawCommand)
    clockOutPlayer(source, "Manual")
end, false)

function clockOutPlayer(source, reason)
    local currentTime = os.time()
    local clockData = playerClockIns[source]
    if not clockData then
        SendNotification(source, "You aren't clocked in.", 'error')
        return
    end
    local clockInTime = clockData.time
    local totalTimeWorked = currentTime - clockInTime
    SendNotification(source, "You have clocked out.", 'error')
    playerClockIns[source] = nil
    playerLastActivity[source] = nil
    local discordId
    for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(identifier, 1, string.len("discord:")) == "discord:" then
            discordId = string.gsub(identifier, "discord:", "")
        end
    end
    local data = {
        staff = false,
    }
    TriggerClientEvent('chimera-staff', source, data)
    if discordId then
        local webhookURL = Config.Webhook
        local embedData = {
            ["color"] = 15548997,
            ["title"] = "Clockout",
            ["description"] = "\n**Discord**: <@" .. discordId .. ">\n**Reason**: " .. reason .. "\n**Clocked In At**: " .. formatTime(clockInTime) .. "\n**Clocked Out At**: " .. formatTime(currentTime),
            ["footer"] = {
                ["text"] = "Chimera Labs",
            },
        }
        sendHttpRequest(webhookURL, {username = "Clockin Bot", embeds = {embedData}})
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        local currentTime = os.time()
        for source, lastActivity in pairs(playerLastActivity) do
            if playerClockIns[source] and (currentTime - lastActivity >= afkTimeout) then
                TriggerClientEvent("showAFKDialog", source)
                clockOutPlayer(source, "AFK Clockout")
            end
        end
    end
end)

RegisterNetEvent("playerActivity")
AddEventHandler("playerActivity", function()
    local source = source
    playerLastActivity[source] = os.time()
end)

AddEventHandler("playerDropped", function(reason)
    local source = source
    if playerClockIns[source] then
        clockOutPlayer(source, "Player Disconnected: " .. reason)
    end
end)

function formatTime(seconds)
    return "<t:" .. seconds .. ">"
end
