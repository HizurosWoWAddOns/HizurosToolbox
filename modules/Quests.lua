

local addon,ns = ...; local L,C=ns.L,ns.LC.color;
local modName = "Quests";
local active,blocks,tooltips,updateQuestTracker = false,{},{};
local questTags = {
	--[ELITE] = {"+","yellow"},
	[QUEST_TAG_GROUP] = "g",
	[QUEST_TAG_PVP] = {"pvp","violet"},
	[QUEST_TAG_DUNGEON] = "d",
	[QUEST_TAG_HEROIC] = "hc",
	[QUEST_TAG_RAID] = "r",
	[QUEST_TAG_RAID10] = "r10",
	[QUEST_TAG_RAID25] = "r25",
	[QUEST_TAG_SCENARIO] = "s",
	[QUEST_TAG_ACCOUNT] = "a",
	[QUEST_TAG_LEGENDARY] = {"leg","orange"},
	TRADE_SKILLS = {"ts","green"}
};
local frequencies = {
	[LE_QUEST_FREQUENCY_DAILY] = {"*",DAILY},
	[LE_QUEST_FREQUENCY_WEEKLY] = {"**",WEEKLY},
};
local ts_try,tradeskills = 0,{};

local module = {
	label = "Quests",
	events = {
		"ADDON_LOADED"
	},
	config = {
		showQuestLevel = true,
		showQuestTag = true,
		showBrackets = true,
		tooltipModifier = "IsShiftKeyDown",
		tooltipShowOnModifier = false,
		tooltipQuestText = true,
		tooltipQuestLevel = true,
		tooltipQuestTag = true,
		tooltipQuestID = false
	},
	options_childGroups = "tab", -- tab / tree
	options = {
		questtracker = {
			type = "group", order = 1,
			name = L["Quest tracker: Level and tags"],
			guiInline = true,
			args = {
				questLevel = {
					type = "toggle", order=1,
					name = L["Show quest level"],
					desc = L["Show quest level and short quest tag on quest tracker"],
					get = function() return ns.get(modName,"showQuestLevel"); end,
					set = function(_,v) ns.set(modName,"showQuestLevel",v); updateQuestTracker(); end
				},
				questTag = {
					type = "toggle", order = 2,
					name = L["Show quest tags"],
					desc = L["Show quest tags on quest tracker"],
					get = function() return ns.get(modName,"showQuestTag"); end,
					set = function(_,v) ns.set(modName,"showQuestTag",v); updateQuestTracker(); end
				},
				questBrackets = {
					type = "toggle", order=3,
					name = L["Show [ ] backets"],
					desc = L["Surround quest level and tags on quest tracker with [ ] brackets"],
					get = function() return ns.get(modName,"showBrackets"); end,
					set = function(_,v) ns.set(modName,"showBrackets",v); updateQuestTracker(); end
				},
				labeling1 = {
					type = "description", order = 4, width = "normal",
					name = C("dkyellow","Quest tags:|n")
						.. C("dailyblue","g").." = group|n"
						.. C("dailyblue","d").." = dungeon|n"
						.. C("dailyblue","hc").." = dungeon, herioc|n"
						.. C("dailyblue","r").." = raid|n"
						.. C("violet","pvp").." = pvp|n",
					fontSize = "medium"
				},
				labeling2 = {
					type = "description", order = 5, width = "normal",
					name = ""
						.. C("dailyblue","*").." = daily|n"
						.. C("dailyblue","**").." = weekly|n"
						.. C("dailyblue","a").." = account|n"
						.. C("orange","leg").." = legendary|n"
						.. C("green","ts").." = trade skill|n",
					fontSize = "medium"
				},
				example = {
					type = "description", order = 6, width = "normal",
					name = "",
					image = ns.media.."example_questtracker.blp",
					imageCoords = {0,1,0,1},
					imageWidth = 128,
					imageHeight = 64
				},
			},
		},
		questTooltip = {
			type = "group", order=2,
			name = L["Quest tracker: Tooltip"],
			guiInline = true,
			args = {
				questTooltipDesc = {
					type = "description", order=1,
					name = L["This module adds a tooltip to quest tracker entries. Minimum one of the following options must be enabled to show tooltips by mouse over quest tracker entries."]
				},
				separator2 = {order=2},
				questTooltipOnModifier = {
					type = "toggle", order=3,
					name = L["Show on modifier"],
					desc = L["Display tooltip only on mouse over a quest tracker entry by hold modifier key"],
					get = function() return ns.get(modName,"tooltipShowOnModifier"); end,
					set = function(_,v) ns.get(modName,"tooltipShowOnModifier",v); end
				},
				questTooltipSelModifier = {
					type = "select", order=4,
					name = L["Modifier"],
					values = {
						IsShiftKeyDown      = L["Shift"],
						IsLeftShiftKeyDown  = L["Left Shift"],
						IsRightShiftKeyDown = L["Right Shift"],
						IsControlKeyDown    = L["Control"],
						IsLeftControlKeyDown= L["Left Control"],
						IsRightShiftKeyDown = L["Right Control"],
						IsAltKeyDown        = L["Alt"],
						IsLeftAltKeyDown    = L["Left Alt"],
						IsRightAltKeyDown   = L["Right Alt"]
					},
					get = function() return ns.get(modName,"tooltipModifier"); end,
					set = function(_,v) ns.get(modName,"tooltipModifier",v); end
				},
				separator3 = {order=5},
				tooltipQuestText = {
					type = "toggle", order=6,
					name = L["Show quest text"],
					desc = L["Add tooltip with quest text to quest tracker"],
					get = function() return ns.get(modName,"tooltipQuestText"); end,
					set = function(_,v) ns.set(modName,"tooltipQuestText",v); updateQuestTracker(); end
				},
				tooltipQuestLevel = {
					type = "toggle", order=7,
					name = L["Show quest level"],
					desc = L["Add tooltip with quest text to quest tracker"],
					get = function() return ns.get(modName,"tooltipQuestLevel"); end,
					set = function(_,v) ns.set(modName,"tooltipQuestLevel",v); updateQuestTracker(); end
				},
				tooltipQuestTag = {
					type = "toggle", order=8,
					name = L["Show quest tag"],
					desc = L["Add tooltip with quest text to quest tracker"],
					get = function() return ns.get(modName,"tooltipQuestTag"); end,
					set = function(_,v) ns.set(modName,"tooltipQuestTag",v); updateQuestTracker(); end
				},
				tooltipQuestID = {
					type = "toggle", order=9,
					name = L["Show quest id"],
					desc = L["Add tooltip with quest text to quest tracker"],
					get = function() return ns.get(modName,"tooltipQuestID"); end,
					set = function(_,v) ns.set(modName,"tooltipQuestID",v); updateQuestTracker(); end
				}
			}
		}
	}
}
ns.modules[modName] = module;

