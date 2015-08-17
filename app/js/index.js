var app = angular.module('app',[])

app.run(function($rootScope,$interval){
	$rootScope.web3 = web3
	$rootScope.Lotto = Lotto

	$rootScope.accounts = web3.eth.accounts
	$rootScope.account = web3.eth.defaultAccount
	$rootScope.blockNumber = web3.eth.blockNumber
	$rootScope.buyers

	$rootScope.blocksPerRound = Lotto.getBlocksPerRound()
	$rootScope.ticketPrice = Lotto.getTicketPrice()


	$rootScope.$watch('account',function(account){
		$rootScope.balance = web3.eth.getBalance(account).toString(10)
	})

	$interval(function(){
		$rootScope.blockNumber = web3.eth.blockNumber
		$rootScope.balance = web3.eth.getBalance($rootScope.account).toString(10)
	},300)

	$rootScope.$watch('blockNumber',function(blockNumber){
		$rootScope.roundIndex = Lotto.getRoundIndex();
		$rootScope.totalAmount = Lotto.getTotalAmount($rootScope.roundIndex);
	})

	function updateBuyers(){
		var buyerAddresses = Lotto.getBuyerAddresses()
			,buyers = {}

		buyerAddresses.forEach(function(buyerAddress){
			buyers[buyerAddress] = Lotto.getBalance(buyerAddress)
		})
	}
})