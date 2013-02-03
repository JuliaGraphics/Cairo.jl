let 
    function find_library(libname,filename)
        try 
            dl = dlopen(joinpath(Pkg.dir(),"Cairo","deps","usr","lib",filename))
            ccall(:add_library_mapping,Int32,(Ptr{Uint8},Ptr{Uint8}),libname,dl)
        catch
            try 
                dl = dlopen(libname)
                dlclose(dl)
            catch
                error("Failed to find required library "*libname*". Try re-running the package script using Pkg.runbuildscript(\"pkg\")")
            end
        end
    end
    find_library("libcairo",OS_NAME == :Windows ? "libcairo-2" : "libcairo")
    find_library("libfontconfig","libfontconfig")
    find_library("libpango-1.0",OS_NAME == :Windows ? "libpango-1.0-0" : "libpango-1.0")
    find_library("libpangocairo-1.0",OS_NAME == :Windows ? "libpangocairo-1.0-0" : "libpangocairo-1.0")
    find_library("libgobject-2.0",OS_NAME == :Windows ? "libgobject-2.0-0" : "libgobject-2.0")
end
