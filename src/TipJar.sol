// SPDX-License-Identifier: MIT

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity 0.8.21;

contract TipJar {

  error TipJar__UserCanOnlyRegisterThemselves();
  error TipJar__UserCanOnlyUnregisterThemselves();
  error TipJar__UserCannotUnregisterWithUnredeemedFunds();
  error TipJar__UserMustBeRegistered();
  error TipJar__UserCanOnlyWithdrawOwnFunds();
  error TipJar__UserBalanceNotSufficient();
  error TipJar__TransferFailed();

  mapping(address => bool) private s_tipWhitelist;
  mapping(address => uint256) private s_tips;

  event Tip(address indexed from, address indexed to, uint256 amount);
  event UserRegistered(address indexed user);
  event UserUnregistered(address indexed user);
  event Withdraw(address indexed from, uint256 amount);

  function registerUser(address user) public {
    if (msg.sender != user) {
      revert TipJar__UserCanOnlyRegisterThemselves();
    }
    s_tipWhitelist[user] = true;
    emit UserRegistered(user);
  }

  function unregisterUser(address user) public {
    if (msg.sender != user) {
      revert TipJar__UserCanOnlyUnregisterThemselves();
    }
    if (s_tips[user] != 0) {
      revert TipJar__UserCannotUnregisterWithUnredeemedFunds();
    }
    s_tipWhitelist[user] = false;
    emit UserUnregistered(user);
  }

  function tipUser(address user) public payable {
    if (!isRegisteredUser(user)) {
      revert TipJar__UserMustBeRegistered();
    }
    s_tips[user] += msg.value;
    emit Tip(msg.sender, user, msg.value);
  }

  function withdrawPartial(address user, uint256 amount) public {
    if (msg.sender != user) {
      revert TipJar__UserCanOnlyWithdrawOwnFunds();
    }

    if (!isRegisteredUser(user)) {
      revert TipJar__UserMustBeRegistered();
    }

    if (amount > s_tips[msg.sender]) {
      revert TipJar__UserBalanceNotSufficient();
    }

    s_tips[msg.sender] -= amount;

    emit Withdraw(msg.sender, amount);
    (bool success,) = user.call{value: amount}("");

    if (!success) {
      revert TipJar__TransferFailed();
    }
  }

    function withdrawAllTips(address user) public {
    if (msg.sender != user) {
      revert TipJar__UserCanOnlyWithdrawOwnFunds();
    }

    if (!isRegisteredUser(user)) {
      revert TipJar__UserMustBeRegistered();
    }

    uint256 amount = s_tips[msg.sender];
    s_tips[msg.sender] = 0;

    emit Withdraw(msg.sender, amount);
    (bool success,) = user.call{value: amount}("");

    if (!success) {
      revert TipJar__TransferFailed();
    }
  }

  function unregisterAndWithdraw(address user) public {
    withdrawAllTips(user);
    unregisterUser(user);
  }

  function isRegisteredUser(address user) public view returns(bool) {
    return s_tipWhitelist[user];
  }

  function getUserBalance(address user) public view returns(uint256) {
    return s_tips[user];
  }
}