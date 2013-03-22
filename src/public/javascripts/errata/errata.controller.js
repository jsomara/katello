'use strict';

var Katello = angular.module('Katello', ['alchemy', 'alch-templates']);

Katello.config(['$httpProvider', function($httpProvider){
    $httpProvider.defaults.headers.common['X-CSRF-TOKEN'] = $('meta[name=csrf-token]').attr('content');
}]);

angular.module('Katello').factory('ErrataTable', ['$location', '$http', function($location, $http){
    var ErrataTable = {};

    ErrataTable.get = function(sort, callback){
        return $http.get('api/errata/', {
            params : {
                'organization_id' : 'ACME_Corporation',
                'search' : $location.search().search,
                'sort_by' : sort.by,
                'sort_order' : sort.order,
                'paged' : true
            }
        })
        .then(function(response){
            callback(ErrataTable.transform(response.data));
        });
    };

    ErrataTable.transform = function(data){
        var table_data = {};

        table_data.rows = [];
        angular.forEach(data.erratum,
            function(errata){
                var row = {
                    'row_id' : errata.id,
                    'show'  : true,
                    'cells': [{
                        display: errata.errata_id,
                        column_id: 'errata_id'
                    },{
                        display: errata.title,
                        column_id: 'title'
                    },{
                        display: errata.severity,
                        column_id: 'severity'
                    }]
                };
                table_data.rows.push(row);
            });

        return {
            data    : table_data,
            total   : data.total,
            subtotal: data.subtotal
        };
    };

    return ErrataTable;

}]);

angular.module('Katello').controller('ErrataController', ['$scope', 'ErrataTable', '$location', function($scope, ErrataTable, $location){
    var sort = { by: 'name', order: 'ASC' };

    $scope.table        = {};
    $scope.table.data   = {};
    $scope.table.start  = 0;
    $scope.table.offset = 0;
    $scope.table.total  = 0;
    $scope.table.model  = 'Errata';
    $scope.table.search_string = $location.search().search;

    $scope.table.data.columns = [{
            id: 'errata_id',
            display: 'Errata ID',
            show: true
        },{
            id: 'title',
            display: 'Title',
            show: true
        },{
            id: 'severity',
            display: 'Severity',
            show: true
        }];

    var fetch = function(callback){
        $scope.table.working = true;

        ErrataTable.get(sort, function(data){
            $scope.table.data.rows  = data.data.rows;
            $scope.table.total      = data.total;
            $scope.table.start      = data.data.rows.length;
            $scope.table.offset     = data.subtotal;

            if ( callback ){
                callback();
            }

            $scope.table.working    = false;
        });
    };

    $scope.table.sort = function(column){
        if (column.id === sort.by){
            sort.order = (sort.order === 'ASC') ? 'DESC' : 'ASC';
        } else {
            sort.order = 'ASC';
            sort.by = column.id;
        }

        angular.forEach($scope.table.data.columns, function(column){
            if( column.active ){
                column.active = false;
            }
        });

        column.active = true;

        fetch(function(){
            angular.forEach($scope.table.data.columns, function(column){
                if( column.active ){
                    column.active = false;
                }
            });

            column.active = true;
        });
    };

    $scope.table.search = function(search_term){
        $location.search('search', search_term);

        fetch();
    };

    fetch();

}]);

