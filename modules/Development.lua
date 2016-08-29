
local addon,ns = ...; local L,C=ns.L,ns.LC.color;
local modName = "DevTools";
local updateSearchFunctions,updateSlashGet,updateSlashItem,fstackGetModifier,fstackSetModifier;
local module = {
	defaultEnabled = false,
	label = "Development Tools",
	desc = L["Some maybe usefull functions for developer and interest users"].." :-)",
	events = {
		-- PLAYER_REGEN_DISABLED
		"MODIFIER_STATE_CHANGED"
	},
	config = {
		-- group1
		addSearchFunctions = true,
		seeTaintByInSearchFunctions = true,
		-- group2
		frameStackModifier = "0.0.0",
		frameStackHidden = false,
		frameStackRegions = false,
		-- group3
		addSlashGet = false,
		-- group4
		addSlashItem = false,
	},
	options_prependingSeparator = true,
	options_NoHeader = true,
	options_childGroups = "tab", -- "tree",
	options = {
		group1 = {
			type = "group", order = 1,
			name = L["Search functions"],
			args = {
				example = {
					type = "description", order = 2,
					name = "",
					image = ns.media.."example_devtools_searchkey.tga",
					imageCoords = {0,323/512,0,42/64},
					imageWidth = 323,
					imageHeight = 42,
				},
				addSearchFunctions = {
					type = "toggle", order=0,
					name = L["Enable"],
					desc = L["Add functions search_key and search_value for use in addons or with chat commands /run and /script"],
					get = function() return ns.get(modName,"addSearchFunctions"); end,
					set = function(_,v) ns.get(modName,"addSearchFunctions",v); updateSearchFunctions(v); end
				},
				seeTaintByInSearchFunctions = {
					type = "toggle", order=1,
					name = L["Show owner of value"],
					desc = L["Display owner of value in search results"],
					get = function() return ns.get(modName,"seeTaintByInSearchFunctions"); end,
					set = function(_,v) ns.get(modName,"seeTaintByInSearchFunctions",v); end
				},
				descSearchKey = {
					type = "group", order=3,
					name = L["Description for"].." search_key",
					guiInline = true,
					args = {
						desc = {
							type = "description",
							name = ""
								..C("dkyellow","Usage:")..""..C("ltblue","  search_key(").."string||number, table, type"..C("ltblue",")").."|n"
								..C("ltgreen", "  - "..L["prints all results in chat window"]).."|n"
								.."|n"
								..C("dkyellow","Or:")..""..C("ltblue","  results = search_key(").."string||number, table, type"..C("ltblue",")").."|n"
								..C("ltgreen", "  - "..L["prints all results in chat window and return the results as table"]).."|n"
								.."|n"
								..C("dkyellow","Or:")..""..C("ltblue","  search_key(").."string||number, table, type, result table"..C("ltblue",")").."|n"
								..C("ltgreen", "  - "..L["return the results as table without print to chat window"]).."|n"
								.."|n"
								..C("dkyellow","Examples:").."|n"
								..C("ltblue",  "  /run search_key(").."\"^TEST\""..C("ltblue",")").."|n"
								..C("ltgreen", "  - "..L["list of matching table keys starting with 'TEST'"]).."|n"
								.."|n"
								..C("ltblue",  "  /run search_key(").."\"TEST$\", _G"..C("ltblue",")").."|n"
								..C("ltgreen", "  - "..L["list of matching table keys ending with 'TEST' in table _G"]).."|n"
								.."|n"
								..C("ltblue",  "  /run search_key(").."\"TEST\", nil, \"number\""..C("ltblue",")").."|n"
								..C("ltgreen", "  - "..L["list of matching table keys contains 'TEST' and value type 'number'"])
						},
					}
				},
				descSearchValue = {
					type = "group", order=4,
					name = L["Description for"].." search_value",
					guiInline = true,
					args = {
						desc = {
							type = "description",
							name = ""
								..C("dkyellow","Usage:")..""..C("ltblue","  search_value(").."any type, table"..C("ltblue",")").."|n"
								..C("ltgreen", "  - "..L["prints all results in chat window"]).."|n"
								.."|n"
								..C("dkyellow","Or:")..""..C("ltblue","  results = search_value(").."any type, table"..C("ltblue",")").."|n"
								..C("ltgreen", "  - "..L["prints all results in chat window and return the results as table"]).."|n"
								.."|n"
								..C("dkyellow","Or:")..""..C("ltblue","  search_value(").."any type, table, result table"..C("ltblue",")").."|n"
								..C("ltgreen", "  - "..L["return the results as table without print to chat window"]).."|n"
								.."|n"
								..C("dkyellow","Examples:").."|n"
								..C("ltblue",  "  /run search_value(").."\"^Faction\""..C("ltblue",")").."|n"
								..C("ltgreen", "   - "..L["list of all string values starting with 'Faction'"]).."|n"
								.."|n"
								..C("ltblue",  "  /run search_value(").."false, _G"..C("ltblue",")").."|n"
								..C("ltgreen", "   - "..L["list of all entries with boolean value 'false' in table _G"]).."|n"
								.."|n"
								..C("ltblue",  "  /run search_value(").."print"..C("ltblue",")").."|n"
								..C("ltgreen", "   - "..L["list of all entries with same reference to function 'print'"])
						}
					}
				}
			}
		},
		group2 = {
			type = "group", order = 2,
			name = L["Frame stack tooltip"],
			args = {
				desc1 = {
					type = "description", order = 0,
					name = L["Blizzards Frame stack tooltip function is a helpfull tool. Sometimes i think /fstack is not enough to show/hide it. Here you can add it to keybinding or show by hold modifier."].."|n "
				},
				modifier = {
					type = "group", order=1,
					name = L["Show by modifier"],
					guiInline = true,
					args = {
						desc = {
							type = "description", order = 1,
							name = L["Here you can combine modifier 1-3 to make frame stack tooltip visible by holding the modifiers"]
						},
						modifier_alt = {
							type = "select", order = 2,
							name = L["Modifier: Alt"],
							desc = nil,
							values = {
								["0"] = NONE.."/"..ADDON_DISABLED,
								["1"] = L["Alt"],
								["2"] = L["Alt left"],
								["3"] = L["Alt right"],
								["4"] = L["Alt left & right"],
							},
							get = function() return fstackGetModifier(1); end,
							set = function(_,v) fstackSetModifier(1,v); end
						},
						modifier_ctrl = {
							type = "select", order = 3,
							name = L["Modifier: Control"],
							desc = nil,
							values = {
								["0"] = NONE.."/"..ADDON_DISABLED,
								["1"] = L["Control"],
								["2"] = L["Control left"],
								["3"] = L["Control right"],
								["4"] = L["Control left & right"],
							},
							get = function() return fstackGetModifier(2); end,
							set = function(_,v) fstackSetModifier(2,v); end
						},
						modifier_shift = {
							type = "select", order = 4,
							name = L["Modifier: Shift"],
							desc = nil,
							values = {
								["0"] = NONE.."/"..ADDON_DISABLED,
								["1"] = L["Shift"],
								["2"] = L["Shift left"],
								["3"] = L["Shift right"],
								["4"] = L["Shift left & right"],
							},
							get = function() return fstackGetModifier(3); end,
							set = function(_,v) fstackSetModifier(3,v); end
						}
					}
				},
				key = {
					type = "group", order = 2,
					name = L["Show on keybind"],
					guiInline = true,
					args = {
						bindme = {
							type = "keybinding", order = 1,
							name = "", desc = nil,
							get = function() return GetBindingKey("HTBFRAMESTACK"); end,
							set = function(_,v)
								local keyb = GetBindingKey("HTBFRAMESTACK");
								if keyb then SetBinding(keyb); end -- unset prev key
								if v~="" then SetBinding(v,"HTBFRAMESTACK"); end
								SaveBindings(GetCurrentBindingSet());
							end
						},
						desc = {
							type = "description", order = 2, width = "double",
							name = L["Bind it to a key to toggle frame stack tooltip"]
						}
					}
				},
				more = {
					type = "group", order = 3,
					name = L["More frame stack tooltip options"],
					guiInline = true,
					args = {
						hidden = {
							type = "toggle", order = 9,
							name = L["Show hidden frames"],
							get = function() return ns.get(modName,"frameStackHidden"); end,
							set = function(_,v) ns.set(modName,"frameStackHidden",v); end
						},
						regions = {
							type = "toggle", order = 10,
							name = L["Show region elements"],
							get = function() return ns.get(modName,"frameStackRegions"); end,
							set = function(_,v) ns.set(modName,"frameStackRegions",v); end
						}
					}
				}
			}
		},
		group3 = {
			type = "group", order = 3,
			name = L["More slash commands"],
			args = {
				get = {
					type = "group", order = 1,
					name = "/get",
					guiInline = true,
					args = {
						addSlashGet = {
							type = "toggle", order=9, width="full",
							name = L["Enabled"],
							get = function() return ns.get(modName,"addSlashGet"); end,
							set = function(_,v) ns.set(modName,"addSlashGet",v); updateSlashGet(v); end
						},
						descSlashGet = {
							type = "description", order=10,
							name = ""
								..C("dkyellow","Usage:")..""..C("ltblue","  /get item||spell <id>").."|n"
								.."|n"
								..C("dkyellow","Examples:").."|n"
								..C("ltblue","  /get item 114821").."|n"
								..C("ltgreen","   - "..L["Print a clickable item link into your general chat window"]).."|n"
								..C("ltblue","  /get spell 40192").."|n"
								..C("ltgreen","   - "..L["Print a clickable spell link into your general chat window"])
						},
					}
				},
				item = {
					type = "group", order = 4,
					name = "/item",
					guiInline = true,
					args = {
						addSlashItem = {
							type = "toggle", order=11, width="full",
							name = L["Enabled"],
							get = function() return ns.get(modName,"addSlashItem"); end,
							set = function(_,v) ns.set(modName,"addSlashItem",v); updateSlashItem(v); end
						},
						descSlashItem = {
							type = "description", order=12,
							name = ""
								..C("dkyellow","Usage:")..""..C("ltblue","  /item <item id>").."|n"
								.."|n"
								..C("dkyellow","Examples:").."|n"
								..C("ltblue","  /item 114821").."|n"
								..C("ltgreen","   - "..L["Print a clickable item link into your general chat window"])
						}
					}
				}
			}
		}
	}
}
ns.modules[modName] = module;

