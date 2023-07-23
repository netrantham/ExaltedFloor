local f = CreateFrame("Frame")

function f:OnEvent(event, ...)
	self[event](self, event, ...)
end

function f:ADDON_LOADED(event, addOnName)
    if addOnName == "ExaltedFloor" then
        FloorDB = FloorDB or {}--initialize DB
        FloorDB.Raids = FloorDB.Raids or {}
        FloorDB.Raids.Aberrus = FloorDB.Raids.Aberrus or 0
	    print("Floor loaded.")
    end
end

function f:PLAYER_DEAD(self, event)
    --If died in Aberrus then increase Aberrus Floor Rep
    if GetZoneText() == "Aberrus, the Shadowed Crucible" then
        --loop through raid group, if a member is dead increment deadParty
        local deadInParty = DeadInParty()
        --increase rep based on amount of deadParty members
        if deadInParty == 1 then--1st death in party = 100 rep
            FloorDB.Raids.Aberrus = FloorDB.Raids.Aberrus + 100
            DEFAULT_CHAT_FRAME:AddMessage("Reputation with Aberrus floor increased by 100.", 0.5,0.5,0.9)
        elseif deadInParty == 2 then--2nd death in party = 60 rep
            FloorDB.Raids.Aberrus = FloorDB.Raids.Aberrus + 60
            DEFAULT_CHAT_FRAME:AddMessage("Reputation with Aberrus floor increased by 60.", 0.5,0.5,0.9)
        elseif deadInParty < 6 then--3rd, 4th, 5th death in party = 40 rep
            FloorDB.Raids.Aberrus = FloorDB.Raids.Aberrus + 40
            DEFAULT_CHAT_FRAME:AddMessage("Reputation with Aberrus floor increased by 40.", 0.5,0.5,0.9)
        else--else = 20 rep
            FloorDB.Raids.Aberrus = FloorDB.Raids.Aberrus + 20
            DEFAULT_CHAT_FRAME:AddMessage("Reputation with Aberrus floor increased by 20.", 0.5,0.5,0.9)
        end
    end
end

--returns the amount of dead players in the party
function DeadInParty()
    local deadParty = 0
    for i = 1, MAX_RAID_MEMBERS do
        local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(i)
        if isDead then
            deadParty = deadParty + 1
        end
    end
    return deadParty
end

--returns the reputation standing, barvalue, and barmax
function repStanding(repValue)
    local barvalue = 0
    if repValue < 3000 then
        return "Neutral", repValue, 3000
    elseif repValue < 9000 then
        barValue = repValue - 3000
        return "Friendly", barValue, 6000
    elseif repValue < 21000 then
        barValue = repValue - 9000
        return "Honored", barValue, 12000
    elseif repValue < 42000 then
        barValue = repValue - 21000
        return "Revered", barValue, 21000
    elseif repValue < 52000 then
        barValue = repValue - 42000
        return "Exalted", barValue, 52000
    else
        return "Floor Bros", 1, 1
    end
end


f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_DEAD")
f:SetScript("OnEvent", f.OnEvent)



--UI Elements-----------------------------------------------------------------------------------------------------------------------------------------------------------------
--Base frame
local floorsFrame = CreateFrame("Frame", nil, ReputationFrame, "BasicFrameTemplate")
floorsFrame:SetPoint("TOPLEFT", ReputationFrame, "TOPRIGHT", 1, 0)
floorsFrame:SetPoint("BOTTOMRIGHT", ReputationFrame, 341, 0)
local insetFrame = CreateFrame("Frame", nil, floorsFrame, "InsetFrameTemplate")
insetFrame:SetPoint("TOPLEFT", floorsFrame, 4, -60)
insetFrame:SetPoint("BOTTOMRIGHT", floorsFrame, -6, 4)
insetFrame.Background = insetFrame:CreateTexture(nil, "BACKGROUND")
insetFrame.Background:SetTexture("Interface\\FrameGeneral\\UI-Background-Marble.PNG")
insetFrame.Background:SetAllPoints()
--hide floors by default
floorsFrame:Hide()


--text on base frame
local Header = floorsFrame:CreateFontString()
Header:SetFont("Fonts\\FRIZQT__.TTF", 12, "GameFontWhite")
Header:SetPoint("TOP", 0, -6)
Header:SetText("Floor Reputations")
local factionHeader = floorsFrame:CreateFontString()
factionHeader:SetFont("Fonts\\FRIZQT__.TTF", 12, "GameFontWhite")
factionHeader:SetPoint("TOPLEFT", 62, -40)
factionHeader:SetText("Floor")
local standingHeader = floorsFrame:CreateFontString()
standingHeader:SetFont("Fonts\\FRIZQT__.TTF", 12, "GameFontWhite")
standingHeader:SetPoint("TOPRIGHT", -62, -40)
standingHeader:SetText("Standing?")


