BASE_DIR = File.expand_path(File.join(File.dirname(__FILE__),
                                      %w[.. ..]))
EMSCRIPTEN_DIR = File.join(BASE_DIR, %w[modules emscripten])
MRUBY_DIR = File.join(BASE_DIR, %w[modules mruby])
DRIVER_DIR = File.join(BASE_DIR, %w[driver])
SCRIPTS_DIR = File.join(BASE_DIR, %w[scripts])

# for compatibility with mruby
def root
  MRUBY_DIR
end

EMCC = File.join(EMSCRIPTEN_DIR, 'emcc')
EMLD = File.join(EMSCRIPTEN_DIR, 'emcc')
EMAR = File.join(EMSCRIPTEN_DIR, 'emar')

# TODO: maybe change these two to functions?
SCRIPT_GEN_POST = File.join(SCRIPTS_DIR, "gen_post.rb")
SCRIPT_GEN_GEMS_CONFIG = File.join(SCRIPTS_DIR, "gen_gems_config.rb")

EMCC_CFLAGS = "-I#{MRUBY_DIR}/include"

LIBMRUBY = "mruby/emscripten/lib/libmruby.a"
MRBTEST = "mruby/emscripten/test/mrbtest"
MRBC = "mruby/host/bin/mrbc"

# the new le32-unknown-nacl triple has a limitation which will break
# mruby build, we have to resort to the old i386 triple.
ENV['EMCC_LLVM_TARGET'] = 'i386-pc-linux-gnu'

# Use customized emscripten config file
ENV['EM_CONFIG'] = File.join(BASE_DIR, %w[config emscripten.py])

# TODO: change this to a gem dependency
MRUBYMIX = File.join(BASE_DIR, %w[modules mrubymix bin mrubymix])
