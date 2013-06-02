require 'functions'

GEM_JS_FILES = ["#{BUILD_DIR}/gem_library.js", "#{BUILD_DIR}/gem_append.js"]
GEM_JS_FLAGS = "--js-library #{BUILD_DIR}/gem_library.js --post-js #{BUILD_DIR}/gem_append.js"

GEM_TEST_JS_FILES = ["#{BUILD_DIR}/gem_test_library.js", "#{BUILD_DIR}/gem_test_append.js"]
GEM_TEST_JS_FLAGS = "--js-library #{BUILD_DIR}/gem_test_library.js --post-js #{BUILD_DIR}/gem_test_append.js"

file "#{BUILD_DIR}/webruby_bin.js" => ["#{BUILD_DIR}/main.o", "#{BUILD_DIR}/app.o", "#{LIBMRUBY_FILE}"] + GEM_JS_FILES do |t|
  func_arg = get_exported_arg("#{BUILD_DIR}/functions", LOADING_MODE, ['main'])

  sh "#{LD} #{BUILD_DIR}/main.o #{BUILD_DIR}/app.o #{LIBMRUBY_FILE} -o #{BUILD_DIR}/webruby_bin.js #{GEM_JS_FLAGS} #{func_arg} #{LDFLAGS.join(' ')}"
end

file "#{BUILD_DIR}/webruby.js" => ["#{BUILD_DIR}/app.o", "#{LIBMRUBY_FILE}"] + GEM_JS_FILES do |t|
  func_arg = get_exported_arg("#{BUILD_DIR}/functions", LOADING_MODE, [])

  sh "#{LD} #{BUILD_DIR}/app.o #{LIBMRUBY_FILE} -o #{BUILD_DIR}/webruby.js #{GEM_JS_FLAGS} #{func_arg} #{LDFLAGS.join(' ')}"
end

file "#{BUILD_DIR}/gem_library.js" => :gen_gems_config
file "#{BUILD_DIR}/gem_append.js" => :gen_gems_config
file "#{BUILD_DIR}/gem_test_library.js" => :gen_gems_config
file "#{BUILD_DIR}/gem_test_append.js" => :gen_gems_config

task :gen_gems_config do |t|
  sh "ruby scripts/gen_post.rb #{LOADING_MODE} #{BUILD_DIR}/js_api.js"
  sh "ruby scripts/gen_gems_config.rb #{WEBRUBY_BUILD_CONFIG} #{BUILD_DIR}/js_api.js #{BUILD_DIR}/gem_library.js #{BUILD_DIR}/gem_append.js #{BUILD_DIR}/gem_test_library.js #{BUILD_DIR}/gem_test_append.js #{BUILD_DIR}/functions"
end

file "#{BUILD_DIR}/mrbtest.js" => ["#{BUILD_DIR}/mrbtest.bc"] + GEM_TEST_JS_FILES do |t|
  sh "#{LD} #{BUILD_DIR}/mrbtest.bc -o #{BUILD_DIR}/mrbtest.js -s TOTAL_MEMORY=33554432 #{GEM_TEST_JS_FLAGS} #{LDFLAGS.join(' ')}"
end

file "#{BUILD_DIR}/mrbtest.bc" => "#{MRBTEST_FILE}" do |t|
  sh "cp #{MRBTEST_FILE} #{BUILD_DIR}/mrbtest.bc"
end
