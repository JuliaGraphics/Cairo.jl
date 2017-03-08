using Cairo
include("shape_functions.jl")

function test_all(;tmax = 2.0, save_flag = false)
    print("cairo version: ",Cairo.libcairo_version,"\n");
    size_surface = [512];#,512,1024]; #three sizes of a surface
    paint_width = [0.5,1.0,3.0,5.0];
    shapes = [ddots1, ddots2, ddots3, ddots4, ddots5,
              rdots1, rdots2, rdots3, rdots4, rdots5, rdots6,
              lines0, lines1, lines2, lines3, lines4];
    n_elements = [100,300,1000,3000,10000,30000,100000];

    n_tests = length(size_surface) * length(paint_width) * length(shapes);
    test_data = zeros(n_tests+1,3 + length(n_elements));
    test_data[1,3+(1:length(n_elements))] = n_elements;
    i = 1;

    if save_flag && !isdir("test_results")
        mkdir("test_results")
    end

    for s_size in size_surface
        s = Cairo.CairoARGBSurface(s_size,s_size);
        c = Cairo.CairoContext(s);
        print("Surface Size: ",s_size,"\n")
        for w in paint_width
            print("Paint Width: ",w,"\n")
            for m_index in 1:length(shapes)
                test_data[i,1] = s_size;
                test_data[i,2] = w;
                test_data[i,3] = m_index;
                m = shapes[m_index];
                for n_index in 1:length(n_elements)
                    n = n_elements[n_index];
                    t = @elapsed(m(c,s_size,s_size,w,n));
                    print(m," ",@sprintf("%6d",n),"  elapsed time: ",@sprintf("%f seconds",t),"\n");
                    test_data[i+1,3+n_index] = t;
                    if save_flag
                        write_to_png(s,@sprintf("test_results/test_speed_%2.1f_%02d_%02d.png",w,m_index,n_index));
                    end
                    if t > tmax && n_index < length(n_elements)
                        println("Remaining tests in this sequence skipped")
                        break
                    end
                end
                print("\n")
                i += 1;
            end
        end
    end
end

test_all()
