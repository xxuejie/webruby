# Webruby Rakefile
# Note this is a full-fledged Rakefile(not minirake-powered)!

BASE_DIR = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(BASE_DIR, *%w[rakelib]))

BUILD_DIR = File.join(BASE_DIR, %w[build])
EMSCRIPTEN_DIR = ENV['EMSCRIPTEN_DIR'] || File.join(BASE_DIR, %w[modules emscripten])
MRUBY_DIR = File.join(BASE_DIR, %w[modules mruby])
APP_DIR = File.join(BASE_DIR, %w[app])
DRIVER_DIR = File.join(BASE_DIR, %w[driver])

CC = File.join(EMSCRIPTEN_DIR, 'emcc')
LD = File.join(EMSCRIPTEN_DIR, 'emcc')
AR = File.join(EMSCRIPTEN_DIR, 'emar')

WEBRUBY_BUILD_CONFIG = ENV['BUILD_CONFIG'] || File.join(BASE_DIR, 'build_config.rb')
MRBC = File.join(MRUBY_DIR, %w[build host bin mrbc])
LIBMRUBY = File.join(%w[build emscripten lib libmruby.a])
LIBMRUBY_FILE = File.join(MRUBY_DIR, LIBMRUBY)
MRBTEST = File.join(%w[build emscripten test mrbtest])
MRBTEST_FILE = File.join(MRUBY_DIR, MRBTEST)

MRUBYMIX = File.join(BASE_DIR, %w[modules mrubymix bin mrubymix])

# Specify supported loading modes of webruby, see rakelib/functions.rb file
# for details, by default all 3 loading modes are supported
LOADING_MODE = ENV['LOADING_MODE'] || 2

CLOSURE = ENV['CLOSURE'] || 0

CFLAGS = %w(-Wall -Werror-implicit-function-declaration)
CFLAGS << "-I#{MRUBY_DIR}/include"
# We use -O2 mode by default since this is not too slow, the closure optimization
# is thus disabled in development mode
LDFLAGS = %w(-O2)

if CLOSURE.to_i == 1
  LDFLAGS << '--closure 1'
else
  LDFLAGS << '--closure 0'
end

load 'app/app.rake'
load 'driver/driver.rake'

# tasks
task :default => :js

task :js => "#{BUILD_DIR}/webruby.js"
task :js_bin => ["#{BUILD_DIR}/webruby_bin.js"]

task :mrbtest => "#{BUILD_DIR}/mrbtest.js" do |t|
  sh "node #{BUILD_DIR}/mrbtest.js"
end

desc "cleanup"
task :clean => [:libmruby_clean] do |t|
  sh "rm -f #{BUILD_DIR}/app.c #{BUILD_DIR}/app.o #{BUILD_DIR}/rbcode.rb #{BUILD_DIR}/rbcode.c #{BUILD_DIR}/main.o"
  sh "rm -f #{BUILD_DIR}/gem_library.js #{BUILD_DIR}/functions #{BUILD_DIR}/post.js"
  sh "rm -f #{BUILD_DIR}/webruby.js #{BUILD_DIR}/webruby_bin.js"
  sh "rm -f #{BUILD_DIR}/mrbtest.js #{BUILD_DIR}/mrbtest.bc"
end
