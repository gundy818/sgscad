/**
 * Archimedes screw.
 *
 */
 
$fs=0.5;
$fa=1;

/**
 * This is the 2d blade, shaped to fit into the curved cylinder
 * without going outside it.
 *
 * The blade is like a rectangle with a rounded end on the x+ end.
 * It is based on the origin, in the X+y+ quadrant.
 *
 * x: the length. The curved end has a radius of x.
 * y: The width of the blade.
 */
 module blade(x, y) {
    // how big to make the square used to chop bits off
    block_square = x*2;

    // this works by making a full circle with a radius of y, 
    // and then shopping bits off it.
    difference() {
        circle(x);

        // remove back end
        translate([-block_square, -block_square/2, 0])
        square(block_square);

        // remove the +y end
        translate([-1, y/2, 0])
        square(block_square);

        // remove the -y end
        translate([-1, -block_square-y/2, 0])
        square(block_square);
    }
}

/**
 * The archimedes screw. This is a cylinder, with a screw internally.
 *
 * h: the height/length of the cylinder
 * r: the inner radius of the tube
 * pitch: how far a full 360 degrees travels. ie. there is a full
 *        360 degree rotation of the blade/screw every 'pitch' distance.
 * thickness: the thickness of the cylinder wall. The blade that is rotated
 *            form the screw is twice this value wide. There is no logical
 *            reason for this, it just seems to work well.
 * 
 */
module archimedes_screw(h=100, r=15, pitch=40, thickness=1.75) {
    // t is the number of degrees to twist the blade as it is extruded
    // from the bottom of the cylinder to the top.
    t = (h/pitch) * 360;
    union() {
        difference() {
            cylinder(r=r+thickness, h=h);
            
            translate([0,0,-1])
            cylinder(r=r,h=h+2);
        }
        // sort of an axle. dont know if I need it?
        //cylinder(h=h, d=2*thickness);

        linear_extrude(height=h, twist=t)
        blade(r+0.1, thickness*2);
    }
}

archimedes_screw();
