/*
 * driver - driver for loading mruby source code
 */

#include <stdio.h>

#include "mruby.h"
#include "mruby/compile.h"
#include "mruby/irep.h"

/* The generated mruby bytecodes are stored in this array */
extern const char app_irep[];

static int check_and_print_errors(mrb_state* mrb)
{
  if (mrb->exc) {
    mrb_p(mrb, mrb_obj_value(mrb->exc));
    return 1;
  }
  return 0;
}

int webruby_internal_run(mrb_state* mrb)
{
  mrb_load_irep(mrb, app_irep);
  return check_and_print_errors(mrb);
}

int webruby_internal_run_bytecode(mrb_state* mrb, const char *bc)
{
  mrb_load_irep(mrb, bc);
  return check_and_print_errors(mrb);
}

int webruby_internal_run_source(mrb_state* mrb, const char *s)
{
  mrb_load_string(mrb, s);
  return check_and_print_errors(mrb);
}
