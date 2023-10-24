
// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract chatApp {

    struct user {
        string name;
        friend[] friendList;
    }

    struct friend {
        address pubKey;
        string name;
    }

    struct message {
        address sender;
        uint256 timestamp;
        string msg;
    }

    struct AllUserStruck{
        string name;
        address accountAddress;
    }

    AllUserStruck[] getAllUsers;

    mapping (address => user) userList;

    mapping (bytes32 => message[]) allMessages;

    //CHECK USER EXISITS
    function checkUserexists(address pubKey) public view returns(bool){
        return bytes(userList[pubKey].name).length > 0;
    }

    //CREATE USER ACCOUNT
    function createUserAccount(string calldata name) external{
        require(checkUserexists(msg.sender)==false, "User Already Exists");
        require(bytes(name).length>0, "Name Cannot be empty");

        userList[msg.sender].name=name;

        getAllUsers.push(AllUserStruck(name, msg.sender));

    }

    //GET USERNAME
    function getUserName(address pubKey) external view returns(string memory){
        require(checkUserexists(pubKey),"User Does not Exists");
        return userList[pubKey].name;
    }

    //ADD FRIEND
    function addFriend(address friend_Key, string calldata name) external{
        require(checkUserexists(msg.sender), "Create an account first");
        require(checkUserexists(friend_Key), "User is not registered");
        require(msg.sender!=friend_Key, "You Cannot add yourself");
        require(checkAlreadyFriends(msg.sender, friend_Key) == false, "These users are already friends");

        _addFriend(msg.sender, friend_Key, name);
        _addFriend(friend_Key, msg.sender, userList[msg.sender].name);
    }

    //CHECK ALREADY FRIENDS
    function checkAlreadyFriends(address pubKey1, address pubKey2) internal view returns (bool) {
        if(userList[pubKey1].friendList.length > userList[pubKey2].friendList.length){
            address temp= pubKey1;
            pubKey1=pubKey2;
            pubKey2=temp;
        }
        for (uint256 i=0; i< userList[pubKey1].friendList.length; i++){
            if(userList[pubKey1].friendList[i].pubKey == pubKey2) return true;
        }
        return false;
    }

    //ADD FRIEND
    function _addFriend(address me, address friend_key, string memory name) internal{
        friend memory newFriend = friend(friend_key, name);
        userList[me].friendList.push(newFriend);
    }

    //GET MY FRIENDLIST
    function getMyFriendList() external view returns(friend[] memory){
        return userList[msg.sender].friendList;
    }

    //GET CHAT CODE
    function _getChatCode(address pubKey1, address pubKey2) internal pure returns(bytes32){
        if (pubKey1<pubKey2){
            return keccak256(abi.encodePacked(pubKey1,pubKey2));
        }
        else return keccak256(abi.encodePacked(pubKey2,pubKey1));
    }
    
    //SEND MESSAGE
    function sendMessage(address friend_key, string calldata _msg) external{
        require(checkUserexists(msg.sender), "Create an account first");
        require(checkUserexists(friend_key), "User has not registered");
        require(checkAlreadyFriends(msg.sender, friend_key), "You have to be friends first before sending the message");

        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
        message memory newMsg = message(msg.sender, block.timestamp, _msg);
        allMessages[chatCode].push(newMsg);
    }

    //READ MESSAGE
    function readMessage(address friend_key) external view returns (message[] memory) {
        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
        return allMessages[chatCode];
    }

    //GET ALL USERS
    function getAllAppUsers() public view returns(AllUserStruck[] memory){
        return getAllUsers;
    }
}