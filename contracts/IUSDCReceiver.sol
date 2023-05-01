//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IUSDCReceiver {
    function transferUSDC(uint256 amount) external;
    function getBalanceUSDC(address _address) external view returns(uint256);
    function getReserce() external view returns(uint256);
    function transferFromContract(address _to, uint256 _value) external;
}