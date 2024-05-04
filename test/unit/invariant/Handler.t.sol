//SPDX-License-Identifier:MIT

pragma solidity 0.8.20;
import {Test, console2} from "lib/forge-std/src/Test.sol";
import {TSwapPool} from "src/TSwapPool.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract Handler is Test {

    TSwapPool pool;
    ERC20Mock weth;


    int256 public startingY;
    int256 public startingX;
    int256 public expectedDeltaY;
    int256 public expectedDeltaX;
    int256 public actualDeltaX;
    int256 public actualDeltaY;
    ERC20Mock poolToken;

    address liquidityPoolProvider = makeAddr("LP");
    address swapper = makeAddr("swapper"); 
    constructor(TSwapPool _pool) {
    pool =_pool;
    weth =ERC20Mock(pool.getWeth());
    poolToken = ERC20Mock(pool.getPoolToken());
    }

function swapPoolTokenForWethBasedOnOutputWeth(uint256 outputWeth) public {
   outputWeth = bound(outputWeth, 0 , type(uint64).max);

   if(outputWeth >= weth.balanceOf(address(pool))) {
    return;
   }

    uint256 poolTokenAmount = pool.getInputAmountBasedOnOutput(outputWeth, poolToken.balanceOf(address(pool)), weth.balanceOf(address(pool)));

   if(poolTokenAmount > type(uint64).max){
    return;
   }

   startingY = int256(weth.balanceOf(address(this)));
startingX = int256(poolToken.balanceOf(address(this)));
expectedDeltaY =int256(-1) * int256(outputWeth);
expectedDeltaX = int256(pool.getPoolTokensToDepositBasedOnWeth(poolTokenAmount));

if(poolToken.balanceOf(swapper) < poolTokenAmount) {
    poolToken.mint(swapper, poolTokenAmount - poolToken.balanceOf(swapper ) +1);
}

vm.startPrank(swapper);
poolToken.approve(address(pool), type(uint256).max);
pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
vm.stopPrank();

uint256 endingY = weth.balanceOf(address(this));
uint256 endingX = poolToken.balanceOf(address(this));

actualDeltaX = int256(endingX) - int256(startingX);
actualDeltaY = int256(endingY) - int256(endingY);
}
 

function deposit(uint256 wethAmount) public {
wethAmount = bound(wethAmount, 0, type(uint64).max);
startingY = int256(weth.balanceOf(address(this)));
startingX = int256(poolToken.balanceOf(address(this)));
expectedDeltaY = int256(wethAmount);
expectedDeltaX = int256(pool.getPoolTokensToDepositBasedOnWeth(wethAmount));

vm.startPrank(liquidityPoolProvider);
weth.mint(liquidityPoolProvider,wethAmount);
poolToken.mint(liquidityPoolProvider, uint256(expectedDeltaX));
weth.approve(address(pool), type(uint256).max);
poolToken.approve(address(pool), type(uint256).max);
pool.deposit(wethAmount,0,uint256(expectedDeltaX), uint64(block.timestamp) );
vm.stopPrank();

uint256 endingY = weth.balanceOf(address(this));
uint256 endingX = poolToken.balanceOf(address(this));

actualDeltaX = int256(endingX) - int256(startingX);
actualDeltaY = int256(endingY) - int256(endingY);
}
}