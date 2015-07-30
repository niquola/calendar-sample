require('file?name=/index.html!jade-env-html?{module:"app"}!./layout.jade')

#require('ng-cache?!jade-env-html!../shared/404.jade')

require('./app.less')

console.log('here')

app = angular.module('app', [
  'ngCookies'
  'ngRoute'
  'ngAnimate'
  'ngSanitize'
])

app.run ($rootScope)->

app.config ($routeProvider) ->
  rp = $routeProvider
  rp.when '/',
    name: 'index'
    templateUrl: 'index.jade'
    controller: 'WelcomeCtrl'


app.controller 'WelcomeCtrl', ($scope)->
  console.log 'here'


