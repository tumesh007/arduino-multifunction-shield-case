# CODEX MASTER PROMPT — REV 5

## Arduino Multifunction Shield Enclosure — Engineering + FreeCAD Agentic Workflow

You are not acting as a simple code generator.

You are an **agentic mechanical-design engineer** responsible for designing, validating, correcting, and delivering a production-quality FDM-printable Arduino electronics enclosure.

Your job is NOT complete when the OpenSCAD code compiles.

Your job is complete only when:

1. The geometry is mechanically coherent.
2. All physical components fit.
3. No component is floating, misplaced, or intersecting incorrectly.
4. The enclosure can actually be printed as separate physical parts.
5. The base and top plate are independently printable.
6. The complete assembly renders correctly.
7. The geometry has been checked visually and dimensionally.
8. FreeCAD has been used where appropriate for engineering inspection.
9. All important dimensions trace back to the defined configuration.
10. You have performed an independent final audit before declaring the project complete.

Do NOT blindly trust your own generated geometry.

If an audit finds a problem, modify the design and repeat the audit.

---

# 1. PRIMARY OBJECTIVE

Design a professional two-piece Arduino electronics enclosure suitable for:

* Bambu Lab A1 Mini
* 180 × 180 × 180 mm build volume
* 0.4 mm nozzle
* PLA
* PETG
* FDM printing

The enclosure should have the appearance and engineering logic of a commercial electronics enclosure similar in design philosophy to Hammond, Takachi, or Bud Industries.

The enclosure consists of:

### PRINT PART 1

`base.scad`

The complete lower enclosure/base, including:

* bottom
* side walls
* Arduino locating features
* battery compartment
* internal divider
* screw bosses
* cable routing
* switch opening
* DC connector opening
* ventilation where appropriate
* rubber-foot recesses
* all structural features belonging to the lower half

### PRINT PART 2

`top_plate.scad`

The complete removable upper/front plate/lid, including:

* display opening
* display bezel
* three button openings
* integrated button-plunger interfaces
* buzzer acoustic grille
* screw holes
* locating/overlap features
* all features required for the user interface

### PREVIEW / MASTER

`main.scad`

This is ONLY the complete assembly/preview file.

It must visually assemble:

* base
* top plate
* Arduino mockup
* multifunction shield mockup
* battery mockup
* SPST switch mockup
* DC connector mockup
* buttons/plungers
* display
* buzzer

`main.scad` must NOT create an additional printable part.

---

# 2. STRICT OUTPUT DIRECTORY

The final project directory must contain ONLY:

```text
Arduino_Multifunction_Shield_Case/
│
├── config.scad
├── base.scad
├── top_plate.scad
└── main.scad
```

No additional `.scad` files.

No temporary files.

No duplicate modules.

No generated garbage.

No STL files.

No DXF files.

No ZIP files unless explicitly requested.

No obsolete versions.

No experimental files.

No backup files.

No unused modules.

The four files above must work together directly.

---

# 3. CONFIGURATION ARCHITECTURE

`config.scad` is the SINGLE SOURCE OF TRUTH.

Every important mechanical dimension must originate there.

Do not silently invent important dimensions inside other files.

Centralize:

* wall thickness
* bottom thickness
* top plate thickness
* corner radius
* general clearances
* sliding clearances
* press-fit clearances
* Arduino dimensions
* Arduino position
* shield height
* battery dimensions
* battery position
* SPST dimensions
* SPST body clearance
* SPST insertion depth
* DC connector dimensions
* button positions
* button diameter
* button travel
* display dimensions
* display position
* buzzer diameter
* buzzer position
* screw dimensions
* screw boss dimensions
* rubber-foot dimensions
* cable clearance
* wire routing clearance
* vent parameters
* build-volume limits

Local mathematical relationships may remain inside a module when they are derived directly from configuration values.

Do NOT create hundreds of meaningless configuration parameters.

Use engineering judgement.

---

# 4. CRITICAL RULE — NEVER INVENT HARDWARE LOCATIONS

This is one of the most important requirements.

DO NOT invent coordinates for components that have not been supplied.

DO NOT automatically reposition:

* buttons
* display
* buzzer
* Arduino
* battery
* SPST
* DC connector

to make the model "look good".

Every component position must be based on the dimensions and coordinates explicitly supplied below.

If a required dimension is genuinely missing and cannot safely be inferred, STOP and ask the user.

Do not guess.

---

