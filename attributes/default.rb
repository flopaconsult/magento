# this flag defines if magento supports remote ssh command to restart web servers through Jenkins
# it only creates a /etc/chef/restart_webserver.json file to be used remotely by jenkins
# By default this should be set to false and then overwritten from a role
# for testing purposes I let it true now
default['magento']['support_remote_jenkins_webserver_restart']='true'
