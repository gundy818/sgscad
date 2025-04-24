/**
 * Archimedes screw.
 *
 * This lets you generate a bare screw, and also a screw embedded in a pipe.
 * Apparently these screws are best operated at an inclination of 34 degrees
 * to the horizontal, and efficiency drops dramatically over 40 degrees.
 * I haven't done any testing, but these numbers sound OK intuitively.
 *
 * The pitch of the screw also affects efficiency. These screws default to
 * a pitch/diameter ratio of 1.4, which is supposed to be optimal, but again
 * I haven't tested it.
 *
 * USAGE:
 * use <sgscad/archimedes.scad>
 *
 * archimedes_screw_tube();
 *
 * This generates a default sized tube. Or if you just want the
 * screw(no tube):
 *
 * archimedes_screw(100, 10, 1000, 2);
 *
 * Look at the comments on those modules to see the parameters available.
 */
 
$fs=0.5;
$fa=1;

/**
 * This is the 2d blade, shaped to fit into the curved cylinder
 * without going outside it.
 *
 * The blade is like a rectangle with a rounded end on the x+ end.
 * It is based on the origin, in the x+y+ quadrant.
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
 * Bare archimedes screw.
 *
 * h: the height/length
 * r: the radius of the screw
 * twist: the number of degrees to rotate over the length
 * thickness: the thickness of the blade
 */
module archimedes_screw(h, r, twist, thickness) {
    union() {
        linear_extrude(height=h, twist=twist)
        blade(r+0.1, thickness);

        cylinder(h=h, d=thickness);
    }
}

/**
 * The archimedes screw pipe. This is a cylinder, with a screw internally.
 *
 * h: the height/length of the cylinder
 * r: the inner radius of the tube
 * pitch_ratio: the ratio of the screw pitch (distance between threads)
 *              to the cylinder diameter. Optimal performance should
 *              be 1.4, but you can override it if you want.
 * thickness: the thickness of the cylinder wall. The blade that is rotated
 *            to form the screw is also this wide.
 */
module archimedes_screw_tube(h=100, r=10, pitch_ratio=1.4, thickness=1.75) {
    // pitch is 'pitch_ratio * outer diameter of thread.
    pitch = (r * 2) * 1.4;
    echo("archimedes pitch: ", pitch);
    echo("archimedes screw rotations: ", h/pitch);

    // t is the number of degrees to twist the blade as it is extruded
    // from the bottom of the cylinder to the top.
    t = (h/pitch) * 360;
    union() {
        difference() {
            cylinder(r=r+thickness, h=h);
            
            translate([0,0,-1])
            cylinder(r=r,h=h+2);
        }
        archimedes_screw(h, r, t, thickness);
    }
}

archimedes_screw_tube();
translate([40, 0, 0])
archimedes_screw(100, 10, 1000, 2);
