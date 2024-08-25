// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TeacherPerformanceReward {

    address public admin;
    uint256 constant rewardThreshold = 70;

    // Teacher performance data structure
    struct Performance {
        uint8 studentFeedback; // 35%
        uint8 studentImprovement; // 35%
        uint8 peerReview; // 15%
        uint8 teacherExperience; // 15%
    }

    mapping(address => Performance) public teacherPerformances;
    mapping(address => bool) public rewardedTeachers;

    // Modifier to restrict access to admin functions
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    // Function to set performance data for a teacher
    function setPerformance(
        address _teacher, 
        uint8 _studentFeedback, 
        uint8 _studentImprovement, 
        uint8 _peerReview, 
        uint8 _teacherExperience
    ) public onlyAdmin {
        require(_studentFeedback <= 100 && _studentImprovement <= 100 && _peerReview <= 100 && _teacherExperience <= 100, "Values must be between 0 and 100");

        Performance memory newPerformance = Performance({
            studentFeedback: _studentFeedback,
            studentImprovement: _studentImprovement,
            peerReview: _peerReview,
            teacherExperience: _teacherExperience
        });

        teacherPerformances[_teacher] = newPerformance;
    }

    // Function to calculate the weighted score for a teacher
    function calculateScore(address _teacher) public view returns (uint256) {
        Performance memory p = teacherPerformances[_teacher];

        uint256 score = (p.studentFeedback * 35 +
                         p.studentImprovement * 35 +
                         p.peerReview * 15 +
                         p.teacherExperience * 15) / 100;

        return score;
    }

    // Function to grant reward if performance exceeds the threshold
    function grantReward(address _teacher) public onlyAdmin {
        uint256 score = calculateScore(_teacher);
        
        require(score >= rewardThreshold, "Teacher's performance score is below the threshold.");
        require(!rewardedTeachers[_teacher], "Reward already granted to this teacher.");

        rewardedTeachers[_teacher] = true;
        
        // Ensure contract has sufficient balance before transferring
        require(address(this).balance >= 1 ether, "Insufficient balance in contract");
        (bool success, ) = _teacher.call{value: 1 ether}("");
        require(success, "Transfer failed.");
    }

    // Function to check if the teacher is eligible for reward
    function checkEligibility(address _teacher) public view returns (bool) {
        return calculateScore(_teacher) >= rewardThreshold;
    }

    // Function to deposit funds into the contract (for rewards)
    receive() external payable {}
}
