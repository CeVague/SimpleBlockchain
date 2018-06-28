(******************************************************************************)
(*     Copyright (C) OCamlPro SAS                                             *)
(******************************************************************************)

open Types
open Helpers
open Pervasives

let main () =
  Random.self_init();
  
  let blockchain = empty_blockchain get_genesis in

  let rec next_block blockchain block =
    let info, content = block.block_info, block.block_ctt in
    let (chaine, hash) = block_content_to_string content in
    let temp = mk_block_content (Options.miner) ["jesuisunelicorne"] info 0 pow_challenge in
    let result = calcul_valid_hash temp in
    let block_result = {block_info = {b_level = info.b_level + 1; b_id = hash}; block_ctt = result} in

    print_string "Block précédent :\n";
    print_string chaine;
    print_string "\nHash : ";
    print_string hash;
    print_string "\n\n";

    let (chaine, hash) = block_content_to_string result in
    print_string "Block suivant :\n";
    print_string chaine;
    print_string "\nHash : ";
    print_string hash;
    print_string "\n\n\n\n";
    print_newline ();

    let db = blockchain.db in
    let db = {
      blocks = (block_result :: db.blocks);
      trans = db.trans;
      pending_trans = db.pending_trans;
      accounts = db.accounts;
    } in

    next_block {blockchain with db = db} block_result
  in

  next_block blockchain blockchain.genesis.g_block
