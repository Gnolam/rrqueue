##' @section Methods:
##'
##' \describe{
##' \item{\code{status}}{
##'   Returns a scalar character indicating the task status.
##'
##'   \emph{Usage:}
##'   \code{status(follow_redirect = FALSE)}
##'
##'   \emph{Arguments:}
##'   \describe{
##'     \item{\code{follow_redirect}}{
##'       should we follow redirects to get the status of any requeued task?
##'     }
##'   }
##'
##'   \emph{Value}:
##'   Scalar character.  Possible values are
##'   \describe{
##'   \item{\code{PENDING}}{queued, but not run by a worker}
##'   \item{\code{RUNNING}}{being run on a worker, but not complete}
##'   \item{\code{COMPLETE}}{task completed successfully}
##'   \item{\code{ERROR}}{task completed with an error}
##'   \item{\code{ORPHAN}}{task orphaned due to loss of worker}
##'   \item{\code{REDIRECT}}{orphaned task has been redirected}
##'   \item{\code{MISSING}}{task not known (deleted, or never existed)}
##'   }
##' }
##' \item{\code{result}}{
##'   Fetch the result of a task, so long as it has completed.
##'
##'   \emph{Usage:}
##'   \code{result(follow_redirect = FALSE, sanitise = FALSE)}
##'
##'   \emph{Arguments:}
##'   \describe{
##'     \item{\code{follow_redirect}}{
##'       should we follow redirects to get the status of any requeued task?
##'     }
##'
##'     \item{\code{sanitise}}{
##'
##'       If the task is not yet complete or is missing, return an \code{UnfetchabmeTask} object rather than throwing an error.
##'     }
##'   }
##' }
##' \item{\code{expr}}{
##'   returns the expression stored in the task
##'
##'   \emph{Usage:}
##'   \code{expr(locals = FALSE)}
##'
##'   \emph{Value}:
##'   A quoted expression (a language object).  Turn this into a string with deparse.  If \code{locals} was \code{TRUE} there will be an environment attribute with local variables included.
##' }
##' \item{\code{envir}}{
##'   returns the environment identifier for the task
##'
##'   \emph{Usage:}
##'   \code{envir()}
##' }
##' \item{\code{times}}{
##'   returns a summar of times associated with this task.
##'
##'   \emph{Usage:}
##'   \code{times(unit_elapsed = "secs")}
##'
##'   \emph{Value}:
##'   A one row \code{data.frame} with columns
##'   \describe{
##'   \item{\code{submitted}}{Time the task was submitted}
##'   \item{\code{started}}{Time the task was started, or \code{NA} if waiting}
##'   \item{\code{finished}}{Time the task was completed, or \code{NA}
##'   if waiting or running}
##'   \item{\code{waiting}}{Elapsed time spent waiting}
##'   \item{\code{running}}{Elapsed time spent running, or \code{NA} if waiting}
##'   \item{\code{idle}}{Elapsed time since finished, or \code{NA}
##'   if waiting or running}
##'   }
##' }
##' }