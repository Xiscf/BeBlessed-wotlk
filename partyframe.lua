local INDEX = UnitName("player").."-"..GetRealmName();



local STATE_UNKNOWN_TIME = 0
local STATE_COUNTDOWN = 1
local STATE_EXPIRED = 2

local textures = {
    ["Blessing of Might"] = "Interface\\ICONS\\Spell_Holy_FistOfJustice.blp",
    ["Greater Blessing of Might"] = "Interface\\ICONS\\Spell_Holy_GreaterBlessingofKings",
    
    ["Blessing of Wisdom"] = "Interface\\ICONS\\Spell_Holy_SealOfWisdom.blp",
    ["Greater Blessing of Wisdom"] = "Interface\\ICONS\\Spell_Holy_GreaterBlessingofWisdom",
    
    ["Blessing of Kings"] = "Interface\\ICONS\\Spell_Magic_MageArmor.blp",
    ["Greater Blessing of Kings"] = "Interface\\ICONS\\Spell_Magic_GreaterBlessingofKings.blp",
	 
    ["Blessing of Sanctuary"] = "Interface\\ICONS\\Spell_Nature_LightningShield.blp",
    ["Greater Blessing of Sanctuary"] = "Interface\\ICONS\\Spell_Holy_GreaterBlessingofSanctuary.blp";
}


local modes = {
    [0] = "Blessing of Might",
    [1] = "Greater Blessing of Might",
    [2] = "Blessing of Wisdom",
    [3] = "Greater Blessing of Wisdom",
    [4] = "Blessing of King",
    [5] = "Greater Blessing of King",
    [6] = "Blessing of Sanctuary",
    [7] = "Greater Blessing of Sanctuary",
}
local numModes = 4;

local unit_ids = {
    [0] = "player",
    [1] = "party1",
    [2] = "party2",
    [3] = "party3",
    [4] = "party4",
}

local class_color_rgb = {
    [0] = {r=0.3, g=0.3, b=0.3},      --None
    [1] = {r=0.78, g=0.61, b=0.43},   --Warrior
    [2] = {r=1.0, g=0.96, b=0.41},    --Rogue
    [3] = {r=1.0, g=1.0, b=1.0},      --Priest
    [4] = {r=1.0, g=0.49, b=0.04},    --Druid
    [5] = {r=0.96, g=0.55, b=0.73},   --Paladin
    [6] = {r=0.67, g=0.83, b=0.45},   --Hunter
    [7] = {r=0.41, g=0.80, b=0.94},   --Mage
    [8] = {r=0.58, g=0.51, b=0.79},   --Warlock
    [9] = {r=0.0, g=0.44, b=0.87},    --Shaman
    [10] = {r=0.77, g=0.12, b=0.23},  --Deathknight
}



local function loadPosition()
	if (type(BeBlessedData[INDEX].framePos) == "table") then
		BeBlessedFrame:SetPoint(
			BeBlessedData[INDEX].framePos.point,
			UIParent,
			BeBlessedData[INDEX].framePos.relativePoint,
			BeBlessedData[INDEX].framePos.x,
			BeBlessedData[INDEX].framePos.y
		);
	else
		BeBlessedFrame:SetPoint("CENTER");
	end
end

local function savePosition()
	BeBlessedData[INDEX].framePos = {};
	BeBlessedData[INDEX].framePos.point,
	BeBlessedData[INDEX].framePos.relativeFrame,
	BeBlessedData[INDEX].framePos.relativePoint,
	BeBlessedData[INDEX].framePos.x,
	BeBlessedData[INDEX].framePos.y = BeBlessedFrame:GetPoint();
end



local function UpdateAvailableSpells()
    local available = BeBlessed:GetAvailableSpells();
    modes = {};
    local i = 0;
    for k,v in pairs(available) do
        modes[i] = k;
        i = i + 1;
    end
    numModes = i-1;
end

