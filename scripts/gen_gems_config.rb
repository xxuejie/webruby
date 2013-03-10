#!/usr/bin/env ruby

# This script loops through all gems to perform the following three tasks:
# 1. Loop through 'js/lib' directory in each gem for JS libraries to include
# 2. Loop through 'js/append' directory in each gem for JS files to append
# 3. Loop through 'test/js/lib' directory of each gem for test libs to include
# 2. Loop through 'test/js/append' directory in each gem for test files to append
# 3. Collect functions to export for each gem

require 'fileutils'

if ARGV.length < 6
  puts 'Usage: (path to build config) (JS lib file name) (JS append file name) (test JS lib file name) (test JS append file name) (output functions file name)'
  exit 1
end

MRUBY_DIR = File.join(File.expand_path(File.dirname(__FILE__)), %w[.. modules mruby])

CONFIG_FILE = File.expand_path(ARGV[0])
JS_LIB_FILE = File.expand_path(ARGV[1])
JS_APPEND_FILE = File.expand_path(ARGV[2])
TEST_JS_LIB_FILE = File.expand_path(ARGV[3])
TEST_JS_APPEND_FILE = File.expand_path(ARGV[4])
EXPORTED_FUNCTIONS_FILE = File.expand_path(ARGV[5])

DIRECTORY_MAP = {
  'js/lib' => JS_LIB_FILE,
  'js/append' => JS_APPEND_FILE,
  'test/js/lib' => TEST_JS_LIB_FILE,
  'test/js/append' => TEST_JS_APPEND_FILE
}

def get_temp_file_name(filename)
  "#{filename}.tmp"
end

# monkey patch for getting mrbgem list
$gems = []
module MRuby
  # Toolchain and Build classes are not used, we just
  # add them here to prevent runtime error.
  class Toolchain
    def initialize(sym, &block)
    end
  end

  class Build
    def initialize(&block)
    end
  end

  class CrossBuild
    def initialize(name, &block)
      if name == "emscripten"
        instance_eval(&block)
      end
    end

    def toolchain(sym)
      # This is also for preventing errors
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

  file_map = {}
  DIRECTORY_MAP.each do |k, v|
    file_map[k] = File.open(get_temp_file_name(v), 'w')
  end
  functions = []

  $gems.each do |gem|
    gem = gem.strip

    # gather JavaScript files
    file_map.each do |dir, tmp_f|
      Dir.glob(File.join(gem, dir, '*.js')) do |f|
        tmp_f.write("/* #{f} */\n")
        tmp_f.write(File.read(f))
      end
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
  file_map.each { |k, f| f.close }

  DIRECTORY_MAP.each do |dir, filename|
    tmpname = get_temp_file_name(filename)
    if (!File.exists?(filename)) ||
        (!FileUtils.compare_file(filename, tmpname))
      puts "Creating new file: #{filename}!"
      FileUtils.cp(tmpname, filename)
    end
    FileUtils.rm(tmpname)
  end

  # writes functions file
  File.open(EXPORTED_FUNCTIONS_FILE, 'w') do |f|
    functions.uniq.each do |func|
      f.write("#{func}\n")
    end
  end
end
