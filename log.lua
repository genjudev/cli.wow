function Log(message)
    local whiteColor = "|cFFFFFFFF" -- White color code
    local orangeColor = "|cFFFFA500" -- Orange color code

    local formattedMessage = whiteColor .. "[CLI]: " .. orangeColor .. message .. "|r"

    print(formattedMessage)
end
