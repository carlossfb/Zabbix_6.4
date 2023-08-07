# Mysql Active Monitoring

This repo contains some informations about MYSQL monitoring with Active mode.

### Themes 

![Sistemas](https://img.shields.io/badge/Mysql-Active-blue)

### Requirements
| Name                 | Version |Key and additional info|
|----------------------|---------|-----------------------|
| Zabbix Server        | 6.4     |```Zabbix Server```
| Zabbix Agent  | 6.4     |```Active Checks```, ```ServerActive```

Ps: For each distribution you will follow a slightly different process, I recommend going to the official website to check the package to use


### Tested versions
This case uses Zabbix Server 6.4, and has been tested with Linux by Zabbix Agent 6.4 (active/passive):

- Debian Stretch (9)
- Debian Buster (10)
- Debian Bullseye (11)

### Configuration
 #### Zabbix should be configured according to instructions bellow

### For OS Linux: 

You need create .my.cnf in zabbix-agent home directory (/var/lib/zabbix by default) 
https://dev.mysql.com/doc/refman/5.7/en/option-files.html

#### The file must have three strings:

```vim
[client]
user='zbx_monitor'
password='<password>'
```

After that, copy the template_db_mysql.conf to /etc/zabbix/zabbix_agentd.d (directory) or copy to zabbix conf file. Import mysql_active_templates,yaml and use apply to Host.


## Reference

 - [Zabbix Mysql reference - based on Zabbix Agent 1](https://www.zabbix.com/br/integrations/mysql#mysql_agent)
