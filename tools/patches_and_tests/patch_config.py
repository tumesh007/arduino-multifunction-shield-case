import sys

with open("Arduino_Multifunction_Shield_Case/config.scad", "r") as f:
    content = f.read()

# 1. Update internal_d calculation to add extra_rear_space
old_internal_d = "internal_d   = arduino_clr + arduino_l + arduino_clr;"
new_internal_d = """extra_rear_space = 10.0;
internal_d   = arduino_clr + arduino_l + arduino_clr + extra_rear_space;"""

if old_internal_d in content:
    content = content.replace(old_internal_d, new_internal_d)
else:
    print("Could not find old_internal_d")
    sys.exit(1)

# 2. Update spst_panel_cy calculation
old_spst = """spst_free_y_start = batt_y + batt_l + batt_clr + 2;
spst_free_y_end   = enc_d - wall - 2;
spst_panel_cy     = (spst_free_y_start + spst_free_y_end) / 2;"""

new_spst = """spst_free_y_start = batt_y + batt_l + batt_clr + 2;
spst_free_y_end   = enc_d - wall - 2;
// Positioned right behind the battery to avoid the rear screw boss
spst_panel_cy     = batt_y + batt_l + batt_clr + spst_body_w/2 + 2.0;"""

if old_spst in content:
    content = content.replace(old_spst, new_spst)
else:
    print("Could not find old_spst")
    sys.exit(1)

with open("Arduino_Multifunction_Shield_Case/config.scad", "w") as f:
    f.write(content)

print("config.scad patched.")
