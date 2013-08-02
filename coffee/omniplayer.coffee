class @OmniPlayer
  type: undefined
  videoId: undefined
  height: undefined
  width: undefined
  elementId: undefined
  startSeconds: undefined
  endSeconds: undefined
  internal: undefined

  constructor: (obj) ->
    @elementId = obj.elementId
    @videoId = obj.videoId
    @type = obj.type
    @height = obj.height
    @width = obj.width
    @startSeconds = obj.startSeconds
    @endSeconds = obj.endSeconds

    this[@type]()

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

  YT: ->
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
    @getDuration = () ->
      @internal.getDuration()

    @getCurrentTime = () ->
      @internal.getCurrentTime()

    @stopVideo = () ->
      @internal.stopVideo()

    @cueVideoById = (options) ->
      @internal.cueVideoById.apply(this, options)

    @loadVideoById = (options) ->
      @internal.loadVideoById.apply(this, options)

    console.log this

  TEST: ->

