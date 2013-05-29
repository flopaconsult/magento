# mysql adjustments for magento - create magento user; TODO: later on, load the user from data bags

template "/tmp/mysql_user_magento.sql" do
  source "mysql_user_magento.sql.erb"
end

bash "mysql_magento_settings" do

  not_if("/usr/bin/mysql -uroot -p#{node[:mysql][:server_root_password]} mysql -e'select user from user' | grep magento", :user => 'root')
  user "root"
  code <<-EOH
    /usr/bin/mysql -uroot -p#{node[:mysql][:server_root_password]} < /tmp/mysql_user_magento.sql
  EOH
end
