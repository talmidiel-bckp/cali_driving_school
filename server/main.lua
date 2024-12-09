-- Check if the player has enough money for the chosen license, and deduct the price from account
ESX.RegisterServerCallback('cali_driving_school:playerHasEnoughMoney', function(source, callback, price, title)
    local player = ESX.GetPlayerFromId(source)

    if player.getAccount('bank').money >= price then
        player.removeAccountMoney('bank', price, string.format(_G.Messages.bankMessage, title))
        callback(true)
    elseif player.getAccount('money').money >= price then
        player.removeAccountMoney('money', price)
        callback(true)
    else
        callback(false)
    end
end)

-- Give the license to the player in db
RegisterNetEvent('cali_driving_school:addLicense')
AddEventHandler('cali_driving_school:addLicense', function(license)
    local source = source

    TriggerEvent('esx_license:addLicense', source, license)
end)
