#
# This file is part of the Actors.jl Julia package, 
# MIT license, part of https://github.com/JuliaActors
#

include("delays.jl")

using Actors, Distributed, Test, .Delays
import Actors: spawn

prcs = addprocs(9)

@everywhere using Actors

t1 = Ref{Task}()

println("Testing supervision with remote failures:")

# start a supervisor with spare nodes
sv = supervisor(:one_for_one, 9, 30, spares=prcs[3:5], taskref=t1)
sa = Actors.diag(sv, :act)
@test sa.bhv.option[:spares] == prcs[3:5]

# start actors for supervision on remote workers
act1 = spawn(+, 10, pid=prcs[1])
act2 = spawn(+, 20, pid=prcs[1])
act3 = spawn(+, 30, pid=prcs[2])
register(:act1, act1)
register(:act2, act2)
register(:act3, act3)

# put them under supervision
supervise(sv, act1)
@test @delayed sa.bhv.childs[1].lk === act1
@test sa.bhv.childs[1].name == :act1
@test @delayed sa.bhv.childs[2].lk.mode == :rnfd
rfd = sa.bhv.childs[2].lk
ra = Actors.diag(rfd, :act)
@test ra.bhv.sv == sv
@test ra.bhv.lks[1] === act1
@test ra.bhv.pids == [prcs[1]]
supervise(sv, act2)
@test @delayed sa.bhv.childs[3].lk === act2
@test length(sa.bhv.childs) == 3
@test @delayed ra.bhv.lks[2] === act2
@test length(ra.bhv.lks) == 2

# intermezzo: test unsupervise and (rfd)(::Remove)
unsupervise(sv, act2)
@test @delayed length(sa.bhv.childs) == 2
@test @delayed length(ra.bhv.lks) == 1

supervise(sv, act2)
supervise(sv, act3)
@test @delayed length(sa.bhv.childs) == 4
@test @delayed length(ra.bhv.lks) == 3
@test ra.bhv.pids == prcs[1:2]

sleep(1)
@test isempty(sv.chn)
rmprocs(prcs[1])
sleep(1)
@test @delayed act1.pid == prcs[3]
@test @delayed act2.pid == prcs[3]
@test @delayed sa.bhv.option[:spares] == prcs[4:5]
@test @delayed call(act1, 10) == 20
@test call(:act1, 10) == 20
@test @delayed call(act2, 10) == 30
@test call(:act2, 10) == 30
@test @delayed length(ra.bhv.lks) == 3
@test ra.bhv.pids == prcs[2:3]

rmprocs(prcs[2])
sleep(1)
@test @delayed act3.pid == prcs[4]
@test @delayed sa.bhv.option[:spares] == prcs[5:5]
@test @delayed call(act3, 10) == 40
@test call(:act3, 10) == 40
@test @delayed length(ra.bhv.lks) == 3
@test ra.bhv.pids == prcs[3:4]

rmprocs(prcs[3])
sleep(1)
@test @delayed act1.pid == prcs[5]
@test @delayed act2.pid == prcs[5]
@test @delayed isempty(sa.bhv.option[:spares])
@test @delayed call(act1, 10) == 20
@test call(:act1, 10) == 20
@test @delayed call(act2, 10) == 30
@test call(:act2, 10) == 30
@test @delayed length(ra.bhv.lks) == 3

rmprocs(prcs[5])
sleep(1)
@test @delayed act1.pid == prcs[end]
@test @delayed act2.pid == prcs[end]
@test @delayed call(act1, 10) == 20
@test call(:act1, 10) == 20
@test @delayed call(act2, 10) == 30
@test call(:act2, 10) == 30
@test @delayed length(ra.bhv.lks) == 3

rmprocs(prcs[4])
sleep(1)
@test @delayed call(act3, 10) == 40
@test call(:act3, 10) == 40
@test @delayed length(ra.bhv.lks) == 3

# change act2 to :temporary
sa.bhv.childs[3].info = (restart = :temporary,)
rmprocs(prcs[end])
sleep(1)
@test @delayed length(sa.bhv.childs) == 3
@test @delayed length(ra.bhv.lks) == 2

# set strategy to :one_for_all
set_strategy(sv, :one_for_all)
@test @delayed sa.bhv.option[:strategy] == :one_for_all
rmprocs(prcs[end-1])
sleep(1)
@test @delayed length(sa.bhv.childs) == 3
@test @delayed length(ra.bhv.lks) == 2

set_strategy(sv, :rest_for_one)
@test @delayed sa.bhv.option[:strategy] == :rest_for_one
rmprocs(prcs[end-2])
sleep(1)
@test @delayed length(sa.bhv.childs) == 3

rmprocs(prcs[end-3])