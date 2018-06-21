(******************************************************************************)
(*     Copyright (C) OCamlPro SAS                                             *)
(******************************************************************************)
open Format
open Util

let fmt = err_formatter

let usage = "usage: mbc [options]"

let dir = ref ""
let miner = ref ""
let genesis = ref ""
let peers = ref SS.empty
let debug = ref false
let log = ref false
let mono_memory = ref false
let mono_disk = ref false

let add_peer p =
  peers := Util.SS.add p !peers

let spec = [
  "-working-dir",
  Arg.Set_string dir,
  " Set working dir";

  "-genesis",
  Arg.Set_string genesis,
  " Set path to genesis dir";

  "-mono-memory",
  Arg.Set mono_memory,
  " Emulate mbc in memory without peers";

  "-mono-disk",
  Arg.Set mono_disk,
  " Emulate mbc without peers, and save/load database to/from disk";

  "-peer",
  Arg.String add_peer,
  " Add a working directory of a new peer";

  "-miner",
  Arg.Set_string miner,
  " Miner associated to this node (will be <-> account)";

  "-debug",
  Arg.Set debug,
  " Activate debug flag";

  "-log",
  Arg.Set log,
  " Log main actions"

]

let () =
  Arg.parse
    spec
    (fun s->
       fprintf fmt "Don't know what to do with %S@." s;
       eprintf "%s@." usage;
       exit 1)
    usage

let debug = !debug
let log = !log
let dir () =
  if String.equal !dir "" then
    begin
      Format.eprintf "-working-dir flag should be set@.";
      assert false
    end;
  !dir

let mode = match !mono_memory, !mono_disk with
  | true , false -> Mono_memory
  | false, true  -> Mono_disk
  | false, false -> Multi
  | true , true  ->
    Format.eprintf "Cannot set both mono-memory and mono-disk@.";
    exit 1


let peers () =
  if Util.SS.is_empty !peers then
    begin
      Format.eprintf
        "At least one peer with -peer option should be provided@.";
      assert false
    end;
  !peers

let genesis = !genesis
let miner =
  if String.equal !miner "" then
    begin
      Format.eprintf "-miner flag should be set@.";
      assert false
    end;
  !miner
