#!/usr/bin/env ruby

# Generate js libraries from mrbgems(if exist)

require 'fileutils'

if ARGV.length < 2
  puts 'Usage: (path to GEMS.active) (output js file name)'
  exit 1
end

BASE_PATH = File.expand_path(File.join(File.dirname(__FILE__),
                                       %w(.. modules mruby mrbgems g)))

GEMS_FILE = ARGV[0]
OUTPUT_JS_FILE = ARGV[1]
OUTPUT_TEMP_FILE = "#{OUTPUT_JS_FILE}.tmp"

File.open(OUTPUT_TEMP_FILE, 'w') do |out_f|
  gems = File.readlines(GEMS_FILE)
  FileUtils.cd(BASE_PATH) do
    gems.each do |gem|
      Dir.glob(File.join(gem.chomp, 'js', '*.js')) do |f|
        out_f.write("/* #{f} */\n")
        out_f.write(File.read(f))
      end
    end
  end
end

if (!File.exists?(OUTPUT_JS_FILE)) ||
  (!FileUtils.compare_file(OUTPUT_JS_FILE, OUTPUT_TEMP_FILE))
  # only copys the file if it does not match the original one
  puts 'Creating new js file!'
  FileUtils.cp(OUTPUT_TEMP_FILE, OUTPUT_JS_FILE)
end

FileUtils.rm(OUTPUT_TEMP_FILE)
