from web3 import Web3
from web3.contract import Contract
from web3.providers.rpc import HTTPProvider
from web3.middleware import geth_poa_middleware #Necessary for POA chains
import json
import sys
from pathlib import Path

source_chain = 'avax'
destination_chain = 'bsc'
contract_info = "contract_info.json"

def connectTo(chain):
    if chain == 'avax':
        api_url = f"https://api.avax-test.network/ext/bc/C/rpc" #AVAX C-chain testnet

    if chain == 'bsc':
        api_url = f"https://data-seed-prebsc-1-s1.binance.org:8545/" #BSC testnet

    if chain in ['avax','bsc']:
        w3 = Web3(Web3.HTTPProvider(api_url))
        # inject the poa compatibility middleware to the innermost layer
        w3.middleware_onion.inject(geth_poa_middleware, layer=0)
    return w3

def getContractInfo(chain):
    """
        Load the contract_info file into a dictinary
        This function is used by the autograder and will likely be useful to you
    """
    p = Path(__file__).with_name(contract_info)
    try:
        with p.open('r')  as f:
            contracts = json.load(f)
    except Exception as e:
        print( "Failed to read contract info" )
        print( "Please contact your instructor" )
        print( e )
        sys.exit(1)

    return contracts[chain]

def scanBlocks(chain):
    """
        chain - (string) should be either "source" or "destination"
        Scan the last 5 blocks of the source and destination chains
        Look for 'Deposit' events on the source chain and 'Unwrap' events on the destination chain
        When Deposit events are found on the source chain, call the 'wrap' function the destination chain
        When Unwrap events are found on the destination chain, call the 'withdraw' function on the source chain
    """

    if chain not in ['source','destination']:
        print( f"Invalid chain: {chain}" )
        return

    dest_url = f"https://data-seed-prebsc-1-s1.binance.org:8545/"
    src_url = f"https://api.avax-test.network/ext/bc/C/rpc"

    arg_filter = {}

    dest_info = getContractInfo('destination')
    dest_addr, dest_abi = dest_info['address'], dest_info['abi']
    dest_w3 = Web3(Web3.HTTPProvider(dest_url))
    dest_w3.middleware_onion.inject(geth_poa_middleware, layer=0)
    dest_contract = dest_w3.eth.contract(address=dest_addr, abi=dest_abi)

    src_info = getContractInfo('source')
    src_addr, src_abi = src_info['address'], src_info['abi']
    src_w3 = Web3(Web3.HTTPProvider(src_url))
    src_w3.middleware_onion.inject(geth_poa_middleware, layer=0)
    src_contract = src_w3.eth.contract(address=src_addr, abi=src_abi)

    if chain == 'source':
        end_block = src_w3.eth.get_block_number()
    else:
        end_block = dest_w3.eth.get_block_number()
    start_block = end_block - 4

    for block_num in range(start_block, end_block + 1):
        if chain == 'source':
            # call Wrap on destination Chain
            event_filter = src_contract.events.Deposit.create_filter(fromBlock=block_num, toBlock=block_num, argument_filters=arg_filter)
            events = event_filter.get_all_entries()
            for evt in events:
                dest_contract.functions.wrap(evt.args['token'], evt.args['recipient'], evt.args['amount']).transact()

        elif chain == 'destination':
            # call Withdrawal on Source Chain
            event_filter = dest_contract.events.Unwrap.create_filter(fromBlock=block_num, toBlock=block_num,argument_filters=arg_filter)
            events = event_filter.get_all_entries()
            for evt in events:
                src_contract.functions.withdraw(evt.args['token'], evt.args['recipient'], evt.args['amount']).transact()
