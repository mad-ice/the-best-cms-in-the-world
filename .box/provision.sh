##
# Pre-provisioning
##


# Start with a freshly updated repository list.
sudo apt-get update -y

# Install generally required packages.
sudo apt-get install python-software-properties -y
sudo apt-get install software-properties-common -y


##
# cURL
##


sudo apt-get install curl -y


##
# Apache
##


APACHE_SITES_AVAILABLE_PATH="/etc/apache2/sites-available"
APACHE_SITES_ENABLED_PATH="/etc/apache2/sites-enabled"

# Install Apache's package.
sudo apt-get install apache2 -y

# Enable required mods.
sudo a2enmod rewrite

sudo cat <<EOT >> $APACHE_SITES_AVAILABLE_PATH/the-best-cms-in-the-world.local.conf
<VirtualHost *:80>
    ServerName the-best-cms-in-the-world.local
	DocumentRoot "/var/www/html/project/public"
	
	<Directory "/var/www/html/project/public">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOT

# Make sure Apache's "sites-enabled" directory is removed so that we can create a symlink to it later.
sudo rm -rf $APACHE_SITES_ENABLED_PATH

# Enable all available sites.
ln -s $APACHE_SITES_AVAILABLE_PATH $APACHE_SITES_ENABLED_PATH

sudo service apache2 restart


##
# MariaDB
##


DATABASE_COLLATION="utf8mb4_unicode_ci"
DATABASE_NAME="the-best-cms-in-the-world"
DATABASE_PASSWORD="secret"
MARIADB_VERSION="10.3"

# Add MariaDB's repository
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
sudo add-apt-repository "deb [arch=amd64,i386,ppc64el] http://ams2.mirrors.digitalocean.com/mariadb/repo/$MARIADB_VERSION/ubuntu xenial main"

# Update the repository list
sudo apt update -y

# Predefine MariaDB's password to prevent prompts from being shown.
sudo debconf-set-selections <<< "mariadb-server mysql-server/root_password password $DATABASE_PASSWORD"
sudo debconf-set-selections <<< "mariadb-server mysql-server/root_password_again password $DATABASE_PASSWORD"

# Install MariaDB's server package
sudo apt-get install mariadb-server -y

# Enable remote access
sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

# Restart MySQL's service to apply remove access changes.
sudo service mysql restart

# adding grant privileges to mysql root user from everywhere
# thx to http://stackoverflow.com/questions/7528967/how-to-grant-mysql-privileges-in-a-bash-script for this
mysql -uroot -p$DATABASE_PASSWORD -e "GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '$DATABASE_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES;"

# Create the database
mysql -uroot -p$DATABASE_PASSWORD -e "CREATE DATABASE \`$DATABASE_NAME\` /*!40100 COLLATE '$DATABASE_COLLATION' */;"


##
# PHP
##


# Fetch PHP repositories
sudo add-apt-repository ppa:ondrej/php -y
sudo apt-get update -y

# Install PHP packages.
sudo apt-get install php7.2 -y
sudo apt-get install php7.2-bcmath -y
sudo apt-get install php7.2-cli -y
sudo apt-get install php7.2-common -y
sudo apt-get install php7.2-mbstring -y
sudo apt-get install php7.2-mysql -y
sudo apt-get install php7.2-xml -y
sudo apt-get install php7.2-zip -y
sudo apt-get install php7.2-fpm -y
sudo apt-get install php-curl -y


##
# COMPOSER
##


curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


##
# Xdebug
##


# Fetch the currently installed PHP version
FULL_PHP_VERSION="$(php -r "echo PHP_VERSION;")"
SHORT_PHP_VERSION="$(echo ${FULL_PHP_VERSION} | sed -E 's/^([0-9]+\.[0-9]+).*/\1/g')"
XDEBUG_INI_PATH=/etc/php/$SHORT_PHP_VERSION/mods-available/xdebug.ini

# Configure Xdebug options
declare -A OPTIONS

OPTIONS[xdebug.default_enable]="1"
OPTIONS[xdebug.idekey]="PHPSTORM"
OPTIONS[xdebug.remote_enable]="1"
OPTIONS[xdebug.remote_host]="10.0.2.2"
OPTIONS[xdebug.remote_port]="9000"
OPTIONS[xdebug.show_error_trace]="1"

# Install Xdebug
sudo apt-get install php-xdebug

# Enable all configured options
for OPTION in "${!OPTIONS[@]}"; do
	VALUE="${OPTIONS[$OPTION]}"
	
	if grep $OPTION $XDEBUG_INI_PATH
	then
		sudo sed -iE "s/$OPTION.*/$OPTION \= $VALUE/g" $XDEBUG_INI_PATH
	else
		echo "$OPTION = $VALUE" | sudo tee -a $XDEBUG_INI_PATH
	fi
done


##
# MIDNIGHT COMMANDER
##


sudo apt-get install mc -y


##
# Node.js
##


# Fetch the setup.
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

# Install the package.
sudo apt-get install nodejs -y


##
# Yarn
##


# Fetch Yarn's repository.
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# Update the local repository list.
sudo apt-get update -y

# Install Yarn's package.
sudo apt-get install yarn -y


##
# Post-provisioning
##


# Remove any leftover unused packages.
sudo apt-get autoremove -y

# Restart the Apache webserver to apply PHP installation
sudo service apache2 restart
