log 'setup angular app (run)'

app = angular.module(GLOBALS.ANGULAR_APP_NAME)

# Run the app only after cordova has been initialized
# (this is why we don't include ng-app in the index.jade)
ionic.Platform.ready ->
  console.log 'ionic.Platform is ready! Running `angular.bootstrap()`...' unless GLOBALS.ENV == "test"
  angular.bootstrap document, [GLOBALS.ANGULAR_APP_NAME]

app.run ($rootScope, $state, $log, $localstorage, $timeout, $ionicPlatform, $ionicLoading, User, $cordovaToast, $cordovaSplashscreen) ->

  $ionicPlatform.ready ->
    window.cordova?.plugins.Keyboard?.hideKeyboardAccessoryBar()
    window.StatusBar?.styleDefault()
    window.ionic.Platform.isFullScreen = true

    #handle authenticity from state to state
    $rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) ->
      $ionicLoading.show template: 'Loading...'
      if toState.isLoginState and User.signedIn()
        $state.transitionTo 'tab.record'
        event.preventDefault()
      else if toState.authenticate and !User.signedIn()
        # User isn’t authenticated
        $state.transitionTo 'login'
        event.preventDefault()

    $rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
      $ionicLoading.hide()

  $log.debug "Ionic app \"#{GLOBALS.ANGULAR_APP_NAME}\" has just started (app.run) in env #{GLOBALS.ENV}!" unless GLOBALS.ENV == "test"

  if GLOBALS.ENV == 'development'
    # play assets/hallo-hallo-hallo.mp3

  # Finally, let's show the app, by hiding the splashscreen
  # (it should be visible up until this moment)
  $timeout ->
    $cordovaSplashscreen.hide()
  , 1000

  # greet the user if we know him or her
  if User.signedIn()
    $timeout ->
      $cordovaToast.showLongBottom "Welcome Back, #{User.attributes.firstname}!"
    , 1337
