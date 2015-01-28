BASE_DIR = File.expand_path(File.join(File.dirname(__FILE__),
                                      %w[.. ..]))
MRUBY_DIR = File.join(BASE_DIR, %w[modules mruby])
DRIVER_DIR = File.join(BASE_DIR, %w[driver])
SCRIPTS_DIR = File.join(BASE_DIR, %w[scripts])

# for compatibility with mruby
def root
  MRUBY_DIR
end

emscripten_dir = ENV["EMSCRIPTEN"]
unless emscripten_dir
  # Read ~/.emscripten if needed
  file = File.join(ENV["HOME"], ".emscripten")
  if File.exists?(file)
    File.readlines(file).each do |line|
      m = line.match(/EMSCRIPTEN_ROOT='([^']+)'/)
      if m
        emscripten_dir = m[1]
      end
    end
    ENV["EMSCRIPTEN"] = emscripten_dir
  end
end

unless emscripten_dir && emscripten_dir.length > 0
  puts <<__EOF__
WARNING: We found out that you have not configured emscripten. Please
install emsdk followings steps at http://kripken.github.io/emscripten-site/
and rerun this command later.
__EOF__
  exit(1)
end

EMCC = File.join(emscripten_dir, 'emcc')
EMXX = File.join(emscripten_dir, 'em++')
EMLD = File.join(emscripten_dir, 'emcc')
EMAR = File.join(emscripten_dir, 'emar')

# TODO: maybe change these two to functions?
SCRIPT_GEN_POST = File.join(SCRIPTS_DIR, "gen_post.rb")
SCRIPT_GEN_GEMS_CONFIG = File.join(SCRIPTS_DIR, "gen_gems_config.rb")
SCRIPT_GEN_REQUIRE = File.join(SCRIPTS_DIR, "gen_require.rb")

EMCC_CFLAGS = "-I#{MRUBY_DIR}/include"

LIBMRUBY = "mruby/emscripten/lib/libmruby.a"
MRBTEST = "mruby/emscripten/test/mrbtest"
MRBC = "mruby/host/bin/mrbc"

# TODO: change this to a gem dependency
MRUBYMIX = File.join(BASE_DIR, %w[modules mrubymix bin mrubymix])

unless File.exists?(File.join(Dir.home, ".emscripten"))
  puts <<__EOF__
WARNING: We found out that you have never run emscripten before, since
emscripten needs a little configuration, we will run emcc here once and
exit. Please follow the instructions given by emcc. When it is finished,
please re-run rake.
__EOF__

  exec(EMCC)
end

if `uname -a`.downcase.index("cygwin")
  ENV['CYGWIN'] = 'nodosfilewarning'
end
