module Webruby
  class Config
    attr_accessor :entrypoint, :build_dir, :selected_gemboxes, :selected_gems,
                  :compile_mode, :loading_mode, :output_name,
                  :append_file, :source_processor, :cflags, :ldflags, :static_libs

    def initialize
      @entrypoint = 'app/app.rb'
      @build_dir = 'build'
      @selected_gemboxes = ['default']
      @selected_gems = []
      @compile_mode = 'debug'   # debug or release
      @loading_mode = 2
      @output_name = 'webruby.js'
      @source_processor = :mrubymix
      @cflags = %w(-Wall -Werror-implicit-function-declaration -Wno-warn-absolute-paths) + [optimization_flag]
      @ldflags = []
      @static_libs = []
    end

    def is_release_mode
      compile_mode == 'release'
    end

    def optimization_flag
      is_release_mode ? "-O2" : "-O0"
    end

    def gem(g)
      selected_gems << g
    end

    def gembox(gb)
      selected_gemboxes << gb
    end

    def gembox_lines
      generate_conf_lines(selected_gemboxes, 'gembox')
    end

    def gem_lines
      generate_conf_lines(selected_gems, 'gem')
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
