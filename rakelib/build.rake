require 'functions'

file "#{BUILD_DIR}/webruby_bin.js" => ["#{BUILD_DIR}/main.o", "#{BUILD_DIR}/app.o", "#{BUILD_DIR}/gem_library.js", "#{BUILD_DIR}/post.js", "#{LIBMRUBY_FILE}"] do |t|
  func_arg = get_exported_arg("#{BUILD_DIR}/functions", LOADING_MODE, ['main'])

  sh "#{LD} #{BUILD_DIR}/main.o #{BUILD_DIR}/app.o #{LIBMRUBY_FILE} -o #{BUILD_DIR}/webruby_bin.js --js-library #{BUILD_DIR}/gem_library.js --post-js #{BUILD_DIR}/post.js #{func_arg} #{LDFLAGS.join(' ')}"
end

file "#{BUILD_DIR}/webruby.js" => ["#{BUILD_DIR}/app.o", "#{BUILD_DIR}/gem_library.js", "#{BUILD_DIR}/post.js", "#{LIBMRUBY_FILE}"] do |t|
  func_arg = get_exported_arg("#{BUILD_DIR}/functions", LOADING_MODE, [])

  sh "#{LD} #{BUILD_DIR}/app.o #{LIBMRUBY_FILE} -o #{BUILD_DIR}/webruby.js --js-library #{BUILD_DIR}/gem_library.js --post-js #{BUILD_DIR}/post.js #{func_arg} #{LDFLAGS.join(' ')}"
end

file "#{BUILD_DIR}/gem_library.js" => "#{LIBMRUBY_FILE}" do |t|
  sh "ruby scripts/gen_gems_config.rb #{MRUBY_BUILD_CONFIG} #{BUILD_DIR}/gem_library.js #{BUILD_DIR}/functions"
end

file "#{BUILD_DIR}/post.js" => :post_js

# This needs to run each time since changing loading mode
# does not trigger any file changes.
task :post_js do |t|
  sh "ruby scripts/gen_post.rb #{LOADING_MODE} #{BUILD_DIR}/post.js"
end

file "#{BUILD_DIR}/mrbtest.js" => "#{BUILD_DIR}/mrbtest.bc" do |t|
  sh "#{LD} #{BUILD_DIR}/mrbtest.bc -o #{BUILD_DIR}/mrbtest.js -s TOTAL_MEMORY=33554432 #{LDFLAGS.join(' ')}"
end

file "#{BUILD_DIR}/mrbtest.bc" => "#{MRBTEST_FILE}" do |t|
  sh "cp #{MRBTEST_FILE} #{BUILD_DIR}/mrbtest.bc"
end
