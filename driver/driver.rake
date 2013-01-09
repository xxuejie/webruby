# Rakefile for webruby driver code

file "#{BUILD_DIR}/main.o" => "#{DRIVER_DIR}/main.c" do |t|
  sh "#{CC} #{CFLAGS.join(' ')} #{DRIVER_DIR}/main.c -o #{BUILD_DIR}/main.o"
end
