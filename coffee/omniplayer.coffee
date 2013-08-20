class @OmniPlayer
  type: undefined
  videoId: undefined
  height: undefined
  width: undefined
  elementId: undefined
  startSeconds: undefined
  endSeconds: undefined
  internal: undefined
  @loaded:
    YT: false
    TEST: false
    JW: true

  constructor: (obj) ->
    @elementId = obj.elementId
    @videoId = obj.videoId
    @type = obj.type
    @height = obj.height
    @width = obj.width
    @startSeconds = obj.startSeconds
    @endSeconds = obj.endSeconds

    # set default height and width
    @height = $("##{@elementId}").height() if !@height?
    @width = $("##{@elementId}").width() if !@width?

    console.log @height
    console.log @width

    this[@type].createPlayer.apply(this, [obj])

  getDuration: ->
    return 0

  getCurrentTime: ->
    return 0    

  stopVideo: ->
    return 0

  cueVideoById: (options) ->
    return 0

  loadVideoById: (options) -> 
    return 0

  remove: ->
    el = $("##{@elementId}")
    new_el = el.after("<div></div>").next()

    el.remove()
    new_el.attr
      id: "#{@elementId}"
    return this

  JW:
    build: (obj) ->

      @internal = jwplayer(@elementId).setup
        file: "http://www.youtube.com/watch?v=#{@videoId}"
        image: "http://img.youtube.com/vi/#{@videoId}/0.jpg"
        height: @height
        width: @width

      that = this
      @internal.seek(@startSeconds)

      @internal.onTime (e) ->
        if e.position > that.endSeconds
          that.stopVideo()

      @getDuration = ->
        @internal.getDuration()

      @getCurrentTime = ->
        @internal.getPosition()

      @stopVideo = ->
        @internal.stop()

      @cueVideoById = (options) ->
        @internal.remove() if @internal?
        @endSeconds = options.endSeconds
        @startSeconds = options.startSeconds
        @videoId = options.videoId

        @internal = jwplayer(@elementId).setup
          file: "http://www.youtube.com/watch?v=#{@videoId}"
          image: "http://img.youtube.com/vi/#{@videoId}/0.jpg"
          height: @height
          width: @width

        that = this
        @internal.seek(@startSeconds)

        @internal.onTime (e) ->
          if e.position > that.endSeconds
            that.stopVideo()


      @loadVideoById = (options) ->
        # TODO

      @remove = ->
        @internal.remove()

    createPlayer: (obj) ->
      jwplayer.key = 'qQr9/RXBwD+he3rSeg0L9C0Z7rjRuWOH2CISkQ=='
      OmniPlayer.loaded.JW = true
      @JW.build.apply this, [obj]

  YT: 
    setup: ->
      tag = document.createElement("script")
      tag.src = "https://www.youtube.com/iframe_api"
      firstScriptTag = document.getElementsByTagName("script")[0]
      firstScriptTag.parentNode.insertBefore tag, firstScriptTag

    build: ->
      @internal = new window.YT.Player(@elementId,
        videoId: @videoId
        height: @height
        width: @width
        events: {
          onReady: (event) =>
            if @startSeconds || @endSeconds
              event.target.cueVideoById
                videoId: @videoId
                startSeconds: @startSeconds
                endSeconds: @endSeconds
                suggestedQuality: "large"
            else
              @startSeconds = 0 
              @endSeconds = @endSeconds or @getDuration()
        }
      )

      # Encapsulate YouTube API functions
      @getDuration = ->
        @internal.getDuration()

      @getCurrentTime = ->
        @internal.getCurrentTime()

      @stopVideo = ->
        @internal.stopVideo()

      @cueVideoById = (options) ->
        @internal.cueVideoById(options)

      @loadVideoById = (options) ->
        @internal.loadVideoById(options)

    createPlayer: (obj)->

      that = this

      if OmniPlayer.loaded.YT
        @YT.build.apply this
      else
        window.onYouTubeIframeAPIReady = () ->
          OmniPlayer.loaded.YT = true
          that.YT.build.apply that

        @YT.setup()

  TEST:
    createPlayer: (obj)->
      OmniPlayer.loaded.TEST = true

