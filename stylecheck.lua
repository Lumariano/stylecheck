addon.name = "stylecheck";
addon.author = "Lumaro";
addon.version = "1.0";
addon.desc = "Shows you some possibilities for what your target could be wearing.";
addon.link = "https://github.com/Lumariano/stylecheck";

require("common");
local chat = require("chat");
local lsb = require("lsb");

local ordered_slots = {
    "Main",
    "Sub",
    "Ranged",
    "Head",
    "Body",
    "Hands",
    "Legs",
    "Feet",
};
local looks_path = ("%saddons\\stylecheck\\looks\\"):fmt(AshitaCore:GetInstallPath());

ashita.events.register("unload", "unload_cb", function ()
    ashita.fs.remove(looks_path)
end);

ashita.events.register("command", "command_cb", function (e)
    if (e.command ~= "/stylecheck") then
        return;
    end

    e.blocked = true;
    local target_index = AshitaCore:GetMemoryManager():GetTarget():GetTargetIndex(0);

    if (target_index == 0) then
        print(chat.header(addon.name):append(chat.error("No target selected.")))
        return;
    end

    local entity = GetEntity(target_index);

    if (not entity.Race:within(1, 8)) then
        print(chat.header(addon.name):append(chat.error("Target >>%s<< will have no look."):fmt(entity.Name)));
        return;
    end

    if (not ashita.fs.exists(looks_path)) then
        if (not ashita.fs.create_dir(looks_path)) then
            print(chat.header(addon.name):append(chat.error("Can't create directory %s"):fmt(looks_path)));
            return;
        end
    end
    
    local outfile_path = ("%s%s.txt"):fmt(looks_path, entity.Name);
    local f, err = io.open(outfile_path , "w");

    if (not f) then
        print(chat.header(addon.name):append(chat.error("Can't create file %s: %s"):fmt(outfile_path, err)));
        return;
    end

    for entry, slot in ipairs(ordered_slots) do
        f:write(("---- [%s] %s"):fmt(slot, string.rep("-", 71 - #slot)));
        local model_id = bit.band(entity.Look[slot], 0x0FFF);
        local items = lsb[slot][model_id];

        if (not items) then
            f:write("\n\n\tUNKNOWN MODEL");
        elseif (type(items) == "string") then
            f:write(("\n\n\t%s"):fmt(items));
        else
            for item_id, item_name in pairs(items) do
                f:write(("\n\n\t%s"):fmt(item_name));
                f:write(("\n\t\thttps://www.bg-wiki.com/ffxi/%s"):fmt(item_name:gsub(" ", "_")));
                f:write(("\n\t\thttps://www.ffxiah.com/item/%s"):fmt(item_id))
            end
        end

        if (entry ~= #ordered_slots) then
            f:write("\n\n");
        end
    end

    f:close();
    ashita.misc.execute(outfile_path, "");
end);
