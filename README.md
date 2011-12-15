Sinatra file server.
========================================================================
Simple sinatra file server. Prepared to use with rvm, capistrano and unicorn.

Steps to install:
-----------------
1. gem install sinatra
2. Rename secret.yml.example to secret.yml and set your secret variable.
3. Rename Capfile.example to Capfile and fill your server parameters.


/etc/init.d/file_server looks like this:

    #! /bin/sh
    ### BEGIN INIT INFO
    # Provides:          file_server
    # Required-Start:    
    # Required-Stop:     
    # Default-Start:     2 3 4 5
    # Default-Stop:      0 1 6
    # Short-Description: Example initscript
    # Description:       This file should be used to construct scripts to be
    #                    placed in /etc/init.d.
    ### END INIT INFO

    # Do NOT "set -e"

    # PATH should only include /usr/* if it runs after the mountnfs.sh script
    RUBY_VERSION=1.9.2-p290
    PATH=/home/deploy/.rvm/gems/ruby-${RUBY_VERSION}/bin:/home/deploy/.rvm/gems/ruby-${RUBY_VERSION}@global/bin:/home/deploy/.rvm/rubies/ruby-${RUBY_VERSION}/bin:/home/deploy/.rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    DESC=""
    NAME=file_server
    APP_DIR=/var/www/$NAME
    DAEMON=/home/deploy/.rvm/gems/ruby-$RUBY_VERSION/bin/unicorn_rails
    DAEMON_ARGS="-c $APP_DIR/current/config/unicorn.rb -D -E production"
    BUNDLE=/home/deploy/.rvm/gems/ruby-$RUBY_VERSION/bin/bundle
    UNICORN_PID=$APP_DIR/shared/unicorn.pid
    SCRIPTNAME=/etc/init.d/$NAME

    # Exit if the package is not installed
    [ -x "$DAEMON" ] || exit 0

    # Read configuration variable file if it is present
    [ -r /etc/default/$NAME ] && . /etc/default/$NAME

    # Load the VERBOSE setting and other rcS variables
    . /lib/init/vars.sh

    # Define LSB log_* functions.
    # Depend on lsb-base (>= 3.0-6) to ensure that this file is present.
    . /lib/lsb/init-functions

    do_start()
    {
    	if [ `whoami` = "deploy" ]; then
    		cd $APP_DIR/current && $BUNDLE exec $DAEMON $DAEMON_ARGS
    	else
    		su - deploy -c "PATH=$PATH cd $APP_DIR/current && \
    			$BUNDLE exec $DAEMON $DAEMON_ARGS"
    	fi
    	return 0
    }

    do_stop()
    {
    	kill `cat $UNICORN_PID`
    }

    #
    # Function that sends a SIGHUP to the daemon/service
    #
    do_reload() {
    	kill -USR2 `cat $UNICORN_PID`
    }

    case "$1" in
      start)
    	[ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
    	do_start
    	case "$?" in
    		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
    		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
    	esac
    	;;
      stop)
    	[ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
    	do_stop
    	case "$?" in
    		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
    		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
    	esac
    	;;
      status)
           status_of_proc "$DAEMON" "$NAME" && exit 0 || exit $?
           ;;
      restart|force-reload)
    	#
    	# If the "reload" option is implemented then remove the
    	# 'force-reload' alias
    	#
    	log_daemon_msg "Restarting $DESC" "$NAME"
    	do_stop
    	case "$?" in
    	  0|1)
    		do_start
    		case "$?" in
    			0) log_end_msg 0 ;;
    			1) log_end_msg 1 ;; # Old process is still running
    			*) log_end_msg 1 ;; # Failed to start
    		esac
    		;;
    	  *)
    	  	# Failed to stop
    		log_end_msg 1
    		;;
    	esac
    	;;
      *)
    	echo "Usage: $SCRIPTNAME {start|stop|status|restart|force-reload}" >&2
    	exit 3
    	;;
    esac
