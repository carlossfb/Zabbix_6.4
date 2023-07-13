#!/bin/bash
# Para utilizar o script deverá na secao ZABBIX SERVER indicar qual senha utilizara no usuario mysql do Zabbix
# Criador: Carlos Eduardo (github:carlossfb)
# Atualizado: 27.06.2023

echo "==============Instalador Zabbix 6.4====================="
echo "________________________________________________________"
echo " " 
echo "Instalando dependencia: MYSQL 8.0"
sleep 2
apt update && apt upgrade ; wget https://dev.mysql.com/get/mysql-apt-config_0.8.22-1_all.deb || apt-get install wget && wget https://dev.mysql.com/get/mysql-apt-config_0.8.22-1_all.deb; apt install ./mysql-apt-config_0.8.22-1_all.deb 
apt update && apt install mysql-server

# Nao recomendo utilizar variaveis para setar a senha direto no shell, mas vou deixar a declaracao
# declare -r MYSQL_PASSWD_ROOT="SuaSenha@123"
# note que para utilizar em algum lugar deste script precisara indicar como $MYSQL_PASSWD_ROOT

# PARTE 1 = MYSQL SERVER
# Baixar os pacotes do Zabbix para instalacao do Agent, Server e FrontEnd
wget https://repo.zabbix.com/zabbix/6.4/debian/pool/main/z/zabbix-release/zabbix-release_6.4-1+debian11_all.deb 
dpkg -i zabbix-release_6.4-1+debian11_all.deb

# Atualizar lista de repositorios
apt update

# PARTE 2 = ZABBIX SERVER
apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent -y

echo "Vamos configurar o usuario do zabbix e o banco de dados, digite a senha do root:"
mysql -u root -p mysql -e "create database zabbix character set utf8mb4 collate utf8mb4_bin; create user zabbix@localhost identified by '<password>';grant all privileges on zabbix.* to zabbix@localhost;set global log_bin_trust_function_creators = 1;"

echo "Precisamos agora da senha do usuario zabbix que indicou para o banco, verifique o script se necessario:"
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix

echo "Digite a senha do root mysql para finalizar alguns ajustes"
mysql -u root -p -e "set global log_bin_trust_function_creators = 0;"

echo "Estamos agora alterando o arquivo /etc/zabbix/zabbix_server.conf"
echo "Parametros alterados: DBPassword"
sed -i 's/# DBPassword=/DBPassword=Senha@2023/' /etc/zabbix/zabbix_server.conf

systemctl restart zabbix-server zabbix-agent apache2 ; systemctl enable zabbix-server zabbix-agent apache2
echo "====================Zabbix 6.4 - script finalizado=================="
echo "O sucesso deste script implica que o Zabbix server esta no endereco http://seuip/zabbix, usuário de login Admin e senha zabbix!"
