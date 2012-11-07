/*
** main.c - entrypoint for the mruby experiment in the browser
**
** This source code is take from
** http://geekmonkey.org/articles/36-an-introduction-to-mini-ruby.
** The copyright belongs to the original author, Fabian Becker.
*/
#include <stdlib.h>
#include <stdio.h>

#include <mruby.h>
#include <mruby/compile.h>

int main(void)
{
  mrb_state *mrb = mrb_open();
  char code[] = "5.times { puts 'Ruby is awesome!' }";

  mrb_load_string(mrb, code);
  return 0;
}
