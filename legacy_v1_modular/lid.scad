// =============================================================================
// lid.scad
// Lid shell with alignment lip, display window, button guide bores/tubes,
// buzzer grille, and screw holes.
// 
// NOTE: Button plungers are SEPARATE REMOVABLE PARTS.
// They insert from the INSIDE of the lid and snap into place.
// See button_plunger.scad for the plunger geometry.
//
// Depends on: config.scad, utilities.scad, button_plunger.scad, display.scad,
//             buzzer.scad, screw_posts.scad
// =============================================================================

include <config.scad>
use <utilities.scad>
use <button_plunger.scad>
use <display.scad>
use <buzzer.scad>
use <screw_posts.scad>

// ---------------------------------------------------------------------------
// Lid outer shell — flat top with rounded perimeter
// ---------------------------------------------------------------------------
module lid_outer_shell() {
    rounded_cube([lid_outer_length, lid_outer_width, lid_thickness], outer_corner_radius);
}

// ---------------------------------------------------------------------------
// Lid alignment lip — perimeter skirt that fits into the base cavity
// ---------------------------------------------------------------------------
module lid_alignment_lip() {
    difference() {
        translate([wall_thickness + lid_fit_clearance, wall_thickness + lid_fit_clearance, -lid_overlap_height])
            rounded_cube([lid_inner_length, lid_inner_width, lid_overlap_height + 0.01], inner_corner_radius);

        translate([wall_thickness + lid_fit_clearance + lid_perimeter_lip_thickness, wall_thickness + lid_fit_clearance + lid_perimeter_lip_thickness, -lid_overlap_height - 0.01])
            rounded_cube([lid_inner_length - lid_perimeter_lip_thickness * 2, lid_inner_width - lid_perimeter_lip_thickness * 2, lid_overlap_height + 0.02], inner_corner_radius - lid_perimeter_lip_thickness);
    }
}

// ---------------------------------------------------------------------------
// Lid underside chamfer — draft angle for printability
// ---------------------------------------------------------------------------
module lid_underside_chamfer() {
    // Chamfer at the bottom edge of the alignment lip
    translate([0, 0, -lid_overlap_height])
        difference() {
            cube([lid_outer_length, lid_outer_width, underside_chamfer_height]);
            translate([underside_chamfer_inset, underside_chamfer_inset, -0.01])
                cube([lid_outer_length - underside_chamfer_inset * 2, lid_outer_width - underside_chamfer_inset * 2, underside_chamfer_height + 0.02]);
        }
}

// ---------------------------------------------------------------------------
// Complete lid assembly
// ---------------------------------------------------------------------------
module lid() {
    difference() {
        union() {
            // Main lid body
            lid_outer_shell();

            // Alignment lip (positive)
            lid_alignment_lip();

            // Arduino-local features translated to enclosure coordinates
            translate([arduino_position_x, arduino_position_y, 0]) {
                // Button guide tubes (positive, extend below lid)
                all_plunger_guide_tubes();

                // Button retaining shoulders (positive, at guide tube bottoms)
                all_plunger_retaining_shoulders();

                // Buzzer reinforcement ring (positive)
                buzzer_grille_positive();

                // Display bezel frame (positive)
                display_positive();
            }
        }

        // Subtractive features
        translate([arduino_position_x, arduino_position_y, 0]) {
            all_plunger_guide_bores();   // Button guide bores with snap grooves
            display_cutout();
            buzzer_grille_cutout();
        }
        lid_screw_holes();

        // Underside chamfer (subtractive from lip outer edge)
        lid_underside_chamfer();
    }
}