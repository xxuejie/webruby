/*
 * driver - driver for loading mruby source code
 */

#include <stdio.h>

#include "mruby.h"
#include "mruby/irep.h"

/* The generated mruby bytecodes are stored in this array */
extern const char app_irep[];

int webruby_internal_run(mrb_state* mrb)
{
  mrb_load_irep(mrb, app_irep);
  return (mrb->exc == NULL) ? (0) : (1);
}
