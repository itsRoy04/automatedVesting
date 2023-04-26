pragma solidity ^0.8.17;

contract TimeLock {
    uint256 QUARTER = 90 * 86400;
    uint256 NO_OF_QUARTER;
    uint256 public amountToBeReleased = 6327000 * 10**18; //amount needs to be released  every quarter 6,660,000
    address public _recipient;

    uint256 public unlockTime;
    uint256 nextReleaseTime;
    uint256 public quarterCompleted;

    receive() external payable {}

    constructor(address _TransferAddress) {
        unlockTime = block.timestamp; //
        nextReleaseTime = unlockTime + QUARTER;
        NO_OF_QUARTER = 20; // 4 quarter every year
        _recipient = _TransferAddress ;
    }
    
    modifier release() {
        require(
            block.timestamp >= nextReleaseTime + quarterCompleted * QUARTER,
            "Release interval not reached yet"
        );
        _;
    }

    function transferVesting() public release {
        require(quarterCompleted < NO_OF_QUARTER, "End of all Quarter ");
        releaseFund();
        quarterCompleted += 1;
    }

    function releaseFund() internal {
        uint256 balance = address(this).balance;
        require(balance >= amountToBeReleased, "Balance too low");
        payable(_recipient).transfer(amountToBeReleased);
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

    function nextReleaseSchedule() public view returns (uint256) {
        return nextReleaseTime + quarterCompleted * QUARTER;
    }
}