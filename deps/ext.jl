let
    printerror() = error("Failed to find required library "*libname*". Try re-running the package script using Pkg.runbuildscript(\"pkg\")")

    if (!find_library("Cairo", "libcairo",OS_NAME == :Windows ? "libcairo-2" : "libcairo") ||
        !find_library("Cairo", "libfontconfig",OS_NAME == :Windows ? "libfontconfig-1" : "libfontconfig") ||
        !find_library("Cairo", "libpango-1.0",OS_NAME == :Windows ? "libpango-1.0-0" : "libpango-1.0") ||
        !find_library("Cairo", "libpangocairo-1.0",OS_NAME == :Windows ? "libpangocairo-1.0-0" : "libpangocairo-1.0") ||
        !find_library("Cairo", "libgobject-2.0",OS_NAME == :Windows ? "libgobject-2.0-0" : "libgobject-2.0")
        )
        printerror()
    end

end
