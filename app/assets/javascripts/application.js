// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require_tree .

var APP = angular.module( "Hangry", [] );

APP.directive('datepicker', function ($parse) {
  return function (scope, element, attrs, controller) {
    var ngModel = $parse(attrs.ngModel);
    $( function() {
      element.datepicker({
        dateFormat: "yy-mm-dd",
        onSelect: function( dateText, inst ) {
          scope.$apply( function( scope ) {
            ngModel.assign( scope, dateText );
          });
        }
      });
    });
  }
});

APP.run(function($rootScope) {
 $rootScope.prettyDate = function(time){
  	var date = new Date((time || "").replace(/-/g,"/").replace(/[TZ]/g," ")),
    		diff = (((new Date()).getTime() - date.getTime()) / 1000),
    		day_diff = Math.floor(diff / 86400);
		
  	if ( isNaN(day_diff) || day_diff < 0 || day_diff >= 31 )
  		return;
		
  	return day_diff == 0 && (
			diff < 60 && "just now" ||
			diff < 120 && "1 minute ago" ||
			diff < 3600 && Math.floor( diff / 60 ) + " minutes ago" ||
			diff < 7200 && "1 hour ago" ||
			diff < 86400 && Math.floor( diff / 3600 ) + " hours ago") ||
  		day_diff == 1 && "yesterday" ||
  		day_diff < 7 && day_diff + " days ago" ||
  		day_diff < 31 && Math.ceil( day_diff / 7 ) + " weeks ago";
  };
});

APP.controller('ListController', ['$scope', '$http', function ($scope, $http) {
  $http.get( '/restaurants/pick.json' ).success( function( data ) {
    $scope.choice = data;
  });

  $http.get( '/restaurants.json' ).success( function( data ) {
    for( var i=0; i < data.length; i++ ) data[i].editing = false;
    $scope.list = data;
  });
  
  $scope.deleteItem = function( item, event ) {
    $http.delete( '/restaurants/' + item.id + '.json' ).success( function( data ) {
      $( event.target ).parent().parent().remove();
      $scope.list.splice( $.inArray( item, $scope.list ), 1 );
    });
  };
  
  $scope.editItem = function( item, event ) {
    if( !item.editing ) item.editing = true;
    else {
      $http({
        url: '/restaurants/' + item.id + '.json',
        method: 'PUT',
        params: { name: item.name, rating: item.rating, last_visit: item.last_visit }
      }).success( function( data ) {
        item.editing = false;
      });
    }
  };
  
  $scope.createItem = function( event ) {
    d = new Date();
    newGuy = { name: "New", rating: 0, last_visit: "2014-10-01" };
    
    $http({
      url: "/restaurants.json",
      method: "POST",
      params: newGuy
    }).success( function( data ) {
      $scope.list.push(data);
    });
  }
}]);