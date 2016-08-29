
local addon,ns = ...; local L,C=ns.L,ns.LC.color;
local modName = "Bags&Banks";
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
		sort_buttons = {
			type = "group", order = 1,
			name = L["Blizzards sort buttons"],
			guiInline = true,
			args = {
				desc = {
					type = "description", order = 1,
					name = L["Info: This functions can be imcompatible with UIs like SuperVillain UI or ElvUI. Currently only tested with Blizzards default UI."]
				},
				bags_sort_button = {
					type = "select", order = 2,
					name = INVTYPE_BAG,
					values = valuesDefShowHide,
					get = function() return ns.get(modName,"bagsSort"); end,
					set = function(_,v)
						ns.set(modName,"bagsSort",v);
						updateSortButtons();
					end
				},
				bank_sort_button = {
					type = "select", order = 3,
					name = BANK.." & "..REAGENT_BANK,
					values = valuesDefShowHide,
					get = function() return ns.get(modName,"bankSort"); end,
					set = function(_,v)
						ns.get(modName,"bankSort",v);
						updateSortButtons();
					end
				},
				--[[ -- bank and reagent bank sort button are the same one
				rbank_sort_button = {
					type = "select", order = 4,
					name = REAGENT_BANK,
					values = valuesDefShowHide,
					get = function() return ns.get(modName,"rbankSort"); end,
					set = function(_,v)
						ns.get(modName,"rbankSort",v);
						updateSortButtons();
					end
				},
				--]]
				--[[ -- not exists...
				gbank_sort_button = {
					type = "select", order = 5,
					name = GUILD_BANK,
					values = valuesDefShowHide,
					get = function() return ns.get(modName,"gbankSort"); end,
					set = function(_,v)
						ns.get(modName,"gbankSort",v);
						updateSortButtons();
					end
				},
				--]]
			}
		}
	},
}
ns.modules[modName] = module;

local sortButtons = { -- evil sort buttons :)
	bagsSort = {name="BagItemAutoSortButton",touched=false},
	bankSort = {name="BankItemAutoSortButton",touched=false},
	--rbankSort = "ReagentBankItemAutoSortButton",
	--gbankSort = "GuildBankItemAutoSortButton",
}

function updateSortButtons()
	for k,v in pairs(sortButtons) do
		if type(_G[v.name])=="table" and (ns.profile[modName][k]~="default" or v.touched) then
			local e,s = true,true;
			if ns.profile[modName][k]=="hide" then
				s = false;
			elseif ns.profile[modName][k]=="disable" then
				e = false;
			end
			if e then
				_G[v.name]:Enable();
			else
				_G[v.name]:Disable();
			end
			_G[v.name]:GetNormalTexture():SetDesaturated(not e);
			_G[v.name]:GetPushedTexture():SetDesaturated(not e);
			_G[v.name]:SetShown(s);
			if not v.touched then
				hooksecurefunc(_G[v.name],"Show",function(self)
					if ns.profile[modName][k]=="hide" then
						self:Hide();
					end
				end);
			end
			v.touched = true;
		end
		--ns.debug("udpateSortButtons",v.name,v.touched);
	end
end

module.onload = function()
	updateSortButtons();
end
