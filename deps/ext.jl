let addSearchDirs = [Pkg.dir("Cairo","deps","usr","lib")]
    global const _jl_libcairo = find_library(["libcairo-2", "libcairo"], addSearchDirs)
    _jl_libcairo != "" || error("libcairo not found")
    global const _jl_libpango = find_library(["libpango-1.0-0", "libpango-1.0", "libpango"], addSearchDirs)
    _jl_libpango != "" || error("libpango not found")
    global const _jl_libpangocairo = find_library(["libpangocairo-1.0-0", "libpangocairo-1.0", "libpangocairo"], addSearchDirs)
    _jl_libpangocairo != "" || error("libpangocairo not found")
    global const _jl_libgobject = find_library(["libgobject-2.0-0", "libgobject-2.0", "libgobject"], addSearchDirs)
    _jl_libgobject != "" || error("libgobject not found")
end
