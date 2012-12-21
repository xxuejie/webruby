# Build JavaScript module from mruby source code and link
# it against our provided source code including the main function

BASE_DIR = File.expand_path('.')

# compiler, linker, archiver, parser generator
EMSCRIPTEN_DIR = File.join(BASE_DIR, 'modules', 'emscripten')
CC = File.join(EMSCRIPTEN_DIR, 'emcc')
LL = File.join(EMSCRIPTEN_DIR, 'emcc')
AR = File.join(EMSCRIPTEN_DIR, 'emar')
YACC = ENV['yacc'] || 'bison'
MAKE = ENV['make'] || 'make'

# mruby paths
MRUBY_ROOT = File.join(BASE_DIR, 'modules', 'mruby')

MRUBY_SRC_DIR = File.join(MRUBY_ROOT, 'src')
MRUBY_MRBC_DIR = File.join(MRUBY_ROOT, 'tools', 'mrbc')
MRUBY_LIB_DIR = File.join(MRUBY_ROOT, 'mrblib')
MRUBY_GEMS_DIR = File.join(MRUBY_ROOT, 'mrbgems')
MRUBY_TEST_DIR = File.join(MRUBY_ROOT, 'test')

# mruby files
MRUBY_TEST_TARGET = File.join(BASE_DIR, 'build', 'mrbtest.js')

MRUBY_CORE_LIB = File.join(MRUBY_ROOT, 'lib', 'libmruby_core.a')
MRUBY_LIB = File.join(MRUBY_ROOT, 'lib', 'libmruby.a')
MRUBY_MRBC = File.join(MRUBY_ROOT, 'bin', 'mrbc')
MRUBY_MRBC_JS = File.join(MRUBY_ROOT, 'bin', 'mrbc.js')
MRUBY_MRBC_JS_ABSOLUTE = File.expand_path(MRUBY_MRBC_JS)

MRUBY_GEMS_TASK_FILE = File.join(MRUBY_GEMS_DIR, 'build_tasks')

# mrbgems setting
ENABLE_GEMS = ENV['ENABLE_GEMS'] == 'true'

# active gems file
ACTIVE_GEMS = ENV['ACTIVE_GEMS'] || File.join(MRUBY_ROOT, 'mrbgems', 'GEMS.active')

# Note: we found that when compiling mruby using double,
# the unit test String#to_f [15.2.10.5.39] would fail, since
# according to v8, the difference between 123456789 and
# 123456789.0 is 1.4901161193848e-08, which is larger than
# 1E-12. So until we found a way to work around this(this may
# due to the generated js code or the problem with v8, we
# just cannot tell which is the reason for now), we have
# to compile mruby in float mode here.
CFLAGS = ["-Werror-implicit-function-declaration",
          "-DMRB_USE_FLOAT",
          "-I#{MRUBY_ROOT}/include"]

if !ENABLE_GEMS
  CFLAGS << "-DDISABLE_GEMS"
end

GENERAL_FLAGS = "CC='#{CC}' LL='#{LL}' AR='#{AR}' YACC='#{YACC}' CP=cp CAT=cat CFLAGS=\"#{CFLAGS.join(' ')}\""

MAKE_FLAGS = GENERAL_FLAGS
# one test case in exception.rb tests the case of a very
# deeply recursive function, which needs a lot of memory
TEST_FLAGS = "#{GENERAL_FLAGS} LDFLAGS=\"-s ALLOW_MEMORY_GROWTH=1\""

##############################
# generic build targets, rules

if ENABLE_GEMS
  require MRUBY_GEMS_TASK_FILE
end

task :default => :js

desc "build js targets and all dependencies"
task :js do
  sh "make -C #{MRUBY_SRC_DIR} #{MAKE_FLAGS}"
  sh "make -q -C #{MRUBY_MRBC_DIR} #{MAKE_FLAGS} EXE=#{MRUBY_MRBC_JS_ABSOLUTE} || (cp scripts/mrbc #{MRUBY_MRBC} && touch #{MRUBY_MRBC})"
  sh "make -C #{MRUBY_MRBC_DIR} #{MAKE_FLAGS} EXE=#{MRUBY_MRBC_JS_ABSOLUTE}"
  if ENABLE_GEMS
    puts "-- MAKE mrbgems --"
    Rake::Task['mrbgems_all'].invoke
  end
  sh "make -C #{MRUBY_LIB_DIR} #{MAKE_FLAGS}"
  sh "make -C src #{MAKE_FLAGS}"
end

desc "build html target"
task :html => [:js] do
    sh "make -C src html #{MAKE_FLAGS}"
end

desc "build and run mruby tests, notice this is not testing your code in src folder!"
task :mruby_test => [:js] do
    sh "make -C #{MRUBY_TEST_DIR} #{TEST_FLAGS} EXE=#{MRUBY_TEST_TARGET} #{MRUBY_TEST_TARGET}"
    puts "Running mruby test in Node.js!"
    sh "node #{MRUBY_TEST_TARGET}"
end

desc "clean up"
task :clean do
    sh "rm -rf #{MRUBY_TEST_TARGET} #{MRUBY_MRBC_JS}"
    sh "make -C src clean #{MAKE_FLAGS}"
    sh "make -C #{MRUBY_ROOT} clean #{MAKE_FLAGS}"
end
