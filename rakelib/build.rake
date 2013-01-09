require 'functions'

file "#{BUILD_DIR}/mruby_exe.js" => ["#{BUILD_DIR}/main.o", "#{BUILD_DIR}/app.o", "#{BUILD_DIR}/gem_library.js", "#{LIBMRUBY_FILE}"] do |t|
  func_arg = get_exported_arg("#{BUILD_DIR}/functions", LOAD_MODE, ['main'])

  sh "#{LD} #{BUILD_DIR}/main.o #{BUILD_DIR}/app.o #{LIBMRUBY_FILE} -o #{BUILD_DIR}/mruby_exe.js --js-library #{BUILD_DIR}/gem_library.js #{func_arg}"
end

file "#{BUILD_DIR}/mruby.js" => ["#{BUILD_DIR}/app.o", "#{BUILD_DIR}/gem_library.js", "#{LIBMRUBY_FILE}"] do |t|
  func_arg = get_exported_arg("#{BUILD_DIR}/functions", LOAD_MODE, [])

  sh "#{LD} #{BUILD_DIR}/app.o #{LIBMRUBY_FILE} -o #{BUILD_DIR}/mruby.js --js-library #{BUILD_DIR}/gem_library.js #{func_arg}"
end

file "#{BUILD_DIR}/gem_library.js" => "#{LIBMRUBY_FILE}" do |t|
  sh "ruby scripts/gen_gems_config.rb #{MRUBY_BUILD_CONFIG} #{BUILD_DIR}/gem_library.js #{BUILD_DIR}/functions"
end
