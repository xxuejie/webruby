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

    def gembox_lines
      generate_conf_lines(gemboxes, 'gembox')
    end

    def gem_lines
      generate_conf_lines(gems, 'gem')
    end

    private
    def generate_conf_lines(arr, option)
      arr.map { |i| "conf.#{option}(#{format_gem(i)})"
      }.inject { |a, b| "#{a}\n  #{b}" }
    end

    def format_gem(gem)
      return gem if gem.is_a?(Hash)
      "'#{gem}'"
    end
  end
end
