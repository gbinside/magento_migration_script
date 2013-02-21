#!/bin/bash

REMOTE_HOST="www.mymagentostore.com"
REMOTE_SSH_PORT="22"
REMOTE_SSH_USERNAME=""
REMOTE_MYSQL_HOSTNAME=""
REMOTE_MYSQL_USERNAME=""
REMOTE_MYSQL_PASSWORD=""
REMOTE_MYSQL_DATABASE=""
REMOTE_FILES_PATH="/remote/path/to/magento"
REMOTE_MAGENTO_UNSECURE_URL="http://www.mymagentostore.com"
REMOTE_MAGENTO_SECURE_URL="http://www.mymagentostore.com"

LOCAL_MYSQL_HOSTNAME="localhost"
LOCAL_MYSQL_USERNAME=""
LOCAL_MYSQL_PASSWORD=""
LOCAL_MYSQL_DATABASE="" # Local MySQL database must exist on local MySQL!
LOCAL_FILES_PATH="/local/path/to/magento" # Local files path must exist!
LOCAL_MAGENTO_UNSECURE_URL="http://mymagentostore.local"
LOCAL_MAGENTO_SECURE_URL="http://mymagentostore.local"

if ! cd $LOCAL_FILES_PATH; then
    echo "Error: $LOCAL_FILES_PATH doesn't exists!"
    exit
fi

echo ""
echo "**************************************"
echo "****** Migrating MySQL database ******"
echo "**************************************"
echo ""

echo "Dumping remote database, please wait..."
ssh $REMOTE_SSH_USERNAME@$REMOTE_HOST -p$REMOTE_SSH_PORT "mysqldump -u $REMOTE_MYSQL_USERNAME -p$REMOTE_MYSQL_PASSWORD --quote-names --opt --hex-blob $REMOTE_MYSQL_DATABASE > /tmp/dump.sql"
echo "Downloading remote database dump..."
scp -P $REMOTE_SSH_PORT $REMOTE_SSH_USERNAME@$REMOTE_HOST:/tmp/dump.sql /tmp/dump.sql
echo "Restoring database locally, please wait..."
sed -i -e "s/\/\*\!50013 DEFINER=\`\w+\`@\`.*?\` SQL SECURITY DEFINER \*\///g" /tmp/dump.sql
REMOTE_MAGENTO_UNSECURE_URL="$(echo "$REMOTE_MAGENTO_UNSECURE_URL" | sed 's/[^[:alnum:]_-]/\\&/g')"
REMOTE_MAGENTO_SECURE_URL="$(echo "$REMOTE_MAGENTO_SECURE_URL" | sed 's/[^[:alnum:]_-]/\\&/g')"
LOCAL_MAGENTO_UNSECURE_URL="$(echo "$LOCAL_MAGENTO_UNSECURE_URL" | sed 's/[^[:alnum:]_-]/\\&/g')"
LOCAL_MAGENTO_SECURE_URL="$(echo "$LOCAL_MAGENTO_SECURE_URL" | sed 's/[^[:alnum:]_-]/\\&/g')"
sed -i -e "s/${REMOTE_MAGENTO_UNSECURE_URL}/${LOCAL_MAGENTO_UNSECURE_URL}/g" /tmp/dump.sql
sed -i -e "s/${REMOTE_MAGENTO_SECURE_URL}/${LOCAL_MAGENTO_SECURE_URL}/g" /tmp/dump.sql
mysql -u $LOCAL_MYSQL_USERNAME -p$LOCAL_MYSQL_PASSWORD $LOCAL_MYSQL_DATABASE < /tmp/dump.sql

echo ""
echo "**************************************"
echo "*********** Migrating files **********"
echo "**************************************"
echo ""

echo "Creating tarball with remote files, please wait..."
ssh $REMOTE_SSH_USERNAME@$REMOTE_HOST -p$REMOTE_SSH_PORT "cd $REMOTE_FILES_PATH && tar --checkpoint=100 --checkpoint-action=dot -czf /tmp/files.tar.gz . "
echo ""
echo "Downloading remote tarball..."
scp -P $REMOTE_SSH_PORT $REMOTE_SSH_USERNAME@$REMOTE_HOST:/tmp/files.tar.gz /tmp/files.tar.gz
echo "Exctracting tarball locally, please wait..."
if ! cd $LOCAL_FILES_PATH; then
    exit "Error: $LOCAL_FILES_PATH doesn't exists!";
fi
tar -xzf /tmp/files.tar.gz
echo "Fixing files permissions..."
if ! cd $LOCAL_FILES_PATH; then
    exit "Error: $LOCAL_FILES_PATH doesn't exists!";
fi
cd $LOCAL_FILES_PATH
find . -type f -print0 | xargs -0 chmod 644
find . -type d -print0 | xargs -0 chmod 755
echo "Fixing Magento configuration..."
sed -i -e "s/$REMOTE_MYSQL_USERNAME/$LOCAL_MYSQL_USERNAME/g" $LOCAL_FILES_PATH/app/etc/local.xml
sed -i -e "s/<password><!\[CDATA\[$REMOTE_MYSQL_PASSWORD\]\]><\/password>/<password><![CDATA[$LOCAL_MYSQL_PASSWORD]]><\/password>/g" $LOCAL_FILES_PATH/app/etc/local.xml
sed -i -e "s/$REMOTE_MYSQL_HOSTNAME/$LOCAL_MYSQL_HOSTNAME/g" $LOCAL_FILES_PATH/app/etc/local.xml

echo ""
echo "**************************************"
echo "*************** DONE!!! **************"
echo "**************************************"