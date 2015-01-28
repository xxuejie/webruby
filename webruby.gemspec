Gem::Specification.new do |s|
  s.name        =  'webruby'
  s.version     =  '0.9.1'
  s.date        =  '2015-01-28'
  s.summary     =  'webruby'
  s.description =  'compile your favourite Ruby source code for the browser!'
  s.author      =  'Xuejie Xiao'
  s.email       =  'xxuejie@gmail.com'
  s.homepage    =  'https://github.com/xxuejie/webruby'
  s.license     =  'MIT'

  s.bindir      =  'bin'
  s.executables << 'webruby'

  s.files       =  Dir['lib/**/*']
  s.files       += Dir['bin/**/*']
  s.files       += Dir['driver/**/*']
  s.files       += Dir['scripts/**/*']
  s.files       += Dir['templates/**/*']
  s.files       += Dir['modules/**/*']
end