local function UpdateMode(P, i)
    if not BeBlessed:InCombat() then
        UpdateAvailableSpells();
        if (not P.mode) then
            P.mode = 0;
        end
        if P.mode < 0 then
            P.mode = numModes;
        elseif P.mode > numModes then
            P.mode = 0;
        end
        BeBlessedData[INDEX].settings.modes[i] = P.mode;
        P:SetAttribute("spell", BeBlessed.toLocal[modes[P.mode]]);
    end
end



local function GetPlayersInParty()
    local n = GetNumGroupMembers();
    if n == 0 then
        return 0;
    else
        return n-1;
    end
end



function BeBlessed:CreateBuffFrame()
    local f = CreateFrame("Frame", "BeBlessedFrame", UIParent);
    f:SetWidth(100);
    f:SetHeight(22*5+20);
    f:SetMovable(true);
    loadPosition();
    UpdateAvailableSpells();

    --f.texture = f:CreateTexture();
    --f.texture:SetAllPoints(f);
    --f.texture:SetColorTexture(0,0,0,0.3);

    f:SetScript("OnMouseDown", function(self)
        self:StartMoving();
    end)
    f:SetScript("OnMouseUp", function(self)
        self:StopMovingOrSizing();
        savePosition();
    end)

    f.title = f:CreateFontString();
    f.title:SetFont("Fonts\\FRIZQT__.TTF",14,"OUTLINE");
    f.title:SetText("Be|cffF58CBABlessed|r");
    f.title:SetPoint("TOP", f, "TOP");

    f.buffs = {};

    for i = 0,4 do
        
        f.buffs[i] = CreateFrame("Button", nil, f, "SecureActionButtonTemplate");
        f.buffs[i].mode = BeBlessedData[INDEX].settings.modes[i];
        f.buffs[i].applied = 0;
        f.buffs[i].state = STATE_UNKNOWN_TIME;
        f.buffs[i]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -22*i- 20);
        f.buffs[i]:SetWidth(100)
        f.buffs[i]:SetHeight(20);
        f.buffs[i]:SetAttribute("type", "spell");
        f.buffs[i]:SetAttribute("spell", BeBlessed.toLocal[modes[f.buffs[i].mode]]);
        f.buffs[i]:SetAttribute("unit", unit_ids[i]);
       

        f.buffs[i].highlight = f.buffs[i]:CreateTexture(nil, "BACKGROUND");
        f.buffs[i].highlight:SetAllPoints(f.buffs[i]);
        f.buffs[i].highlight:SetColorTexture(1,1,0,0.1);

        f.buffs[i]:SetHighlightTexture(f.buffs[i].highlight);


        f.buffs[i].class = f.buffs[i]:CreateTexture();
        f.buffs[i].class:SetWidth(18);
        f.buffs[i].class:SetHeight(18);
        f.buffs[i].class:SetPoint("LEFT", f.buffs[i], "LEFT", 1, 0);
        f.buffs[i].class:SetTexture("Interface\\ICONS\\Spell_Holy_SealOfWisdom.blp");

        f.buffs[i].icon = f.buffs[i]:CreateTexture();
        f.buffs[i].icon:SetWidth(18);
        f.buffs[i].icon:SetHeight(18);
        f.buffs[i].icon:SetPoint("LEFT", f.buffs[i].class, "RIGHT", 1, 0);
        f.buffs[i].icon:SetTexture("Interface\\ICONS\\Spell_Holy_SealOfWisdom.blp");

        f.buffs[i].text = f.buffs[i]:CreateFontString(nil, "OVERLAY");
        f.buffs[i].text:SetFont("Fonts\\FRIZQT__.TTF",14,"OUTLINE");
        f.buffs[i].text:SetText("00:00");
        f.buffs[i].text:SetTextColor(1,0,0);
        f.buffs[i].text:SetPoint("LEFT", f.buffs[i].icon, "RIGHT", 5, 0)
        f.buffs[i].text:SetJustifyH("LEFT");

        
        f.buffs[i]:SetScript("OnMouseWheel", function(self,delta)
            if (BeBlessed:InCombat()) then 
                return
            end
            
            UpdateAvailableSpells();
            f.buffs[i].mode = f.buffs[i].mode + delta;
            if f.buffs[i].mode < 0 then
                f.buffs[i].mode = numModes;
            elseif f.buffs[i].mode > numModes then
                f.buffs[i].mode = 0;
            end
            BeBlessedData[INDEX].settings.modes[i] = f.buffs[i].mode;
            f.buffs[i]:SetAttribute("spell", BeBlessed.toLocal[modes[f.buffs[i].mode]]);
        end)

    end

    f.update = 0;
    
    f:SetScript("OnUpdate", function()
        if (f.update < GetTime()) then
            f.update = GetTime() + 0.1;

            UpdateAvailableSpells();
            
            if (numModes == 0) then
                for i = 0, 4 do
                    f.buffs[i]:Hide();
                end
                return;
            end
            
            local class, classIndex, uintID, coords, guid;
            local P;
            local status;
            local buff_present;
            local textAlpha = 0.3;
            local inRange;

            for i = 0,GetPlayersInParty() do

                -- Fetch information
                P = f.buffs[i];
                unitID = unit_ids[i];
                _, class, classIndex = UnitClass(unitID);
                guid = UnitGUID(unitID);
                coords = CLASS_ICON_TCOORDS[class];

                if (not P.mode or not modes[P.mode]) then
                    P:Hide();
                    return;
                end


                if P.mode > numModes then
                    P.mode = 0;
                end

                UpdateMode(P, i);

                -- Check range 
                inRange = IsSpellInRange(BeBlessed.toLocal[modes[P.mode]], unitID);
                if ((inRange == 1) and UnitExists(unitID) and UnitIsVisible(unitID)) then
                    textAlpha = 1.0;
                else
                    textAlpha = 0.3;
                end

                -- Update textures
                if classIndex then
                    P.class:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"); 
                    if (classIndex) then
                        f.buffs[i].highlight:SetColorTexture(
                            class_color_rgb[classIndex].r,
                            class_color_rgb[classIndex].g,
                            class_color_rgb[classIndex].b, 
                            0.2
                        );
                    end
                    P.class:SetTexCoord(unpack(coords));
                end
                P.icon:SetTexture(textures[modes[f.buffs[i].mode]]);

                -- Check buff status
                status = BeBlessed:GetGUIDStatus(guid);
                buff_present = BeBlessed:UnitHasBuff(unitID, BeBlessed.toLocal[modes[P.mode]]);
                if (status) then
                    
                    if (status.spellName == modes[P.mode] and buff_present) then
                        local remaining = status.duration - (GetTime() - status.applied);
                        if (remaining <= 0) then
                            P.text:SetTextColor(1,0,0, textAlpha);
                            P.text:SetText("None");
                        else
                            local minutes = floor(remaining / 60);
                            local seconds = floor(remaining - 60*minutes);
                    
                            if (remaining >= 120) then
                                f.buffs[i].text:SetTextColor(0,1,0, textAlpha);
                            elseif (remaining >= 30) then
                                f.buffs[i].text:SetTextColor(1,1,0, textAlpha);
                            else
                                f.buffs[i].text:SetTextColor(1,0,0, textAlpha);
                            end
                    
                            if seconds < 10 then
                                seconds = "0"..tostring(seconds);
                            else
                                seconds = tostring(seconds);
                            end
                            minutes = tostring(minutes);
                            P.text:SetText(minutes..":"..seconds);
                        end
                    elseif buff_present then
                        P.text:SetTextColor(1,1,0, textAlpha);
                        P.text:SetText("Buffed");
                    else
                        P.text:SetTextColor(1,0,0, textAlpha);
                        P.text:SetText("None");
                    end 
                else
                    P.text:SetTextColor(1,0,0, textAlpha);
                    P.text:SetText("None");
                end
                P:Show();
            end

            for i = GetPlayersInParty()+1,4 do
                f.buffs[i]:Hide();
            end
        end

    end)

    

end
