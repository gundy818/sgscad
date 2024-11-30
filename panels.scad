/**
 * panels.scad
 *
 * This contains (or will contain) modules and functions to make various plates etc. At the 
 * moment it only contains:
 *
 * - module sloped_plater, to produce a flat plate with endcaps at a specified angle.
 * - function sloped_plate_extra(). returns the amount of extra length is added to a
 *    plate based on its angle.
 * - module wedge(angle, length, thickness). Produces a wedge witht he specified
 *    dimensions
 * 
 * - function max_coin_d (v, m=undef, i=0). Given a list of coins (diameter, thickness
 *    pairs) , returns the largest diameter.
 * 
 * - function max_coin_thickness (v, m=undef, i=0). Given a list of coins (diameter, thickness
 *    pairs) , returns the largest ckness.
 *
 * - function get_row_col(index, width). Given an index into a list, return the [row,
 *    col] it is in if the list is divided into rows of 'width' length.
 * 
 * - module coin_holder_panel(coins, angle, coins_per_row = 0). Given a list of coins and
 *    a desired angle, build a coin display panell for the coins.
 *
 * For example, to create a holder for four coins:
 *
 * // order this in the order you want the coins
 * coins = [
 * [56.92, 10.2], 
 * [51.4, 8.3],
 * [45.2, 7.3],
 * [37.2, 6.4]];
 *
 * This would display four coins in a single row:
 * coin_holder_panel(coins, 45);
 *
 * This would display teo rows of two coins each:
 * coin_holder_panel(coins, 45, 2);
 *
 * This would display four coins in a vertical column:
 * coin_holder_panel(coins, 45, 1);
 *
 */


$fn=90;

/** 
 * calculates how much extra the slope to the back panel will extend
 * past the edges of the plate on the y direction.
 */
 function sloped_plate_extra(z, angle) = z/(tan(90 - angle));

/**
 * creates a sloped plate that slopes up as in goes back in the Y
 * direction.
 * All four size surfaces are vertical, but the top and bottom slope at 
 * the provided angle.
 * x, y are the core length of the top surface.
 * z is the thickness.abs
 * Returns: The plate is laid flat on its back, with the front left corner
 * of the core x,y sorface at x=0, y=0. BUT the sloped surface extends
 * past this in the x direction.
 * So you still have to rotate this yourself to the angle.
 */
module sloped_plate(x, y, z, angle, top_horizontal=false) {
    // calculate the trapezoid looking from the -x direction
    
    // the offset of the base from the top
   y_d = sloped_plate_extra(z, angle);

    // poit a. rear bottom
    a = top_horizontal ? [0, y + y_d] : [0, y - y_d];
    
    // b: front bottom
    b = [0, -y_d];
    
    // c: front top
    c = [z, 0];
    
    // d: rear top
    d = [z, y];
       
    trapezoid = [a, b, c, d];

    translate([x, 0, 0])
    rotate([0, -90, 0])
    linear_extrude(height = x) {
        polygon(points = trapezoid);
    }
}
//sloped_plate(40,30,4,45, top_horizontal=true);

module wedge(angle, length, thickness) {
    // horizontal y length
    y_len = length * cos(angle);

    // vertical z length
    z_len = length * sin(angle);

    // Calculate the height of the wedge
    height = tan(angle) * length;

    // Create the wedge shape
    linear_extrude(height = thickness, center = true, convexity = 10)
    polygon(points = [
        [0, 0],
        [y_len, 0],
        [y_len, z_len],
        [0, 0]
    ]);
}

function max_coin_d (v, m=undef, i=0) = 
    // if i is the length, return the currenct max, else calculate
    i == len(v) ? m :
    max_coin_d(v,
        m == undef ? v[i][0] : 
        (v[i][0] > m ? v[i][0] : m),
        i + 1);

function max_coin_thickness (v, m=undef, i=0) = 
    // if i is the length, return the current max, else calculate
    i == len(v) ? m :
    max_coin_thickness(v,
        m == undef ? v[i][1] : 
        (v[i][1] > m ? v[i][1] : m),
        i + 1);

/**
 * returns the cow and column for a specific coin
 */
function get_row_col(index, width) =
    [floor(index / width), index % width];


/**
 * Build a coin holder.
 * 'coins' is a list of coin measurements. Each coin is 
 * a [diameter, thickness] list.
 * angle is the angle of the display face plate.
 * row_len is the maximum number of coins you want in one row.
 * If not specified, it'll be the number of coins in the list
 * (so you'll only get one row).
 */
module coin_holder_panel(coins, angle, coins_per_row = 0) {
    // amount to add tho the coin diameter for the hole
    // rinter hole size is 0.4mm less than specified for some reason
    coin_d_extra = 0.5;

    row_len = coins_per_row == 0 ? len(coins) : coins_per_row;

    // extra size to allow around each coin hole
    coin_pad = 2.5;

    // size of each coin block, sized to the largest coin
    max_d = max_coin_d(coins) + coin_d_extra + coin_pad;
    max_thickness = max_coin_thickness(coins);

    // extra thickness for the base
    base_buffer = 2;

    // calculate sizes for panel based on number of coins
    cols = min(row_len, len(coins));
    rows = floor((len(coins) + cols - 1) / cols);
    block_size = max_d + ( 2 * coin_pad );

    base_width = cols * block_size;
    base_height = rows * block_size;
    base_thickness = ( max_thickness/2 ) + base_buffer;

    union() {
        // extra length past the block size used to make the sloped panel
        y_extra = sloped_plate_extra(base_thickness, angle);
        rotate([angle, 0, 0])
        // move is so the front of the rear surface is at y=0
        translate([0, y_extra, 0])
        difference() {
            // create the plate
            sloped_plate(base_width, base_height, base_thickness, angle,
                top_horizontal=true);
 
            // subtract the coins
            for (i = [0 : len(coins) - 1]) {
                row_col = get_row_col(i, row_len);
                x_offset = (row_col[1] + 0.5) * block_size;
                y_offset = ((row_col[0] + 0.5)  * block_size );

                coin_hole_d = coins[i][0] + coin_d_extra;
                coin_thickness = coins[i][1];

                translate([x_offset, y_offset, base_thickness - coin_thickness/2])
                union() {
                    // coin
                    cylinder(h=coin_thickness, d=coin_hole_d);

                    // hole in back to let you poke the coin out
                    translate([0, coin_hole_d/4,
                        -base_thickness-coin_thickness+1])
                    cylinder(h=base_thickness + coin_thickness, d=4);
                }
            }
        }

        // the end plates
        support_thickness = 3;
        translate([support_thickness/2, 0, 0])
        rotate([90, 0, 90])
        wedge(angle, base_height  + ( 2 * y_extra ), support_thickness);

        translate([(cols * block_size) - support_thickness/2, 0, 0])
        rotate([90, 0, 90])
        wedge(angle, base_height + ( 2 * y_extra ), support_thickness);        
    }
}

