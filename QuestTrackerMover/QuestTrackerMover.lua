local addonName, addonTable = ...

local frame = CreateFrame("Frame", addonName, UIParent)

local questFrame = ObjectiveTrackerFrame

local borderFrame = CreateFrame("Frame", nil, questFrame, BackdropTemplateMixin and "BackdropTemplate")
borderFrame:SetFrameLevel(questFrame:GetFrameLevel() + 1)
borderFrame:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
})
borderFrame:SetBackdropBorderColor(1, 1, 0, 1)
borderFrame:SetAllPoints(questFrame)
borderFrame:Hide()

questFrame:SetMovable(true)
questFrame:EnableMouse(true)
questFrame:RegisterForDrag("LeftButton")
questFrame:SetClampedToScreen(true)

local isSettingPosition = false

questFrame:SetScript("OnDragStart", function(self)
    if IsShiftKeyDown() then
        self:StartMoving()
    end
end)

questFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
    QuestTrackerMoverDB = { point, relativePoint, xOfs, yOfs }
end)

questFrame:HookScript("OnEnter", function()
    if IsShiftKeyDown() then
        borderFrame:Show()
    end
end)

questFrame:HookScript("OnLeave", function()
    borderFrame:Hide()
end)

frame:SetScript("OnUpdate", function()
    if not IsShiftKeyDown() then
        borderFrame:Hide()
    end
end)

local function RestorePosition()
    if QuestTrackerMoverDB then
        local point, relativePoint, xOfs, yOfs = unpack(QuestTrackerMoverDB)
        isSettingPosition = true
        questFrame:ClearAllPoints()
        questFrame:SetPoint(point, UIParent, relativePoint, xOfs, yOfs)
        isSettingPosition = false
    else
        isSettingPosition = true
        questFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -50, -200)
        isSettingPosition = false
    end
end

hooksecurefunc(questFrame, "SetPoint", function()
    if not isSettingPosition then
        RestorePosition()
    end
end)

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        RestorePosition()
    elseif event == "PLAYER_ENTERING_WORLD" then
        RestorePosition()
    end
end)
