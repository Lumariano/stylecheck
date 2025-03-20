import re
from datetime import datetime

from big_slpp import slpp
from big_slpp.utils import order_dict


LSB_INFILE = "item_equipment.sql"
VALUES_PATTERN = r"\((.*?)\);"
ROMAN_PATTERN = r"(.*? )([ivIV]+)$"
SLOT_NAME_MAP = {
    "1": "Main",  # Hand-to-Hand weapons
    "2": "Sub",
    "3": "Main",  # Everything else
    "4": "Ranged",
    "16": "Head",
    "32": "Body",
    "64": "Hands",
    "128": "Legs",
    "256": "Feet",
}


def main():
    with open(LSB_INFILE, "r") as f:
        content = f.read()

    data = {
        "Main": {0: "NO MODEL"},
        "Sub": {0: "NO MODEL"},
        "Ranged": {0: "NO MODEL"},
        "Head": {0: "NO MODEL"},
        "Body": {0: "NO MODEL"},
        "Hands": {0: "NO MODEL"},
        "Legs": {0: "NO MODEL"},
        "Feet": {0: "NO MODEL"},
    }

    values_matches = re.findall(VALUES_PATTERN, content)

    for value_match in values_matches:
        values = value_match.split(",")
        
        slot_id = values[8]
        if slot_id not in SLOT_NAME_MAP:
            continue
        slot_name = SLOT_NAME_MAP[slot_id]

        model_id = int(values[5])
        if model_id == 0:
            continue

        item_id = int(values[0])

        item_name = values[1].strip("'").replace("_", " ").title()
        roman_match = re.search(ROMAN_PATTERN, item_name)
        if roman_match:
            item_name = roman_match.group(1) + roman_match.group(2).upper()

        if model_id not in data[slot_name]:
            data[slot_name][model_id] = { item_id: item_name }
        else:
            data[slot_name][model_id][item_id] = item_name
    
    for slot, model_ids in data.items():
        data[slot] = order_dict(model_ids)
    
    timestamp = datetime.now()
    lua_str = f"-- Parsed on {timestamp}\nreturn {slpp.encode(data)};"
    with open("lsb.lua", "w") as f:
        f.write(lua_str)


if __name__ == "__main__":
    main()