function fstackGetModifier(i)
	local values  = {strsplit(".",ns.get(modName,"frameStackModifier"))};
	return values[i];
end

function fstackSetModifier(i,v)
	local values = {strsplit(".",ns.get(modName,"frameStackModifier"))};
	values[i] = v;
	ns.set(modName,"frameStackModifier",table.concat(values,"."));
end

-------------------------
-------------------------

local function search_key(matchStr,parentTable,typeStr,results)
	local c,assertMsg = 0,"Usage: search_key(string||number, table, type)";
	assert(type(matchStr)=="string" or type(matchStr)=="number",assertMsg);
	assert(type(parentTable)=="table" or parentTable==nil,assertMsg);
	assert(type(typeStr)=="string" or typeStr==nil,assertMsg);
	assert(type(results)=="string" or results==nil,assertMsg);
	if type(parentTable)~="table" then parentTable = _G; end
	local _print = ns.print;
	if results then _print = function() end; end
	local p = {"Search key:",matchStr}
	if typeStr then
		tinsert(p,"with value type:");
		tinsert(p,typeStr);
	end
	_print(unpack(p));
	results = results or {};
	for i,v in pairs(parentTable)do
		local t=type(v);
		if ((type(i)=="string" and i:match(matchStr)) or (i==matchStr)) and (typeStr==nil or typeStr==t) then
			c=c+1;
			local res = {c, i, tostring(v), "("..t..")"};
			if ns.profile[modName].seeTaintByInSearchFunctions then
				local _,n = issecurevariable(parentTable,i);
				tinsert(res,"["..(n or "Blizzard").."]");
			end
			_print(false,unpack(res));
			tinsert(results,res);
		end
	end
	if c==0 then
		_print(false,L["No matching keys found..."]);
	end
	return results;
