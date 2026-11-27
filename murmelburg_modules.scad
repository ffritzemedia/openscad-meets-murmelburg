// LibFile: murmelburg_modules.scad
//   Modulebibliothek fuer die Murmelburg (Cults3D).
//   Enthält Rampen- und Verbindungsprofile fuer die Murmelbahn.

// Function: polynomial()
// Synopsis: Normalisierte Rampen-Profilfunktion (Smoothstep, Polynom 5. Grades).
// Arguments:
//   x = Position auf der Rampe, normiert auf [0, 1]
// Returns:
//   Hoehenanteil der Rampe im Bereich [0, 1].
// Description:
//   p(0)=p'(0)=p''(0)=0 und p(1)=p'(1)=p''(1)=0: Der Anstieg startet und
//   endet horizontal und ohne Knick (krümmungsfreier Übergang).
// Example:
//   z = 50 * polynomial(x / 50);
function polynomial(x) = assert(x >= 0 && x <= 1, "x muss im Bereich [0, 1] liegen") x^3 * (10 + x * (-15 + 6 * x));

// Function: slope()
// Synopsis: Steigung dz/dx der Rampe zu einem gegebenen x.
// Arguments:
//   x = Position entlang der Rampe in mm (0 .. 50)
// Returns:
//   Anstieg dh/dx (dimensionslos, = tan des Steigungswinkels).
// Description:
//   Ableitung von z = 50 * polynomial(x/50). Maximum 1.875 bei x = 25
//   (ca. 62°), null an beiden Enden.
// Example:
//   angle = atan(slope(25));
function slope(x) = assert(x >= 0 && x <= 1, "x muss im Bereich [0, 1] liegen") let(t = x ) 30 * t * t * (1 - t) * (1 - t);

// Function: spinn()
// Synopsis: Spinn-Profilefunktion (Halbkreis).
// Arguments:
//   x = Position auf der Spinn, normiert auf [-1, 1]
// Returns:
//   Hoehenanteil der Spinn im Bereich [0, 1].
// Description:
//   Spinn-Profilefunktion (Halbkreis).
// Example:
//   y = 50 * spinn(x / 50);
function spinn(x) = assert(abs(x) <= 1, "x muss im Bereich [-1, 1] liegen") sqrt(1-x*x);

// Function: spinnslope()
// Synopsis: Steigung dy/dx der Spinn zu einem gegebenen x.
// Arguments:
//   x = Position auf der Spinn, normiert auf [-1, 1]
// Returns:
//   Anstieg dy/dx (dimensionslos, = tan des Steigungswinkels).
// Description:
//   Ableitung von y = 50 * spinn(x/50).
// Example:
//   angle = atan(spinnslope(0));
function spinnslope(x) = assert(abs(x) <= 1, "x muss im Bereich [-1, 1] liegen") -x/sqrt(1-x*x);

// Module: halftube()
// Synopsis: Halbe Röhre als Rinne, Achse entlang +X.
// Arguments:
//   radius = Aussendurchmesser [mm], Default: 10
//   wall = Wandstärke [mm], Default: 1.8
//   length = Länge entlang X [mm], Default: 50
//   fn = Facettenzahl fuer die Zylinder, Default: 20
// Description:
//   Erzeugt eine halbzylindrische Rinne (aussen Zylinder, innen
//   Ausschneidung, eine Seite offen).
// Example:
//   halftube(10, 1.8, 20);
module halftube(radius = 10, wall = 1.8, length = 50, fn = 20) {
    assert(radius > 0, "radius muss positiv sein");
    assert(wall > 0, "wall muss positiv sein");
    assert(length > 0, "length muss positiv sein");
    assert(fn > 0, "fn muss positiv sein");
    rotate([0, 90, 0]) {
        difference() {
            cylinder(r = radius + wall, h = length, $fn = fn);
            translate([0, 0, -2]) cylinder(r = radius, h = length + 4, $fn = fn);
            translate([(radius + wall)/2, 0, length/2 + 2]) cube([(radius + wall) +1, (radius + wall) * 2 + 4 , length + 4], center = true);
        }
    }
}

