import sys

with open("Arduino_Multifunction_Shield_Case/fc_audit.py", "r") as f:
    content = f.read()

content = content.replace("abs(bd-91.4)<0.5", "abs(bd-98.4)<0.5")
content = content.replace("Depth   91.4:", "Depth   98.4:")
content = content.replace("abs(td-87.8)<1", "abs(td-94.8)<1")
content = content.replace("Top D  87.8:", "Top D  94.8:")

with open("Arduino_Multifunction_Shield_Case/fc_audit.py", "w") as f:
    f.write(content)
