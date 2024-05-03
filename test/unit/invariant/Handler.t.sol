//SPDX-License-Identifier:MIT

pragma solidity 0.8.20;
import {Test, console2} from "lib/forge-std/src/Test.sol";
import {TSwapPool} from "src/TSwapPool.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract Handler is Test {

    TSwapPool pool;
    ERC20Mock weth;


    uint256 startingY;
    uint256 startingX;
    uint256 expectedStartingY;
    uint256 expectedStartingX;
    ERC20Mock poolToken;

    address liquidityPoolProvider = makeAddr("LP");
    constructor(TSwapPool _pool) {
    pool =_pool;
    weth =ERC20Mock(pool.getWeth());
    poolToken = ERC20Mock(pool.getPoolToken());
    }

function deposit(uint256 wethAmount) public {
wethAmount = bound(wethAmount, 0, type(uint64).max);
startingY = weth.balanceOf(address(this));
startingX = poolToken.balanceOf(address(this));
expectedStartingY = wethAmount;
expectedStartingX = pool.getPoolTokensToDepositBasedOnWeth(wethAmount);

vm.startPrank(liquidityPoolProvider);
weth.mint(liquidityPoolProvider,wethAmount);
poolToken.mint(liquidityPoolProvider, expectedStartingX);
weth.approve(address(pool), type(uint256).max);
poolToken.approve(address(pool), type(uint256).max);
pool.deposit(wethAmount,0,expectedStartingX, uint64(block.timestamp) );
vm.stopPrank();
}
}