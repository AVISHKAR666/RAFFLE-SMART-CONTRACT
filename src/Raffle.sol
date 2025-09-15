// Layout of the contract file:
// version
// imports
// errors
// interfaces, libraries, contract

// Inside Contract:
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

// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

/* IMPORTS */
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/dev/vrf/libraries/VRFV2PlusClient.sol";
// import {VRFV2PlusClient} from "../libraries/VRFV2PlusClient.sol";
import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";

/**
 * @title a sample raffle contract
 * @author Avishkar Chavan
 * @notice this contract is for creating a sample raffle
 * @dev Implements chainlink VRFv2.5
 * @dev the duration of the lottery in seconds
 */
contract Raffle is VRFConsumerBaseV2Plus {
    /* ERRORS */
    error Raffle__NotEnoughEthSentToEnterIntoRaffle();
    error Raffle__RewardTransferToWinnerFailed();
    error Raffle__RaffleNotOpen();
    error Raffle__UpkeepNotNeeded(uint256 balance, uint256 playersLength, uint256 raffleState);

    /* TYPE DECLARATION */
    enum RaffleState {
        OPEN, // 0
        CALCULATING // 1
            //another_state // 2

    }

    /* STATE VARIABLES */
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    address payable[] private s_players;
    uint256 private s_startedTimeStamp;
    address private s_recentWinnerAddress;
    RaffleState private s_raffleState;

    /* EVENTS */
    // when player enters the raffle
    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);

    /* CONSTRUCTOR */
    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 keyHash,
        uint256 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_keyHash = keyHash;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_startedTimeStamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
    }

    /* FUNCTIONS */
    // to enter into the raffle
    function enterRaffle() external payable {
        // checking raffle state is open or not
        if (s_raffleState != RaffleState.OPEN) revert Raffle__RaffleNotOpen();
        // acc to new update we can write custom errors inside "require" condition...like this
        //require(msg.value < i_entranceFee, NotEnoughEthToEnterIntoRaffle());
        // but still hypothetically "if" condition is more gas efficient than "require"
        if (msg.value < i_entranceFee) revert Raffle__NotEnoughEthSentToEnterIntoRaffle();
        s_players.push(payable(msg.sender));
        // there is a thumb of rule, always emmiting an event, when storage variable is updated
        // emitting an event, when player entered the raffle
        emit RaffleEntered(msg.sender);
    }

    // when should the winner should be picked
    /**
     * @dev this is the function that the chainlink nodes will call to see
     * if the lottery is ready to have winner picked
     * The following should be true in order for upkeepNeeded to be true
     * 1. The time interval has been passed between raffle runs
     * 2. The lottery is open
     * 3. The contracts has ETH
     * 4. The raffle has players
     * 5. Implicitly your subscription has LINK
     * @param - ignored
     * @return upkeepNeeded - true true if it's time to restart the lottery
     * @return - ignored
     */
    function checkUpkeep(bytes memory /*checData*/ )
        public
        view
        returns (bool upkeepNeeded, bytes memory /*performDataa*/ )
    {
        bool timeHasPassed = (block.timestamp - s_startedTimeStamp >= i_interval);
        bool isRaffleOpen = (s_raffleState == RaffleState.OPEN);
        bool hasBalance = (address(this).balance > 0);
        bool hasPlayers = (s_players.length > 0);
        upkeepNeeded = timeHasPassed && isRaffleOpen && hasBalance && hasPlayers;
        return (upkeepNeeded, "");
    }

    // to pick the winner randomly - 3 step process
    // 3. be automatically called...when there is a time to pick a winner
    function performUpkeep(bytes calldata /*performData*/ ) external {
        // check to see if enough time has passed
        (bool upkeepNeeded,) = checkUpkeep("");
        // If upkeepNeeded == true → !true == false → if(false) → ❌ the revert won’t run. -->  performUpkeep will run
        // If upkeepNeeded == false → !false == true → if(true) → ✅ the revert will run. --> performUpkeep won't run
        if (!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded(address(this).balance, s_players.length, uint256(s_raffleState));
        }

        s_raffleState = RaffleState.CALCULATING;
        // 1. get a random number
        // generating a random number from chainlink VRF 2.5

        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
            keyHash: i_keyHash,
            subId: i_subscriptionId,
            requestConfirmations: REQUEST_CONFIRMATIONS,
            callbackGasLimit: i_callbackGasLimit,
            numWords: NUM_WORDS,
            extraArgs: VRFV2PlusClient._argsToBytes(
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
            )
        });

        IVRFCoordinatorV2Plus coordinator = IVRFCoordinatorV2Plus(address(s_vrfCoordinator));
        coordinator.requestRandomWords(request);
    }

    // 2. use a random number to select a player randomly
    // to get back this generated random num we use "fulfillRandomWords" function
    function fulfillRandomWords(uint256, /*requestId*/ uint256[] calldata randomWords) internal override {
        // CHECKS - include require/conditional statements 
        
        // EFFECTS (internal contract state changes)
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address recentWinnerAddress = s_players[indexOfWinner];
        s_recentWinnerAddress = recentWinnerAddress;
        // emitting an event
        emit WinnerPicked(s_recentWinnerAddress);
        // also resetting the started timestamp
        s_startedTimeStamp = block.timestamp;
        // again resetting an array for next raffle
        s_players = new address payable[](0);
        // again opening raffle for next raffle
        s_raffleState = RaffleState.OPEN;

        // INTERACTIONS(external contract interactions)
        // external calls should be in the last always, to reduce the attack surface
        (bool success,) = s_recentWinnerAddress.call{value: address(this).balance}("");
        if (!success) revert Raffle__RewardTransferToWinnerFailed();
    }

    /* GETTER Functions */
    // getting entrance fee
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    // getting recent winner address
    function getRecentWinnerAddress() external view returns (address) {
        return s_recentWinnerAddress;
    }

    // getting starting state of 
    function getRaffleState() external view returns(RaffleState) {
        return s_raffleState;
    }

    function getPlayer(uint256 indexOfPlayer) external view returns(address){
        return s_players[indexOfPlayer];
    }
}
