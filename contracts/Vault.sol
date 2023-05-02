//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IERC20 {
    function transfer(address _to, uint256 _value) external returns(bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function balanceOf(address _buyer) external view returns (uint256);
    function approve(address _spender,  uint tokens) external returns (bool);
}

contract Vault{

    uint256 numPeople;
    //to keep track of how much eth was deposited by each address
    mapping (address => uint256) public userBalance;
    address[] public users;
    uint256 public totalAmountOfEthDeposited;
    //to keep track of time since the function releaseRewards() was called
    uint256 public timeSinceLastRelease;
    //To keep track of the eth to be claimed after releaseRewards() was called
    mapping (address => uint256) public ethToBeClaimed;
    //To keep track of the USDC to be claimed after releaseRewards() was called
    mapping (address => uint256) public usdcToBeClaimed;
    //check if the release function was called
    bool public isReleaseFunctionCalled;
    address public _owner;
    uint256 public startDeposits;
    uint256 public amountOfEthBeforeRelease;
    address payable public owner;
    IERC20 public usdcToken;

    constructor(){
        _owner = msg.sender;
        startDeposits = block.timestamp;
        usdcToken = IERC20(address(0x0Cbb65Db53c7042D9bCC14360fEdA7b86080cF77));
    }

    function depositEth() public payable{
       //when the contract is just deployed and releaseRewards() has never been called
       if(timeSinceLastRelease == 0){
         require(block.timestamp <= startDeposits + 8 hours);
       }
       //providing 8 hours timeframe to deposit after the release 
       if(timeSinceLastRelease != 0){
          require(block.timestamp <= timeSinceLastRelease + 8 hours);
       }
       //allows not more 20 eth to be deposited to the contract
       require(totalAmountOfEthDeposited < 20 ether, "20 ether have been already deposited to the contract");
       //allows eth to be deposited by only 20 people
       require(numPeople < 20, "Number of people depositing eth cannot exceed 20");
       //does not allow a single address to send transaction of more than 20 ether multiple times
       require(userBalance[msg.sender] < 20 ether, "You have already deposited a max of 20 ether");
       //allows people to deposit only upto 20 eth
       require(msg.value <= (20 ether - userBalance[msg.sender]), "You can only deposit upto 20 eth");
       //updating the mapping balance
       userBalance[msg.sender] += msg.value;
       ethToBeClaimed[msg.sender] += msg.value;
       numPeople += 1;
       //adding addresses to users array
       users.push(msg.sender);
       totalAmountOfEthDeposited += msg.value;
    }

    function releaseRewards() public{
       //requires the caller to be the owner
       require(msg.sender == _owner, "You are not the owner");
       //1 week should have passed before another release
       require(block.timestamp > timeSinceLastRelease + 168 hours);
       isReleaseFunctionCalled = true;
       //releasing USDCtoken to the contract
       usdcToken.transferFrom(msg.sender, address(this), 1000*(10**18));
       //resetting timestamp for the next person
       timeSinceLastRelease = block.timestamp;
       //reset number of people who deposited ether
       numPeople = 0;
       //update usdc to be claimed
       usdcToBeClaimed[msg.sender] = (ethToBeClaimed[msg.sender]/totalAmountOfEthDeposited)*(1000 * (10**18));
       //capture total amount of eth for the whole week
       amountOfEthBeforeRelease = totalAmountOfEthDeposited;
       //start anew for new week
       totalAmountOfEthDeposited = 0;
       //resetting the mapping used for deposit
       for(uint i = 0; i < users.length; i++){
           userBalance[users[i]] = 0;
       }
    }

    // function transferUSDC(uint256 amount) external {
    //     require(usdcToken.balanceOf(msg.sender) > amount, "You do not have enough balance to send tokens");
    //     usdcToken.transferFrom(msg.sender, address(this), amount);
    // }

    function claimRewardsInUSDC() public{
        require(usdcToBeClaimed[msg.sender] > 0, "You do not have any USDC to claim");
        usdcToken.transfer(msg.sender, usdcToBeClaimed[msg.sender]);
        usdcToBeClaimed[msg.sender] = 0;
    }

    function claimEthDeposited() public {
       //can be called only after the release function is called
       //require(block.timestamp > timeSinceLastRelease + 168 hours);
       require(isReleaseFunctionCalled == true, "release function hasn't been called yet");
       require(block.timestamp > timeSinceLastRelease);
       //send eth deposited by person back 
      owner = payable(msg.sender);
       owner.transfer(ethToBeClaimed[msg.sender]);
       //reset the mapping once the amount is withdrawn
       ethToBeClaimed[msg.sender] = 0;
    }

    function getBalanceUSDC(address _address) external view returns(uint256){
        uint256 balance = usdcToken.balanceOf(_address);
        return balance;
    }

    function getUSDCPerUser(address _userForUSDC) external view returns(uint256){
        return usdcToBeClaimed[_userForUSDC];
    }

    function ethDepositedByUser(address _address) external view returns(uint256){
        return userBalance[_address];
    }

    function getNumberOfPeople() external view returns(uint256){
        return numPeople;
    }

    function getTotalEthAmount() external view returns(uint256){
        return totalAmountOfEthDeposited;
    }

    receive() external payable {}
    fallback() external payable{}


}

//deployed contract address with 2 minutes locking period -->  0x0ca49F86EaedCb5e625027f7d83129e1e1a04390 
//USDC address --> 0x0Cbb65Db53c7042D9bCC14360fEdA7b86080cF77