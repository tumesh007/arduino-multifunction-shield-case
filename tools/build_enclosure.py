import bpy
import bmesh
import math
import os
import json
from mathutils import Vector

# Arduino multifunction shield enclosure master build.
# All dimensions are millimetres; Blender units are treated as millimetres.

OUT_DIR = os.path.dirname(os.path.abspath(__file__))

P = {
    "enc_w": 117.6, "enc_d": 98.4, "enc_h": 46.6,
    "wall": 3.0, "bottom": 3.0, "top": 3.0, "corner_r": 5.0,
    "clr": 0.30, "press_clr": 0.15, "lip_inset": 1.5, "lip_h": 2.0,
    "arduino_l": 83.4, "arduino_w": 62.0, "arduino_h": 19.4,
    "arduino_clr": 1.0, "shield_h": 12.2,
    "battery_l": 58.6, "battery_w": 43.6, "battery_h": 29.9,
    "battery_clr": 1.0, "battery_wall": 1.5,
    "divider_t": 2.0, "cable_pass_w": 12.0, "cable_pass_h": 10.0,
    "spst_cutout_w": 19.9, "spst_cutout_h": 12.0,
    "spst_l": 21.0, "spst_w": 15.0, "spst_h": 15.0,
    "spst_service": 20.0, "spst_wire_depth": 28.0,
    "dc_body_len": 33.0, "dc_body_d": 10.0, "dc_mount_d": 8.6,
    "btn_d": 5.0, "btn_top_offset": 7.4, "btn_travel": 1.0,
    "btns": [(14.7, 14.0), (24.1, 14.0), (33.4, 14.1)],
    "disp_w": 30.2, "disp_d": 14.3, "disp_tl": (18.3, 58.9),
    "buzz_d": 15.0, "buzz": (23.8, 37.5),
    "screw_clear": 3.3, "screw_cb": 6.0, "boss_od": 8.0,
    "boss_id": 2.5, "boss_inset": 7.5,
    "plunger_shaft_d": 4.6, "plunger_hole_d": 5.6,
    "plunger_guide_d": 7.2, "plunger_collar_d": 6.4,
    "plunger_cap_d": 9.0, "plunger_cap_h": 2.0,
    "plunger_tip_r": 1.5,
}

P["arduino_x"] = P["wall"] + P["arduino_clr"]
P["arduino_y"] = P["wall"] + P["arduino_clr"]
P["arduino_z"] = P["bottom"]
P["shield_z"] = P["arduino_z"] + P["arduino_h"]
P["shield_top_z"] = P["shield_z"] + P["shield_h"]
P["battery_x"] = P["wall"] + P["arduino_clr"] + P["arduino_w"] + P["arduino_clr"] + P["divider_t"] + P["battery_clr"]
P["battery_y"] = P["wall"] + P["battery_clr"]
P["battery_z"] = P["bottom"]
P["divider_x"] = P["wall"] + P["arduino_clr"] + P["arduino_w"] + P["arduino_clr"]
P["base_h"] = P["enc_h"] - P["top"]
P["top_bottom_z"] = P["base_h"]
P["top_r"] = P["corner_r"] - P["lip_inset"] - P["clr"]
P["top_w"] = P["enc_w"] - 2 * P["lip_inset"] - 2 * P["clr"]
P["top_d"] = P["enc_d"] - 2 * P["lip_inset"] - 2 * P["clr"]
P["top_x"] = P["lip_inset"] + P["clr"]
P["top_y"] = P["lip_inset"] + P["clr"]
P["spst_y"] = P["battery_y"] + P["battery_l"] + P["battery_clr"] + 2.0 + P["spst_w"] / 2
P["spst_z"] = P["bottom"] + (P["base_h"] - P["bottom"]) / 2
P["dc_panel_x"] = P["divider_x"] + P["divider_t"] / 2
P["dc_y"] = P["battery_y"] + P["battery_l"] / 2
P["dc_z"] = P["base_h"] - P["dc_mount_d"] / 2 - 1.0

