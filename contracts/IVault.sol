//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IVault{
    function depositEth() external payable;
    function releaseRewards() external;
    function claimRewardsInUSDC() external;
    function claimEthDeposited() external;
    function getBalanceUSDC(address _address) external view returns(uint256);
    function getUSDCPerUser(address _userForUSDC) external view returns(uint256);
    function ethDepositedByUser(address _address) external view returns(uint256);
    function getNumberOfPeople() external view returns(uint256);
    function getTotalEthAmount() external view returns(uint256);
}

