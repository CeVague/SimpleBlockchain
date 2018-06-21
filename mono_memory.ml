(******************************************************************************)
(*     Copyright (C) OCamlPro SAS                                             *)
(******************************************************************************)

open Types
open Helpers
open Pervasives

let main () =
  let genese = get_genesis.g_block.block_ctt in


  let rec calcul_valid_hash block =
    let (chaine, hash) = block_content_to_string block in
    if sufficient_pow block.b_pow hash then
      block
    else
      let block = {block with b_nonce = block.b_nonce + 1} in 
      calcul_valid_hash block
  in
  

  let rec next_block block =
    let (chaine, hash) = block_content_to_string block in
    let b_previous = {b_level = block.b_previous.b_level + 1 ; b_id = hash} in
    let temp = {  b_previous = b_previous;
                  b_miner = "monoblock_mem";
                  b_pow = pow_challenge;
                  b_date = Util.Date.now();
                  b_nonce = 0;
                  b_transactions = ["jesuisunelicorne"]} in
    let result = calcul_valid_hash temp in

    print_string "Block précédent :\n";
    print_string chaine;
    print_string "\nHash :";
    print_string hash;
    print_string "\n\n";

    let (chaine, hash) = block_content_to_string result in
    print_string "Block suivant :\n";
    print_string chaine;
    print_string "\nHash :";
    print_string hash;
    print_string "\n\n\n\n";
    print_newline ();

    next_block result
  in

  next_block genese