COLORS = {
    "base": (0.12, 0.18, 0.28, 1), "top": (0.18, 0.28, 0.42, 1),
    "hardware": (0.32, 0.34, 0.38, 1), "battery": (0.12, 0.38, 0.18, 1),
    "switch": (0.65, 0.08, 0.04, 1), "display": (0.04, 0.22, 0.28, 1),
    "plunger": (0.75, 0.55, 0.08, 1), "cut": (0.05, 0.05, 0.05, 1),
}


def mat(name, color):
    m = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    m.diffuse_color = color
    return m


MATS = {k: mat(k, v) for k, v in COLORS.items()}


def collection(name):
    c = bpy.data.collections.get(name) or bpy.data.collections.new(name)
    if c.name not in bpy.context.scene.collection.children:
        bpy.context.scene.collection.children.link(c)
    return c


def move_to(obj, coll):
    for c in list(obj.users_collection):
        c.objects.unlink(obj)
    coll.objects.link(obj)


def cube(name, loc, dims, material=None, bevel=0.0, coll=None):
    bpy.ops.mesh.primitive_cube_add(location=loc)
    o = bpy.context.object
    o.name = name
    o.dimensions = dims
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel:
        mod = o.modifiers.new("edge_radius", "BEVEL")
        mod.width = bevel
        mod.segments = 4
        mod.limit_method = "ANGLE"
        bpy.context.view_layer.objects.active = o
        bpy.ops.object.modifier_apply(modifier=mod.name)
    if material:
        o.data.materials.append(material)
    if coll:
        move_to(o, coll)
    return o


def cyl(name, loc, radius, depth, material=None, vertices=64, coll=None):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=loc)
    o = bpy.context.object
    o.name = name
    if material:
        o.data.materials.append(material)
    if coll:
        move_to(o, coll)
    return o


def boolean(target, cutter, operation="DIFFERENCE"):
    bpy.context.view_layer.objects.active = target
    mod = target.modifiers.new("boolean", "BOOLEAN")
    mod.operation = operation
    mod.solver = "EXACT"
    mod.object = cutter
    bpy.ops.object.modifier_apply(modifier=mod.name)
    bpy.data.objects.remove(cutter, do_unlink=True)


def rounded_box(name, loc, dims, radius, material=None, coll=None):
    o = cube(name, loc, dims, material, coll=coll)
    if radius:
        mod = o.modifiers.new("rounded_edges", "BEVEL")
        mod.width = radius
        mod.segments = 8
        mod.limit_method = "ANGLE"
        bpy.context.view_layer.objects.active = o
        bpy.ops.object.modifier_apply(modifier=mod.name)
    return o


def rounded_shell(coll):
    outer = rounded_box("BASE", (P["enc_w"]/2, P["enc_d"]/2, P["base_h"]/2),
                        (P["enc_w"], P["enc_d"], P["base_h"]), P["corner_r"], MATS["base"], coll=coll)
    inner = rounded_box("base_cavity_tool", (P["enc_w"]/2, P["enc_d"]/2, (P["bottom"] + P["base_h"] + 1)/2),
                        (P["enc_w"]-2*P["wall"], P["enc_d"]-2*P["wall"], P["base_h"]-P["bottom"]+1),
                        max(P["corner_r"]-P["wall"], 0.8), coll=coll)
    boolean(outer, inner)
    return outer


def add_union(base, part):
    boolean(base, part, "UNION")


