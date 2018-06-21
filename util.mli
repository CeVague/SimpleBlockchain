(******************************************************************************)
(*     Copyright (C) OCamlPro SAS                                             *)
(******************************************************************************)

type mode =
  | Mono_memory
  | Mono_disk
  | Multi

module SS : Set.S with type elt = String.t
module MS : Map.S with type key = String.t

module Date : sig
  type t
  val now : unit -> t
  val to_string : t -> string
  val of_string : string -> t
end
