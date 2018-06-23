(******************************************************************************)
(*     Copyright (C) OCamlPro SAS                                             *)
(******************************************************************************)

open Types
open Helpers
open Pervasives

let main () =
  Random.self_init();

  let genese = get_genesis.g_block.block_ctt in


  let rec calcul_valid_hash block =
    let (chaine, hash) = block_content_to_string block in
    if sufficient_pow block.b_pow hash then
      block
    else
      let block = {block with b_nonce = Random.bits()} in 
      calcul_valid_hash block
  in
  

  let rec next_block block =
    let (chaine, hash) = block_content_to_string block in
    let b_previous = {b_level = block.b_previous.b_level + 1 ; b_id = hash} in
    let temp = mk_block_content (Options.miner) ["jesuisunelicorne"] b_previous 0 pow_challenge in
    let result = calcul_valid_hash temp in

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

    next_block result
  in

  next_block genese
