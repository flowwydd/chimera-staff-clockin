function sendHttpRequest(url, data)
    PerformHttpRequest(url, function(err, text, headers)
        if err then
            return
        end
    end, 'POST', json.encode(data), { ['Content-Type'] = 'application/json' })
end

function formatTime(seconds)
    return "<t:" .. seconds .. ">"
end

function SendNotification(recipient, message, type)
    if Config.Notify == 0 then
        if type == "success" then
            local type = "SUCCESS"
            local message = "~g~[ " .. type .. " ] ~w~" .. message
            TriggerClientEvent('chat:addMessage', recipient, message)
        elseif type == "error" then
            local type = "ERROR"
            local message = "~r~[ " .. type .. " ] ~w~" .. message
            TriggerClientEvent('chat:addMessage', recipient, message)
        end
    elseif Config.Notify == 1 then
        if type == "success" then
            TriggerClientEvent('okokNotify:Alert', recipient, 'SUCCESS', message, Config.NotifyDuration, 'success', true)
        elseif type == "error" then
            TriggerClientEvent('okokNotify:Alert', recipient, 'ERROR', message, Config.NotifyDuration, 'error', true)
        end
    elseif Config.Notify == 2 then
        if type == "success" then
            TriggerClientEvent('codem-notification', recipient, message, 8000, 'check', options)
        elseif type == "error" then
            TriggerClientEvent('codem-notification', recipient, message, 8000, 'error', options)
        end
    elseif Config.Notify == 3 then
        -- mythic_notify
        if type == "success" then
            TriggerClientEvent('mythic_notify:client:SendAlert', recipient, { type = 'success', text = message, style = { ['background-color'] = '#000000', ['color'] = '#ffff' } })
        elseif type == "error" then
            TriggerClientEvent('mythic_notify:client:SendAlert', recipient, { type = 'error', text = message, style = { ['background-color'] = '#000000', ['color'] = '#ffff' } })
        end
    elseif Config.Notify == 4 then
        if type == "success" then
            TriggerClientEvent('ox_lib:notify', recipient, { description = message, type = 'success', duration = Config.NotifyDuration, position = 'center-right' })
        elseif type == "error" then
            TriggerClientEvent('ox_lib:notify', recipient, { description = message, type = 'error', duration = Config.NotifyDuration, position = 'center-right' })
        end
    end
end
