using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = true #"--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["liblzo2"], :liblzo2),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaBinaryWrappers/LZO_jll.jl/releases/download/LZO-v2.10.0+0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/LZO.v2.10.0.aarch64-linux-gnu.tar.gz", "e52fa677da7ff05b34b9ece0687b115c14abe1c62c6c91d52fc44b8b62472efc"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/LZO.v2.10.0.aarch64-linux-musl.tar.gz", "3914e96ddd370014ebd45b8a2dcfdd4f58e36f16c5e329f9cb78e32cd5e4b162"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/LZO.v2.10.0.arm-linux-gnueabihf.tar.gz", "cabafde36a75013a290795a044c464d52a75af8d2e7a65f403311b0c51a48caf"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/LZO.v2.10.0.arm-linux-musleabihf.tar.gz", "d2dfc002d422ff5609db189fd70ca3f324e93f3a315d1e59540471e454280980"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/LZO.v2.10.0.i686-linux-gnu.tar.gz", "68b8e3985c9b3a679aa94f845ca59cb344c24f62cc72a983ad9d94893ab238db"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/LZO.v2.10.0.i686-linux-musl.tar.gz", "1af1f199194aba2adb83e7803e7109fee0d5ee0c624efa196835adf056d65909"),
    Windows(:i686) => ("$bin_prefix/LZO.v2.10.0.i686-w64-mingw32.tar.gz", "a2a9733122da8120d9998e0054ec917d843664a7bf61bcea81cb06c1ea49dd1b"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/LZO.v2.10.0.powerpc64le-linux-gnu.tar.gz", "e10799a78fda02b6242aebec185ddfff2d346411eb19d13b8237a565e589bc6a"),
    MacOS(:x86_64) => ("$bin_prefix/LZO.v2.10.0.x86_64-apple-darwin14.tar.gz", "456646ae7d9757d7d6a5464da661c9a408eba04a2deec004e06d76168940498d"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/LZO.v2.10.0.x86_64-linux-gnu.tar.gz", "051f1e2bdf58a68923dc00dfbc234cdff6d316fd4d2ef2f41d2dd7389165b8b0"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/LZO.v2.10.0.x86_64-linux-musl.tar.gz", "e5681aab8c4fe7cc948c47dbe8052aa72c71912538af4c8b7a9c7da8b9e7c7f6"),
    FreeBSD(:x86_64) => ("$bin_prefix/LZO.v2.10.0.x86_64-unknown-freebsd11.1.tar.gz", "3c3c10321263962799c3b9b77a89f57df07fbaf6ca3e1eb7e9a867a90c252cb1"),
    Windows(:x86_64) => ("$bin_prefix/LZO.v2.10.0.x86_64-w64-mingw32.tar.gz", "fbe885b9cc97520878a0d5f89d0627247f93e77173e90792408b0f699428cc1f"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
