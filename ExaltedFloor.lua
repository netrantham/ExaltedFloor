local f = CreateFrame("Frame")

function f:OnEvent(event, ...)
	self[event](self, event, ...)
end

--used in PLAYER_DEAD compared to GetZoneText()
local dungNames = {"Brackenhide Hollow", "Dawn of the Infinite", "Freehold", "Halls of Infusion", "Neltharion's Lair", "Neltharus", "Uldaman", "The Underrot", "The Vortex Pinnacle"}
local bgNames = {"Arathi Basin", "Battle for Gilneas", "Deepwind Gorge", "Eye of the Storm", "Seething Shore", "Silvershard Mines", "Temple of Kotmogu", "Twin Peaks", "Warsong Gulch", "Alterac Valley", "Ashran","Battle for Wintergrasp","Isle of Conquest"}
--used to access the appropriate index in FloorDB.Dungeons, likely a better way
local indexNames = {"Brackenhide", "DawnInfinite", "Freehold", "HOI", "NelthLair", "Neltharus", "Uldaman", "Underrot", "Vortex"}
local bgIndexNames = {"Arathi", "Gilneas", "Deepwind", "EotS", "SeethingShore", "Silvershard", "Kotmogu", "TwinPeaks", "Warsong", "Alterac", "Ashran","Wintergrasp","IoC"}
function f:ADDON_LOADED(event, addOnName)
    if addOnName == "ExaltedFloor" then
        FloorDB = FloorDB or {}--initialize DB
        FloorDB.Raids = FloorDB.Raids or {Aberrus = 0}
        FloorDB.Dungeons = FloorDB.Dungeons or {Underrot = 0, Neltharus = 0, Brackenhide = 0, HOI = 0, Uldaman = 0, Freehold = 0, Vortex = 0, NelthLair = 0, DawnInfinite = 0}
        FloorDB.Bgs = FloorDB.Bgs or {Arathi = 0, Gilneas = 0, Deepwind = 0, EotS = 0, SeethingShore = 0, Silvershard = 0, Kotmogu = 0, TwinPeaks = 0, Warsong = 0, Alterac = 0, Ashran = 0,Wintergrasp = 0,IoC = 0}
        print("Floor loaded.")
    end
end

function f:PLAYER_DEAD()
    --If died in Aberrus then increase Aberrus Floor Rep
    if HasPetUI() == false then --Makes pets not count as multiple player deaths
        local deadInParty = 0
        zoneText = GetZoneText() --so GetZoneText isn't called repeatedly
        if zoneText == "Aberrus, the Shadowed Crucible" then
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
        end
        --check the dungeon list
        for i = 1, 9 do
            if zoneText == dungNames[i] then
                deadInParty = DeadInParty()
                local gain = addDungeonRep(i,deadInParty)
                DEFAULT_CHAT_FRAME:AddMessage("Reputation with "..dungNames[i].." floor increased by "..gain..".", 0.5,0.5,0.9)
            end
        end
        --check the battleground list, could save time by combining for loops but would slightly hurt readability
        for i = 1, 13 do
            if zoneText == bgNames[i] then
                --add flat rate of 50, bg deaths can be quite complex with a high variance in party members so I'm making the increment a flat rate
                FloorDB.Bgs[bgIndexNames[i]] = FloorDB.Bgs[bgIndexNames[i]] + 50
                DEFAULT_CHAT_FRAME:AddMessage("Reputation with "..bgNames[i].." floor increased by 50.", 0.5,0.5,0.9)
            end
        end
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

local scrollframe = CreateFrame("ScrollFrame", nil, insetFrame, "UIPanelScrollFrameTemplate");
scrollframe:SetPoint("TOPLEFT", insetFrame, 3, -4)
scrollframe:SetPoint("BOTTOMRIGHT", insetFrame, -27, 4)

local scrollChild = CreateFrame("Frame")
scrollframe:SetScrollChild(scrollChild)
scrollChild:SetWidth(330)
scrollChild:SetHeight(1)

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
local raidHeader = scrollChild:CreateFontString()
raidHeader:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
raidHeader:SetPoint("TOPLEFT", 25, -10)
raidHeader:SetTextColor(1, 0.82, 0, 1)
raidHeader:SetText("Raids")
local raidFrame = CreateFrame("Frame", nil, scrollChild)
raidFrame:SetPoint("TOPLEFT", 0, -25)
raidFrame:SetPoint("BOTTOMRIGHT", scrollChild, "TOPRIGHT", 0, -40)
local raidbtn = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
raidbtn:SetPoint("CENTER", raidHeader, "LEFT", -10 , 0)
raidbtn:SetSize(20,16)
raidbtn:SetText("-")
raidbtn:SetScript("OnClick",function(self,button)
    if raidbtn:GetText() == "+" then
        raidFrame:SetPoint("BOTTOMRIGHT", scrollChild, "TOPRIGHT", 0, -40)
        raidFrame:Show()
        raidbtn:SetText("-")
    else
        raidFrame:SetPoint("BOTTOMRIGHT", scrollChild, "TOPRIGHT", 0, -25)
        raidFrame:Hide()
        raidbtn:SetText("+")
    end
end)
--Rep Bar for Aberrus
local aberrusFloor = CreateFrame("Button", nil, raidFrame, "ReputationBarTemplate")
aberrusFloor:SetSize(270, 20)
aberrusFloor.Container:SetAllPoints()
aberrusFloor:SetPoint("TOPLEFT", scrollChild, 30, -25)
aberrusFloor.Container.ReputationBar:SetStatusBarColor(0, 1, 0)
aberrusFloor.Container.ReputationBar.BonusIcon:Hide()
aberrusFloor.Container.ReputationBar:SetFrameLevel(8) --so highlighting will appear above the bar
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
aberrusFloor:SetScript("OnClick", function(self)
end)

