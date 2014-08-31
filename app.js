angular.module('gameCollection', [])

.controller('GameCollectionCtrl', ['$scope', '$http', function($scope, $http){

    $scope.order_by = 'platform.name';

    $http.get('games.json').success(function(response){
        $scope.games = response;
    });

}]);