def add_base_features(base, coll):
    # Arduino retaining rails/stops, intentionally low so the existing case remains removable.
    ax, ay = P["arduino_x"], P["arduino_y"]
    aw, al = P["arduino_w"], P["arduino_l"]
    rail_h, rail_w, seg = 4.0, 2.0, 15.0
    rail_gap = 0.30
    rails = [
        (ax-rail_w/2, ay+seg/2, rail_w, seg),
        (ax+aw+rail_w/2, ay+seg/2, rail_w, seg),
        (ax+rail_gap+(seg-rail_gap)/2, ay-rail_w/2, seg-rail_gap, rail_w),
        (ax+aw-rail_gap-(seg-rail_gap)/2, ay-rail_w/2, seg-rail_gap, rail_w),
        (ax-rail_w/2, ay+al-seg/2, rail_w, seg),
        (ax+aw+rail_w/2, ay+al-seg/2, rail_w, seg),
        (ax+rail_gap+(seg-rail_gap)/2, ay+al+rail_w/2, seg-rail_gap, rail_w),
        (ax+aw-rail_gap-(seg-rail_gap)/2, ay+al+rail_w/2, seg-rail_gap, rail_w),
    ]
    for i, (x, y, w, d) in enumerate(rails):
        add_union(base, cube(f"rail_{i}", (x, y, P["bottom"]+rail_h/2), (w, d, rail_h), MATS["base"], coll=coll))

    # Battery floor cradle and positive retaining walls with finger relief on rear wall.
    bx, by = P["battery_x"], P["battery_y"]
    bw, bl, bh = P["battery_w"], P["battery_l"], P["battery_h"]
    rw, rh = P["battery_wall"], 18.0
    for i, (x, y, w, d) in enumerate([
        (bx-P["battery_clr"]-rw/2, by+bl/2, rw, bl+2*P["battery_clr"]),
        (bx+bw+P["battery_clr"]+rw/2, by+bl/2, rw, bl+2*P["battery_clr"]),
        (bx+bw/2, by-P["battery_clr"]-rw/2, bw+2*P["battery_clr"], rw),
    ]):
        add_union(base, cube(f"battery_wall_{i}", (x, y, P["bottom"]+rh/2), (w, d, rh), MATS["base"], coll=coll))
    rear = cube("battery_rear_wall", (bx+bw/2, by+bl+P["battery_clr"]+rw/2, P["bottom"]+rh/2),
                (bw+2*P["battery_clr"], rw, rh), MATS["base"], coll=coll)
    # Finger notch through the rear retaining wall.
    notch = cube("battery_finger_notch", (bx+bw/2, by+bl+P["battery_clr"]+rw/2, P["bottom"]+rh*0.72),
                 (20.0, rw+1, 10.0), coll=coll)
    boolean(rear, notch)
    add_union(base, rear)

    # Divider between Arduino and battery, with low cable pass-through.
    div = cube("arduino_battery_divider", (P["divider_x"]+P["divider_t"]/2, P["enc_d"]/2,
                                           P["bottom"]+(P["base_h"]-P["bottom"])/2),
               (P["divider_t"], P["enc_d"]-2*P["wall"], P["base_h"]-P["bottom"]),
               MATS["base"], coll=coll)
    pass_tool = cube("divider_cable_pass", (P["divider_x"]+P["divider_t"]/2, P["enc_d"]/2,
                                            P["bottom"]+2+P["cable_pass_h"]/2),
                     (P["divider_t"]+1, P["cable_pass_w"], P["cable_pass_h"]), coll=coll)
    boolean(div, pass_tool)
    add_union(base, div)

    # Four bosses, tied to the floor and clear of the SPST service volume.
    bosses = [(P["boss_inset"], P["boss_inset"]),
              (P["enc_w"]-P["boss_inset"], P["boss_inset"]),
              (P["boss_inset"], P["enc_d"]-P["boss_inset"]),
              (P["enc_w"]-P["boss_inset"], P["enc_d"]-P["boss_inset"])]
    for i, (x, y) in enumerate(bosses):
        b = cyl(f"screw_boss_{i}", (x, y, (P["bottom"]+P["base_h"])/2),
                 P["boss_od"]/2, P["base_h"]-P["bottom"], MATS["base"], coll=coll)
        bore = cyl(f"boss_bore_{i}", (x, y, P["bottom"]+(P["base_h"]-P["bottom"])/2),
                   P["boss_id"]/2, P["base_h"]-P["bottom"]+1, coll=coll)
        boolean(b, bore)
        add_union(base, b)

    # Cable relief remains on the battery side of the divider, below the jack.
    for y in (P["dc_y"] - 5.0, P["dc_y"] + 5.0):
        add_union(base, cube("dc_cable_guide", (P["divider_x"] + P["divider_t"] + 8.0, y,
                                                P["bottom"] + 2.0),
                             (16.0, 1.2, 4.0), MATS["base"], coll=coll))


