cat .setup 2>/dev/null

if [ $? -ne 0 ]; then

    mariadb-install-db --datadir=/var/lib/mysql \
        --auth-root-authentication-method=normal

    chown -R mysql:mysql /var/lib/mysql
    chown -R mysql:mysql /run/mysqld

    mysqld_safe --datadir=/var/lib/mysql &

    while ! mysqladmin ping -h "mariadb" --silent; do
        sleep 1
    done
    eval "echo \"$(cat /tmp/create_db.sql)\"" | mariadb
    touch .setup
else
    echo "Database is already created"
fi

mysqld_safe --datadir=/var/lib/mysql
