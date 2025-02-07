include <BOSL2/std.scad>
include <BOSL2/joiners.scad>


/* [Render] */

part_insert = true;
part_insert_grid = true;
part_edge_left = true;
part_edge_right = true;
part_edge_top = true;
part_edge_bottom = true;
part_clip = true;

/* [Size] */
rows = 3;
columns = 3;

/* [Design] */

flush = false;

/* [hidden] */

width = 42;
height = 48.5;

grid_r = 2.8;
grid_frame_r = 2.4;
overlap = flush ? 0 : 1.6;
recess = flush ? 0 : 2;

epsilon = 0.01;

$fa = 1;
$fs = 0.4;


snap_depth = 0.3;

module pin()
{
   rabbit_clip(type="pin",length=4, width=5,snap=snap_depth,thickness=0.8,
      depth=2, compression=0.3,lock=false);
}

module pin_double()
{
   rabbit_clip(type="double",length=4, width=5,snap=snap_depth,thickness=0.8,
      depth=2, compression=0.3,lock=false);
}

module socket()
{
   rabbit_clip(type="socket",length=4, width=5,snap=snap_depth,thickness=0.8, 
      depth=2.2, lock=false,compression=0);
}


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

module grid(pos = 0, h, do_overlap = true)
{
   or = height / 2;
   ol = do_overlap ? overlap : 0;
   ir = or - grid_r + ol;
   difference() {
      translate([0, 0, pos]) rotate([0, 0, 30]) cylinder(h = h, r = or, $fn=6);
      translate([0, 0, pos]) rotate([0, 0, 30]) cylinder(h = h, r = ir, $fn=6);
   }
}

module pin_top_left()
{
   rotate([0, 0,  30]) translate([0, 21 - epsilon, 1]) rotate([270, 0, 0]) pin();
}
module pin_top_right()
{
   rotate([0, 0, -30]) translate([0, 21 - epsilon, 1]) rotate([270, 0, 0]) pin();
}
module pin_bottom_left()
{
   rotate([0, 0, 150]) translate([0, 21 - epsilon, 1]) rotate([270, 0, 0]) pin();
}
module pin_bottom_right()
{
   rotate([0, 0, 210]) translate([0, 21 - epsilon, 1]) rotate([270, 0, 0]) pin();
}

module insert()
{
   old_hole_y = -18;
   new_hole_y = -16.5;

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
         cylinder(4, 5, 5);
      }

      // hole for screw head
      translate([0, new_hole_y, 3])
      cylinder(10, 4, 4);

      // hole for screw
      translate([0, new_hole_y, -1])
      cylinder(10, 2, 2);

      // Subtract where grid is going
      grid(6 - recess - 0.5, 10);

      // Socket
      rotate([0, 0, -30]) translate([0, 21 + epsilon, 1 - epsilon]) rotate([270, 0, 0]) socket();
      rotate([0, 0,  30]) translate([0, 21 + epsilon, 1 - epsilon]) rotate([270, 0, 0]) socket();
      rotate([0, 0, 150]) translate([0, 21 + epsilon, 1 - epsilon]) rotate([270, 0, 0]) socket();
      rotate([0, 0, 210]) translate([0, 21 + epsilon, 1 - epsilon]) rotate([270, 0, 0]) socket();
   }
}

module hex()
{
   difference() {
      union() {
         if (part_insert) insert();
         if (part_insert_grid) grid(6 - recess - 0.5, 0.5);
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
            grid(0, 6 - recess, false);
            // Cut half of grid
            translate([-width - epsilon, -1.5 * height/2 - epsilon, 0]) cube([width, 1.5 * height + epsilon*2, 6]);
         }
         // Close half grid
         h = height - grid_frame_r*2;
         translate([-grid_frame_r, -h/2, 0]) cube([grid_frame_r*2, h, 6 - recess]);

         // Snaps
         top_row_x_offset = (rows % 2) * width/2; // x offset is half a hex when rows are odd
         if (!part_edge_top || iy < rows-1 || top_row_x_offset > 0) pin_top_right();
         pin_bottom_right();

         // Frame
         translate([-grid_frame_r, -1.5 * height / 2 - epsilon, 0]) cube([grid_frame_r, 1.5 * height + epsilon*2, 6 - recess]);
      }
   }
}

if (part_edge_right) {
   ix = columns;
   for (iy=[0:2:rows-1]) {
      translate([ix * width, 3/4 * height * iy, 0]) {
         difference() {
            grid(0, 6 - recess, false);
            // Cut half of grid
            translate([epsilon, -1.5 * height/2 - epsilon, 0]) cube([width, 1.5 * height + epsilon*2, 6]);
         }
         // Close half grid
         h = height - grid_frame_r*2;
         translate([-grid_frame_r, -h/2, 0]) cube([grid_frame_r*2, h, 6 - recess]);

         // Snaps
         if (!part_edge_top || iy < rows-1) pin_top_left();
         if (!part_edge_bottom || iy > 0) pin_bottom_left();

         // Frame
         translate([0, -1.5 * height / 2 - epsilon, 0]) cube([grid_frame_r, 1.5 * height + epsilon*2, 6 - recess]);
      }
   }
}

