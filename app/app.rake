# Rakefile for mruby application code

APP_FILES = FileList.new("#{APP_DIR}/*.rb")

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

file "#{BUILD_DIR}/rbcode.rb" => [APP_FILES] do |t|
  sh "cat #{APP_FILES.join(' ')} > #{BUILD_DIR}/rbcode.rb"
end
