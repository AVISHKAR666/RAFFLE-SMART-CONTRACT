// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig, CodeConstants} from "script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

/* in our raflle contract we created an automation to pick the wineer automatucally, using Chinlink Aurtomation
   but we didn't provide any subscription ID, 
   so here we will  
   1.create a subscription  
   2.fund the subscription  
   3.Adding a consumer 
   so we will  get subID to run the automation(perfromUpkeep and all...) 
*/

contract CreateSubscription is Script {
    function run() public {
        createSubscriptionUsingConfig();
    }

    function createSubscriptionUsingConfig() public returns (uint256, address) {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        // using vrfCoordinator next we are going to create subscription
        address account = helperConfig.getConfig().account;
        (uint256 subId,) = createSubscription(vrfCoordinator, account);
        return (subId, vrfCoordinator);
    }

    function createSubscription(address vrfCoordinator, address account) public returns (uint256, address) {
        console.log("creating subscription on chainID:", block.chainid);
        vm.startBroadcast(account);
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();
        console.log("your subscription Id is: ", subId);
        console.log("please update subscription Id in your HelperConfig.s.sol");
        return (subId, vrfCoordinator);
    }
}

// Contract to fund the subscription that we created above
contract FundSubscription is Script, CodeConstants {
    uint256 public constant FUND_AMOUNT = 3 ether;

    function run() public {
        fundSubscriptionUsingConfig();
    }

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
        address linkToken = helperConfig.getConfig().link;
        address account = helperConfig.getConfig().account;
        fundSubscription(vrfCoordinator, subscriptionId, linkToken, account);
    }

    function fundSubscription(address vrfCoordinator, uint256 subscriptionId, address linkToken, address account) public {
        console.log("Funding Subscription: ", subscriptionId);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On ChainId: ", block.chainid);
        if (block.chainid == LOCAL_CHAIN_ID) {
            // for anvil
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subscriptionId, (FUND_AMOUNT * 100));
            vm.stopBroadcast();
        } else {
            // for sepolia and all
            vm.startBroadcast();
            LinkToken(linkToken).transferAndCall(vrfCoordinator, FUND_AMOUNT, abi.encode(subscriptionId));
            vm.stopBroadcast();
        }
    }

    /*
    -Like any other Script our's has a run function that gets executed
    -Inside we call the fundSubscriptionUsingConfig function
    -Inside the fundSubscriptionUsingConfig function we get the config that provides the chain-appropriate vrfCoordinator, subscriptionId and link token address
    -At the end of fundSubscriptionUsingConfig we call the fundSubscription, a function that we are going to define
    -We define fundSubscription as a public function that takes the 3 parameters as input
    -We console log some details, this will help us debug down the road
    -Then using an if statement we check if we are using Anvil, if that's the case we'll use the fundSubscription method found inside the VRFCoordinatorV2_5Mock
    -If we are not using Anvil, it means we are using Sepolia. The way we fund the Sepolia vrfCoordinator is by using the LINK's transferAndCall function.
    */
}

// Contract to add a consumer
contract AddConsumer is Script {
    function addConsumerUsingConfig(address mostRecentlyDeployed) public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        uint256 subId = helperConfig.getConfig().subscriptionId;
        address account = helperConfig.getConfig().account;
        addConsumer(mostRecentlyDeployed, vrfCoordinator, subId, account);
    }

    function addConsumer(address contractToAddtoVrf, address vrfCordinator, uint256 subId, address account) public {
        console.log("Adding consumer contract: ", contractToAddtoVrf);
        console.log("To vrfCoordinator: ", vrfCordinator);
        console.log("On ChainId: ", block.chainid);
        vm.startBroadcast(account);
        VRFCoordinatorV2_5Mock(vrfCordinator).addConsumer(subId, contractToAddtoVrf);
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);
        addConsumerUsingConfig(mostRecentlyDeployed);
    }

    /*
    -We used DevOpsTools to grab the last deployment of the Raffle contract inside the run function;
    -We also call addConsumerUsingConfig inside the run function;
    -We define addConsumerUsingConfig as a public function taking an address as an input;
    -We deploy a new HelperConfig and call getConfig() to grab the vrfCoordinate and subscriptionId addresses;
    -We call the addConsumer function;
    -We define addConsumer as a public function taking 3 input parameters: address of the raffle contract, address of vrfCoordinator and subscriptionId;
    -We log some things useful for debugging;
    -Then, inside a startBroadcast- stopBroadcast block we call the addConsumer function from the VRFCoordinatorV2_5Mock using the right input parameters;
    */
}
