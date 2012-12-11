/*
 * driver - driver for loading mruby source code
 */

#include <stdio.h>

#include "mruby.h"
#include "mruby/irep.h"
#include "mruby/dump.h"
#include "mruby/string.h"
#include "mruby/proc.h"

/* The generated mruby bytecodes are stored in this array */
extern const char app_irep[];

int main(int argc, char *argv[])
{
  mrb_state *mrb;
  mrb_value return_value;
  int ret = EXIT_SUCCESS;

  /* create new interpreter instance */
  mrb = mrb_open();
  if (mrb == NULL) {
    fprintf(stderr, "Invalid mrb_state, exiting test driver.\n");
    return EXIT_FAILURE;
  }

  /* load bytecode */
  mrb_load_irep(mrb, app_irep);
  if (mrb->exc) {
    /* an exception occurs */
    fprintf(stderr, "An exception occurs when running mruby bytecodes!\n");
    mrb_p(mrb, return_value);
    mrb->exc = 0;
    ret = EXIT_FAILURE;
  }
  mrb_close(mrb);

  return ret;
}
