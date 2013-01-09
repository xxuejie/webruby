file "#{MRBC}" => :libmruby
file "#{LIBMRUBY_FILE}" => :libmruby
file "#{MRBTEST_FILE}" => :libmruby_test

desc "build mruby library"
task :libmruby do |t|
  sh "cd #{MRUBY_DIR} && CONFIG=#{MRUBY_BUILD_CONFIG} ./minirake #{LIBMRUBY}"
end

desc "mruby test library"
task :libmruby_test do |t|
  sh "cd #{MRUBY_DIR} && CONFIG=#{MRUBY_BUILD_CONFIG} ./minirake #{MRBTEST}"
end

desc "clean mruby library"
task :libmruby_clean do |t|
  sh "cd #{MRUBY_DIR} && CONFIG=#{MRUBY_BUILD_CONFIG} ./minirake clean"
end
