contract Lotto {
    uint constant blocksPerRound=6800;
 
    struct Round {
        address[] buyerAddrs;
        mapping(address=>uint) buyerAmounts;
    }
  
    mapping(uint => Round) rounds;

    function getRoundIndex() constant returns (uint){
        return block.number/blocksPerRound;
    }

    function getBuyerAddrs() constant returns (address[]){
        return rounds[getRoundIndex()].buyerAddrs;
    }

    function getBuyerAmount(address buyerAddr) constant returns(uint){
        return rounds[getRoundIndex()].buyerAmounts[buyerAddr];
    }

    function getTotalAmount() constant returns(uint){
        var roundIndex = getRoundIndex();
        var totalAmount = uint256(0);
        for(var i = 0; i<rounds[roundIndex].buyerAddrs.length;i++){
            var buyerAddr = rounds[roundIndex].buyerAddrs[i];
            totalAmount+= rounds[roundIndex].buyerAmounts[buyerAddr];
        }
        return totalAmount;
    }
   
    function addBuyer(address buyerAddr,uint buyerAmount) returns(address[]){

        var roundIndex = getRoundIndex();
        var buyerExists = false;
        var buyerIndex = uint256(0);

        for(var i = 0; i<rounds[roundIndex].buyerAddrs.length;i++){
            if(rounds[roundIndex].buyerAddrs[i]==buyerAddr){
                buyerExists=true;
                buyerIndex=i;
            }
        }

        if(!buyerExists){
            buyerIndex = rounds[roundIndex].buyerAddrs.length;
            rounds[roundIndex].buyerAddrs.length++;
            rounds[roundIndex].buyerAddrs[buyerIndex] = buyerAddr;
        }

        rounds[roundIndex].buyerAmounts[buyerAddr]+=buyerAmount;
    
    }

    function getBuyersLength() constant returns(uint){
        return rounds[getRoundIndex()].buyerAddrs.length;
    }
  
}