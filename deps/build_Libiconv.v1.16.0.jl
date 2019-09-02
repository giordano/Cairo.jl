using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = true #"--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libiconv"], :libiconv),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaBinaryWrappers/Libiconv_jll.jl/releases/download/Libiconv-v1.16.0+0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/Libiconv.v1.16.0.aarch64-linux-gnu.tar.gz", "31c725be17f94299ae02b28219f3cd7fdb297440f0303aa70f83a79f71893f74"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/Libiconv.v1.16.0.aarch64-linux-musl.tar.gz", "9cbf93b673ef9d9b7156887e4589043e92ec55d7fe0346c66b8ca279f8dda3f7"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/Libiconv.v1.16.0.arm-linux-gnueabihf.tar.gz", "a1f115552cb98687205097434301707969d7e5fb72d2040bb7672b024f534577"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/Libiconv.v1.16.0.arm-linux-musleabihf.tar.gz", "bf3ccd632f8581fc07e235d2d1a39ea2a50d290373312c22c2778326ab0fa7b6"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/Libiconv.v1.16.0.i686-linux-gnu.tar.gz", "9c684b831f912929094d8dd06124893cca3809d2bbb6a6f0e66148d93798d7f3"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/Libiconv.v1.16.0.i686-linux-musl.tar.gz", "e86c1a642cc993545647b037fd55487437cb07080d3cb12db1e971f823c45931"),
    Windows(:i686) => ("$bin_prefix/Libiconv.v1.16.0.i686-w64-mingw32.tar.gz", "29bdad22b4d9780b38adb17b32e4f4cb971bdec3a9951239f4a78dced9b4dad7"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/Libiconv.v1.16.0.powerpc64le-linux-gnu.tar.gz", "bfae01d3860938a424ed7de86032e3699a661b492a2fbeefa795a0f44ebd30b1"),
    MacOS(:x86_64) => ("$bin_prefix/Libiconv.v1.16.0.x86_64-apple-darwin14.tar.gz", "9cd7ce295085e1d63252e9065f8b7c41e3c35604039417e4eb3e235e815708a4"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/Libiconv.v1.16.0.x86_64-linux-gnu.tar.gz", "88b9b11b99b1d66caa8397663b38886b12eeb30fb1ee4418e43761149fb45257"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/Libiconv.v1.16.0.x86_64-linux-musl.tar.gz", "cf0ca9cd00dbfdc62ce74e89e0cb2b47f3d18335a176c41bed0a7c2172cf2d80"),
    FreeBSD(:x86_64) => ("$bin_prefix/Libiconv.v1.16.0.x86_64-unknown-freebsd11.1.tar.gz", "0fe5e4215d5ab9582c1fc6259ed001dcf319ff8868a37a788e20160c923b071a"),
    Windows(:x86_64) => ("$bin_prefix/Libiconv.v1.16.0.x86_64-w64-mingw32.tar.gz", "3cb448413852c03d92aa43146bfc88b23851e1654b705a1203b59af3b6b25ff5"),
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
