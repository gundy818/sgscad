// Chain link module

$fn = $preview ? 32 : 64;

module chain_link(length, width, thickness) {
    side_length = length - ( 2 * thickness );
    assert(side_length > thickness, "Link is not long enough to make a chain.");
    
    top_length = width - ( 2 * thickness );
    assert(top_length > thickness, "Link is not wide enough to make a chain.");

    translate([0, 0, width - thickness/2])
    rotate([0, 90, 0])
    union() {
        translate([0, 0, thickness])
        cylinder(h=side_length, d=thickness);
        
        translate([width - thickness, 0, thickness])
        cylinder(h=side_length, d=thickness);
    
        translate([thickness/2, 0, thickness/2])
        rotate([0, 90, 0])
        cylinder(h=width - ( 2*thickness), d=thickness);
    
        translate([thickness/2, 0, length - thickness/2])
        rotate([0, 90, 0])
        cylinder(h=width - ( 2*thickness), d=thickness);
        
        translate([thickness/2, 0, thickness])
        rotate([90, 180, 0])
        rotate_extrude(angle = 90)
        translate([thickness/2, 0, 0])
        circle(d=thickness);
        
        translate([width - (1.5 * thickness), 0, thickness])
        rotate([90, 90, 0])
        rotate_extrude(angle = 90)
        translate([thickness/2, 0, 0])
        circle(d=thickness);
        
        translate([thickness/2, 0, length - thickness])
        rotate([90, 270, 0])
        rotate_extrude(angle = 90)
        translate([thickness/2, 0, 0])
        circle(d=thickness);
        
        translate([width - (1.5 * thickness), 0, length - thickness])
        rotate([90, 0, 0])
        rotate_extrude(angle = 90)
        translate([thickness/2, 0, 0])
        circle(d=thickness);

    }
}


// Chain module
module chain(num_links, length, width, thickness) {
    // How far to move each link along
    x_step_length = length - thickness * 2 - 1;

    for (i = [0:num_links-1]) {
        x = i * x_step_length;
        x_rotate = ( i % 2 ) * 90;
        // echo("XXX: i=", i, ", x=", x, ", x_step_length=", x_step_length);
        // echo("XXX: x_rotate=", x_rotate);
        rotate([x_rotate + 45, 0, 0])
        translate([x, 0, -width/2])
        chain_link(length, width, thickness);
    }
}


module chain_link_r(length, width, thickness) {
    straight_length = length - width;
    width_offset = ( width - thickness ) / 2;

    union() {
        translate([0, 0, width_offset])
        rotate([0, 90, 0])
        cylinder(h=straight_length+0.1, r=thickness/2, center=true);

        translate([0, 0, -width_offset])
        rotate([0, 90, 0])
        cylinder(h=straight_length+0.1, r=thickness/2, center=true);
    
        translate([-(length - width)/2, 0, 0])
        rotate([0, 90, 90])
        rotate_extrude(angle=180)
        translate([width_offset, 0, 0])
        circle(d=thickness);

        translate([length/2 - width/2, 0, 0])
        rotate([0, 90, -90])
        rotate_extrude(angle=180)
        translate([width_offset, 0, 0])
        circle(d=thickness);
    }
}


// Chain module
module chain_r(num_links, length, width, thickness) {
    // How far to move each link along
    x_step_length = length - thickness * 2 - 1;

    for (i = [0:num_links-1]) {
        x = i * x_step_length;
        x_rotate = ( i % 2 ) * 90;
        rotate([x_rotate, 0, 0])
        translate([x, 0, 0])
        chain_link_r(length, width, thickness);
    }
}


// Create a chain with 4 links, each link is 20mm long, 13mm wide, and 4mm thick
// chain(4, 20, 13, 4);

// create a single chain link 20mm long, 13mm wide, and 4mm thic
// chain_link(20, 13, 4);

// Create a chain with 4 links, each link is 20mm long, 13mm wide, and 4mm thick
//chain_r(4, 25, 12, 3);

// create a single chain link 20mm long, 13mm wide, and 4mm thic
//chain_link_r(20, 13, 4);
//link_r(20, 13, 4);


// Ring parameters
outer_diameter = 20;
inner_diameter = 18;
height = 5;
edge_radius = 0.5;

// Create the ring with rounded edges
//difference() {
    //minkowski() {
      ////  cylinder(h=height-2*edge_radius, d=outer_diameter-2*edge_radius, center=true);
//        sphere(r=edge_radius);
  //  }
    //cylinder(h=height+1, d=inner_diameter, center=true);
//}


// nunchuck link 25mm long, 11mm wide, 2.62mm thick