// Module: halftubetube_end()
// Synopsis: Verbindungsstück am Ende der Rampe (Übergang Rinne -> Endstück).
// Arguments:
//   r = Radius des Hauptteils [mm], Default: 10
//   w_1 = Wandstärke vorderes Teil [mm], Default: 2.8
//   w_2 = Wandstärke hinteres Teil [mm], Default: 1.8
//   l_1 = Länge des vorderen Teils [mm], Default: 1.5
//   l2 = Länge des hinteren Teils [mm], Default: 2.4
//   fn = Facettenzahl, Default: 20
// Description:
//   Union aus zwei halben Röhren mit unterschiedlichem Radius und
//   Wandstärke, die stumpf aneinanderstoßen (entlang +X).
// Example:
//   translate([-3.9, 0, 0]) halftubetube_end();
module halftubetube_end(r= 10, w_1 = 2.8, w_2= 1.8, l_1 = 1.5, l2 = 2.4  ,fn = 20) {
    assert(r > 0, "r muss positiv sein");
    assert(w_1 > 0, "w_1 muss positiv sein");
    assert(w_2 > 0, "w_2 muss positiv sein");
    assert(l_1 > 0, "l_1 muss positiv sein");
    assert(l2 > 0, "l2 muss positiv sein");
    assert(fn > 0, "fn muss positiv sein");
    union(){
        halftube(r, w_1, l_1, fn);
        translate([l_1, 0, 0]) halftube(r, w_2, l2, fn);
    }
}

// Module: on_slope()
// Synopsis: Setzt Kinder auf einen Bahnpunkt, gekippt um den Steigungswinkel.
// Arguments:
//   x = Position entlang X [mm]
//   z = Höhe der Bahn an dieser Stelle [mm]
//   m = Steigung dz/dx an dieser Stelle (dimensionslos)
//   y = Position entlang Y [mm], Default: 0
//   d = Steigung dy/dx an dieser Stelle (dimensionslos), Default: 0
//   bank = Bankwinkel um die Bahnachse in Grad, Default: 0
// Description:
//   Verschiebt die Kinder nach [x, y, z] und richtet die lokale X-Achse an
//   der Tangente (1, d, m) aus. Ein positiver bank-Wert hebt die +Y-Seite
//   der Bahn an (Neigung in die Kurve).
// Example:
//   on_slope(25, 50 * polynomial(0.5), slope(25)) halftube_slice();
module on_slope(x, z, m, y = 0, d=0, bank = 0) {
    pitch = atan(m / sqrt(1 + d*d));
    translate([x, y, z]) rotate([bank, -pitch, atan(d)]) children();
}

// Module: halftube_slice()
// Synopsis: Hauchdünne Scheibe mit dem Außenprofil von halftube().
// Arguments:
//   radius = Aussenradius [mm], Default: 10
//   fn = Facettenzahl, Default: 20
// Description:
//   Zylinderscheibe (Dicke eps = 0.05, zentriert auf x = 0) oberhalb von
//   z = 0.5, wie der Schnitt in halftube(). Dient als Querschnitt fuer
//   hull() in tilted_halftube_segment().
// Example:
//   hull() { halftube_slice(); translate([5, 0, 0]) halftube_slice(); }
module halftube_slice(radius = 10, wall = 1.8, fn = 20) {
    assert(radius > 0, "radius muss positiv sein");
    assert(wall > 0, "wall muss positiv sein");
    assert(fn > 0, "fn muss positiv sein");
    eps = 0.05;
    intersection() {
        rotate([0, 90, 0]) cylinder(r = radius + wall, h = eps, center = true, $fn = fn);
        translate([-eps, -(radius + wall) - 1, 0.5]) cube([2 * eps, 2 * (radius + wall) + 2, radius + wall + 1]);
    }
}

// Module: halftube_core_slice()
// Synopsis: Dünne volle Kreisscheibe mit dem Innenradius von halftube().
// Arguments:
//   radius = Aussenradius [mm], Default: 10
//   wall = Wandstärke [mm], Default: 1.8
//   fn = Facettenzahl, Default: 20
// Description:
//   Scheibe mit Radius radius - wall (Dicke 3 * eps = 0.15, zentriert auf
//   x = 0). Sie ist dicker als halftube_slice(), damit der Innenraum beim
//   difference() sauber über die Segmentenden hinaus schneidet und keine
//   hauchdünnen Häute stehen bleiben.
// Example:
//   hull() { halftube_core_slice(); translate([5, 0, 0]) halftube_core_slice(); }
module halftube_core_slice(radius = 10, fn = 20) {
    assert(radius > 0, "radius muss positiv sein");
    assert(fn > 0, "fn muss positiv sein");
    eps = 0.05;
    rotate([0, 90, 0]) cylinder(r = radius, h = 3 * eps, center = true, $fn = fn);
}

