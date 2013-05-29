
case node[:platform]
  when "centos"
    package "php-cgi"
    package "php-cli"
    package "php-common"
    package "php-curl"
    package "php-gd"
    package "php-mcrypt"
    package "php-mysql"
    package "php-pear"
#    package "libapache2-mod-php5"
  when "ubuntu"
    package "php5-cgi"
    package "php5-cli"
    package "php5-common"
    package "php5-curl"
    package "php5-gd"
    package "php5-mcrypt"
    package "php5-mysql"
    package "php-pear"
    package "libapache2-mod-php5"
end

