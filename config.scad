// config.scad — Single Source of Truth
// Arduino Multifunction Shield Enclosure

// ─── Build Volume (Bambu Lab A1 Mini) ───
build_max_x = 180;
build_max_y = 180;
build_max_z = 180;

// ─── General Enclosure ───
wall         = 3.0;
bottom_t     = 3.0;
top_t        = 3.0;
corner_r     = 5.0;
general_clr  = 0.3;
press_clr    = 0.15;

// ─── Arduino Uno ───
arduino_l    = 83.4;
arduino_w    = 62.0;
arduino_h    = 19.4;
arduino_clr  = 1.0;
rail_h       = 3.0;
rail_w       = 2.0;

// ─── Multifunction Shield ───
shield_h     = 12.2;

// ─── Battery ───
batt_l       = 58.6;
batt_w       = 43.6;
batt_h       = 29.9;
batt_clr     = 1.0;
batt_wall    = 1.5;

// ─── Divider ───
divider_t    = 2.0;
cable_pass_w = 12.0;
cable_pass_h = 10.0;

// ─── SPST Rocker Switch ───
spst_cutout_w = 19.9;
spst_cutout_h = 12.0;
spst_rear_depth = 22.0;
spst_body_w  = 21.0;
spst_body_h  = 15.0;
spst_clr     = 0.3;

// ─── DC Power Connector ───
dc_dia       = 5.0;
dc_body_len  = 33.0;
dc_mount_dia = 8.0;
dc_clr       = 0.3;
dc_nut_flat  = 10.0;

// ─── Buttons (relative to shield top-left) ───
btn_dia      = 5.0;
btn_h        = 4.8;
btn_travel   = 1.0;
btn_clr      = 0.3;

btn1_x       = 14.7;
btn1_y       = 14.0;
btn2_x       = 24.1;
btn2_y       = 14.0;
btn3_x       = 33.4;
btn3_y       = 14.1;

// ─── Display ───
disp_w       = 30.2;
disp_h       = 14.3;
disp_tl_x    = 18.3;
disp_tl_y    = 58.9;
disp_clr     = 0.5;
bezel_depth  = 1.0;
bezel_width  = 1.5;

// ─── Buzzer ───
buzz_dia     = 15.0;
buzz_cx      = 23.8;
buzz_cy      = 37.5;
buzz_h       = 9.0;
grille_slot_w = 1.2;
grille_spoke_w = 1.5;
grille_rings = 3;

// ─── Screws (M3) ───
screw_dia    = 3.0;
screw_clr_dia = 3.3;
screw_boss_od = 8.0;
screw_boss_id = 2.5;
screw_cb_dia = 6.0;
screw_cb_depth = 2.0;
screw_len    = 12.0;

// ─── Rubber Feet ───
foot_dia     = 8.0;
foot_h       = 1.5;
foot_inset   = 8.0;

// ─── Ventilation ───
vent_slot_w  = 1.5;
vent_slot_h  = 8.0;
vent_gap     = 2.5;
vent_count   = 6;
vent_z_offset = 8.0;

// ─── Cable Management ───
cable_ch_w   = 6.0;
cable_ch_d   = 3.0;
wire_route_r = 2.0;

// ─── Lip/overlap ───
lip_h        = 2.0;
lip_inset    = 1.5;

// ═══════════════════════════════════════════
// DERIVED DIMENSIONS
// ═══════════════════════════════════════════

arduino_x    = wall + arduino_clr;
arduino_y    = wall + arduino_clr;
arduino_z    = bottom_t;

batt_x       = wall + arduino_clr + arduino_w + arduino_clr + divider_t + batt_clr;
batt_y       = wall + batt_clr;
batt_z       = bottom_t;

internal_w   = arduino_clr + arduino_w + arduino_clr + divider_t
             + batt_clr + batt_w + batt_clr;
internal_d   = arduino_clr + arduino_l + arduino_clr + 7.0;

stack_h      = arduino_h + shield_h;
top_clr      = 9.0;  // clearance above shield — also gives room for DC connector above battery
internal_h   = max(stack_h + top_clr, batt_h + 2.0);

enc_w        = wall + internal_w + wall;
enc_d        = wall + internal_d + wall;
enc_h        = bottom_t + internal_h + top_t;

base_h_val   = enc_h - top_t;

shield_top_z = arduino_z + stack_h;

function shield_to_enc_x(sx) = arduino_x + sx;
function shield_to_enc_y(sy) = arduino_y + sy;

// ─── Screw boss positions ───
boss_inset   = wall + screw_boss_od/2 + 0.5;
screw_positions = [
    [boss_inset,           boss_inset,           0],
    [enc_w - boss_inset,   boss_inset,           0],
    [boss_inset,           enc_d - boss_inset,   0],
    [enc_w - boss_inset,   enc_d - boss_inset,   0]
];

