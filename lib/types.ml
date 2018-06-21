(******************************************************************************)
(*     Copyright (C) OCamlPro SAS                                             *)
(******************************************************************************)

open Util

type block_id    = string (* block ID/hash *)
type trans_id    = string (* transaction ID/hash *)
type miner_id    = string (* miner ID. Can be hash *)
type account_id = string (* account ID. Can be a hash *)
type nonce  = int
type pow = int

type transaction = {
  t_id   : trans_id;
  t_from : account_id;
  t_to   : account_id;
  t_fees : int;
  t_amount : int;
}

type block_info = {
  b_level : int;
  b_id    : block_id;
}

type block_content = {
  b_previous : block_info;
  b_miner : miner_id;
  b_pow : int;
  b_date : Util.Date.t;
  b_nonce : nonce;
  b_transactions : trans_id list
}

type block = {
  block_info : block_info;
  block_ctt : block_content
}

type account = {
  acc_id : account_id;
  acc_balance : int;
}

type database = {
  blocks : block list;
  trans : transaction list;
  pending_trans : transaction list;
  accounts : account list;
}

type genesis = {
  g_block : block;
  g_accounts : account list;
}

type blockchain = {
  genesis : genesis;
  db : database;
  peers_db : database MS.t
}
