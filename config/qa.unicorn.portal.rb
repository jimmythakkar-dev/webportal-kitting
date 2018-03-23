# Minimal sample configuration file for Unicorn (not Rack) when used
# with daemonization (unicorn -D) started in your working directory.
#
# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.
# See also http://unicorn.bogomips.org/examples/unicorn.conf.rb for
# a more verbose configuration using more features.# a more verbose configuration using more features.

# listen 8080, :tcp_nopush =&gt; true
listen 20090 # by default Unicorn listens on port 8080

pid "/apps/rails/portal/tmp/pids/portal.pid"
stderr_path "/apps/rails/portal/log/portal.err"
stdout_path "/apps/rails/portal/log/portal.out"
