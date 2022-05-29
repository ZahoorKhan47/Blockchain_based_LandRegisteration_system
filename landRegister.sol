// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract landRegistry{

    /*The constructor will assign the contract deployer as a Land_Inpector*/


    constructor(){
        inspector = msg.sender ;
        addLandInspector("Zahoor Khan", 21, "Inspector");
    }


////////////////////////////  DEFINING STRUCTORS///////////////////////////////

/* The following struct define the artibutes need by Seller,Buyer,Land_inspector and Land */

 struct Land {
        uint id;
        uint area;
        string city;
        string state;
        uint landPrice;
        uint propertyPID;

    }

    struct Buyer{
        address id;
        string name;
        uint age;
        string city;
        string cnic;
        string email;
    }

    struct Seller{
        address id;
        string name;
        uint age;
        string city;
        string cnic;
        string email;
        
    }

    struct LandInspector {
        uint id;
        string name;
        uint age;
        string designation;
    }



///////////////////////////////////////mapping and variable//////////////////////////////////////


   /* The following mapping are used to store different parties like Sellers , Buyer , Inspetor and more 
   things like Lands, verified_Sellers, verified_buyers and more */

mapping(uint => Land) private lands;
    mapping(uint => LandInspector) private InspectorMapping;
    mapping(address => Seller) private SellerMapping;
    mapping(address => Buyer) private BuyerMapping;
    mapping(uint => address payable) private LandOwner;
    mapping(address => bool) private registeredSellers;
    mapping(address => bool) private verifiedSellers;
    mapping(address => bool) private rejectedSellers;
    mapping(address => bool) private registeredBuyers;
    mapping(address => bool) private verifiedBuyer;
    mapping(address => bool) private rejectedBuyer;
    mapping(uint => bool) private verifiedLands;
    mapping(uint => bool) private receivedPayments;
    mapping(address => bool) private registeredAddresses;

    address public inspector;
    address[] private sellers;
    address[] private buyers;

    uint private totalinspectors;
    uint private totallands;
  
    

    event Registration(address _registrationId);  
    event Verified(address _id);
    event Rejected(address _id);





/////////////////////////// //////Storing details//////////////////////////////////

/*  Through the following we can add lands , inspectors and register sellers and buyers */

  function addLandInspector(string memory _name, uint _age, string memory _designation) public {
        totalinspectors++;
        InspectorMapping[totalinspectors] = LandInspector(totalinspectors, _name, _age, _designation);
    }
     function addLand(uint _area, string memory _city,string memory _state, uint _landPrice , uint _propertyPID) public {
      //The require  check Seller and its id verifcation 
        require((checkSellerVerification(msg.sender)) && (checkIdVerification(msg.sender)));
        totallands++;
        ////the following commented line will convert land price unit from wei to ether
      ///  _landPrice*=10^18;
        lands[totallands] = Land(totallands, _area, _city, _state, _landPrice ,_propertyPID);
        LandOwner[totallands] = payable(msg.sender);
    
    }

      function registerSeller(string memory _name, uint _age, string memory _city,string memory _cnic,string memory _email) public {
     //here the require check that the seller is not already registered
        require(!registeredAddresses[msg.sender]);

        registeredAddresses[msg.sender] = true;
        registeredSellers[msg.sender] = true ;
        SellerMapping[msg.sender] = Seller(msg.sender, _name, _age, _city,_cnic,_email);
        sellers.push(msg.sender);
        emit Registration(msg.sender);
    }

    
    function registerBuyer(string memory _name, uint _age, string memory _city, string memory _cnic, string memory _email) public {
     //here the require check that the buyer is not already registered
    
        require(!registeredAddresses[msg.sender]);

        registeredAddresses[msg.sender] = true;
        registeredBuyers[msg.sender] = true ;
        BuyerMapping[msg.sender] = Buyer(msg.sender, _name, _age, _city, _cnic, _email);
        buyers.push(msg.sender);

        emit Registration(msg.sender);
    }





/////////////////////////////////updating deatails////////////////////////////////////////

/* Buyers and Sellers details can also be updated through these function*/

function updateSeller(string memory _name, uint _age, string memory _city,string memory _cnic,string memory _email) public {
        // here the require check that the editor is registered and contract deployer
        require(registeredAddresses[msg.sender] && (SellerMapping[msg.sender].id == msg.sender));

        SellerMapping[msg.sender].name = _name;
        SellerMapping[msg.sender].age = _age;
        SellerMapping[msg.sender].city = _city;
        SellerMapping[msg.sender].cnic = _cnic;
        SellerMapping[msg.sender].email = _email;

    }

  function updateBuyer(string memory _name,uint _age, string memory _city,string memory _cnic, string memory _email) public {
        // here the require check that the editor is registered and contract deployer
    
        require(registeredAddresses[msg.sender] && (BuyerMapping[msg.sender].id == msg.sender));

        BuyerMapping[msg.sender].name = _name;
        BuyerMapping[msg.sender].age = _age;
        BuyerMapping[msg.sender].city = _city;
        BuyerMapping[msg.sender].cnic = _cnic;
        BuyerMapping[msg.sender].email = _email;
        
    }



