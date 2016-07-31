
local addon,ns=...;
local L=ns.L;
local order = 10;

ns.options = {
	type = "group",
	name = ns.L[addon],
	childGroups = "tree",
	args = { 
		-- general = { type = "group", name = "Options", args = {} }
	}
};

function ns.addModuleOptions(modName,modData)
	ns.options.args[modName] = {
		type = "group",
		name = modData.label,
		order = order,
		args = {},
	};
	if not modData.options_NoHeader then
		ns.options.args[modName].args.title = {order=1,type="header",name=modData.label};
	end
	if modData.desc then
		ns.options.args[modName].args.description ={
			type = "description", order = 2,
			name = modData.desc,
			fontSize = "small"
		}
	end
	local c = 10;
	if modData.options then
		for i,v in pairs(modData.options)do
			if v.order then
				v.order = v.order+c;
			else
				v.order = c;
				c=c+1;
			end
			ns.options.args[modName].args[i] = v;
		end
	end
	order=order+1;
end

function ns.RegisterOptionPanel()
	LibStub("AceConfig-3.0"):RegisterOptionsTable(L[addon], ns.options);
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(L[addon]);
end
