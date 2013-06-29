using BinDeps

find_library("Cairo", "libcairo", ["libcairo-2", "libcairo"]) || error("libcairo not found")
find_library("Cairo", "libfontconfig", ["libfontconfig-1", "libfontconfig"]) || error("libfontconfig not found")
find_library("Cairo", "libpango",["libpango-1.0-0", "libpango-1.0"]) || error("libpango not found")
 find_library("Cairo", "libpangocairo", ["libpangocairo-1.0-0", "libpangocairo-1.0"]) || error("libpangocairo not found")
find_library("Cairo", "libgobject", ["libgobject-2.0-0", "libgobject-2.0"]) || error("libgobject not found")

@osx_only find_library("Cairo", "libcairo_wrapper",["libcairo_wrapper"]) || error("libcairo_wrapper not found")
