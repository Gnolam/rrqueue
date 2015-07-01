# rrqueue

Beyond `mclapply` -- queue-based parallel processing in R, using [Redis](http://redis.io).

The idea here is to allow `mclapply`-like parallelisation, but with richer control.  A queue can be created and reattached to from different R instances; jobs can be added to the queue and queried.  Jobs that fail due to workers crashing (or running on nodes that have been shut down) can be restarted.

# Simple usage

Start a queue that we will submit tasks to
```
con <- rrqueue::queue("jobs")
```

Expressions can be queued using the `enqueue` method:

```
task <- con$enqueue(sin(1))
```

Task objects can be inspected to find out (for example) how long they have been waiting for:

```
task$times()
```

or what their status is:

```
task$status()
```

To get workers to process jobs from this queue, interactively run (in a separate R instance)

```
w <- rrqueue::worker("jobs")
```

or spawn a worker in the background with

```
logfile <- tempfile()
rrqueue::worker_spawn("jobs", logfile)
```

The task will complete:

```
task$status()
```

and the value can be retrieved:

```
task$result()
```

```
con$send_message("STOP")
```

In contrast with many parallel approaches in R, workers can be added at at any time and will automatically start working on any remaining jobs.

There's lots more in various stages of completion, including `mclapply`-like functions (`rrqlapply`), and lots of information gathering.

# Installation

Redis must be installed, `redis-server` must be running.  If you are familiar with docker, the [redis](https://registry.hub.docker.com/_/redis/) docker image might be a good idea here. Alterantively, [download redis](http://redis.io/download), unpack and then install by running `make install` in a terminal window within the downlaoded folder.

Once installed start `redis-server` by typing in a terminal window

```
redis-server
```

On Linux the server will probably be running for you if you.  Try `redis-server PING` to see if it is running.


R packages:

```
install.packages(c("RcppRedis", "R6", "digest", "docopt"))
devtools::install_github(c("gaborcsardi/crayon", "ropensci/RedisAPI", "richfitz/RedisHeartbeat", "richfitz/storr"))
devtools::install_git("https://github.com/traitecoevo/rrqueue")
```

(*optional*) to see what is going on, in a terminal, run `redis-cli monitor` which will print all the Redis chatter, though it will impact on redis performance.
