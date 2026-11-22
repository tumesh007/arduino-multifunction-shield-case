// ============================================================================
// File: utilities.scad
// ============================================================================
include <config.scad>

module rounded_rect_2d(w, d, r) {
    offset(r = r)
        offset(delta = -r)
            square([w, d], center = false);
}

module rounded_box(w, d, h, r) {
    linear_extrude(height = h)
        rounded_rect_2d(w, d, r);
}
