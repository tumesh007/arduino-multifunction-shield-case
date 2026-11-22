import Mesh
import os

base_path = os.path.expanduser("~/Arduino_Multifunction_Shield_Case/base_check.stl")
top_path = os.path.expanduser("~/Arduino_Multifunction_Shield_Case/top_check.stl")

mesh_base = Mesh.Mesh(base_path)
bb = mesh_base.BoundBox
print("BASE bounding box:")
print("  X: {:.2f} to {:.2f} = {:.2f} mm".format(bb.XMin, bb.XMax, bb.XMax-bb.XMin))
print("  Y: {:.2f} to {:.2f} = {:.2f} mm".format(bb.YMin, bb.YMax, bb.YMax-bb.YMin))
print("  Z: {:.2f} to {:.2f} = {:.2f} mm".format(bb.ZMin, bb.ZMax, bb.ZMax-bb.ZMin))

mesh_top = Mesh.Mesh(top_path)
bb2 = mesh_top.BoundBox
print("\nTOP PLATE bounding box:")
print("  X: {:.2f} to {:.2f} = {:.2f} mm".format(bb2.XMin, bb2.XMax, bb2.XMax-bb2.XMin))
print("  Y: {:.2f} to {:.2f} = {:.2f} mm".format(bb2.YMin, bb2.YMax, bb2.YMax-bb2.YMin))
print("  Z: {:.2f} to {:.2f} = {:.2f} mm".format(bb2.ZMin, bb2.ZMax, bb2.ZMax-bb2.ZMin))

# Expected dimensions
enc_w = 117.6
enc_d = 91.4
enc_h = 39.6
top_t = 3.0
lip_inset = 1.5
general_clr = 0.3

base_h_exp = enc_h - top_t  # 36.6
tp_w_exp = enc_w - 2*lip_inset - 2*general_clr  # 114.0
tp_d_exp = enc_d - 2*lip_inset - 2*general_clr  # 88.0

bw = bb.XMax - bb.XMin
bd = bb.YMax - bb.YMin
bh = bb.ZMax - bb.ZMin

print("\nVERIFICATION:")
print("  Base width  {:.2f} (exp {:.1f}): {}".format(bw, enc_w, "PASS" if abs(bw-enc_w)<0.5 else "FAIL"))
print("  Base depth  {:.2f} (exp {:.1f}): {}".format(bd, enc_d, "PASS" if abs(bd-enc_d)<0.5 else "FAIL"))
print("  Base height {:.2f} (exp {:.1f}): {}".format(bh, base_h_exp, "PASS" if abs(bh-base_h_exp)<0.5 else "FAIL"))
print("  Fits build volume: {}".format("PASS" if bw<=180 and bd<=180 and bh<=180 else "FAIL"))

tw = bb2.XMax - bb2.XMin
td = bb2.YMax - bb2.YMin
th = bb2.ZMax - bb2.ZMin
print("  Top width   {:.2f} (exp {:.1f}): {}".format(tw, tp_w_exp, "PASS" if abs(tw-tp_w_exp)<1.0 else "FAIL"))
print("  Top depth   {:.2f} (exp {:.1f}): {}".format(td, tp_d_exp, "PASS" if abs(td-tp_d_exp)<1.0 else "FAIL"))
print("  Top height  {:.2f} (exp ~4.7): {}".format(th, "PASS" if abs(th-4.7)<1.0 else "FAIL"))

exit()
