// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Source is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant WARDEN_ROLE = keccak256("BRIDGE_WARDEN_ROLE");
	mapping( address => bool) public approved;
	address[] public tokens;

	event Deposit( address indexed token, address indexed recipient, uint256 amount );
	event Withdrawal( address indexed token, address indexed recipient, uint256 amount );
	event Registration( address indexed token );

    constructor( address admin ) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
    }

	function deposit(address _token, address _recipient, uint256 _amount ) public {
    // Check if the token being deposited has been “registered”
    require(approved[_token] == true, "token not registered");
    // Use the ERC20 “transferFrom” function to pull the tokens into the deposit contract
    ERC20(_token).transferFrom(msg.sender, address(this), _amount);
    //BridgeToken(_token).transferFrom(_token, _recipient, _amount);
    // Emit a “Deposit” event so that the bridge operator knows to make the necessary actions on the destination side
    emit Deposit(_token, _recipient, _amount);
  }

	function withdraw(address _token, address _recipient, uint256 _amount ) onlyRole(ADMIN_ROLE) public {
    // Check that the function is being called by the contract owner
    //require(msg.sender == address(_token), "Withdraw function not called by contract owner");
    //require(ERC20(_token).balanceOf(msg.sender) > 0, "Caller is not the token owner");
    // Push the tokens to the recipient using the ERC20 “transfer” function
    ERC20(_token).transfer(_recipient, _amount);
    // Emit a “Withdraw” event
    emit Withdrawal(_token, _recipient, _amount);
	}

	function registerToken(address _token) onlyRole(ADMIN_ROLE) public {
    // Check that the function is being called by the contract owner
    // Require(ERC20(_token).balanceOf(msg.sender) > 0, "not owner");
    // Check that the token has not already been registered
    require(!approved[_token], "token already registered");
    // Add the token address to the list of registered tokens
    approved[_token] = true;
    // Emit a Registration event
    emit Registration(_token);
	}


}


