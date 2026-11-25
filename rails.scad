use <murmelburg_modules.scad>;

// Rail module (flat track without drop)
// units: number of 50mm segments (for angle 90: length = units*50 - 25)
// step: step size for the rail
// angle: bend angle in degrees (0 = straight, 90 = quarter turn, 180 = half turn)
// fn: facet count for the rail
module rail(units = 1, step = 1 , angle= 0, fn = 20) {
    asstert (units > 0, "units must be greater than 0");
    assert (floor(units) == units, "units must be an integer");
    length = angle == 90 ? units * 50 -25 : units * 50;
    if (angle == 0) {
        union() {
            tilted_ramp(function(x) 0, function(x) 0, function(x) 0, function(x) 0, x_start = 0, x_end = length, step = step, fn = fn);
            translate([-3.9, 0, 0]) halftubetube_end(fn = 20);
            translate([length + 3.9, 0, 0]) rotate([0, 0, 180]) halftubetube_end(fn = 20);
        }
    } else if (angle == 90 || angle == 180) {
        radius = angle == 90 ? length: length / 2;
        union() {
            tilted_ramp(function(x) 0, function(x) 0, function(x) radius * spinn(x/radius - 1), function(x) spinnslope(x/radius - 1), x_start = 0, x_end = length, step = step, fn = fn);
            translate([0, -3.9, 0]) rotate([0, 0, 90]) halftubetube_end(fn = 20);
            rotate([0, 0, 90]) halftube(radius = 11, wall = 5, length = 1.6, fn = 20);
            translate([angle == 90 ? length + 3.9 : length, angle == 90 ? length : -3.9, 0]) rotate([0, 0, angle == 90 ? 180 : 90]) halftubetube_end(fn = 20);
            translate([length, angle == 90 ? length : 0, 0]) rotate([0, 0, angle == 90 ? 180 : 90]) halftube(radius = 11, wall = 5, length = 1.6, fn = 20);
        }
    }
    echo("Rail created with units: ", units, " angle: ", angle);
}
