
# FreeBSD monitoring with Zabbix 6.4

This script is designed for the effortless deployment of NAS (FreeBSD, TrueNas) monitoring by Zabbix via Zabbix agent and support with install requirements


### Support 

![Sistemas](https://img.shields.io/badge/FreeBSD-NAS-blue)
![Sistemas](https://img.shields.io/badge/TrueNAS-NAS-green)


### Requirements
|Name|Version|Key and additional info|
|----|-----------|-----------------------|
|Zabbix Server|5.4+|```Zabbix Server```
|Zabbix Agent Source |5.4+|```Pre-compiled```, ```sources```

### Tested versions
This case uses Zabbix Agent 5.4 source and has been tested with Linux by Zabbix Agent 6.4 (active/passive):

- FreeBSD 12.2

### Configuration
 #### Zabbix should be configured according to instructions bellow

### Create source Zabbix Agent folder
```bash
mkdir /etc/zabbix; cd /etc/zabbix
```
### Download Zabbix sources and unzip them
```bash
wget https://cdn.zabbix.com/zabbix/binaries/stable/5.4/5.4.10/zabbix_agent-5.4.10-freebsd-11.2-amd64-gnutls.tar.gz
tar -xvzf zabbix_agent-5.4.10-freebsd-11.2-amd64-gnutls.tar.gz
```
### Copy unzipped binaries
```bash
cp sbin/* /usr/local/sbin
cp bin/* /usr/local/bin
cp -Rf conf/* .
```
### Edit Zabbix Agent
```bash
cp /conf/zabbix_agentd.conf . 
sed -i 's/Server=127.0.0.1/Server=172.31.9.154/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/ServerActive=127.0.0.1/ServerActive=172.31.9.154/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/Hostname=Zabbix server/Hostname=nas/' /etc/zabbix/zabbix_agentd.conf
```
### Enable DAEMON zabbix in rc.conf, add "zabbix_agentd_enable=YES"
```bash
echo 'zabbix_agentd_enable="YES"' >> /etc/rc.conf
```
### Create The following config file (or copy and paste the example zabbix_agentd script in this repository)
```bash
sudo touch /etc/rc.d/zabbix_agentd
```
### Make executable
```bash
chmod +x /etc/rc.d/zabbix_agentd
```
### Persist Zabbix Agent configuration
```bash
cp /etc/rc.conf /conf/base/etc/ ; cp /etc/rc.d/zabbix_agentd /conf/base/etc/rc.d/
```
### Create a directory to indicate zabbix_agentd.conf as soft link
```
mkdir /conf/etc/zabbix ; cd /conf/etc/zabbix
ln -s /etc/zabbix/zabbix_agentd.conf zabbix_agentd.conf
 ```

## Referência

 - [Install reference](https://lucasatrindade.wordpress.com/2021/05/13/instalando-o-zabbix-agente-no-truenas/)
