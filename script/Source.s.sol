pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Source.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SourceScript is Script {
  function setUp() public{}

  function run() public {
    uint privateKey = vm.envUint("PRIVATE_KEY");
    address account = vm.addr(privateKey);

    console.log("Account", account);

    vm.startBroadcast(privateKey);

    //Source source = new Source(account);
    address source_address = 0x5F74016D8191eB229E5042b41562840eBD778DD3;
    Source source = new Source(account);
    
    address token1 = 0xc677c31AD31F73A5290f5ef067F8CEF8d301e45c;
    source.registerToken(token1);
    
    address token2 = 0x0773b81e0524447784CcE1F3808fed6AaA156eC8;
    source.registerToken(token2);

    vm.stopBroadcast();
  }
}