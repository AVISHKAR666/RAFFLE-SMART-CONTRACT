// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract RaffleTest is Test {
    Raffle public raffle;
    HelperConfig public helperConfig;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 keyHash;
    uint256 subscriptionId;
    uint32 callbackGasLimit;

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;
    
    // to test the event
    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);

    function setUp() public {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.deployRaffleContract();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        keyHash = config.keyHash;
        subscriptionId = config.subscriptionId;
        callbackGasLimit = config.callbackGasLimit;

        vm.deal(PLAYER, STARTING_PLAYER_BALANCE);
    }

    // TESTS
    function testRaffleInitializesInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testRaffleReverWhenPlayerDontPayEnoughToEnter() public {
        // Arrange
        vm.prank(PLAYER);
        // Act/assert
        vm.expectRevert(Raffle.Raffle__NotEnoughEthSentToEnterIntoRaffle.selector);
        raffle.enterRaffle();
        //calling "enterRaffle" fun without sending an eth
        //so the raffle contract will revert with error "Raffle__NotEnoughEthSentToEnterIntoRaffle"
        // vm.expectRevert(...) is waiting for that revert.
        // and test will pass eventually
    }

    function testRaffleRecordsPlayerWhenEntered() public {
        // Arrange
        vm.prank(PLAYER);
        // Act
        raffle.enterRaffle{value: entranceFee}();
        // Assert
        address playerRecorded = raffle.getPlayer(0);
        // assert(playerRecorded == PLAYER);
        //assert comes from solidity directly, low-level 
        assertEq(playerRecorded , PLAYER); 
        // req more gas than "assert" becoz it comes from lib/forge-std/Test
        // it logs both value if error comes
    }

    function testEnteringRaffleEmitsEvent() public {
        // Arrange
        vm.prank(PLAYER);
        // Act
        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEntered(PLAYER);
        // Assert
        raffle.enterRaffle{value: entranceFee}();
    }

    function testDontAllowPlayersToEnterWhileRaffleIsCalculating() public {
        // "Calculating" state is happening in performUpkeep() function,
        // so to perform this function we have to pass some checks, such as, hasPlayers, hasBalance, timeHasPassed
        // Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);  //here we passed the interval of raffle to pick the winner
        vm.roll(block.number + 1);  //
        raffle.performUpkeep("");
        // Act/Assert
        vm.expectRevert();
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();

    }
}
