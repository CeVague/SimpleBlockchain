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
    let db = blockchain.db in

    
    let acc, trans = apply_pending_transactions db.pending_trans db.accounts [] in
    let trans_id = List.map (fun t -> t.t_id) trans in 

    print_string "Transactions à faire :\n";
    print_string (list_trans_to_string trans);
    print_newline ();
    print_string "\n\n";


    let info, content = block.block_info, block.block_ctt in
    let (chaine, hash) = block_content_to_string content in
    let temp = mk_block_content (Options.miner) trans_id info 0 pow_challenge in
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

    let acc_len = List.length acc in

    let db = {
      blocks = (block_result :: db.blocks);
      trans = List.append db.trans trans;
      pending_trans = [
        random_transaction acc_len;
        random_transaction acc_len;
        random_transaction acc_len;
        random_transaction acc_len;
        random_transaction acc_len;
        random_transaction acc_len; 
      ];
      accounts = acc;
    } in

    next_block {blockchain with db = db} block_result
  in

  next_block blockchain blockchain.genesis.g_block
