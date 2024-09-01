UserFunctions = {}

function NewFunction(funcName, funcCode)
    if funcName == nil or funcCode == nil then
        Log("No function name or code provided.")
        return
    end

    if UserFunctions[funcName] then
        local i = 1
        while UserFunctions[funcName .. "_" .. i] do
            i = i + 1
        end
        funcName = funcName .. "_" .. i
    end

    SaveFunctionCode(funcName, funcCode)
end

function SaveFunctionCode(funcName, funcCode)
    if funcName == nil or funcCode == nil then
        Log("No function name or code provided.")
        return
    end
  
    local funcTable = {}
    funcTable.code = funcCode

    local loadSuccess, loadError = pcall(function()
        local funcEnv = setmetatable({}, { __index = _G }) 
        funcEnv.init, funcEnv.run, funcEnv.OnEvent = nil, nil, nil  

        local chunk = loadstring(funcCode, "Function_" .. funcName)  
        if chunk then
            setfenv(chunk, funcEnv) 
            chunk()  
         
            funcTable.init = funcEnv.init
            funcTable.run = funcEnv.run
            funcTable.OnEvent = funcEnv.OnEvent
        else
            error("Failed to compile function code for " .. funcName)
        end
    end)

    if loadSuccess then
        UserFunctions[funcName] = funcTable
        CLIDB[funcName] = { code = funcCode } 
        if funcTable.init then
            funcTable.init()
        end
        Log("Function '" .. funcName .. "' has been saved and loaded.")
    else
        Log("Error saving function '" .. funcName .. "': " .. loadError)
    end
end

function LoadFunctions()
    if CLIDB == nil then
        CLIDB = {}
    end

    local names = {}
    for name, funcData in pairs(CLIDB) do
        local funcTable = {}
        funcTable.code = funcData.code

        local loadSuccess, loadError = pcall(function()
            local funcEnv = setmetatable({}, { __index = _G }) 
            funcEnv.init, funcEnv.run, funcEnv.OnEvent = nil, nil, nil 

            local chunk = loadstring(funcTable.code, "Function_" .. name)  
            if chunk then
                setfenv(chunk, funcEnv) 
                chunk()  

                -- Assign the parsed functions to the table
                funcTable.init = funcEnv.init
                funcTable.run = funcEnv.run
                funcTable.OnEvent = funcEnv.OnEvent
            else
                error("Failed to compile function code for " .. name)
            end
        end)

        
        if loadSuccess then
            UserFunctions[name] = funcTable
            table.insert(names, name)
        else
            Log("Error loading function '" .. name .. "': " .. loadError)
        end
    end
    Log("Function(s) '" .. table.concat(names, ", ") .. "' has been loaded.")

end

function DeleteFunction(funcName)
    if funcName == nil then
        Log("No function name provided.")
        return
    end

    if UserFunctions[funcName] then
        UserFunctions[funcName] = nil
        CLIDB[funcName] = nil
        Log("Function '" .. funcName .. "' has been deleted.")
    else
        Log("Function '" .. funcName .. "' not found.")
    end
end

function ExportFunction(funcName)
    if funcName == nil then
        Log("No function name provided.")
        return
    end

    local funcTable = UserFunctions[funcName]
    if funcTable then
        local funcCode = funcTable.code
        if funcCode == nil then
            Log("No code found for function '" .. funcName .. "'")
            return
        end

        local exportCode = funcName .. "::" .. funcCode
        return to_base64(exportCode)
    else
        Log("Function '" .. funcName .. "' not found.")
    end
end

function ImportFunction(b64Code, funcName)
    if b64Code == nil then
        Log("No code provided.")
        return
    end

    local rawCode = from_base64(b64Code)
    if rawCode == nil then
        Log("Failed to decode code.")
        return
    end

    local nameToUse = funcName or b64Code:match("^(.-)::")
    local funcCode = rawCode:match("::(.+)$")

    if nameToUse == nil or funcCode == nil then
        Log("Invalid code format.")
        return
    end

    NewFunction(nameToUse, funcCode)
end



function to_base64(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

function from_base64(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end