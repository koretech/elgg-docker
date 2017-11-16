#!/bin/sh
set -e

WAIT_MYSQL_START="30" # In seconds

#wait for mysql
i=0
while ! netcat $ELGG_DB_HOST $ELGG_DB_PORT >/dev/null 2>&1 < /dev/null; do
  i=`expr $i + 1`
  if [ $i -ge $MYSQL_LOOPS ]; then
    echo "$(date) - ${ELGG_DB_HOST}:${ELGG_DB_PORT} still not reachable, giving up."
    exit 1
  fi
  echo "$(date) - waiting for ${ELGG_DB_HOST}:${ELGG_DB_PORT}... $i/$WAIT_MYSQL_START."
  sleep 1
done
echo "The MySQL server is ready."

echo "Starting installation elgg."
#This directory will hold Elgg's ``settings.php`` file after installation.
if [ ! -d "${ELGG_PATH}elgg-config/" ]; then
	mkdir "${ELGG_PATH}elgg-config/"
	chown -R www-data:www-data "${ELGG_PATH}elgg-config/"
fi

# Dependencies install
if [ ! -f "${ELGG_PATH}vendor/autoload.php" ]; then
	echo 'File vendor/autoload.php does not exist.'
	echo 'Running composer install'
	composer install --prefer-source
fi

mkdir -p $ELGG_DATA_ROOT
chmod -R 770 "${ELGG_DATA_ROOT}" 
chown -R www-data:www-data "${ELGG_DATA_ROOT}"

sed -i "s/^mailhub=.*$/mailhub=${ELGG_MAIL_RELAY}/g" /etc/ssmtp/ssmtp.conf

php	/elgg/elgg-install.php
