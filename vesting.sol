pragma solidity ^0.8.17;

contract TimeLock {
    uint256 YEAR = 60 * 60 ; // test
    // uint256 YEAR = 365 * 86400;
    uint256 QUARTER = 3*60; // test
    // uint256 QUARTER = 90 * 86400;
    uint256 NO_OF_YEARS;
    uint256 NO_OF_QUARTER;
    uint256 public amountToBeReleased = 6 * 10**18; //amount needs to be released  every quarter 6660000
    address public owner;

    address public _recipient;

    uint256 public unlockTime;
    uint256 nextReleaseTime;
    uint256 public quarterCompleted;

    receive() external payable {}

    constructor(address _TransferAddress) {
        unlockTime = block.timestamp; //
        nextReleaseTime = unlockTime + QUARTER;
        NO_OF_YEARS = 5; // total years count
        NO_OF_QUARTER = 5; // 4 quarter every year
        owner = msg.sender;
        _recipient = _TransferAddress ;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    modifier release() {
        require(
            block.timestamp >= nextReleaseTime + quarterCompleted * QUARTER,
            "Release interval not reached yet"
        );
        _;
    }

    function transferVesting() public release {
        // not onlyowner
        require(quarterCompleted < NO_OF_QUARTER, "End of all Quarter ");
        releaseFund();
        quarterCompleted += 1;
    }

    function releaseFund() internal {
        uint256 balance = address(this).balance;

        require(balance >= amountToBeReleased, "Balance too low");
        payable(_recipient).transfer(amountToBeReleased);
    }

    function changeRecipient(address _newRecipient) public onlyOwner {
        _recipient = _newRecipient;
    }

    function time() public view returns (uint256) {
        return block.timestamp;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function remainingQuarter() public view returns (uint256) {
        return NO_OF_QUARTER - quarterCompleted;
    }

    // function Withdrawal() public {
    //     uint256 balance = address(this).balance;
    //     payable(owner).transfer(balance);
    // }

    function nextReleaseSchedule() public view returns (uint256) {
        return nextReleaseTime + quarterCompleted * QUARTER;
    }
}
