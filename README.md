# stylecheck
This is an addon for Ashitav4 that will show you some possible options for what players, NPCs and even some mobs are wearing.
### Usage
* `/stylecheck`: Writes a file for your current target containing every possible item it could be wearing for every slot.
The file will be written under `<ashita_root>/addons/stylecheck/looks/<entity_name>.txt` and should be automatically opened.
This command will fail on any target that isnt a player, NPC or mob.

**Note**: `<ashita_root>/addons/stylecheck/looks/` containing the appearance of the entities you have checked will be deleted upon unloading the addon.
## Model-to-item mapping
For this addon to work, a model-to-item mapping is required. A mapping is already included, for which I've used the dataset from [LSB](https://github.com/LandSandBoat/server).
If you want to create your own mapping download [item_equipment.sql](https://github.com/LandSandBoat/server/blob/base/sql/item_equipment.sql) from LSB and run `lsb_parse.py` with it in the same directory to create `lsb.lua` containing the model-to-item mapping.

**Note**: `lsb_parse.py` requires `big-slpp` to run, which can be installed via pip using `pip install big-slpp`
