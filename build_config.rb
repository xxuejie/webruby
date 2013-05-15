# This file configures mruby to cross compile the emscripten version
# We expose this file here to let users adding mrbgems using the same
# method as in mruby

CURRENT_DIR = File.dirname(File.expand_path(__FILE__))
EMSCRIPTEN_DIR = ENV['EMSCRIPTEN_DIR'] || File.join(CURRENT_DIR, %w[modules emscripten])

# Native mruby build config for mrbc
MRuby::Build.new do |conf|
  # load specific toolchain settings
  toolchain :gcc

  # Use standard Kernel#sprintf method
  conf.gem "#{root}/mrbgems/mruby-sprintf"

  # Use standard print/puts/p
  conf.gem "#{root}/mrbgems/mruby-print"

  # Use standard Math module
  conf.gem "#{root}/mrbgems/mruby-math"

  # Use standard Time class
  conf.gem "#{root}/mrbgems/mruby-time"

  # Use standard Struct class
  conf.gem "#{root}/mrbgems/mruby-struct"

  # Use extensional Enumerable module
  conf.gem "#{root}/mrbgems/mruby-enum-ext"

  # Use extensional String class
  conf.gem "#{root}/mrbgems/mruby-string-ext"

  # Use extensional Numeric class
  conf.gem "#{root}/mrbgems/mruby-numeric-ext"

  # Use extensional Array class
  conf.gem "#{root}/mrbgems/mruby-array-ext"

  # Use extensional Hash class
  conf.gem "#{root}/mrbgems/mruby-hash-ext"

  # Use extensional Range class
  conf.gem "#{root}/mrbgems/mruby-range-ext"

  # Use extensional Proc class
  conf.gem "#{root}/mrbgems/mruby-proc-ext"

  # Use extensional Symbol class
  conf.gem "#{root}/mrbgems/mruby-symbol-ext"

  # Use Random class
  conf.gem "#{root}/mrbgems/mruby-random"

  # No use eval method
  # conf.gem "#{root}/mrbgems/mruby-eval"
end


# Emscripten customized toolchain
MRuby::Toolchain.new(:emscripten) do |conf|
  toolchain :clang

  conf.cc do |cc|
    cc.command = File.join(EMSCRIPTEN_DIR, 'emcc')
    cc.flags = (ENV['CFLAGS'] || %w(-Wall -Werror-implicit-function-declaration))
  end

  conf.linker.command = File.join(EMSCRIPTEN_DIR, 'emcc')
  conf.archiver.command = File.join(EMSCRIPTEN_DIR, 'emar')
end

# Cross build for emscripten, adding your mrbgems here.
MRuby::CrossBuild.new('emscripten') do |conf|
  toolchain :emscripten

  # TODO: gembox
  # Use standard Kernel#sprintf method
  conf.gem "#{root}/mrbgems/mruby-sprintf"

  # Use standard print/puts/p
  conf.gem "#{root}/mrbgems/mruby-print"

  # Use standard Math module
  conf.gem "#{root}/mrbgems/mruby-math"

  # Use standard Time class
  conf.gem "#{root}/mrbgems/mruby-time"

  # Use standard Struct class
  conf.gem "#{root}/mrbgems/mruby-struct"

  # Use extensional Enumerable module
  conf.gem "#{root}/mrbgems/mruby-enum-ext"

  # Use extensional String class
  conf.gem "#{root}/mrbgems/mruby-string-ext"

  # Use extensional Numeric class
  conf.gem "#{root}/mrbgems/mruby-numeric-ext"

  # Use extensional Array class
  conf.gem "#{root}/mrbgems/mruby-array-ext"

  # Use extensional Hash class
  conf.gem "#{root}/mrbgems/mruby-hash-ext"

  # Use extensional Range class
  conf.gem "#{root}/mrbgems/mruby-range-ext"

  # Use extensional Proc class
  conf.gem "#{root}/mrbgems/mruby-proc-ext"

  # Use extensional Symbol class
  conf.gem "#{root}/mrbgems/mruby-symbol-ext"

  # Use Random class
  conf.gem "#{root}/mrbgems/mruby-random"

  # No use eval method
  # conf.gem "#{root}/mrbgems/mruby-eval"

  # You can add new mrbgem at here!
  # A few commonly used gems are listed here(but commented),
  # you can simply uncomment the corresponding lines if you want to use them.

  # JavaScript calling interface
  # conf.gem :git => 'git://github.com/xxuejie/mruby-js.git', :branch => 'master'

  # OpenGL ES 2.0 binding
  # conf.gem :git => 'git://github.com/xxuejie/mruby-gles.git', :branch => 'master'

  # Normally we wouldn't use this example gem, I just put it here to show how to
  # add a gem on the local file system, you can either use absolute path or relative
  # path from mruby root, which is modules/webruby.
  # conf.gem "#{root}/examples/mrbgems/c_and_ruby_extension_example"
end
