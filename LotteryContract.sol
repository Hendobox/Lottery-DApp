pragma solidity ^0.5.0;

import './SafeMath.sol';

contract Lottery is SafeMath {
    
    using SafeMath for uint256;
    
    address owner;
    uint256 participants = 0;
    uint256 randNonce = 0;
    address[] winnersList;
    uint prize;

    enum LotteryState { Open, Closed }
    LotteryState public lotteryState; 

    mapping (address => bool) rewarded;
    mapping (uint256 => address[]) winners;
    
    event MemberJoined(address memberAddress, uint256 indexed chosenNumber);
    
    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can make this call");
        _;
    }
    
    constructor() public {
        owner = msg.sender;   
        lotteryState = LotteryState.Open; 
    }
    
    function join(uint256 _chosenNumber) payable external {
        require(_chosenNumber > 0 && _chosenNumber <= 1000, 'Must be a number between 1-1000');
        require(msg.value == 0.1 ether, 'Send 0.1 Eth to join');
        require(lotteryState == LotteryState.Open, 'Lottery is closed');
        winners[_chosenNumber].push(msg.sender);  
        participants++;
        emit MemberJoined(msg.sender, _chosenNumber);
    }
    
    function randomNumber(uint _limit) external returns(uint256) {
        uint random = uint256(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % _limit;
        randNonce++;
        return random;
    }
    
    function selectWinners() external onlyOwner returns(uint) {
        lotteryState = LotteryState.Closed;
        uint256 selected = randomNumber(1000) + 1;
        winnersList = winners[selected];
        prize = address(this).balance / winnersList.length;
       // emit WinnnersSelected(msg.sender, _chosenNumber);
    }

    function isWinner() external view returns(bool) {
        for(uint i = 0; i < winnersList.length; i++) {
            if (winnersList[i] == msg.sender) {
                return true;
            } else {
                return false;
            }
        }
    }

    
    function withdrawReward() external {
        require(isWinner(), "You must be a winner");
        require(rewarded[msg.sender] != true, "You have got your reward");
        rewarded[msg.sender] = true;
        msg.sender.transfer(prize);
    }

     
    
}