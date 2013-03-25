/*
 * main - main file used for testing
 */

#include <stdio.h>
#include <stdlib.h>

#include "mruby.h"
#include "mruby/irep.h"
#include "mruby/dump.h"
#include "mruby/string.h"
#include "mruby/proc.h"

int webruby_internal_run(mrb_state* mrb);

int main(int argc, char *argv[])
{
  mrb_state *mrb;
  int ret = EXIT_SUCCESS;

  /* create new interpreter instance */
  mrb = mrb_open();
  if (mrb == NULL) {
    fprintf(stderr, "Invalid mrb_state, exiting test driver.\n");
    return EXIT_FAILURE;
  }

  /* load bytecode */
  webruby_internal_run(mrb);
  if (mrb->exc) {
    /* an exception occurs */
    fprintf(stderr, "An exception occurs when running mruby bytecodes!\n");
    mrb_p(mrb, mrb_obj_value(mrb->exc));
    mrb->exc = 0;
    ret = EXIT_FAILURE;
  }
  mrb_close(mrb);

  return ret;
}