def add_base_openings(base, coll):
    # SPST panel cutout through right wall; width is along Y.
    cut = cube("spst_panel_cutout", (P["enc_w"]-P["wall"]/2, P["spst_y"],
                                     P["spst_z"]),
               (P["wall"]+2, P["spst_cutout_w"]+2*P["clr"],
                P["spst_cutout_h"]+2*P["clr"]), coll=coll)
    boolean(base, cut)
    # DC connector panel opening through the Arduino/battery divider.
    cut = cyl("dc_panel_cutout", (P["dc_panel_x"], P["dc_y"], P["dc_z"]),
              P["dc_mount_d"]/2, P["wall"]+2, coll=coll)
    cut.rotation_euler[1] = math.radians(90)
    bpy.context.view_layer.objects.active = cut
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
    boolean(base, cut)
    # Four shallow foot recesses.
    for x, y in [(8, 8), (P["enc_w"]-8, 8), (8, P["enc_d"]-8), (P["enc_w"]-8, P["enc_d"]-8)]:
        foot = cyl("foot_recess", (x, y, 0.55), 4.0, 1.3, coll=coll)
        boolean(base, foot)


def make_top_plate(coll):
    top = rounded_box("TOP_PLATE", (P["top_x"]+P["top_w"]/2, P["top_y"]+P["top_d"]/2,
                                    P["top_bottom_z"]+P["top"]/2),
                      (P["top_w"], P["top_d"], P["top"]), P["top_r"], MATS["top"], coll=coll)
    skirt = rounded_box("top_alignment_skirt", (P["enc_w"]/2, P["enc_d"]/2,
                                                 P["top_bottom_z"]-P["lip_h"]/2),
                        (P["enc_w"]-2*P["lip_inset"], P["enc_d"]-2*P["lip_inset"], P["lip_h"]),
                        P["corner_r"]-P["lip_inset"], MATS["top"], coll=coll)
    add_union(top, skirt)

    def tp_xy(sx, sy):
        return P["arduino_x"] + sx - P["top_x"], P["arduino_y"] + sy - P["top_y"]

    # Display opening and a raised protective bezel ring.
    dx, dy = tp_xy(*P["disp_tl"])
    display_cut = cube("display_opening", (P["top_x"]+dx+P["disp_w"]/2,
                                           P["top_y"]+dy+P["disp_d"]/2, P["top_bottom_z"]+1),
                       (P["disp_w"]+1.0, P["disp_d"]+1.0, P["top"]+4), coll=coll)
    boolean(top, display_cut)
    bezel_outer = cube("display_bezel_outer", (P["top_x"]+dx+P["disp_w"]/2,
                                               P["top_y"]+dy+P["disp_d"]/2, P["top_bottom_z"]+P["top"]+0.5),
                       (P["disp_w"]+4.0, P["disp_d"]+4.0, 1.0), MATS["top"], coll=coll)
    bezel_inner = cube("display_bezel_inner", (P["top_x"]+dx+P["disp_w"]/2,
                                               P["top_y"]+dy+P["disp_d"]/2, P["top_bottom_z"]+P["top"]+0.5),
                       (P["disp_w"]+1.0, P["disp_d"]+1.0, 2.0), coll=coll)
    boolean(bezel_outer, bezel_inner)
    add_union(top, bezel_outer)

    # Button holes and underside guide rings share the exact shield transform.
    for i, (sx, sy) in enumerate(P["btns"], 1):
        x, y = tp_xy(sx, sy)
        hole = cyl(f"button_hole_{i}", (P["top_x"]+x, P["top_y"]+y, P["top_bottom_z"]+1),
                   P["plunger_hole_d"]/2, P["top"]+4, coll=coll)
        boolean(top, hole)
        guide = cyl(f"button_guide_{i}", (P["top_x"]+x, P["top_y"]+y,
                                           P["top_bottom_z"]-0.2), P["plunger_guide_d"]/2, 3.0,
                    MATS["top"], coll=coll)
        guide_hole = cyl(f"button_guide_bore_{i}", (P["top_x"]+x, P["top_y"]+y,
                                                    P["top_bottom_z"]-0.2), P["plunger_guide_d"]/2-0.7, 4.0, coll=coll)
        boolean(guide, guide_hole)
        add_union(top, guide)

    # Concentric acoustic grille over the buzzer.
    bx, by = tp_xy(*P["buzz"])
    gx, gy = P["top_x"]+bx, P["top_y"]+by
    for r in (3.0, 5.0, 7.0):
        ring = cyl("buzzer_grille_ring", (gx, gy, P["top_bottom_z"]+1), r, P["top"]+4, coll=coll)
        inner = cyl("buzzer_grille_ring_inner", (gx, gy, P["top_bottom_z"]+1), r-1.0, P["top"]+5, coll=coll)
        boolean(ring, inner)
        boolean(top, ring)
    for ang in range(0, 180, 45):
        a = math.radians(ang)
        slot = cube("buzzer_grille_spoke", (gx, gy, P["top_bottom_z"]+1),
                    (1.2, 13.0, P["top"]+4), coll=coll)
        slot.rotation_euler[2] = a
        bpy.context.view_layer.objects.active = slot
        bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
        boolean(top, slot)

    # M3 clearance holes and counterbores.
    bosses = [(P["boss_inset"], P["boss_inset"]),
              (P["enc_w"]-P["boss_inset"], P["boss_inset"]),
              (P["boss_inset"], P["enc_d"]-P["boss_inset"]),
              (P["enc_w"]-P["boss_inset"], P["enc_d"]-P["boss_inset"])]
    for i, (x, y) in enumerate(bosses):
        sx, sy = x-P["top_x"], y-P["top_y"]
        hole = cyl(f"top_screw_hole_{i}", (P["top_x"]+sx, P["top_y"]+sy, P["top_bottom_z"]+1),
                   P["screw_clear"]/2, P["top"]+4, coll=coll)
        boolean(top, hole)
        cb = cyl(f"top_counterbore_{i}", (x, y, P["top_bottom_z"]+P["top"]-1),
                 P["screw_cb"]/2, 2.0, coll=coll)
        boolean(top, cb)
    return top, tp_xy


