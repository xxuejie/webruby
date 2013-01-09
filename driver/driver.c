/*
 * driver - driver for loading mruby source code
 */

#include <stdio.h>

#include "mruby.h"
#include "mruby/compile.h"
#include "mruby/irep.h"

/* The generated mruby bytecodes are stored in this array */
extern const char app_irep[];

int webruby_internal_run(mrb_state* mrb)
{
  mrb_load_irep(mrb, app_irep);
  return (mrb->exc == NULL) ? (0) : (1);
}

int webruby_internal_run_bytecode(mrb_state* mrb, const char *bc)
{
  mrb_load_irep(mrb, bc);
  return (mrb->exc == NULL) ? (0) : (1);
}

int webruby_internal_run_source(mrb_state* mrb, const char *s)
{
  mrb_load_string(mrb, s);
  return (mrb->exc == NULL) ? (0) : (1);
}
