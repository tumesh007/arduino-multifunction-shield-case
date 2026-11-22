import sys

with open("Arduino_Multifunction_Shield_Case/config.scad", "r") as f:
    content = f.read()

# We know moving spst_panel_cy to 69.1 clears the rear screw boss.
# BUT we have an assert:
# assert(spst_panel_cy - spst_body_w/2 > batt_y + batt_l + batt_clr)
# batt_y = 3+1 = 4
# batt_l = 58.6
# batt_clr = 1.0
# sum = 63.6
# spst_panel_cy - 21.0/2 = 69.1 - 10.5 = 58.6.
# Wait! 58.6 > 63.6 is False! It would overlap the battery!
print("Cannot shift negative without hitting battery!")
