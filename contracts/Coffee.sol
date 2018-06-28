pragma solidity ^0.4.23;

contract Coffee{

    event LogAddCoffeeBatch(uint256 indexed _id);

    struct CoffeeBatch{
        uint256 id;
        uint16 altitude;
        bytes32 variety;
        bytes32 averageCupping; 
        bool isSold;
        Action[] actions;
        string additionalInformation;
    }

    struct Action{
        //@dev address of the individual or the organization who realizes the action.
        address processor;
        //@dev description of the action.
        bytes32 typeOfAction; 
        string additionalInformation;
        // @dev Instant of time when the Action is done.
        uint timestamp;
    }
    CoffeeBatch[] public coffeeBatches;
   // mapping(uint256 => CoffeeBatch) coffeeBatches;
   // uint256[] coffeeBatchIds;

    function getCount() public view returns(uint count) {
        return coffeeBatches.length;
    }

    function addCoffeeBatch(uint16 _altitude, bytes32 _variety, string _additionalInformation, uint _timestamp) public {
        Action memory action = Action(msg.sender,"creation",_additionalInformation, _timestamp); 
        //Fixes memory error that doesn't allow to create memory objects in structs
        coffeeBatches.length++;
        CoffeeBatch storage coffeeBatch = coffeeBatches[coffeeBatches.length - 1];
        //Assigns values
        coffeeBatch.id = coffeeBatches.length - 1;
        coffeeBatch.altitude = _altitude;
        coffeeBatch.variety = _variety;
        coffeeBatch.averageCupping = "";
        coffeeBatch.isSold = false;
        coffeeBatch.actions.push(action);
        coffeeBatch.additionalInformation = _additionalInformation;
        //logs insert
        emit LogAddCoffeeBatch(coffeeBatch.id);        
    }

    function getCoffeeBatchAction(uint _coffeeBatchIndex, uint _actionIndex) 
    public view returns (address,bytes32,string,uint){
        CoffeeBatch memory coffeeBatch = coffeeBatches[_coffeeBatchIndex];
        Action memory action = coffeeBatch.actions[_actionIndex];
        return (
            action.processor,
            action.typeOfAction,
            action.additionalInformation,
            action.timestamp
        );
    }

    //add coffee batch

    //Add Action
    //Update Action
    //Update Actor 
    //Finish Process
    //Get Coffee Process 
    //Get Origin
    //Get Tasters
    

} 