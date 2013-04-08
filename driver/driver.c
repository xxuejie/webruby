/*
 * driver - driver for loading mruby source code
 */

#include <stdint.h>
#include <stdio.h>

#include "mruby.h"
#include "mruby/compile.h"
#include "mruby/irep.h"

/* The generated mruby bytecodes are stored in this array */
extern const uint8_t app_irep[];

/*
 * Print levels:
 * 0 - Do not print anything
 * 1 - Print errors only
 * 2 - Print errors and results
 */
static int check_and_print_errors(mrb_state* mrb, mrb_value result,
                                  int print_level)
{
  if (mrb->exc && (print_level > 0)) {
    mrb_p(mrb, mrb_obj_value(mrb->exc));
    mrb->exc = 0;
    return 1;
  }

  if (print_level > 1) {
    mrb_p(mrb, result);
  }
  return 0;
}

int webruby_internal_run_bytecode(mrb_state* mrb, const uint8_t *bc,
                                  int print_level)
{
  return check_and_print_errors(mrb, mrb_load_irep(mrb, bc), print_level);
}

int webruby_internal_run(mrb_state* mrb, int print_level)
{
  return webruby_internal_run_bytecode(mrb, app_irep, print_level);
}

int webruby_internal_run_source(mrb_state* mrb, const char *s, int print_level)
{
  return check_and_print_errors(mrb, mrb_load_string(mrb, s), print_level);
}