end

local function search_value(target,parentTable,results)
	local c,assertMsg = 0,"Usage: search_value(any type, table)";
	assert(type(parentTable)=="table" or parentTable==nil,assertMsg);
	assert(type(results)=="string" or results==nil,assertMsg);
	if type(parentTable)~="table" then parentTable = _G; end
	local _print = ns.print;
	if results then _print = function() end; end
	_print("Search_value:",matchStr);
	results = results or {};
	for i,v in pairs(parentTable)do
		if (type(v)=="string" and type(target)=="string" and v:match(target)) or (v==target) then
			c=c+1;
			local res = {c, i, v};
			if ns.profile[modName].seeTaintByInSearchFunctions then
				local _,n = issecurevariable(parentTable,i);
				tinsert(res,"["..(n or "Blizzard").."]");
			end
			_print(false,unpack(res));
			tinsert(results,res);
		end
	end
	if c==0 then
		_print(false,L["No matching values found..."]);
	end
	return results;
end

local function IsTaintByName(name,tbl)
	assert(name,"Usage: IsTaintByName(AddOnName[,table])\nUse of second argument fill given table instead of output into chat frame.");
	local c,p,t=0,ns.print,tbl or {};
	if tbl then p=function() end end
	for i,v in pairs(_G)do
		if type(i)=="string" then
			local _,n = issecurevariable(_G,i);
			if n==name then
				if c==0 then p("IsTaintByName",name); end
				c=c+1;
				p(c,i,type(v));
				tinsert(t,i);
			end
		end
	end
