# Webruby Rakefile
# Note this is a full-fledged Rakefile(not minirake-powered)!

BASE_DIR = File.expand_path(File.dirname(__FILE__))
BUILD_DIR = File.join(BASE_DIR, 'build')

EMSCRIPTEN_DIR = File.join(BASE_DIR, %w[modules emscripten])
CC = File.join(EMSCRIPTEN_DIR, 'emcc')
LD = File.join(EMSCRIPTEN_DIR, 'emcc')
AR = File.join(EMSCRIPTEN_DIR, 'emar')
CFLAGS = %w(-DMRB_USE_FLOAT -Wall -Werror-implicit-function-declaration)

MRUBY_DIR = File.join(BASE_DIR, %w[modules mruby])
MRUBY_BUILD_CONFIG = File.join(BASE_DIR, %w[scripts mruby_build_config.rb])
CFLAGS << "-I#{MRUBY_DIR}/include"

MRBC = File.join(MRUBY_DIR, %w[build host bin mrbc])
LIBMRUBY = File.join(%w[build emscripten lib libmruby.a])
LIBMRUBY_FILE = File.join(MRUBY_DIR, LIBMRUBY)

load 'src/app.rake'

task :default => "#{BUILD_DIR}/mruby.js"

file "#{BUILD_DIR}/mruby.js" => ["#{BUILD_DIR}/app.o", :libmruby] do |t|
  sh "#{LD} #{BUILD_DIR}/app.o #{LIBMRUBY_FILE} -o #{BUILD_DIR}/mruby.js"
end

desc "build mruby library"
task :libmruby do |t|
  sh "cd #{MRUBY_DIR} && CONFIG=#{MRUBY_BUILD_CONFIG} ./minirake #{LIBMRUBY}"
end

desc "cleanup"
task :clean do |t|
  sh "cd #{MRUBY_DIR} && CONFIG=#{MRUBY_BUILD_CONFIG} ./minirake clean"
  sh "rm -f #{BUILD_DIR}/app.c #{BUILD_DIR}/app.o #{BUILD_DIR}/rbcode.rb #{BUILD_DIR}/rbcode.c"
  sh "rm -f #{BUILD_DIR}/mruby.js"
end
