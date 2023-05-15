# Grannophone plywood case

This directory contains the plans for a plywood handset.

Note that this is a work in progress. Most sheets should be usable already, but may lack information about where to drill holes when using a fretsaw/scrollsaw, and where to place screws. Screw positions may also be entirely wrong.
The sheets *should* work with a lasercutter, too (if you use the SVG versions instead of the PDF ones) - feedback welcome!
Note that for lasercutting, you should use the individual SVG files and arrange them to match the size of the plywood sheets you have available. We tried auto-generating merged SVGs for the more common sizes, but the merge tool never really worked.

At present, the base model consists of the following sheets:

- scale check - print this first, to check that your printer is printing everything to scale
	- ../case/sheet_0.pdf

- handset based on the EKULIT 210030 (ETR-35/21A) dynamic receiver (alternatively a VISATON K16 50 Ohm speaker) and a Siedle STS/CTB 711-... (200019224-00) electret microphone. The handset should work as a drop-in replacement for the Digitus one, but will require a USB soundcard and a shielded audio cable with a TRRS plug (plus a TRRS - 2 x TRS splitter cable if your USB soundcard has separate ports for Audio in and Audio out). Note that there are two gaps in the two middle layers that SHOULD be large enough to fit two pairs of WAGO 221-2411 cage clamps, but they MUST be inserted *horizontally* (i.e. with their orange "wings" folded flat in and pointing *to the left and right*, NOT upwards).
        - sheet_a_ekulit_visaton_siedle.pdf
        - sheet_b_ekulit_visaton_siedle.pdf

- optional templates
	- ../case/a3_a5_position_marker.pdf - this draws little boxes in each corner of four DIN A5 sheets arranged in DIN A3 landscape mode - useful if you want to use masking tape on the bottom of your lasercutter to position your plywood sheets (use minimum power/engraving rather than cutting mode so you don't damage your device)
	- ../case/cut_a3_into_4_times_a5.pdf - a template to cut a DIN A3 sheet into four DIN A5 sheets - useful if you're using a lasercutter, as the larger sheets of plywood tend to warp easily
	- ../case/cut_a3_into_4_times_a5_with_corner_markers.pdf - a combination of the two templates listed above

Shield: [![CC BY-NC-SA 4.0][cc-by-nc-sa-shield]][cc-by-nc-sa]

This work is licensed under a
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License][cc-by-nc-sa].

[![CC BY-NC-SA 4.0][cc-by-nc-sa-image]][cc-by-nc-sa]

[cc-by-nc-sa]: http://creativecommons.org/licenses/by-nc-sa/4.0/
[cc-by-nc-sa-image]: https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png
[cc-by-nc-sa-shield]: https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg
