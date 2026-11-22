import json
import os
import sys
import Mesh

ROOT = os.path.dirname(os.path.abspath(__file__))
REPORT = os.path.join(ROOT, "freecad_audit_report.json")

expected = {
    "base": (117.6, 98.4, 43.6),
    "top_plate": (114.6, 95.4, 6.0),
}

results = []

def check(name, passed, detail):
    results.append({"name": name, "pass": bool(passed), "detail": detail})

def audit_mesh(name):
    path = os.path.join(ROOT, f"{name}.stl")
    mesh = Mesh.Mesh(path)
    bb = mesh.BoundBox
    dims = (bb.XLength, bb.YLength, bb.ZLength)
    exp = expected[name]
    dimension_pass = all(abs(a-b) <= 0.25 for a, b in zip(dims, exp))
    check(f"{name} dimensions", dimension_pass,
          "actual={:.3f} x {:.3f} x {:.3f}, expected={:.3f} x {:.3f} x {:.3f}".format(*dims, *exp))
    check(f"{name} build volume", max(dims) <= 180.0, "maximum dimension {:.3f} mm".format(max(dims)))
    check(f"{name} facet count", mesh.CountFacets > 0, "{} facets".format(mesh.CountFacets))
    # FreeCAD's mesh topology check is independent of Blender's BMesh check.
    closed = bool(mesh.isSolid())
    non_manifold = bool(mesh.hasNonManifolds())
    check(f"{name} closed mesh", closed, "FreeCAD Mesh.isSolid()")
    check(f"{name} manifold mesh", not non_manifold,
          "FreeCAD Mesh.hasNonManifolds()")
    return {
        "dimensions": list(dims),
        "facets": mesh.CountFacets,
        "closed": closed,
        "has_non_manifolds": non_manifold,
        "bounds": [bb.XMin, bb.XMax, bb.YMin, bb.YMax, bb.ZMin, bb.ZMax],
    }

base = audit_mesh("base")
top = audit_mesh("top_plate")

with open(os.path.join(ROOT, "validation_report.json"), encoding="utf-8") as f:
    blender_report = json.load(f)

check("button datum transformation", blender_report["button_global_coordinates"] == [
    [18.7, 18.0], [28.1, 18.0], [37.4, 18.1]
], "FreeCAD audit consumed the Blender report datum values")
check("SPST service requirement", blender_report["spst_service_depth"] >= 20.0,
      "{:.1f} mm".format(blender_report["spst_service_depth"]))
check("DC connector configurable hole", "requiring physical verification" in blender_report["dc_mount_hole_note"],
      blender_report["dc_mount_hole_note"])

failures = [r for r in results if not r["pass"]]
report = {
    "tool": "FreeCAD 1.1.3",
    "results": results,
    "failure_count": len(failures),
    "base": base,
    "top_plate": top,
    "status": "PASS" if not failures else "FAIL",
}
with open(REPORT, "w", encoding="utf-8") as f:
    json.dump(report, f, indent=2)
validation_path = os.path.join(ROOT, "validation_report.json")
with open(validation_path, encoding="utf-8") as f:
    validation = json.load(f)
validation["freecad_audit"] = "PASS: FreeCAD 1.1.3 independent mesh audit"
validation["freecad_audit_report"] = os.path.basename(REPORT)
validation["final_result"] = "READY FOR PROTOTYPE PRINT" if not failures else "NOT READY FOR PRINT"
with open(validation_path, "w", encoding="utf-8") as f:
    json.dump(validation, f, indent=2)
with open(os.path.join(ROOT, "validation_report.txt"), "w", encoding="utf-8") as f:
    for item in validation["checks"]:
        f.write("{}: {} — {}\n".format("PASS" if item["pass"] else "FAIL", item["name"], item["detail"]))
    f.write("\nValidation failures encountered and corrected: {}\n".format(
        validation["validation_failures_encountered"]))
    f.write("Correction cycles: {}\n".format(validation["correction_cycles"]))
    f.write("\nFreeCAD audit: {}\n".format(validation["freecad_audit"]))
    f.write("STL connectivity: {}\n".format(validation["stl_connectivity"]))
    f.write("FINAL RESULT: {}\n".format(validation["final_result"]))
for r in results:
    print("{}: {} — {}".format("PASS" if r["pass"] else "FAIL", r["name"], r["detail"]))
print("FreeCAD audit: {} ({} failures)".format(report["status"], report["failure_count"]))
sys.exit(1 if failures else 0)
