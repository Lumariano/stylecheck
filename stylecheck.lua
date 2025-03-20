addon.name = "stylecheck";
addon.author = "Lumaro";
addon.version = "1.0";
addon.desc = "Tries to guess what players, NPCs and some mobs are wearing";
addon.link = "https://github.com/Lumariano/stylecheck";

require("common");
local chat = require("chat");
local lsb = require("lsb");

local looks_path = ("%saddons\\stylecheck\\looks\\"):fmt(AshitaCore:GetInstallPath());

local function get_entity_type(entity)
    if (entity.SpawnFlags == 0x001) then
        return "PC";
    elseif (entity.SpawnFlags == 0x20D) then
        return "Local PC";
    elseif (entity.SpawnFlags == 0x010) then
        return "Mob";
    elseif (entity.Type == 1) then
        return "NPC";
    elseif (entity.Type == 2) then
        return "Object";
    elseif (entity.Type == 3) then
        return "Door";
    else
        return "Unknown";
    end
end

ashita.events.register("unload", "unload_cb", function ()
    ashita.fs.remove(looks_path)
end);

ashita.events.register("command", "command_cb", function (e)
    if (e.command ~= "/stylecheck") then
        return;
    end

    local target = AshitaCore:GetMemoryManager():GetTarget();
    local target_index = target:GetTargetIndex(0);
    if (target_index == 0) then
        print(chat.header(addon.name):append(chat.error("No target selected.")));
        return;
    end

    local entity = GetEntity(target_index);

    local entity_type = get_entity_type(entity);
    if (not entity_type:any("PC", "Local PC", "NPC", "Mob")) then
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

    for slot, model_ids in pairs(lsb) do
        f:write(("%s slot could be:\n"):fmt(slot));

        local model_id = bit.band(entity.Look[slot], 0x0FFF);
        local items = model_ids[model_id];

        if (not items) then
            f:write(("\tUNKNOWN MODEL\n\n"));
        elseif (items == "NO MODEL") then
            f:write(("\t%s\n\n"):fmt(items));
        else
            for item_id, item_name in pairs(items) do
                f:write(("\t%s:\n\t\thttps://www.bg-wiki.com/ffxi/%s\n\t\thttps://www.ffxiah.com/item/%s\n\n"):fmt(item_name, item_name:gsub(" ", "_"), item_id));
            end
        end
        f:write("\n");
    end
    f:close();

    ashita.misc.execute(outfile_path, "");
end);
