
local addon,ns = ...; local L,C=ns.L,ns.LC.color;
local modName = "DevTools";
local addSearchFunctions;
local module = {
	defaultEnabled = false,
	label = "Development Tools",
	desc = L["Some maybe usefull functions for developer and interest users"].." :-)",
	events = nil, --{},
	config = {
		addSearchFunctions = true,
		seeTaintByInSearchFunctions = true
	},
	options_NoHeader = true,
	options = {
		header1 = {
			type = "header", order=1,
			name = L["Search functions"]
		},
		addSearchFunctions = {
			type = "toggle", order=2,
			name = L["Enable"],
			desc = L["Add functions search_key and search_value for use in addons or with chat commands /run and /script"],
			get = function() return ns.profile[modName].addSearchFunctions; end,
			set = function(_,v) ns.profile[modName].addSearchFunctions = v; addSearchFunctions(v); end
		},
		seeTaintByInSearchFunctions = {
			type = "toggle", order=3,
			name = L["Show owner of value"],
			desc = L["Display owner of value in search results"],
			get = function() return ns.profile[modName].seeTaintByInSearchFunctions; end,
			set = function(_,v) ns.profile[modName].seeTaintByInSearchFunctions = v; end
		},
		header2 = {
			type = "header", order=4,
			name = L["Description for"].." search_key"
		},
		descSearchKey = {
			type = "description", order=5,
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
		header3 = {
			type = "header", order=6,
			name = L["Description for"].." search_value"
		},
		descSearchValue = {
			type = "description", order=7,
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
ns.modules[modName] = module;

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

function addSearchFunctions(bool)
	if bool then
		_G.search_key = search_key;
		_G.search_value = search_value;
	end
end

module.onload = function()
	addSearchFunctions(ns.profile[modName].addSearchFunctions);
	--_G.IsTaintByName = IsTaintByName;
end

