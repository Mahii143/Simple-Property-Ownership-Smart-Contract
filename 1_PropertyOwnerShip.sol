// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract PropertyOwnerShip {
    uint256 public id = 0;
    address payable public immutable sc_owner;

    struct Property {
        uint256 propertyID;
        address payable owner;
        string details;
        uint256 rate;
    }
    Property asset;

    mapping(uint256 => Property) public assets;

    constructor() {
        sc_owner = payable(msg.sender);
    }

    function addId() public {
        id = id + 1;
    }
    function decId() public {
        id = id - 1;
    }

    function addProperty(string memory _details, uint256 _rate) public {
        asset.propertyID = id;
        asset.owner = payable(msg.sender);
        asset.details = _details;
        asset.rate = _rate;
        assets[id] = asset;
        addId();
    }

    function updateProperty(
        uint256 _propertyID,
        string memory _details,
        uint256 _rate
    ) public {

        require(assets[_propertyID].owner == msg.sender ,"You are not the owner!");

        asset.propertyID = _propertyID;
        asset.details = _details;
        asset.rate = _rate;
        assets[_propertyID] = asset;
        addId();
    }

    function removeProperty(uint256 _propertyID) public {
        require(assets[_propertyID].owner == msg.sender ,"You are not the owner!");
        delete assets[_propertyID];
    }

    function refundPayment(uint256 amount) public {
        uint256 balance = amount;
        payable(msg.sender).transfer(balance);
    }

    function buyProperty(uint256 _propertyID) public payable {
        uint256 amount = msg.value;
        bool result = changeOwnerShip(_propertyID, payable(msg.sender), amount);
        if (!result) {
            refundPayment(amount);
        }
    }

    function changeOwnerShip(
        uint256 _propertyID,
        address payable _owner,
        uint256 amount
    ) private returns (bool) {
        if (assets[_propertyID].rate == amount) {
            //change owner and transact money to him
            address payable prevOwner = assets[_propertyID].owner;
            assets[_propertyID].owner = _owner;
            payable(prevOwner).transfer(amount);
        } else {
            if (assets[_propertyID].rate > amount) {
                uint256 refundable = amount - assets[_propertyID].rate;
                refundPayment(refundable);
                //change owner and transact money to him
                address payable prevOwner = assets[_propertyID].owner;
                assets[_propertyID].owner = _owner;
                payable(prevOwner).transfer(assets[_propertyID].rate);
            } else return false;
        }
        return true;
    }
    
    function viewAllProperties() public view returns (Property[] memory) {
        uint256 x = 0;
        Property[] memory propertyList = new Property[](id);
        for (uint256 i = 0; i < id; i++) {
            if(assets[i].propertyID != 0){
                propertyList[x] = assets[i];
                x++;
            } 
        }
        return propertyList;
    }
}

// 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, "Test Property", 5000000000000000000
