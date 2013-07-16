CURRENT_DIR = File.dirname(__FILE__)

require 'webruby/app'
require 'webruby/config'
require 'webruby/environment'
require 'webruby/utility'

# load rake tasks
require 'rake'
Dir.glob("#{CURRENT_DIR}/webruby/rake/*.rake") { |f| load f; }
