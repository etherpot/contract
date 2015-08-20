var app = angular.module('app',['ui.bootstrap'])

app.run(function($rootScope,$interval,$modal){
	$rootScope.web3 = web3
	$rootScope.Lotto = Lotto

	$rootScope.accounts = web3.eth.accounts
	$rootScope.account = web3.eth.defaultAccount
	$rootScope.blockNumber = web3.eth.blockNumber
	$rootScope.buyers

	$rootScope.blocksPerRound = Lotto.getBlocksPerRound().toNumber()
	$rootScope.ticketPrice = Lotto.getTicketPrice()


	$rootScope.$watch('account',function(account){
		$rootScope.balance = web3.eth.getBalance(account).toString(10)
	})

	$interval(function(){
		$rootScope.blockNumber = web3.eth.blockNumber
		$rootScope.balance = web3.eth.getBalance($rootScope.account).toString(10)
	},300)

	$rootScope.$watch('blockNumber',function(blockNumber){
		$rootScope.roundIndex = Lotto.getRoundIndex()
		$rootScope.pot = Lotto.getPot($rootScope.roundIndex)
		$rootScope.blocksLeft = $rootScope.blocksPerRound-(blockNumber%$rootScope.blocksPerRound)
		$rootScope.eta = 1000*$rootScope.blocksLeft*12.7
	})

	$rootScope.open = function () {
	    var modalInstance = $modal.open({
	      templateUrl: 'ticketModal',
	      controller: 'TicketController',
	      resolve: {
	        items: function () {
	          return [];
	        }
	      }
	    });
	}
})

app.controller('TicketController',function($scope){
	$scope.ticketsCount = 1;
})