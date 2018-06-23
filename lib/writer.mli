(******************************************************************************)
(*     Copyright (C) OCamlPro SAS                                             *)
(******************************************************************************)

val safe_folder : string -> unit

val write_file : string -> string -> unit

val write_block : string -> Types.block -> unit

val write_trans : string -> bool -> Types.transaction -> unit

val save_database : Types.database -> string -> unit
