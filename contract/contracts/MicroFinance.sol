pragma solidity ^0.4.23;

// @title microFinance - Allow borrower to borrow loan in 3days
// @author Son Do Phuc

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract MicroFinance {
    using SafeMath for uint256;
    uint256 internal totalLoan;
    /*
     *  CONSTANTS
     */
    uint256 constant public MAXIUM_BORROW = 1 ether;
    uint256 constant public DEADLINE = 1 days;

    function() public payable {
        revert();
    }

    struct Loan {
        address receiver;
        uint256 amount;
        uint256 start;
        uint256 end;
        uint256 timeOut;
        address borrower;
        bool completed;
    }

    mapping(address => Loan) microFinaces;

    /*
     *  EVENTS
     */
    event NewLoan(address borrower, uint256 amount, uint256 timeOut);
    //done loan in deadline
    event DoneInDeadline(uint256 indexed timeOut, address indexed borrower );
    //done before deadline
    event DoneBeforeDeadline(uint256 indexed timeOut, address indexed borrower);
    // fail in loan
    event Failed(address borrower);

    /*
     *  Modifiers
     */
    // only accept loan which is under 1 ether
    modifier onlyValidLoan(uint256 amount) {
        require(amount < MAXIUM_BORROW);
        _;
    }

    //only accept user which wasn't in blacklist
    modifier onlyOutOfBlackList(address borrower) {
        require(microFinaces[borrower].completed == true);
        _;
    }

    modifier onlyValidTimeout(uint256 timeOut) {
        require(timeOut < 3 days);
        _;
    }

    modifier onlyCreatorOfContract(address borrower) {
        require(borrower == msg.sender);
        _;
    }

    modifier onlyNotCompleted(address borrower) {
        require(microFinaces[borrower].completed == false);
        _;
    }

    /*
     *  FUNCTIONS
     */
    /// @dev createLoan function allows users to create a new Loan
    /// @param _amount  Amount which user want to borrow
    function createLoan(uint256 _amount) public onlyOutOfBlackList(msg.sender) onlyValidLoan(_amount) returns(bool success) {
        Loan memory newLoan;

        newLoan.receiver = msg.sender;
        newLoan.amount = _amount;
        newLoan.timeOut = DEADLINE;
        newLoan.start = block.timestamp;

        //triger event
        // emit newLoan( msg.sender, _amount, DEADLINE);

        //append this loan to microFinaces map
        microFinaces[msg.sender] = newLoan;

        totalLoan = totalLoan.add(1);

        return true;
    }

    /// @dev sendLoanToReceiver function allows users to be received Loan
    /// @param _amount  Amount which user is received
    /// @param _receiver address of receiver
    function sendLoanToReceiver(address _receiver, uint256 _amount) internal 
            onlyOutOfBlackList(_receiver) 
            onlyValidLoan(_amount) returns(bool success) {
        microFinaces[_receiver].receiver.transfer(_amount);
        return true;
    }

    /// @dev sendLoanInDeadline function allows users to send Loan back
    /// @param _borrower address of required comfirmations
    function sendLoanInDeadline(address _borrower) public returns (bool success) {
        require(now.sub(microFinaces[_borrower].start) == 3 days);

        //get temporary object
        Loan memory mLoan = microFinaces[_borrower];

        // value must be pay if someone send it in deadline
        uint256 value = ((mLoan.amount.div(100)).mul(10)).add(mLoan.amount);
        mLoan.completed = true;
        mLoan.timeOut = 0;
        mLoan.end = block.timestamp;
        mLoan.start = 0;

        //update data set
        microFinaces[_borrower] = mLoan;

        //_borrower lost 10% loan
        msg.sender.transfer(value);

        emit DoneInDeadline(3 days, _borrower);
        return true;
    }

    /// @dev sendLoanBeforeDeadline function allows users to send Loan back in deadline
    /// @param _borrower address of required comfirmations
    function sendLoanBeforeDeadline(address _borrower) public returns(bool success){
        require(now.sub(microFinaces[_borrower].start) < 3 days);

        Loan memory mLoan = microFinaces[_borrower];

        // value must be pay if someone send it before deadline
        uint256 value = mLoan.amount;
        mLoan.completed = true;
        mLoan.timeOut = 0;
        mLoan.end = block.timestamp;
        mLoan.start = 0;

        //update data set
        microFinaces[_borrower] = mLoan;

        // borrower pay back to contract loan
        msg.sender.transfer(value);

        emit DoneBeforeDeadline (now.sub(microFinaces[_borrower].start), _borrower);

        return true;
    }

    /// @dev failed function allows users to comfirm Loan which is failed
    /// @param _borrower address of required comfirmations
    function failed(address _borrower) public returns (bool success){
        require(now.sub(microFinaces[_borrower].start) < 3 days);

        // set temporary object
        Loan memory mLoan = microFinaces[_borrower];

        // add _borrower into blacklist
        mLoan.completed = false;
        mLoan.timeOut = 0;
        mLoan.end = block.timestamp;
        mLoan.start = 0;
        mLoan.receiver = msg.sender;

        emit Failed(_borrower);
        return true;
    }

}
