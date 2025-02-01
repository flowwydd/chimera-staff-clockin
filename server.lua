local playerClockIns = {}
local playerLastActivity = {}
local clockOutTimestamps = {}
local afkTimeout = Config.AFKClockoutTime * 60
local cooldownTime = 30

RegisterCommand("clockin", function(source, args, rawCommand)
    local currentTime = os.time()
    if clockOutTimestamps[source] and (currentTime - clockOutTimestamps[source] < cooldownTime) then
        local timeRemaining = cooldownTime - (currentTime - clockOutTimestamps[source])
        SendNotification(source, "You cannot clock in yet. Please wait " .. timeRemaining .. " seconds.", 'error')
        return
    end
    if playerClockIns[source] then
        SendNotification(source, "You are already clocked in.", 'error')
        return
    end

    clockInPlayer(source, "Manual Clock-in")
end, false)

RegisterCommand("clockout", function(source, args, rawCommand)
    clockOutPlayer(source, "Manual Clock-out")
end, false)

function clockInPlayer(source, reason)
    playerClockIns[source] = {time = os.time(), dept = "chimera-staff"}
    playerLastActivity[source] = os.time()

    local data = {staff = true}
    TriggerClientEvent('chimera-staff', source, data)

    local discordId
    for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(identifier, 1, string.len("discord:")) == "discord:" then
            discordId = string.gsub(identifier, "discord:", "")
        end
    end

    if discordId then
        local webhookURL = Config.Webhook
        if webhookURL and webhookURL ~= "" then
            local embedData = {
                ["color"] = 5763719,
                ["title"] = "Clock-in",
                ["description"] = "**Discord**: <@" .. discordId .. ">\n**Reason**: " .. reason,
                ["footer"] = { ["text"] = "Chimera Labs" },
            }
            sendHttpRequest(webhookURL, {username = "Clock-in Bot", embeds = {embedData}})
        end
    end

    SendNotification(source, "You have successfully clocked in.", 'success')
end

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
    clockOutTimestamps[source] = currentTime

    local discordId
    for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(identifier, 1, string.len("discord:")) == "discord:" then
            discordId = string.gsub(identifier, "discord:", "")
        end
    end

    local data = {staff = false}
    TriggerClientEvent('chimera-staff', source, data)

    if discordId then
        local webhookURL = Config.Webhook
        if webhookURL and webhookURL ~= "" then
            local embedData = {
                ["color"] = 15548997,
                ["title"] = "Clock-out",
                ["description"] = "**Discord**: <@" .. discordId .. ">\n**Reason**: " .. reason .. "\n**Clocked In At**: " .. formatTime(clockInTime) .. "\n**Clocked Out At**: " .. formatTime(currentTime),
                ["footer"] = { ["text"] = "Chimera Labs" },
            }
            sendHttpRequest(webhookURL, {username = "Clock-in Bot", embeds = {embedData}})
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local currentTime = os.time()
        for source, lastActivity in pairs(playerLastActivity) do
            if playerClockIns[source] then
                if not IsPlayerAceAllowed(source, "clockin.bypass") then
                    TriggerClientEvent("checkPlayerMovement", source)
                    if (currentTime - lastActivity >= afkTimeout) then
                        TriggerClientEvent("showAFKDialog", source)
                        clockOutPlayer(source, "AFK Clockout")
                    end
                end
            end
        end
    end
end)

RegisterNetEvent("playerMoved")
AddEventHandler("playerMoved", function()
    local source = source
    playerLastActivity[source] = os.time()
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

exports("StaffClockin", function(source, reason)
    clockInPlayer(source, reason or "Manual Clock-in")
end)

exports("StaffClockout", function(source, reason)
    clockOutPlayer(source, reason or "Manual Clock-out")
end)