-------------------
--Dungeon Section--
-------------------
--Dungeon header and container for dungeon reputation bars
local dungHeader = scrollChild:CreateFontString()
dungHeader:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
dungHeader:SetPoint("TOPLEFT", raidFrame , "BOTTOMLEFT", 25, -10)
dungHeader:SetTextColor(1, 0.82, 0, 1)
dungHeader:SetText("Dungeons")
local dungFrame = CreateFrame("Frame", nil, scrollChild)
dungFrame:SetPoint("TOPLEFT", dungHeader, -25, 10)
dungFrame:SetPoint("BOTTOMRIGHT", dungHeader, "TOPRIGHT", 0, -205)
local dungbtn = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
dungbtn:SetPoint("CENTER", dungHeader, "LEFT", -10 , 0)
dungbtn:SetSize(20,16)
dungbtn:SetText("-")
dungbtn:SetScript("OnClick",function(self,button)
    if dungbtn:GetText() == "+" then
        dungFrame:SetPoint("BOTTOMRIGHT", dungHeader, "TOPRIGHT", 0, -205)
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
    dungBars[i] = CreateFrame("Button", nil, dungFrame, "ReputationBarTemplate")
    dungBars[i]:SetSize(270, 20)
    dungBars[i].Container:SetAllPoints()
    dungBars[i]:SetPoint("TOPLEFT", dungFrame, 30, -25*i)
    dungBars[i].Container.ReputationBar:SetStatusBarColor(0, 1, 0)
    dungBars[i].Container.ReputationBar.BonusIcon:Hide()
    dungBars[i].Container.ReputationBar:SetFrameLevel(8)
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
    dungBars[i]:SetScript("OnClick", function(self)
    end)
end

-------------------
--Battlegrounds Section--
-------------------
--Battlegrounds header and container for battlegrounds reputation bars
local bgHeader = scrollChild:CreateFontString()
bgHeader:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
bgHeader:SetPoint("TOPLEFT", dungFrame , "BOTTOMLEFT", 25, -35)
bgHeader:SetTextColor(1, 0.82, 0, 1)
bgHeader:SetText("Battlegrounds")
local bgFrame = CreateFrame("Frame", nil, scrollChild)
bgFrame:SetPoint("TOPLEFT", bgHeader, -25, 10)
bgFrame:SetPoint("BOTTOMRIGHT", scrollChild, "TOPRIGHT", 0, -305)
local bgbtn = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
bgbtn:SetPoint("CENTER", bgHeader, "LEFT", -10 , 0)
bgbtn:SetSize(20,16)
bgbtn:SetText("-")
bgbtn:SetScript("OnClick",function(self,button)
    if bgbtn:GetText() == "+" then
        bgFrame:SetPoint("BOTTOMRIGHT", scrollChild, "TOPRIGHT", 0, -305)
        bgFrame:Show()
        bgbtn:SetText("-")
    else
        bgFrame:SetPoint("BOTTOMRIGHT", bgHeader, "TOPRIGHT", 0, 10)
        bgFrame:Hide()
        bgbtn:SetText("+")
    end
end)
--Rep Bars for battlegrounds
local bgBars = {}
for i = 1, 13 do
    bgBars[i] = CreateFrame("Button", nil, bgFrame, "ReputationBarTemplate")
    bgBars[i]:SetSize(270, 20)
    bgBars[i].Container:SetAllPoints()
    bgBars[i]:SetPoint("TOPLEFT", bgFrame, 30, -25*i)
    bgBars[i].Container.ReputationBar:SetStatusBarColor(0, 1, 0)
    bgBars[i].Container.ReputationBar.BonusIcon:Hide()
    bgBars[i].Container.ReputationBar:SetFrameLevel(8)
    bgBars[i].Container.ExpandOrCollapseButton:Hide()
    bgBars[i].Container.Paragon:Hide()
    bgBars[i].Container.Name:SetText("    "..bgNames[i])
    bgBars[i]:SetScript("OnEnter", function(self)
        local _, barvalue, barmax = repStanding(FloorDB.Bgs[bgIndexNames[i]])
        self.Container.ReputationBar.FactionStanding:SetText(barvalue.."/"..barmax)
        self.Container.ReputationBar.Highlight1:Show()
        self.Container.ReputationBar.Highlight2:Show()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetText(self.Container.Name:GetText(), nil, nil, nil, nil, true);
        GameTooltip:Show();
    end)
    bgBars[i]:SetScript("OnLeave", function(self)
        local standing, barvalue, barmax = repStanding(FloorDB.Bgs[bgIndexNames[i]])
        self.Container.ReputationBar.FactionStanding:SetText(standing)
        self.Container.ReputationBar:SetValue(barvalue/barmax)
        self.Container.ReputationBar.Highlight1:Hide()
        self.Container.ReputationBar.Highlight2:Hide()
        GameTooltip:Hide()
    end)
    bgBars[i]:SetScript("OnClick", function(self)
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
    for i = 1, 13 do
        if i <= 9 then
            standing, barvalue, barmax = repStanding(FloorDB.Dungeons[indexNames[i]])
            dungBars[i].Container.ReputationBar.FactionStanding:SetText(standing)
            dungBars[i].Container.ReputationBar:SetValue(barvalue/barmax)
        end
        standing, barvalue, barmax = repStanding(FloorDB.Bgs[bgIndexNames[i]])
        bgBars[i].Container.ReputationBar.FactionStanding:SetText(standing)
        bgBars[i].Container.ReputationBar:SetValue(barvalue/barmax)
    end
    floorsFrame:Show()
end)

