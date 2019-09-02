using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = true #"--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libX11"], :libX11),
    LibraryProduct(prefix, ["libX11-xcb"], :libX11_xcb),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaBinaryWrappers/X11_jll.jl/releases/download/X11-v1.6.8+3"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/X11.v1.6.8.aarch64-linux-gnu.tar.gz", "66a4e90fbbf28134ccc9955d69e7a39128fd5eac302908896c6afc49c7af8b74"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/X11.v1.6.8.aarch64-linux-musl.tar.gz", "6d72b9c547046236506ca167c6d906dd510d2d85584a6a3aee0554eac30d6b6f"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/X11.v1.6.8.arm-linux-gnueabihf.tar.gz", "268f9074808301dcf7ec736e04c23456320611526aee4414104fa85988795ee4"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/X11.v1.6.8.arm-linux-musleabihf.tar.gz", "4f0b3cf80aa6e0dcabc99fd4a24b09c540265c1fc4cf6bbff4f68f79e8245c55"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/X11.v1.6.8.i686-linux-gnu.tar.gz", "ff46ea524df10a642a8d998731edaba4c1412592fb85671f371dca9644268867"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/X11.v1.6.8.i686-linux-musl.tar.gz", "c67d3c15ae1a85f2a7f9fbc3208d9dfb39517f1ea17d5d6701e115e29f14021d"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/X11.v1.6.8.powerpc64le-linux-gnu.tar.gz", "8cf5424bd749e74bf8868159cd710ba8108e705b61b963f04e1a5850de1dbacd"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/X11.v1.6.8.x86_64-linux-gnu.tar.gz", "151d0366855cd3a9c26f1c6c7f32e81bc99d4f955e72c59f634e0152b658aac9"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/X11.v1.6.8.x86_64-linux-musl.tar.gz", "58cf221560c3ac0d32183e692eec58720fcf906c99f0ef6ab7f81d0286171560"),
    FreeBSD(:x86_64) => ("$bin_prefix/X11.v1.6.8.x86_64-unknown-freebsd11.1.tar.gz", "3249f3ad025ff31ebdec4a5463df84700747f0d78a2c7a9702beadf0723c6ee0"),
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