# 5. ARDUINO

Arduino dimensions:

```text
83.4 × 62.0 × 19.4 mm
```

The Arduino is NOT to be screw-mounted.

Provide locating rails/stops only.

Target clearance:

```text
approximately 1.0 mm
```

The Arduino must be restrained against:

* lateral movement
* longitudinal movement
* accidental lifting where practical

Do not modify the Arduino geometry.

Do not create arbitrary mounting holes.

---

# 6. MULTIFUNCTION SHIELD

Shield is mounted above the Arduino.

Additional shield height:

```text
12.2 mm
```

The internal enclosure height must provide adequate clearance for the complete stack.

Do not blindly use a fixed enclosure height if the resulting stack does not fit.

Calculate:

```text
bottom thickness
+
Arduino height
+
shield height
+
required clearance
+
top plate thickness
```

and verify the result.

The top plate must not collide with the shield.

---

# 7. BATTERY

Battery dimensions:

```text
58.6 × 43.6 × 29.9 mm
```

Battery sits beside the Arduino.

Provide:

* retaining walls
* divider
* cable pass-through
* finger/service access
* controlled clearance
* positive retention

The battery must not float.

The battery mockup in `main.scad` must occupy exactly the same coordinate system as the physical retaining structure.

Do not create a battery holder at one location and a battery mockup at another.

They MUST share the same datum.

---

# 8. SPST ROCKER SWITCH — CRITICAL

SPST switch cutout:

```text
19.9 × 12.0 mm
```

The switch requires substantial physical depth behind the panel.

Reserve:

```text
MINIMUM 20 mm internal depth
```

behind the SPST mounting opening.

This is NOT optional.

The switch has:

* front body
* rear body
* terminals/pins
* wiring space

The design must account for the actual rear intrusion.

Do NOT treat the 19.9 × 12 mm cutout as the entire switch volume.

Create a realistic SPST mockup in `main.scad`.

The mockup must extend at least 20 mm behind the panel.

The surrounding enclosure geometry must be checked against:

* battery
* divider
* wall
* wiring clearance
* screw bosses

If the switch conflicts with another component, reposition the enclosure architecture rather than simply hiding the collision.

---

# 9. DC POWER CONNECTOR — CRITICAL

Use the specified panel-mounted DC connector concept.

The user clarification is:

```text
approximately 33 mm body length
standard approximately 5 mm diameter connector
```

IMPORTANT:

Do NOT reinterpret this as a 33 mm mounting-hole diameter.

Do NOT create a 33 mm diameter hole.

The connector is a small standard barrel-style DC connector with approximately:

```text
5 mm diameter
33 mm overall/body length
```

If an exact manufacturer's drawing is unavailable, treat the values above as the design envelope and clearly expose the connector clearance in `config.scad`.

The connector must be physically represented in `main.scad`.

Its rear body and cable exit must fit inside the enclosure.

Provide a realistic cable-routing path toward the Arduino DC input.

Do not allow the connector body to float independently from the panel.

---

# 10. BUTTONS

There are exactly THREE buttons.

Coordinates are relative to the TOP-LEFT datum of the Arduino/interface coordinate system:

### BUTTON 1

```text
X = 14.7 mm
Y = 14.0 mm
```

### BUTTON 2

```text
X = 24.1 mm
Y = 14.0 mm
```

### BUTTON 3

```text
X = 33.4 mm
Y = 14.1 mm
```

Do NOT change these coordinates.

Do NOT invent alternative button coordinates.

Do NOT mirror them.

Do NOT rotate them into another coordinate system without explicitly accounting for the transformation.

---

# 11. BUTTON PLUNGERS

Button plungers:

```text
Diameter = 5.0 mm
Height = 4.8 mm
Travel = 1.0 mm
Clearance = 0.3 mm
```

Provide:

* rounded contact tip
* guided movement
* controlled travel
* anti-rotation where practical
* commercial reset-button style geometry

The plunger must be physically aligned with its corresponding button.

The button location in the top plate and the button location in the internal mockup must be generated from the SAME coordinates.

No duplicated manually entered coordinates.

---

# 12. BUZZER

Buzzer centre:

```text
X = 23.8 mm
Y = 37.5 mm
```

Buzzer diameter:

```text
15.0 mm
```

This is a critical requirement.

Create a proper acoustic grille above the buzzer.

Use a radial pattern.

The grille must:

