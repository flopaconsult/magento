require File.expand_path('../helpers', __FILE__)
describe 'magento::webonly' do
include Helpers::Magento
include Helpers::Apache

%w{
php5-cgi
php5-cli
php5-common
php5-curl
php5-gd
php5-mcrypt
php5-mysql
php-pear
libapache2-mod-php5
}.each do |expected_package|

  it 'installs #{expected_package}' do
    package("#{expected_package}").must_be_installed
  end
end





  
end
