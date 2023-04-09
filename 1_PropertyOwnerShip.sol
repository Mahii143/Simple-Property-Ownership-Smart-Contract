// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract PropertyOwnerShip {
    uint256 public id = 1;
    address payable public sc_owner;

    constructor() {
        sc_owner = payable(msg.sender);
    }

    function addId() public {
        id = id + 1;
    }

    struct Property {
        uint256 propertyID;
        address payable owner;
        string details;
        uint256 rate;
    }
    Property asset;

    mapping(uint256 => Property) public assets;

    function addProperty(
        address payable _owner,
        string memory _details,
        uint256 _rate
    ) public {
        asset.propertyID = id;
        asset.owner = _owner;
        asset.details = _details;
        asset.rate = _rate;
        assets[id] = asset;
        addId();
    }

    function updateProperty(
        uint256 _propertyID,
        address payable _owner,
        string memory _details,
        uint256 _rate
    ) public {
        asset.propertyID = _propertyID;
        asset.owner = _owner;
        asset.details = _details;
        asset.rate = _rate;
        assets[_propertyID] = asset;
        addId();
    }

    function removeProperty(uint256 _propertyID) public {
        delete assets[_propertyID];
    }

    function viewAllProperties() public view returns (Property[] memory) {
        Property[] memory propertyList = new Property[](id);
        for (uint256 i = 1; i <= id; i++) {
            propertyList[i - 1] = assets[i];
        }
        return propertyList;
    }

    function refundPayment(uint256 amount) public {
        uint256 balance = amount;
        payable(msg.sender).transfer(balance);
    }

    function receivePayment(uint256 _propertyID, address payable _owner)
        public
        payable
    {
        uint256 amount = msg.value;
        bool result = changeOwnerShip(_propertyID, _owner, amount);
        if (!result) {
            refundPayment(amount);
        }
    }

    function changeOwnerShip(
        uint256 _propertyID,
        address payable _owner,
        uint256 amount
    ) public returns (bool) {
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
}

// 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, "Test Property", 5000000000000000000