local function tradeskills_build()
	ts_try = ts_try+1;
	local fail = false;
	for spellId, spellName in pairs({
		[1804] = "Lockpicking", [2018]  = "Blacksmithing", [2108]  = "Leatherworking", [2259]  = "Alchemy",     [2550]  = "Cooking",     [2575]   = "Mining",
		[2656] = "Smelting",    [2366]  = "Herbalism",     [3273]  = "First Aid",      [3908]  = "Tailoring",   [4036]  = "Engineering", [7411]   = "Enchanting",
		[8613] = "Skinning",    [25229] = "Jewelcrafting", [45357] = "Inscription",    [53428] = "Runeforging", [78670] = "Archaeology", [131474] = "Fishing",
	}) do
		local spellLocaleName,_,spellIcon = GetSpellInfo(spellId);
		if spellLocaleName then
			tradeskills[spellLocaleName] = true;
		else
			fail = true;
		end
	end
	if fail and ts_try<=3 then
		--ns.debug(modName,"tradeskills_build", "retry", ts_try);
		C_Timer.After(0.5, function()
			tradeskills_build()
		end);
	end
end

local function CreateQuestTag(level, shortTags, frequency)
	if ns.profile[modName].showQuestLevel then
		if level == -1 then
			level = "|cffff0000~?~|r"; -- really possible?
		else
			local col = GetQuestDifficultyColor(level);
			level = ("|cff%02x%02x%02x%d|r"):format(col.r*255,col.g*255,col.b*255,level);
		end
	else 
		level = "";
	end

	local tags = "";
	if ns.profile[modName].showQuestTag then
		for i,v in ipairs(shortTags)do
			if questTags[v] then
				if type(questTags[v])=="table" then
					tags = tags .. C(questTags[v][2],questTags[v][1]);
				else
					tags = tags .. C("dailyblue",questTags[v]);
				end
			end
		end
		if frequencies[frequency] then
			tags = tags .. C("dailyblue",frequencies[frequency][1]);
		end
	end
	
	if ns.profile[modName].showBrackets then
		return "[" .. level .. tags .. "] ";
	end
	return level .. tags .. " ";
