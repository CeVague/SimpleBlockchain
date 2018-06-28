(******************************************************************************)
(*     Copyright (C) OCamlPro SAS                                             *)
(******************************************************************************)

val block_reward : int
val pow_challenge : int

val hash_string : string -> string
val hash_file : string -> string
val sufficient_pow : Types.pow -> string -> bool

val blocks_dir : string -> string

val transactions_dir : string -> pending:bool -> string

val accounts_dir : string -> string

val empty_blockchain : Types.genesis -> Types.blockchain

val mk_block_content :
  Types.miner_id ->
  Types.trans_id list ->
  Types.block_info ->
  Types.nonce ->
  Types.pow ->
  Types.block_content

val transaction_to_string : Types.transaction -> string * string

val list_trans_id_to_string : Types.trans_id list -> string

val list_trans_to_string : Types.transaction list -> string

val account_to_string : Types.account -> string * string

val get_genesis : Types.genesis

val random_transaction : int -> Types.transaction

val block_content_to_string :
  Types.block_content ->
  string * string (* string content * hash *)

val check_chain_of_blocks : Types.block list -> Types.genesis -> bool

val calcul_valid_hash : Types.block_content -> Types.block_content

val check_valid_trans : Types.transaction -> Types.account list -> bool

val acc_after_trans : Types.transaction -> Types.account list -> Types.account list

val apply_pending_transactions : Types.transaction list -> Types.account list -> Types.transaction list -> Types.account list * Types.transaction list
