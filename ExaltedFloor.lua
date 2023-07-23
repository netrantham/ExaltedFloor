local f = CreateFrame("Frame")

function f:OnEvent(event, ...)
	self[event](self, event, ...)
end

--used in PLAYER_DEAD compared to GetZoneText()
local dungNames = {"The Underrot", "Neltharus", "Brackenhide Hollow", "Halls of Infusion", "Uldaman", "Freehold", "The Vortex Pinnacle", "Neltharion's Lair", "Dawn of the Infinite"}
--used to access the appropriate index in FloorDB.Dungeons, likely a better way
local indexNames = {"Underrot", "Neltharus", "Brackenhide", "HOI", "Uldaman", "Freehold", "Vortex", "NelthLair", "DawnInfinite"}
function f:ADDON_LOADED(event, addOnName)
    if addOnName == "ExaltedFloor" then
        FloorDB = FloorDB or {}--initialize DB
        FloorDB.Raids = FloorDB.Raids or {Aberrus = 0}
        FloorDB.Dungeons = FloorDB.Dungeons or {Underrot = 0, Neltharus = 0, Brackenhide = 0, HOI = 0, Uldaman = 0, Freehold = 0, Vortex = 0, NelthLair = 0, DawnInfinite = 0}
        print("Floor loaded.")
    end
end

function f:PLAYER_DEAD(self, event)
    --If died in Aberrus then increase Aberrus Floor Rep
    local deadInParty = 0
    if GetZoneText() == "Aberrus, the Shadowed Crucible" then
        --loop through raid group, if a member is dead increment deadParty
        deadInParty = DeadInParty()
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
    elseif GetZoneText() == "The Underrot" then
        deadInParty = DeadInParty()
        local gain = addDungeonRep(1,deadInParty)
        DEFAULT_CHAT_FRAME:AddMessage("Reputation with "..dungNames[1].." floor increased by 20.", 0.5,0.5,0.9)
    elseif GetZoneText() == "Neltharus" then
        deadInParty = DeadInParty()
        local gain = addDungeonRep(2,deadInParty)
        DEFAULT_CHAT_FRAME:AddMessage("Reputation with "..dungNames[2].." floor increased by "..gain..".", 0.5,0.5,0.9)
    elseif GetZoneText() == "Brackenhide Hollow" then
        deadInParty = DeadInParty()
        local gain = addDungeonRep(3,deadInParty)
        DEFAULT_CHAT_FRAME:AddMessage("Reputation with "..dungNames[3].." floor increased by "..gain..".", 0.5,0.5,0.9)        
    elseif GetZoneText() == "Halls of Infusion" then
        deadInParty = DeadInParty()
        local gain = addDungeonRep(4,deadInParty)
        DEFAULT_CHAT_FRAME:AddMessage("Reputation with "..dungNames[4].." floor increased by "..gain..".", 0.5,0.5,0.9)
    elseif GetZoneText() == "Uldaman" then
        deadInParty = DeadInParty()
        local gain = addDungeonRep(5,deadInParty)
        DEFAULT_CHAT_FRAME:AddMessage("Reputation with "..dungNames[5].." floor increased by "..gain..".", 0.5,0.5,0.9)
    elseif GetZoneText() == "Freehold" then
        deadInParty = DeadInParty()
        local gain = addDungeonRep(6,deadInParty)
        DEFAULT_CHAT_FRAME:AddMessage("Reputation with "..dungNames[6].." floor increased by "..gain..".", 0.5,0.5,0.9)
    elseif GetZoneText() == "The Vortex Pinnacle" then
        deadInParty = DeadInParty()
        local gain = addDungeonRep(7,deadInParty)
        DEFAULT_CHAT_FRAME:AddMessage("Reputation with "..dungNames[7].." floor increased by "..gain..".", 0.5,0.5,0.9)
    elseif GetZoneText() == "Neltharion's Lair" then
        deadInParty = DeadInParty()
        local gain = addDungeonRep(8,deadInParty)
        DEFAULT_CHAT_FRAME:AddMessage("Reputation with "..dungNames[8].." floor increased by "..gain..".", 0.5,0.5,0.9)
    elseif GetZoneText() == "Dawn of the Infinite" then
        deadInParty = DeadInParty()
        local gain = addDungeonRep(9,deadInParty)
        DEFAULT_CHAT_FRAME:AddMessage("Reputation with "..dungNames[9].." floor increased by "..gain..".", 0.5,0.5,0.9)
    end
end