end

local function showQuestTooltip(self,questID)
	if tooltips[questID] then
		local fnc = _G[ns.profile[modName].tooltipModifier];
		if ns.profile[modName].tooltipShowOnModifier and type(fnc)=="function" and not fnc() then
			return;
		end
		HTB_Tooltip_OnEnter(self,tooltips[questID],{"RIGHT",self,"LEFT",-28,0});
	end
end

function updateQuestTracker(force)
	if (ns.profile[modName].showQuestLevel==false and ns.profile[modName].showQuestTag==false) and not active then
		return; -- not enabled, no previous taints = no actions needed
	end
	local header = false;
	local num = GetNumQuestLogEntries();
	for i = 1, num do
		local block;
		local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory = GetQuestLogTitle(i);
		if questID and questID~=0 then
			block = QUEST_TRACKER_MODULE:GetExistingBlock(questID);
		end
		if isHeader then
			header = title;
		end
		if block then
			if not active and title~=block.HeaderText:GetText() then
				return; -- C_Timer and this check should detect changes by other addons and stop this function
			end
			if not tonumber(level) then
				--ns.debug(title, level, questID);
			end
			local tagID, tagName = GetQuestTagInfo(questID);
			local tags,shortTags = {tagName},{tagID};
			if tagName == PLAYER_DIFFICULTY2 then
				tinsert(tags,1,LFG_TYPE_DUNGEON);
			end
			if tradeskills[header] then
				tinsert(tags, TRADE_SKILLS);
				tinsert(shortTags,"TRADE_SKILLS");
			end
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
					tinsert(tooltips[questID],{C("ltblue",#tags==1 and L["Quest tag"] or L["Quest tags"]..":"),C("ltgreen",table.concat(tags,", "))});
				end
				if ns.profile[modName].tooltipQuestID then
					tinsert(tooltips[questID],{C("ltblue",L["Quest id"]..":"),C("ltgreen",questID)});
				end
				if #tooltips[questID]>1 then
					tooltips[questID][2][1] = "|n"..tooltips[questID][2][1];
					tooltips[questID][2][2] = "|n"..tooltips[questID][2][2];
				end
				if ns.profile[modName].tooltipQuestText then
					local questText = GetQuestLogQuestText(i);
					tinsert(tooltips[questID],"|n"..questText);
				end
			end
			block.height = block.height - block.HeaderText:GetHeight();
			block.height = block.height + QUEST_TRACKER_MODULE:SetStringText(block.HeaderText, CreateQuestTag(level, shortTags, frequency)..title, nil, OBJECTIVE_TRACKER_COLOR["Header"]);
			block:SetHeight(block.height);
			if not blocks[questID] and block.HeaderButton then
				block.HeaderButton:HookScript("OnEnter",function(self)
					showQuestTooltip(self,questID);
				end);
				block.HeaderButton:HookScript("OnLeave",HTB_Tooltip_OnLeave);
				block.HeaderButton:HookScript("OnEvent",function(self,event,...)
					if event=="MODIFIER_STATE_CHANGED" then
						if GameTooltip:GetOwner()==block.HeaderButton and GameTooltip:IsShown() then
							HTB_Tooltip_OnLeave();
						elseif GetMouseFocus()==block.HeaderButton and ns.profile[modName].tooltipShowOnModifier then
							showQuestTooltip(self,questID);
						end
					end
				end);
				block.HeaderButton:RegisterEvent("MODIFIER_STATE_CHANGED");
				blocks[questID] = true;
			end
		end
	end
	active = true;
	if ns.profile[modName].showQuestLevel==false and ns.profile[modName].showQuestTag==false then
		active = false;
	end
end

module.onload = function()
	tradeskills_build();
	hooksecurefunc("QuestSuperTracking_CheckSelection",function()
		updateQuestTracker();
	end);
end
