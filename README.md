# Introduction

This project brings mruby to the browser. It uses [emscripten]
(https://github.com/kripken/emscripten) to compiles the mruby source code into
JavaScript and runs in the browser.

Please refer to this [tutorial](http://qiezi.me/2013/01/09/webruby-1-2-3-tutorial/) for how to use webruby.

# Notes

This project is still in a immature state! It still contains a lot of bugs and I'm now working to fix them. Feel free to write to me(xxuejie@gmail.com) if you have any comments or find any bugs. I would really appreciate it:)

**For Mac users**: The latest version of emscripten uses `python2` as the default python interpreter. If you are using a Mac and rely on the default python. Please add a link from `python` to `python2` before building:

    $ sudo ln -s /usr/bin/python /usr/bin/python2

# License

This project is distributed under the MIT License. See LICENSE for further details.