// Module: tilted_halftube_segment()
// Synopsis: Rinnensegment zwischen zwei Bahnpunkten, Enden senkrecht zur Bahn.
// Arguments:
//   x0 = Startposition entlang X [mm]
//   z0 = Höhe am Start [mm]
//   m0 = Steigung am Start (dimensionslos)
//   x1 = Endposition entlang X [mm]
//   z1 = Höhe am Ende [mm]
//   m1 = Steigung am Ende (dimensionslos)
//   radius = Aussenradius [mm], Default: 10
//   wall = Wandstärke [mm], Default: 1.8
//   fn = Facettenzahl, Default: 20
//   y0 = Position entlang Y am Start [mm], Default: 0
//   y1 = Position entlang Y am Ende [mm], Default: 0
//   bank0 = Bankwinkel am Start in Grad, Default: 0
//   bank1 = Bankwinkel am Ende in Grad, Default: 0
// Description:
//   hull() der beiden Aussenquerschnitte minus hull() der beiden
//   Innenquerschnitte. Aufeinanderfolgende Segmente teilen sich denselben
//   Querschnitt und schliessen daher ohne Lücken oder Ringe aneinander an.
// Example:
//   tilted_halftube_segment(0, 0, 0, 10, 5, 1);
module tilted_halftube_segment(x0, y0, z0, m0, d0, x1, y1, z1, m1, d1, radius = 10, wall = 1.8, fn = 20, bank0 = 0, bank1 = 0) {
    assert(radius > 0, "radius muss positiv sein");
    assert(wall > 0, "wall muss positiv sein");
    assert(fn > 0, "fn muss positiv sein");
    difference() {
        hull() {
            on_slope(x0, z0, m0, y0, d0, bank0) halftube_slice(radius, wall, fn);
            on_slope(x1, z1, m1, y1, d1, bank1) halftube_slice(radius, wall, fn);
        }
        hull() {
            on_slope(x0, z0, m0, y0, d0, bank0) halftube_core_slice(radius, fn);
            on_slope(x1, z1, m1, y1, d1, bank1) halftube_core_slice(radius, fn);
        }
    }
}

// Module: tilted_ramp()
// Synopsis: Rinne entlang einer beliebigen Funktion z = f(x), Segmente gekippt.
// Arguments:
//   f = Höhenfunktion als Funktionsliteral, z = f(x) [mm]
//   df = Ableitung von f als Funktionsliteral (Steigung dz/dx)
//   x_start = Beginn der Rampe entlang X [mm], Default: 0
//   x_end = Ende der Rampe entlang X [mm], Default: 50
//   step = Segmentlänge entlang X [mm], Default: 0.1
//   radius = Aussenradius [mm], Default: 10
//   wall = Wandstärke [mm], Default: 1.8
//   fn = Facettenzahl, Default: 20
//   fy = Y-Verlauf als Funktionsliteral, y = fy(x) [mm], Default: y = 0
//   fb = Bankverlauf als Funktionsliteral, bank = fb(x) [Grad], Default: 0
// Description:
//   Reiht tilted_halftube_segment() von x_start bis x_end aneinander.
//   Kleineres step ergibt eine glattere Rinne, aber längere Renderzeit.
//   Endstücke sind nicht enthalten. Benötigt OpenSCAD 2021.01 oder neuer
//   (Funktionsliterale).
// Example:
//   tilted_ramp(function(x) 50 * polynomial(x / 50), function(x) slope(x));
module tilted_ramp(f1, df1, f2, df2, x_start = 0, x_end = 50, step = 0.1, radius = 10, wall = 1.8, fn = 20, fy = function(x) 0, fb = function(x) 0) {
    assert(is_function(f1), "f1 muss eine Funktion sein");
    assert(is_function(df1), "df1 muss eine Funktion sein");
    assert(is_function(f2), "f2 muss eine Funktion sein");
    assert(is_function(df2), "df2 muss eine Funktion sein");
    assert(is_function(fy), "fy muss eine Funktion sein");
    assert(is_function(fb), "fb muss eine Funktion sein");
    assert(x_start < x_end, "x_start muss kleiner x_end sein");
    assert(step > 0, "step muss positiv sein");
    assert(radius > 0, "radius muss positiv sein");
    assert(wall > 0, "wall muss positiv sein");
    assert(fn > 0, "fn muss positiv sein");
    n = round((x_end - x_start) / step);
    for (k = [0:n - 1]) {
        x0 = x_start + k * step;
        x1 = x_start + (k + 1) * step;
        tilted_halftube_segment(x0, f2(x0), f1(x0), df1(x0), df2(x0), x1, f2(x1), f1(x1), df1(x1), df2(x1), radius, wall, fn, fb(x0), fb(x1));
    }
}
