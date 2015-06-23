###
@ngdoc factory
@name TalkFactory

@object

@description
  The TalkFactory provides functionallity to 
  create/retrieve/delete talks (audio files)
  from the native persistent filesystem (storage).

  **Note:** 
    Using the following cordova plugins:
    - cordova.file

@example
  talk =  TalkFactory.createNew()

  talks = TalkFactory.getAllTalks()

  talk = TalkFactory.getTalkById id

  TalkFactory.deleteTalk id
###
angular.module("voicerepublic")

.factory 'TalkFactory', ($window, $localstorage, $cordovaFile, $log) ->
  new class TalkFactory
    constructor: () ->
      #constructor

    createNew: () ->
      date = new $window.Date()
      prefix = $window.cordova?.file.dataDirectory or "documents://"
      sufix = "talk_on_" + date.toDateString().replace /\s/g, ''
      sufix += ".wav"

      talkId = $localstorage.get "idCounter", 0
      $localstorage.set "idCounter", ++talkId

      talk =
        id : talkId
        src : prefix + sufix
        filename : sufix
        isUploaded : false

      talks = $localstorage.getObject "talks"

      talks.push talk

      $localstorage.setObject "talks", talks

      #expose talk
      talk

    getAllTalks: () ->
      talks = $localstorage.getObject "talks"

      #expose talks
      talks

    getTalkById: (id) ->
      talks = $localstorage.getObject "talks"

      talk = talk for talk in talks when talk.id is id

      #expose talk which has the id
      talk

    deleteTalkById: (id) ->
      talk = @getTalkById id
      deleted = false
      path = $window.cordova?.file.dataDirectory or "documents://"
      $cordovaFile.removeFile(path, talk.filename)
      .then ((success) ->
        deleted = true
      (error) ->
        deleted = false
        $log.debug error
      )

      talks = @getAllTalks()
      pos = 0
      pos++ until talk.id > id
      talks = talks.splice pos, 1

      $localstorage.setObject "talks", talks

      #expose status of delete
      deleted