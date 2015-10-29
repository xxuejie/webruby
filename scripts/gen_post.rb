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
  function WEBRUBY(opts) {
    if (!(this instanceof WEBRUBY)) {
      // Well, this is not perfect, but it can at least cover some cases.
      return new WEBRUBY(opts);
    }
    opts = opts || {};

    // Default print level is errors only
    this.print_level = 1;
    if (typeof opts.print_level === "number" && opts.print_level >= 0) {
      this.print_level = opts.print_level;
    }
    this.mrb = _mrb_open();
    _webruby_internal_setup(this.mrb);
  };

  WEBRUBY.prototype.close = function() {
    _mrb_close(this.mrb);
  };
  WEBRUBY.prototype.run = function() {
    _webruby_internal_run(this.mrb, this.print_level);
  };
  WEBRUBY.prototype.set_print_level = function(level) {
    if (level >= 0) this.print_level = level;
  };
__EOF__

  if mode > 0
    # WEBRUBY.run_bytecode
    f.puts <<__EOF__
  WEBRUBY.prototype.run_bytecode = function(bc) {
    var stack = Runtime.stackSave();
    var addr = Runtime.stackAlloc(bc.length);
    var ret;
    writeArrayToMemory(bc, addr);

    ret = _webruby_internal_run_bytecode(this.mrb, addr, this.print_level);

    Runtime.stackRestore(stack);
    return ret;
  };
__EOF__
  end

  if mode > 1
    # WEBRUBY.run_source
    f.puts <<__EOF__
  WEBRUBY.prototype.run_source = function(src) {
    var stack = Runtime.stackSave();
    var addr = Runtime.stackAlloc(src.length);
    var ret;
    writeStringToMemory(src, addr);

    ret = _webruby_internal_run_source(this.mrb, addr, this.print_level);

    Runtime.stackRestore(stack);
    return ret;
  };
__EOF__
  end

  #if mode > 2
    # WEBRUBY.run_source
    f.puts <<__EOF__
  WEBRUBY.prototype.compile_to_file = function(src, file_name) {
    var stack  = Runtime.stackSave();
    var f_addr = Runtime.stackAlloc(file_name.length);
    var addr   = Runtime.stackAlloc(src.length);
    var ret;

    writeStringToMemory(file_name, f_addr);
    writeStringToMemory(src, addr);

    ret = _webruby_internal_compile(this.mrb, f_addr, addr, this.print_level);

    Runtime.stackRestore(stack);
    return ret;
  };
__EOF__
  #end

  f.puts <<__EOF__

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
