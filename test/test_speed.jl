using Cairo
import shape_functions

print("cairo version:",ccall((:cairo_version,Cairo._jl_libcairo),Int32,()),"\n")

#size_surface = [256,512,1024] #three sizes of a surface
size_surface = [512]

for s_size in size_surface

	s = Cairo.CairoARGBSurface(s_size,s_size);
	c = Cairo.CairoContext(s)

	print("Surface Size: ",s_size,"\n");

	for w in [0.5,1.0,3.0]

		print("Paint Width: ",w,"\n");		

		for m in [ddots1, ddots2, ddots3, ddots4, lines0, lines1, lines2]

			for n in [100,300,1000,3000,10000,30000,100000]
				print(m," ",@sprintf("%6d",n),"  ");
        		@time m(c,s_size,s_size,w,n)
        	end
        	print("\n");
    	end
	end
end
