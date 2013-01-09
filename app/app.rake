# Rakefile for mruby application code

ENTRYPOINT_FILE = "#{APP_DIR}/app.rb"
app_files = Dir.glob("#{APP_DIR}/*.rb")

file "#{BUILD_DIR}/app.o" => "#{BUILD_DIR}/app.c" do |t|
  sh "#{CC} #{CFLAGS.join(' ')} #{BUILD_DIR}/app.c -o #{BUILD_DIR}/app.o"
end

file "#{BUILD_DIR}/app.c" => ["#{BUILD_DIR}/rbcode.c",
                               "#{DRIVER_DIR}/driver.c"] do |t|
  sh "cat #{DRIVER_DIR}/driver.c #{BUILD_DIR}/rbcode.c > #{BUILD_DIR}/app.c"
end

file "#{BUILD_DIR}/rbcode.c" => ["#{BUILD_DIR}/rbcode.rb", "#{MRBC}"] do |t|
  sh "#{MRBC} -Bapp_irep -o#{BUILD_DIR}/rbcode.c #{BUILD_DIR}/rbcode.rb"
end

file "#{BUILD_DIR}/rbcode.rb" => app_files do |t|
  # Puts the entrypoint file at the end of the list
  if (i = app_files.index(ENTRYPOINT_FILE))
    last_i = app_files.length - 1
    app_files[i], app_files[last_i] = app_files[last_i], app_files[i]
  end

  sh "cat #{app_files.join(' ')} > #{BUILD_DIR}/rbcode.rb"
end
