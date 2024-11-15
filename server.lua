
RegisterServerEvent('ic3d_banking:depositMoney')
AddEventHandler('ic3d_banking:depositMoney', function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)

    if amount > 0 then
        xPlayer.addAccountMoney('bank', amount)
        TriggerClientEvent('esx:showNotification', source, 'Amount deposited: $' .. amount)
        logTransaction(xPlayer.identifier, 'deposit', amount, nil) -- Log deposit transaction
    else
        TriggerClientEvent('esx:showNotification', source, 'Invalid amount.')
    end
end)

-- Register server event to handle withdrawals
RegisterServerEvent('ic3d_banking:withdrawMoney')
AddEventHandler('ic3d_banking:withdrawMoney', function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerMoney = xPlayer.getAccount('bank').money

    if amount > 0 and playerMoney >= amount then
        xPlayer.removeAccountMoney('bank', amount)
        xPlayer.addMoney(amount)
        TriggerClientEvent('esx:showNotification', source, 'Amount withdrawn: $' .. amount)
        logTransaction(xPlayer.identifier, 'withdraw', amount, nil) -- Log withdrawal transaction
    else
        TriggerClientEvent('esx:showNotification', source, 'Insufficient funds or invalid amount.')
    end
end)

-- Register server event to handle transfers
RegisterServerEvent('ic3d_banking:transferMoney')
AddEventHandler('ic3d_banking:transferMoney', function(targetId, amount)
    local sourcePlayer = ESX.GetPlayerFromId(source)
    local targetPlayer = ESX.GetPlayerFromId(targetId)

    if amount > 0 and sourcePlayer and targetPlayer then
        if sourcePlayer.getAccount('bank').money >= amount then
            sourcePlayer.removeAccountMoney('bank', amount)
            targetPlayer.addAccountMoney('bank', amount)
            TriggerClientEvent('esx:showNotification', source, 'Transfer successful: $' .. amount .. ' to ' .. GetPlayerName(targetId))
            TriggerClientEvent('esx:showNotification', targetId, 'Transfer received: $' .. amount .. ' from ' .. GetPlayerName(source))
            logTransaction(sourcePlayer.identifier, 'transfer', amount, targetPlayer.identifier) -- Log transfer transaction
            logTransaction(targetPlayer.identifier, 'received_transfer', amount, sourcePlayer.identifier) -- Log received transfer transaction
        else
            TriggerClientEvent('esx:showNotification', source, 'Insufficient funds for transfer.')
        end
    else
        TriggerClientEvent('esx:showNotification', source, 'Invalid transfer.')
    end
end)

function logTransaction(playerId, transactionType, amount, targetPlayerId)
    local playerId = playerId
    local transactionType = transactionType
    local amount = amount
    local targetPlayerId = targetPlayerId

    MySQL.Async.execute(
        'INSERT INTO bank_transactions (player_id, transaction_type, amount, target_player_id) VALUES (@playerId, @transactionType, @amount, @targetPlayerId)',
        {
            ['@playerId'] = playerId,
            ['@transactionType'] = transactionType,
            ['@amount'] = amount,
            ['@targetPlayerId'] = targetPlayerId
        },
        function(rowsChanged)
            if rowsChanged > 0 then
                print('Transaction logged successfully')
            else
                print('Failed to log transaction')
            end
        end
    )
end


-- Server callback to retrieve bank transactions
ESX.RegisterServerCallback('ic3d_banking:getBankTransactions', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local transactions = {}

    MySQL.Async.fetchAll('SELECT * FROM bank_transactions WHERE player_id = @playerId', {
        ['@playerId'] = xPlayer.identifier
    }, function(result)
        if result then
            for _, transaction in ipairs(result) do
                table.insert(transactions, {
                    transaction_type = transaction.transaction_type,
                    amount = transaction.amount
                })
            end
            cb(transactions)
        else
            cb(nil)
        end
    end)
end)