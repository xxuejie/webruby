# Introduction

This project brings mruby to the browser. It uses [emscripten]
(https://github.com/kripken/emscripten) to compiles the mruby source code into
JavaScript and runs in the browser.

# How to use this

    $ git clone git://github.com/xxuejie/webruby.git
    $ cd webruby
    $ git submodule init
    $ git submodule update
    $ make
    $ node build/mruby.js
    Ruby is awesome!
    Ruby is awesome!
    Ruby is awesome!
    Ruby is awesome!
    Ruby is awesome!

The entrypoint file is at `src/app.rb`, you can change this file or add new ruby files into this folder. When you finish editing, you can simply use `make` to compile the project.

While providing JavaScript file for Node.js, `webruby` can also generate html page for a browser:

    $ make webpage
    $ open build/mruby.html

**For Mac users**: The latest version of emscripten uses `python2` as the default python interpreter. If you are using a Mac and rely on the default python. Please add a link from `python` to `python2` before building:

    $ sudo ln -s /usr/bin/python /usr/bin/python2

# Notes

This project is still in a immature state! It still contains a lot of bugs and I'm now working to fix them. Feel free to write to me(xxuejie@gmail.com) if you have any comments or find any bugs. I would really appreciate it:)

# License

This project is distributed under the MIT License. See LICENSE for further details.
