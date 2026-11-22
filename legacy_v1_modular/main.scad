// =============================================================================
// main.scad
// Master assembly file with views: assembled, exploded, cutaway, base-only,
// lid-only, plunger-only, and STL export support.
// Depends on: config.scad, base.scad, lid.scad, button_plunger.scad
// =============================================================================

include <config.scad>
use <base.scad>
use <lid.scad>
use <button_plunger.scad>

// ---------------------------------------------------------------------------
// View control booleans
// ---------------------------------------------------------------------------

show_base = true;
show_lid = true;
show_plungers = true;
show_assembly = true;
show_exploded = false;
show_cutaway = false;
show_fasteners = false;
show_hardware = false;

explode_factor = show_exploded ? 30 : 0;

// ---------------------------------------------------------------------------
// Assembly positioning
// ---------------------------------------------------------------------------

// Lid sits at Z = bottom_thickness + required_internal_height
lid_assembly_z = bottom_thickness + required_internal_height;

// ---------------------------------------------------------------------------
// Cutaway plane — removes a portion for interior visualization
// ---------------------------------------------------------------------------
module cutaway_plane() {
    if (show_cutaway) {
        translate([external_length / 2, -1, -1])
            cube([external_length / 2 + 2, external_width + 2, external_height + 2]);
    }
}

// ---------------------------------------------------------------------------
// Fastener visualization (screws, for reference only)
// ---------------------------------------------------------------------------
module fasteners() {
    if (show_fasteners) {
        post_positions = [
            [screw_post_corner_offset, screw_post_corner_offset],
            [external_length - screw_post_corner_offset, screw_post_corner_offset],
            [screw_post_corner_offset, external_width - screw_post_corner_offset],
            [external_length - screw_post_corner_offset, external_width - screw_post_corner_offset]
        ];

        for (pos = post_positions) {
            translate([pos[0], pos[1], bottom_thickness + screw_post_height - 5])
                color("silver")
                    cylinder(d = screw_nominal_diameter, h = 20, $fn = $fn);
        }
    }
}

// ---------------------------------------------------------------------------
// Plunger assembly — three snap-in plungers positioned in the lid
// ---------------------------------------------------------------------------
module plunger_assembly() {
    if (show_plungers && show_assembly) {
        // Plungers are inserted from inside the lid
        // snap_in_plunger() uses absolute Z; only XY needs Arduino offset
        exploded_translate([0, 0, explode_factor * 0.5])
            translate([arduino_position_x, arduino_position_y, 0])
                all_plungers();
    }
}

// ---------------------------------------------------------------------------
// Main assembly
// ---------------------------------------------------------------------------

module assembly() {
    difference() {
        union() {
            // Base
            if (show_base) {
                base();
            }

            // Lid
            if (show_lid && show_assembly) {
                exploded_translate([0, 0, explode_factor])
                    translate([0, 0, lid_assembly_z])
                        lid();
            }

            // Plungers
            plunger_assembly();

            // Fasteners
            if (show_fasteners) {
                fasteners();
            }
        }

        // Cutaway
        cutaway_plane();
    }
}

// ---------------------------------------------------------------------------
// STL export modules
// ---------------------------------------------------------------------------

module base_stl() {
    base();
}

module lid_stl() {
    lid();
}

module plunger_stl() {
    // Export a single plunger for printing three copies
    // Bottom-align on build plate (cap sits at Z=0)
    translate([0, 0, -(bottom_thickness + required_internal_height + lid_thickness)])
        snap_in_plunger(button_positions[0]);
}

// ---------------------------------------------------------------------------
// Render the selected view
// ---------------------------------------------------------------------------

assembly();
