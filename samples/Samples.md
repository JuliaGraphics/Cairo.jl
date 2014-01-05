Sample programs.
################

This is mainly a copy of the sample code examples listed at [cairographics.org/samples](http://www.cairographics.org/samples/).
The examples are C code and need a environment of a Cairo surface and Cairo Context.

This (samples) directory contains independend julia programms that prefixes the orginal, ported code with the creation of a Surface and Context and an output routine to a .png file, rendering the current time into picture.

### arc #

Example of using the arc path operator [sample_arc.jl](sample_arc.jl).
Note: The path creation starts without current point, otherwise there would be a linesegment first, before starting of the arc.

![arc .png](sample_arc.png "arc example")

### arc_negative #

Example of using the arc_negative path operator [sample_arc_negative.jl](sample_arc_negative.jl).

![arc_negative .png](sample_arc_negative.png "arc negative example")

### clip #

A clip path, a circle is defined, then the drawing is done [sample_clip.jl](sample_clip.jl).

![clip .png](sample_clip.png "clip example")

### clip image #

Like the previous, but now inserting a picture by reading a .png to an Image Surface. Note: the function is called read_from_png and creates an Image Surface; while in pure C cairo this would be a call of cairo_image_surface_create_from_png [sample_clip_image.jl](sample_clip_image.jl).

![clip image.png](sample_clip_image.png "clip image example")

### curve rectangle #
missing.

### curve to #

Example of using the curve to path operator, which adds a cubic Bézier spline to the current path [sample_curve_to.jl](sample_curve_to.jl).

![curve to .png](sample_curve_tp.png "curve to example")






