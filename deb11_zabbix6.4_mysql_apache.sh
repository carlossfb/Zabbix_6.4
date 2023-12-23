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


echo "==============Instalador Zabbix 6.4====================="
echo "________________________________________________________"
echo " " 

#!/bin/bash

# Nome do arquivo de log
LOG_FILE="install_log.txt"

# Funcao para exibir mensagem de erro e sair
function exibir_erro {
    echo "Erro: $1"
    exit 1
}
# Funcao para solicitar senhas de forma segura
function solicitar_senha {
    local senha
    read -s -p "$1: " senha
    echo "$senha"
}

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

    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B7B3B788A8D3785C
    apt install gnupg
    # Instalando o MySQL APT Config
    apt update && apt upgrade ; wget http://repo.mysql.com/mysql-apt-config_0.8.13-1_all.deb -O mysql-apt-config.deb
    dpkg -i ./mysql-apt-config.deb
    dpkg-reconfigure mysql-apt-config
    apt-get update && apt upgrade

    # Instalando o MySQL Server
    echo "Tentando instalar o mysql server, aguarde..."
    apt-get install mysql-server

    # Verifica se a instalacao do MySQL foi bem-sucedida
    if [ $? -ne 0 ]; then
        exibir_erro "Erro durante a instalacao do MySQL."
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

    apt-get update && apt-get install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

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
MYSQL_PASSWORD=$(solicitar_senha "Digite a senha para o 'root' do mysql")

echo "Aguarde que estamos ajustando algumas configurações"

# Configuracao do banco de dados
mysql -u root -p$MYSQL_PASSWORD mysql -e "create database zabbix character set utf8mb4 collate utf8mb4_bin; create user zabbix@localhost identified by '$ZABBIX_PASSWORD'; grant all privileges on zabbix.* to zabbix@localhost; set global log_bin_trust_function_creators = 1;"

# Importar estrutura do banco de dados
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p"$ZABBIX_PASSWORD" zabbix

# Desativar o log_bin_trust_function_creators apos a importacao
mysql -u root -p$MYSQL_PASSWORD -e "set global log_bin_trust_function_creators = 0;"

# Modificar o arquivo de configuracao do Zabbix
echo "Estamos agora alterando o arquivo /etc/zabbix/zabbix_server.conf"

echo "Parametros alterados: DBPassword"
sed -i "s/# DBPassword=/DBPassword=$ZABBIX_PASSWORD/" /etc/zabbix/zabbix_server.conf


systemctl restart zabbix-server zabbix-agent apache2 ;systemctl enable zabbix-server zabbix-agent apache2

echo "Configuracao concluida com sucesso! Lembre de definir uma senha para o root do mysql"
ip a | awk '/inet .*enp0s3/{print "Zabbix Running in: "$2}' | cut -d '/' -f 1


# Script concluido com sucesso
exit 0
