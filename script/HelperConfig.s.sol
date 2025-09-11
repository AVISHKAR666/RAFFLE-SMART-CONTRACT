// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

// Declared abstract because it doesn’t need deployment itself, just provides constants.
abstract contract CodeConstants{
    /*VRF MOCK values */
    uint96 public MOCK_BASE_FEE = 0.25 ether;
    uint96 public MOCK_GAS_PRICE_LINK = 1e9;
    int256 public MOCK_WEI_PER_UNIT_LINK = 4e15; 

    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant LOCAL_CHAIN_ID = 31337; //anvil chainID
}

contract HelperConfig is CodeConstants, Script {
    
    error HelperConfig__InvalidChainId();

    // key settings needed for Raffle.
    struct NetworkConfig{
        uint256 entranceFee; 
        uint256 interval;
        address vrfCoordinator;
        bytes32 keyHash;
        uint256 subscriptionId;        
        uint32 callbackGasLimit; 
    }

    // localNetworkConfig - stores config for your Anvil local chain
    NetworkConfig public localNetworkConfig;
    
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    constructor() {
        // scripts already know Sepolia settings without manual setup beacause we give it in constructor
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
    }

    function getConfifByChainId(uint256 chainId) public returns(NetworkConfig memory) { 
        if (networkConfigs[chainId].vrfCoordinator !=  address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == LOCAL_CHAIN_ID) {
            // it will deploy on local anvil chain
            return getOrCreateAnvilEthConfig();
        }
        else {
            revert HelperConfig__InvalidChainId();
        }
    }

    //just a getter function- to know on which chain contract is deployed 
    function getConfig() public returns(NetworkConfig memory) {
        return getConfifByChainId(block.chainid);
    }

    // deploying on sepolia chain
    function getSepoliaEthConfig() public pure returns(NetworkConfig memory) {
        return NetworkConfig({
            entranceFee: 0.01 ether, //1e16
            interval:30, //30 sec
            vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            keyHash: 0x474e34a077df58807dbe9c96e02e3f8f07c3c7d7b3e1a37e2319d0c7d6c12d6b,
            callbackGasLimit: 500000,
            subscriptionId: 0 //have to fix this
        });
    }

    // deploying on anvil chain (anvil requires mock config)
    function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory) {
        // check to see if we set an active network config
        if(localNetworkConfig.vrfCoordinator != address(0)) {
            return localNetworkConfig;
        }

        // deploy mock vrf and key settings
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorV2_5Mock = new VRFCoordinatorV2_5Mock(MOCK_BASE_FEE, MOCK_GAS_PRICE_LINK, MOCK_WEI_PER_UNIT_LINK);
        vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({
            entranceFee: 0.01 ether, //1e16
            interval:30, //30 sec
            vrfCoordinator: address(vrfCoordinatorV2_5Mock),
            // gaslane doesn't matter because it's just a mock man
            keyHash: 0x474e34a077df58807dbe9c96e02e3f8f07c3c7d7b3e1a37e2319d0c7d6c12d6b,
            callbackGasLimit: 500000,
            subscriptionId: 0 //might have to fix this
        });
        return localNetworkConfig;

    }
}