if (part_edge_bottom) {
   iy = -1;
   for (ix=[0:1:columns-1]) {
      translate([ix * width + width/2, 3/4 * height * iy, 0]) {
         difference() {
            grid(0, 6 - recess, false);
            // Cut half of grid
            translate([-width/2 - epsilon, -height + epsilon, 0]) cube([width + 2*epsilon, height, 6]);
         }

         // Snaps
         pin_top_left();
         if (!part_edge_right || ix < columns-1) pin_top_right();

         // Frame
         translate([-width/2 - epsilon, -grid_frame_r, 0]) cube([width + epsilon*2, grid_frame_r*2, 6 - recess]);
      }
   }
}


if (part_edge_top) {
   iy = rows;
   top_row_x_offset = (rows % 2) * width/2; // x offset is half a hex when rows are odd
   for (ix=[0:1:columns-1]) {
      translate([ix * width + top_row_x_offset, 3/4 * height * iy, 0]) {
         difference() {
            grid(0, 6 - recess, false);
            // Cut half of grid
            translate([-width/2 - epsilon, -epsilon, 0]) cube([width + 2*epsilon, height, 6]);
         }

         // Snaps
         if (!part_edge_left || ix > 0 || top_row_x_offset > 0) pin_bottom_left();
         if (!part_edge_right || ix < columns-1 || top_row_x_offset == 0) pin_bottom_right();

         // Frame
         translate([-width/2 - epsilon, -grid_frame_r, 0]) cube([width + epsilon*2, grid_frame_r*2, 6 - recess]);
      }
   }
}

// Add corners
if (part_edge_left && part_edge_bottom) {
   corner_x = -width/2;
   corner_y = -3/4 * height;
   translate([corner_x, corner_y]) {
      // Quarter grid in corner
      difference() {
         grid(0, 6 - recess, false);
         translate([-width/2 - epsilon, -height + epsilon, 0]) cube([width + 2*epsilon, height, 6]);
         translate([-width - epsilon, -1.5 * height/2 - epsilon, 0]) cube([width, 1.5 * height + epsilon*2, 6]);
      }
      pin_top_right();
   }
   translate([corner_x - grid_frame_r, corner_y - grid_frame_r]) {
      cube([width, grid_frame_r*2, 6 - recess]);
      cube([grid_frame_r*2, height/2, 6 - recess]);
      cube([grid_frame_r, height, 6 - recess]);
   }
}
if (part_edge_left && part_edge_top) {
   corner_x = -width/2;
   corner_y = rows * 3/4 * height;
   top_row_x_offset = (rows % 2) * width/2; // x offset is half a hex when rows are odd
   if (top_row_x_offset > 0) translate([corner_x, corner_y]) {
      // Quarter grid in corner
      difference() {
         grid(0, 6 - recess, false);
         translate([-width/2 - epsilon, -epsilon, 0]) cube([width + 2*epsilon, height, 6]);
         translate([-width - epsilon, -1.5 * height/2 - epsilon, 0]) cube([width, 1.5 * height + epsilon*2, 6]);
      }
      pin_bottom_right();
   }
   translate([corner_x - grid_frame_r, corner_y - grid_frame_r]) {
      cube([width, grid_frame_r*2, 6 - recess]);
      translate([0, -height/2 + grid_frame_r*2, 0]) cube([grid_frame_r*2, height/2 - grid_frame_r, 6 - recess]);
      translate([0, -height, 0]) cube([grid_frame_r, height, 6 - recess]);
   }
}
if (part_edge_right && part_edge_top) {
   corner_x = columns * width;
   corner_y = rows * 3/4 * height;
   top_row_x_offset = (rows % 2) * width/2; // x offset is half a hex when rows are odd
   if (top_row_x_offset == 0) translate([corner_x, corner_y]) {
      // Quarter grid in corner
      difference() {
         grid(0, 6 - recess, false);
         translate([-width/2 - epsilon, -epsilon, 0]) cube([width + 2*epsilon, height, 6]);
         translate([epsilon, -1.5 * height/2 - epsilon, 0]) cube([width, 1.5 * height + epsilon*2, 6]);
      }
      pin_bottom_left();
      // Close quarter grid
      translate([-grid_frame_r, -height/2 + grid_frame_r, 0]) cube([grid_frame_r*2, height/2, 6 - recess]);
   }
   translate([corner_x, corner_y]) {
      translate([-width, -grid_frame_r, 0]) cube([width + grid_frame_r, grid_frame_r*2, 6 - recess]);
      translate([0, -height, 0]) cube([grid_frame_r, height, 6 - recess]);
   }
}
if (part_edge_right && part_edge_bottom) {
   corner_x = columns * width;
   corner_y = -3/4 * height;
   translate([corner_x, corner_y]) {
      translate([-width, -grid_frame_r, 0]) cube([width + grid_frame_r, grid_frame_r*2, 6 - recess]);
   }
}

if (part_clip) {
   translate([-width, 0, 0]) pin_double();
}

