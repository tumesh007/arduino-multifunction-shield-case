// =============================================================================
// vents.scad
// Side ventilation slots with reinforcement ribs and bridge-safe geometry.
// Depends on: config.scad, utilities.scad
// =============================================================================

include <config.scad>
use <utilities.scad>

// ---------------------------------------------------------------------------
// Single side vent slot — horizontal slot with rounded ends
// ---------------------------------------------------------------------------
// position: [x, y, z] where the slot center is located
// length: slot length along the wall
// width: slot width (height in the wall face)
module side_vent_slot(position, length, width) {
    translate([position[0], position[1], position[2] - width / 2])
        rotate([0, 90, 0])
            vent_slot(length, width, wall_thickness + 0.02);
}

// ---------------------------------------------------------------------------
// Side vent row — vertical stack of vent slots on one wall face
// ---------------------------------------------------------------------------
// face: "left", "right", "front", "back" — which wall face
// bottom_z: Z coordinate of the bottom vent center
module side_vent_row(face, bottom_z) {
    // Calculate positions based on face
    x_positions = (face == "left" || face == "right") ?
        [0, external_length] : [vent_end_margin, external_length - vent_end_margin];
    y_pos = (face == "left") ? 0 :
            (face == "right") ? external_width :
            (face == "front") ? 0 : external_width;

    x_span = x_positions[1] - x_positions[0];
    available_length = x_span - vent_end_margin * 2;
    vent_count = floor(available_length / vent_slot_spacing);

    for (i = [0 : vent_count - 1]) {
        x = x_positions[0] + vent_end_margin + i * vent_slot_spacing;
        z = bottom_z;

        if (face == "left" || face == "right") {
            translate([x, y_pos, z])
                rotate([90, 0, 0])
                    vent_slot(vent_slot_length, vent_slot_width, wall_thickness + 0.02);
        } else {
            translate([x, y_pos, z])
                rotate([0, -90, 0])
                    vent_slot(vent_slot_length, vent_slot_width, wall_thickness + 0.02);
        }
    }
}

// ---------------------------------------------------------------------------
// Side vents — all ventilation slots on the enclosure walls
// ---------------------------------------------------------------------------
// Subtractive module: use difference() with the base shell.
module side_vents() {
    // Front wall vents (Y=0 face)
    for (row = [0 : side_vent_count - 1]) {
        z = side_vent_bottom_offset + row * vent_row_spacing;
        if (z + vent_slot_width / 2 <= required_internal_height + bottom_thickness) {
            for (i = [0 : floor((external_length - vent_end_margin * 2) / vent_slot_spacing) - 1]) {
                x = vent_end_margin + i * vent_slot_spacing;
                if (x + vent_slot_length / 2 <= external_length - vent_end_margin) {
                    translate([x, -0.01, z])
                        rotate([-90, 0, 0])
                            vent_slot(vent_slot_length, vent_slot_width, wall_thickness + 0.02);
                }
            }
        }
    }

    // Back wall vents (Y=external_width face)
    for (row = [0 : side_vent_count - 1]) {
        z = side_vent_bottom_offset + row * vent_row_spacing;
        if (z + vent_slot_width / 2 <= required_internal_height + bottom_thickness) {
            for (i = [0 : floor((external_length - vent_end_margin * 2) / vent_slot_spacing) - 1]) {
                x = vent_end_margin + i * vent_slot_spacing;
                if (x + vent_slot_length / 2 <= external_length - vent_end_margin) {
                    translate([x, external_width - wall_thickness - 0.01, z])
                        rotate([-90, 0, 0])
                            vent_slot(vent_slot_length, vent_slot_width, wall_thickness + 0.02);
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Vent reinforcement ribs — vertical ribs between vent rows for wall strength
// ---------------------------------------------------------------------------
module vent_reinforcement_ribs() {
    // Vertical ribs on the interior face, aligned between vent rows
    for (row = [0 : side_vent_count - 2]) {
        z = side_vent_bottom_offset + row * vent_row_spacing + vent_slot_width;
        for (x = [vent_wall_edge_clearance : internal_rib_spacing : external_length - vent_wall_edge_clearance]) {
            translate([x, wall_thickness, z])
                cube([vent_reinforcement_rib_thickness, internal_width, vent_row_spacing - vent_slot_width]);
        }
    }
}