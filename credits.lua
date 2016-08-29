
local addon,ns = ...;
local C,L = ns.LC.color,ns.L;
local count = 1;

ns.options.args.credits = {
	type = "group",
	name = L["Credits"],
	guiInline = true,
	order = 100001,
	args = {}
};

local function addCredit(names, color, titleExtra, description)
	local str,colors,color = "",color,color[1];
	color = colors[1];
	for i,v in ipairs(names)do
		if not colors[i] then
			colors[i] = color;
		end
		names[i] = C(colors[i],v);
	end
	if count>1 then
		str = " |n";
	end
	ns.options.args.credits.args["credit"..count] = {
		type = "description", order = count,
		name = str..table.concat(names," / ") .. (titleExtra and " ".. C("dkyellow","("..titleExtra..")") or "") .. "|n   " .. C("silver",description),
		fontSize = "medium"
	}
	count = count + 1;
end

addCredit(
	{"liquidbase","Merith"},
	{"cyan","deathknight"},
	"Author of DuffedUI",
	"For idea and first code to add quest level to quest tracker :)"
);

addCredit(
	{"pas06"},
	{"cyan"},
	nil,
	"For idea to the keystroke replace function"
);
