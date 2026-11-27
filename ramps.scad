use <murmelburg_modules.scad>;
/* 
File: ramps.scad
Description: Creates ramps for the Murmelbahn project Murmelburg on cults3d.com
For greater values of bank you might need to use https://www.formware.co/onlinestlrepair after rendering the stl-files to fix any non-manifold edges.
*/

// Straight ramp module
// units: number of 50mm segments
// drop: number of 50mm drops
// step: step size for the ramp
// fn: facet count for the ramp
module ramp(units = 1, drop = 1, step = 1, fn=20) {
    assert (units > 0, "units must be greater than 0");
    assert (floor(units) == units, "units must be an integer");
    assert (drop > 0, "drop must be greater than 0");
    assert (floor(drop) == drop, "drop must be an integer");
    union(){
        length = units * 50;
        height = drop * 50;
        tilted_ramp(function(x) height * polynomial(x / length), function(x) slope(x/length), function(x) 0, function(x) 0, x_start = 0, x_end = length, step = step, fn = fn);
        translate([-3.9, 0, 0]) halftubetube_end(fn = 20);
        translate([length + 3.9, 0, height]) rotate([0, 0, 180]) halftubetube_end(fn = 20);
    }
}

// 90 degree bend ramp module
// units: number of 50mm segments ()
// drop: number of 50mm drops
// step: step size for the ramp
// reverse: if true, the ramp turns to the right, otherwise to the left
// fn: facet count for the ramp
// bank: max angle of banking in degrees (0 = no banking)
module ramp90(units = 1, drop = 1, step = 1, reverse = false, fn = 20, bank = 0) {
    // bank: maximaler Bankwinkel in Grad (0 = keine Querneigung)
    // Positives bank neigt nach aussen (Bande auf der Aussenseite erhoeht).
    // Die Bahn ist ein Viertelkreis (Radius length), also ist die noetige
    // Querneigung konstant. Sie blendet an beiden Enden auf 0 aus und
    // zusaetzlich erst ein, wenn unter der Lippe genug Bauhoehe ist
    // (z > ~8mm), damit die gekippte Lippe nicht unter z = 0 sticht.
    assert (units > 0, "units must be greater than 0");
    assert (floor(units) == units, "units must be an integer");
    assert (drop > 0, "drop must be greater than 0");
    assert (floor(drop) == drop, "drop must be an integer");
    assert (reverse == true || reverse == false, "reverse must be true or false");
    length = 25 + (units - 1) * 50;
    height = drop * 50;
    tl = 0.1 * length;
    fb = function(x) let(
        z = height * polynomial(x / length),
        zh = min(1, max(0, z / 8)),
        zs = zh * zh * (3 - 2 * zh),
        u = min(min(1, max(0, (x - step) / tl)), min(1, max(0, (length - step - x) / tl))),
        s = u * u * (3 - 2 * u)
    ) -bank * s * zs;

    module build(){
        union(){
            tilted_ramp(function(x) height * polynomial(x / length), function(x) slope(x/length), function(x) length*spinn(x / length-1), function(x) spinnslope(x / length-1), x_start = 0, x_end = length, step = step, fn = fn, fb = fb);
            rotate([0, 0, 90]) translate([-3.9, 0, 0]) halftubetube_end(fn = 20);
            translate([length + 3.9, length , height]) rotate([0, 0, 180]) halftubetube_end(fn = 20);
        }
    }
    if (reverse) {
        mirror([0, 1, 0]) build();
    } else {
        build();
    }
}

