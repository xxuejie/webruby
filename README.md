This is a top experiment trying to bring mruby to the browser.

Currently I'm using emscripten to compile mruby source code. I may
come back for a NaCl version when I have time.

The code is suffering from "RangeError: Maximum call stack size exceeded"
due to setjmp/longjmp issues in mruby. Planning to fix this soon, a viable
solution is at [here](https://github.com/replit/emscripted-ruby/commit/c78f8457817e1fd57f7f464ae9a8158b13dac371#ruby-1.8.7/eval.c).

