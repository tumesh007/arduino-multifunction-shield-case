import Mesh, os
bp = os.path.expanduser("~/Arduino_Multifunction_Shield_Case/base_check.stl")
tp = os.path.expanduser("~/Arduino_Multifunction_Shield_Case/top_check.stl")
mb = Mesh.Mesh(bp)
bb = mb.BoundBox
print("BASE: X={:.2f}..{:.2f} ({:.2f})  Y={:.2f}..{:.2f} ({:.2f})  Z={:.2f}..{:.2f} ({:.2f})".format(
    bb.XMin,bb.XMax,bb.XMax-bb.XMin, bb.YMin,bb.YMax,bb.YMax-bb.YMin, bb.ZMin,bb.ZMax,bb.ZMax-bb.ZMin))
mt = Mesh.Mesh(tp)
bt = mt.BoundBox
print("TOP:  X={:.2f}..{:.2f} ({:.2f})  Y={:.2f}..{:.2f} ({:.2f})  Z={:.2f}..{:.2f} ({:.2f})".format(
    bt.XMin,bt.XMax,bt.XMax-bt.XMin, bt.YMin,bt.YMax,bt.YMax-bt.YMin, bt.ZMin,bt.ZMax,bt.ZMax-bt.ZMin))
bw=bb.XMax-bb.XMin; bd=bb.YMax-bb.YMin; bh=bb.ZMax-bb.ZMin
print("\nDIMENSION CHECKS:")
print("  Base: {:.1f} x {:.1f} x {:.1f}".format(bw, bd, bh))
print("  Width  117.6: {}".format("PASS" if abs(bw-117.6)<0.5 else "FAIL ({:.2f})".format(bw)))
print("  Depth   98.4: {}".format("PASS" if abs(bd-98.4)<0.5 else "FAIL ({:.2f})".format(bd)))
print("  Height  43.6: {}".format("PASS" if abs(bh-43.6)<0.5 else "FAIL ({:.2f})".format(bh)))
print("  Build vol: {}".format("PASS" if bw<=180 and bd<=180 and bh<=180 else "FAIL"))
tw=bt.XMax-bt.XMin; td=bt.YMax-bt.YMin; th=bt.ZMax-bt.ZMin
print("  Top: {:.1f} x {:.1f} x {:.1f}".format(tw, td, th))
print("  Top W 114.0: {}".format("PASS" if abs(tw-114.0)<1 else "FAIL"))
print("  Top D  94.8: {}".format("PASS" if abs(td-94.8)<1 else "FAIL"))
print("  Top H  ~6.0: {}".format("PASS" if abs(th-6.0)<1 else "FAIL"))
exit()
