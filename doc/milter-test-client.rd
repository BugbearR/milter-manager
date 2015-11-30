= milter-test-client / milter manager / milter manager's manual

== NAME

milter-test-client - milter side milter protocol implemented program

== SYNOPSIS

(({milter-test-client})) [((*option ...*))]

== DESCRIPTION

milter-test-client is a milter that just shows received data
from MTA. It also shows macros received from MTA, it can be
used for confirming MTA's milter configuration.

Postfix's source archive includes similar tool.
It's src/milter/test-milter.c. It seems that it's used for
testing Postfix's milter implementation. But test-milter
doesn't show macros. If you have a milter that doesn't work
as you expect and uses macro, milter-test-client is useful
tool for looking into the problems.

== Options

: --help

   Shows available options and exits.

: --connection-spec=SPEC

   Specifies a socket that accepts connections from
   MTA. SPEC should be formatted as one of the followings:

     * unix:PATH
     * inet:PORT
     * inet:PORT@HOST
     * inet:PORT@[ADDRESS]
     * inet6:POST
     * inet6:PORT@HOST
     * inet6:PORT@[ADDRESS]

   Examples:
     * unix:/tmp/milter-test-client.sock
     * inet:10025
     * inet:10025@localhost
     * inet:10025@[127.0.0.1]
     * inet6:10025
     * inet6:10025@localhost
     * inet6:10025@[::1]

: --log-level=LEVEL

   Specifies log output items. You can specify multiple items by separating
   items with "|" like "error|warning|message".

   See ((<Log list - Level|log-list.rd#level>)) for available levels.

: --log-path=PATH

   Specifies log output path. If you don't specify this option, log
   output is the standard output. You can use "-" to output to the
   standard output.

: --verbose

   Logs verbosely.

   "--log-level=all" option has the same effect.

: --syslog

   Logs Syslog too.

: --no-report-request

   Doesn't show any information received from MTA.

: --report-memory-profile

   Reports memory usage each milter session finished.

   When MILTER_MEMORY_PROFILE environment variable is set to
   'yes', details are reported.

   Example:
     % MILTER_MEMORY_PROFILE=yes milter-test-client -s inet:10025

: --daemon

   Runs as daemon process.

: --user=USER

   Runs as USER's process. root privilege is needed.

: --group=GROUP

   Runs as GROUP's process. root privilege is needed.

: --unix-socket-group=GROUP

   Changes UNIX domain socket group to GROUP when
   "unix:PATH" format SPEC is used.

: --n-workers=N_WORKERS

   Runs ((|N_WORKERS|)) processes to process mails.
   Available value is between 0 and 1000.
   If it is 0, no worker processes will be used.

   ((*NOTE: This item is an experimental feature.*))

: --event-loop-backend=BACKEND

   Uses ((|BACKEND|)) as event loop backend.
   Available values are ((%glib%)) or ((%libev%)).
   If you use glib backend, please refer to the following note.

   ((*NOTE: For the sake of improving milter-manager performance per process,
   event-driven model based architechture pattern is choosed in this software.
   If this feature is implemented by glib, it is expressed as a callback.
   Note that glib's callback registration upper limit makes
   the limitation of the number of communications.
   This limitations exist against glib backend only.*))

: --packet-buffer-size=SIZE

   Uses ((|SIZE|)) as send packets buffer size on
   end-of-message. Buffered packets are sent when buffer
   size is rather than ((|SIZE|)) bytes. Buffering is
   disabled when ((|SIZE|)) is 0.

   The default is 0KB. It means packet buffering is disabled
   by default.

: --version

   Shows version and exits.

== EXIT STATUS

The exit status is 0 if milter starts to listen and non 0
otherwise. milter-test-client can't start to listen when
connection spec is invalid format or other connection
specific problems. e.g. the port number is already used,
permission isn't granted for create UNIX domain socket and
so on.

== EXAMPLE

The following example runs a milter which listens at 10025
port and waits a connection from MTA.

  % milter-test-client -s inet:10025

== SEE ALSO

((<milter-test-server.rd>))(1),
((<milter-performance-check.rd>))(1)
