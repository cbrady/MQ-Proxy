# Install hook code here
require 'fileutils'

mq_config = File.dirname(__FILE__) + '/../../../config/mq_proxy_config.yml'
FileUtils.cp File.dirname(__FILE__) + '../config/mq_proxy_config.yml.tpl', mq_config unless File.exist?(mq_config)