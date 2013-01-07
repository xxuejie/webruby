# Webruby Rakefile
# Note this is a full-fledged Rakefile(not minirake-powered)!

BASE_DIR = File.expand_path(File.dirname(__FILE__))
BUILD_DIR = File.join(BASE_DIR, 'build')

EMSCRIPTEN_DIR = File.join(BASE_DIR, %w[modules emscripten])
CC = File.join(EMSCRIPTEN_DIR, 'emcc')
LD = File.join(EMSCRIPTEN_DIR, 'emcc')
AR = File.join(EMSCRIPTEN_DIR, 'emar')

CUSTOM_EXPORTED_FUNCTIONS = ENV['CUSTOM_EXPORTED_FUNCTIONS'] || ['main']

CFLAGS = %w(-DMRB_USE_FLOAT -Wall -Werror-implicit-function-declaration)
LDFLAGS = []

MRUBY_DIR = File.join(BASE_DIR, %w[modules mruby])
MRUBY_BUILD_CONFIG = File.join(BASE_DIR, 'build_config.rb')
MRBC = File.join(MRUBY_DIR, %w[build host bin mrbc])
LIBMRUBY = File.join(%w[build emscripten lib libmruby.a])
LIBMRUBY_FILE = File.join(MRUBY_DIR, LIBMRUBY)

CFLAGS << "-I#{MRUBY_DIR}/include"

load 'src/app.rake'

# tasks
task :default => "#{BUILD_DIR}/mruby.js"

file "#{BUILD_DIR}/mruby.js" => ["#{BUILD_DIR}/app.o", "#{BUILD_DIR}/pre.js", :libmruby] do |t|
  functions = File.readlines("#{BUILD_DIR}/functions").map {|f| f.strip}
  functions = functions.concat(CUSTOM_EXPORTED_FUNCTIONS)
  func_str = functions.map {|f| "'_#{f}'"}.join ', '

  sh "#{LD} #{BUILD_DIR}/app.o #{LIBMRUBY_FILE} -o #{BUILD_DIR}/mruby.js --js-library #{BUILD_DIR}/pre.js -s EXPORTED_FUNCTIONS=\"[#{func_str}]\""
end

file "#{BUILD_DIR}/pre.js" => :libmruby do |t|
  sh "ruby scripts/gen_gems_config.rb #{MRUBY_BUILD_CONFIG} #{BUILD_DIR}/pre.js #{BUILD_DIR}/functions"
end

desc "build mruby library"
task :libmruby do |t|
  sh "cd #{MRUBY_DIR} && CONFIG=#{MRUBY_BUILD_CONFIG} ./minirake #{LIBMRUBY}"
end

desc "cleanup"
task :clean do |t|
  sh "cd #{MRUBY_DIR} && CONFIG=#{MRUBY_BUILD_CONFIG} ./minirake clean"
  sh "rm -f #{BUILD_DIR}/app.c #{BUILD_DIR}/app.o #{BUILD_DIR}/rbcode.rb #{BUILD_DIR}/rbcode.c"
  sh "rm -f #{BUILD_DIR}/pre.js #{BUILD_DIR}/functions"
  sh "rm -f #{BUILD_DIR}/mruby.js"
end
