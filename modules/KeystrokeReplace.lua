local addon,ns = ...; local L,C=ns.L,ns.LC.color;
local modName = "KeystrokeReplace";
local update,ticker,current,lastObj,updateOptions,updateKeys,current_modifier_state = false;
local keys = {};

local module = {
	defaultEnabled = false,
	label = "Keystroke replace",
	desc = L["Some keyboard layouts are a little bit incompatible with the wow client like EurKey. This module should help you to write character with combinations that the wow client normally use for other actions. For example: Ctrl+a and Ctrl+u. Normally mark and undo text. In EurKey to write ä and ö."],
	events = {
		"ADDON_LOADED",
		"PLAYER_LOGIN",
		"MODIFIER_STATE_CHANGED"
	},
	config = {
		enabled = false,
		keys = {
			-- modifier, key, replace, append
			{"CTRL_ALT",      "A",false,"ä",true},
			{"CTRL_ALT_SHIFT","A",false,"Ä",true},
			{"CTRL_ALT",      "U",false,"ü",true},
			{"CTRL_ALT_SHIFT","U",false,"Ü",true}
		}
	},
	options_childGroups = "tab",
	options = {
		enabled = {
			type = "toggle", order = 1, width = "full",
			name = L["Enable keystroke replace functionality"],
			get = function() return ns.profile[modName].enabled; end,
			set = function(_,v) ns.profile[modName].enabled = v; end
		},
		keys = {
			type = "group", order = 3,
			name = L["Keys"],
			childGroups = "tree",
			args = {
				
			}
		}
	}
}
ns.modules[modName] = module;

local add = {
	type = "execute", order = 1,
	name = ADD, desc = nil,
	func = function()
		tinsert(ns.profile[modName].keys,{"","",false,"",true});
		updateOptions();
		updateKeys();
	end
};
local reset = {
	type = "execute", order = 2,
	name = RESET, desc = L["Reset key list"],
	func = function()
		ns.profile[modName].keys = CopyTable(module.config.keys);
		updateOptions();
	end
};
local modvalues = {
	ALT = L["Alt+<Key>"],
	ALT_SHIFT = L["Alt+Shift+<Key>"],
	CTRL = L["Control+<Key>"],
	CTRL_ALT = L["Control+Alt+<Key>"],
	CTRL_ALT_SHIFT = L["Control+Alt+Shift+<Key>"]
}

