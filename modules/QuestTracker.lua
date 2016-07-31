

local addon,ns = ...; local L,C=ns.L,ns.LC.color;
local modName = "QuestTracker";
local updateQuestTracker;
local get,set;
local active = false;
local blocks = {};
local tooltips = {};

local module = {
	label = "QuestTracker",
	desc = C("dkyellow","Credit")..":|nliquidbase (author of DuffedUI) for idea and code to add quest level to quest tracker :)",
	events = {
		"ADDON_LOADED"
	},
	config = {
		showQuestLevel = true,
		tooltipQuestText = true,
		tooltipQuestLevel = true,
		tooltipQuestTag = true,
		tooltipQuestID = false
	},
	options = {
		questlevel = {
			type = "toggle", order=1,
			name = L["Show quest level"],
			desc = L["Show quest level and short quest tag on quest tracker."],
			get = function() return get("showQuestLevel"); end,
			set = function(_,v) set("showQuestLevel",v); end
		},
		questTooltip = {
			type = "header", order=2,
			name = L["Quest tracker tooltip"]
		},
		questTooltipDesc = {
			type = "description", order=3,
			name = L["This module adds a tooltip to quest tracker entries. Minimum one of the following options must be enabled to show tooltips by mouse over quest tracker entries."]
		},
		tooltipQuestText = {
			type = "toggle", order=4,
			name = L["Show quest text"],
			desc = L["Add tooltip with quest text to quest tracker"],
			get = function() return get("tooltipQuestText"); end,
			set = function(_,v) set("tooltipQuestText",v); end
		},
		tooltipQuestLevel = {
			type = "toggle", order=5,
			name = L["Show quest level"],
			desc = L["Add tooltip with quest text to quest tracker"],
			get = function() return get("tooltipQuestLevel"); end,
			set = function(_,v) set("tooltipQuestLevel",v); end
		},
		tooltipQuestTag = {
			type = "toggle", order=6,
			name = L["Show quest tag"],
			desc = L["Add tooltip with quest text to quest tracker"],
			get = function() return get("tooltipQuestTag"); end,
			set = function(_,v) set("tooltipQuestTag",v); end
		},
		tooltipQuestID = {
			type = "toggle", order=7,
			name = L["Show quest id"],
			desc = L["Add tooltip with quest text to quest tracker"],
			get = function() return get("tooltipQuestID"); end,
			set = function(_,v) set("tooltipQuestID",v); end
		},
	}
}
ns.modules[modName] = module;

local questTags = {
	[ELITE] = "+",
	[QUEST_TAG_GROUP] = "g",
	[QUEST_TAG_PVP] = "pvp",
	[QUEST_TAG_DUNGEON] = "d",
	[QUEST_TAG_HEROIC] = "hc",
	[QUEST_TAG_RAID] = "r",
	[QUEST_TAG_RAID10] = "r10",
	[QUEST_TAG_RAID25] = "r25",
	[QUEST_TAG_SCENARIO] = "s",
	[QUEST_TAG_ACCOUNT] = "a",
	[QUEST_TAG_LEGENDARY] = "leg"
};
local frequencies = {
	[LE_QUEST_FREQUENCY_DAILY] = {"*",DAILY},
	[LE_QUEST_FREQUENCY_WEEKLY] = {"**",WEEKLY},
}

function get(key)
	return ns.profile[modName][key];
end

function set(key,value)
	ns.profile[modName][key] = value;
	updateQuestTracker();
end

local function CreateQuestTag(level, questTag, frequency)
	local tag = questTags[questTag] or "";
	local color = "";

	if level == -1 then
		level = "|cff00ff00~?~"; -- really possible?
	else
		local col = GetQuestDifficultyColor(level);
		level = ("|cff%02x%02x%02x%d"):format(col.r*255,col.g*255,col.b*255,level);
	end

	if frequencies[frequency] then
		tag = tag..frequencies[frequency][1];
	end

	if tag ~= "" then
		tag = ("|cff00b3ff%s"):format(tag);
	end

	return ("[%s%s|r] "):format(level,tag);
end

function updateQuestTracker()
	if ns.profile[modName].showQuestLevel==false and not active then return end
	active = true;
	local num = GetNumQuestLogEntries();
	for i = 1, num do
		local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory = GetQuestLogTitle(i);
		if questID and questID~=0 then
			local block = QUEST_TRACKER_MODULE:GetBlock(questID);
			local tagID, tagName = GetQuestTagInfo(questID);
			local tags = {tagName};
			if frequencies[frequency] then
				tinsert(tags,frequencies[frequency][2]);
			end
			tooltips[questID] = false;
			if ns.profile[modName].tooltipQuestText or ns.profile[modName].tooltipQuestLevel or (ns.profile[modName].tooltipQuestTag and tagName) or ns.profile[modName].tooltipQuestID then
				spacer = false;
				tooltips[questID] = {title};
				if ns.profile[modName].tooltipQuestLevel then
					tinsert(tooltips[questID],{C("ltblue",L["Quest level"]..":"),C("ltgreen",level)});
				end
				if ns.profile[modName].tooltipQuestTag and #tags>0 then
					tinsert(tooltips[questID],{C("ltblue",L["Quest tag"]..":"),C("ltgreen",table.concat(tags,", "))});
				end
				if ns.profile[modName].tooltipQuestID then
					tinsert(tooltips[questID],{C("ltblue",L["Quest id"]..":"),C("ltgreen",questID)});
				end
				if ns.profile[modName].tooltipQuestText then
					local questText = GetQuestLogQuestText(i);
					tinsert(tooltips[questID],questText);
				end
			end
			if ns.profile[modName].showQuestLevel then
				title = CreateQuestTag(level, tagID, frequency) .. title;
			end
			QUEST_TRACKER_MODULE:SetStringText(block.HeaderText, title, nil, OBJECTIVE_TRACKER_COLOR["Header"]);
			if not blocks[questID] and block.HeaderButton then
				block.HeaderButton:HookScript("OnEnter",function(self)
					if tooltips[questID] then
						HTB_Tooltip_OnEnter(self,tooltips[questID],{"RIGHT",self,"LEFT",-28,0});
					end
				end);
				block.HeaderButton:HookScript("OnLeave",HTB_Tooltip_OnLeave);
				blocks[questID] = true;
			end
		end
	end

	if ns.profile[modName].showQuestLevel==false then
		active = false;
	end
end

module.onload = function()
	hooksecurefunc("QuestSuperTracking_CheckSelection",updateQuestTracker);
end
