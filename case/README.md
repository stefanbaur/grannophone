# Grannophone plywood case

This directory contains the plans for a plywood case.

Note that this is a work in progress. Most sheets should be usable already, but may lack information about where to drill holes when using a fretsaw/scrollsaw, and where to place screws.
The sheets *should* work with a lasercutter, too (if you use the SVG versions instead of the PDF ones) - feedback welcome!
Note that for lasercutting, you should use the individual SVG files and arrange them to match the size of the plywood sheets you have available. We tried auto-generating merged SVGs for the more common sizes, but the merge tool never really worked.

At present, the base model consists of the following sheets:

- scale check - print this first, to check that your printer is printing everything to scale
	- sheet_0.pdf

- telephone hook for the Digitus USB telephone receiver/headset
	- sheet_1_digitus.pdf
	- sheet_2_digitus.pdf
	- sheet_3_digitus.pdf - this sheet is needed twice! As with sheets 5 and 6 from the siedle_noamp series, you can simply attach two sheets (good sides facing each other) with masking tape and cut two sheets at the same time.
        - sheet_3_digitus_gespiegelt.pdf - this is a mirrored and partially stripped version of sheet 3 for easier lasercutting.

- telephone hook for the OpisTech telephone receiver/handset (with t-coil hearing aid support)
	- sheet_1_opistech.pdf
	- sheet_2_opistech.pdf
	- sheet_3_opistech.pdf - this sheet is needed twice! As with sheets 5 and 6 from the siedle_noamp series, you can simply attach two sheets (good sides facing each other) with masking tape and cut two sheets at the same time.
        - sheet_3_opistech_gespiegelt.pdf - this is a mirrored and partially stripped version of sheet 3 for easier lasercutting.


- base plates to accommodate two Siedle speakers, connected directly to the SBC, no amplifier
	- sheet_4_siedle_noamp.pdf
	- sheet_5_siedle_noamp.pdf
	- sheet_6_siedle_noamp.pdf - place this sheet on top of sheet 5, firmly secure them by wrapping them with masking tape, and start drilling/sawing/filing - this will help reduce splintering, and the affected areas on sheet 5 will be cut out later on anyway.


- base plates to accommodate two Visaton K50 WP speakers, connected directly to the SBC (or via amplifier, if you find one that works with them)
	- sheet_4_visaton.pdf
	- sheet_5_visaton.pdf - place this sheet on top of sheet 4, it is exactly the same, except for missing the cutout for the audio plug that's on sheet_4_visaton.pdf (and you could actually cut that out of sheet_5_visaton.pdf as well, it wouldn't matter)
	- sheet_6_visaton.pdf - place this sheet on top of sheets 4 and 5, firmly secure all of them by wrapping them with masking tape, and start drilling/sawing/filing - this will help reduce splintering, and the affected areas on sheets 4 and 5 will be cut out later on anyway.

- currently generic parts
	- sheet_7.pdf
	- sheet_8.pdf

- backplates for Digitus and OpisTech variants, including optional cutouts for Visaton SC 5.9 ND speakers (these require an amplifier)
	- sheet_9_digitus.pdf
	- sheet_9_opistech.pdf

- optional templates
	- a3_a5_position_marker.pdf - this draws little boxes in each corner of four DIN A5 sheets arranged in DIN A3 landscape mode - useful if you want to use masking tape on the bottom of your lasercutter to position your plywood sheets (use minimum power/engraving rather than cutting mode so you don't damage your device)
	- cut_a3_into_4_times_a5.pdf - a template to cut a DIN A3 sheet into four DIN A5 sheets - useful if you're using a lasercutter, as the larger sheets of plywood tend to warp easily
	- cut_a3_into_4_times_a5_with_corner_markers.pdf - a combination of the two templates listed above

Shield: [![CC BY-NC-SA 4.0][cc-by-nc-sa-shield]][cc-by-nc-sa]

This work is licensed under a
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License][cc-by-nc-sa].

[![CC BY-NC-SA 4.0][cc-by-nc-sa-image]][cc-by-nc-sa]

[cc-by-nc-sa]: http://creativecommons.org/licenses/by-nc-sa/4.0/
[cc-by-nc-sa-image]: https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png
[cc-by-nc-sa-shield]: https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg
