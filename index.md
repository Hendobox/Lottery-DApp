OVERVIEW:

The aim is to steadily introduce the students to every aspect of solidity and smart contracts while giving them smart contract exercises for practice and better understanding.

Contract feature/requirement:

There is this prejudice that lottery winners usually get chosen on a partial basis and even though these lottery companies try to be as transparent as possible in their selection processes, participants cannot really vouch for fair-play because of the centralization of platforms. Here we will be developing a decentralized lottery DApp smart contract which gives all the features for participants to monitor the process of winners’ selection, as well as the power for winners to directly withdraw their prizes from the smart contract without delays or the interference of the contract owner. The Contract will contain the following features...



STATE VARIABLES:

owner: An address to define the owner of the contract.

participantNum: A public uint256 type to show how many people participated in the lottery.

randNonce: A uint256 type to be used as a computational variable for randomization.

winners: A public array of winners’ addresses.

prize: A public uint256 type which defines the award.



STRUCT:

Participant: Contains a string for ‘name’ and a boolean ‘isWhitelisted’.


MAPPINGS:

rewarded:A public mapping of address to boolean to know which address has been rewarded.

logs: A public mapping of selected numbers to an array of addresses owned by participants who selected the number.

participants: A public mapping of addresses to Participant struct.



ENUM

LotteryState: It contains Open and Closed. Also include an instance to enable changing its state.



EVENTS

NewRegistration: Displays when a member signs up. Shows name and address 

MemberJoined: Displays when a member participates in the lottery. Shows address and chosen number(which should be indexed for easy sorting)

Blacklisted: Displays when a member is restricted from participating. Shows address and name

WinnnerSelected: Displays the winning number



MODIFIERS:

onlyOwner: Should throw an error if the caller is not the owner of the contract

onlyWhitelisted: Should throw an error if the caller is not whitelisted



CONSTRUCTOR:

The constructor function should make the deployer the owner of the contract. It should also change the LotteryState to open.



FUNCTIONS:

addParticipant: 
- An external function with one argument (string).
- It should add participants to the Participant struct and whitelist them.
- It should emit the NewRegistration event.

blackListParticipant:
- An external function to be called only by the contract owner
- It should carry one argument (the Participant’s address)
- The participant’s whitelisted status should be changed to false
- It should emit the Blacklisted event

isWhitelisted:
- An external view function that returns a boolean
- It should have one argument (the Participant’s address)
- It should return the whitelisted status of the passed address

participate:
- An external payable function that can only be called by a whitelisted member
- It should have two arguments (the selected number and the Participant’s address)
- It should ensure that the caller matches the passed address
- It should ensure that the chosen number falls between 1 - 1000
- It should ensure that the participant sends exactly 0.1 ether when calling the function
- It should ensure that the lottery state is open
- It should add the selected number and address to the logs mapping
- It should increase the participantNum by 1
- It should emit the MemberJoined event

_randomNumber:
- An internal function that passes one argument (uint) and returns a uint
- It should hash the present time with the sender’s address and randNonce.
- It should also find the modulus of the passed uint
- It should increase the randNonce by 1
- It should return the random number

selectWinners:
- An external function that can only be called by the ‘owner’ of contract and returns a uint
- It should close the state of the lottery
- Create a uint variable which calls the ‘_randomNumber’ with an argument (1000) and adds 1 to the result
- Merge the ‘winners’ array with the logs mapping using the variable you created above
- Let ‘prize’ be the balance of the contract address divided by the number of winners
- It should emit the WinnerSelected event

isWinner:
- A public view function that returns a bool
- Should loop through the array to ensure that winners don't exceed the number
- An if-else statement checks if caller’s address is among the winners array and returns a boolean

withdrawPrize:
- A public payable function that returns a boolean
- Ensures that the caller is among the winners
- Ensures that the caller isn’t rewarded already
- Records that the caller has received rewards in the ‘rewarded’ mapping
- Transfers the ‘prize’ to the caller
- Returns true



OTHER MODALITIES:

Contract inheritance.
Contract will inherit SafeMath.sol and Ownable.sol to check user permissions
