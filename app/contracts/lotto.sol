contract Lotto {
    
    uint constant public blocksPerRound=10;
    // there are an infinite number of rounds (just like a real lottery that takes place every week). `blocksPerRound` decides how many blocks each round will last. 10 is chosen mostly for development purposes and the real lottery will last much longer.

    uint constant public ticketPrice = 1;
    // the cost of each ticket in wei. Again, 1 is chosen mostly for development purchases and the real price will be closer to 1 ether.

    uint constant public blockReward = 5000000000000000000;

    function getBlocksPerRound() constant returns(uint){ return blocksPerRound; }
    function getTicketPrice() constant returns(uint){ return ticketPrice; }
    //accessors for constants

    struct Round {
        address[] tickets;
        uint jackpot;
        mapping(uint=>bool) isFinalized;
    }
    mapping(uint => Round) rounds;
    //the contract maintains a mapping of rounds. Each round maintains a list of tickets, the total amount of the pot, and whether or not the round was "finalized". "Finalization" is the act of paying out the pot to the winner.

    function getRoundIndex() constant returns (uint){
        //The round index tells us which round we're on. For example if we're on block 24, we're on round 2. Division in Solidity automatically rounds down, so we don't need to worry about decimals.
        
        return block.number/blocksPerRound;
    }

    function getIsFinalized(uint roundIndex,uint subroundIndex) constant returns (bool){
        //Determine if a given.
        
        return rounds[roundIndex].isFinalized[subroundIndex];
    }


    function calculateWinner(uint roundIndex, uint subroundIndex) constant returns(address){
        //note this function only calculates the winners. It does not do any state changes and therefore does not include various validitiy checks

        var decisionBlockNumber = getDecisionBlockNumber(roundIndex,subroundIndex);

        if(decisionBlockNumber>block.number)
            return;
        //We can't decided the winner if the round isn't over yet

        var winningTicketIndex = getHashOfBlock(decisionBlockNumber)%rounds[roundIndex].tickets.length;
        //We perform a modulus of the blockhash to determine the winner

        return rounds[roundIndex].tickets[winningTicketIndex];
    }

    function getDecisionBlockNumber(uint roundIndex,uint subroundIndex) returns (uint){
        return ((roundIndex+1)*blocksPerRound)+subroundIndex;
    }

    function getMaxSubroundIndex(uint roundIndex) returns(uint){
        var maxSubroundIndex = rounds[roundIndex].jackpot/blockReward;

        if(rounds[roundIndex].jackpot%blockReward>0)
            maxSubroundIndex++;

        return maxSubroundIndex;
    }

    function finalize(uint roundIndex, uint subroundIndex){

        var maxSubroundIndex = getMaxSubroundIndex(roundIndex);

        if(subroundIndex>maxSubroundIndex)
            return;

        var decisionBlockNumber = getDecisionBlockNumber(roundIndex,subroundIndex);

        if(decisionBlockNumber>block.number)
            return;

        if(rounds[roundIndex].isFinalized[subroundIndex])
            return;
        //Subrounds can only be finalized once. This is to prevent double payouts

        var winner = calculateWinner(roundIndex,subroundIndex);      

        if(subroundIndex<maxSubroundIndex)
            winner.send(blockReward);
        else 
            winner.send(rounds[roundIndex].jackpot%blockReward);
        //Send the winner their earnings

        rounds[roundIndex].isFinalized[subroundIndex] = true;
        //Mark the round as finalized
    }

    function getHashOfBlock(uint blockIndex) constant returns(uint){
        return uint(block.blockhash(blockIndex));
    }

    function getTickets(uint roundIndex) constant returns (address[]){
        return rounds[roundIndex].tickets;
    }

    function getJackpot(uint roundIndex) constant returns(uint){
        return rounds[roundIndex].jackpot;
    }

    function() {
        //this is the function that gets called when people send money to the contract.

        var roundIndex = getRoundIndex();

        var ticketsCount = msg.value/ticketPrice;
        //Solidity automatically rounds down, so we don't need to worry about decimals

        var ticketsLength = rounds[roundIndex].tickets.length;
        //Amount of tickets sold in this round BEFORE the new tickets are added

        rounds[roundIndex].tickets.length = rounds[roundIndex].tickets.length+ticketsCount;
        //we need to increase the length of the tickets array to make room for new tickets

        for(var i = 0; i<ticketsCount;i++){
            rounds[roundIndex].tickets[ticketsLength+i]=msg.sender;
            //fill new slots in the tickets array with the purchasers addresses
        }

        rounds[roundIndex].jackpot+=msg.value;
        //add the value of the transaction to the total amount

    }

}