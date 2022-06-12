#!/bin/bash

set -e

if [ -v PASSWORD_FILE ]; then
    PASSWORD="$(< $PASSWORD_FILE)"
fi

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${ODOO_DB_HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${ODOO_DB_PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${ODOO_DB_USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${ODOO_DB_PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}
: ${ODOO_SERVER_WIDE_MODULES:='web'}

DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then       
        value=$(grep -E "^\s*\b${param}\b\s*=" "$ODOO_RC" |cut -d " " -f3|sed 's/["\n\r]//g')
    fi;
    DB_ARGS+=("--${param}")
    DB_ARGS+=("${value}")
}


echo "============= SED ==================="
sed -i -e "s/db_host =.*/db_host = $ODOO_DB_HOST/" "$ODOO_RC"
sed -i -e "s/db_user =.*/db_user = $ODOO_DB_USER/" "$ODOO_RC"
sed -i -e "s/db_password =.*/db_password = $ODOO_DB_PASSWORD/" "$ODOO_RC"
sed -i -e "s/; server_wide_modules =.*/server_wide_modules = $ODOO_SERVER_WIDE_MODULES/" "$ODOO_RC"


check_config "db_host" "$ODOO_DB_HOST"
check_config "db_port" "$ODOO_DB_PORT"
check_config "db_user" "$ODOO_DB_USER"
check_config "db_password" "$ODOO_DB_PASSWORD"


export PGUSER=$ODOO_DB_USER
export PGPASSWORD=$ODOO_DB_PASSWORD
export PGHOST=$ODOO_DB_HOST
export PGPORT=$ODOO_DB_PORT

export MARABUNTA_DATABASE=demo
export MARABUNTA_DB_USER=$ODOO_DB_USER
export MARABUNTA_DB_PASSWORD=$ODOO_DB_PASSWORD
export MARABUNTA_DB_HOST=$ODOO_DB_HOST
export MARABUNTA_MODE=base

export DEFAULTDB=postgres

function drop() {
    echo "$PGHOST"
    echo "Dropping $1"
    dropdb --if-exists --maintenance-db=$DEFAULTDB $1
    echo "Database $1 has been dropped"
}

function create() {
  echo "Start create function"
  EXIST=$(psql -X -A -t $DEFAULTDB -c "SELECT 1 AS result FROM pg_database WHERE datname = '$1'";)
  if [ "$EXIST" != "1" ]; then
    echo "Creating $1"
    createdb --maintenance-db=$DEFAULTDB $1
  fi
}

case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec odoo "$@"
        else
            echo "${DB_ARGS[@]}"
            wait-for-psql.py ${DB_ARGS[@]} --timeout=30
            echo "DB: Ready"
            drop demo
            create demo
            sed -i -e "s/; db_name =.*/db_name = $MARABUNTA_DATABASE/" "$ODOO_RC"
            gosu odoo marabunta -f /migration.yml
            sed -i -e "s/db_name =.*/; db_name = $MARABUNTA_DATABASE/" "$ODOO_RC"
            echo "Migration Finished"
            exec gosu odoo odoo "$@" "${DB_ARGS[@]}"
        fi
        ;;
    -*)
        wait-for-psql.py ${DB_ARGS[@]} --timeout=30
        exec gosu odoo odoo "$@" "${DB_ARGS[@]}"
        ;;
    *)
        exec "$@"
esac

exit 1