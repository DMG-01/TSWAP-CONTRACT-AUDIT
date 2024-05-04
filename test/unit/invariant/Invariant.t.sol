//SPDX-License-Identifier:MIT

pragma solidity 0.8.20;

import {Test} from "lib/forge-std/src/Test.sol";
import {StdInvariant} from "lib/forge-std/src/StdInvariant.sol";
import {ERC20Mock} from "test/unit/mocks/ERC20Mock.sol";
import {PoolFactory} from "src/PoolFactory.sol";
import {TSwapPool} from "test/unit/TSwapPool.t.sol";
import {Handler} from "test/unit/invariant/Handler.t.sol";

contract Invariant is StdInvariant, Test {
    ERC20Mock poolToken;
    ERC20Mock weth;

    PoolFactory factory;
    TSwapPool pool;
    Handler handler; 

    int256 STARTING_X_AMOUNT = 100e18;
    int256 STARTING_Y_AMOUNT = 50e18;
    function setUp() public {
        poolToken = new ERC20Mock();
        weth = new ERC20Mock();
        factory = new PoolFactory(address(weth));
        pool = TSwapPool(factory.createPool(address(poolToken)));

        poolToken.mint(address(this), uint256(STARTING_X_AMOUNT));
        weth.mint(address(this), uint256(STARTING_Y_AMOUNT));

        poolToken.approve(address(pool), type(uint256).max);
        weth.approve(address(pool), type(uint256).max);

        pool.deposit(uint256(STARTING_X_AMOUNT), uint256(STARTING_X_AMOUNT),uint256(STARTING_Y_AMOUNT), uint64(block.timestamp) );
    
       handler = new Handler(pool);
       bytes4[] memory selectors = new bytes4[](2); 
       selectors[0] = Handler.deposit.selector;
       selectors[1] = Handler.swapPoolTokenForWethBasedOnOutputWeth.selector; 

       targetSelector(FuzzSelector({addr:address(handler), selectors: selectors}));
       targetContract(address(handler));
}
function statefulFuzz_constantProductFormulaStaysTheSame() public {
    assertEq(handler.actualDeltaX() == handler.expectedDeltaX());
}
}