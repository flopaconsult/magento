#
# Cookbook Name:: magento
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apache2"

if (node.has_key?("magento") && node.magento.has_key?("support_remote_jenkins_webserver_restart") && node.magento.support_remote_jenkins_webserver_restart == 'true')

template "restart webserver run list json" do
  source "restart_webserver.json.erb"
  path "/etc/chef/restart_webserver.json"
  owner "root"
  group "root"
  mode "0644"
end

end  

mysql_host = "localhost"
mysql_pwd = node[:mysql][:server_root_password]

remote_file "/tmp/magento-1.5.1.0.tar.gz" do
  source "http://www.magentocommerce.com/downloads/assets/1.5.1.0/magento-1.5.1.0.tar.gz"
  mode "0644"
  action :create_if_missing
end

execute "untar magento archive" do
  cwd "/tmp"
  command "tar xvf magento-1.5.1.0.tar.gz"
  creates "/tmp/magento"
  action :run
end

bash "prepare magento installation" do
  user "root"
  cwd "/var/www"
  code <<-EOH
    mv /tmp/magento/{,.}* /var/www/
    chown -R www-data.www-data *
    chown www-data:www-data .htaccess*
    find . -type f -exec chmod 644 {} \;
    find . -type d -exec chmod 755 {} \;
    chmod o+w var var/.htaccess app/etc
    chmod 550 mage
    chmod -R o+w media var
  EOH
  not_if "test -d /var/www/mage"
end

    if node.has_key?("elb") && node.elb.has_key?("dnsname")
      server_fqdn = node.elb.dnsname
    else
      if node.has_key?("ec2")
        if node.ec2.has_key?("public_hostname")
          server_fqdn = node.ec2.public_hostname
        else
          server_fqdn = node.ipaddress #VPC
        end
      else
        server_fqdn = node.fqdn
      end
    end

execute "create magento db" do
  command "mysql -h#{mysql_host} -uroot -p#{mysql_pwd} -e 'create database magentodb'"
  action :run
  not_if "mysql -h#{mysql_host} -uroot -p#{mysql_pwd} -e 'show databases' | grep magentodb"
end


bash "magento installation" do
  user "root"
  cwd "/var/www"
  code <<-EOH
    rm -f app/etc/local.xml
    php -f install.php -- \
    --license_agreement_accepted "yes" \
    --locale "en_US" \
    --timezone "America/Los_Angeles" \
    --default_currency "USD" \
    --db_host "#{mysql_host}" \
    --db_name "magentodb" \
    --db_user "root" \
    --db_pass "#{mysql_pwd}" \
    --url "http://#{server_fqdn}/" \
    --skip_url_validation \
    --use_rewrites "yes" \
    --use_secure "yes" \
    --secure_base_url "http://#{server_fqdn}/" \
    --use_secure_admin "yes" \
    --admin_firstname "Admin" \
    --admin_lastname "Admin" \
    --admin_email "admin@mycompany.com" \
    --admin_username "admin" \
    --admin_password "admin123" > /var/www/install.log
  EOH
  not_if "grep SUCCESS /var/www/install.log"
end


execute "enable Apache2 rewrite module" do
  command "a2enmod rewrite"
  action :run
  not_if "apache2ctl -t -D DUMP_MODULES | grep rewrite_module"
end


execute "enable Apache2 headers module" do
  command "a2enmod headers"
  action :run
  not_if "apache2ctl -t -D DUMP_MODULES | grep headers_module"
end


remote_file "/tmp/magento-sample-data-1.1.2.tar.gz" do
  source "http://www.magentocommerce.com/downloads/assets/1.1.2/magento-sample-data-1.1.2.tar.gz"
  mode "0644"
  action :create_if_missing
end

execute "untar magento demo archive" do
  cwd "/tmp"
  command "tar xvf magento-sample-data-1.1.2.tar.gz"
  creates "/tmp/magento-sample-data-1.1.2"
  action :run
end

# Before the demo database can be installed the old datbase has to be deleted
# Afterwards magento has to be installed again in order to create the admin user account.
execute "import magento demo db" do
  command "mysql -h#{mysql_host} -uroot -p#{mysql_pwd} -e 'drop database magentodb;create database magentodb' && mysql -h#{mysql_host} -uroot -p#{mysql_pwd} magentodb < /tmp/magento-sample-data-1.1.2/magento_sample_data_for_1.1.2.sql && rm /var/www/install.log"
  action :run
  not_if "test -d /var/www/media/catalog"
  notifies :run, resources(:bash => "magento installation"), :immediately
end

bash "magento demo installation" do
  user "root"
  cwd "/var/www"
  code <<-EOH
    mv /tmp/magento-sample-data-1.1.2/media/* /var/www/media/
    chown -R www-data.www-data /var/www/media/*
    chmod -R o+w /var/www/media/
  EOH
  not_if "test -d /var/www/media/catalog"
end