function updateOptions()
	local count,inline = 20,0;
	module.options.keys.args = {add=add,reset=reset};

	for i,value in ipairs(ns.profile[modName].keys)do
		if type(ns.profile[modName].keys[i])=="table" then
			count = count + 1;
			module.options.keys.args["KEY"..i] = {
				type = "group", order = count,
				name = L["Entry %d (empty)"]:format(i),
				desc = L["Modifiers: %s|nKey: %s|nReplace: %s|nAppend: %s"]:format(
					modvalues[value[1]]~=nil and gsub(modvalues[value[1]],"%+%<Key%>","") or L["<Not set>"],
					value[2]~="" and value[2] or L["<Not set>"],
					value[3] or L["(Not set / disabled)"],
					value[4]~="" and value[4] or L["(Not set)"]
				),
				args = {}
			};
			if modvalues[value[1]] then
				module.options.keys.args["KEY"..i].name = gsub(modvalues[value[1]],"%<Key%>",value[2]).." = "..value[4];
			end
			module.options.keys.args["KEY"..i].args = {
				enable = {
					type = "toggle", order = 0,
					name = L["Enable"], desc = nil,
					disabled = function()
						local d = ns.profile[modName].keys[i];
						if not (d[1]~="" and d[2]~="" and d[4]~="") then
							return true;
						end
					end,
					get = function() return ns.profile[modName].keys[i][5]; end,
					set = function(_,v) ns.profile[modName].keys[i][5] = v; end
				},
				modifier = {
					type = "select", order = 1, width="double",
					name = L["Modifier"], desc = nil,
					values = modvalues,
					get = function() return ns.profile[modName].keys[i][1]; end,
					set = function(_,v)
						ns.profile[modName].keys[i][1] = v;
						updateOptions();
					end
				},
				key = {
					type = "keybinding", order = 2,
					name = C("dkyellow",L["Key"]), desc = nil,
					get = function() return ns.profile[modName].keys[i][2]; end,
					set = function(_,v)
						if not IsModifierKeyDown() then
							ns.profile[modName].keys[i][2] = v;
							updateOptions();
						end
					end
				},
				replace = {
					type = "input", order = 3, width = "half",
					name = REPLACE, desc = L["Some combinations of modifier+key are producing a character. Put the unwanted character in this field to replace it. Leave it empty to disable this option."],
					get = function() return ns.profile[modName].keys[i][3] or ""; end,
					set = function(_,v)
						ns.profile[modName].keys[i][3] = v~="" and v or false;
						updateOptions();
					end
				},
				append = {
					type = "input", order = 4, width = "half",
					name = L["Append"], desc = L["Write in this field the wanted character you wish to see"],
					get = function() return ns.profile[modName].keys[i][4]; end,
					set = function(_,v)
						ns.profile[modName].keys[i][4] = v;
						updateOptions();
					end
				},
				delete = {
					type = "execute",  order = 5, width="double",
					name = DELETE, desc = nil,
					func = function()
						tremove(ns.profile[modName].keys,i);
						updateOptions();
						updateKeys();
					end
				}
			};
		end
	end
	LibStub("AceConfigRegistry-3.0"):NotifyChange(modName);
end

function updateKeys()
	for i,v in ipairs(ns.profile[modName].keys)do
		keys[v[1].."_"..v[2]] = v;
	end
end

local function OnKeyDown(self,key)
	if not ns.profile[modName].enabled then return end
	if self:HasFocus() and ( IsAltKeyDown() or IsControlKeyDown() or IsShiftKeyDown() ) and not (key:match("SHIFT") or key:match("ALT") or key:match("CTRL")) then
		local Key = {};
		if IsControlKeyDown() then tinsert(Key,"CTRL"); end
		if IsAltKeyDown()     then tinsert(Key,"ALT");  end
		if IsShiftKeyDown()   then tinsert(Key,"SHIFT"); end
		if #Key>0 then
			current_modifier_state = table.concat(Key,"_");
		else
			current_modifier_state = false;
		end
		current_text = self:GetText();
	end
end

local function OnKeyUp(self,key)
	if not ns.profile[modName].enabled then return end
	if current_modifier_state and current_text and keys[current_modifier_state.."_"..key] and keys[current_modifier_state.."_"..key][5]==true then
		local d = keys[current_modifier_state.."_"..key];
		if d[3] then
			current_text = current_text:gsub(d[3].."$","");
		end
		self:SetText(current_text..d[4]);
		current_text = nil;
	end
end

local function SearchAndHook() -- EditBox
	local elems,obj = {},lastObj or EnumerateFrames();
	while obj do
		if not obj:IsForbidden() and obj:GetObjectType()=="EditBox" then
			obj:HookScript("OnKeyDown",OnKeyDown);
			obj:HookScript("OnKeyUp",OnKeyUp);
		end
		lastObj = obj; -- use last found obj as start for the next execution of this function.
		obj = EnumerateFrames(obj);
	end
end

module.onevent = function(self,event,...)
	if event=="ADDON_LOADED" then
		updateOptions();
		updateKeys();
		self:UnregisterEvent(event);
	elseif event=="PLAYER_LOGIN" then
		ticker = C_Timer.NewTicker(1,function()
			if update then
				update=false;
				SearchAndHook();
			end
		end);
		local doUpdate = function() update=true; end;
		hooksecurefunc(_G,"LoadAddOn",doUpdate);
		hooksecurefunc(_G,"CreateFrame",doUpdate);
	end
end
