pragma solidity ^0.5.0;

import './SafeMath.sol';        //imports SafeMath

contract Lottery {
    using SafeMath for uint256;     //initiates SafeMath
    address owner;      //owner's address
    uint256 public participants = 0;       //number of participants
    uint256 randNonce = 0;      //pre-defined variable to influence the randomization of the contract
    address[] public winnersList;      //array of winners addresses
    uint256 public prize;     //lottery prize
    
    //defines the state of the lottery
    enum LotteryState { Open, Closed }       
    LotteryState public lotteryState;       

    //mapping showing if winner has been rewarded
    mapping (address => bool) rewarded;     
    //mapping of selected numbers to the array of addresses that picked the number
    mapping (uint256 => address[]) winners;
    
    //event displayed when a new member joins the lottery
    event MemberJoined(address memberAddress, uint256 indexed chosenNumber);        
    
    //modifier to give rights to only contract owner
    modifier onlyOwner {
        //ensures that the caller of the function must be the owner
        require(msg.sender == owner, "Only owner can make this call");
        _;
    }
    
    //constructor function to be executed on deployment
    constructor() public {
        //makes the deployer owner of smart contract
        owner = msg.sender;     
        //opens the state of the lottery on deployment
        lotteryState = LotteryState.Open;
    }
    
    //function to enable members participate in the lottery
    function participate(uint256 _chosenNumber) payable external {
        //ensures that the chosen number falls within 1-1000
        require(_chosenNumber > 0 && _chosenNumber <= 10, 'Must be a number between 1-1000');
        //ensures that participant sends exactly 0.1 ether to join
        require(msg.value == 0.1 ether, 'Send 0.1 Eth to join');
        //ensures that the state of the lottery is open before members can join
        require(lotteryState == LotteryState.Open, 'Lottery is closed');
        //adds the address of members to array of the winners mapping in accordance to selected number
        winners[_chosenNumber].push(msg.sender);  
        //updates the number of participants
        participants = participants.add(1);
        //emits an event
        emit MemberJoined(msg.sender, _chosenNumber);
    }
    
    /*
    * This function first hashes the curret time, sender's address, and
    * radNonce as defined in the state variable. Next, it converts the hash 
    * an integer and divides it by _limit to get an integer between 1-1000.
    * The randNonce is increased by 1 for the next transaction.
    */
    function _randomNumber(uint _limit) internal returns(uint256) {
        uint random = uint256(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % _limit;
        randNonce = randNonce.add(1);
        return random;
    }
    
    //function for smart contract owner to select winners
    function selectWinners() external onlyOwner returns(uint256) {
        //closes the state of the lottery
        lotteryState = LotteryState.Closed;
        //selects a random number within 1000 and adds 1
        uint256 selected = _randomNumber(10).add(1);
        //binds the winnersList array with the winners mapping
        winnersList = winners[selected];
        //divides the ether balance in the smart contract with the number of winners
        prize = address(this).balance / winnersList.length;
        //emits event
        //emit WinnnersSelected(msg.sender, _chosenNumber);
    }

    //function to check if caller is among the winners
    function isWinner() public view returns(bool) {
        //loops through the array to ensure that winners don't exceed the number
        for(uint i = 0; i < winnersList.length; i++) {
        //if and else statement to verify winners
            if (winnersList[i] == msg.sender) {
                return true;
            } else {
                return false;
            }
        }
    }
    
    //function for winners to withdraw the prize
    function withdrawPrize() public payable returns(bool success) {
        //ensures that caller is among the winners
        require(isWinner(), "You must be a winner");
        //ensures that winner hasn't already made withdrawal
        require(rewarded[msg.sender] != true, "You have taken your reward");
        //records that the user has made withdrawal
        rewarded[msg.sender] = true;
        //transfers prize to the user
        msg.sender.transfer(prize);
        return true;
    }
    
}