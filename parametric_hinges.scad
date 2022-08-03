// Height of the hinge inline with the axis
hinge_height = 40; // .1
// Width of the hinge across the plate including the axis
hinge_width = 20; // .1
// Thickness of the hinge when folded, same as the diameter of the axis
hinge_thick = 6; // .1
// Number of fingers on the hinge, must be odd
hinge_fingers = 7; // [3:2:21]
// Radius of the hinge plate corners
corner_radius = 7.5;

/* [Axis] */
// Axis type
axis_style = "pip"; // [bolt: Through Bolt, pip: Print in Place]
// Clearance drill for bolt style
axis_clear = 3.5; // .1
// Tapping drill for bolt style
axis_tap = 2.5; // .1
// Pin dia for Print in Place
axis_pin = 3; // .1

/* [Mounting Holes] */
// Mounting hole type
hole_style = "csk"; // [plain: Plain Holes, csk: Countersunk]
// Mounting hole drill size
hole_drill = 3.5; // .1
// Number of holes per plate
hole_number = 3; // [0:1:10]
// Hole spacing, 0 for even spacing
hole_spacing = 0; // .1
// Counter sink outer dia for csk style
hole_csk_dia = 7; // .1

/* [Advanced] */
// Circle facets
$fn=32;
// Clearancing, appears between the fingers and around the print in place axis
clearance = 0.3;

// ====================

leaf_thick = hinge_thick/2;

finger_step = (hinge_height + clearance) / hinge_fingers;
finger_width = finger_step + clearance;


module leaf_base() {
    difference() {
        union() {
            translate([0, 0, leaf_thick])
                rotate([-90, 0, 0])
                cylinder(h=hinge_height, d=hinge_thick);
            translate([-leaf_thick,
                       0,
                       0])
                cube([hinge_width-corner_radius,
                      hinge_height,
                      leaf_thick]);
            translate([hinge_width-corner_radius-leaf_thick,
                       corner_radius,
                       0])
                cylinder(r=corner_radius, h=leaf_thick);
            translate([hinge_width-corner_radius-leaf_thick,
                       hinge_height-corner_radius,
                       0])
                cylinder(r=corner_radius, h=leaf_thick);
            translate([hinge_width-corner_radius-leaf_thick,
                       corner_radius,
                       0])
                cube([corner_radius, hinge_height - 2*corner_radius, leaf_thick]);
        }
        rotate([-90, 0, 0])
            linear_extrude(hinge_height)
            polygon([[-leaf_thick, 0],
                     [-leaf_thick, -leaf_thick],
                     [-leaf_thick/2, 0]]);


    }
}

module holes() {
    plate_width = hinge_width-leaf_thick*2;
    plate_centre = leaf_thick + plate_width/2;
    
    
    v_plate_height = hinge_height + (hole_style == "csk" ? hole_csk_dia : hole_drill);
    v_plate_offset = -(hole_style == "csk" ? hole_csk_dia : hole_drill)/2;
    
    hole_spacing = (hole_spacing == 0 ? v_plate_height/(hole_number + 1) : hole_spacing);
    hole_offset = ((v_plate_height - (hole_spacing * (hole_number - 1)))/2) + v_plate_offset;
    
    difference() {
        children();

        for(hole=[0:hole_number-1]) {
            translate([plate_centre,
                       hole_offset + hole_spacing*hole, 
                       0]) {
                cylinder(h=leaf_thick, d=hole_drill);

                if(hole_style == "csk") {
                    translate([0,
                               0,
                               leaf_thick - hole_csk_dia/2])
                        cylinder(h=hole_csk_dia/2,
                                 d1=0,
                                 d2=hole_csk_dia);
                }
            }
        }
    }
}

module hinge_slots(start_idx) {
    difference() {
        children();
        
        for(step=[start_idx:2:hinge_fingers-1]) {
            translate([-leaf_thick,
                       step*finger_step,
                       0])
                cube([hinge_thick + clearance/2,
                      finger_width,
                      hinge_thick]);
        }
    }
}

module left() {
    difference() {
        hinge_slots(0) holes() leaf_base();

        if(axis_style == "bolt") {
            translate([0, 0, leaf_thick])
                rotate([-90, 0, 0])
                cylinder(h=hinge_height, d=axis_clear);
        } else if(axis_style == "pip") {
            translate([0, 0, leaf_thick])
                rotate([-90, 0, 0])
                    cylinder(h=hinge_height,
                             d=axis_pin+clearance*2);
        }
    }
}

module right() {
    difference() {
        union() {
            hinge_slots(1) holes() leaf_base();
            
            if(axis_style == "pip") {
                translate([0, 0, leaf_thick])
                    rotate([-90, 0, 0])
                        cylinder(h=hinge_height,
                                 d=axis_pin);
            }
        }
        
        if(axis_style == "bolt") {
            translate([0, 0, leaf_thick])
                rotate([-90, 0, 0]){
                    translate([0, 0, finger_step])
                        cylinder(h=hinge_height-finger_step,
                                 d=axis_clear);
                    cylinder(h=finger_step, d=axis_tap);
                }
        }
    }
}
left();
mirror([1, 0, 0]) right();