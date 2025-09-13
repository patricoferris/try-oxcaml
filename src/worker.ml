let () =
  Js_of_ocaml_compiler.Config.set_effects_backend `Disabled;
  print_endline "Backend is disabled for effects";
  Js_top_worker.Worker.run ()
