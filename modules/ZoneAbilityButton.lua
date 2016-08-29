
local addon,ns = ...; local L,C=ns.L,ns.LC.color;
local modName = "ZoneAbilityButton";
local updateButtons;
local buttons = {};
local module = {
	label = "Zone Ability Button",
	desc = nil,
	events = nil,
	config = {},
	options = {
		desc = {
			type = "description", order = 0,
			name = L["Do you have a problem to find blizzards zone ability button on your action bars?"],
			fontSize = "medium"
		},
		getFromActionBar = {
			type = "execute", order = 1, width = "full",
			name = L["Click me!"],
			desc = L["Push this button and this function search on your action bars placed zone ability spell and drag the first from the bar and put on mouse cursor. (multi exebutable)"],
			func = function()
				local _,SpellID;
				local frame = DraenorZoneAbilityFrame or ZoneAbilityFrame; -- wod and legion frame name.
				if frame and frame.baseName then
					_,_,_,_,_,_,SpellID = GetSpellInfo(frame.baseName);
				end
				if SpellID then
					for ActionSlot=1, 120 do
						local ActionType,ActionID=GetActionInfo(ActionSlot);
						if ActionType=="spell" and ActionID==SpellID then
							PickupAction(ActionSlot);
						end
					end
				end
			end
		}
	}
}
ns.modules[modName] = module;
