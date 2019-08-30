using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))

# These are the two binary objects we care about
products = Product[
    LibraryProduct(prefix, "libcairo", :libcairo),
]

dependencies = [
    "https://github.com/bicycle1885/ZlibBuilder/releases/download/v1.0.4/build_Zlib.v1.2.11.jl",
    "https://github.com/JuliaIO/LibpngBuilder/releases/download/v1.0.3/build_libpng.v1.6.37.jl",
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/Pixman-v0.36.0-0/build_Pixman.v0.36.0.jl",
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/Bzip2-v1.0.6-2/build_Bzip2.v1.0.6.jl",
    "https://github.com/JuliaGraphics/FreeTypeBuilder/releases/download/v2.9.1-4/build_FreeType2.v2.10.0.jl",
    "https://github.com/giordano/Yggdrasil/releases/download/X11-v1.6.8/build_X11.v1.6.8.jl",
    "https://github.com/giordano/Yggdrasil/releases/download/Cairo-v1.14.12/build_Cairo.v1.14.12.jl",
]


for dependency in dependencies
    file = joinpath(@__DIR__, basename(dependency))
    isfile(file) || download(dependency, file)
    # it's a bit faster to run the build in an anonymous module instead of
    # starting a new julia process

    # Build the dependencies
    Mod = @eval module Anon end
    Mod.include(file)
end

# Finally, write out a deps.jl file
write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
