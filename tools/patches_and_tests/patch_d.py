import sys

with open("Arduino_Multifunction_Shield_Case/config.scad", "r") as f:
    content = f.read()

old_d = "internal_d   = arduino_clr + arduino_l + arduino_clr;"
# Add just enough extra depth at the rear. 
# We need enc_d to increase so the boss moves back.
# boss_cy = enc_d - boss_inset
# We found in previous test that adding 10mm to internal_d worked (but was probably too much).
# Let's find the minimum extra space.
