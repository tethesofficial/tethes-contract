// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TethesToken {
    uint8 public constant decimals = 6;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    bool private _initialized;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function name() public pure returns (string memory) {
        return "Tethes";
    }

    function symbol() public pure returns (string memory) {
        return "UST";
    }

    function initialize(uint256 initialSupply, address owner) public {
        require(!_initialized, "UST: Already initialized");
        _initialized = true;
        
        totalSupply = initialSupply * (10 ** uint256(decimals));
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "TRC20: transfer to zero address");
        require(balanceOf[msg.sender] >= value, "TRC20: insufficient balance");
        unchecked {
            balanceOf[msg.sender] -= value;
            balanceOf[to] += value;
        }
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(to != address(0), "TRC20: transfer to zero address");
        require(balanceOf[from] >= value, "TRC20: insufficient balance");
        require(allowance[from][msg.sender] >= value, "TRC20: allowance exceeded");
        unchecked {
            balanceOf[from] -= value;
            balanceOf[to] += value;
            allowance[from][msg.sender] -= value;
        }
        emit Transfer(from, to, value);
        return true;
    }
}