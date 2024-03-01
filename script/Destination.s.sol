pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Destination.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DestinationScript is Script {
  function setUp() public{}

  function run() public {
    uint privateKey = vm.envUint("PRIVATE_KEY");
    address account = vm.addr(privateKey);

    console.log("Account", account);

    vm.startBroadcast(privateKey);

    //Destination destination = new Destination(account);
    address destination_address = 0xBBD65c422364F877964725715c14039BBE3D858D;
    Destination destination = new Destination(account);

    address token1 = 0xc677c31AD31F73A5290f5ef067F8CEF8d301e45c;
    destination.createToken(token1, "MCIT Token", "MCIT");
    
    address token2 = 0x0773b81e0524447784CcE1F3808fed6AaA156eC8;
    destination.createToken(token2, "MCIT Token", "MCIT");

    vm.stopBroadcast();
  }
}