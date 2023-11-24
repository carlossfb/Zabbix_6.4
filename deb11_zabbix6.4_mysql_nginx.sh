#!/bin/bash

# Nome do arquivo de log
LOG_FILE="install_log.txt"

# Funcao para exibir mensagem de erro e sair
function exibir_erro {
    echo "Erro: $1"
    exit 1
}
# Função para solicitar senhas de forma segura
function solicitar_senha {
    local senha
    read -s -p "$1: " senha
    echo "$senha"
}

if systemctl is-active --quiet apache2; then
    echo "Apache2 esta em execucao. Desabilitando e parando o processo para evitar conflitos com nginx..."
    sleep 5
    # Desabilitar o Apache2
    systemctl disable apache2

    # Parar o servico Apache2
    systemctl stop apache2

    echo "Apache2 desabilitado e processo parado com sucesso."
else
    echo "Apache2 nao esta em execucao. Continuando..."
fi


echo "==============Instalador Zabbix 6.4====================="
echo "________________________________________________________"
echo " " 


# Verifica se o wget esta instalado
if ! command -v wget &> /dev/null; then
    echo "Instalando wget..."
    apt-get update && apt-get install -y wget >> "$LOG_FILE" 2>&1
fi

# Verifica se o MySQL ja esta instalado
if command -v mysql &> /dev/null; then
    echo "MySQL ja esta instalado. Pulando a instalacao do banco de dados."
    sleep 5
else
    echo "Instalando dependencia: MYSQL 8.0"
    sleep 2

    # Instalando o MySQL APT Config
    apt update && apt upgrade ; wget https://dev.mysql.com/get/mysql-apt-config_0.8.22-1_all.deb ; apt install ./mysql-apt-config_0.8.22-1_all.deb 
    dpkg -i /tmp/mysql-apt-config.deb
    apt-get update -y

    # Instalando o MySQL Server
    apt-get install -y mysql-server >> "$LOG_FILE" 2>&1

    # Verifica se a instalacao do MySQL foi bem-sucedida
    if [ $? -ne 0 ]; then
        exibir_erro "Erro durante a instalacao do MySQL. Consulte o arquivo de log '$LOG_FILE' para mais detalhes."
    else
        echo "MySQL Community 8.0 instalado com sucesso!"
    fi
fi

#Instalando o Zabbix
# Verificacoes e instalacao do Zabbix
if command -v zabbix_server &> /dev/null; then
    echo "Zabbix ja esta instalado. Pulando a instalacao."
    sleep 5
else
    echo "Instalando o Zabbix..."
    
    wget https://repo.zabbix.com/zabbix/6.4/debian/pool/main/z/zabbix-release/zabbix-release_6.4-1+debian11_all.deb
    dpkg -i zabbix-release_6.4-1+debian11_all.deb

    apt-get update && apt-get install -y zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent

    # Verifica se a instalacao do Zabbix foi bem-sucedida
    if [ $? -ne 0 ]; then
        exibir_erro "Erro durante a instalacao do Zabbix. Consulte o arquivo de log '$LOG_FILE' para mais detalhes."
    else
        echo "Zabbix instalado com sucesso!"
    fi
fi

# Solicitar senhas
ZABBIX_PASSWORD=$(solicitar_senha "Digite a senha para o usuario 'zabbix'")
echo " "

# Configuracao do banco de dados
mysql -u root mysql -e "create database zabbix character set utf8mb4 collate utf8mb4_bin; create user zabbix@localhost identified by '$ZABBIX_PASSWORD'; grant all privileges on zabbix.* to zabbix@localhost; set global log_bin_trust_function_creators = 1;"

# Importar estrutura do banco de dados
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p"$ZABBIX_PASSWORD" zabbix

# Desativar o log_bin_trust_function_creators apos a importacao
mysql -u root -e "set global log_bin_trust_function_creators = 0;"

# Modificar o arquivo de configuracao do Zabbix
echo "Estamos agora alterando o arquivo /etc/zabbix/zabbix_server.conf"

echo "Parametros alterados: DBPassword"
sed -i "s/# DBPassword=/DBPassword=$ZABBIX_PASSWORD/" /etc/zabbix/zabbix_server.conf
sed -i "s/^\s*#*\s*listen\s*8080;/listen 8080;/" /etc/zabbix/nginx.conf

systemctl restart zabbix-server zabbix-agent nginx php7.4-fpm ; systemctl enable zabbix-server zabbix-agent nginx php7.4-fpm

echo "Configuracao concluida com sucesso! Lembre de definir uma senha para o root do mysql"
ip a | awk '/inet .*enp0s3/{print "Zabbix Running in(port 8080): "$2}' | cut -d '/' -f 1


# Script concluido com sucesso
exit 0
