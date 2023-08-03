#!/bin/sh
 
# PROVIDE: zabbix_agentd
# REQUIRE: DAEMON
# KEYWORD: shutdown
#
# Add the following lines to /etc/rc.conf.local or /etc/rc.conf to
# enable zabbix_agentd:
#
# zabbix_agentd_enable (bool): Set to NO by default.  Set it to YES to
#         enable zabbix_agentd.
#
 
. /etc/rc.subr
 
name="zabbix_agentd"
rcvar=zabbix_agentd_enable
start_precmd="zabbix_precmd"
required_files="/etc/zabbix/zabbix_agentd.conf"
 
# read configuration and set defaultsc
load_rc_config "$name"
: ${zabbix_agentd_enable="NO"}
#: ${zabbix_agentd_pre:=/etc/${name}.pre.sh}
 
zabbix_agentd_conf="/etc/zabbix/zabbix_agentd.conf"
 
if [ ! -z "$zabbix_agentd_conf" ] ; then
  zabbix_agentd_flags="${zabbix_agentd_flags} -c ${zabbix_agentd_conf}"
  required_files=${zabbix_agentd_conf}
fi
 
zabbix_precmd()
{
  if [ ! -z "$zabbix_agentd_pre" ] ; then
    if [ -e $zabbix_agentd_pre ] ; then
      . $zabbix_agentd_pre
    fi
  fi
}
 
command="/usr/local/sbin/${name}"
 
run_rc_command "$1"  run_rc_command "$1"
