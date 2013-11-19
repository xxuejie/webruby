# Introduction

This project brings mruby to the browser. It uses [emscripten]
(https://github.com/kripken/emscripten) to compile the mruby source code into
JavaScript and runs in the browser.

Please refer to this [tutorial](http://blog.qiezi.me/posts/84789-webruby-1-2-3-tutorial) for how to use webruby.

# Build Status

[![Build Status](https://travis-ci.org/xxuejie/webruby.png)](https://travis-ci.org/xxuejie/webruby)
[![Build Status](https://drone.io/github.com/xxuejie/webruby/status.png)](https://drone.io/github.com/xxuejie/webruby/latest)

# Notes

Currently this is still a toy project. Though several demos have been created, it hasn't been used in a production environment. Feel free to play with this, but please give it a complete evaluation before using it in your real-world project.

**About LLVM**: Currently if you are installing LLVM using `homebrew`, the default version installed is `3.3`. However, `emscripten` only works with `3.2` nowadays. So you may want to go to [here](http://llvm.org/releases/download.html#3.2), download the binary pack for your OS, extracted and define a local environment variable `LLVM` containing the `bin` folder of the extracted files. This will tell `emscripten` to use this version of `LLVM`.

**For Mac users**: The latest version of emscripten uses `python2` as the default python interpreter. If you are using a Mac and rely on the default python. Please add a link from `python` to `python2` before building:

    $ sudo ln -s /usr/bin/python /usr/bin/python2

# Demos

* [webruby irb](http://joshnuss.github.io/mruby-web-irb/) - A nice-looking full-fledged webruby irb. Thanks to @joshnuss for his work!
* [Webruby tutorial](http://qiezi.me/projects/webruby-tutorial/) - minimal example of webruby project, a full description is at [here](http://blog.qiezi.me/posts/84789-webruby-1-2-3-tutorial)
* [mruby](http://qiezi.me/projects/mruby-web-irb/mruby.html) - This is only a minimal demo of web irb, if you want to try out mruby in a browser, I strongly suggest the demo above.
* [geometries](http://qiezi.me/projects/webgl/geometries.html) - a WebGL example using webruby, [mruby-js](https://github.com/xxuejie/mruby-js) and [three.js](https://github.com/mrdoob/three.js/). **NOTE**: from a practical point of view, I agree that this can be easily implemented using JS. However, this demo shows how easy it is to interact with the JavaScript environment using Ruby.

# License

This project is distributed under the MIT License. See LICENSE for further details.
