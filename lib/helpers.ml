(******************************************************************************)
(*     Copyright (C) OCamlPro SAS                                             *)
(******************************************************************************)

open Types
open Format

let block_reward = 10

let pow_challenge = 5

let hash_string s = Digest.string s |> Digest.to_hex

let hash_file s = Digest.file s |> Digest.to_hex


let sufficient_pow pow b_hash =
  let rec aux pow b_hash =
    if pow == 0 then 
      true
    else
      let first_char = String.get b_hash 0 in
      let next_hash = String.sub b_hash 1 ( (String.length b_hash)-1) in
      if Char.equal first_char '0' then
        aux (pow - 1) next_hash
      else 
        false
  in
  aux pow b_hash


let blocks_dir wdir =
  wdir ^ "/blocks"


let transactions_dir wdir ~pending =
  wdir ^ (if pending then "/pending-transactions" else "transactions")


let accounts_dir wdir =
  wdir ^ "/accounts"


let empty_blockchain genesis =
  {
    genesis = genesis;
    db = {
      blocks = [];
      trans = [];
      pending_trans = [];
      accounts = [];
    };
    peers_db = Util.MS.empty
  }


let mk_block_content b_miner b_transactions previous b_nonce b_pow =
  {
    b_previous = previous;
    b_miner = b_miner;
    b_pow = b_pow;
    b_date = Util.Date.now();
    b_nonce = b_nonce;
    b_transactions = b_transactions
  }


let transaction_to_string trans =
  let string_of_trans =
    "from " ^ trans.t_from ^ "\n"
    ^ "to " ^ trans.t_to ^ "\n"
    ^ "amount " ^ string_of_int trans.t_amount ^ " units\n"
    ^ "fees " ^ string_of_int trans.t_fees ^ " units\n"
  in
  let hash_of_trans = hash_string string_of_trans in
  (string_of_trans, hash_of_trans)


let rec list_trans_to_string list_trans =
  match list_trans with
  | [] -> ""
  | e::s -> " " ^ e ^ (list_trans_to_string s)


let block_content_to_string b_content =
  let string_of_block =
    "previous " ^ string_of_int b_content.b_previous.b_level ^ "." ^ b_content.b_previous.b_id ^ "\n"
    ^ "miner " ^ b_content.b_miner ^ "\n"
    ^ "pow " ^ string_of_int b_content.b_pow ^ "\n"
    ^ "date " ^ Util.Date.to_string b_content.b_date ^ "\n"
    ^ "nonce " ^ string_of_int b_content.b_nonce ^ "\n"
    ^ "transactions" ^ list_trans_to_string b_content.b_transactions ^ "\n"
  in
  let hash_of_block = hash_string string_of_block in
  (string_of_block, hash_of_block)


let get_genesis =
  {
    g_block = 
      {
        block_info = {b_level= -1 ; b_id = "---"};
        block_ctt = {
          b_previous = {b_level= -1 ; b_id = "---"};
          b_miner = "God";
          b_pow = 0;
          b_date = Util.Date.of_string "Mon-Jun-12--11:02:03--+00-2000";
          b_nonce = 0;
          b_transactions = []};};
    g_accounts = []}


let check_chain_of_blocks b_list genesis =
  (* TODO *)
  assert false