///////////////////////////////////////verifaction///////////////////////////////////////////

// The inspector can verify the seller , buyer and land with the following function

function verifySeller(address _sellerId) public{
    // only land_inspector can verify 
        require(checkLandInspector(msg.sender));

        verifiedSellers[_sellerId] = true;
        emit Verified(_sellerId);
    }
     
     
    function verifyBuyer(address _buyerId) public{
    // only land_inspector can verify 

        require(checkLandInspector(msg.sender));

        verifiedBuyer[_buyerId] = true;
        emit Verified(_buyerId);
    }

  


      
    function verifyLand(uint _landId) public{
    // only land_inspector can verify 

        require(checkLandInspector(msg.sender));

        verifiedLands[_landId] = true;
    }



//////////////////////////////////////checking verification ///////////////////////////////////////

function checkLandInspector(address _inspectorId) public view returns (bool) {
        if(inspector == _inspectorId){
            return true;
        }
            return false;
        
    }

   function checkLandOwner(uint _landId) public view returns (address) {
        return LandOwner[_landId];
    }

     function checkSellerVerification(address _sellerId) public view returns (bool) {
        if(registeredSellers[_sellerId]){
            return true;
        }
        return false;
    }

  function checkBuyerVerification(address _buyerId) public view returns (bool) {
        if(registeredBuyers[_buyerId]){
            return true;
        }
        return false;
    }

  function checkLandVerification(uint _landId) public view returns (bool) {
        if(verifiedLands[_landId]){
            return true;
        }
        return false;
    }

      function checkIdVerification(address _id) public view returns (bool) {
        if(verifiedSellers[_id] || verifiedBuyer[_id]){
            return true;
        }
        return false;
    }

      function IsLandPaid(uint _landId) internal view returns (bool) {
        if(receivedPayments[_landId]){
            return true;
        }
        return false;
    }





// The Inspector can reject a seller or buyer
  function rejectSeller(address _sellerId) public{
        require(checkLandInspector(msg.sender));

        rejectedSellers[_sellerId] = true;
        emit Rejected(_sellerId);
    }

      function rejectBuyer(address _buyerId) public{
        require(checkLandInspector(msg.sender));

        rejectedBuyer[_buyerId] = true;
        emit Rejected(_buyerId);
    }




// We can also get individual details of Seller ,Buyer and Lands (area,city,price,owner)


function GetArea(uint _landId) public view returns (uint) {
        return lands[_landId].area;
    }
    function GetLandCity(uint _landId) public view returns (string memory) {
        return lands[_landId].city;
    }
     function getLandState(uint _landId) public view returns (string memory) {
        return lands[_landId].state;
    }
   
    function GetLandPrice(uint _landId) public view returns (uint) {
        return lands[_landId].landPrice;
    }
    
    
     function getSellerDetails(address _sellerId) public view returns (string memory, uint, string memory, string memory, string memory) {
        return (SellerMapping[_sellerId].name, SellerMapping[_sellerId].age, SellerMapping[_sellerId].city, SellerMapping[_sellerId].cnic, SellerMapping[_sellerId].email);
    }

     function getBuyerDetails(address _buyerId) public view returns ( string memory,uint, string memory, string memory, string memory) {
        return (BuyerMapping[_buyerId].name, BuyerMapping[_buyerId].age,BuyerMapping[_buyerId].city , BuyerMapping[_buyerId].cnic, BuyerMapping[_buyerId].email);
    }


    



// Ther buyer will pay the amount with this function



    function BuyLand (uint _landId) public payable {
        require(verifiedBuyer[msg.sender]);
        require(registeredSellers[LandOwner[_landId]]);
        require(verifiedLands[_landId],"You Cannot buy the land because it is not verified");
        uint price=lands[_landId].landPrice;
        require(msg.value==price,"Your payment is not exactly eqaule to landPrice");

        receivedPayments[_landId] = true;
        LandOwner[_landId].transfer(msg.value);
      
    }
  

//  The land ownership will transfer to the new owner by land inspector
    function transferLandOwnership(uint _landId, address _newLandOwner) public{
        require(checkLandInspector(msg.sender));
        require(IsLandPaid(_landId));

        LandOwner[_landId] = payable(_newLandOwner);
    }
   

   
   



}
