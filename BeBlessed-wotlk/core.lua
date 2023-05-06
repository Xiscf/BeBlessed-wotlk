BeBlessed = {};
local eventHandler = CreateFrame("Frame");
eventHandler.events = {};
local INDEX = UnitName("player").."-"..GetRealmName();
local inCombat = false;

BeBlessed.toLocal = {};
BeBlessed.toEnglish = {};
BeBlessed.guidToIndex = {};
BeBlessed.BlessingIDs = {
    ["Blessing of Might"]             = 48932,
    ["Blessing of Wisdom"]            = 48936,
    ["Blessing of Kings"]             = 20217,
    ["Blessing of Sanctuary"]         = 20911,
    ["Greater Blessing of Might"]     = 48934,
    ["Greater Blessing of Wisdom"]    = 48938,
    ["Greater Blessing of Kings"]     = 25898,
    ["Greater Blessing of Sanctuary"] = 25899,
}

-- Do not take in consideration the minor glyphe that increase the buff's duration
-- on yourself from yourself. 
local BlessingDurations = {
    ["Blessing of Might"] =  600,    -- 300 (300 = 5min, 600 = 10min, 900 = 15min, 1800 = 30m)
    ["Blessing of Wisdom"] = 600,    -- 300 (300 = 5min, 600 = 10min, 900 = 15min, 1800 = 30m)
    ["Blessing of Kings"] = 600,     -- 300 (300 = 5min, 600 = 10min, 900 = 15min, 1800 = 30m)
    ["Blessing of Sanctuary"] = 600, -- 300 (300 = 5min, 600 = 10min, 900 = 15min, 1800 = 30m)
    ["Greater Blessing of Might"] = 1800,      -- 900 (300 = 5min, 600 = 10min, 900 = 15min, 1800 = 30m)
    ["Greater Blessing of Wisdom"] = 1800,     -- 900 (300 = 5min, 600 = 10min, 900 = 15min, 1800 = 30m)
    ["Greater Blessing of Kings"] = 1800,      -- 900 (300 = 5min, 600 = 10min, 900 = 15min, 1800 = 30m)
    ["Greater Blessing of Sanctuary"] = 1800,  -- 900 (300 = 5min, 600 = 10min, 900 = 15min, 1800 = 30m)
}

local function EqualAny(val, target)
   for v,_ in pairs(target) do
      if val == v then
         return true;
      end
   end
   return false;
end


function eventHandler.events:ADDON_LOADED(event, addon)
   if (addon == "BeBlessed") then

      local _, class = UnitClass("player");
      if (class ~= "PALADIN") then
         return;
      end

      if type(BeBlessedData) ~= "table" then
         BeBlessedData = {}
      end

      if (type(BeBlessedData[INDEX]) ~= "table") then
         BeBlessedData[INDEX] = {};
         BeBlessedData[INDEX].settings = {}
         BeBlessedData[INDEX].settings.modes = {[0] = 0, [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, [6] = 0, [7] = 0};
         BeBlessedData[INDEX].buffStatus = {};
         BeBlessedData[INDEX].settings.selectedBlessings = {[0] = 0, [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, [6] = 0, [7] = 0};
      end

      BeBlessed:CreateSpellNameLocale();
      BeBlessed:CreateBuffFrame();

      print("Be|cffF58CBABlessed|r: Loaded");
   end
end

function eventHandler.events:PLAYER_REGEN_ENABLED(event,...)
   inCombat = false;
end

function eventHandler.events:PLAYER_REGEN_DISABLED(event,...)
   inCombat = true;
end

function eventHandler.events:COMBAT_LOG_EVENT_UNFILTERED(event)
   local _, eventType, _, sourceGUID, sourceName, spellID, _, destGUID, destName, _, _, _, spellName = CombatLogGetCurrentEventInfo();

   if (sourceGUID == UnitGUID("player") and eventType == "SPELL_CAST_SUCCESS") then
      local engSpellName = BeBlessed.toEnglish[spellName];
      
      if EqualAny(engSpellName, BlessingDurations) then
         BeBlessedData[INDEX].buffStatus[destGUID] = {applied=GetTime(), spellName=engSpellName, spellID=spellID, duration=BlessingDurations[engSpellName]};
      end
        
   end
end

for event,_ in pairs(eventHandler.events) do
   eventHandler:RegisterEvent(event);
end

eventHandler:SetScript("OnEvent", function(self,event,...)
   eventHandler.events[event](self, event, ...);
end)


function BeBlessed:GetGUIDStatus(guid)
   if (type(BeBlessedData[INDEX].buffStatus[guid]) == "table") then
      return BeBlessedData[INDEX].buffStatus[guid]
   end
   return nil;
end

function BeBlessed:UnitHasBuff(unitID, buffName)
   for i = 1,40 do
      local name = UnitBuff(unitID, i);
      if name == buffName then
         return true;
      end
   end
   return false;
end

function BeBlessed:InCombat()
   return inCombat;
end

function BeBlessed:GetAvailableSpells()
   local avaialble = {};
   for k,v in pairs(BeBlessed.BlessingIDs) do 
      if IsSpellKnown(v) then
         avaialble[k] = true;
      end
   end
   return avaialble;
end

function BeBlessed:CreateSpellNameLocale()
   for k,v in pairs(BeBlessed.BlessingIDs) do
      local name = GetSpellInfo(v);
      BeBlessed.toLocal[k] = name;
      BeBlessed.toEnglish[name] = k;
   end
end
