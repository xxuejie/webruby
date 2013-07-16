module Webruby
  class App
    class << self
      def config
        @config ||= Webruby::Config.new
      end

      def setup(&block)
        block.call(config)
      end
    end
  end
end
