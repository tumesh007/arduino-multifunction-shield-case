import sys

# Original constants
enc_w = 117.6
enc_d = 91.4
wall = 3.0
bottom_t = 3.0

boss_od = 8.0
boss_r = boss_od / 2
boss_inset = wall + boss_r + 0.5
boss_cx = enc_w - boss_inset
boss_cy = enc_d - boss_inset

# Try shifting SPST in Y but negative offsets
batt_y = wall + 1.0  # wall + batt_clr
batt_l = 58.6
batt_clr = 1.0
spst_body_w = 21.0
spst_rear_depth = 22.0

spst_free_y_start = batt_y + batt_l + batt_clr

for offset in range(0, -10, -1):
    spst_panel_cy = spst_free_y_start + spst_body_w/2 + offset
    
    spst_min_x = enc_w - wall - spst_rear_depth
    spst_max_x = enc_w - wall
    spst_min_y = spst_panel_cy - spst_body_w / 2
    spst_max_y = spst_panel_cy + spst_body_w / 2

    # Check circle vs AABB
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
        print(f"SAFE at offset {offset}! spst_panel_cy = {spst_panel_cy:.2f}, dist_sq={dist_sq:.2f}, r2={boss_r**2}")
    else:
        print(f"Collision at offset {offset}, dist_sq={dist_sq:.2f}, r2={boss_r**2}")

