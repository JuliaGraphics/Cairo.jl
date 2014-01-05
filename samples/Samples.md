Sample programs.
################

This is mainly a copy of the sample code examples listed at [cairographics.org/samples](http://www.cairographics.org/samples/).
The examples are C code and need a environment of a Cairo surface and Cairo Context.

This (samples) directory contains independend julia programms that prefixes the orginal, ported code with the creation of a Surface and Context and an output routine to a .png file, rendering the current time into picture.

### arc #

Example of using the arc path operator (sample_arc.jl).
Note: The path creation starts without current point, otherwise there would be a linesegment first, before starting of the arc.

![arc .png](sample_arc.png "arc example")

### arc_negative #

Example of using the arc_negative path operator (sample_arc_negative.jl).

