#!/usr/bin/env ruby

# This script loops through all gems to perform the following three tasks:
# 1. Copy WEBRUBY API file to JS append file(this allows us to add WEBRUBY JS plugins)
# 2. Loop through 'js/lib' directory in each gem for JS libraries to include
# 3. Loop through 'js/append' directory in each gem for JS files to append
# 4. Loop through 'test/js/lib' directory of each gem for test libs to include
# 5. Loop through 'test/js/append' directory in each gem for test files to append
# 6. Collect functions to export for each gem

require 'fileutils'

if ARGV.length < 7
  puts 'Usage: (path to build config) (path to WEBRUBY API file) (JS lib file name) (JS append file name) (test JS lib file name) (test JS append file name) (output functions file name) (mruby build output path)'
  exit 1
end

MRUBY_DIR = File.join(File.expand_path(File.dirname(__FILE__)), %w[.. modules mruby])

CONFIG_FILE = File.expand_path(ARGV[0])
WEBRUBY_API_FILE = File.expand_path(ARGV[1])
JS_LIB_FILE = File.expand_path(ARGV[2])
JS_APPEND_FILE = File.expand_path(ARGV[3])
TEST_JS_LIB_FILE = File.expand_path(ARGV[4])
TEST_JS_APPEND_FILE = File.expand_path(ARGV[5])
EXPORTED_FUNCTIONS_FILE = File.expand_path(ARGV[6])
MRUBY_BUILD_DIR = File.expand_path(ARGV[7])

DIRECTORY_MAP = {
  'js/lib' => JS_LIB_FILE,
  'js/append' => JS_APPEND_FILE,
  'test/js/lib' => TEST_JS_LIB_FILE,
  'test/js/append' => TEST_JS_APPEND_FILE
}

def get_temp_file_name(filename)
  "#{filename}.tmp"
end

def write_file_with_name(fd, file_to_write)
  fd.write("/* #{file_to_write} */\n")
  fd.write(File.read(file_to_write))
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

  GemBox = Object.new
  class << GemBox
    def new(&block); block.call(self); end
    def config=(obj); @config = obj; end
    def gem(gemdir, &block); @config.gem(gemdir, &block); end
  end

  class CrossBuild
    def initialize(name, &block)
      if name == "emscripten"
        instance_eval(&block)
      end
    end

    def root
      MRUBY_DIR
    end

    def toolchain(sym)
      # This is also for preventing errors
    end

    def build_dir=(dir)
    end

    def gembox(gemboxfile)
      gembox = File.expand_path("#{gemboxfile}.gembox", "#{root}/mrbgems")
      fail "Can't find gembox '#{gembox}'" unless File.exists?(gembox)
      GemBox.config = self
      instance_eval File.read(gembox)
    end

    def gem(gemdir)
      gemdir = load_hash_gem(gemdir) if gemdir.is_a?(Hash)

      # Collecting available gemdir
      $gems << gemdir if File.exists?(gemdir)
    end

    def load_hash_gem(params)
      if params[:github]
        params[:git] = "https://github.com/#{params[:github]}.git"
      elsif params[:bitbucket]
        params[:git] = "https://bitbucket.org/#{params[:bitbucket]}.git"
      end

      if params[:core]
        gemdir = "#{root}/mrbgems/#{params[:core]}"
      elsif params[:git]
        url = params[:git]
        gemdir = "#{MRUBY_BUILD_DIR}/mrbgems/#{url.match(/([-\w]+)(\.[-\w]+|)$/).to_a[1]}"
      else
        fail "unknown gem option #{params}"
      end

      gemdir
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

  if File.exists? WEBRUBY_API_FILE
    write_file_with_name(file_map['js/append'], WEBRUBY_API_FILE)
  end

  $gems.each do |gem|
    gem = gem.strip

    # gather JavaScript files
    file_map.each do |dir, tmp_f|
      Dir.glob(File.join(gem, dir, '*.js')) do |f|
        write_file_with_name(tmp_f, f)
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

  ['js/append', 'js/lib'].each do |path|
    name = get_temp_file_name(DIRECTORY_MAP[path])
    test_name = get_temp_file_name(DIRECTORY_MAP["test/#{path}"])
    tmp_test_name = "#{test_name}.orig"

    FileUtils.mv(test_name, tmp_test_name)
    File.open(test_name, 'w') do |f|
      f.write(File.read(name))
      f.write(File.read(tmp_test_name))
    end
    FileUtils.rm(tmp_test_name)
  end

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
