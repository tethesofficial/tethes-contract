// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TethesProxy {
    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(address _logic) {
        _setAdmin(msg.sender);
        _setImplementation(_logic);
    }

    modifier onlyAdmin() {
        require(msg.sender == _getAdmin(), "Proxy: Not admin");
        _;
    }

    function _getAdmin() private view returns (address adm) {
        bytes32 slot = _ADMIN_SLOT;
        assembly { adm := sload(slot) }
    }

    function _setAdmin(address newAdmin) private {
        bytes32 slot = _ADMIN_SLOT;
        assembly { sstore(slot, newAdmin) }
    }

    function _setImplementation(address newLogic) private {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly { sstore(slot, newLogic) }
    }

    function upgradeTo(address newLogic) external onlyAdmin {
        _setImplementation(newLogic);
    }

    function name() public returns (string memory) { _delegate(); }
    function symbol() public returns (string memory) { _delegate(); }
    function decimals() public returns (uint8) { _delegate(); }
    function totalSupply() public returns (uint256) { _delegate(); }
    function balanceOf(address) public returns (uint256) { _delegate(); }
    function allowance(address, address) public returns (uint256) { _delegate(); }
    
    function transfer(address, uint256) public returns (bool) { _delegate(); }
    function approve(address, uint256) public returns (bool) { _delegate(); }
    function transferFrom(address, address, uint256) public returns (bool) { _delegate(); }

    fallback() external payable {
        _delegate();
    }

    receive() external payable {
        _delegate();
    }

    function _delegate() private {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        address _impl;
        assembly { _impl := sload(slot) }
        require(_impl != address(0), "Proxy: Implementation not set");

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}