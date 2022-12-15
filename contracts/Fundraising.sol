// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Fundraising {
    event Created(string name, string purpose, address creator, address[] beneficiaries, uint goalAmount, uint createdAt, uint deadline);
    event Completed(string name, uint raisedAmount); 

    struct Campaign {
        string name;
        string purpose;
        address creator;
        address[] beneficiaries;
        uint goalAmount;
        uint createdAt;
        uint deadline;

        uint raisedAmount;
        bool completed;
    }

    Campaign[] public campaigns;
    mapping(string => bool) public campaignNames;

    function getCampaigns() public view returns (Campaign[] memory) {
        return campaigns;
    }

    function getCampaignsCount() public view returns (uint) {
        return campaigns.length;
    }

    function getIndexByName(string memory _name) public view returns (uint) {
        for (uint i = 0; i < campaigns.length; i++) {
            if (keccak256(bytes(campaigns[i].name)) == keccak256(bytes(_name))) {
                return i;
            }
        }
        revert("Campaign not found");
    }

    function getMissingAmount(uint _index) public view returns (uint) {
        Campaign storage campaign = campaigns[_index];
        if (campaign.raisedAmount >= campaign.goalAmount) {
            return 0;
        }
        return campaign.goalAmount - campaign.raisedAmount;
    }

    mapping(uint => mapping(address => uint)) public campaignContributions;

    function getCampaignContributions(uint _index, address _contributor) public view returns (uint) {
        return campaignContributions[_index][_contributor];
    }

    function getTotalContributions(address _contributor) public view returns (uint) {
        uint total = 0;
        for (uint i = 0; i < campaigns.length; i++) {
            total += campaignContributions[i][_contributor];
        }
        return total;
    }

    function create(string memory _name, string memory _purpose, address[] memory _beneficiaries, uint _goalAmount, uint _deadline) public {
        require(bytes(_name).length > 0, "Name must be given");
        require(bytes(_name).length <= 100, "Name must be <= 100 characters");
        require(!campaignNames[_name], "Name already taken");
        require(bytes(_purpose).length > 0, "Purpose must be given");
        require(bytes(_purpose).length <= 1000, "Purpose must be <= 1000 characters");
        require(_beneficiaries.length > 0, "There must be at least one beneficiary");
        require(_goalAmount > 0, "Goal must be > 0");
        require(_goalAmount % 1000000000000000 == 0, "Goal must be a multiple of 0.001");
        require(_deadline < block.timestamp + 365 days, "Deadline must be within 365 days");

        Campaign memory newCampaign = Campaign(_name, _purpose, msg.sender, _beneficiaries, _goalAmount, block.timestamp, _deadline, 0, false);
        campaignNames[_name] = true;
        campaigns.push(newCampaign);
        emit Created(_name, _purpose, msg.sender, _beneficiaries, _goalAmount, block.timestamp, _deadline);
    }

    function suspend(uint _index) public {
        Campaign storage campaign = campaigns[_index];
        require(block.timestamp < campaign.deadline || campaign.raisedAmount < campaign.goalAmount, "Fundraising is over");
        require(!campaign.completed, "Fundraising has already been completed");
        require(msg.sender == campaign.creator, "Only the creator can suspend the campaign");

        campaign.completed = true;
        uint amountPerBeneficiary = campaign.raisedAmount / campaign.beneficiaries.length;
        for (uint i = 0; i < campaign.beneficiaries.length; i++) {
            payable(campaign.beneficiaries[i]).transfer(amountPerBeneficiary);
        }
        emit Completed(campaign.name, campaign.raisedAmount);
    }

    function contribute(uint _index) public payable {
        require(msg.value > 0, "You need to send some ether");
        require(msg.value % 1000000000000000 == 0, "You need to send a multiple of 0.001");
        
        Campaign storage campaign = campaigns[_index];
        require(block.timestamp < campaign.deadline, "Fundraising is over");
        require(campaign.raisedAmount + msg.value <= campaign.goalAmount, "The goal has been reached");
        
        campaign.raisedAmount += msg.value;
        campaignContributions[_index][msg.sender] += msg.value;
    }

    function collect(uint _index) public {
        Campaign storage campaign = campaigns[_index];
        require(block.timestamp >= campaign.deadline || campaign.raisedAmount >= campaign.goalAmount, "Fundraising is not over yet");
        require(!campaign.completed, "Fundraising has already been completed");
        require(campaign.raisedAmount > 0, "No funds have been raised");
        bool isBeneficiary = false;
        for (uint i = 0; i < campaign.beneficiaries.length; i++) {
            if (campaign.beneficiaries[i] == msg.sender) {
                isBeneficiary = true;
                break;
            }
        }
        require(isBeneficiary, "You are not allowed to withdraw");

        campaign.completed = true;
        payable(msg.sender).transfer(campaign.raisedAmount);
        emit Completed(campaign.name, campaign.raisedAmount);
    }
}