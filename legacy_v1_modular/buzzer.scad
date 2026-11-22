// =============================================================================
// buzzer.scad
// Piezo buzzer radial grille with sound holes and reinforcement ring.
// Coordinates are relative to the Arduino feature origin.
// Depends on: config.scad, utilities.scad
// =============================================================================

include <config.scad>
use <utilities.scad>

// ---------------------------------------------------------------------------
// Buzzer grille recess — shallow pocket for the grille area
// ---------------------------------------------------------------------------
module buzzer_grille_recess() {
    translate([buzzer_center_x, buzzer_center_y, lid_thickness - buzzer_grille_recess_depth])
        cylinder(d = buzzer_grille_outer_diameter, h = buzzer_grille_recess_depth + 0.01, $fn = $fn);
}

// ---------------------------------------------------------------------------
// Buzzer sound holes — radial pattern of through-holes
// ---------------------------------------------------------------------------
module buzzer_sound_holes() {
    // Direct hole generation — full lid thickness penetration
    translate([buzzer_center_x, buzzer_center_y, -0.01])
        for (ring = [1 : buzzer_grille_ring_count]) {
            ring_radius = buzzer_grille_inner_diameter / 2 + ring * buzzer_grille_ring_spacing - buzzer_grille_ring_spacing / 2;
            if (ring_radius <= buzzer_grille_outer_diameter / 2 - buzzer_grille_hole_diameter / 2) {
                count_at_ring = max(1, floor(2 * PI * ring_radius / (buzzer_grille_hole_diameter * 2)));
                for (i = [0 : count_at_ring - 1]) {
                    angle = i * 360 / count_at_ring;
                    rotate([0, 0, angle])
                        translate([ring_radius, 0, 0])
                            cylinder(d = buzzer_grille_hole_diameter, h = lid_thickness + 0.02, $fn = $fn);
                }
            }
        }
}

// ---------------------------------------------------------------------------
// Buzzer reinforcement ring — thin ring between hole rings for rigidity
// ---------------------------------------------------------------------------
module buzzer_reinforcement_ring() {
    // Inner reinforcement ring
    translate([buzzer_center_x, buzzer_center_y, lid_thickness - buzzer_grille_recess_depth])
        difference() {
            cylinder(
                d = buzzer_grille_inner_diameter + buzzer_grille_reinforcement_thickness * 2,
                h = buzzer_grille_recess_depth,
                $fn = $fn
            );
            translate([0, 0, -0.01])
                cylinder(d = buzzer_grille_inner_diameter, h = buzzer_grille_recess_depth + 0.02, $fn = $fn);
        }
}

// ---------------------------------------------------------------------------
// Full buzzer grille — positive and negative features for the lid
// ---------------------------------------------------------------------------
// Subtractive: use difference() with lid body
module buzzer_grille_cutout() {
    buzzer_grille_recess();
    buzzer_sound_holes();
}

// Positive: reinforcement ring adds material back
module buzzer_grille_positive() {
    buzzer_reinforcement_ring();
}