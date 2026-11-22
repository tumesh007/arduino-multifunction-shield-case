import sys
import math

wall = 3.0
batt_l = 58.6
batt_w = 43.6
arduino_l = 83.4
arduino_clr = 1.0

boss_od = 8.0
boss_r = boss_od / 2
boss_inset = wall + boss_r + 0.5

batt_clr = 1.0
batt_y = wall + batt_clr

spst_body_w = 21.0
spst_rear_depth = 22.0
spst_free_y_start = batt_y + batt_l + batt_clr + 2
# spst_panel_cy is now fixed!
spst_panel_cy = spst_free_y_start + spst_body_w/2

for extra in range(0, 20):
    internal_d = arduino_clr + arduino_l + arduino_clr + extra
    enc_w = 117.6
    enc_d = wall + internal_d + wall
    
    boss_cx = enc_w - boss_inset
    boss_cy = enc_d - boss_inset
    
    spst_min_x = enc_w - wall - spst_rear_depth
    spst_max_x = enc_w - wall
    spst_min_y = spst_panel_cy - spst_body_w / 2
    spst_max_y = spst_panel_cy + spst_body_w / 2

    test_x = boss_cx
    if boss_cx < spst_min_x: test_x = spst_min_x
    elif boss_cx > spst_max_x: test_x = spst_max_x

    test_y = boss_cy
    if boss_cy < spst_min_y: test_y = spst_min_y
    elif boss_cy > spst_max_y: test_y = spst_max_y

    dist_x = boss_cx - test_x
    dist_y = boss_cy - test_y
    dist_sq = dist_x**2 + dist_y**2
    
    if dist_sq >= boss_r**2:
        print(f"SAFE at extra={extra}! dist_sq={dist_sq:.2f}, enc_d={enc_d:.2f}, boss_cy={boss_cy:.2f}, spst_max_y={spst_max_y:.2f}")
        break
    else:
        print(f"Collision at extra={extra}, dist_sq={dist_sq:.2f}, spst_max_y={spst_max_y:.2f}, boss_cy={boss_cy:.2f}")
