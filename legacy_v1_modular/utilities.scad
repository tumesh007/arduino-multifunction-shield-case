// =============================================================================
// utilities.scad
// Reusable geometric primitives, transforms, and helper modules/functions.
// Depends on: config.scad
// =============================================================================

include <config.scad>

// ---------------------------------------------------------------------------
// 2D rounded rectangle
// ---------------------------------------------------------------------------
// Returns a 2D rounded rectangle path for linear_extrude or polygon use.
// size = [width, height], radius = corner fillet radius.
function rounded_rectangle_2d(size, radius) =
    let(
        w = size[0],
        h = size[1],
        r = min(radius, w / 2, h / 2)
    )
    [
        [r, 0],
        [w - r, 0],
        [w, r],
        [w, h - r],
        [w - r, h],
        [r, h],
        [0, h - r],
        [0, r]
    ];

// ---------------------------------------------------------------------------
// Rounded cube (box) — centered or corner-oriented
// ---------------------------------------------------------------------------
// size: [x, y, z] dimensions
// radius: corner fillet in XY plane
// center: if true, cube is centered on origin; otherwise corner at [0,0,0]
module rounded_cube(size, radius, center = false) {
    r = min(radius, size[0] / 2, size[1] / 2);
    if (center) {
        translate([-size[0] / 2, -size[1] / 2, -size[2] / 2])
            rounded_cube(size, r, center = false);
    } else {
        linear_extrude(height = size[2])
            offset(r = r)
                offset(delta = -r)
                    square([size[0], size[1]]);
    }
}

// ---------------------------------------------------------------------------
// Rounded box with all six faces filleted (hull of 8 spheres + extrusions)
// ---------------------------------------------------------------------------
// More expensive but produces true 3D rounded corners.
module rounded_box(size, radius, center = false) {
    r = min(radius, size[0] / 2, size[1] / 2, size[2] / 2);
    pos = center ? [-size[0] / 2, -size[1] / 2, -size[2] / 2] : [0, 0, 0];
    translate(pos)
        hull() {
            for (x = [r, size[0] - r])
                for (y = [r, size[1] - r])
                    for (z = [r, size[2] - r])
                        translate([x, y, z])
                            sphere(r = r, $fn = $fn);
        }
}

// ---------------------------------------------------------------------------
// Rounded slot (2D profile for extrusion)
// ---------------------------------------------------------------------------
// length: overall length including radii
// width: diameter of end semicircles
module rounded_slot_2d(length, width) {
    r = width / 2;
    hull() {
        translate([r, 0]) circle(r = r, $fn = $fn);
        translate([length - r, 0]) circle(r = r, $fn = $fn);
    }
}

// ---------------------------------------------------------------------------
// Slot (2D rectangle with semicircular ends)
// ---------------------------------------------------------------------------
module slot_2d(length, width) {
    rounded_slot_2d(length, width);
}

// ---------------------------------------------------------------------------
// Counterbore — cylindrical recess for screw head
// ---------------------------------------------------------------------------
// bore_diameter: through-hole diameter
// bore_depth: depth of the counterbore (from top surface down)
// head_diameter: diameter of the screw head recess
// head_depth: depth of the head recess
module counterbore(bore_diameter, bore_depth, head_diameter, head_depth) {
    union() {
        cylinder(d = bore_diameter, h = bore_depth, $fn = $fn);
        translate([0, 0, bore_depth - head_depth])
            cylinder(d = head_diameter, h = head_depth + 0.01, $fn = $fn);
    }
}

// ---------------------------------------------------------------------------
// Countersink — conical recess for screw head
// ---------------------------------------------------------------------------
// bore_diameter: through-hole diameter
// bore_depth: total depth of the hole
// head_diameter: maximum diameter of the countersink cone
// head_angle: included angle of the countersink (default 90 degrees)
module countersink(bore_diameter, bore_depth, head_diameter, head_angle = 90) {
    cone_height = (head_diameter - bore_diameter) / 2 / tan(head_angle / 2);
    union() {
        cylinder(d = bore_diameter, h = bore_depth, $fn = $fn);
        translate([0, 0, bore_depth - cone_height])
            cylinder(d1 = bore_diameter, d2 = head_diameter, h = cone_height + 0.01, $fn = $fn);
    }
}

