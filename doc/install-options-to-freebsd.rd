# -*- rd -*-

= Install to FreeBSD (optional) --- How to install milter manager related softwares to FreeBSD

== About this document

This document describes how to install milter manager
related softwares to FreeBSD. See ((<Install to
FreeBSD|install-to-freebsd.rd>)) for milter manager install
information and ((<Install|install.rd>)) for general install
information.

== [freebsd-milter-manager-log-analyzer] Install milter-manager-log-analyzer

=== Install packages

We use Apache as Web server. We will install Apache 2.2
series. (www/apache22)

  % sudo /usr/local/sbin/portupgrade -NRr www/apache22

We use RRDtool for generating graphs. We also install Ruby
bindings to RRDtool.

((*NOTE: The Ruby bindings in RRDtool 1.3.8 has a bug. Don't
specify "-M'WITH_RUBY_MODULE=yes'" when you use 1.3.8.*))

  % sudo /usr/local/sbin/portupgrade -NRr -M'WITH_RUBY_MODULE=yes' rrdtool

=== Configure milter-manager-log-analyzer

milter-manager-log-analyzer generates graphs to
milter-manager user's home directory. They are published at
at http://localhost/~milter-manager/log/.

  % sudo -u milter-manager mkdir -p ~milter-manager/public_html/log

Apache publishes users' files. We edit
/usr/local/etc/apache22/httpd.conf like the following:

Before:
  # User home directories
  #Include etc/apache22/extra/httpd-userdir.conf

After:
  # User home directories
  Include etc/apache22/extra/httpd-userdir.conf

Then we reload configuration file:

  % sudo /usr/local/etc/rc.d/apache22 reload

Next, we setup cron for milter-manager
user. milter-manager-log-analyzer extracts milter-manager
information from log file and generates graphs regularly.

  % sudo -u milter-manager -H crontab /usr/local/etc/milter-manager/cron.d/freebsd/milter-manager-log

milter-manager-log-analyzer is invoked every 5 minutes. We
can confirm it is invoked at /var/log/cron.

== [freebsd-milter-manager-admin] Install milter manager admin

=== Install packages

To install the following packages, related packages are also
installed:

  % sudo /usr/local/sbin/portupgrade -NRr rubygem-sqlite3

=== Instal gems

  % sudo gem install rails -v '2.3.2'
  % sudo gem install passenger -v '2.2.4'

=== Install Passenger

To build Passenger we run the following command:

  % (echo 1; echo) | sudo passenger-install-apache2-module

Then we create /usr/local/etc/apache22/Includes/passenger.conf
with the following content:

  LoadModule passenger_module /usr/local/lib/ruby/gems/1.8/gems/passenger-2.2.4/ext/apache2/mod_passenger.so
  PassengerRoot /usr/local/lib/ruby/gems/1.8/gems/passenger-2.2.4
  PassengerRuby /usr/local/bin/ruby18

  RailsBaseURI /milter-manager

We reload configuration file:

  % sudo /usr/local/etc/rc.d/apache22 reload

milter manager admin has password authentication but it's
better that milter manager admin accepts connections only
from trusted hosts. For example, here is an example
configuration that accepts connections only from
localhost. We can use the configuration by appending it to
/usr/local/etc/apache22/Includes/passenger.conf.

  <Location /milter-manager>
    Allow from 127.0.0.1
    Deny from ALL
  </Location>

If we append the configuration, we should not forget to
reload configuration:

  % sudo /usr/local/etc/rc.d/apache22 reload

=== Configure milter manager admin

milter manager admin is installed to
/usr/local/share/milter-manager/admin/. We run it as
milter-manager user authority, and access it at
http://localhost/milter-manager/.

  % tar cf - -C /usr/local/share/milter-manager admin | sudo -u milter-manager -H tar xf - -C ~milter-manager
  % sudo ln -s ~milter-manager/admin/public /usr/local/www/apache22/data/milter-manager
  % cd ~milter-manager/admin
  % sudo -u milter-manager -H rake gems:install
  % sudo -u milter-manager -H rake RAILS_ENV=production db:migrate

Then we create a file to
~milter-manager/admin/config/initializers/relative_url_root.rb
with the following content:

~milter-manager/admin/config/initializers/relative_url_root.rb
  ActionController::Base.relative_url_root = "/milter-manager"

Now, we can access to http://localhost/milter-manager/. The
first work is registering a user. We will move to
milter-manager connection configuration page after register
a user. We can confirm where milter-manager accepts control
connection:

  % sudo -u milter-manager -H /usr/local/sbin/milter-manager --show-config | grep controller.connection_spec
  controller.connection_spec = "unix:/var/run/milter-manager/milter-manager-controller.sock"

We register confirmed value by browser. In the above case,
we select "unix" from "Type" at first. "Path" will be
appeared. We specify
"/var/run/milter-manager/milter-manager-controller.sock" to "Path".

We can confirm registered child milters and their
configuration by browser.

== Conclusion

We can confirm milter's effect visually by
milter-manager-log-analyzer. If we use Postfix as MTA, we
can compare with
((<Mailgraph|URL:http://mailgraph.schweikert.ch/>))'s graphs
to confirm milter's effect. We can use graphs generated by
milter-manager-log-analyzer effectively when we are trying
out a milter.

We can reduce administration cost by using milter manager
admin. Because we can change configurations without editing
configuration file.

It's convenient that we can enable and/or disable milters by
browser when we try out milters. We can use graphs generated
by milter-manager-log-analyzer to find what is the best milter
combination for our mail system.