end

local function PrintLink(c)
	local c1, c2=strsplit(" ",c);
	c1,c2=c1:lower(),tonumber(c2);
	if (c1=="item" or c1=="spell") and c2 then
		ns.print(("\124cfffffff\124H%s:%d:0:0:0:0:0:0:0:0\124h[%s %d]\124h\124r"):format(c1,c2,c1,c2));
		return
	end
	ns.print("Usage:",C("white","/get"),"<item or spell>","<id>");
	ns.print("Example:",C("ltorange","/get item 114821"));
end

local function PrintItemLink(id)
	local id=tonumber(id);
	if id then
		ns.print("\124cffffffff\124Hitem:"..id..":0:0:0:0:0:0:0:0\124h[item "..id.."]\124h\124r");
		return;
	end
	ns.print("Usage:",C("white","/item"),"<item id>");
	ns.print("Example:",C("ltorange","/item 114821"));
end

local function ToggleFrameStack()
	securecall("UIParentLoadAddOn","Blizzard_DebugTools");
	securecall("FrameStackTooltip_Toggle",ns.profile[modName].frameStackHidden, ns.profile[modName].frameStackRegions);
	if not FrameStackTooltip:IsShown() then
		frameStackShownByModifier = false;
	end
end

-------------------------
-------------------------

function updateSearchFunctions(bool)
	if bool then
		_G.search_key = search_key;
		_G.search_value = search_value;
	else
		_G.search_key = nil;
		_G.search_value = nil;
	end
end

function updateSlashGet(bool)
	if bool then
		SlashCmdList.GET = PrintLink;
		SLASH_GET1 = "/get";
	elseif SLASH_GET1 and ({issecurevariable(_G,"SLASH_GET1")})[2]==addon then
		SlashCmdList.GET = nil;
		SLASH_GET1 = nil;
	end
end

function updateIsTaintBy()
	--_G.IsTaintByName = TaintByName;
end

