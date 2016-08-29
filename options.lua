
local addon,ns=...;
local L,C=ns.L,ns.LC.color;
local order,orderSub = 10,1;

ns.options = {
	type = "group",
	name = L[addon],
	childGroups = "tree",
	args = { 
		-- general = { type = "group", name = "Options", args = {} }
		--[[
		credits_separator = {
			type = "group",
			name = " ",
			order = 100000,
			disabled = true,
			args = {},
		},
		--]]
	}
};
ns.options_subpanels = {
	
};
ns.options_subpanels_count = 0;

local function separators(tbl,mod)
	for k,v in pairs(tbl.args)do
		if k:match("^separator%d+$") then
			v.type = "description";
			v.name = " ";
			v.fontSize = v.size or "small";
			v.size = nil;
		elseif v.args then
			separators(v,mod.."/"..k); -- recursive
		end
	end
end

function ns.addModuleOptions(modName,modData)
	local tbl = ns.options;
	if modData.options_subpanel ~= false then
		if not ns.options_subpanels[modName] then
			ns.options_subpanels[modName] = {
				type = "group", order = orderSub,
				name = modData.label,
				childGroups = "tab",
				args = {}
			};
		end
		tbl = ns.options_subpanels[modName];
		ns.options_subpanels_count  = ns.options_subpanels_count+1;
		orderSub = orderSub + 1;
	else
		if modData.options_prependingSeparator then
			ns.options.args[modName.."_separator"] = {
				type = "group",
				name = " ",
				order = order,
				disabled = true,
				args = {},
			}
			order=order+1;
		end
		if not ns.options.args[modName] then
			ns.options.args[modName] = {
				type = "group",
				name = modData.label,
				order = order,
				args = {},
			};
		end
		tbl = ns.options.args[modName];
		if not modData.options_NoHeader then
			tbl.args.title = {
				order=1,
				type="description",
				name=C("dkyellow",modData.label),
				fontSize = "large"
			};
		end
	end

	if modData.desc then
		tbl.args.description ={
			type = "description", order = 2,
			name = modData.desc,
			fontSize = "small"
		}
	end
	local c = 10;
	if modData.options then
		if modData.options_childGroups then
			tbl.childGroups = modData.options_childGroups;
		end
		for k,v in pairs(modData.options)do
			if v.order then
				v.order = v.order+c;
			else
				v.order = c;
				c=c+1;
			end
			tbl.args[k] = v;
		end
		separators(tbl,modName);
	end
	order=order+1;
end

function ns.RegisterOptionPanel()
	LibStub("AceConfig-3.0"):RegisterOptionsTable(L[addon], ns.options);
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(L[addon]);
	if ns.options_subpanels_count>0 then
		for modName,modOptions in ns.pairsByKeys(ns.options_subpanels)do
			LibStub("AceConfig-3.0"):RegisterOptionsTable(modName, modOptions);
			LibStub("AceConfigDialog-3.0"):AddToBlizOptions(modName,modOptions.name,L[addon]);
		end
	end
end
