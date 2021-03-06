##' @section Methods:
##'
##' \describe{
##' \item{\code{workers_list}}{
##'
##'   Generalises the \code{workers_list} method in \code{\link{observer}} by adding optional support for listing workers that can work on the queue's environment.
##'
##'   \emph{Usage:}
##'   \code{workers_list(envir_only = FALSE)}
##'
##'   \emph{Arguments:}
##'   \describe{
##'     \item{\code{envir_only}}{
##'
##'       List workers that can carry out tasks in this queue's environment (see Details below for limitations).  By default this is \code{FALSE} and this method is identical in behaviour to the observer \code{workers_list} method.
##'     }
##'   }
##'
##'   \emph{Details:}
##'
##'   Workers that are started \emph{after} the queue will be listed here immediately as they start; by the time they have started they will report if they can work on this environment.
##'
##'   Workers that are started \emph{before} the queue will only be listed after they finish working on any current task and have cleared any messages in the message queue.  Practically this should be very quick.
##' }
##' \item{\code{workers_list_exited}}{
##'
##'   Generalises the \code{workers_list_exited} method in \code{\link{observer}} by adding optional support for listing workers that use to work on the queue's environment.  See \code{workers_list} for further details
##'
##'   \emph{Usage:}
##'   \code{workers_list_exited(envir_only = FALSE)}
##'
##'   \emph{Arguments:}
##'   \describe{
##'     \item{\code{envir_only}}{
##'
##'       List workers that could have carried out tasks in this queue's environment before exiting.  By default this is \code{FALSE} and this method is identical in behaviour to the observer \code{workers_list_exited} method.
##'     }
##'   }
##' }
##' \item{\code{enqueue}}{
##'   The main queuing function.
##'
##'   \emph{Usage:}
##'   \code{enqueue(expr, envir = parent.frame(), key_complete = NULL,
##'       group = NULL)}
##'
##'   \emph{Arguments:}
##'   \describe{
##'     \item{\code{expr}}{
##'       An unevaluated expression to be evaluated
##'     }
##'
##'     \item{\code{envir}}{
##'
##'       An environment in which local variables required to compute \code{expr} can be found.  These will be evaluated and added to the Redis database.
##'     }
##'
##'     \item{\code{key_complete}}{
##'
##'       an optional string representing the Redis key to write to when the task is complete.  You generally don't need to modify this, but is used in some higher-level functions (such as \code{link{rrqlapply}}) to keep track of task completions efficiently.
##'     }
##'
##'     \item{\code{group}}{
##'
##'       An optional human-readable "group" to add the task to. There are methods for addressing sets of tasks using this group.
##'     }
##'   }
##'
##'   \emph{Details:}
##'
##'   This method uses non standard evaluation and the \code{enqueue_} form may be prefereable for programming.
##'
##'   \emph{Value}:
##'
##'   invisibly, a \code{link{task}} object, which can be used to monitor the status of the task.
##' }
##' \item{\code{enqueue_}}{
##'
##'   The workhorse version of \code{enqueue} which uses standard evaluation and is therefore more suitable for programming.  All arguments are the same as \code{enqueue_} except for \code{eval}.
##'
##'   \emph{Usage:}
##'   \code{enqueue_(expr, envir = parent.frame(), key_complete = NULL,
##'       group = NULL)}
##'
##'   \emph{Arguments:}
##'   \describe{
##'     \item{\code{expr}}{
##'       Either a language object (quoted expression)
##'     }
##'
##'     \item{\code{envir}}{
##'       Environment to find locals (see `enqueue`)
##'     }
##'
##'     \item{\code{key_complete}}{
##'       See `enqueue`
##'     }
##'
##'     \item{\code{group}}{
##'       See `enqueue`
##'     }
##'   }
##' }
##' \item{\code{requeue}}{
##'
##'   Re-queue a task that has been orphaned by worker failure.
##'
##'   \emph{Usage:}
##'   \code{requeue(task_id)}
##'
##'   \emph{Arguments:}
##'   \describe{
##'     \item{\code{task_id}}{
##'       Task id number
##'     }
##'   }
##'
##'   \emph{Details:}
##'
##'   If a worker fails (either an unhandled exception, R crash, network loss or machine loss) then if the worker was running a heartbeat process the task will eventually be flagged as orphaned.  If this happens then the task can be requeued. Functions for fetching and querying tasks take a \code{follow_redirect} argument which can be set to \code{TRUE} so that this new, requeued, task is found instead of the old task.
##'
##'   \emph{Value}:
##'
##'   invisibly, a \code{\link{task}} object.
##' }
##' \item{\code{send_message}}{
##'
##'   Send a message to one or more (or all) workers.  Messages can be used to retrieve information from workers, to shut them down and are useful in debugging.  See Details for possible messages and their action.
##'
##'   \emph{Usage:}
##'   \code{send_message(command, args = NULL, worker_ids = NULL)}
##'
##'   \emph{Arguments:}
##'   \describe{
##'     \item{\code{command}}{
##'
##'       Name of the command to run; one of "PING", "ECHO", "EVAL", "STOP", "PAUSE", "RESUME", "INFO", "ENVIR", "PUSH", "PULL", "DIR".  See Details.
##'     }
##'
##'     \item{\code{args}}{
##'
##'       Arguments to pass through to commands.  Some commands require arguments, others do not.  See Details.
##'     }
##'
##'     \item{\code{worker_ids}}{
##'
##'       Optional vector of worker ids to send the message to.  If this is omitted (or \code{NULL} then try all workers that rrqueue knows about.
##'     }
##'   }
##'
##'   \emph{Details:}
##'
##'   The possible types of message are
##'
##'   \describe{
##'   \item{\code{PING}}{send a "PING" to the worker.  It will respond by
##'   replying PONG to its stderr, to its log (see \code{observer} for
##'   how to access) and to the response queue.  Ignores any argument.}
##'
##'   \item{\code{ECHO}}{Like "PING", but the worker responds by echoing the
##'   string given.  Requires one argument.}
##'
##'   \item{\code{PAUSE}}{Tell the worker to stop polling for new jobs,
##'   but continue polling for new messages.  Calling \code{PAUSE}
##'   multiple times in a row is not an error and leaves the worker in a
##'   paused state.  A paused worker will report "PAUSED" for its status.}
##'
##'   \item{\code{RESUME}}{Tell the worker to resume polling for new
##'   jobs, if paused.  All previous environments will be polled.}
##'
##'   \item{\code{INFO}}{Refresh the worker info (see \code{workers_info} in
##'   \code{\link{observer}}.  Worker will print info to stderr, write
##'   it to the appropriate place in the database and return it in the
##'   response queue.  Ignores any argument.}
##'
##'   \item{\code{DIR}}{Tell the worker to return directory contents and md5
##'   hashes of files.}
##'
##'   \item{\code{PUSH}}{Tell the worker to push files into the database.  The
##'   arguments should be a vector of filenames to copy.  The response
##'   queue will contain appropriate data for retrieving the files, bu
##'   the interface here will change to make this nice to use.}
##'
##'   \item{\code{PULL}}{Tells the worker to pull files into its working
##'   directory.  Can be used to keep the worker in sync.}
##'
##'   \item{\code{EVAL}}{Evaluate an arbitrary R expression as a string (e.g.,
##'   \code{run_message("EVAL", "sin(1)")}).  The output is printed to
##'   stdout, the worker log and to the response queue.  Requires a
##'   single argument.}
##'
##'   # the interface here is likely to change, so I'll withdraw the
##'   # documentation for now:
##'   # \code{ENVIR}: Tell the worker to try an load an environment, whose
##'   # id is given as a single argument.  Requires a single argument.
##'
##'   \item{\code{STOP}}{Tell the worker to stop cleanly.  Ignores any argument.}
##'   }
##'
##'   After sending a message, there is no guarantee about how long i
##'   will take to process.  If the worker is involved in a long-running
##'   computation it will be unavailable to process the message.
##'   However, it will process the message before running any new task.
##'
##'   The message id is worth saving.  It can be passed to the method
##'   \code{get_respones} to wait for and retrieve responses from one or
##'   more workers.
##'
##'
##'   \emph{Value}:
##'
##'   The "message id" which can be used to retrieve messages with \code{has_responses}, \code{get_responses} and \code{get_response}.
##' }
##' \item{\code{has_responses}}{
##'
##'   Detect which workers have responses ready for a given message id.
##'
##'   \emph{Usage:}
##'   \code{has_responses(message_id, worker_ids = NULL)}
##'
##'   \emph{Arguments:}
##'   \describe{
##'     \item{\code{message_id}}{
##'       id of the message (as returned by \code{send_message}
##'     }
##'
##'     \item{\code{worker_ids}}{
##'
##'       Optional vector of worker ids to send the message to.  If this is omitted (or \code{NULL} then try all workers that rrqueue knows about.
##'     }
##'   }
##'
##'   \emph{Value}:
##'
##'   A named logical vector; names are worker ids, the value is \code{TRUE} for each worker for which a response is ready and \code{FALSE} for workers where a response is not ready.
##' }
##' \item{\code{get_responses}}{
##'
##'   Retrieve responses to a give message id from one or more workers.
##'
##'   \emph{Usage:}
##'   \code{get_responses(message_id, worker_ids = NULL, delete = FALSE, wait = 0)}
##'
##'   \emph{Arguments:}
##'   \describe{
##'     \item{\code{message_id}}{
##'       id of the message (as returned by \code{send_message}
##'     }
##'
##'     \item{\code{worker_ids}}{
##'
##'       Optional vector of worker ids to send the message to.  If this is omitted (or \code{NULL} then try all workers that rrqueue knows about.
##'     }
##'
##'     \item{\code{delete}}{
##'
##'       delete the response after a successful retrieval of \emph{all} responses?
##'     }
##'
##'     \item{\code{wait}}{
##'
##'       Number of seconds to wait for a response.  We poll the database repeatedly during this interval.  If 0, then a response is requested immediately.  If no response is recieved from all workers in time, an error is raised.
##'     }
##'   }
##'
##'   \emph{Value}:
##'   Always returns a list, even if only one worker id is given.
##' }
##' \item{\code{get_response}}{
##'
##'   As for \code{get_responses}, but only for a single worker id, and returns the value of the response rather than a list.
##'
##'   \emph{Usage:}
##'   \code{get_response(message_id, worker_id, delete = FALSE, wait = 0)}
##'
##'   \emph{Arguments:}
##'   \describe{
##'     \item{\code{message_id}}{
##'       message id
##'     }
##'
##'     \item{\code{worker_id}}{
##'       single worker id
##'     }
##'
##'     \item{\code{delete}}{
##'       delete response after successful retrieval?
##'     }
##'
##'     \item{\code{wait}}{
##'       how long to wait for a message, in seconds
##'     }
##'   }
##' }
##' \item{\code{response_ids}}{
##'
##'   Get list of message ids that a given worker has responses for.
##'
##'   \emph{Usage:}
##'   \code{response_ids(worker_id)}
##'
##'   \emph{Arguments:}
##'   \describe{
##'     \item{\code{worker_id}}{
##'       single worker id
##'     }
##'   }
##' }
##' \item{\code{tasks_drop}}{
##'   Drop tasks from the database.
##'
##'   \emph{Usage:}
##'   \code{tasks_drop(task_ids)}
##'
##'   \emph{Arguments:}
##'   \describe{
##'     \item{\code{task_ids}}{
##'       Vector of task ids to drop
##'     }
##'   }
##' }
##' \item{\code{files_pack}}{
##'   Pack files into the Redis database
##'
##'   \emph{Usage:}
##'   \code{files_pack(..., files = c(...))}
##'
##'   \emph{Arguments:}
##'   \describe{
##'     \item{\code{...}}{
##'       filenames
##'     }
##'
##'     \item{\code{files}}{
##'       a vector of filename, used in place of \code{...}
##'     }
##'   }
##' }
##' \item{\code{files_unpack}}{
##'   Unpack files from the Redis database onto the filesystem.
##'
##'   \emph{Usage:}
##'   \code{files_unpack(pack, path = tempfile())}
##'
##'   \emph{Arguments:}
##'   \describe{
##'     \item{\code{pack}}{
##'       a \code{files_pack} object, created by \code{files_pack} or returned as a response to a \code{PUSH} response.
##'     }
##'
##'     \item{\code{path}}{
##'       path to unpack files.  Files will be overwritten without warning, so using \code{tempfile()} (the default) guarantees not to overwrite anything.  This method returns \code{path} invisibly so you can move files around easily afterwards.
##'     }
##'   }
##' }
##' \item{\code{tasks_set_group}}{
##'
##'   Set the group name for one or more tasks.  The tasks can be pending, running or completed, and the tasks can already have a group ir can be groupless.  Once tasks have been grouped they can be easier to work with as a set (see \code{tasks_in_groups} and \code{task_bundle_get} in \code{\link{observer}}.
##'
##'   \emph{Usage:}
##'   \code{tasks_set_group(task_ids, group, exists_action = "stop")}
##'
##'   \emph{Arguments:}
##'   \describe{
##'     \item{\code{task_ids}}{
##'       Vector of task ids
##'     }
##'
##'     \item{\code{group}}{
##'       Single group name
##'     }
##'
##'     \item{\code{exists_action}}{
##'
##'       Behaviour when a group name already exists for a given task. Options are \code{"stop"} (throw an error, the default), \code{"warn"} (warn, but don't rename), \code{"pass"} (don't warn, don't rename) and \code{"overwrite"} (replace the group name).
##'     }
##'   }
##' }
##' \item{\code{stop_workers}}{
##'
##'   Stop some or all rrqueue workers.
##'
##'   \emph{Usage:}
##'   \code{stop_workers(worker_ids = NULL, type = "message", interrupt = TRUE,
##'       wait = 0)}
##'
##'   \emph{Arguments:}
##'   \describe{
##'     \item{\code{worker_ids}}{
##'
##'       Optional vector of worker ids to send the message to.  If this is omitted (or \code{NULL} then try all workers that rrqueue knows about.
##'     }
##'
##'     \item{\code{type}}{
##'
##'       way to stop workers; options are \code{"message"} (the default) or \code{"kill"}.  See Details for more information.
##'     }
##'
##'     \item{\code{interrupt}}{
##'
##'       Should busy workers be interrupted after sending a message?  See Details.
##'     }
##'
##'     \item{\code{wait}}{
##'
##'       How long to wait after sending a message for a response to be retrieved.  If this is greater than zero, any unresponsive workers will be killed.
##'     }
##'   }
##'
##'   \emph{Details:}
##'
##'   Stopping remote workers is fairly tricky because we can't really talk to them, they might be working on a task, or worse they might be working on a task that does not listen for interrupt (custom C/C++ code is a common culprit here).
##'
##'   The default behaviour of this function is to send a \code{STOP} message and then immediately send an interrupt signal to all workers that have status \code{"BUSY"}.  This should work in most cases.  Wait a second or two and then check \code{workers_list_exited()} to make sure that all workers are listed.
##'
##'   To let workers finish whatever task they are working on, specify \code{interrupt=FALSE}.  The \code{STOP} message will be the next thing the workers process, so they will shut down as soon as they finish the task.
##'
##'   To ensure that workers do stop in some timeframe, specify a time. Passing \code{time=5} will send a \code{STOP} signal (and possibly an interrupt) and then poll for responses from all workers for 5 seconds.  Any worker that has not completed within this time will then be killed.  If all workers respond in time, the function will exit more quickly, so you can use an overestimate.
##'
##'   If you just want to kill the workers outright, use \code{type="kill"} which will send a \code{SIGTERM} via the database.  No other checks are done as the worker will be unceremoniously halted.
##'
##'   If you want to kill a local worker and just want it dead, you can use \code{type="kill_local"} which will use \code{tools::pskill} to terminate the process.  This is really a line of last resort.
##' }
##' \item{\code{refresh_environment}}{
##'
##'   Refresh environment contents and inform workers of the update.  If the environment has not changed (i.e., no changes to source files) then nothing happens.  All \emph{new} tasks will be started with the new environment but all \code{old} tasks will continue to use the previous environment.  If you want old tasks to use the new environment you will need to drop and requeue them (there is no support for this automatically).
##'
##'   \emph{Usage:}
##'   \code{refresh_environment(global = TRUE)}
##'
##'   \emph{Arguments:}
##'   \describe{
##'     \item{\code{global}}{
##'       logical, indicating if environment contents should be sourced locally.  Ideally, use the same value as you did when creating the original queue object.
##'     }
##'   }
##'
##'   \emph{Value}:
##'   Invisibly returns \code{TRUE} if the environment was updated or \code{FALSE} if not.
##' }
##' }
