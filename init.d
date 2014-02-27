#! /bin/sh
### BEGIN INIT INFO
# Provides:          glassfish
# Required-Start:    $remote_fs $network $syslog
# Required-Stop:     $remote_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Starts GlassFish
# Description:       Starts GlassFish application server
### END INIT INFO

GLASSFISH_DIR=/opt/glassfish/glassfish
DERBY_BIN=$GLASSFISH_DIR/javadb/bin

case "$1" in
start)
  echo "Starting GlassFish from $GLASSFISH_DIR"
  sudo -u glassfish -E "$GLASSFISH_DIR/bin/asadmin" start-database
  sudo -u glassfish -E "$GLASSFISH_DIR/bin/asadmin" start-domain domain1
  ;;
stop)
  echo "Stopping GlassFish from $GLASSFISH_DIR"
  sudo -u glassfish -E "$GLASSFISH_DIR/bin/asadmin" stop-domain domain1
  sudo -u glassfish -E "$GLASSFISH_DIR/bin/asadmin" stop-database
  ;;
restart)
  $0 stop
  $0 start
  ;;
status)
  echo "# GlassFish at $GLASSFISH_DIR:"
  sudo -u glassfish -E "$GLASSFISH_DIR/bin/asadmin" list-domains | grep -v Command
  sudo -u glassfish -E "$GLASSFISH_DIR/bin/asadmin" list-domains | grep -q "domain1 running"
  if [ $? -eq 0 ]; then
    sudo -u glassfish -E "$GLASSFISH_DIR/bin/asadmin" uptime | grep -v Command
    echo "\n# Deployed applications:"
    sudo -u glassfish -E "$GLASSFISH_DIR/bin/asadmin" list-applications --long=true --resources | grep -v Command
    echo "\n# JDBC resources:"
    sudo -u glassfish -E "$GLASSFISH_DIR/bin/asadmin" list-jdbc-resources | grep "jdbc/"
  fi
  echo "\n# Derby:"
  sudo -u glassfish -E "$DERBY_BIN/NetworkServerControl" ping | sed "s/^.* : //"
  ;;
*)
  echo "Usage: $0 {start|stop|restart|status}"
  exit 1
  ;;
esac

exit 0