desc "create build output directory"
directory Webruby.build_dir

desc "cleanup all generated files"
task :clean => [:libmruby_clean] do |t|
  sh "rm -f #{Webruby.build_dir}/app.c #{Webruby.build_dir}/app.o #{Webruby.build_dir}/rbcode.rb #{Webruby.build_dir}/rbcode.c #{Webruby.build_dir}/main.o"
  sh "rm -f #{Webruby.build_dir}/gem_library.js #{Webruby.build_dir}/gem_append.js #{Webruby.build_dir}/gem_test_library.js #{Webruby.build_dir}/gem_test_append.js #{Webruby.build_dir}/functions #{Webruby.build_dir}/js_api.js"
  sh "rm -f #{Webruby.build_dir}/#{Webruby::App.config.output_name} #{Webruby.build_dir}/#{Webruby::App.config.output_name}.map"
  sh "rm -f #{Webruby.build_dir}/#{Webruby::App.config.executable_output_name} #{Webruby.build_dir}/#{Webruby::App.config.executable_output_name}.map"
  sh "rm -f #{Webruby.build_dir}/mrbtest.js #{Webruby.build_dir}/mrbtest.js.map #{Webruby.build_dir}/mrbtest.bc"
  sh "rm -f #{Webruby.build_dir}/mruby_build_config.rb"
end

task :debug do |t|
  puts Webruby::build_dir
  puts Webruby::App.config.build_dir
  puts MRUBY_DIR
  puts EMSCRIPTEN_DIR
end

task :default => :js
task :js => "#{Webruby.build_dir}/#{Webruby::App.config.output_name}"
task :js_bin => "#{Webruby.build_dir}/#{Webruby::App.config.executable_output_name}"

task :mrbtest => "#{Webruby.build_dir}/mrbtest.js" do |t|
  sh "node #{Webruby.build_dir}/mrbtest.js"
end
