local lastPosition = nil
TriggerEvent('chat:addSuggestion', '/clockin', 'Clock in as a staff member', {})
TriggerEvent('chat:addSuggestion', '/clockout', 'Clock out as a staff member', {})

RegisterNetEvent("showAFKDialog")
AddEventHandler("showAFKDialog", function(afkTimeout)
    local alert = lib.alertDialog({
        header = 'Staff API',
        content = 'You have been clocked in and inactive for more than ' .. (afkTimeout / 60) .. ' minutes. You have been clocked out.',
        centered = true,
        cancel = false
    })
end)

RegisterNetEvent("checkPlayerMovement")
AddEventHandler("checkPlayerMovement", function()
    local ped = PlayerPedId()
    local currentPosition = GetEntityCoords(ped)
    
    if lastPosition and #(currentPosition - lastPosition) > 0.1 then
        TriggerServerEvent("playerMoved")
    end
    lastPosition = currentPosition
end)
