
local addon,ns = ...; local L,C=ns.L,ns.LC.color;
local modName = "UndressButtons";
local updateButtons;
local buttons = {};
local module = {
	label = "Undress buttons",
	desc = nil,
	events = nil, --{},
	config = {
		showUndressButtons = true
	},
	options = {
		showUndressButtons = {
			type = "toggle",
			name = L["Show Undress buttons"],
			desc = L["Display Undress buttons on DressUpFrames"],
			get = function() return ns.profile[modName].showUndressButtons; end,
			set = function(_,v) ns.profile[modName].showUndressButtons = v; updateButtons(v); end,
		}
	}
}
ns.modules[modName] = module;

function updateButtons(bool)
	for i=1, #buttons do
		buttons[i]:SetShown(bool);
	end
end

local function add(parent,model,point,pointLevel)
	local button = CreateFrame("Button",parent.."_HTB_UndressButton",_G[parent],"UIPanelButtonTemplate");
	button:Hide();
	button:SetWidth(80);
	button:SetText("Undress");
	button:SetPoint(unpack(point));
	button:SetScript("OnClick",function() _G[model]:Undress(); end);
	if pointLevel then button:SetFrameLevel(point[2]:GetFrameLevel()); end
	tinsert(buttons,button);
end

module.onload = function()
	if DressUpFrame and not DressUpFrameUndressButton then
		add("DressUpFrame","DressUpModel",{"TOPLEFT",DressUpModel,"BOTTOMLEFT",-4,-4});
	end
	if SideDressUpFrame and not SideDressUpFrameUndressButton then
		-- Undress button for smaller dress up frame (auction house and void storage)
		add("SideDressUpFrame","SideDressUpModel",{"TOP",SideDressUpModelResetButton,"BOTTOM",0,-4},true);
	end
	updateButtons(ns.profile[modName].showUndressButtons);
end

