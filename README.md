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
    $ ./scripts/bootstrap
    $ node build/mruby.js
    Ruby is awesome!
    Ruby is awesome!
    Ruby is awesome!
    Ruby is awesome!
    Ruby is awesome!

If you make changes to the source code, you can simply use `make` to rebuild it. The default target generates a js file. You can also use the `webpage` target to generate a webpage:

    $ make webpage
    $ open build/mruby.html

# Notes

This is currently only an experiment! It may contains bugs. Feel free to write to me(xxuejie@gmail.com) if you have any comments or find any bugs. I would really appreciate it:)

