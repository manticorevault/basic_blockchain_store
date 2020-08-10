    pragma solidity ^0.4.24;
    
    // Define a Supply Chain Contract "Lemonade Stand"
    contract LemonadeStand { 
        
        // Variable: "Owner"
        address owner;
        
        // Variable: "skuCount"
        uint skuCount;
        
        // State: For Sale 
        enum State { ForSale, Sold, Shipped }
        
        // Struct: "Item" with the following fields: name, sku, price, state, seller, buyer
        struct Item {
            string name;
            uint sku;
            uint price;
            State state;
            address seller;
            address buyer;
        }
        
        // Mapping: Assign "Item" a sku
        mapping (uint => Item) items;
        
        // Event ForSale
        event ForSale(uint skuCount);
        
        // Event Sold
        event Sold(uint sku);
        
        // Event Shipped
        event Shipped(uint sku);
        
        // modifier: Only Owner to see if msg.sender == owner of the contract
        modifier onlyOwner() {
            require(msg.sender == owner);
            _;
        }
        
        // modifier: verify caller to verify the caller 
        modifier verifyCaller(address _address) {
            require(msg.sender == _address);
            _;
        }
        
        // modifier: paid enough to check if the paid amount is sufficient to cover the price
        modifier paidEnough(uint _price) {
            require(msg.value >= _price);
            _;
        }
        
        // modifier: For Sale to check if an item.state of a sku is for sale
        modifier forSale(uint _sku) {
            require(items[_sku].state == State.ForSale);
            _;
        }
        
        // modifier: Sold to check if an item.state of a sku is sold
        modifier sold(uint _sku) {
            require(items[_sku].state == State.Sold);
            _;
        }
        
        // function: constructor to set some initial values
        constructor() public {
            owner = msg.sender;
            skuCount = 0;
        }
        
        // function: add Item 
        function addItem(string _name, uint _price) onlyOwner public {
            //Increment sku 
            skuCount = skuCount + 1;   
            
            //emit the appropriate event
            emit ForSale(skuCount);
            
            //Add the new item into the inventory and mark it for sale
            items[skuCount] = Item({ name: _name, sku: skuCount, price: _price, state: State.ForSale, seller: msg.sender, buyer: 0 });
        }
        
        // function: buy Item
        function buyItem(uint sku) forSale(sku) paidEnough(items[sku].price) public payable {
            address buyer = msg.sender;
            uint price = items[sku].price;
            
            //update buyer
            items[sku].buyer = buyer;
            
            //update State
            items[sku].state = State.Sold;
            
            //transfer the money to seller
            items[sku].seller.transfer(price);
            
            //emit the appropriate event
            emit Sold(sku);
        }

        // function: fetch item 
        function fetchItem(uint _sku) public view returns (string name, uint sku, uint price, string stateIs, address seller, address buyer) {
            uint state;
            name = items[_sku].name;
            sku = items[_sku].sku;
            price = items[_sku].price;
            state = uint(items[_sku].state);

            if( state == 0) {
                stateIs = "For Sale";
            }

            if( state == 1) {
                stateIs = "Sold";
            }

            seller = items[_sku].seller;
            buyer = items[_sku].buyer;
        }
        
        // Define a function 'shipItem' that allows the seller to change the state to 'Shipped'
        function shipItem(uint sku) public sold(sku) verifyCaller(items[sku].seller) {
            // Update state
            items[sku].state = State.Shipped;
            
            // Emit the appropriate event
            emit Shipped(sku);
        }
        
}