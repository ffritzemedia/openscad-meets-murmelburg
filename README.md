# OpenSCAD meets Murmelburg

Parametrische, 3D-druckbare Murmelbahnelemente für [OpenSCAD](https://openscad.org) — auf einem 50-mm-Raster mit standardisierten Anschlussstücken, damit alle Teile untereinander kompatibel bleiben.

## Dateien

| Datei | Inhalt |
|---|---|
| `murmelburg_modules.scad` | Grundbibliothek: Halbrohr-Profile, Querschnitts-Scheiben, `tilted_ramp()` mit Höhen-/Seitenkurven und Banking |
| `ramps.scad` | Rampen-Module: `ramp()` (gerade), `ramp90()` (Viertelbogen), `ramp180()` (Halbdrehung) |
| `rails.scad` | Schienen-Module: `rail()` — gerade und gebogene Bahnen **ohne** Höhenunterschied |

## Voraussetzungen

- OpenSCAD ≥ 2021.01 (für `assert()`-Validierungen in den Bibliotheken)
- Die drei Dateien in **dasselbe Verzeichnis** legen

## Verwendung

```scad
use <murmelburg_modules.scad>;
use <rails.scad>;

// Schiene mit 90°-Bogen, 2 Einheiten (je 50 mm)
rail(units = 2, angle = 90);

// Rampe mit 180°-Wende und Banking
// use <ramps.scad>;
// ramp180(units = 2, drop = 1, bank = 15);
```

### Parameter (Auswahl)

- `units` — Anzahl der 50-mm-Segmente
- `drop` — Anzahl der 50-mm-Höhenstufen (nur Rampen)
- `bank` — maximaler Banking-Winkel in Grad, neigt die Rinne in die Kurve (0 = aus)
- `angle` — nur bei `rail()`: `0` gerade, `90` Viertelbogen, `180` Halbdrehung
- `reverse` — spiegelt Kurven nach rechts (Rampen)
- `step` — Segmentdichte; kleiner = glatter, aber langsamere Render
- `fn` — Facettenzahl für Zylinder

## Hinweise

- Bei hohen `bank`-Werten kann der [Formware STL Repair](https://www.formware.co/onlinestlrepair) vor dem Druck nicht-mannigfaltige Kanten korrigieren.
- Die Teile sind für den Druck **auf dem Kopf** konstruiert (Öffnung der Rinne nach unten im Buildvolumen).
