(******************************************************************************)
(*     Copyright (C) OCamlPro SAS                                             *)
(******************************************************************************)

type mode =
  | Mono_memory
  | Mono_disk
  | Multi

module SS = Set.Make(String)
module MS = Map.Make(String)

module Date = struct
  module D = ODate.Unix
  let format = "%a-%b-%d--%T--%:::z-%Y"
  let parseR = match D.From.generate_parser format with
    | Some p -> p
    | None -> failwith "could not generate parser"
  let printer = match D.To.generate_printer format with
    | Some p -> p
    | None -> failwith "could not generate printer"

  type t = D.t
  let now () = D.now ()
  let to_string d = D.To.string ~tz:ODate.UTC printer d
  let of_string s = D.From.string parseR s

end