// 180 degree bend ramp module
// units: number of 50mm segments
// drop: number of 50mm drops
// step: step size for the ramp
// reverse: if true, the ramp turns to the right, otherwise to the left
// fn: facet count for the ramp
// bank: max angle of banking in degrees (0 = no banking)
module ramp180(units = 1, drop = 1, step = 1, reverse = false, fn=20, bank = 0) {
    // bank: maximaler Bankwinkel in Grad (0 = keine Querneigung)   
    // Positives bank neigt nach aussen (Bande auf der Aussenseite erhoeht).
    // Das Banking folgt der Plan-Gedaechtnis des Bogens (Krummung ~ 1/sqrt(1-t^2))
    // und blendet an beiden Enden auf 0 aus, damit die Anschlussstuecke passen.
    assert (units > 0, "units must be greater than 0");
    assert (floor(units) == units, "units must be an integer");
    assert (drop > 0, "drop must be greater than 0");
    assert (floor(drop) == drop, "drop must be an integer");
    assert (reverse == true || reverse == false, "reverse must be true or false");
    R = max(25, (units * 50) / 2);
    L = units * 50;
    tl = 0.1 * L;
    fb = function(x) let(
        t = x / R - 1,
        curv = min(1 / sqrt(max(0.02, 1 - t * t)), 3) / 3,
        z = (drop * 50) * polynomial(x / (units * 50)),
        zh = min(1, max(0, z / 8)),
        zs = zh * zh * (3 - 2 * zh),
        u = min(min(1, max(0, (x - step) / tl)), min(1, max(0, (L - step - x) / tl))),
        s = u * u * (3 - 2 * u)
    ) -bank * curv * s * zs;
    module build(){
        union(){
            length = units * 50;
            height = drop * 50;
            tilted_ramp(function(x) height * polynomial(x / length), function(x) slope(x/length), function(x) (height/2) * spinn((x / (max(25,length/2))-1)), function(x) spinnslope((x / (length/2))-1), x_start = 0, x_end = length, step = step, fn = fn, fb = fb);
            rotate([0, 0, 90]) translate([-3.9, 0, 0]) halftubetube_end(fn = 20);
            translate([length, -3.9, height]) rotate([0, 0, 90]) halftubetube_end(fn = 20);
        }
    }
    if (reverse){
        mirror([0, 1, 0]) build();
    } else {
        build();   
    }
}

module ramp360(units = 1, drop = 1, step = 1, reverse = false, fn=20) {
    // bank: maximaler Bankwinkel in Grad (0 = keine Querneigung)   
    // Positives bank neigt nach aussen (Bande auf der Aussenseite erhoeht).
    // Das Banking folgt der Plan-Gedaechtnis des Bogens (Krummung ~ 1/sqrt(1-t^2))
    // und blendet an beiden Enden auf 0 aus, damit die Anschlussstuecke passen.
    assert (units > 0, "units must be greater than 0");
    assert (floor(units) == units, "units must be an integer");
    assert (drop > 0, "drop must be greater than 0");
    assert (floor(drop) == drop, "drop must be an integer");
    assert (reverse == true || reverse == false, "reverse must be true or false");
    length = units * 50;
    height = drop * 50;
    module tuberail(){
        translate([0, -50, 0]) union(){
            rotate([0, 0, 90]) halftube(length = 50);
            translate([0, -3.9, 0]) rotate([0, 0, 90]) halftubetube_end(fn = 20);
            rotate([0, 0, 90]) halftube(radius = 11, wall = 5, length = 1.6, fn = 20);
        }
    }
    module first_half(){
        union(){
            tilted_ramp(function(x) height * polynomial(x / (2*length)), function(x) slope(x / (2*length)), function(x) length / 2 * spinn((x / (length /2))-1), function(x) spinnslope((x / (length/2))-1), x_start = 0, x_end = length, step = step, fn = fn, fb = function(x) 0);
            tuberail();
        }
    }
    module second_half(){
        union(){
            tilted_ramp(function(x) height * polynomial(x / (2*length)), function(x) slope(x / (2*length)), function(x) length / 2 * spinn(((x - length) / (length /2))-1), function(x) spinnslope(((x-length) / (length/2))-1), x_start = length, x_end = 2*length, step = step, fn = fn, fb = function(x) 0);
            translate([2*length, 0, height]) tuberail();
        }
    }
    module build(){
        union(){
            first_half();
            translate([2*length, 0, 0]) rotate([0, 0, 180]) second_half();
        }
    }
    build();
}

