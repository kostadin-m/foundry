import {Test, console} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/raffle/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {RaffleConfig} from "../../script/raffle/RaffleConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";


import {CreateSubscriptionId,FundSubscription, AddConsumer} from "../../script/raffle/Interactions.s.sol";

contract RaffleIntegrationTest is Test {
    DeployRaffle deployer;
    Raffle raffle;
    RaffleConfig raffleConfig;
    address vrfCoordinator;

    event EnteredRaffle(address indexed player);

    function setUp() public {
        deployer = new DeployRaffle();
        (raffle, raffleConfig) = deployer.run();
                (, address vrf, , , ,) =
            raffleConfig.activeNetworkConfig();

        vrfCoordinator = vrf;
    }
    /**
     * @dev If the subscriptionId is not valid the fundSubscription will revert
     */
    
    function test_CreateSubscriptionInteractionCreatesValidSubscription () public {
        CreateSubscriptionId createSubscriptionId = new CreateSubscriptionId();
        uint64 subscriptionId = createSubscriptionId.createSubscription(vrfCoordinator);


        (, , , , , address link) = raffleConfig.activeNetworkConfig();

        FundSubscription fundSubscription = new FundSubscription();
                fundSubscription.fundSubscription(vrfCoordinator,subscriptionId, link);

    }


    function test_fundSubscriptionUsingConfigShouldRevertDueToInvalidId () public {
        FundSubscription fundSubscription = new FundSubscription();
        vm.expectRevert();
        fundSubscription.fundSubscriptionUsingConfig();
    }

    function test_createSubscriptionUsingConfigShouldCreateValidSubscription () public {
        CreateSubscriptionId createSubscriptionId = new CreateSubscriptionId();
        createSubscriptionId.createSubscriptionUsingConfig();
    }

    function test_addConsumerShouldAddConsumer () public {
        CreateSubscriptionId createSubscriptionId = new CreateSubscriptionId();
        uint64 subscriptionId = createSubscriptionId.createSubscription(vrfCoordinator);


        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(address(vrfCoordinator),subscriptionId, address(raffle));
    }

    function test_addConsumerShouldRevertWithoutValidId () public {
        AddConsumer addConsumer = new AddConsumer();
        vm.expectRevert();
        addConsumer.addConsumer(address(vrfCoordinator),0, address(raffle));
    }

    function test_addConsumerWithConfigShouldRevertWithoutValidId () public {
        AddConsumer addConsumer = new AddConsumer();
        vm.expectRevert();
        addConsumer.addConsumerUsingConfig(address(raffle));
    }

    function test_CreateSubscriptionContractShouldCreateSubscriptionFromRun () public {
        CreateSubscriptionId createSubscriptionId = new CreateSubscriptionId();
        createSubscriptionId.run();
    }

    function test_AddConsumerRunFunctionShouldRevert () public {
        AddConsumer addConsumer = new AddConsumer();
        vm.expectRevert();
        addConsumer.run();
    }

}