(function() {
  var global = (typeof window === 'object') ? (window) : (global);
  global.WEBRUBY = global.WEBRUBY || {};
  var webruby = global.WEBRUBY;

  if (!webruby.open) {
    webruby.open = _mrb_open;
  }

  if (!webruby.close) {
    webruby.close = _mrb_close;
  }

  if (!webruby.run) {
    webruby.run = _webruby_internal_run;
  }

  if (!webruby.run_bytecode) {
    webruby.run_bytecode = function(mrb, bc) {
      var stack = Runtime.stackSave();
      var addr = Runtime.stackAlloc(bc.length);
      var ret;
      writeArrayToMemory(bc, addr);

      ret = _mrb_load_irep(mrb, addr);

      Runtime.stackRestore(stack);
      return ret;
    };
  }

  if (!webruby.run_source) {
    webruby.run_source = function(mrb, src) {
      var stack = Runtime.stackSave();
      var addr = Runtime.stackAlloc(bc.length);
      var ret;
      writeStringToMemory(bc, addr);

      ret = _mrb_load_string(mrb, addr);

      Runtime.stackRestore(stack);
      return ret;
    }
  }
}) ();