--Reduces amount of lines needed to type, increases dungeon rep and returns the rep increase amount
function addDungeonRep(index, dead)
    if dead == 1 then--1st death in party = 100 rep
        FloorDB.Dungeons[indexNames[index]] = FloorDB.Dungeons[indexNames[index]] + 100
        return 100
    elseif dead == 2 then--2nd death in party = 60 rep
        FloorDB.Dungeons[indexNames[index]] = FloorDB.Dungeons[indexNames[index]] + 60
        return 60
    else--else = 30 rep
        FloorDB.Dungeons[indexNames[index]] = FloorDB.Dungeons[indexNames[index]] + 30
        return 30
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


--------------
--UI Section--
--------------
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

-----------------
--Raids Section--
-----------------
--Raids header and container for raids reputation bars
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
--Rep Bar for Aberrus
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

-------------------
--Dungeon Section--
-------------------
--Dungeon header and container for dungeon reputation bars
local dungHeader = insetFrame:CreateFontString()
dungHeader:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
dungHeader:SetPoint("TOPLEFT", raidFrame , "BOTTOMLEFT", 25, -10)
dungHeader:SetTextColor(1, 0.82, 0, 1)
dungHeader:SetText("Dungeons")
local dungFrame = CreateFrame("Frame", nil, insetFrame)
dungFrame:SetPoint("TOPLEFT", dungHeader, -25, 10)
dungFrame:SetPoint("BOTTOMRIGHT", insetFrame, "TOPRIGHT", 0, -185)
local dungbtn = CreateFrame("Button", nil, insetFrame, "UIPanelButtonTemplate")
dungbtn:SetPoint("CENTER", dungHeader, "LEFT", -10 , 0)
dungbtn:SetSize(20,16)
dungbtn:SetText("-")
dungbtn:SetScript("OnClick",function(self,button)
    if dungbtn:GetText() == "+" then
        dungFrame:SetPoint("BOTTOMRIGHT", insetFrame, "TOPRIGHT", 0, -185)
        dungFrame:Show()
        dungbtn:SetText("-")
    else
        dungFrame:SetPoint("BOTTOMRIGHT", dungHeader, "TOPRIGHT", 0, 10)
        dungFrame:Hide()
        dungbtn:SetText("+")
    end
end)
--Rep Bars for the dungeons
local dungBars = {}
for i = 1, 9 do
    dungBars[i] = CreateFrame("Frame", nil, dungFrame, "ReputationBarTemplate")
    dungBars[i]:SetSize(270, 20)
    dungBars[i].Container:SetAllPoints()
    dungBars[i]:SetPoint("TOPLEFT", dungFrame, 30, -25*i)
    dungBars[i].Container.ReputationBar:SetStatusBarColor(0, 1, 0)
    dungBars[i].Container.ReputationBar.BonusIcon:Hide()
    dungBars[i].Container.ExpandOrCollapseButton:Hide()
    dungBars[i].Container.Paragon:Hide()
    dungBars[i].Container.Name:SetText("    "..dungNames[i])
    dungBars[i]:SetScript("OnEnter", function(self)
        local _, barvalue, barmax = repStanding(FloorDB.Dungeons[indexNames[i]])
        self.Container.ReputationBar.FactionStanding:SetText(barvalue.."/"..barmax)
        self.Container.ReputationBar.Highlight1:Show()
        self.Container.ReputationBar.Highlight2:Show()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetText(self.Container.Name:GetText(), nil, nil, nil, nil, true);
        GameTooltip:Show();
    end)
    dungBars[i]:SetScript("OnLeave", function(self)
        local standing, barvalue, barmax = repStanding(FloorDB.Dungeons[indexNames[i]])
        self.Container.ReputationBar.FactionStanding:SetText(standing)
        self.Container.ReputationBar:SetValue(barvalue/barmax)
        self.Container.ReputationBar.Highlight1:Hide()
        self.Container.ReputationBar.Highlight2:Hide()
        GameTooltip:Hide()
    end)
end



--open button for the base frame (located on reputationframe) and update reps
local btn = CreateFrame("Button", nil, ReputationFrame, "UIPanelButtonTemplate")
btn:SetPoint("TOPRIGHT", -6 , -21)
btn:SetSize(50,40)
btn:SetText("Floors")
btn:SetScript("OnClick",function(self,button)
    local standing, barvalue, barmax = repStanding(FloorDB.Raids.Aberrus)
    aberrusFloor.Container.ReputationBar.FactionStanding:SetText(standing)
    aberrusFloor.Container.ReputationBar:SetValue(barvalue/barmax)
    for i = 1, 9 do
        standing, barvalue, barmax = repStanding(FloorDB.Dungeons[indexNames[i]])
        dungBars[i].Container.ReputationBar.FactionStanding:SetText(standing)
        dungBars[i].Container.ReputationBar:SetValue(barvalue/barmax)
    end
    floorsFrame:Show()
end)

