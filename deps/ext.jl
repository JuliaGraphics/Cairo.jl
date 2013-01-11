ccall(:add_library_mapping,Int32,(Ptr{Uint8},Ptr{Uint8}),"libcairo",dlopen("/Users/keno/.julia/Cairo/deps/usr/lib/libcairo.dylib"))
ccall(:add_library_mapping,Int32,(Ptr{Uint8},Ptr{Uint8}),"libpango-1.0",dlopen("/Users/keno/.julia/Cairo/deps/usr/lib/libpango-1.0.dylib"))
ccall(:add_library_mapping,Int32,(Ptr{Uint8},Ptr{Uint8}),"libpangocairo-1.0",dlopen("/Users/keno/.julia/Cairo/deps/usr/lib/libpangocairo-1.0.dylib"))
ccall(:add_library_mapping,Int32,(Ptr{Uint8},Ptr{Uint8}),"libgobject-2.0",dlopen("/Users/keno/.julia/Cairo/deps/usr/lib/libgobject-2.0.dylib"))
