# Introduction

This is a top experiment trying to bring mruby to the browser. It uses [emscripten]
(https://github.com/kripken/emscripten) to compiles the mruby source code into
JavaScript and runs in the browser.

The build script and patches I wrote are licensed under the [MIT license]
(http://www.opensource.org/licenses/mit-license.php), the entrypoint file at
`src/main.c` is taken from [An Introduction to Mini Ruby]
(http://geekmonkey.org/articles/36-an-introduction-to-mini-ruby) and
belongs to the original author, Fabian Becker.

# How to use this

    $ git clone git://github.com/xxuejie/mruby-browser.git
    $ git submodule init
    $ git submodule update
    $ make applypatch
    $ make
    $ node build/mruby.js
    Ruby is awesome!
    Ruby is awesome!
    Ruby is awesome!
    Ruby is awesome!
    Ruby is awesome!

The `applypatch` target in Makefile applies a series of patches to the mruby source code, this only needs to be run once. After that you can simply use make to build the sources as long as there are no new patches added.

The default target generates a js file. You can also use the `webpage` target to generate a webpage:

    $ make webpage
    $ open build/mruby.html

# Notes

This is currently only an experiment! It may contains bugs. Feel free to write to me(xxuejie@gmail.com) if you have any comments or find any bugs. I would really appreciate it:)

