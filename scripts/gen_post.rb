#!/usr/bin/env ruby

# This script generates the post attached JavaScript file according to loading modes

require 'fileutils'

def convert_to_valid_loading_mode str
  if str.to_i.to_s == str
    i = str.to_i
    if (i >= 0) && (i <= 2)
      return i
    end
  end
  nil
end

if ARGV.length < 2
  puts 'Usage: (loading mode) (output post js file name)'
  exit 1
end

if !(mode = convert_to_valid_loading_mode ARGV[0])
  puts "#{ARGV[0]} is not a valid loading mode!"
  exit 1
end

OUTPUT_JS_FILE = ARGV[1]
OUTPUT_JS_TEMP_FILE = "#{OUTPUT_JS_FILE}.tmp"

File.open(OUTPUT_JS_TEMP_FILE, 'w') do |f|
  f.puts <<__EOF__
(function() {
  function WEBRUBY() {
    var instance = {};
    instance.mrb = _mrb_open();
    instance['close'] = function() {
      _mrb_close(instance.mrb);
    };
    instance['run'] = function() {
      _webruby_internal_run(instance.mrb);
    };
__EOF__

  if mode > 0
    # WEBRUBY.run_bytecode
    f.puts <<__EOF__
    instance['run_bytecode'] = function(bc) {
      var stack = Runtime.stackSave();
      var addr = Runtime.stackAlloc(bc.length);
      var ret;
      writeArrayToMemory(bc, addr);

      ret = _webruby_internal_run_bytecode(instance.mrb, addr);

      Runtime.stackRestore(stack);
      return ret;
    };
__EOF__
  end

  if mode > 1
    # WEBRUBY.run_source
    f.puts <<__EOF__
    instance['run_source'] = function(src) {
      var stack = Runtime.stackSave();
      var addr = Runtime.stackAlloc(src.length);
      var ret;
      writeStringToMemory(src, addr);

      ret = _webruby_internal_run_source(instance.mrb, addr);

      Runtime.stackRestore(stack);
      return ret;
    };
__EOF__
  end

  f.puts <<__EOF__
    return instance;
  };

  if (typeof window === 'object') {
    window['WEBRUBY'] = WEBRUBY;
  } else {
    global['WEBRUBY'] = WEBRUBY;
  }
}) ();
__EOF__
end

if (!File.exists?(OUTPUT_JS_FILE)) ||
    (!FileUtils.compare_file(OUTPUT_JS_FILE, OUTPUT_JS_TEMP_FILE))
  # only copys the file if it does not match the original one
  puts 'Creating new post js file!'
  FileUtils.cp(OUTPUT_JS_TEMP_FILE, OUTPUT_JS_FILE)
end
FileUtils.rm(OUTPUT_JS_TEMP_FILE)
