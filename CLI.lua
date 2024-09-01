local eventFunctions = {}
local evt = CreateFrame("Frame")
evt:RegisterEvent("ADDON_LOADED")

local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" and ... == "CLI" then
        Log("loaded.")

        LoadFunctions()
        for name, funcTable in pairs(UserFunctions) do
            if funcTable.init then
                funcTable.init()
            else
                Log("No init function found for '" .. name .. "'")
            end
        end
    else
        if eventFunctions[event] then
            for _, funcName in ipairs(eventFunctions[event]) do
                local funcTable = UserFunctions[funcName]
                if funcTable and funcTable.OnEvent then
                    local success, err = pcall(funcTable.OnEvent, ...)
                    if not success then
                        Log("Error in user-defined function '" .. funcName .. "' for event '" .. event .. "': " .. err)
                    end
                else
                    Log("Function '" .. funcName .. "' does not have an OnEvent handler.")
                end
            end
        end
    end
end

evt:SetScript("OnEvent", OnEvent)

local function OpenEditor(funcName)
    editorFrame, editBox, saveButton = CreateEditor(funcName)

    local funcTable = UserFunctions[funcName]

    if funcTable and funcTable.code then
        editBox:SetText(funcTable.code)  
    else
        local templateCode = "function init()\n  -- Initialization code here\nend\n\nfunction run()\n  -- Code to run when /cli run <function_name> is called\nend\n\nfunction OnEvent(self, event, ...)\n  -- Code to handle events if needed\nend"
        editBox:SetText(templateCode)  
    end

    editorFrame:Show()
end

local function OpenExportEditor(funcName)
    editorFrame, editBox = CreateReadOnlyEditor(funcName)

    local exportCode = ExportFunction(funcName)

    if exportCode then
        editBox:SetText(exportCode) 
        editorFrame:Show()
    end

end

local function OpenImportEditor(funcName)
    editorFrame = CreateImportEditor(funcName)
    editorFrame:Show()
end


SLASH_CLIFUNCTION1 = "/cli"
SlashCmdList["CLIFUNCTION"] = function(msg)
    local command, funcName = strsplit(" ", msg, 2)

    if command == "create" then
        OpenEditor(funcName) 
    elseif command == "edit" then
        OpenEditor(funcName)  
    elseif command == "export" then
        OpenExportEditor(funcName)
    elseif command == "import" then
        OpenImportEditor(funcName)
    elseif command == "delete" then
        DeleteFunction(funcName)
    
    elseif command == "run" then
        if UserFunctions[funcName] and UserFunctions[funcName].run then
            local success, errorMsg = pcall(UserFunctions[funcName].run)
            if success then
                Log("Function '" .. funcName .. "' executed.")
            else
                Log("Error executing function '" .. funcName .. "': " .. errorMsg)
            end
        else
            Log("Function '" .. funcName .. "' not found or has no run function.")
        end
    elseif command == "list" then
        Log("User-defined functions:")
        for name, _ in pairs(UserFunctions) do
            Log("- " .. name)
        end
    else
        Log("Usage:")
        Log("/cli create <function_name> - Creates a new function with init(), run(), and OnEvent().")
        Log("/cli edit <function_name> - Opens the editor to edit an existing function.")
        Log("/cli run <function_name> - Runs the specified function's run() method.")
        Log("/cli list - Lists all user-defined functions.")
        Log("/cli export <function_name> - Export a function.")
        Log("/cli import [<function_name>] - Import a function.")
        Log("/cli delete <function_name> - Delete a specific function.")
    end
end
