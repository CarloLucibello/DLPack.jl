using CondaPkg

# Python dependencies are declared in test/CondaPkg.toml and installed
# automatically by CondaPkg the first time the environment is used.

@static if Sys.islinux()
    # conda-forge's libtorch ships with an executable stack, which hardened
    # kernels refuse to load (`cannot enable executable stack as shared object
    # requires`). Clear the flag so `import torch` works under PythonCall.
    CondaPkg.withenv() do
        python = CondaPkg.which("python")
        script = "import sysconfig; print(sysconfig.get_paths()['purelib'])"
        sitelib = readchomp(`$python -c "$script"`)
        run(`patchelf --clear-execstack $sitelib/torch/lib/libtorch_cpu.so`)
        run(`patchelf --clear-execstack $sitelib/torch/lib/libtorch_global_deps.so`)
    end
end

# Load PythonCall after having installed all python dependencies
using PythonCall

ENV["PYTHON"] = PythonCall.C.CTX.exe_path

Pkg = Base.require(Base.PkgId(Base.UUID(0x44cfe95a1eb252eab672e2afdf69b78f), "Pkg"))
Pkg.build("PyCall")  # we rebuild PyCall to use the same python environment as PythonCall