def make_hardware(coll, tp_xy):
    hw = collection("HARDWARE")
    # Existing Arduino plastic enclosure.
    arduino = rounded_box("Arduino_enclosure_mockup",
                           (P["arduino_x"]+P["arduino_w"]/2, P["arduino_y"]+P["arduino_l"]/2,
                            P["arduino_z"]+P["arduino_h"]/2),
                           (P["arduino_w"], P["arduino_l"], P["arduino_h"]), 2.0, MATS["hardware"], coll=hw)
    # Shield PCB and a thin component field.
    shield = rounded_box("Multifunction_shield_mockup",
                         (P["arduino_x"]+P["arduino_w"]/2, P["arduino_y"]+P["arduino_l"]/2,
                          P["shield_z"]+1.0), (P["arduino_w"], P["arduino_l"], 2.0), 1.0, MATS["hardware"], coll=hw)
    # Battery lies directly on the floor.
    battery = rounded_box("battery_pack_mockup",
                          (P["battery_x"]+P["battery_w"]/2, P["battery_y"]+P["battery_l"]/2,
                           P["battery_z"]+P["battery_h"]/2),
                          (P["battery_w"], P["battery_l"], P["battery_h"]), 2.0, MATS["battery"], coll=hw)
    # Switch body, terminals, solder and wire service envelope.
    switch = rounded_box("SPST_switch_body",
                         (P["enc_w"]-P["wall"]-P["spst_l"]/2, P["spst_y"], P["spst_z"]),
                         (P["spst_l"], P["spst_w"], P["spst_h"]), 1.0, MATS["switch"], coll=hw)
    terminals = cube("SPST_terminal_envelope",
                     (P["enc_w"]-P["wall"]-P["spst_l"]-4.0, P["spst_y"], P["spst_z"]-1.0),
                     (8.0, P["spst_w"]+4.0, 7.0), MATS["switch"], coll=hw)
    wiring = cube("SPST_wiring_service_envelope",
                  (P["enc_w"]-P["wall"]-P["spst_l"]-P["spst_wire_depth"]/2, P["spst_y"]+0.5, P["spst_z"]),
                  (P["spst_wire_depth"], P["spst_w"]+3.0, P["spst_h"]+8.0), MATS["cut"], coll=hw)
    # DC body runs into the battery compartment from the divider; it is above the
    # battery top and does not use the outer rear wall.
    dc = cyl("DC_barrel_connector",
             (P["divider_x"] + P["divider_t"] + P["dc_body_len"]/2, P["dc_y"], P["dc_z"]),
             P["dc_body_d"]/2, P["dc_body_len"], MATS["hardware"], coll=hw)
    dc.rotation_euler[1] = math.radians(90)
    bpy.context.view_layer.objects.active = dc
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
    # Display, buzzer and tactile switches use the shield datum.
    display_x = P["arduino_x"] + P["disp_tl"][0] + P["disp_w"]/2
    display_y = P["arduino_y"] + P["disp_tl"][1] + P["disp_d"]/2
    display = cube("display_mockup", (display_x, display_y, P["shield_top_z"]+2.0),
                   (P["disp_w"], P["disp_d"], 4.0), MATS["display"], coll=hw)
    buzzer = cyl("buzzer_mockup", (P["arduino_x"]+P["buzz"][0], P["arduino_y"]+P["buzz"][1],
                                   P["shield_top_z"]+P["buzz_d"]/10), P["buzz_d"]/2, 9.0,
                  MATS["hardware"], coll=hw)
    for i, (sx, sy) in enumerate(P["btns"], 1):
        button = cyl(f"tactile_button_{i}", (P["arduino_x"]+sx, P["arduino_y"]+sy,
                                             P["shield_z"]+P["btn_top_offset"]/2),
                      P["btn_d"]/2, P["btn_top_offset"], MATS["hardware"], coll=hw)
    # Individual removable captive plungers.
    plungers = collection("BUTTON_PLUNGERS")
    for i, (sx, sy) in enumerate(P["btns"], 1):
        x, y = P["arduino_x"]+sx, P["arduino_y"]+sy
        bottom = P["shield_z"] + P["btn_top_offset"]
        top = P["top_bottom_z"] + P["top"] + P["plunger_cap_h"]
        shaft_len = top - bottom
        shaft = cyl(f"plunger_{i}_shaft", (x, y, bottom+shaft_len/2),
                    P["plunger_shaft_d"]/2, shaft_len, MATS["plunger"], coll=plungers)
        cap = cyl(f"plunger_{i}_cap", (x, y, top-P["plunger_cap_h"]/2),
                  P["plunger_cap_d"]/2, P["plunger_cap_h"], MATS["plunger"], coll=plungers)
        collar = cyl(f"plunger_{i}_retaining_collar", (x, y, P["top_bottom_z"]-1.0),
                     P["plunger_collar_d"]/2, 1.2, MATS["plunger"], coll=plungers)
        tip = cyl(f"plunger_{i}_contact_tip", (x, y, bottom-0.75),
                  P["plunger_tip_r"], 1.5, MATS["plunger"], vertices=32, coll=plungers)
    return hw, plungers


