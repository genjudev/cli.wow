function CreateEditor(funcName)
    if funcName == nil then
        Log("No function name provided.")
        return
    end
    -- Frame for in-game editor
    local editorFrame = CreateFrame("Frame", "CLIAddonEditorFrame", UIParent, "BasicFrameTemplateWithInset")
    editorFrame:SetSize(800, 600)  -- Increase the size of the editor window
    editorFrame:SetPoint("CENTER")
    editorFrame:Hide()

    -- Title text for the editor
    editorFrame.title = editorFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    editorFrame.title:SetPoint("TOP", editorFrame, "TOP", 0, -10)
    editorFrame.title:SetText(funcName)

    -- Scrollable text frame for code display
    local scrollFrame = CreateFrame("ScrollFrame", nil, editorFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -40)  -- Adjust position for title
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 60)

    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetFontObject(Game18Font)

    editBox:SetWidth(scrollFrame:GetWidth() - 20)  -- Adjust width to fit within the scroll frame
    editBox:SetAutoFocus(true)
    editBox:SetScript("OnEscapePressed", function() editorFrame:Hide() end)

    scrollFrame:SetScrollChild(editBox)
    scrollFrame:EnableMouse(true)
    scrollFrame:SetScript("OnMouseDown", function()
        editBox:SetFocus()
    end)


    -- Save button
    local saveButton = CreateFrame("Button", nil, editorFrame, "GameMenuButtonTemplate")
    saveButton:SetSize(100, 30)
    saveButton:SetPoint("BOTTOM", 0, 10)
    saveButton:SetText("Save")
    -- Close editor on ESC key  
    tinsert(UISpecialFrames, editorFrame:GetName())

    saveButton:SetScript("OnClick", function()
        local funcCode = editBox:GetText()
        SaveFunctionCode(funcName, funcCode)
        editorFrame:Hide()
    end)

    return editorFrame, editBox, saveButton
end

function CreateReadOnlyEditor(funcName)
    if funcName == nil then
        Log("No function name provided.")
        return
    end

    -- Frame for in-game editor
    local editorFrame = CreateFrame("Frame", "CLIAddonReadOnlyEditorFrame", UIParent, "BasicFrameTemplateWithInset")
    editorFrame:SetSize(800, 600)  -- Increase the size of the editor window
    editorFrame:SetPoint("CENTER")
    editorFrame:Hide()

    -- Title text for the editor
    editorFrame.title = editorFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    editorFrame.title:SetPoint("TOP", editorFrame, "TOP", 0, -10)
    editorFrame.title:SetText("Export: " .. funcName)

    -- Scrollable text frame for code display
    local scrollFrame = CreateFrame("ScrollFrame", nil, editorFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -40)  -- Adjust position for title
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 60)

    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetFontObject(Game18Font)
    editBox:SetWidth(scrollFrame:GetWidth() - 20)  -- Adjust width to fit within the scroll frame
    editBox:SetAutoFocus(true)
    
    -- Make the EditBox read-only by disabling editing
    editBox:EnableMouse(true)  -- Allow mouse interaction
    editBox:SetScript("OnEscapePressed", function() editorFrame:Hide() end)

    -- Disable key input to prevent editing
    editBox:SetScript("OnKeyDown", function() end)
    editBox:SetScript("OnKeyUp", function() end)

    scrollFrame:SetScrollChild(editBox)
    scrollFrame:SetScrollChild(editBox)
    scrollFrame:EnableMouse(true)
    scrollFrame:SetScript("OnMouseDown", function()
        editBox:SetFocus()
    end)

    -- Close button
    local closeButton = CreateFrame("Button", nil, editorFrame, "GameMenuButtonTemplate")
    closeButton:SetSize(100, 30)
    closeButton:SetPoint("BOTTOM", 0, 10)
    closeButton:SetText("Close")

    closeButton:SetScript("OnClick", function()
        editorFrame:Hide()
    end)

    -- Close editor on ESC key
    tinsert(UISpecialFrames, editorFrame:GetName())

    return editorFrame, editBox
end

function CreateImportEditor(funcName)
    local title = funcName or "IMPORT"

    -- Frame for in-game editor
    local editorFrame = CreateFrame("Frame", "CLIAddonEditorFrame", UIParent, "BasicFrameTemplateWithInset")
    editorFrame:SetSize(800, 600)  -- Increase the size of the editor window
    editorFrame:SetPoint("CENTER")
    editorFrame:Hide()

    -- Title text for the editor
    editorFrame.title = editorFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    editorFrame.title:SetPoint("TOP", editorFrame, "TOP", 0, -10)
    editorFrame.title:SetText(title)

    -- Scrollable text frame for code display
    local scrollFrame = CreateFrame("ScrollFrame", nil, editorFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -40)  -- Adjust position for title
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 60)

    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetFontObject(Game18Font)

    editBox:SetWidth(scrollFrame:GetWidth() - 20)  -- Adjust width to fit within the scroll frame
    editBox:SetAutoFocus(true)
    editBox:SetScript("OnEscapePressed", function() editorFrame:Hide() end)

    scrollFrame:SetScrollChild(editBox)
    scrollFrame:EnableMouse(true)
    scrollFrame:SetScript("OnMouseDown", function()
        editBox:SetFocus()
    end)


    -- Save button
    local saveButton = CreateFrame("Button", nil, editorFrame, "GameMenuButtonTemplate")
    saveButton:SetSize(100, 30)
    saveButton:SetPoint("BOTTOM", 0, 10)
    saveButton:SetText("Save")
    -- Close editor on ESC key  
    tinsert(UISpecialFrames, editorFrame:GetName())

    saveButton:SetScript("OnClick", function()
        local b64Code = editBox:GetText()
        ImportFunction(b64Code, funcName)
        editorFrame:Hide()
    end)

    return editorFrame
end


