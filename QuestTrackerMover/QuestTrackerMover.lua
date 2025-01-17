local addonName, addonTable = ...

-- Lokalisierungstabelle
local L = {}
local locale = GetLocale()

-- Deutsche Übersetzung
if locale == "deDE" then
    L["RESET_POSITION"] = "Position wurde zurückgesetzt."
    L["BORDER_COLOR_CHANGED"] = "Rahmenfarbe geändert."
    L["FRAME_SHOWN"] = "Rahmen angezeigt. Halte SHIFT, um zu verschieben."
    L["COMMANDS"] = "QuestTrackerMover Befehle:"
    L["COMMAND_RESET"] = "/qtm reset - Setzt die Position auf Standard zurück."
    L["COMMAND_COLOR"] = "/qtm color [r] [g] [b] [a] - Ändert die Rahmenfarbe."
    L["COMMAND_SHOW"] = "/qtm show - Zeigt den Rahmen an."
-- Englische Übersetzung (Standard)
else
    L["RESET_POSITION"] = "Position has been reset."
    L["BORDER_COLOR_CHANGED"] = "Border color changed."
    L["FRAME_SHOWN"] = "Frame shown. Hold SHIFT to move."
    L["COMMANDS"] = "QuestTrackerMover Commands:"
    L["COMMAND_RESET"] = "/qtm reset - Resets the position to default."
    L["COMMAND_COLOR"] = "/qtm color [r] [g] [b] [a] - Changes the border color."
    L["COMMAND_SHOW"] = "/qtm show - Shows the border frame."
end

-- Hauptframe für das Addon
local frame = CreateFrame("Frame", addonName, UIParent)
local questFrame = ObjectiveTrackerFrame

-- Rahmen für die visuelle Hervorhebung
local borderFrame = CreateFrame("Frame", nil, questFrame, BackdropTemplateMixin and "BackdropTemplate")
borderFrame:SetFrameLevel(questFrame:GetFrameLevel() + 1)
borderFrame:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
})
borderFrame:SetBackdropBorderColor(1, 1, 0, 1)
borderFrame:SetAllPoints(questFrame)
borderFrame:Hide()

-- QuestFrame Einstellungen
questFrame:SetMovable(true)
questFrame:EnableMouse(true)
questFrame:RegisterForDrag("LeftButton")
questFrame:SetClampedToScreen(true)

local isSettingPosition = false

-- Drag-Start-Ereignis mit visueller Rückmeldung
questFrame:SetScript("OnDragStart", function(self)
    if IsShiftKeyDown() then
        self:StartMoving()
        borderFrame:SetBackdropBorderColor(0, 1, 0, 1) -- Grün anzeigen
        borderFrame:Show()
    end
end)

-- Drag-Stopp-Ereignis
questFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    borderFrame:SetBackdropBorderColor(1, 1, 0, 1) -- Zurück zu Gelb
    borderFrame:Hide()

    -- Position speichern
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    QuestTrackerMoverDB = { point, relativePoint, xOfs, yOfs }
end)

-- Rahmenanzeige bei Mausbewegung
questFrame:HookScript("OnEnter", function()
    if IsShiftKeyDown() then
        borderFrame:Show()
    end
end)

questFrame:HookScript("OnLeave", function()
    borderFrame:Hide()
end)

-- Rahmen ausblenden, wenn Shift losgelassen wird
frame:SetScript("OnUpdate", function()
    if not IsShiftKeyDown() then
        borderFrame:Hide()
    end
end)

-- Position wiederherstellen
local function RestorePosition()
    if QuestTrackerMoverDB and type(QuestTrackerMoverDB) == "table" and #QuestTrackerMoverDB == 4 then
        local point, relativePoint, xOfs, yOfs = unpack(QuestTrackerMoverDB)
        isSettingPosition = true
        questFrame:ClearAllPoints()
        questFrame:SetPoint(point, UIParent, relativePoint, xOfs, yOfs)
        isSettingPosition = false
    else
        -- Standardposition, falls keine oder ungültige Daten vorliegen
        isSettingPosition = true
        questFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -50, -200)
        isSettingPosition = false
    end
end

-- Funktion zum Zurücksetzen der Position
local function ResetPositionToDefault()
    QuestTrackerMoverDB = nil
    RestorePosition()
end

-- Funktion zum Ändern der Rahmenfarbe
local function SetBorderColor(r, g, b, a)
    borderFrame:SetBackdropBorderColor(r, g, b, a or 1)
end

-- Hook, um unerwünschte Positionsänderungen zu verhindern
hooksecurefunc(questFrame, "SetPoint", function()
    if not isSettingPosition then
        RestorePosition()
    end
end)

-- Ereignisse für das Laden des Addons und das Betreten der Welt
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(_, event, arg1)
    if (event == "ADDON_LOADED" and arg1 == addonName) or event == "PLAYER_ENTERING_WORLD" then
        RestorePosition()
    end
end)

-- Slash-Commands hinzufügen
SLASH_QUESTTRACKERMOVER1 = "/qtm"
SlashCmdList["QUESTTRACKERMOVER"] = function(msg)
    local cmd, r, g, b, a = strsplit(" ", msg)
    if cmd == "reset" then
        ResetPositionToDefault()
        print("QuestTrackerMover: " .. L["RESET_POSITION"])
    elseif cmd == "color" and r and g and b then
        SetBorderColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a) or 1)
        print("QuestTrackerMover: " .. L["BORDER_COLOR_CHANGED"])
    elseif cmd == "show" then
        borderFrame:Show()
        print("QuestTrackerMover: " .. L["FRAME_SHOWN"])
    else
        print("QuestTrackerMover: " .. L["COMMANDS"])
        print(L["COMMAND_RESET"])
        print(L["COMMAND_COLOR"])
        print(L["COMMAND_SHOW"])
    end
end
