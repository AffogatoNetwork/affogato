pragma solidity ^0.5.9;

/** @title Coffee Batch Factory.
  * @author Affogato
  */

import 'openzeppelin-solidity/contracts/lifecycle/Pausable.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import "./ActorFactory.sol";
import "./CoffeeBatchFactory.sol";

/** TODO:
  * Should be able to burn Tastings
  */

contract CupProfileFactory is Ownable, Pausable{

    /** @notice Logs when a Cup Profile is created. */
    event LogAddCupProfile(
        uint indexed _id,
        uint _coffeeBatchId,
        address _tasterAddress,
        string _profile,
        string _imageHash,
        uint16 _cuppingNote
    );

    /** @notice Logs when a Cup Profile is updated. */
    event LogUpdateCupProfile(
        uint indexed _id,
        string _profile,
        string _imageHash,
        uint16 _cuppingNote
    );

    /** @notice Throws if called by any account not allowed. */
    modifier isAllowed(address _farmerAddress, address _target){
        require(actor.isAllowed(_farmerAddress, msg.sender), "not authorized");
        _;
    }

    /** @notice Throws if called by any account other than a taster*/
    modifier onlyTaster(){
        require(actor.isTaster(msg.sender), "not a taster");
        _;
    }

    /**@dev ActorFactory contract object */
    ActorFactory actor;

    struct CupProfile {
        uint uid;
        string profile;
        string imageHash; /** @dev IPFS hash*/
        uint16 cuppingNote; /** @dev Range from 0 to 100*/
        address tasterAddress;
    }

    mapping(uint => uint[]) public coffeeBatchToCupProfiles;
    mapping(uint => CupProfile) public cupProfiles;
    uint tastingCount = 1;

    /** @notice Constructor, sets the actor factory
      * @param _actorAddress contract address of ActorFactory
      */
    constructor(address payable _actorAddress) public {
        actor = ActorFactory(_actorAddress);
    }

    /** @notice Gets the number of Tastings per coffee batch
      * @param _coffeeBatch id of the coffee batch to count
      * @return returns a uint with the amount of tastings
      */
    function getCoffeeCupProfileCount(uint _coffeeBatch) public view returns (uint) {
        return coffeeBatchToCupProfiles[_coffeeBatch].length;
    }

    /** @notice Gets the data of the cup tasting by id.
      * @param _uid uint with the id of the tasting.
      * @return the values of the tasting.
      */
    function getCupProfileById(uint _uid)
        public
        view
        returns (
            uint,
            string memory _profile,
            string memory,
            uint16,
            address
        )
    {
        CupProfile memory cupProfile = cupProfiles[_uid];
        return (
            cupProfile.uid,
            cupProfile.profile,
            cupProfile.imageHash,
            cupProfile.cuppingNote,
            cupProfile.tasterAddress
        );
    }

    /** @notice creates a new tasting
      * @param _farmerAddress address of the farmer.
      * @param _coffeeBatchId id of the coffee batch.
      * @param _profile of the coffee batch.
      * @param _imageHash of the coffee batch.
      * @param _cuppingNote of the coffee batch.
      * @dev sender must be a taster and must be allowed
      */
    function addCupProfile(
        address _farmerAddress,
        uint _coffeeBatchId,
        string memory _profile,
        string memory _imageHash,
        uint16 _cuppingNote
    ) public whenNotPaused  isAllowed(_farmerAddress, msg.sender) onlyTaster{
        uint uid = tastingCount;
        CupProfile memory cupProfile = CupProfile(
            uid,
            _profile,
            _imageHash,
            _cuppingNote,
            msg.sender
        );
        coffeeBatchToCupProfiles[_coffeeBatchId].push(uid);
        cupProfiles[uid] = cupProfile;
        tastingCount++;
        emit LogAddCupProfile(
            uid,
            _coffeeBatchId,
            msg.sender,
            _profile,
            _imageHash,
            _cuppingNote
        );
    }
    /** @notice Updates a cup profile
      * @param _uid of the cup profile.
      * @param _profile id of the coffee batch.
      * @param _imageHash of the coffee batch.
      * @param _cuppingNote of the coffee batch.
      * @dev sender must be a taster and must be creator
      */
    function updateCupProfileById(
        uint _uid,
        string memory _profile,
        string memory _imageHash,
        uint16 _cuppingNote
    ) public whenNotPaused onlyTaster {
        require(cupProfiles[_uid].cuppingNote != 0, "cup profile should't be empty");
        require(cupProfiles[_uid].tasterAddress == msg.sender,"updater should be the taster");
        CupProfile storage cupProfile = cupProfiles[_uid];
        cupProfile.profile = _profile;
        cupProfile.imageHash = _imageHash;
        cupProfile.cuppingNote = _cuppingNote;
        emit LogUpdateCupProfile(_uid, _profile, _imageHash, _cuppingNote);
    }

    /** @notice destroys contract
      * @dev Only Owner can call this method
      */
    function destroy() public onlyOwner {
        address payable owner = address(uint160(owner()));
        selfdestruct(owner);
    }

    /** @notice reverts if ETH is sent */
    function() external payable{
      revert("Contract can't receive Ether");
    }
}