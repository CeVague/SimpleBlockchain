from datetime import datetime
import hashlib as hasher

class Transaction():
    def __init__(self, sender, buyer, asset):
        self.sender = sender
        self.buyer = buyer
        self.asset = asset

    def __repr__(self):
        return '{} ({} -> {})'.format(self.asset, self.sender, self.buyer)


class Block:
    def __init__(self, index, timestamp, data, previous_hash, nonce, transaction):
        self.index = index
        #variable permettant de vérifier si un doc a bien été crée à une date donnée
        self.timestamp = timestamp
        #donne de ma blockchain
        self.data = data

        self.nonce= nonce
        self.transaction= transaction
        #le hash du block précédent
        self.previous_hash = previous_hash




    def __str__(self):
        return 'Block #{}'.format(self.index)

    """ fonction permettant de générer un hash pour notre block """
    def hash_block(self):
        sha = hasher.md5()
        seq = (str(x) for x in (
               self.index, self.timestamp, self.data, self.previous_hash, self.nonce, self.transaction))
        sha.update(''.join(seq).encode('utf-8'))
        return sha.hexdigest()

""" fonction permettant de créer le premier block de la blockchain """
def make_genesis_block():
    block = Block(index=0,timestamp=datetime.now(),data="Genesis Block",previous_hash="0", nonce=0, transaction=[])
    return block


""" fonction permettant de créer le nouveau block de la blockchain """
def next_block(last_block, data=''):
    idx = last_block.index + 1
    block = Block(index=idx,
                  timestamp=datetime.now(),
                  data='{}{}'.format(data, idx),
                  previous_hash=last_block.hash_block(), nonce=0, transaction=[])
    return block

difficulty = 1

def test_code():
    blockchain = [make_genesis_block()]
    prev_block = blockchain[0]
    block = next_block(prev_block, data='some data here')

    #proof of work
    while not block.hash_block().startswith("0"*difficulty):
        block.nonce+=1


    for _ in range(0, 20):
        block = next_block(prev_block, data='some data here')
        blockchain.append(block)
        prev_block = block
        print (block.__dict__)
        print (block.hash_block()+"\n")



test_code()
