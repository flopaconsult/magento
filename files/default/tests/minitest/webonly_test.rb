require File.expand_path('../helpers', __FILE__)
describe 'magento::webonly' do
include Helpers::magento


 it 'creates the MY OWN directory' do
    directory("/etc/chef").must_exist
  end
  
end
