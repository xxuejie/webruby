#!/usr/bin/env ruby

require 'fileutils'

def relative_file_name(file_name)
  file_name.sub(/\.rb$/, '')
end

def symbol_name(relative_file_name)
  "#{relative_file_name.gsub('/', '_')}_irep"
end

if ARGV.length < 2
  puts "Usage: (entryfile) (outputfile)"
  exit 1
end

ENTRY_FILE = ARGV[0]
OUTPUT_PATH = ARGV[1]
ENTRY_DIRECTORY = File.dirname(ENTRY_FILE)
MRBC = ENV['MRBC']

File.open(OUTPUT_PATH, "w") do |f|
  f.puts <<END
#include "mruby.h"
#include "mruby/irep.h"
END
end

files = []

FileUtils.chdir ENTRY_DIRECTORY do
  Dir["**/*.rb"].each do |f|
    file_name = relative_file_name(f)
    files << file_name
    system("#{MRBC} -o- -B#{symbol_name(file_name)} #{f} >> #{OUTPUT_PATH}")
  end
end

File.open(OUTPUT_PATH, "a") do |f|
  f.puts <<END
mrb_value
mrb_require_internal(mrb_state* mrb, mrb_value mod)
{
  mrb_int idx;
  mrb_value result;
  mrb_get_args(mrb, "i", &idx);

  switch (idx) {
END
  files.each_with_index do |file_name, index|
    f.puts <<END
    case #{index}:
      result = mrb_load_irep(mrb, #{symbol_name(file_name)});
      break;
END
  end
  f.puts <<END
  }

  if (mrb->exc) {
    mrb_p(mrb, mrb_obj_value(mrb->exc));
    mrb->exc = 0;
  }

  return mrb_nil_value();
}
END
end

RUBY_SOURCE_PATH = "#{OUTPUT_PATH}.tmp"
File.open(RUBY_SOURCE_PATH, "w") do |f|
  f.puts <<END
module Kernel
  @@REQUIRED_PATH = ""
  @@REQUIRED_MODULES = {
END

  files.each_with_index do |file_name, index|
    f.puts "    #{file_name.inspect} => #{index},\n"
  end

  f.puts <<END
  }

  def require(name)
    return false unless @@REQUIRED_MODULES.include?(name)
    @@REQUIRED_PATH = name[0, name.rindex('/') || 0]
    require_internal(@@REQUIRED_MODULES[name])
    @@REQUIRED_MODULES.delete(name)
    true
  end

  def require_relative(path)
    current_path = @@REQUIRED_PATH
    path.split('/').each do |fragment|
      case fragment
      when '.'
        # Doing nothing, current path
      when '..'
         current_path = current_path[0, current_path.rindex('/') || 0]
      else
        current_path = current_path.empty? ? fragment :
          "\#{current_path}/\#{fragment}"
      end
    end
    require(current_path)
  end
end
END
end

system("#{MRBC} -o- -Bmrb_require_internal_irep #{RUBY_SOURCE_PATH} >> #{OUTPUT_PATH}")
FileUtils.rm RUBY_SOURCE_PATH

File.open(OUTPUT_PATH, "a") do |f|
  f.puts <<END
void mrb_enable_require(mrb_state *mrb) {
  struct RClass* kernel_module = mrb->kernel_module;
  mrb_define_method(mrb, kernel_module, "require_internal",
                    mrb_require_internal, ARGS_REQ(1));
  mrb_load_irep(mrb, mrb_require_internal_irep);
}
END
end
