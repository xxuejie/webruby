file "#{MRBC}" => :libmruby
file "#{LIBMRUBY_FILE}" => :libmruby

desc "build mruby library"
task :libmruby do |t|
  sh "cd #{MRUBY_DIR} && CONFIG=#{MRUBY_BUILD_CONFIG} ./minirake #{LIBMRUBY}"
end

