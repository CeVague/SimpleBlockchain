(******************************************************************************)
(*     Copyright (C) OCamlPro SAS                                             *)
(******************************************************************************)

open Types
open Format
open Options


let already_exist wdir =
  Sys.file_exists (Helpers.blocks_dir wdir)


let cut_string s start length =
  match length with
  | 0 ->
    let length = String.length s in
    String.sub s start (length - start)
  | n when n > 0 ->
    String.sub s start length
  | n when n < 0 ->
    let length = (String.length s) + length in
    String.sub s start (length - start)
  | _ -> assert false


let get_blocks wdir =
  let rec file_to_block files acc =
    match files with
    | -1 -> acc
    | i ->
      let ic = open_in (wdir ^ "/" ^ (string_of_int i)) in
      let b_previous = cut_string (input_line ic) (10 + (String.length (string_of_int (i-1)))) 0 in
      let b_miner = cut_string (input_line ic) 6 0 in
      let b_pow = cut_string (input_line ic) 4 0 in
      let b_date = cut_string (input_line ic) 5 0 in
      let b_nonce = cut_string (input_line ic) 6 0 in
      let b_transactions = cut_string (input_line ic) 12 0 in
      let tmp_ctt = 
        {b_previous = {
          b_level = (i-1);
          b_id = b_previous;
        };
        b_miner = b_miner;
        b_pow = int_of_string b_pow;
        b_date = Util.Date.of_string b_date;
        b_nonce = int_of_string b_nonce;
        b_transactions = Str.split (Str.regexp " +") b_transactions} in
      let _, hash = Helpers.block_content_to_string tmp_ctt in
      let tmp = {
        block_info = { b_level = i; b_id = hash};
        block_ctt = tmp_ctt
      } in
      close_in ic;
      file_to_block (i-1) (tmp :: acc)
  in

  file_to_block (Array.length (Sys.readdir wdir) -1) []


let get_transactions wdir =
  let files = 
    if not (Sys.file_exists wdir) then
      []
    else
      Array.to_list (Sys.readdir wdir)
  in

  let rec file_to_trans files acc =
    match files with
    | [] -> acc
    | e::s -> 
      let ic = open_in (wdir ^ "/" ^ e) in
      let t_from = cut_string (input_line ic) 5 0 in
      let t_to = cut_string (input_line ic) 3 0 in
      let t_amount = cut_string (input_line ic) 7 (-6) in
      let t_fees = cut_string (input_line ic) 5 (-6) in
      let tmp = {t_id=e;t_from=t_from;t_to=t_to;
                 t_fees = int_of_string t_fees;
                 t_amount = int_of_string t_amount} in
      close_in ic;
      file_to_trans s (tmp :: acc)
  in

  file_to_trans files []


let get_accounts wdir =
  
    let rec file_to_account files acc =
      match files with
      | [] -> acc
      | e::s -> 
        let ic = open_in (wdir ^ "/" ^ e) in
        let acc_id = cut_string (input_line ic) 3 0 in
        let acc_balance = cut_string (input_line ic) 8 0 in
        let tmp = {
          acc_id = acc_id;
          acc_balance = int_of_string acc_balance} in
        close_in ic;
        file_to_account s (tmp :: acc)
    in
  
    file_to_account (Array.to_list (Sys.readdir wdir)) []


let load_database wdir =
  let get_str str =
    let str, _ = Helpers.account_to_string str in
    str
  in

  let blocks = get_blocks (Helpers.blocks_dir wdir) in
  let blocks = List.rev blocks in
  let trans = get_transactions (Helpers.transactions_dir wdir false) in
  let pend = get_transactions (Helpers.transactions_dir wdir true) in
  let acc = get_accounts (Helpers.accounts_dir wdir) in
  {blocks = blocks;
   trans = trans;
   pending_trans = pend;
   accounts = acc}
