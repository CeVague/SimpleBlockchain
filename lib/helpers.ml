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


let account_to_string account =
  assert false


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






let random_transaction =
  let rec generate_x_y n =
    let x = Random.int 2 in
    let y = Random.int n in
    if x != y then (string_of_int x, string_of_int y) else generate_x_y n
  in

  let (x,y) = generate_x_y 4 in
  let amount = Random.int 100 in
  let fees = amount / 10 in

  let trans = {t_id = ""; t_from = x; t_to = y; t_fees = fees; t_amount = amount} in
  let (str,hash) = transaction_to_string trans  in
  print_string (str ^ " : DONE");

  {trans with t_id = hash}



let empty_blockchain genesis =
  {
    genesis = genesis;
    db = {
      blocks = [];
      trans = [];
      pending_trans = [
        random_transaction; 
        random_transaction; 
        random_transaction; 
        random_transaction; 
        random_transaction;
      ];
      accounts = [
        {acc_id = "0"; acc_balance = 1000};
        {acc_id = "1"; acc_balance = 1000};
      ]
    };
    peers_db = Util.MS.empty
  }

let rec update_l_acc acc accounts = match accounts with 
  | [] -> [acc]
  | a :: tail -> if a.acc_id == acc.acc_id then acc :: tail 
    else a :: update_l_acc acc tail

let make_transaction trans accounts =
  let rec update_acc_source accs = match accs with
    | [] -> failwith "Account not found for transaction %s" trans.t_id
    | acc :: tail -> if String.equal acc.acc_id trans.t_from then
        if acc.acc_balance >= trans.t_amount+trans.t_fees then
          {acc with acc_balance = acc.acc_balance - trans.t_amount+trans.t_fees}
        else failwith "Not enough balance in account %s" acc.acc_id
      else update_acc_source tail
  in

  let rec update_acc_dest accs = match accs with
    | [] ->
      begin
        let account = {
          acc_id = "acc_id_xxx";
          acc_balance = trans.t_amount} in
        account
      end
    | acc :: tail ->
      if acc.acc_id == trans.t_to then
        {acc with acc_balance = acc.acc_balance + trans.t_amount}
      else update_acc_dest tail 
  in

  let updated_accs = update_l_acc (update_acc_source accounts) accounts in
  update_l_acc (update_acc_dest updated_accs) updated_accs

let rec add_blck_in_blcks b blocks =
  match blocks with
  | [] -> [b]
  | t :: tail -> t :: add_blck_in_blcks b tail

let rec add_tran_in_trans tran trans =
  match trans with
  | [] -> [tran]
  | t :: tail -> t :: add_tran_in_trans tran tail

let rec make_pending_transactions (*block*) db = 
  match db.pending_trans with
  | [] -> db
  | trans :: tail -> 
    (*let blcks = add_blck_in_blcks block db.blocks in*)
    let trns = add_tran_in_trans trans db.trans in
    let accs = make_transaction trans db.accounts in
    make_pending_transactions (*block*) {blocks = db.blocks; trans = trns; pending_trans = tail; accounts = accs}

let check_block_hash block =
  let (str,hash) = block_content_to_string block.block_ctt  in
  if String.equal hash block.block_info.b_id then true
  else failwith "Invalid hash for block %s" block.block_info.b_id

let check_trans_hash trans =
  let (str,hash) = transaction_to_string trans  in
  if String.equal hash trans.t_id then true
  else failwith "Invalid hash for transaction %s" trans.t_id

let rec find_trans tran_id trans = match trans with
  | [] -> failwith "Transaction not found!"
  | tran :: tail -> if tran_id == tran.t_id then tran
    else find_trans tran_id tail

let rec check_transactions t_list b_id =
  match t_list with
  | [] -> true
  | tran :: tail ->
    if true(*check_trans_hash (find_trans tran bc.db.trans)*) then
      begin
        check_transactions tail b_id
      end
    else failwith "Invalid transaction in block %s : %s" tran b_id 

let check_block block parent =
  let check_level =
    if block.block_info.b_level = parent.block_info.b_level + 1
    then true else failwith "Invalid level in block %s" block.block_info.b_id
  in

  check_transactions block.block_ctt.b_transactions block.block_info.b_id && check_block_hash block && check_level

let check_chain_of_blocks b_list genesis =
  let parent = genesis.g_block in
  let rec check_b_list l =
    match l with
    | [] -> true
    | block :: tail ->
      begin
        check_block block parent;
        let parent = block in
        check_b_list tail
      end in

  check_transactions genesis.g_block.block_ctt.b_transactions genesis.g_block.block_info.b_id && check_b_list b_list
