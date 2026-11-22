import sys

with open("Arduino_Multifunction_Shield_Case/config.scad", "r") as f:
    content = f.read()

# Instead of blindly centering the SPST panel, push it as far forward as possible 
# without hitting the battery.

old_spst = """spst_free_y_start = batt_y + batt_l + batt_clr + 2;
spst_free_y_end   = enc_d - wall - 2;
spst_panel_cy     = (spst_free_y_start + spst_free_y_end) / 2;"""

new_spst = """spst_free_y_start = batt_y + batt_l + batt_clr + 2;
spst_free_y_end   = enc_d - wall - 2;
// Push SPST as far forward as possible to maximize distance from rear screw boss
spst_panel_cy     = spst_free_y_start + spst_body_w/2;"""

content = content.replace(old_spst, new_spst)

with open("Arduino_Multifunction_Shield_Case/config.scad", "w") as f:
    f.write(content)

print("Patched SPST Y position.")