* be centred on the 15 mm buzzer
* have reasonable wall thickness
* not weaken the top plate excessively
* not accidentally cover the button/display
* remain printable
* not require unnecessary support

The buzzer mockup and grille MUST share the exact same centre coordinate.

---

# 13. DISPLAY

Visible display window:

```text
30.2 × 14.3 mm
```

Top-left coordinate:

```text
X = 18.3 mm
Y = 58.9 mm
```

Bottom-right:

```text
X = 48.5 mm
Y = 73.2 mm
```

Do not independently calculate a different display position.

These dimensions define the display datum.

Provide:

```text
0.5 mm clearance
```

around the actual display interface where appropriate.

Provide a recessed bezel.

The display mockup and display cutout MUST use the same coordinate system.

---

# 14. ENCLOSURE

Two-piece enclosure.

Base:

```text
3 mm wall
3 mm bottom
```

Top plate:

```text
3 mm
```

Corner radius:

```text
5 mm
```

Use:

* internal reinforcing ribs
* sensible fillets
* chamfers where useful
* printable overhangs
* clean FDM geometry

Avoid unnecessary supports.

Avoid decorative geometry that compromises manufacturing.

---

# 15. SCREWS

Four M3 screws.

Provide:

* screw bosses
* 3.3 mm clearance holes
* counterbores
* reinforcing geometry
* sufficient boss wall thickness

Keep screw positions symmetric and mechanically sensible.

Do not place screw bosses through:

* battery
* Arduino
* display
* buttons
* buzzer
* switch
* connector

Check the actual geometry.

---

# 16. BOTTOM

Base must include:

* flat stable bottom
* rubber-foot recesses
* underside chamfer
* reinforced screw locations
* no unnecessary floating geometry

The base must print flat on the Bambu A1 Mini.

---

# 17. VENTILATION

Provide sensible side ventilation.

Do not weaken structural walls.

Do not place vents where they interfere with:

* battery
* Arduino
* switch
* connector
* screw bosses

Vent geometry must remain printable.

---

# 18. CABLE MANAGEMENT

Provide practical:

* cable channels
* rounded wire exits
* tie slots where useful
* clearance around connector terminals
* routing from DC connector to Arduino
* battery cable routing

Cable channels must not intersect structural walls.

---

# 19. FLOATING-GEOMETRY RULE

This is a HARD FAILURE CONDITION.

No component may float unless it is deliberately shown as a removable/exploded component.

In assembled preview:

* Arduino must sit on rails.
* Battery must sit on its compartment floor.
* Buzzer must be located against the intended top interface.
* Buttons must align with their holes.
* Display must align with its window.
* SPST must physically occupy its cutout.
* DC connector must physically occupy its opening.
* Top plate must sit on the base.
* Screw axes must align.

If a component appears visually detached, investigate it.

Do not dismiss it as "only a mockup".

---

# 20. COORDINATE SYSTEM RULE

Establish ONE master coordinate system.

Prefer:

```text
X = enclosure width
Y = enclosure depth
Z = vertical
```

All hardware datums must derive from this system.

Create explicit datum relationships.

Do not repeatedly add arbitrary offsets in different files.

For example:

```text
Arduino origin
    ↓
button coordinates
display coordinates
buzzer coordinates
battery relationship
```

must remain mathematically traceable.

---

# 21. NO RANDOM FLOATING-POINT PARAMETERS

Avoid meaningless values such as:

```text
17.384927
42.76381
6.218473
```

unless they are the mathematical result of a defined relationship.

Prefer:

```openscad
battery_x = arduino_x + arduino_width + service_gap;
```

rather than manually invented coordinates.

Derived values are acceptable.

Arbitrary values are not.

Round displayed engineering dimensions sensibly.

Do not accumulate floating-point errors through repeated transformations.

---

# 22. ASSERTIONS

Use OpenSCAD assertions aggressively.

Examples:

```text
assert enclosure fits A1 Mini
assert wall thickness is printable
assert battery fits compartment
assert SPST has >=20 mm rear clearance
assert display fits
assert buttons remain inside top plate
assert buzzer fits
assert screw bosses remain inside enclosure
assert no component exceeds enclosure boundaries
```

Assertions should stop invalid designs.

Do NOT create assertions that merely hide a design problem.

---

# 23. AGENTIC DEVELOPMENT PROCESS

Work as a mechanical engineering team.

Internally follow this process:

### PHASE 1 — REQUIREMENTS AUDIT

