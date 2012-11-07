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
