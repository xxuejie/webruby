module Webruby
  class App
    class << self
      def config
        @config ||= Webruby::Config.new
      end

      def setup(&block)
        block.call(config)

        # load rake tasks
        require 'rake'
        Dir.glob("#{CURRENT_DIR}/webruby/rake/*.rake") { |f| load f; }
      end
    end
  end
end