Before coding, extract every known requirement.

Create an internal checklist.

Identify:

* known dimensions
* known coordinates
* required clearances
* missing information
* potential conflicts

If a missing dimension materially affects physical fit, ask the user before proceeding.

Do not guess.

---

### PHASE 2 — ARCHITECTURE

Establish:

* master coordinate system
* enclosure dimensions
* Arduino datum
* battery datum
* UI datum
* switch datum
* connector datum
* screw datum

Ensure every component is physically reachable and manufacturable.

---

### PHASE 3 — PARAMETRIC MODEL

Generate the four required files:

```text
config.scad
base.scad
top_plate.scad
main.scad
```

Do not create extra files.

---

### PHASE 4 — OPENSCAD VALIDATION

Run OpenSCAD validation.

At minimum:

1. compile `base.scad`
2. compile `top_plate.scad`
3. render `main.scad`
4. inspect for warnings
5. inspect for non-manifold/self-intersecting geometry
6. verify build volume
7. verify component placement

F6 rendering must succeed.

---

# 24. FREECAD VALIDATION

Use FreeCAD as an independent engineering audit tool.

Do NOT use FreeCAD merely to generate a pretty drawing.

Import/inspect the actual OpenSCAD-generated geometry.

Use FreeCAD to verify:

* overall width
* overall depth
* overall height
* wall thickness
* component clearance
* screw locations
* button locations
* display location
* buzzer location
* SPST rear clearance
* connector body clearance
* battery clearance
* Arduino clearance
* top/base mating geometry

Where practical, generate:

* top view
* front view
* side view
* section view

The section view is especially important for:

* Arduino stack
* battery
* SPST
* DC connector
* top plate
* screw bosses

---

# 25. CRITICAL SECTION CHECK

Perform a virtual section through the enclosure.

Inspect the physical stack.

Verify:

```text
Base
↓
Arduino
↓
Multifunction shield
↓
clearance
↓
top plate
```

Also inspect:

```text
SPST front
↓
SPST body
↓
SPST terminals
↓
20 mm minimum rear space
```

Also inspect:

```text
DC connector
↓
33 mm body length
↓
cable exit
↓
Arduino connection
```

If any section reveals an impossible physical arrangement, redesign it.

---

# 26. VISUAL AUDIT

Render the complete `main.scad`.

Inspect the model from:

1. isometric view
2. top view
3. front view
4. rear view
5. left side
6. right side
7. transparent/cutaway view

Look specifically for:

* floating components
* inverted components
* incorrect button positions
* incorrect display position
* buzzer mismatch
* switch collision
* connector collision
* battery collision
* screw boss collision
* top plate interference
* missing openings
* inaccessible connectors
* accidental wall intersections

---

# 27. PHYSICAL ASSEMBLY AUDIT

Pretend you are physically assembling the product.

Ask:

### Arduino

Can I insert it?

Can I remove it?

Does it move excessively?

### Battery

Can I insert it?

Can I remove it?

Is it retained?

Can I route its cable?

### SPST

Can the actual switch body enter the opening?

Is there at least 20 mm rear space?

Are the terminals/wires accommodated?

### DC connector

Can the approximately 33 mm long body fit?

Is the connector actually mounted to the panel?

Can its cable reach the Arduino?

### Buttons

Do all three plungers line up exactly?

Can they move 1 mm?

Do they have 0.3 mm clearance?

### Display

Does the actual 30.2 × 14.3 mm window align?

### Buzzer

Does the 15 mm buzzer align with the 15 mm acoustic grille?

### Top plate

Can it physically close?

Does it collide with anything?

### Screws

Can all four screws be inserted?

---

# 28. FAILURE-RECOVERY LOOP

If ANY audit fails:

DO NOT simply report the problem.

Fix the geometry.

Then:

```text
modify
↓
compile
↓
render
↓
inspect
↓
FreeCAD check
↓
re-audit
```

Repeat until clean.

Do not stop after the first failed attempt.

---

# 29. USER CHECKPOINT

If the design reaches a point where the remaining uncertainty depends on a real-world hardware dimension that has not been provided, STOP.

Tell me exactly what physical measurement is required.

For example:

```text
I need the rear body length of your actual SPST switch.
```

Do not ask vague questions.

Do not ask about dimensions that can be safely derived from the information already supplied.

Once I provide the measurement, resume the engineering loop.

---

# 30. PRINTABILITY

