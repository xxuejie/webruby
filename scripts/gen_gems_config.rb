#!/usr/bin/env ruby

# This script loops through all gems, and collect the JavaScript file to
# append as well as functions to export.

require 'fileutils'

if ARGV.length < 3
  puts 'Usage: (path to build config) (output js file name) (output functions file name)'
  exit 1
end

MRUBY_DIR = File.join(File.expand_path(File.dirname(__FILE__)), %w[.. modules mruby])

CONFIG_FILE = File.expand_path(ARGV[0])
OUTPUT_JS_FILE = File.expand_path(ARGV[1])
OUTPUT_JS_TEMP_FILE = "#{OUTPUT_JS_FILE}.tmp"
OUTPUT_FUNCTIONS_FILE = File.expand_path(ARGV[2])

# monkey patch for getting mrbgem list
$gems = []
module MRuby
  class Build
    def initialize(&block)
      # This is omitted
    end
  end

  class CrossBuild
    attr_accessor :cc, :cflags
    attr_accessor :ld, :ldflags
    attr_accessor :ar

    def initialize(name, &block)
      if name == "emscripten"
        @cflags = []
        @ldflags = []

        instance_eval(&block)
      end
    end

    def gem(gemdir)
      gemdir = load_external_gem(gemdir) if gemdir.is_a?(Hash)

      # Collecting available gemdir
      $gems << gemdir if File.exists?(gemdir)
    end

    def load_external_gem(params)
      if params[:git]
        "build/mrbgems/#{params[:git].match(/([-_\w]+)(\.[-_\w]+|)$/).to_a[1]}"
      end
    end
  end
end

FileUtils.cd(MRUBY_DIR) do
  load CONFIG_FILE

  temp_js_file = File.open(OUTPUT_JS_TEMP_FILE, 'w')
  functions = []

  $gems.each do |gem|
    gem = gem.strip

    # gather all prepending JavaScript files
    Dir.glob(File.join(gem, %w[js *.js])) do |f|
      temp_js_file.write("/* #{f} */\n")
      temp_js_file.write(File.read(f))
    end

    # gather exported functions
    functions_file = File.join(gem, 'EXPORTED_FUNCTIONS')
    if File.exists?(functions_file)
      File.readlines(functions_file).each do |func|
        func = func.strip
        functions << func if !func.empty?
      end
    end
  end

  # writes js file
  temp_js_file.close
  if (!File.exists?(OUTPUT_JS_FILE)) ||
      (!FileUtils.compare_file(OUTPUT_JS_FILE, OUTPUT_JS_TEMP_FILE))
    # only copys the file if it does not match the original one
    puts 'Creating new js file!'
    FileUtils.cp(OUTPUT_JS_TEMP_FILE, OUTPUT_JS_FILE)
  end
  FileUtils.rm(OUTPUT_JS_TEMP_FILE)

  # writes functions file
  File.open(OUTPUT_FUNCTIONS_FILE, 'w') do |f|
    functions.uniq.each do |func|
      f.write("#{func}\n")
    end
  end
end
