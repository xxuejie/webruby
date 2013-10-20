desc "create build output directory"
directory Webruby.build_dir

desc "cleanup all generated files"
task :clean do |t|
  sh "rm -rf #{Webruby.build_dir}"
end

task :debug do |t|
  puts Webruby::build_dir
  puts Webruby::App.config.build_dir
  puts MRUBY_DIR
  puts EMSCRIPTEN_DIR
end

task :default => :js
task :js => "#{Webruby.build_dir}/#{Webruby::App.config.output_name}"

task :mrbtest => "#{Webruby.build_dir}/mrbtest.js" do |t|
  sh "node #{Webruby.build_dir}/mrbtest.js"
end
