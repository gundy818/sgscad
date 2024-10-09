/* joint.scad
 * 
 * This produces a ball and socket joint.
 *
 * STATUS:
 * At the moment, this produces the socket in an outer sphere. It would
 * be better if it could cut the socket out of an arbitrary passed object.
 *
 * TODO:
 * - modify so it can cut the socket in any object.
 *
 */

$fn=128;

/**
 * Generates the ball with attached shaft fo=r the joint
 */
 module ball(d, shaft_d, shaft_len) {
    union() {
        sphere(d=d);

        translate([0, 0, 0])
        cylinder(h=shaft_len, d=shaft_d);
    }
}

/**
 * Creates a slot with rounded ends, swept through a particular angle.
 */
module slot(slot_width, h, angle) {
    hull()
    union() {
        translate([0, slot_width/2, 0])
        rotate([90, -90+angle, 0])
        rotate_extrude(angle=angle)
        square([h, slot_width]);

        cylinder(h=h, d=slot_width);

        rotate([0, angle, 0])
        cylinder(h=h, d=slot_width);
    }
}

/**
 * Makes an upside-down ice cream cone.
 */
module cone(height, angle, base_d) {
    // the angle per side is half the required angle
    angle_per_side = angle/2;

    // this si the top radius if the base radius is zero
    top_radius = height * tan(angle_per_side);
    
    // this is the top radius if including the base size
    top_radius_expanded = top_radius + base_d/2;
    
    cylinder(h = height, r1 = base_d/2, r2=top_radius_expanded);
}

/**
 * Build the socket.
 *
 * There are from 1 to 4 cutouts added for the shaft to move in:
 * There is always a hole of 'hold_d' diameter opened to allow
 * the shaft to fit. This allows the shaft to rotate around the z axis,
 * but not move any other way.
 *
 * If 'xslot_angle' is defined, a rounded slot is added in the x axis
 * that will permit the shaft to move + or - 'xslot_angle/2' degrees
 * in the X direction.
 *
 * If 'yslot_angle' is defined, a rounded slot is added in the y axis
 * that will permit the shaft to move + or - 'xslot_angle/2' degrees
 * in the y direction.
 *
 * If 'circle_angle' is defined, a cone shaped cutout is added which 
 * will allow the shaft to move 'circle_angle/2' degrees off centre
 * in any direction.
 */
module socket(inner_d, outer_d, hole_d,
              xslot_angle=undef, yslot_angle=undef,
              circle_angle=undef) {
    difference() {
        // outer sphere
        sphere(d=outer_d);

        // remove the inside
        sphere(d=inner_d);

        // always remove the cylinder aound the sshaft
        cylinder(h=outer_d/2, d=hole_d);

        if (xslot_angle != undef) {
            // remove the x slot
            rotate([0, -xslot_angle/2, 0])
            slot(hole_d, outer_d/2, xslot_angle);
        }

        if (yslot_angle != undef) {
            // remove the y slot
            rotate([0, -yslot_angle/2, 90])
            slot(hole_d, outer_d/2, yslot_angle);
        }
 
        if (circle_angle != undef) {
            cone(outer_d/2, circle_angle, hole_d);
        }
    }
}

/**
 * Create a complete ball and socket.
 *
 * Only the shaft diameter and length need to be specified. Everything
 * else has defaults.
 */
module ball_and_socket(shaft_d, shaft_len, clearance=0.35,
    xslot_angle=undef, yslot_angle=undef, circle_angle=undef,
    wall_thickness=4) {
    // the amount diameter has top be increased to make up for the wall 
    // thickness.
    wall_d = 2 * wall_thickness;

    // extra clearance to add to diameter to give clearance_d on both sides
    clearance_d = 2 * clearance;

    // hole diameter for the shaft
    hole_d = shaft_d + clearance_d;

    // inside dimansion of the socket
    ball_d = 1.6 * shaft_d;
        
    socket_inner_d = ball_d + clearance_d;
    socket_outer_d = socket_inner_d + wall_d;
 
    translate([0, 0, shaft_len])
    rotate([0, 180, 0]) {
        ball(ball_d, shaft_d, shaft_len);

        //rotate([0, -45, 0])
        socket(socket_inner_d, socket_outer_d, hole_d,
            xslot_angle=xslot_angle, yslot_angle=yslot_angle,
            circle_angle=circle_angle);
    }
}

if (false) {
    ball_and_socket(10, 25
        //xslot_angle=90,
        //yslot_angle=90,
        //circle_angle=90
    );
}

