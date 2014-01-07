## Sample programs #

This is roughly a copy of the sample code listed at [cairographics.org/samples](http://www.cairographics.org/samples/).
These examples are C code and assume that you've already set up a Cairo surface and Cairo Context.

This (samples) directory contains ports of these examples to julia, additionally creating the Surface and Context, adding a time-stamp to the image, and saving the result to a .png file.

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
Missing.

### curve to #

Example of using the curve to path operator, which adds a cubic Bézier spline to the current path [sample_curve_to.jl](sample_curve_to.jl).

![curve to .png](sample_curve_to.png "curve to example")

### dash #

Example of using a dash line pattern for stroking a path. Note: the julia set_dash uses the length of the dash array to set the ndash internally [sample_dash.jl](sample_dash.jl).

![dash .png](sample_dash.png "dash example")

### fill and stroke 2 #

Example of creating a path of non connected areas and fill - while preserving the path - and stroke [sample_fill_and_stroke2.jl](sample_fill_and_stroke2.jl).

![fill and stroke2 .png](sample_fill_and_stroke2.png "fill and stroke2 example")

### fill style #

Exmaple of using the different fill rules. The same path is filled and stroked [sample_fill_style.jl](sample_fill_style.jl). Note: the julia function is called set_fill_type while the pure C cairo is called with set_fill_rule.

![fill style .png](sample_fill_style.png "fill style example")

### gradient #
missing.

### image #

Example of painting with a Image Surface as source [sample_image.jl](sample_image.jl).

![image .png](sample_image.png "image example")

### image pattern #

Example of painting with a Image Surface as pattern [sample_imagepattern.jl] (sample_imagepattern.jl).

![imagepattern .png](sample_imagepattern.png "imagepattern example")

### multi segment caps #

Example of stroking a path with non connected segments [sample_multi_segment_caps.jl](sample_multi_segment_caps.jl).

![multi segment caps .png](sample_multi_segment_caps.png "multi segment caps example")

### rounded rectangle #

Example of more path operators, custom shape could be wrapped in a function [sample_rounded_rectangle.jl](sample_rounded_rectangle.jl).

![rounded rectangle .png](sample_rounded_rectangle.png "rounded rectangle example")

### set line caps

Examples of the line cap settings [sample_set_line_cap.jl](sample_set_line_cap.jl).

![set line cap .png](sample_set_line_cap.png "line caps example")

### set line join

Examples of the line join settings [sample_set_line_join.jl](sample_set_line_join.jl).

![set line join .png](sample_set_line_join.png "line join example")

### text

Example of setting text, one with text_show, second with text_path extending the current path and fill and stroke the outline [sample_text.jl](sample_text.jl).

![text .png](sample_text.png "text example")

### text align center

Example of getting the text extents, then centering the text around 128.0,128.0 [sample_text_align_center.jl](sample_text_align_center.jl).

![text align center.png](sample_text_align_center.png "text align example")

### text extents

Example of getting the text extents, plotting the dimension [sample_text_extents.jl](sample_text_extents.jl).

![text extents .png](sample_text_extents.png "text extents example")



