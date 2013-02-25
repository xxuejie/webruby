file "#{MRBC}" => :libmruby
file "#{LIBMRUBY_FILE}" => :libmruby
file "#{MRBTEST_FILE}" => :libmruby_test

desc "build mruby library"
task :libmruby do |t|
  sh "cd #{MRUBY_DIR} && EMSCRIPTEN_DIR=#{EMSCRIPTEN_DIR} MRUBY_CONFIG=#{WEBRUBY_BUILD_CONFIG} ./minirake #{MRUBY_DIR}/#{LIBMRUBY}"
end

desc "mruby test library"
task :libmruby_test do |t|
  sh "cd #{MRUBY_DIR} && EMSCRIPTEN_DIR=#{EMSCRIPTEN_DIR} MRUBY_CONFIG=#{WEBRUBY_BUILD_CONFIG} ./minirake #{MRUBY_DIR}/#{MRBTEST}"
end

desc "clean mruby library"
task :libmruby_clean do |t|
  sh "cd #{MRUBY_DIR} && EMSCRIPTEN_DIR=#{EMSCRIPTEN_DIR} MRUBY_CONFIG=#{WEBRUBY_BUILD_CONFIG} ./minirake clean"
end