// ---------------------------------------------------------------------------
// Screw hole — through-hole with optional counterbore
// ---------------------------------------------------------------------------
// diameter: screw clearance diameter
// depth: hole depth
// head_diameter: screw head diameter (for counterbore)
// head_depth: screw head depth (for counterbore)
// countersink_angle: if > 0, use countersink instead of counterbore
module screw_hole(diameter, depth, head_diameter = 0, head_depth = 0, countersink_angle = 0) {
    if (head_diameter > 0 && head_depth > 0) {
        if (countersink_angle > 0) {
            countersink(diameter, depth, head_diameter, countersink_angle);
        } else {
            counterbore(diameter, depth, head_diameter, head_depth);
        }
    } else {
        cylinder(d = diameter, h = depth + 0.01, $fn = $fn);
    }
}

// ---------------------------------------------------------------------------
// Heat-set insert hole — pilot hole with lead-in chamfer
// ---------------------------------------------------------------------------
// outer_diameter: nominal outer diameter of the brass insert
// depth: insert seating depth
// lead_in_diameter: diameter of the lead-in chamfer at the top
// lead_in_depth: depth of the lead-in chamfer
module heat_insert_hole(outer_diameter, depth, lead_in_diameter, lead_in_depth) {
    union() {
        cylinder(d = outer_diameter + heat_set_insert_clearance, h = depth, $fn = $fn);
        translate([0, 0, depth - lead_in_depth])
            cylinder(d1 = outer_diameter + heat_set_insert_clearance, d2 = lead_in_diameter + heat_set_insert_clearance, h = lead_in_depth + 0.01, $fn = $fn);
    }
}

// ---------------------------------------------------------------------------
// Vent slot — single rounded-end slot for airflow
// ---------------------------------------------------------------------------
// length: slot length
// width: slot width
// height: extrusion height (wall thickness through which it cuts)
module vent_slot(length, width, height) {
    linear_extrude(height = height + 0.02)
        rounded_slot_2d(length, width);
}

// ---------------------------------------------------------------------------
// Vent array — linear row of evenly spaced vent slots
// ---------------------------------------------------------------------------
// slot_length, slot_width: dimensions of each slot
// slot_spacing: center-to-center distance between slots
// count: number of slots
// height: extrusion depth
module vent_array(slot_length, slot_width, slot_spacing, count, height) {
    total_width = (count - 1) * slot_spacing;
    for (i = [0 : count - 1]) {
        translate([i * slot_spacing - total_width / 2, 0, -0.01])
            vent_slot(slot_length, slot_width, height);
    }
}