function updateSlashItem(bool)
	if bool then
		SlashCmdList.ITEM = PrintItemLink;
		SLASH_ITEM1 = "/item";
	elseif SLASH_ITEM1 and ({issecurevariable(_G,"SLASH_ITEM1")})[2]==addon then
		SlashCmdList.ITEM = nil;
		SLASH_ITEM1 = nil;
	end
end

function updateFrameStack()
	local key = GetBindingKey("HTBFRAMESTACK");
	if key then
		HTB_FrameStack = ToggleFrameStack;
	else
		HTB_FrameStack = nil;
	end
end

-------------------------
-------------------------

module.onload = function()
	updateSearchFunctions(ns.profile[modName].addSearchFunctions);
	updateIsTaintBy();
	updateSlashGet(ns.profile[modName].addSlashGet);
	updateSlashItem(ns.profile[modName].addSlashItem);
	updateFrameStack();
end

module.onevent = function(self,event)
	if event=="MODIFIER_STATE_CHANGED" then
		local mod,alt,control,shift = ns.get(modName,"frameStackModifier"),false,false,false;
		if mod=="0.0.0" then
			return; -- option is disabled
		end
		mod = {strsplit(".",mod)};

		if (mod[1]=="1" and IsAltKeyDown())
		or (mod[1]=="2" and IsLeftAltKeyDown())
		or (mod[1]=="3" and IsRightAltKeyDown())
		or (mod[1]=="2" and IsLeftAltKeyDown() and IsRightAltKeyDown()) then
			alt = true;
		end

		if (mod[2]=="1" and IsControlKeyDown())
		or (mod[2]=="2" and IsLeftControlKeyDown())
		or (mod[2]=="3" and IsRightControlKeyDown())
		or (mod[2]=="2" and IsLeftControlKeyDown() and IsRightControlKeyDown()) then
			control = true;
		end

		if (mod[3]=="1" and IsShiftKeyDown())
		or (mod[3]=="2" and IsLeftShiftKeyDown())
		or (mod[3]=="3" and IsRightShiftKeyDown())
		or (mod[3]=="2" and IsLeftShiftKeyDown() and IsRightShiftKeyDown()) then
			shift = true;
		end

		if (mod[1]=="0" or alt) and (mod[2]=="0" or control) and (mod[3]=="0" or shift) then
			if FrameStackTooltip and FrameStackTooltip:IsShown() then
				return; -- is already visible
			end
			ToggleFrameStack();
			frameStackShownByModifier = true;
		elseif frameStackShownByModifier and FrameStackTooltip and FrameStackTooltip:IsShown() then
			ToggleFrameStack();
		end
	end
end

-- [some of my original macros]
-- /run SlashCmdList['X'] = function(c) local r, c1, c2='usage: /get <item||||spell> <id>', strsplit(" ",c); if c2:match("^%d+$") then r=("\124cffff8000\124H%s:%d:0:0:0:0:0:0:0:0\124h[%s %d]\124h\124r"):format(c1,c2,c1,c2) end print(r) end SLASH_X1 = "/get"
-- /run SlashCmdList["ITEM"] = function(cmd) local r="usage: /item <item id>" if cmd:match("^%d+$") then r="\124cffff8000\124Hitem:"..cmd..":0:0:0:0:0:0:0:0\124h[item "..cmd.."]\124h\124r" end print(r) end SLASH_ITEM1 = "/item"
-- /run SlashCmdList["SPELLID"] = function(cmd) local r="usage: /spellid <id>" if cmd:match("^%d+$") then r="\124cffff8000\124Hspell:"..cmd..":0:0:0:0:0:0:0:0\124h[spell"..cmd.."]\124h\124r" end print(r) end SLASH_SPELLID1 = "/spellid"
-- /run SlashCmdList["TC"]=function(cmd)local w,h,l,r,t,b=cmd:match("^(%d+) (%d+) (%d+) (%d+) (%d+) (%d+)$");if(b==nil)then print("wrong usage");return;end print(('left="%f" right="%f" top="%f" bottom="%f"'):format(l/w,r/w,t/h,b/h));end SLASH_TC1="/tc";

