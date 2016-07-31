
local addon,ns = ...; local L,C=ns.L,ns.LC.color;
local modName = "Bags&Banks";
local get,set;
local valuesDefShowHide = {
	default = DEFAULT,
	disable = DISABLE,
	hide = HIDE
}

local module = {
	label = "Bags & Banks",
	desc = nil,
	events = nil, --{},
	config = {
		bagsSort = "default",
		bankSort = "default",
		--gbankSort = "default",
		--rbankSort = "default",
	},
	options_NoHeader = true,
	options = {
		header_sort_buttons = {
			type = "header", order = 1,
			name = L["Blizzards sort buttons"]
		},
		bags_sort_button = {
			type = "select", order = 2,
			name = INVTYPE_BAG,
			values = valuesDefShowHide,
			get = function() return ns.profile[modName].bagsSort; end,
			set = function(_,v)
				ns.profile[modName].bagsSort = value;
				updateSortButtons();
			end
		},
		bank_sort_button = {
			type = "select", order = 3,
			name = BANK.." & "..REAGENT_BANK,
			values = valuesDefShowHide,
			get = function() return ns.profile[modName].bankSort; end,
			set = function(_,v)
				ns.profile[modName].bankSort = v;
				updateSortButtons();
			end
		},
		--[[
		rbank_sort_button = {
			type = "select", order = 4,
			name = REAGENT_BANK,
			values = valuesDefShowHide,
			get = function() return ns.profile[modName].rbankSort; end,
			set = function(_,v)
				ns.profile[modName].rbankSort = v;
				updateSortButtons();
			end
		},
		--]]
		--[[
		gbank_sort_button = {
			type = "select", order = 5,
			name = GUILD_BANK,
			values = valuesDefShowHide,
			get = function() return ns.profile[modName].gbankSort; end,
			set = function(_,v)
				ns.profile[modName].gbankSort = v;
				updateSortButtons();
			end
		},
		--]]
	},
}
ns.modules[modName] = module;

local sortButtons = { -- evil sort buttons :)
	bagsSort = "BagItemAutoSortButton",
	bankSort = "BankItemAutoSortButton",
	--rbankSort = "ReagentBankItemAutoSortButton",
	--gbankSort = "GuildBankItemAutoSortButton",
}

local function updateSortButtons(OnLoad)
	for k,v in pairs(sortButtons) do
		local e,s = true,true;
		if ns.profile[modName][k]=="hide" then
			s = false;
		elseif ns.profile[modName][k]=="disable" then
			e = false;
		end
		if e then
			_G[v]:Enable();
		else
			_G[v]:Disable();
		end
		_G[v]:GetNormalTexture():SetDesaturated(not e);
		_G[v]:GetPushedTexture():SetDesaturated(not e);
		_G[v]:SetShown(s);
		if OnLoad then
			hooksecurefunc(_G[v],"Show",function(self)
				if ns.profile[modName][k]=="hide" then
					self:Hide();
				end
			end);
		end
	end
end

function get(key)
	return ns.profile[modName][key];
end

function set(key,value)
	ns.profile[modName][key] = value;
	updateSortButtons();
end

module.onload = function()
	updateSortButtons(true);
end
