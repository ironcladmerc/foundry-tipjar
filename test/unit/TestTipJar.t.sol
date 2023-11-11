// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import {Test,console} from "lib/forge-std/src/Test.sol";
import {DeployTipJar} from "script/DeployTipJar.s.sol";
import {TipJar} from "src/TipJar.sol";

contract TestTipJar is Test {

  TipJar tipJar;

  address public USER = makeAddr("user");
  address public DONOR = makeAddr("donor");
  address public NONREG_USER = makeAddr("nonreg_user");

  uint256 public constant STARTING_BALANCE = 10 ether;
  uint256 public constant TIP_AMOUNT = 1 ether;

  function setUp() external {
    DeployTipJar deployer = new DeployTipJar();
    tipJar = deployer.run();

    vm.deal(DONOR, STARTING_BALANCE);
    vm.deal(USER, STARTING_BALANCE);
    vm.deal(NONREG_USER, STARTING_BALANCE);
  }

  modifier registered() {
    if (!tipJar.isRegisteredUser(USER)) {
      vm.prank(USER);
      tipJar.registerUser(USER);
    }
    _;
  }

  modifier hasBalance() {
    vm.prank(DONOR);
    tipJar.tipUser{value:TIP_AMOUNT}(USER);
    _;
  }

  function testRegisterUser() public {
    vm.prank(USER);
    tipJar.registerUser(USER);
    assertTrue(tipJar.isRegisteredUser(USER));
  }

  function testRegisterAnotherUser() public {
    vm.prank(NONREG_USER);
    vm.expectRevert(TipJar.TipJar__UserCanOnlyRegisterThemselves.selector);
    tipJar.registerUser(USER);
  }

  function testTipUserIsSuccess() public registered {
    console.log("Contract balance before tip: " , tipJar.getContractBalance());
    uint256 expectedBalance = tipJar.getContractBalance() + TIP_AMOUNT;
    vm.prank(DONOR);
    tipJar.tipUser{value:TIP_AMOUNT}(USER);
    uint256 userBalance = tipJar.getUserBalance(USER);
    assertEq(userBalance, TIP_AMOUNT);
    assertEq(tipJar.getContractBalance(), expectedBalance);
    console.log("Contract balance after tip: " , tipJar.getContractBalance());
  }

  function testCannotTipUnregisteredUser() public {
    vm.prank(DONOR);
    vm.expectRevert(TipJar.TipJar__UserMustBeRegistered.selector);
    tipJar.tipUser{value:TIP_AMOUNT}(NONREG_USER);
  }

  function testUserCanWithdrawAllTips() public registered hasBalance {
    vm.prank(USER);
    tipJar.withdrawAllTips(USER);
  }

  function testCannotWithdrawAnotherUsersTips() public registered hasBalance {
    vm.prank(NONREG_USER);
    vm.expectRevert(TipJar.TipJar__UserCanOnlyWithdrawOwnFunds.selector);
    tipJar.withdrawAllTips(USER);
  }

  function testUserCanWithdrawPartial() public registered {
    uint256 doubleTipAmount = TIP_AMOUNT * 2;
    vm.prank(DONOR);
    tipJar.tipUser{value:doubleTipAmount}(USER);

    vm.prank(USER);
    tipJar.withdrawPartial(USER, TIP_AMOUNT);

    uint256 userBalance = tipJar.getUserBalance(USER);
    assertEq(userBalance, TIP_AMOUNT);
  }

  function testUserCannotWithDrawPartialAnotherUsersFunds() public registered hasBalance {
    vm.prank(NONREG_USER);
    vm.expectRevert(TipJar.TipJar__UserCanOnlyWithdrawOwnFunds.selector);
    tipJar.withdrawPartial(USER, TIP_AMOUNT);
  }

  function testUserCanUnregisterWithNoBalance() public registered {
    vm.prank(USER);
    tipJar.unregisterUser(USER);
    assertFalse(tipJar.isRegisteredUser(USER));
  }

  function testUserCantUnregisterWithBalance() public registered hasBalance {
    vm.prank(USER);
    vm.expectRevert(TipJar.TipJar__UserCannotUnregisterWithUnredeemedFunds.selector);
    tipJar.unregisterUser(USER);
  }

  function testUserCantUnregisterAnotherUser() public registered {
    vm.prank(NONREG_USER);
    vm.expectRevert(TipJar.TipJar__UserCanOnlyUnregisterThemselves.selector);
    tipJar.unregisterUser(USER);
  }

  function testUserCanUnregisterAndWithdraw() public registered hasBalance {
    uint256 userBalance = tipJar.getUserBalance(USER);
    vm.prank(USER);
    tipJar.unregisterAndWithdraw(USER);
    assertFalse(tipJar.isRegisteredUser(USER));
    uint256 userBalanceAfter = tipJar.getUserBalance(USER);
    assertEq(userBalanceAfter, 0);
    assertEq(tipJar.getContractBalance(), 0);
    uint256 userWalletBalance = address(USER).balance;
    assertEq(userWalletBalance, userBalance + STARTING_BALANCE);
  }
}