/**
 * Desk drawer.
 *
 * This generates a simple box with drawers. You just need to tell it
 * the outside domensions of the box, and how many drawers you need.
 *
 * The available modules are:
 * - module drawer(size, thickness). Produces a single drawer.
 * - module case (size, n_drawers, thickness). Produces the case.
 * - module case_with_drawer(size, n_drawers, thickness, clearance=0.5). Produces a
 *    matched case and drawer.
 */

// the $fn is hardcoded in the two places where rounding is applied.
rounding_fn = 64;

/**
 * Render a single drawer.
 * size: [x, y, z] overall drawer size
 * thickness: How thick to make the walls and floor.
 */
module drawer(size, thickness) {
    handle_size = [size[0]/2, 10+thickness, thickness];
    
    // the rouding radius. This needs to be less than the thickness, or 
    // otherwise the handle will be zero thickness (or negative)
    rounding_d = thickness-1;

    // allow for rounding. 
    rounding = [rounding_d, rounding_d, rounding_d];

    union() {
        difference () {
            cube(size);
            translate([thickness, thickness, thickness])
            cube([size[0]-(thickness*2), size[1]-(thickness*2), size[2]]);
        }
        // hard coding this here, which I probably shouldn't?
        $fn = rounding_fn;
        translate([(size[0] - handle_size[0])/2, -handle_size[1]+thickness, size[2]/2 - thickness/2])
        // need to translate by the rounding diameter to put it back where it would be without
        // the minkowski
        translate(rounding/2)
        minkowski() { 
            cube(handle_size - rounding);
            sphere(d=rounding_d);
        }
    }
}

/**
 * Calculate the cutout size for each drawer
 * y and z are easy. For x:
 * - subtract the total space token up by dividers from the total x space;
 * - divide the remainder by the number of drawers.
 * Note: This gives the cutout size (drawer + clearance). You need
 * to subtract the clearance size from this size to get the actual drawer
 * size.
 */
function drawer_cutout_size(size, n_drawers, thickness) =
    [ (size[0] - ((n_drawers + 1) * thickness)) / n_drawers, 
        size[1]-thickness, size[2]-(2*thickness)];

/**
 * The outer case
 * size: [x, y, z] outer measurements
 * n_drawers: the number of drawers
 * thickness: Tthe thickness of walls
 */
module case (size, n_drawers, thickness, rounded) {
    // drawer_cutout is [x, y, z]
    drawer_cutout = drawer_cutout_size(size, n_drawers, thickness);
    echo("Drawer cutout = ", drawer_cutout);

    difference () {
        if (rounded) {
            // hard coding this here, which I probably shouldn't?
            $fn = rounding_fn;
            translate([thickness/2, thickness/2, thickness/2])
            minkowski() {
                cube(size - [thickness, thickness, thickness]);
                sphere(thickness/2);
            }
        }
        else {
            cube(size);
        }

        // take the cutouts for each drawer
        for (i = [0 : n_drawers-1]) {
            translate([thickness + (thickness + drawer_cutout[0])*i,
                -1, thickness])
            cube([drawer_cutout[0], drawer_cutout[1]+1, drawer_cutout[2]]);
        }
    }
}

/**
 * Print the case + one drawer.
 * This does all in one. It only renders one drawer.
 * size: [x, y, z] outer size
 * n_drawers: the number of drawers
 * clearance: the clearance (space) to leave between the drawer
 * and its cutout.
 * rounded: if true, the corners of the outer case are rounded (default: false)
 */
module case_with_drawer(size, n_drawers, thickness, clearance=0.5, rounded=false) {
    case(size, n_drawers, thickness, rounded);

    drawer_cutout = drawer_cutout_size(size, n_drawers, thickness);

    // reduce the drawer size by the clearance
    clearances = [2*clearance, clearance, 2*clearance];
    drawer_size = drawer_cutout - clearances;
    echo("Drawer size: ", drawer_size);
    
    translate([0, 0, 70])
    drawer(drawer_size, thickness);
}

// Sample
case_with_drawer([100, 100, 50], 2, 3, rounded=true);
