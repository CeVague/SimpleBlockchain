(******************************************************************************)
(*     Copyright (C) OCamlPro SAS                                             *)
(******************************************************************************)

open Format
open Types


let safe_folder path =
  if Sys.file_exists path then
    ()
  else
    Unix.mkdir path 0o777


let write_file path text =
  let channel = open_out path in
  output_string channel text;
  close_out channel


let write_block wdir b =
  let b_info, b_content = b.block_info, b.block_ctt in
  let text, hash = Helpers.block_content_to_string b_content in

  let path_dir =  Helpers.blocks_dir wdir in
  let path_file = path_dir ^ "/" ^ (string_of_int b_info.b_level) in

  safe_folder path_dir;
  write_file path_file text


let write_trans wdir pending trans =
  let text, hash = Helpers.transaction_to_string trans in

  let path_dir = Helpers.transactions_dir wdir pending in
  let path_file = path_dir ^ "/" ^ hash in

  safe_folder path_dir;
  write_file path_file text


let write_account wdir acc =
  let text, hash = Helpers.account_to_string acc in

  let path_dir = Helpers.accounts_dir wdir in
  let path_file = path_dir ^ "/" ^ acc.acc_id in

  safe_folder path_dir;
  write_file path_file text


let save_database db wdir =

  let _ = Sys.command ("rm -r " ^ (Helpers.transactions_dir wdir true)) in

  List.iter (write_block wdir) db.blocks;
  List.iter (write_trans wdir false) db.trans;
  List.iter (write_trans wdir true) db.pending_trans;
  List.iter (write_account wdir) db.accounts
