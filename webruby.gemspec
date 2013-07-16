Gem::Specification.new do |s|
  s.name = 'webruby'
  s.version = '0.1.0'
  s.date = '2013-07-16'
  s.summary = 'webruby'
  s.description = 'mruby compiler for compiling Ruby source code and C implementation To JavaScript'
  s.author = 'Xuejie Xiao'
  s.email = 'xxuejie@gmail.com'
  s.homepage = 'https://github.com/xxuejie/webruby'
  s.license = 'MIT'

  s.files = Dir['lib/**/*']
  s.files += Dir['driver/**/*']
  s.files += Dir['scripts/**/*']
  s.files += Dir['modules/**/*'].reject do |f|
    f['modules/emscripten/tests'] ||
    f['modules/emscripten/demos'] ||
    f['modules/emscripten/docs']
  end
end
