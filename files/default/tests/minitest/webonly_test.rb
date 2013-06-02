require File.expand_path('../helpers', __FILE__)
describe 'magento::webonly' do
include Helpers::Magento
include Helpers::Apache


  it 'creates the MY OWN directory' do
    directory("/etc/chef").must_exist
  end
  
  it 'checks if file /etc/chef/restart_webserver.json. created by template exists' do 
      file("/etc/chef/restart_webserver.json").must_exist
  end
  
    it 'listens on port 80' do
    apache_configured_ports.must_include(80)
  end
  
%w{
mysql-client
libmysqlclient-dev
}.each do |mysql_client_package|
  
  it "installs #{mysql_client_package}" do
    package(mysql_client_package).must_be_installed
  end
  
  end
  
%w{
core
http
php5
}.each do |expected_module|

  describe "apache2::mod_#{expected_module}" do
    include Helpers::Apache

    it "installs mod_#{expected_module}" do
      apache_enabled_modules.must_include "#{expected_module}_module"
    end

  end
end  
  
end
