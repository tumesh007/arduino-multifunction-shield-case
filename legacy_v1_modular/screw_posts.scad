// =============================================================================
// screw_posts.scad
// M3 screw bosses, counterbores, and optional heat-set insert support.
// Four corner posts anchor the base and receive screws from the lid.
// Depends on: config.scad, utilities.scad
// =============================================================================

include <config.scad>
use <utilities.scad>

// ---------------------------------------------------------------------------
// Single screw boss — cylindrical post with optional rib reinforcement
// ---------------------------------------------------------------------------
// height: post height from base floor
// position: [x, y] center coordinates on the base floor
module screw_boss(height, position) {
    translate([position[0], position[1], bottom_thickness]) {
        difference() {
            union() {
                // Main boss cylinder
                cylinder(d = screw_post_outer_diameter, h = height, $fn = $fn);

                // Corner reinforcement ribs (two orthogonal ribs)
                for (angle = [0, 90]) {
                    rotate([0, 0, angle])
                        translate([0, -screw_boss_rib_thickness / 2, 0])
                            cube([
                                screw_post_outer_diameter / 2 + screw_boss_rib_length,
                                screw_boss_rib_thickness,
                                min(height, screw_boss_rib_height)
                            ]);
                }
            }

            // Screw hole or insert hole
            if (heat_set_insert_enabled) {
                translate([0, 0, -0.01])
                    heat_insert_hole(
                        heat_set_insert_outer_diameter,
                        heat_set_insert_depth,
                        heat_set_insert_lead_in_diameter,
                        heat_set_insert_lead_in_depth
                    );
            } else {
                translate([0, 0, -0.01])
                    screw_hole(
                        screw_clearance_diameter,
                        height + 0.02,
                        screw_head_diameter,
                        screw_head_depth
                    );
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Screw boss array — all four corner posts
// ---------------------------------------------------------------------------
module screw_posts() {
    // Calculate corner positions based on internal dimensions
    post_positions = [
        [screw_post_corner_offset, screw_post_corner_offset],
        [external_length - screw_post_corner_offset, screw_post_corner_offset],
        [screw_post_corner_offset, external_width - screw_post_corner_offset],
        [external_length - screw_post_corner_offset, external_width - screw_post_corner_offset]
    ];

    for (pos = post_positions) {
        screw_boss(screw_post_height, pos);
    }
}

// ---------------------------------------------------------------------------
// Lid screw hole — through-hole in the lid aligned with screw bosses
// ---------------------------------------------------------------------------
// These are subtractive features for the lid module.
module lid_screw_holes() {
    post_positions = [
        [screw_post_corner_offset, screw_post_corner_offset],
        [external_length - screw_post_corner_offset, screw_post_corner_offset],
        [screw_post_corner_offset, external_width - screw_post_corner_offset],
        [external_length - screw_post_corner_offset, external_width - screw_post_corner_offset]
    ];

    for (pos = post_positions) {
        translate([pos[0], pos[1], -0.01])
            cylinder(d = screw_clearance_diameter, h = lid_thickness + 0.02, $fn = $fn);

        // Counterbore for screw head in lid (if not using inserts in base)
        if (!heat_set_insert_enabled) {
            translate([pos[0], pos[1], lid_thickness - screw_head_depth])
                cylinder(d = screw_head_diameter, h = screw_head_depth + 0.01, $fn = $fn);
        }
    }
}

// ---------------------------------------------------------------------------
// Screw post cutout — negative space for the boss in the internal cavity
// ---------------------------------------------------------------------------
// Used by base.scad to ensure the cavity does not intersect posts.
module screw_post_cavity_cutout() {
    post_positions = [
        [screw_post_corner_offset, screw_post_corner_offset],
        [external_length - screw_post_corner_offset, screw_post_corner_offset],
        [screw_post_corner_offset, external_width - screw_post_corner_offset],
        [external_length - screw_post_corner_offset, external_width - screw_post_corner_offset]
    ];

    for (pos = post_positions) {
        translate([pos[0], pos[1], bottom_thickness - 0.01])
            cylinder(d = screw_post_outer_diameter + 0.5, h = screw_post_height + 0.02, $fn = $fn);
    }
}