#require File.expand_path('../support/helpers', __FILE__)

describe 'magento::webonly' do



 it 'creates the MY OWN directory' do
    directory("/etc/chef").must_exist
  end
  
end
