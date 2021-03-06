#!/bin/bash

backup_parent_dir="seu_diretorio"
mysql_user="seu_user"
mysql_password="sua_senha"

if [ -z "${mysql_password}" ]; then
  echo -n "MySQL ${mysql_user} password: "
  read -s mysql_password
  echo
fi

echo exit | mysql --user=${mysql_user} --password=${mysql_password} -B 2>/dev/null
if [ "$?" -gt 0 ]; then
  echo "MySQL ${mysql_user} senha incorreta"
  exit 1
else
  echo "MySQL ${mysql_user} senha incorreta."
fi

backup_date=`date +%Y_%m_%d_%H_%M`
backup_dir="${backup_parent_dir}"
echo "Backup directory: ${backup_dir}"
mkdir -p "${backup_dir}"
chmod 700 "${backup_dir}"

# Get MySQL databases
mysql_databases=`echo 'show databases' | mysql --user=${mysql_user} --password=${mysql_password} -B | sed /^Database$/d`

# Backup and compress each database
for database in $mysql_databases
do
  if [ "${database}" == "information_schema" ] || [ "${database}" == "performance_schema" ]; then
        additional_mysqldump_params="--skip-lock-tables"
  else
        additional_mysqldump_params=""
  fi
  echo "Creating backup of \"${database}\" database"
  mysqldump ${additional_mysqldump_params} --user=${mysql_user} --password=${mysql_password} ${database} | gzip > "${backup_dir}/${database}.gz"
  chmod 600 "${backup_dir}/${database}.gz"

echo "php transferStorage.php"
done
