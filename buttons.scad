// ============================================================================
// File: buttons.scad (Compact Stadium-Flexure Integrated Plunger Buttons)
// Engineered for 9.2 mm center-to-center pitch with zero neighbor interference
// Datum: Z = 0 is Internal Surface of Top Plate; Z = top_plate_t is Outer Face
// ============================================================================
include <config.scad>

module integrated_button_cutout(bx, by) {
    cap_r = btn_cap_d / 2;

    translate([bx, by, -EPS]) {
        difference() {
            scale([1.0, btn_bore_ry / btn_bore_rx, 1.0])
                cylinder(r = btn_bore_rx, h = top_plate_t + 2*EPS);
            cylinder(r = cap_r, h = top_plate_t + 2*EPS);
            for (sy = [-1, 1]) {
                translate([-btn_flexure_w/2, sy * (cap_r - 0.2) + (sy < 0 ? -(btn_bore_ry - cap_r + 0.4) : 0), 0])
                    cube([btn_flexure_w, btn_bore_ry - cap_r + 0.4, top_plate_t + 2*EPS]);
            }
        }
    }
}

module integrated_button_solid(bx, by, sw_h) {
    plen  = calc_plunger_length(sw_h);
    cap_r = btn_cap_d / 2;

    translate([bx, by, 0]) {
        for (sy = [-1, 1]) {
            translate([-btn_flexure_w/2, sy < 0 ? -btn_bore_ry : cap_r - 0.2, top_plate_t - btn_flexure_t])
                cube([btn_flexure_w, btn_bore_ry - cap_r + 0.2, btn_flexure_t]);
        }
        if (btn_use_sacrificial) {
            for (sx = [-1, 1]) {
                translate([sx < 0 ? -btn_bore_rx : cap_r - 0.1, -btn_sacrificial_tie/2, top_plate_t - 0.4])
                    cube([btn_bore_rx - cap_r + 0.1, btn_sacrificial_tie, 0.4]);
            }
        }
        cylinder(d = btn_cap_d, h = top_plate_t);
        translate([0, 0, -plen]) {
            cylinder(d1 = btn_plunger_d - 0.6, d2 = btn_plunger_d, h = 0.8);
            translate([0, 0, 0.8 - EPS])
                cylinder(d = btn_plunger_d, h = plen - 0.8 + EPS);
            translate([0, 0, plen - 1.2])
                cylinder(d1 = btn_plunger_d, d2 = btn_plunger_d + 1.2, h = 1.2 + EPS);
        }
    }
}
