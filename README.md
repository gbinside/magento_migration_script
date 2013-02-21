Magento Migration Script
========================

This simple bash script allows to migrate a remote running copy of a Magento store on a local machine where it's executed.


Parameters:
-----------

* **REMOTE_HOST**: the hostname (or IP address) of the remote machine
* **REMOTE_SSH_PORT**: the port used for SSH connections to remote machine
* **REMOTE_SSH_USERNAME**: the username used for SSH connection
* **REMOTE_MYSQL_HOSTNAME**: the hostname of MySQL server used by remote Magento installation
* **REMOTE_MYSQL_USERNAME**: the username used for remote MySQL connection
* **REMOTE_MYSQL_PASSWORD**: the password used for remote MySQL connection
* **REMOTE_MYSQL_DATABASE**: the database name used by remote Magento installation
* **REMOTE_FILES_PATH**: the directory path that contains remote Magento installation root
* **REMOTE_MAGENTO_UNSECURE_URL**: the Unsecure URL of remote Magento installation
* **REMOTE_MAGENTO_SECURE_URL**: the Secure URL of remote Magento installation
* **LOCAL_MYSQL_HOSTNAME**: the hostname used for local MySQL connection
* **LOCAL_MYSQL_USERNAME**: the username used for local MySQL connection
* **LOCAL_MYSQL_PASSWORD**: the password used for local MySQL connection
* **LOCAL_MYSQL_DATABASE**: the database name that will be used by local Magento installation. The database must already exists on local MySQL server!
* **LOCAL_FILES_PATH**: the directory path that will contains local Magento installation. This directory must already exists and should be empty!
* **LOCAL_MAGENTO_UNSECURE_URL**: the Unsecure URL of local Magento installation
* **LOCAL_MAGENTO_SECURE_URL**: the Secure URL of local Magento installation


Requirements:
-------------

* Remote machine must run GNU Unix based system.
* Remote machine must run an SSH server.