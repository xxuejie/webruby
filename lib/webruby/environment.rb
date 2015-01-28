BASE_DIR = File.expand_path(File.join(File.dirname(__FILE__),
                                      %w[.. ..]))
MRUBY_DIR = File.join(BASE_DIR, %w[modules mruby])
DRIVER_DIR = File.join(BASE_DIR, %w[driver])
SCRIPTS_DIR = File.join(BASE_DIR, %w[scripts])

# for compatibility with mruby
def root
  MRUBY_DIR
end

EMSCRIPTEN_DIR = ENV["EMSCRIPTEN"]
unless EMSCRIPTEN_DIR
  # Read ~/.emscripten if needed
  if File.exists?("~/.emscripten")
    File.read("~/.emscripten").each do |line|
      m = line.match(/EMSCRIPTEN_ROOT='([^']+)'/)
      if m
        EMSCRIPTEN_DIR = m[1]
      end
    end
    ENV["EMSCRIPTEN"] = EMSCRIPTEN_DIR
  end
end

unless EMSCRIPTEN_DIR && EMSCRIPTEN_DIR.length > 0
  puts <<__EOF__
WARNING: We found out that you have not configured emscripten. Please
install emsdk followings steps at http://kripken.github.io/emscripten-site/
and rerun this command later.
__EOF__
  exit(1)
end

EMCC = File.join(EMSCRIPTEN_DIR, 'emcc')
EMXX = File.join(EMSCRIPTEN_DIR, 'em++')
EMLD = File.join(EMSCRIPTEN_DIR, 'emcc')
EMAR = File.join(EMSCRIPTEN_DIR, 'emar')

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
