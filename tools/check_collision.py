import sys
import re

def get_val(content, var):
    m = re.search(r"echo\(\"" + var + r"=([0-9.]+)", content)
    if m:
        return float(m.group(1))
    return None

enc_w = 117.6
enc_d = 91.4 + 7.0  # From manual patch
wall = 3.0

boss_od = 8.0
boss_r = boss_od / 2
boss_inset = wall + boss_r + 0.5
boss_cx = enc_w - boss_inset
boss_cy = enc_d - boss_inset
print(f"Rear-right screw boss center: ({boss_cx:.2f}, {boss_cy:.2f}), radius {boss_r:.2f}")

batt_y = wall + 1.0
batt_l = 58.6
batt_clr = 1.0
spst_body_w = 21.0
spst_rear_depth = 22.0
spst_free_y_start = batt_y + batt_l + batt_clr + 2
spst_panel_cy = spst_free_y_start + spst_body_w/2

spst_min_x = enc_w - wall - spst_rear_depth
spst_max_x = enc_w - wall
spst_min_y = spst_panel_cy - spst_body_w / 2
spst_max_y = spst_panel_cy + spst_body_w / 2

print(f"SPST body X: {spst_min_x:.2f} to {spst_max_x:.2f}")
print(f"SPST body Y: {spst_min_y:.2f} to {spst_max_y:.2f}")

test_x = boss_cx
if boss_cx < spst_min_x: test_x = spst_min_x
elif boss_cx > spst_max_x: test_x = spst_max_x

test_y = boss_cy
if boss_cy < spst_min_y: test_y = spst_min_y
elif boss_cy > spst_max_y: test_y = spst_max_y

dist_x = boss_cx - test_x
dist_y = boss_cy - test_y
dist_sq = dist_x**2 + dist_y**2

if dist_sq < boss_r**2:
    print(f"COLLISION! Squared distance {dist_sq:.2f} < radius squared {boss_r**2:.2f}")
else:
    print(f"SAFE. Squared distance {dist_sq:.2f} >= radius squared {boss_r**2:.2f}")
