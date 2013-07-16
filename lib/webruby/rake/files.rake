file "#{Webruby.build_dir}/gem_library.js" => :gen_gems_config
file "#{Webruby.build_dir}/gem_append.js" => :gen_gems_config
file "#{Webruby.build_dir}/gem_test_library.js" => :gen_gems_config
file "#{Webruby.build_dir}/gem_test_append.js" => :gen_gems_config

task :gen_gems_config do |t|
  sh "ruby #{SCRIPT_GEN_POST} #{Webruby::App.config.loading_mode} #{Webruby.build_dir}/js_api.js"
  sh "ruby #{SCRIPT_GEN_GEMS_CONFIG} #{Webruby.build_config} #{Webruby.build_dir}/js_api.js #{Webruby.build_dir}/gem_library.js #{Webruby.build_dir}/gem_append.js #{Webruby.build_dir}/gem_test_library.js #{Webruby.build_dir}/gem_test_append.js #{Webruby.build_dir}/functions"
end

file "#{Webruby.build_dir}/rbcode.rb" => Webruby.rb_files do |t|
  sh "ruby #{MRUBYMIX} #{Webruby.entrypoint_file} #{Webruby.build_dir}/rbcode.rb"
end

file "#{Webruby.build_dir}/rbcode.c" => ["#{Webruby.build_dir}/rbcode.rb", :libmruby] do |t|
  sh "#{Webruby.build_dir}/#{MRBC} -Bapp_irep -o#{Webruby.build_dir}/rbcode.c #{Webruby.build_dir}/rbcode.rb"
end

file "#{Webruby.build_dir}/app.c" => ["#{Webruby.build_dir}/rbcode.c",
                                      "#{DRIVER_DIR}/driver.c"] do |t|
  sh "cat #{DRIVER_DIR}/driver.c #{Webruby.build_dir}/rbcode.c > #{Webruby.build_dir}/app.c"
end

file "#{Webruby.build_dir}/app.o" => "#{Webruby.build_dir}/app.c" do |t|
  sh "#{EMCC} #{EMCC_CFLAGS} #{Webruby::App.config.cflags} #{Webruby.build_dir}/app.c -o #{Webruby.build_dir}/app.o"
end

file "#{Webruby.build_dir}/main.o" => "#{DRIVER_DIR}/main.c" do |t|
  sh "#{EMCC} #{EMCC_CFLAGS} #{Webruby::App.config.cflags} #{DRIVER_DIR}/main.c -o #{Webruby.build_dir}/main.o"
end

file "#{Webruby.build_dir}/#{Webruby::App.config.output_name}" =>
  ["#{Webruby.build_dir}/app.o", :libmruby] +
  Webruby.gem_js_files do |t|
  func_arg = Webruby.get_exported_arg("#{Webruby.build_dir}/functions",
                                      Webruby::App.config.loading_mode,
                                      [])

  sh "#{EMLD} #{Webruby.build_dir}/app.o #{Webruby.build_dir}/#{LIBMRUBY} -o #{Webruby.build_dir}/#{Webruby::App.config.output_name} #{Webruby.gem_js_flags} #{func_arg} #{Webruby::App.config.ldflags}"
end

file "#{Webruby.build_dir}/#{Webruby::App.config.executable_output_name}" =>
  ["#{Webruby.build_dir}/main.o",
   "#{Webruby.build_dir}/app.o", :libmruby] +
  Webruby.gem_js_files do |t|
  func_arg = Webruby.get_exported_arg("#{Webruby.build_dir}/functions",
                                      Webruby::App.config.loading_mode,
                                      ['main'])

  sh "#{EMLD} #{Webruby.build_dir}/main.o #{Webruby.build_dir}/app.o #{Webruby.build_dir}/#{LIBMRUBY} -o #{Webruby.build_dir}/#{Webruby::App.config.executable_output_name} #{Webruby.gem_js_flags} #{func_arg} #{Webruby::App.config.ldflags}"
end

file "#{Webruby.build_dir}/mrbtest.bc" => :libmruby_test do |t|
  sh "cp #{Webruby.build_dir}/#{MRBTEST} #{Webruby.build_dir}/mrbtest.bc"
end

file "#{Webruby.build_dir}/mrbtest.js" =>
  ["#{Webruby.build_dir}/mrbtest.bc"] + Webruby.gem_test_js_files do |t|
  # loading mode 0 is necessary for mrbtest
  func_arg = Webruby.get_exported_arg("#{Webruby.build_dir}/functions",
                                      0, ['main'])

  sh "#{EMLD} #{Webruby.build_dir}/mrbtest.bc -o #{Webruby.build_dir}/mrbtest.js -s TOTAL_MEMORY=33554432 #{Webruby.gem_test_js_flags} #{func_arg} #{Webruby::App.config.ldflags}"
end
