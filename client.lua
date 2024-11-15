local bankMenu = false
local notificationsEnabled = true

-- Function to open account summary menu
function openAccountSummary()
    ESX.TriggerServerCallback('ic3d_banking:getAccountSummary', function(accounts)
        local elements = {}

        for _, account in ipairs(accounts) do
            table.insert(elements, {
                label = account.label,
                value = account.value,
                type = 'item'
            })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'account_summary_menu', {
            title = 'Account Summary',
            align = 'top-right',
            elements = elements
        }, function(data, menu)
            -- Handle button clicks if needed
        end, function(data, menu)
            menu.close()
        end)
    end)
end



function openSettingsMenu()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'settings_menu', {
        title = 'Bank Settings',
        align = 'top-right',
        elements = {
            {label = 'Change PIN', value = 'change_pin'},
            {label = 'Toggle Notifications', value = 'toggle_notifications'},
            {label = 'Close', value = 'close'}
        }
    }, function(data, menu)
        if data.current.value == 'change_pin' then
            openChangePINMenu()
        elseif data.current.value == 'toggle_notifications' then
            toggleNotifications()
        elseif data.current.value == 'close' then
            menu.close()
        end
    end, function(data, menu)
        menu.close()
    end)
end

function toggleNotifications()
    notificationsEnabled = not notificationsEnabled

    if notificationsEnabled then
        ESX.ShowNotification('Notifications enabled')
    else
        ESX.ShowNotification('Notifications disabled')
    end
end

function openBankMenu()
    bankMenu = true

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'bank_menu',
        {
            title    = 'Bank',
            align    = 'top-right',
            elements = {
                {label = 'Deposit', value = 'deposit'},
                {label = 'Withdraw', value = 'withdraw'},
                {label = 'Transfer', value = 'transfer'},
                {label = 'Account Summary', value = 'account_summary'},
                {label = 'Settings', value = 'settings'},
                {label = 'Close', value = 'close'}
            }
        },
        function(data, menu)
            if data.current.value == 'deposit' then
                depositMoney()
            elseif data.current.value == 'withdraw' then
                withdrawMoney()
            elseif data.current.value == 'transfer' then
                transferMoney()
            elseif data.current.value == 'account_summary' then
                openAccountSummary()
            elseif data.current.value == 'settings' then
                openSettingsMenu()
            elseif data.current.value == 'close' then
                closeBankMenu()
            end
        end,
        function(data, menu)
            menu.close()
            bankMenu = false
        end
    )
end

-- Add transferMoney function
function transferMoney()
    local amount = KeyboardInput('Enter Amount', '', 10)
    if amount ~= nil then
        amount = tonumber(amount)
        if amount > 0 then
            local targetPlayer = KeyboardInput('Enter Player ID to Transfer', '', 10)
            if targetPlayer ~= nil then
                targetPlayer = tonumber(targetPlayer)
                TriggerServerEvent('ic3d_banking:transferMoney', targetPlayer, amount)
            else
                ESX.ShowNotification('Invalid player ID.')
            end
        else
            ESX.ShowNotification('Invalid amount.')
        end
    end
end

function depositMoney()
    local amount = KeyboardInput('Enter Amount', '', 10)

    if amount ~= nil then
        amount = tonumber(amount)
        if amount > 0 then
            TriggerServerEvent('ic3d_banking:depositMoney', amount)
        else
            ESX.ShowNotification('Invalid amount.')
        end
    end
end

function withdrawMoney()
    local amount = KeyboardInput('Enter Amount', '', 10)

    if amount ~= nil then
        amount = tonumber(amount)
        if amount > 0 then
            TriggerServerEvent('ic3d_banking:withdrawMoney', amount)
        else
            ESX.ShowNotification('Invalid amount.')
        end
    end
end

function closeBankMenu()
    ESX.UI.Menu.CloseAll()
    bankMenu = false
end

-- Helper function to create keyboard input dialog
function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)

	AddTextEntry(GetCurrentResourceName() .. '_Keyboard', TextEntry) --Sets the Text Entry
	DisplayOnscreenKeyboard(1, GetCurrentResourceName() .. '_Keyboard', '', ExampleText, '', '', '', MaxStringLenght) -- actually displays the text entry
	blockinput = true -- blocks new input while typing if **blockinput** is used

	-- While the player doesn't press Enter and hasn't cancelled the input
	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end

	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult() --Gets the result of the text entry

		Citizen.Wait(500) -- Wait a bit to avoid capturing an old keyboard event

		blockinput = false --Unblocks new input when typing is done
		return result --Returns the result
	else
		Citizen.Wait(500) -- Wait a bit to avoid capturing an old keyboard event
		blockinput = false --Unblocks new input when typing is done
		return nil --Returns nil if the player cancelled the text entry
	end
end

-- Open bank menu when player presses a key (e.g., F5)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, 318) then -- F5
            if not bankMenu then
                openBankMenu()
            end
        end
    end
end)

-- Function to view statistics
function viewStatistics()
    ESX.TriggerServerCallback('ic3d_banking:getBankTransactions', function(transactions)
        if transactions then
            OpenStatisticsMenu(transactions)
        else
            ESX.ShowNotification('Failed to retrieve transaction data.')
        end
    end)
end

-- Function to open statistics menu
function OpenStatisticsMenu(transactions)
    local elements = {}
    for _, transaction in ipairs(transactions) do
        local label = string.format('%s: $%s', transaction.transaction_type, transaction.amount)
        table.insert(elements, {
            label = label,
            value = transaction.value,
            type = 'item'
        })
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'statistics_menu', {
        title = 'Bank Transactions',
        align = 'top-right',
        elements = elements
    }, function(data, menu)
        -- Handle button clicks if needed
    end, function(data, menu)
        menu.close()
    end)
end

