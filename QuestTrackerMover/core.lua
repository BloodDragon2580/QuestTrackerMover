local QT = ObjectiveTrackerFrame
QT.ClearAllPoints = function() end
QT:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOM", 45, -5) 
QT.SetPoint = function() end
QT:SetMovable(true)
QT:SetUserPlaced(true)
QT:SetClampedToScreen(true)
QT:SetHeight(550)
QT:SetWidth(190)

local MoveQuestTracker = CreateFrame("Frame", nil, QT)  
MoveQuestTracker:SetHeight(15)
MoveQuestTracker:ClearAllPoints()
MoveQuestTracker:SetPoint("TOPLEFT", QT)
MoveQuestTracker:SetPoint("TOPRIGHT", QT)
MoveQuestTracker:EnableMouse(true)
MoveQuestTracker:SetHitRectInsets(-5, -5, -5, -5)
MoveQuestTracker:RegisterForDrag("LeftButton")
MoveQuestTracker:SetScript("OnDragStart", function(self, button)
	if button=="LeftButton" and IsModifiedClick()then
		QT:StartMoving()
	end
end)
MoveQuestTracker:SetScript("OnDragStop", function(self, button)
	QT:StopMovingOrSizing()
end)