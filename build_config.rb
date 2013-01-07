# This file configures mruby to cross compile the emscripten version
# We expose this file here to let users adding mrbgems using the same
# method as in mruby

BASE_DIR = File.expand_path(File.dirname(__FILE__))
EMSCRIPTEN_DIR = File.join(BASE_DIR, %w[modules emscripten])

# Original mruby build, we only use the generated mrbc file for this native build
MRuby::Build.new do |conf|
  conf.cc = ENV['CC'] || 'gcc'
  conf.ld = ENV['LD'] || 'gcc'
  conf.ar = ENV['AR'] || 'ar'

  conf.cflags << (ENV['CFLAGS'] || %w(-g -O3 -Wall -Werror-implicit-function-declaration))
  conf.ldflags << (ENV['LDFLAGS'] || %w(-lm))
end

# Cross build for emscripten, adding your mrbgems here.
MRuby::CrossBuild.new('emscripten') do |conf|
  conf.cc = File.join(EMSCRIPTEN_DIR, 'emcc')
  conf.ld = File.join(EMSCRIPTEN_DIR, 'emcc')
  conf.ar = File.join(EMSCRIPTEN_DIR, 'emar')

  conf.cflags << (ENV['CFLAGS'] || %w(-DMRB_USE_FLOAT -Wall -Werror-implicit-function-declaration))
  conf.ldflags << (ENV['LDFLAGS'] || %w(-lm))

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
  # conf.gem 'doc/mrbgems/c_and_ruby_extension_example'
end