The two physical files must independently render and be printable:

```text
base.scad
top_plate.scad
```

They must not depend on hidden geometry from `main.scad`.

`main.scad` is only the assembly preview.

The parts must be oriented sensibly for FDM.

Do not require supports unless absolutely unavoidable.

---

# 31. FINAL ACCEPTANCE TEST

Before declaring the project finished, verify ALL of the following:

### Files

* [ ] config.scad exists
* [ ] base.scad exists
* [ ] top_plate.scad exists
* [ ] main.scad exists
* [ ] no unnecessary files exist

### Geometry

* [ ] Base renders
* [ ] Top plate renders
* [ ] Main assembly renders
* [ ] No obvious floating geometry
* [ ] No obvious self-intersections
* [ ] No missing components
* [ ] No accidental duplicate components

### Arduino

* [ ] 83.4 × 62.0 × 19.4 mm
* [ ] approximately 1 mm clearance
* [ ] locating rails present
* [ ] no arbitrary PCB holes

### Shield

* [ ] 12.2 mm additional height
* [ ] top clearance verified

### Battery

* [ ] 58.6 × 43.6 × 29.9 mm
* [ ] retained
* [ ] cable path exists

### SPST

* [ ] 19.9 × 12.0 mm cutout
* [ ] actual switch body represented
* [ ] minimum 20 mm rear depth
* [ ] no battery/wall collision

### DC connector

* [ ] approximately 5 mm diameter
* [ ] approximately 33 mm body length
* [ ] NOT a 33 mm mounting hole
* [ ] rear clearance checked
* [ ] cable route checked

### Buttons

* [ ] 3 buttons
* [ ] exact supplied coordinates
* [ ] 5 mm diameter
* [ ] 4.8 mm height
* [ ] 1 mm travel
* [ ] 0.3 mm clearance

### Buzzer

* [ ] centre 23.8 × 37.5 mm
* [ ] 15 mm diameter
* [ ] radial acoustic grille
* [ ] grille centred correctly

### Display

* [ ] 30.2 × 14.3 mm
* [ ] supplied position
* [ ] 0.5 mm clearance
* [ ] recessed bezel

### Enclosure

* [ ] 3 mm walls
* [ ] 3 mm bottom
* [ ] 3 mm top plate
* [ ] 5 mm corner radius
* [ ] four M3 screw locations
* [ ] rubber-foot recesses
* [ ] cable management
* [ ] ventilation
* [ ] A1 Mini printable envelope

---

# 32. IMPORTANT ENGINEERING PRINCIPLE

Never optimize the code at the expense of physical correctness.

Never make geometry "look right" merely to make a render attractive.

Never assume a component fits because its mounting hole fits.

Always consider the COMPLETE physical component:

```text
body
pins
terminals
wires
connectors
clearance
insertion direction
removal direction
assembly access
```

This is especially important for:

* SPST switch
* DC connector
* battery
* buttons

---

# 33. FINAL DELIVERABLE

The final project must contain only:

```text
Arduino_Multifunction_Shield_Case/
├── config.scad
├── base.scad
├── top_plate.scad
└── main.scad
```

`base.scad` = independently printable lower enclosure.

`top_plate.scad` = independently printable upper/front interface plate.

`main.scad` = complete assembled preview with realistic hardware mockups.

The model must be parametrically driven from `config.scad`.

Do not create any other files unless I explicitly request them.

---

# 34. DEVELOPMENT BEHAVIOUR

Do not rush.

Do not generate hundreds of lines merely to appear complete.

Do not invent dimensions.

Do not silently change requirements.

Do not preserve a bad design simply because previous code used it.

When you detect a contradiction, explain it and resolve it mechanically.

When you detect a collision, fix the architecture.

When you detect an incorrect coordinate system, correct the datum rather than adding another arbitrary offset.

Your priority order is:

```text
1. Physical correctness
2. Component fit
3. Manufacturability
4. Parametric integrity
5. Printability
6. Clean code
7. Visual appearance
```

---

# START

First perform the requirements and geometry audit internally.

Then generate the complete project.

Do NOT give me a superficial first draft.

Do NOT stop merely because OpenSCAD compiles.

Build it, render it, inspect it, audit it, correct it, and re-check it.

If you require a real-world measurement that is genuinely unavailable, ask me for that exact measurement before finalizing.

When everything passes the engineering audit, provide the final four-file project only.

END OF MASTER PROMPT — REV 5

