/* [Render] */

// Part to export
part = "all"; // ["all", "insert", "grid"]

/* [Size] */
rows = 3;
columns = 3;
edge_left = false;
edge_right = false;
edge_top = false;
edge_bottom = false;

/* [Design] */

flush = true;

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

module grid(h2 = 0)
{
   h = 0.5;
   or = height / 2;
   ir = or - grid_r + overlap;
   difference() {
      translate([0, 0, 6 - recess - h]) rotate([0, 0, 30]) cylinder(h = h + h2, r = or, $fn=6);
      translate([0, 0, 6 - recess - h]) rotate([0, 0, 30]) cylinder(h = h + h2, r = ir, $fn=6);
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
      grid(10);
   }
}

module white2()
{
   difference() {
      insert();
      grid(10);
   }
}

module hex()
{
   difference() {
      union() {
         if (part == "insert" || part == "all") insert();
         if (part == "grid" || part == "all") grid();
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

if (edge_left) {

}


