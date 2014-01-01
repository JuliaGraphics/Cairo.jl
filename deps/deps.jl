macro checked_lib(libname, path)
        (dlopen_e(path) == C_NULL) && error("Unable to load \n\n$libname ($path)\n\nPlease re-run Pkg.build(package), and restart Julia.")
        quote const $(esc(libname)) = $path end
    end
@checked_lib _jl_libgobject "libgobject-2.0"
@checked_lib _jl_libpangocairo "libpangocairo-1.0"
@checked_lib _jl_libcairo "libcairo"
@checked_lib _jl_libpango "libpango-1.0"
