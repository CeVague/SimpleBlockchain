(******************************************************************************)
(*     Copyright (C) OCamlPro SAS                                             *)
(******************************************************************************)

open Types

let () = match Options.mode with
  | Util.Mono_memory -> Mono_memory.main ()
  | Util.Mono_disk   -> Mono_disk.main ()
  | Util.Multi       -> Multi.main ()

