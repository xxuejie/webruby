# `GEM` branch

I'm now working to make `webruby` a command-line based gem. You can use this gem to create a new project, build and run the final JS file. This helps us avoid relying on an `app` folder which would mess up the git staging area.

Now this is maintained in a separate branch since it is under heavy development, the APIs can be changed dramastically within hours. I will merge this to the master branch once I think it is stable.

# Introduction

This project brings mruby to the browser. It uses [emscripten]
(https://github.com/kripken/emscripten) to compile the mruby source code into
JavaScript and runs in the browser.

Please refer to this [tutorial](http://qiezi.me/2013/01/09/webruby-1-2-3-tutorial/) for how to use webruby.

# Build Status

[![Build Status](https://travis-ci.org/xxuejie/webruby.png)](https://travis-ci.org/xxuejie/webruby)
[![Build Status](https://drone.io/github.com/xxuejie/webruby/status.png)](https://drone.io/github.com/xxuejie/webruby/latest)


# Notes

Currently this is still a toy project. Though several demos have been created, it hasn't been used in a production environment. Feel free to play with this, but please give it a complete evaluation before using it in your real-world project.

**For Mac users**: The latest version of emscripten uses `python2` as the default python interpreter. If you are using a Mac and rely on the default python. Please add a link from `python` to `python2` before building:

    $ sudo ln -s /usr/bin/python /usr/bin/python2

# Demos

* [webruby irb](http://joshnuss.github.io/mruby-web-irb/) - A nice-looking full-fledged webruby irb. Thanks to @joshnuss for his work!
* [Webruby tutorial](http://qiezi.me/projects/webruby-tutorial/) - minimal example of webruby project, a full description is at [here](http://qiezi.me/2013/01/09/webruby-1-2-3-tutorial/)
* [mruby](http://qiezi.me/projects/mruby-web-irb/mruby.html) - This is only a minimal demo of web irb, if you want to try out mruby in a browser, I strongly suggest the demo above.
* [geometries](http://qiezi.me/projects/webgl/geometries.html) - a WebGL example using webruby, [mruby-js](https://github.com/xxuejie/mruby-js) and [three.js](https://github.com/mrdoob/three.js/). **NOTE**: from a practical point of view, I agree that this can be easily implemented using JS. However, this demo shows how easy it is to interact with the JavaScript environment using Ruby.

# License

This project is distributed under the MIT License. See LICENSE for further details.
