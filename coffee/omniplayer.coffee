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
      console.log @elementId
      jwplayer(@elementId).setup
        file: "http://www.youtube.com/watch?v=ac7KhViaVqc"
        image: 'http://rack.1.mshcdn.com/media/ZgkyMDEyLzEyLzA0Lzg1L2hhcHB5NXRoYmlyLmJLYy5qcGcKcAl0aHVtYgk5NTB4NTM0IwplCWpwZw/eb8329a5/d20/happy-5th-birthday-youtube--501ecffedf.jpg'
        # height: @height
        # width: @width

      @getDuration = ->
        jwplayer(@elementId).getDuration()

      @getCurrentTime = ->
        jwplay(@elementId).getPosition()

      @stopVideo = ->
        jwplayer(@elementId).stop()

      @cueVideoById = (options) ->
        # TODO

      @loadVideoById = (options) ->
        # TODO

      @remove = ->
        jwplayer(@elementId).remoe()

    createPlayer: (obj) ->
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

