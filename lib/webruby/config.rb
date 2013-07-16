module Webruby
  class Config
    attr_accessor :entrypoint, :build_dir, :gemboxes, :gems,
                  :compile_mode, :loading_mode, :output_name,
                  :executable_output_name

    def initialize
      @entrypoint = 'app/app.rb'
      @build_dir = 'build'
      @gemboxes = ['default']
      @gems = []
      @compile_mode = 'debug'   # debug or release
      @loading_mode = 2
      @output_name = 'webruby.js'
      @executable_output_name = 'webruby_bin.js'
    end

    def is_release_mode
      @compile_mode == 'release'
    end

    def cflags
      "-Wall -Werror-implicit-function-declaration #{optimization_flag}"
    end

    def ldflags
      optimization_flag
    end

    def optimization_flag
      is_release_mode ? "-O2" : "-O0"
    end
  end
end
