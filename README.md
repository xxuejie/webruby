# Warning

In fact, I've been thinking about webruby's future: the whole development & debugging flow feels just a nightmare. Sometimes I won't want to work on this myself, so how can I expect others to use this? The tooling support for other projects in this field is so great, that we really can't expect developers would fall in love with this unconditionally.

So right now, I more consider this to be a demonstration of what we can achieve by combining emscripten and mruby. While I will continue to support it when certain bugs arise, I advise you to consider it carefully before using it in production.

# Introduction

This project brings mruby to the browser. It uses [emscripten]
(https://github.com/kripken/emscripten) to compile the mruby source code into
JavaScript and runs in the browser.

# Build Status

Since emscripten SDK [does not provide](http://kripken.github.io/emscripten-site/docs/getting_started/downloads.html#linux) pre-built binaries for Linux, we cannot use Travis CI right now. We want to be nice and don't try to rebuild whole LLVM each time we are pushing new code :)

# How to Install

Webruby now depends on [emsdk](http://kripken.github.io/emscripten-site/docs/getting_started/downloads.html) to provide emscripten and LLVM infrustructure. To install webruby, following the following steps:

1. Install emsdk following instructions at [here](http://kripken.github.io/emscripten-site/docs/getting_started/downloads.html)
2. Install latest incoming version of emscripten sdk(right now webruby still depends on code from incoming branch of emscripten, once this goes into a release version, we will lock the version for better stability)
3. Activate latest incoming version
4. Webruby should be able to pick up the correct version of emscripten from emsdk. If not, feel free to create an issue :)

# Notes

Thanks to @scalone and @sadasant, webruby is already used in production: http://rubykaigi.org/2014/presentation/S-ThiagoScalone-DanielRodriguez

However, you might still want to give it a full test before using it in production :)

# Demos

* [webruby irb](http://joshnuss.github.io/mruby-web-irb/) - A nice-looking full-fledged webruby irb. Thanks to @joshnuss for his work!
* [Webruby tutorial](http://qiezi.me/projects/webruby-tutorial/) - minimal example of webruby project, a full description is at [here](http://blog.qiezi.me/posts/84789-webruby-1-2-3-tutorial)
* [mruby](http://qiezi.me/projects/mruby-web-irb/mruby.html) - This is only a minimal demo of web irb, if you want to try out mruby in a browser, I strongly suggest the demo above.
* [geometries](http://qiezi.me/projects/webgl/geometries.html) - a WebGL example using webruby, [mruby-js](https://github.com/xxuejie/mruby-js) and [three.js](https://github.com/mrdoob/three.js/). **NOTE**: from a practical point of view, I agree that this can be easily implemented using JS. However, this demo shows how easy it is to interact with the JavaScript environment using Ruby.

# License

This project is distributed under the MIT License. See LICENSE for further details.
