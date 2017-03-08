## header to provide surface and context
using Cairo
c = CairoRGBSurface(256,256);
cr = CairoContext(c);

save(cr);
set_source_rgb(cr,0.8,0.8,0.8);    # light gray
rectangle(cr,0.0,0.0,256.0,256.0); # background
fill(cr);
restore(cr);

save(cr);
## original example, taken from cairo/test/pattern-mesh.c
function draw(cr, width::Int, height::Int)

	PAT_WIDTH  = 170
	PAT_HEIGHT = 170
	SIZE = PAT_WIDTH
	PAD = 2
	WIDTH = (PAD + SIZE + PAD)
	HEIGHT = WIDTH

	pattern = CairoPatternMesh();

	#cairo_test_paint_checkered (cr); ?

	translate(cr, PAD, PAD);
	translate(cr, 10, 10);

	mesh_pattern_begin_patch(pattern);

	mesh_pattern_move_to(pattern, 0, 0);
	mesh_pattern_curve_to(pattern, 30, -30,  60,  30, 100, 0);
	mesh_pattern_curve_to(pattern, 60,  30, 130,  60, 100, 100);
	mesh_pattern_curve_to(pattern, 60,  70,  30, 130,   0, 100);
	mesh_pattern_curve_to(pattern, 30,  70, -30,  30,   0, 0);

	mesh_pattern_set_corner_color_rgb(pattern, 0, 1, 0, 0);
	mesh_pattern_set_corner_color_rgb(pattern, 1, 0, 1, 0);
	mesh_pattern_set_corner_color_rgb(pattern, 2, 0, 0, 1);
	mesh_pattern_set_corner_color_rgb(pattern, 3, 1, 1, 0);

	mesh_pattern_end_patch(pattern);

	mesh_pattern_begin_patch(pattern);

	mesh_pattern_move_to(pattern, 50, 50);
	mesh_pattern_curve_to(pattern,  80,  20, 110,  80, 150, 50);
	mesh_pattern_curve_to(pattern, 110,  80, 180, 110, 150, 150);
	mesh_pattern_curve_to(pattern, 110, 120,  80, 180,  50, 150);
	mesh_pattern_curve_to(pattern,  80, 120,  20,  80,  50, 50);

	mesh_pattern_set_corner_color_rgba(pattern, 0, 1, 0, 0, 0.3);
	mesh_pattern_set_corner_color_rgb(pattern, 1, 0, 1, 0);
	mesh_pattern_set_corner_color_rgba(pattern, 2, 0, 0, 1, 0.3);
	mesh_pattern_set_corner_color_rgb(pattern, 3, 1, 1, 0);

	mesh_pattern_end_patch(pattern);

	set_source(cr, pattern);
	paint(cr);
	#pattern_destroy (pattern);

end

draw(cr,170,170);

## mark picture with current date
restore(cr);
move_to(cr,0.0,12.0);
set_source_rgb(cr, 0,0,0);
show_text(cr,Libc.strftime(time()));
write_to_png(c,"sample_meshpattern.png");
