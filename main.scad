include <BOSL2/std.scad>
include <BOSL2/joiners.scad>


/* [Render] */

part_insert = true;
part_grid = true;
part_edge_left = false;
part_edge_right = false;
part_edge_top = false;
part_edge_bottom = false;

/* [Size] */
rows = 3;
columns = 3;

/* [Design] */

flush = false;

/* [hidden] */

width = 42;
height = 48.5;

grid_r = 2.8;
overlap = flush ? 0 : 1.8;
recess = flush ? 0 : 2;

$fa = 1;
$fs = 0.4;

module chamfer()
{
   difference() {
      h = 0.5;
      or = height / 2;
      ir = or - grid_r + overlap;
      translate([0, 0, 6 - h]) rotate([0, 0, 30]) cylinder(h = 0.5, r1 = ir, r2 = ir + 0.5, $fn=6);
      translate([0, 0, 6 - h]) rotate([0, 0, 30]) cylinder(h = 0.5, r1 = ir, r2 = ir - 0.5, $fn=6);
   }

}

module grid(pos = 0, h)
{
   or = height / 2;
   ir = or - grid_r + overlap;
   difference() {
      translate([0, 0, pos]) rotate([0, 0, 30]) cylinder(h = h, r = or, $fn=6);
      translate([0, 0, pos]) rotate([0, 0, 30]) cylinder(h = h, r = ir, $fn=6);
   }
}

module insert()
{
   old_hole_y = -18;
   new_hole_y = -16.25;

   difference() {
      union() {
         // Load original hex
         translate([0, 0, 6])
         rotate([270, 270, 0])
         import("single.stl");

         // Fill mount hole - have to move it a bit
         translate([0, old_hole_y, 0])
         cylinder(6, 5, 5);

         // support for new hole on back side
         translate([0, new_hole_y, 0])
         cylinder(4, 6, 6);
      }

      // hole for screw head
      translate([0, new_hole_y, 5])
      cylinder(3, 3.5, 3.5);

      // hole for screw
      translate([0, new_hole_y, -1])
      cylinder(8, 2, 2);

      // Subtract where grid is going
      grid(6 - recess - 0.5, 10);
   }
}

module hex()
{
   difference() {
      union() {
         if (part_insert) insert();
         if (part_grid) grid(6 - recess - 0.5, 0.5);
      }
      chamfer();
   }
}

for (ix=[0:1:columns-1]) {
   for (iy=[0:2:rows-1]) {
      translate([ix * width, 3/4 * height * iy, 0]) hex();
   }
   for (iy=[1:2:rows-1]) {
      translate([ix * width + width/2, 3/4 * height * iy, 0]) hex();
   }
}

if (part_edge_left) {
   ix = -1;
   for (iy=[1:2:rows-1]) {
      translate([ix * width + width/2, 3/4 * height * iy, 0]) {
         difference() {
            grid(0, 6 - recess);
            translate([-width, -1.5 * height / 2, 0]) cube([width, 1.5 * height, 6]);
         }
         translate([-grid_r/2, -1.5 * height / 2, 0]) cube([grid_r, 1.5 * height, 6 - recess]);
      }
   }
}

/*
module test_pair(length, width, snap, thickness, compression, lock=false)
{
  depth = 5;
  extra_depth = 10;// Change this to 0.4 for closed sockets
  cuboid([max(width+5,12),12, depth], chamfer=.5, edges=[FRONT,"Y"], anchor=BOTTOM)
      attach(BACK)
        rabbit_clip(type="pin",length=length, width=width,snap=snap,thickness=thickness,depth=depth,
                    compression=compression,lock=lock);
  right(width+13)
  diff("remove")
      cuboid([width+8,max(12,length+2),depth+3], chamfer=.5, edges=[FRONT,"Y"], anchor=BOTTOM)
        tag("remove")
          attach(BACK)
            rabbit_clip(type="socket",length=length, width=width,snap=snap,thickness=thickness,
                        depth=depth+extra_depth, lock=lock,compression=0);
}
left(37)ydistribute(spacing=28){
  test_pair(length=6, width=7, snap=0.25, thickness=0.8, compression=0.1);
  test_pair(length=3.5, width=7, snap=0.1, thickness=0.8, compression=0.1);  // snap = 0.2 gives a firmer connection
  test_pair(length=3.5, width=5, snap=0.1, thickness=0.8, compression=0.1);  // hard to take apart
}
right(17)ydistribute(spacing=28){
  test_pair(length=12, width=10, snap=1, thickness=1.2, compression=0.2);
  test_pair(length=8, width=7, snap=0.75, thickness=0.8, compression=0.2, lock=true); // With lock, very firm and irreversible
  test_pair(length=8, width=7, snap=0.75, thickness=0.8, compression=0.2, lock=true); // With lock, very firm and irreversible
}
*/