--Raid reputation bars
local raidHeader = insetFrame:CreateFontString()
raidHeader:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
raidHeader:SetPoint("TOPLEFT", 25, -10)
raidHeader:SetTextColor(1, 0.82, 0, 1)
raidHeader:SetText("Raids")
local raidFrame = CreateFrame("Frame", nil, insetFrame)
raidFrame:SetPoint("TOPLEFT", 0, -25)
raidFrame:SetPoint("BOTTOMRIGHT", insetFrame, "TOPRIGHT", 0, -40)
local raidbtn = CreateFrame("Button", nil, insetFrame, "UIPanelButtonTemplate")
raidbtn:SetPoint("CENTER", raidHeader, "LEFT", -10 , 0)
raidbtn:SetSize(20,16)
raidbtn:SetText("-")
raidbtn:SetScript("OnClick",function(self,button)
    if raidbtn:GetText() == "+" then
        raidFrame:SetPoint("BOTTOMRIGHT", insetFrame, "TOPRIGHT", 0, -40)
        raidFrame:Show()
        raidbtn:SetText("-")
    else
        raidFrame:SetPoint("BOTTOMRIGHT", insetFrame, "TOPRIGHT", 0, -25)
        raidFrame:Hide()
        raidbtn:SetText("+")
    end
end)

--Raid Rep Bar for Aberrus
local aberrusFloor = CreateFrame("Frame", nil, raidFrame, "ReputationBarTemplate")
aberrusFloor:SetSize(270, 20)
aberrusFloor.Container:SetAllPoints()
aberrusFloor:SetPoint("TOPLEFT", insetFrame, 30, -25)
aberrusFloor.Container.ReputationBar:SetStatusBarColor(0, 1, 0)
aberrusFloor.Container.ReputationBar.BonusIcon:Hide()
aberrusFloor.Container.ExpandOrCollapseButton:Hide()
aberrusFloor.Container.Paragon:Hide()
aberrusFloor.Container.Name:SetText("    Aberrus, the Shadowed Floor")
aberrusFloor:SetScript("OnEnter", function(self)
    local _, barvalue, barmax = repStanding(FloorDB.Raids.Aberrus)
    self.Container.ReputationBar.FactionStanding:SetText(barvalue.."/"..barmax)
    self.Container.ReputationBar.Highlight1:Show()
    self.Container.ReputationBar.Highlight2:Show()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(self.Container.Name:GetText(), nil, nil, nil, nil, true);
    GameTooltip:Show();
end)
aberrusFloor:SetScript("OnLeave", function(self)
    local standing, barvalue, barmax = repStanding(FloorDB.Raids.Aberrus)
    self.Container.ReputationBar.FactionStanding:SetText(standing)
    aberrusFloor.Container.ReputationBar:SetValue(barvalue/barmax)
    self.Container.ReputationBar.Highlight1:Hide()
    self.Container.ReputationBar.Highlight2:Hide()
    GameTooltip:Hide()
end)


--Dungeon reputation bars
local dungHeader = insetFrame:CreateFontString()
dungHeader:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
dungHeader:SetPoint("TOPLEFT", raidFrame , "BOTTOMLEFT", 25, -10)
dungHeader:SetTextColor(1, 0.82, 0, 1)
dungHeader:SetText("Dungeons")
local dungFrame = CreateFrame("Frame", nil, insetFrame)
dungFrame:SetPoint("TOPLEFT", 0, -40)
dungFrame:SetPoint("TOPRIGHT", 0, -55)
local dungbtn = CreateFrame("Button", nil, insetFrame, "UIPanelButtonTemplate")
dungbtn:SetPoint("CENTER", dungHeader, "LEFT", -10 , 0)
dungbtn:SetSize(20,16)
dungbtn:SetText("-")
dungbtn:SetScript("OnClick",function(self,button)
    if dungbtn:GetText() == "+" then
        dungFrame:SetPoint("BOTTOMRIGHT", insetFrame, "TOPRIGHT", 0, -55)
        dungFrame:Show()
        dungbtn:SetText("-")
    else
        dungFrame:SetPoint("BOTTOMRIGHT", insetFrame, "TOPRIGHT", 0, -40)
        dungFrame:Hide()
        dungbtn:SetText("+")
    end
end)


--open button for the base frame (located on reputationframe) and update reps
local btn = CreateFrame("Button", nil, ReputationFrame, "UIPanelButtonTemplate")
btn:SetPoint("TOPRIGHT", -6 , -21)
btn:SetSize(50,40)
btn:SetText("Floors")
btn:SetScript("OnClick",function(self,button)
    local standing, barvalue, barmax = repStanding(FloorDB.Raids.Aberrus)
    aberrusFloor.Container.ReputationBar.FactionStanding:SetText(standing)
    aberrusFloor.Container.ReputationBar:SetValue(barvalue/barmax)

    floorsFrame:Show()
end)
