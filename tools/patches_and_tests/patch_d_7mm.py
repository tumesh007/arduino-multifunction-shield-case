import sys

with open("Arduino_Multifunction_Shield_Case/config.scad", "r") as f:
    content = f.read()

old_d = "internal_d   = arduino_clr + arduino_l + arduino_clr;"
new_d = "internal_d   = arduino_clr + arduino_l + arduino_clr + 7.0;"

if old_d in content:
    content = content.replace(old_d, new_d)
else:
    print("Could not find old_d")
    sys.exit(1)

with open("Arduino_Multifunction_Shield_Case/config.scad", "w") as f:
    f.write(content)

print("Added 7.0mm extra depth to resolve SPST-vs-screw boss collision.")
