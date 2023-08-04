
# Linux monitoring with Zabbix 6.4

This repo contains some informations about Linux monitoring with Passive or Active modes.

### Themes 

![Sistemas](https://img.shields.io/badge/Linux-Passive-blue)
![Sistemas](https://img.shields.io/badge/Linux-Active-green)


### Requirements
| Name                 | Version |Key and additional info|
|----------------------|---------|-----------------------|
| Zabbix Server        | 6.x     |```Zabbix Server```
| Zabbix Agent Package | 5.x     |```Package```

Ps: For each distribution you will follow a slightly different process, I recommend going to the official website to check the package to use


### Tested versions
This case uses Zabbix Server 6.4, and has been tested with Linux by Zabbix Agent 6.4 (active/passive):

- Debian Stretch (9)
- Debian Buster (10)
- Debian Bullseye (11)

### Configuration
 #### Zabbix should be configured according to instructions bellow

### (Example with Debian 11)
#### Download Zabbix sources and unzip them 
```bash
wget https://repo.zabbix.com/zabbix/6.4/debian/pool/main/z/zabbix-release/zabbix-release_6.4-1+debian11_all.deb
dpkg -i zabbix-release_6.4-1+debian11_all.deb
apt update
```

#### Install Zabbix Agent
```bash 
apt install zabbix-agent
```

#### Edit Zabbix Agent
```bash 
sed -i 's/Server=127.0.0.1/Server=ipServerHere/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/ServerActive=127.0.0.1/ServerActive=ipServerHere/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/Hostname=Zabbix server/Hostname=hostnameClientHere/' /etc/zabbix/zabbix_agentd.conf
```


#### Enable and Start Zabbix Agent
```bash 
systemctl restart zabbix-agent
systemctl enable zabbix-agent
```
#### Now you need to create your Host in Zabbix Server interface...

- For Active Profile: Create Host and add the SAME Hostname (Yes, exactly the same Hostname in **Zabbix Conf**), finally add template for zabbix agent active

- For Passive Profile: Create Host and add one interface as Agent, need to indicate your client's IP, prepare to configure one or more rules for port default 10050 **exclusively for Zabbix Server** connect to you, finally add template by zabbix agent

## Reference

 - [Install reference](https://www.zabbix.com/download?zabbix=6.4&os_distribution=debian&os_version=11&components=agent&db=&ws=)
