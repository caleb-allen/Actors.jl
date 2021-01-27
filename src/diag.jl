#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#

"""
	info(lk::Link)

Return the state of an actor associated with `lk`:

- `:runnable` if it is runnable,
- `:done` if it has finished,
- else return the failed task. 
"""
function info(lk::Link{Channel{Any}})
	!isnothing(lk.chn.excp) ?
		hasfield(typeof(lk.chn.excp), :task) ? 
			lk.chn.excp.task : 
			:done :
		:runnable
end
function info(lk::Link{RemoteChannel{Channel{Any}}})
	try
		diag(lk)
		return :runnable
	catch exc
		return exc.captured.ex isa InvalidStateException ?
			:done :
			exc.captured.ex.task
	end
end
info(lks::Array{Link,1}) = foreach(lks) do lk
	t = info(lk)
	println(t, ": ", t.exception)
end

"""
```
diag(lk::Link, check::Symbol=:state)
diag(name::Symbol, ....)
```
Diagnose an actor, get a state or stacktrace.

# Arguments
- `lk::Link`: actor link,
- `check::Symbol`: requested information,
	- `:state`: :ok if the actor is running, 
	- `:task`: current actor task,
	- `:act`: actor `_ACT` variable,
	- `:err`: error log (only monitors or supervisors).

!!! warn "This is for diagnosis only!"
	Don't use this for other purposes than for diagnosis.
"""
diag(lk::Link, check::Symbol=:state) = request(lk, Diag, check)
diag(name::Symbol, args...) = diag(whereis(name), args...)
