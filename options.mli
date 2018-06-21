(******************************************************************************)
(*     Copyright (C) OCamlPro SAS                                             *)
(******************************************************************************)

val fmt : Format.formatter

val debug : bool
val log : bool
val dir : unit -> string
val genesis : string
val peers : unit -> Util.SS.t
val mode : Util.mode
val miner : string