// ─── SPST on right side wall ───
// Positioned in the free zone behind the battery (Y > batt_y + batt_l + batt_clr)
spst_free_y_start = batt_y + batt_l + batt_clr + 2;
spst_free_y_end   = enc_d - wall - 2;
// Push SPST as far forward as possible to maximize distance from rear screw boss
spst_panel_cy     = spst_free_y_start + spst_body_w/2;
spst_panel_cz     = bottom_t + internal_h / 2;

// ─── DC connector on rear wall ───
// Positioned in battery-side X range, raised above battery
dc_panel_cx   = batt_x + batt_w / 2;
dc_panel_cz   = base_h_val - dc_mount_dia/2 - 1;  // near top of base

// ═══════════════════════════════════════════
// ASSERTIONS
// ═══════════════════════════════════════════
assert(enc_w <= build_max_x, str("Width ", enc_w, " > build!"));
assert(enc_d <= build_max_y, str("Depth ", enc_d, " > build!"));
assert(enc_h <= build_max_z, str("Height ", enc_h, " > build!"));
assert(wall >= 1.2);
assert(bottom_t >= 1.2);
assert(top_t >= 1.2);
assert(internal_h >= stack_h + 1.0, "Shield headroom!");
assert(internal_h >= batt_h + 1.0, "Battery headroom!");
assert(spst_rear_depth >= 20, "SPST rear depth < 20!");

// Buttons within shield
assert(btn1_x >= 0 && btn1_x <= arduino_w);
assert(btn2_x >= 0 && btn2_x <= arduino_w);
assert(btn3_x >= 0 && btn3_x <= arduino_w);
assert(btn1_y >= 0 && btn1_y <= arduino_l);
assert(btn2_y >= 0 && btn2_y <= arduino_l);
assert(btn3_y >= 0 && btn3_y <= arduino_l);

// Display within shield
assert(disp_tl_x >= 0 && disp_tl_x + disp_w <= arduino_w);
assert(disp_tl_y >= 0 && disp_tl_y + disp_h <= arduino_l);

// Buzzer within shield
assert(buzz_cx - buzz_dia/2 >= 0);
assert(buzz_cx + buzz_dia/2 <= arduino_w);
assert(buzz_cy - buzz_dia/2 >= 0);
assert(buzz_cy + buzz_dia/2 <= arduino_l);

// SPST within right wall bounds
assert(spst_panel_cy - spst_cutout_w/2 > wall, "SPST Y beyond front wall!");
assert(spst_panel_cy + spst_cutout_w/2 < enc_d - wall, "SPST Y beyond rear wall!");
assert(spst_panel_cz - spst_cutout_h/2 > bottom_t, "SPST Z below floor!");
assert(spst_panel_cz + spst_cutout_h/2 < base_h_val, "SPST Z above top!");

// SPST body must not overlap battery (Y check)
assert(spst_panel_cy - spst_body_w/2 > batt_y + batt_l + batt_clr,
       str("SPST body overlaps battery! SPST Y start: ", spst_panel_cy - spst_body_w/2,
           " Battery Y end: ", batt_y + batt_l + batt_clr));

// DC connector within rear wall bounds
assert(dc_panel_cx - dc_mount_dia/2 > wall, "DC X too small!");
assert(dc_panel_cx + dc_mount_dia/2 < enc_w - wall, "DC X too large!");
assert(dc_panel_cz - dc_mount_dia/2 > bottom_t, "DC Z below floor!");
assert(dc_panel_cz + dc_mount_dia/2 < base_h_val, "DC Z above top!");

// DC body must not hit battery (vertical check)
assert(dc_panel_cz - (dc_dia + 2)/2 > batt_z + batt_h,
       str("DC body intersects battery! DC bottom: ", dc_panel_cz - (dc_dia+2)/2,
           " Battery top: ", batt_z + batt_h));

// DC body length fits inside enclosure depth
assert(dc_body_len < internal_d, str("DC body ", dc_body_len, " > internal depth ", internal_d));

echo(str("Enclosure: ", enc_w, " x ", enc_d, " x ", enc_h, " mm"));
echo(str("Internal:  ", internal_w, " x ", internal_d, " x ", internal_h, " mm"));
echo(str("Stack: ", stack_h, " mm  Headroom: ", internal_h - stack_h, " mm"));
echo(str("SPST panel: Y=", spst_panel_cy, " Z=", spst_panel_cz));
echo(str("DC panel: X=", dc_panel_cx, " Z=", dc_panel_cz));
