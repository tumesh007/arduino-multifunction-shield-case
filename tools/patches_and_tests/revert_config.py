with open("Arduino_Multifunction_Shield_Case/config.scad", "r") as f:
    content = f.read()

# Revert internal_d
old = """extra_rear_space = 10.0;
internal_d   = arduino_clr + arduino_l + arduino_clr + extra_rear_space;"""
new = "internal_d   = arduino_clr + arduino_l + arduino_clr;"
content = content.replace(old, new)

# Revert spst_panel_cy
old_spst = """spst_free_y_start = batt_y + batt_l + batt_clr + 2;
spst_free_y_end   = enc_d - wall - 2;
// Positioned right behind the battery to avoid the rear screw boss
spst_panel_cy     = batt_y + batt_l + batt_clr + spst_body_w/2 + 2.0;"""
new_spst = """spst_free_y_start = batt_y + batt_l + batt_clr + 2;
spst_free_y_end   = enc_d - wall - 2;
spst_panel_cy     = (spst_free_y_start + spst_free_y_end) / 2;"""
content = content.replace(old_spst, new_spst)

with open("Arduino_Multifunction_Shield_Case/config.scad", "w") as f:
    f.write(content)