// ---------------------------------------------------------------------------
// Radial grille — circular pattern of holes or slots
// ---------------------------------------------------------------------------
// outer_diameter: overall diameter of the grille area
// inner_diameter: central solid hub diameter
// hole_diameter: diameter of each sound/light hole
// radial_count: number of holes per ring
// ring_count: number of concentric rings
// ring_spacing: radial distance between ring centers
// recess_depth: depth of the recessed pocket (0 for flat)
module radial_grille(outer_diameter, inner_diameter, hole_diameter, radial_count, ring_count, ring_spacing, recess_depth = 0) {
    if (recess_depth > 0) {
        translate([0, 0, -recess_depth])
            cylinder(d = outer_diameter, h = recess_depth + 0.01, $fn = $fn);
    }
    for (ring = [1 : ring_count]) {
        ring_radius = inner_diameter / 2 + ring * ring_spacing - ring_spacing / 2;
        if (ring_radius <= outer_diameter / 2 - hole_diameter / 2) {
            count_at_ring = max(1, floor(2 * PI * ring_radius / (hole_diameter * 2)));
            for (i = [0 : count_at_ring - 1]) {
                angle = i * 360 / count_at_ring;
                rotate([0, 0, angle])
                    translate([ring_radius, 0, -0.01])
                        cylinder(d = hole_diameter, h = recess_depth + 0.02, $fn = $fn);
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Rounded rectangle cut — 2D profile for difference() operations
// ---------------------------------------------------------------------------
module rounded_rectangle_cut(size, radius, depth) {
    linear_extrude(height = depth + 0.02)
        offset(r = radius)
            offset(delta = -radius)
                square([size[0], size[1]], center = true);
}

// ---------------------------------------------------------------------------
// Fillet — rounded edge between two faces (simplified as cylinder segment)
// ---------------------------------------------------------------------------
// radius: fillet radius
// length: length of the edge to fillet
// angle: rotation angle for orientation (0 = along X axis)
module fillet(radius, length, angle = 0) {
    rotate([0, 0, angle])
        translate([0, -radius, 0])
            rotate([90, 0, 0])
                linear_extrude(height = length)
                    difference() {
                        square([radius + 0.01, radius + 0.01]);
                        circle(r = radius, $fn = $fn);
                    }
}

// ---------------------------------------------------------------------------
// Chamfer — beveled edge
// ---------------------------------------------------------------------------
// length: length of the edge
// height: vertical chamfer amount
// width: horizontal chamfer amount (if 0, uses height for 45 degree)
module chamfer(length, height, width = 0) {
    w = width == 0 ? height : width;
    rotate([90, 0, 90])
        linear_extrude(height = length)
            polygon([[0, 0], [w, 0], [0, height]]);
}

// ---------------------------------------------------------------------------
// Mirror copy — duplicate child geometry across a plane
// ---------------------------------------------------------------------------
// axis: "x", "y", or "z" — the axis normal to the mirror plane
module mirror_copy(axis = "x") {
    children();
    if (axis == "x") {
        mirror([1, 0, 0]) children();
    } else if (axis == "y") {
        mirror([0, 1, 0]) children();
    } else if (axis == "z") {
        mirror([0, 0, 1]) children();
    }
}

// ---------------------------------------------------------------------------
// Corner pattern — place children at all four XY corners of a rectangle
// ---------------------------------------------------------------------------
// size: [width, depth] of the rectangle
// offset: [x_offset, y_offset] from each corner toward center
module corner_pattern(size, offset) {
    for (x = [offset[0], size[0] - offset[0]])
        for (y = [offset[1], size[1] - offset[1]])
            translate([x, y, 0])
                children();
}

// ---------------------------------------------------------------------------
// Polar copy — radial array of children
// ---------------------------------------------------------------------------
// count: number of copies
// radius: distance from origin to each copy
// start_angle: starting angle in degrees
module polar_copy(count, radius, start_angle = 0) {
    for (i = [0 : count - 1]) {
        angle = start_angle + i * 360 / count;
        rotate([0, 0, angle])
            translate([radius, 0, 0])
                children();
    }
}

// ---------------------------------------------------------------------------
// Center between two points — returns midpoint coordinate
// ---------------------------------------------------------------------------
function center_between(a, b) = [(a[0] + b[0]) / 2, (a[1] + b[1]) / 2, (a[2] + b[2]) / 2];

// ---------------------------------------------------------------------------
// Coordinate transforms — helpers for positioning
// ---------------------------------------------------------------------------
function to_arduino_origin(x, y, z = 0) = [arduino_position_x + x, arduino_position_y + y, arduino_position_z + z];

// ---------------------------------------------------------------------------
// Debug helpers — visual aids for development
// ---------------------------------------------------------------------------
// Highlight a region with a translucent bounding box
module debug_bbox(size, center = false) {
    %cube(size, center = center);
}

// Axis indicator at origin
module debug_axes(length = 10) {
    color("red") translate([0, 0, 0]) rotate([0, 90, 0]) cylinder(d = 0.5, h = length, $fn = 8);
    color("green") translate([0, 0, 0]) rotate([-90, 0, 0]) cylinder(d = 0.5, h = length, $fn = 8);
    color("blue") translate([0, 0, 0]) cylinder(d = 0.5, h = length, $fn = 8);
}

// ---------------------------------------------------------------------------
// Exploded view translate — offset children by a vector scaled by a factor
// ---------------------------------------------------------------------------
// vector: [x, y, z] direction of explosion
// factor: scalar multiplier (0 = assembled, 1 = fully exploded)
module exploded_translate(vector) {
    translate(vector)
        children();
}

// ---------------------------------------------------------------------------
// Helper assertion — runtime check with custom message
// ---------------------------------------------------------------------------
module assert_positive(value, name) {
    assert(value > 0, str(name, " must be positive."));
}

// ---------------------------------------------------------------------------
// Bridge-safe overhang check — warn if geometry exceeds support-free angle
// ---------------------------------------------------------------------------
function overhang_angle(horizontal, vertical) = atan(horizontal / vertical);