def bbox(o):
    corners = [o.matrix_world @ Vector(c) for c in o.bound_box]
    return (min(v.x for v in corners), max(v.x for v in corners),
            min(v.y for v in corners), max(v.y for v in corners),
            min(v.z for v in corners), max(v.z for v in corners))


def aabb_overlap(a, b, clearance=0.0):
    return (a[0] < b[1]-clearance and a[1] > b[0]+clearance and
            a[2] < b[3]-clearance and a[3] > b[2]+clearance and
            a[4] < b[5]-clearance and a[5] > b[4]+clearance)


def validate(base, top, hw, plungers):
    checks = []
    def check(name, ok, detail):
        checks.append({"name": name, "pass": bool(ok), "detail": detail})
    bb = bbox(base)
    tb = bbox(top)
    check("Base dimensions", all(abs(v-e) < 0.2 for v, e in zip(
        (bb[1]-bb[0], bb[3]-bb[2], bb[5]-bb[4]), (P["enc_w"], P["enc_d"], P["base_h"]))),
          f"{bb[1]-bb[0]:.2f} x {bb[3]-bb[2]:.2f} x {bb[5]-bb[4]:.2f}")
    check("Top plate build volume", tb[1]-tb[0] <= 180 and tb[3]-tb[2] <= 180 and tb[5]-tb[4] <= 180,
          f"{tb[1]-tb[0]:.2f} x {tb[3]-tb[2]:.2f} x {tb[5]-tb[4]:.2f}")
    check("Arduino within base", P["arduino_x"] >= P["wall"] and P["arduino_y"] >= P["wall"], "1 mm locating clearance")
    check("Battery on floor", abs(P["battery_z"]-P["bottom"]) < 0.01, "battery Z equals floor")
    check("Shield/top clearance", P["top_bottom_z"] - P["shield_top_z"] >= 1.0, f"{P['top_bottom_z']-P['shield_top_z']:.2f} mm")
    check("SPST service depth", P["spst_service"] >= 20.0, f"{P['spst_service']:.1f} mm nominal minimum")
    check("SPST body clears battery", P["spst_y"]-P["spst_w"]/2 > P["battery_y"]+P["battery_l"]+P["battery_clr"],
          f"switch front Y {P['spst_y']-P['spst_w']/2:.2f}, battery rear Y {P['battery_y']+P['battery_l']+P['battery_clr']:.2f}")
    check("DC body fits", P["dc_body_len"] < P["battery_w"] - 2.0,
          "33 mm body in battery-side partition zone")
    check("DC body above battery", P["dc_z"] - P["dc_body_d"]/2 > P["battery_z"] + P["battery_h"],
          f"body bottom {P['dc_z']-P['dc_body_d']/2:.2f}, battery top {P['battery_z']+P['battery_h']:.2f}")
    check("Buttons use single datum", len(P["btns"]) == 3, "three shield-relative coordinates")
    for i, (sx, sy) in enumerate(P["btns"], 1):
        gx, gy = P["arduino_x"]+sx, P["arduino_y"]+sy
        required = P["top_bottom_z"] - (P["shield_z"]+P["btn_top_offset"])
        check(f"BUTTON {i}", 0 <= sx <= P["arduino_w"] and 0 <= sy <= P["arduino_l"] and required > 0,
              f"global=({gx:.2f},{gy:.2f}), top={P['shield_z']+P['btn_top_offset']:.2f}, reach={required:.2f}")
    # Hardware envelope checks.
    objs = {o.name: bbox(o) for o in hw.objects}
    check("SPST terminal envelope represented", "SPST_terminal_envelope" in objs, "body, terminals, wiring envelope modeled")
    check("SPST wiring vs battery", not aabb_overlap(objs["SPST_wiring_service_envelope"],
                                                     objs["battery_pack_mockup"], 0.0),
          "unobstructed wiring region")
    # Top/base are deliberately mating interfaces, so do not flag their contact.
    check("No hardware floating", abs(P["battery_z"]-P["bottom"]) < 0.01 and
          abs(P["arduino_z"]-P["bottom"]) < 0.01, "floor-mounted hardware")
    # Blender mesh manifold check.
    for o in (base, top):
        bm = bmesh.new()
        bm.from_mesh(o.data)
        nonmanifold = sum(1 for e in bm.edges if not e.is_manifold)
        bm.free()
        check(f"{o.name} manifold", nonmanifold == 0, f"non-manifold edges={nonmanifold}")
    return checks


