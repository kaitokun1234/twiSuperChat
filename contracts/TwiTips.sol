// SPDX-License-Identifier: Unlicence
pragma solidity 0.8.13;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract TwiTips is Ownable{

  uint public fee;
  tip[] public tips;
  mapping(address => uint) public unclaimed;
  event withdraw(uint256 amount);
  event sent(uint amount, string message, address to);
  event changedFee(uint newFee);
  event claimed(uint amount, address user);

  struct tip{
    uint amount;
    string message;
    address from;
    address to;
  }

  constructor(uint256 _defaultFee){
    fee = _defaultFee;
  }

  function getTips() view public returns(tip[] memory){
      return tips;
  }

  function sendTip(uint _amount, string memory _message, address _to) public payable{
    require(_amount > 0, "amount is empty");
    require(msg.value == _amount, "insufficient fund");
    tips.push(tip(_amount, _message, msg.sender, _to));
    unclaimed[_to] += _amount;
    emit sent(_amount, _message, _to);
  }

  function Withdraw(uint256 _amount) public onlyOwner{
    (bool success, ) = payable(msg.sender).call{ value: _amount } ("");
    require(success, "ETH transfer failed");
    emit withdraw(_amount);
  }

  function changeFee(uint256 _newFee) public onlyOwner{
      fee = _newFee;
      emit changedFee(fee);
  }

  function claim() public {
      uint _amount = unclaimed[msg.sender];
      _amount = (_amount*(( 100 - fee )/100));
      require(_amount > 0, "no unclaimed");
      unclaimed[msg.sender] = 0;
      (bool success, ) = payable(msg.sender).call{ value: _amount } ("");
      require(success, "ETH transfer failed");
      emit claimed(_amount, msg.sender);
  }

  function getMyUnclaimed() public view returns(uint) {
    return (unclaimed[msg.sender]*(100-fee)/100);
  }
}