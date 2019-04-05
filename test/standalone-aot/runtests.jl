include("IRGen.jl")
using .IRGen

using Test

# Various tests

twox(x) = 2x
@test twox(10) == @jlrun twox(10)

hello() = "hellllllo world!"
@test hello() == @jlrun hello()

fint() = UInt32
@test fint() == @jlrun fint()

const a = Ref(0x80808080)
jglobal() = a[]
@test jglobal()[] == (@jlrun jglobal())[]

arraysum(x) = sum([x, 1])
@test arraysum(6) == @jlrun arraysum(6)

fsin(x) = sin(x)
@test fsin(0.5) == @jlrun fsin(0.5)

fccall() = ccall(:jl_ver_major, Cint, ())
@test fccall() == @jlrun fccall()

fcglobal() = cglobal(:jl_n_threads, Cint)
@test fcglobal() == @jlrun fcglobal()

many() = ("jkljkljkl", :jkljkljkljkl, :asdfasdf, "asdfasdfasdf")
## @jlrun doesn't work with this method.
## Here, ccall needs an Any return type, not the tuple type deduced by @jlrun.
# @show @jlrun many()
native = irgen(many, Tuple{})
dump_native(native, "libmany.o")
run(`clang -shared -fpic libmany.o -o libmany.so`)
ccall((:init_lib, "./libmany.so"), Cvoid, ()) 
@test many() == ccall((:many, "./libmany.so"), Any, ()) 

const sv = Core.svec(1,2,3,4)
fsv() = sv
@test fsv() == @jlrun fsv()

const arr = [9,9,9,9]
farray() = arr
@test farray() == @jlrun farray()

