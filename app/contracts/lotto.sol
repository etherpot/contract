contract Lotto {
    
    uint constant blocksPerRound=10;
    // there are an infinite number of rounds (just like a real lottery that takes place every week). `blocksPerRound` decides how many blocks each round will last. 10 is chosen mostly for development purposes and the real lottery will last much longer.

    uint constant ticketPrice = 1;
    // the cost of each ticket in wei. Again, 1 is chosen mostly for development purchases and the real price will be closer to 1 ether.


    struct Round {
        address[] tickets;
        uint totalAmount;
        bool wasFinalized;
    }
    mapping(uint => Round) rounds;
    //the contract maintains a mapping of rounds. Each round maintains a list of tickets, the total amount of the pot, and whether or not the round was "finalized". "Finalization" is the act of paying out the pot to the winner.

    function getRoundIndex() constant returns (uint){
        //The round index tells us which round we're on. For example if we're on block 24, we're on round 2. Division in Solidity automatically rounds down, so we don't need to worry about decimals.
        
        return block.number/blocksPerRound;
    }

    function calculateWinnerForRound(uint roundIndex) constant returns(address){
        //note this function only calculates the winners. It does not do any state changes and therefore does not include various validitiy checks

        var decisionBlockNumber = (roundIndex+1)*blocksPerRound;
        //The winner of every round is decided by the first block of the next round

        if(decisionBlockNumber>block.number)
            return;
        //We can't decided the winner if the round isn't over yet

        var winningTicketIndex = getHashOfBlock(decisionBlockNumber)%rounds[roundIndex].tickets.length;
        //We perform a modulus of the blockhash to determine the winner

        return rounds[roundIndex].tickets[winningTicketIndex];
    }

    function finalizeRound(uint roundIndex){
        if(rounds[roundIndex].wasFinalized)
            return;
        //Rounds can only be finalized once. This is to prevent double payouts

        if(roundIndex>=getRoundIndex())
            return;
        //Rounds can only be finalized once we've moved on to the next round

        var winner = calculateWinnerForRound(roundIndex);
        winner.send(rounds[roundIndex].totalAmount);
        //Send the winner their earnings

        rounds[roundIndex].wasFinalized = true;
        //Mark the round as finalized
    }

    function getHashOfBlock(uint blockIndex) constant returns(uint){
        return uint(block.blockhash(blockIndex));
    }

    function getTickets(uint roundIndex) constant returns (address[]){
        return rounds[roundIndex].tickets;
    }

    function getTotalAmount(uint roundIndex) constant returns(uint){
        return rounds[roundIndex].totalAmount;
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

        rounds[roundIndex].totalAmount+=msg.value;
        //add the value of the transaction to the total amount

    }

}