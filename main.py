import json
from web3 import Web3
prov = Web3(Web3.HTTPProvider('http://localhost:8545'))
account = prov.eth.accounts[0]
with open('/Users/quanrong/sol-workplace/compound/out/SimplePriceOracle.sol/SimplePriceOracle.json', 'r') as f:
    all_contents = json.load(f)
    abi = all_contents['abi']
    code = all_contents['bytecode']['object']
oracle_address = '0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9'
oracle = prov.eth.contract(address=oracle_address, abi=abi)

oracle.functions.setDirectPrice('0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE',1700).call()
print(oracle.functions.getUnderlyingPrice('0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0').call())