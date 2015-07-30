require('file?name=/index.html!jade-env-html?{module:"app"}!./layout.jade')

require('ng-cache?!jade-env-html!./index.jade')

require('./app.less')
u = require('./utils')

app = angular.module('app', [
  'ngRoute'
  'ngAnimate'
])

app.run ($rootScope)->

app.config ($routeProvider) ->
  rp = $routeProvider
  rp.when '/',
    name: 'index'
    templateUrl: 'index.jade'
    controller: 'WelcomeCtrl'

shiftWeekDays = (weekDays, firstDayOfWeek)->
  weekDaysHead = weekDays.slice(firstDayOfWeek, weekDays.length)
  weekDaysHead.concat(weekDays.slice(0, firstDayOfWeek))

beginingOfDay = (date)->
  new Date(date.getFullYear(), date.getMonth(), date.getDate())

addDays = (date, days)->
  new Date(date.getFullYear(), date.getMonth(), date.getDate() + days)

addHours = (date, h)->
  new Date(date.getFullYear(), date.getMonth(), date.getDate(), date.getHours() + h)

datesIndex = (dates)->  
  res = {}
  for d in dates
    res[beginingOfDay(d).getTime()] = true
  res

app.factory 'Data', ($http)->
  freeDays: (from, to)->
    success: (cb)->
      data = for i in [0..10]
        addDays(from, i*2) 
      cb(data)
  freeTime: (date)->
    success: (cb)->
      data = for i in [0..10]
        addHours(date, i*2) 
      cb(data)
  makeAppointment: (appoint)->
    success: (cb)->
      cb(appoint)

app.controller 'WelcomeCtrl', ($scope, $locale, Data)->
  $scope.selectionMode = 'day'

  $scope.months = $locale.DATETIME_FORMATS.SHORTMONTH

  currentTime = new Date()
  $scope.currentDate = new Date(currentTime.getFullYear(), currentTime.getMonth(), currentTime.getDate())
  $scope.selectedYear = $scope.currentDate.getFullYear()
  $scope.selectedMonth = $scope.months[$scope.currentDate.getMonth()]
  $scope.monthGroups = ($scope.months.slice(i * 4, i * 4 + 4) for i in [0..2])

  setBuisyDays = (dates)->
    $scope.buisyDatesIdx = datesIndex(dates)

  monthChanged = ()->
    startDate= new Date($scope.selectedYear, $scope.months.indexOf($scope.selectedMonth),1)
    endDate = new Date(startDate.getTime() + 35*24*60*60*1000)
    $scope.times = null
    Data.freeDays(startDate, endDate).success (data)->
      data = data.map (x)-> new Date(x)
      setBuisyDays(data)

  $scope.selectDay = (day)->
    $scope.selectedDate = day
    $scope.selectionMode = 'time'
    Data.freeTime(day).success (data)->
      $scope.times = data

  $scope.unselectDay = ()->
    console.log('unselect')
    $scope.selectedDate = null
    $scope.selectionMode = 'day'

  $scope.selectTimeSlot = (tm)->
    $scope.selectionMode = 'form'
    $scope.selectedTimeSlot = tm

  $scope.unselectTimeSlot = (tm)->
    $scope.selectionMode = 'time'

  $scope.prevMonth = ->
    month = u.indexOf($scope.months, $scope.selectedMonth) - 1
    if month < 0
      month = $scope.months.length - 1
      $scope.selectedYear--
    $scope.selectedMonth = $scope.months[month]
    monthChanged()

  $scope.nextMonth = ->
    month = u.indexOf($scope.months, $scope.selectedMonth) + 1
    if month >= $scope.months.length
      month = 0
      $scope.selectedYear++
    $scope.selectedMonth = $scope.months[month]
    monthChanged()

  $scope.prevYear = ->
    $scope.selectedYear--
    monthChanged()

  $scope.nextYear = ->
    $scope.selectedYear++
    monthChanged()

  $scope.prevYearRange = ->
    rangeSize = $scope.years.length
    $scope.years = [$scope.years[0] - rangeSize..$scope.years[$scope.years.length - 1] - rangeSize]

  $scope.nextYearRange = ->
    rangeSize = $scope.years.length
    $scope.years = [$scope.years[0] + rangeSize..$scope.years[$scope.years.length - 1] + rangeSize]

  $scope.switchSelectionMode = ->
    $scope.selectionMode = switch $scope.selectionMode
      when 'day' then 'month'
      when 'month' then 'year'
      else
        'day'

  $scope.isDayInSelectedMonth = (day)->
    day.getFullYear() == $scope.selectedYear && $scope.months[day.getMonth()] == $scope.selectedMonth

  $scope.isCurrentDate = (day)->
    day.getTime() == $scope.currentDate?.getTime()

  isBusy = (day)->
    $scope.buisyDatesIdx[beginingOfDay(day).getTime()]

  $scope.isBusy = isBusy

  $scope.isSelectedDate = (day)->
    day.getTime() == $scope.selectedDate?.getTime()

  addDays = (date, days)->
    new Date(date.getFullYear(), date.getMonth(), date.getDate() + days)

  updateSelectionRanges = ->
    monthIndex = u.indexOf($scope.months, $scope.selectedMonth)
    firstDayOfMonth = new Date($scope.selectedYear, monthIndex)
    dayOffset = $scope.firstDayOfWeek - firstDayOfMonth.getDay()
    dayOffset -= 7 if dayOffset > 0
    firstDayOfWeek = addDays(firstDayOfMonth, dayOffset)
    $scope.weeks = ((addDays(firstDayOfWeek, 7 * week + day) for day in [0..6]) for week in [0..5])
    $scope.years = [$scope.selectedYear - 5..$scope.selectedYear + 6]

  $scope.$watch 'selectedMonth', updateSelectionRanges
  $scope.$watch 'selectedYear', updateSelectionRanges
  $scope.$watch 'years', ->
    $scope.yearGroups = ($scope.years.slice(i * 4, i * 4 + 4) for i in [0..3])

  $scope.firstDayOfWeek = 0
  $scope.weekDays = shiftWeekDays($locale.DATETIME_FORMATS.SHORTDAY, $scope.firstDayOfWeek)

  $scope.isSameYear = ->
    u.parseDate($scope.selectedDate)?.getFullYear() == $scope.selectedYear


  $scope.selectMonth = (monthName)->
    $scope.selectionMode = 'day'
    $scope.selectedDate = undefined
    $scope.selectedMonth = monthName
    monthChanged()

  $scope.selectYear = (year)->
    $scope.selectionMode = 'month'
    $scope.selectedDate = undefined
    $scope.selectedYear = year
    monthChanged()


  $scope.makeAppointment = ()->
    Data.makeAppointment($scope.appoint).success ()->
      $scope.selectedTimeSlot = null

  $scope.classForDay = (day)->
    res = []
    res.push 'day-in-selected-month' if $scope.isDayInSelectedMonth(day)
    res.push 'day-busy' if $scope.isBusy(day)
    res.push 'day-current' if $scope.isCurrentDate(day)
    res.push 'active bg-info' if $scope.isSelectedDate(day)
    res.join(" ")

  monthChanged()