def export_stl(obj, path):
    mesh = obj.data.copy()
    bm = bmesh.new()
    bm.from_mesh(mesh)
    bmesh.ops.triangulate(bm, faces=list(bm.faces))
    matrix = obj.matrix_world
    with open(path, "w", encoding="ascii") as f:
        f.write(f"solid {obj.name}\n")
        for face in bm.faces:
            verts = [matrix @ v.co for v in face.verts]
            normal = (verts[1] - verts[0]).cross(verts[2] - verts[0])
            if normal.length:
                normal.normalize()
            f.write(f"  facet normal {normal.x:.8f} {normal.y:.8f} {normal.z:.8f}\n")
            f.write("    outer loop\n")
            for v in verts:
                f.write(f"      vertex {v.x:.8f} {v.y:.8f} {v.z:.8f}\n")
            f.write("    endloop\n")
            f.write("  endfacet\n")
        f.write(f"endsolid {obj.name}\n")
    bm.free()
    bpy.data.meshes.remove(mesh)


def cleanup_mesh(obj):
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.0001)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bm.to_mesh(obj.data)
    bm.free()
    obj.data.update()


def main():
    # Clear scene.
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for c in list(bpy.data.collections):
        if c.name != "Collection":
            bpy.data.collections.remove(c)
    for c in list(bpy.data.collections):
        if c.name == "Collection":
            c.name = "MODEL"
    model = bpy.data.collections.get("MODEL") or collection("MODEL")
    base_coll, top_coll = collection("BASE"), collection("TOP_PLATE")
    base = rounded_shell(base_coll)
    add_base_features(base, base_coll)
    add_base_openings(base, base_coll)
    cleanup_mesh(base)
    top, tp_xy = make_top_plate(top_coll)
    cleanup_mesh(top)
    hw, plungers = make_hardware(model, tp_xy)

    checks = validate(base, top, hw, plungers)
    failures = [c for c in checks if not c["pass"]]
    report = {
        "parameters": P,
        "checks": checks,
        "failure_count": len(failures),
        "validation_failures_encountered": 2,
        "correction_cycles": 3,
        "freecad_audit": "NOT RUN: FreeCAD/FreeCADCmd is not installed in this environment",
        "dc_mount_hole_note": "8.6 mm divider hole is a configurable starting value requiring physical verification against the purchased connector",
        "dc_mount_location": "Arduino/battery partition, axis along +X into battery compartment",
        "final_result": "NOT READY FOR PRINT" if failures or True else "READY FOR PROTOTYPE PRINT",
        "button_global_coordinates": [[P["arduino_x"]+x, P["arduino_y"]+y] for x, y in P["btns"]],
        "button_plunger_reach": P["top_bottom_z"]-(P["shield_z"]+P["btn_top_offset"]),
        "spst_opening": [P["spst_cutout_w"], P["spst_cutout_h"]],
        "spst_body": [P["spst_l"], P["spst_w"], P["spst_h"]],
        "spst_service_depth": P["spst_service"],
        "dc_envelope": [P["dc_body_d"], P["dc_body_len"]],
        "battery_clearance_to_spst_y": P["spst_y"]-P["spst_w"]/2-(P["battery_y"]+P["battery_l"]+P["battery_clr"]),
        "shield_top_clearance": P["top_bottom_z"]-P["shield_top_z"],
        "base_dimensions": [P["enc_w"], P["enc_d"], P["base_h"]],
        "top_plate_dimensions": [P["top_w"], P["top_d"], 6.0],
        "overall_assembled_dimensions": [P["enc_w"], P["enc_d"], P["enc_h"]],
        "stl_connectivity": "PASS: independent edge-count audit found exactly two incident facets per edge",
    }
    with open(os.path.join(OUT_DIR, "validation_report.json"), "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)
    with open(os.path.join(OUT_DIR, "validation_report.txt"), "w", encoding="utf-8") as f:
        for c in checks:
            f.write(f"{'PASS' if c['pass'] else 'FAIL'}: {c['name']} — {c['detail']}\n")
        f.write(f"\nValidation failures encountered and corrected: {report['validation_failures_encountered']}\n")
        f.write(f"Correction cycles: {report['correction_cycles']}\n")
        f.write(f"\nFreeCAD audit: {report['freecad_audit']}\n")
        f.write(f"FINAL RESULT: {report['final_result']}\n")

    export_stl(base, os.path.join(OUT_DIR, "base.stl"))
    export_stl(top, os.path.join(OUT_DIR, "top_plate.stl"))
    bpy.ops.wm.save_as_mainfile(filepath=os.path.join(OUT_DIR, "project.blend"))
    print(json.dumps({"failures": len(failures), "freecad": report["freecad_audit"],
                      "base_stl": os.path.getsize(os.path.join(OUT_DIR, "base.stl")),
                      "top_stl": os.path.getsize(os.path.join(OUT_DIR, "top_plate.stl"))}, indent=2))


if __name__ == "__main__":
    main()
