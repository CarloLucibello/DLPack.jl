using CondaPkg

python_deps = ["jax<0.4", "numpy<2.1", "pytorch", "setuptools<70"]

CondaPkg.add(CondaPkg.PkgREPL.parse_pkg.(python_deps))

@static if Sys.islinux()
    CondaPkg.withenv() do
        python = CondaPkg.which("python")
        script = "import sysconfig; print(sysconfig.get_paths()['purelib'])"
        sitelib = readchomp(`$python -c "$script"`)
        run(`patchelf --add-rpath '$ORIGIN/../../../..' $sitelib/torch/lib/libtorch_cpu.so`)
        run(`patchelf --add-rpath '$ORIGIN/../../../..' $sitelib/torch/lib/libtorch_global_deps.so`)
    end
end

# Load PythonCall after having installed all python dependencies
using PythonCall

ENV["PYTHON"] = PythonCall.C.CTX.exe_path

Pkg = Base.require(Base.PkgId(Base.UUID(0x44cfe95a1eb252eab672e2afdf69b78f), "Pkg"))
Pkg.build("PyCall")  # we rebuild PyCall to use the same python environment as PythonCall
