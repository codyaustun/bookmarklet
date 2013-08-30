class @VideoClipper

  # Instance Variables
  startTime: ""
  endTime: ""
  caretPos: 0
  answerClass: ""
  videoId: "" # video id
  videoType: "" # YT, TEST
  generate: true
  buttonId: ""
  textareaId: ""
  clips: []
  questionBox = null # the question box as a jQuery object
  snippetButton = null # the button to open snippet box as a jQuery object

  # Class Variables 
  @reel: 'http://web.mit.edu/colemanc/www/bookmarklet/images/film3Small.png'
  @player: false
  @playerV: false
  @answerClass: "bookMarklet-answer"
  @generateHtml: true
  @clipper: ""
  @clippers: []
  @callback = false
  @prepared:
    snippet: false

  constructor: (obj)->
    obj = obj or {}
    @textareaId = obj.textareaId
    @videoId = obj.videoId
    @videoType = obj.videoType

    @mediaContentUrl = obj.mediaContentUrl
    @thumbnailUrl = obj.thumbnailUrl

    @reel = obj.reel or VideoClipper.reel
    @answerClass = obj.answerClass or VideoClipper.answerClass
    @buttonId = obj.buttonId or "bl-"+@videoType + @videoId

    # The variables below can be false, so or can't be used
    @generate = if obj.generate != undefined then obj.generate else VideoClipper.generateHtml

    # This condition is mainly used for testing
    @setup() if @generate

    VideoClipper.clippers = VideoClipper.clippers.concat(this)

  # TODO: Add tests
  destroy: ->
    @questionBox.remove() if @questionBox?
    @snippetButton.remove() if @snippetButton?

  generateQuestionBox: () =>
    element = $("#"+@textareaId)
    w = element.width()
    h = element.height()
    content = element.val()

    # Newly created div for answer input
    @questionBox = element.after("<div></div>").css("display", "none").next()

    @questionBox.attr(contenteditable: "true").addClass(@answerClass).css
      width: w
      height: h

    dataString = VideoClipper.generateBLDataString "generate", this

    blDataEncoded = encodeURI(dataString)

    if $('#'+@buttonId).length > 0
      $('#'+@buttonId).attr
        "data-bl": blDataEncoded
        rel: "blModal"
    else
      @questionBox.after("<input type='button' value='Snippet'>").next().attr
        "data-bl": blDataEncoded
        rel: "blModal"
        id: @buttonId

    that = this

    @snippetButton = $('#'+@buttonId)

    @snippetButton.click ->
      VideoClipper.modal.open this, that
      return

  getCaretPosition: (editableDiv) =>
    @caretPos = 0
    containerEl = null
    sel = undefined
    range = undefined
    if window.getSelection()?
      sel = window.getSelection()
      if sel.rangeCount
        range = sel.getRangeAt(0)
        if range.commonAncestorContainer.parentNode is editableDiv
          temp1 = range.endContainer.data
          temp2 = range.commonAncestorContainer.parentNode.innerHTML.replace(/&nbsp;/g, String.fromCharCode(160))
          temp2 = VideoClipper.stripHTML(temp2)
          @caretPos = range.endOffset + temp2.split(temp1)[0].length
    @caretPos

  setup: =>
    @generateQuestionBox()
    VideoClipper.generate(this)

  update: (newTag) =>
    $(".bl-URL").text newTag
    currContent = @questionBox.contents()
    newContent = []
    beginPos = 0
    endPos = 0
    if currContent.length is 0
      newContent = newTag
    else
      currContent.each (i, e) =>
        if ((e.nodeType is 3) or (e.nodeType is 1)) and (endPos < @caretPos)
          eString = ""
          if e.nodeType is 3
            eString = e.data
          else
            eString = e.text
          beginPos = endPos
          endPos = endPos + eString.length

          if endPos >= @caretPos
            front = eString.substring(0, @caretPos - beginPos)
            back = eString.substring(@caretPos - beginPos, eString.length)
            newContent = newContent.concat(front)
            newContent = newContent.concat(newTag)
            newContent = newContent.concat(back)
            return
          else
            newContent = newContent.concat(e)
            return
        else
          newContent = newContent.concat(e)
          return

    @questionBox.text ""
    $(newContent).each (i, e) =>
      @questionBox.append e

    that = this

    @questionBox.find('[rel*=blModal]').each (index, element) ->
      data = VideoClipper.getBLData $(element)

      startTime = VideoClipper.secondsToTime(data.startSeconds)
      endTime = VideoClipper.secondsToTime(data.endSeconds)

      $(element).click ->
        VideoClipper.modal.open this, that

      $(element).qtip
        style:
          classes: 'qtip-rounded qtip-dark'
        content:
          text: "Start: #{startTime} - End: #{endTime}"

    newVal = @questionBox.html()
    @questionBox.prev().val newVal

  @checkErrors: =>
    startTime = parseFloat(@getStartTime())
    endTime = parseFloat(@getEndTime())
    if (startTime < endTime or isNaN(endTime)) and (not isNaN(startTime))
      $("input[name='bl-start']").removeClass "bl-incorrect"
      $("input[name='bl-end']").removeClass "bl-incorrect"
      true
    else
      $("input[name='bl-start']").addClass "bl-incorrect"
      $("input[name='bl-end']").addClass "bl-incorrect"
      false

  @cleanUp: =>
    $('#bl').remove()
    $('#bl-vid').remove()
    $("#bookMarklet-overlay").remove()
    @prepared.snippet = false
    for clipper in @clippers
      clipper.destroy()
    @clippers = []
    return this

  @clearInputs: =>
    @setStartTime ""
    @setEndTime ""
    $("input[name='bl-start']").removeClass "bl-incorrect"
    $("input[name='bl-end']").removeClass "bl-incorrect"
    $(".bl-URL").text "Generated URL goes here"

    return this

  @generate: (clipper)->
    @generateSnippetBox(clipper) if clipper?
    @generateVideoBox()
    @generateOverlay()

    that = this

    if !clipper?
      $('[rel*=blModal]').each (index, element) ->
        data = VideoClipper.getBLData $(element)

        startTime = VideoClipper.secondsToTime(data.start)
        endTime = VideoClipper.secondsToTime(data.end)

        $(element).click ->
          that.modal.open this

        $(element).qtip
          style:
            classes: 'qtip-rounded qtip-dark'
          content:
            text: "Start: #{startTime} - End: #{endTime}"

    return that

  @generateBLDataString: (type, clipper) =>
    dataString = ""

    if type is "generate"
      dataString = """
        {
          \"elementId\": \"bl-player\",
          \"videoId\": \"#{clipper.videoId}\",
          \"videoType\": \"#{clipper.videoType}\",
          \"mediaContentUrl\": \"#{clipper.mediaContentUrl}\",
          \"thumbnailUrl\": \"#{clipper.thumbnailUrl}\",
          \"modal\": {
            \"Id\": \"bl\"
          }
        }
      """
    else if type is "show"
      dataString = """
      {
          \"elementId\": \"bl-playerV\",
          \"videoId\": \"#{clipper.videoId}\",
          \"videoType\": \"#{clipper.videoType}\",
          \"startSeconds\": \"#{clipper.startTime}\",
          \"endSeconds\": \"#{clipper.endTime}\",
          \"mediaContentUrl\": \"#{clipper.mediaContentUrl}\",
          \"thumbnailUrl\": \"#{clipper.thumbnailUrl}\",
          \"modal\": {
            \"Id\": \"bl-vid\"
          }
        }
      """    
    return dataString

  @generateOverlay: =>
    $("<div id='bookMarklet-overlay'></div>").appendTo "body"  if $("#bookMarklet-overlay").length is 0
    $("#bookMarklet-overlay").click =>
      @modal.close()

    return this

  @generateSnippetBox: (clipper) =>
    $("""
      <div id='bl'>
        <div class='bl-top'>
          <div class='bl-vid'>
            <div id='bl-player'></div>
          </div>
          <div class='bl-controls'>
            <div class='bl-title'>
              <h1>Create a Clip</h1>
            </div>
            <div class='bl-instructions'>
              Click \"Start Time\" and \"End Time\" buttons,or by type in the time in the text boxes.
            </div>
            <table class='bl-input'>
              <tr>
                <td>
                  <input class='bl-button bl-start' type='button' value='Start Time'>
                </td>
                <td>
                </td>
                <td>
                  <input class='bl-button bl-end' type='button' value='End Time'>
                </td>
              </tr>
              <tr>
                <td>
                  <input class='bl-data' type='text' name='bl-start'>
                </td>
                <td>
                  -
                </td>
                <td>
                  <input class='bl-data' type='text' name='bl-end'>
                </td>
              </tr>
              <tr>
                <td>
                  <input class='bl-button bl-done' type='button' value='Done'>
                </td>
                <td>
                </td>
                <td>
                  <input class='bl-button bl-reset' type='button' value='Reset'>
                </td>
              </tr>
            </table>
            <textarea class='bl-URL'>
              Generated URL goes here
            </textarea>
          </div>
        </div>
        <div class='bl-bottom'>
          Source URL:<a class='bl-srcURL'></a>
        </div>
      </div>
      """).appendTo("body") if $("#bl").length is 0

    that = this
    
    clipper.questionBox.click (e) ->
      clipper.caretPos = clipper.getCaretPosition(this)
      return

    clipper.questionBox.keyup (e) ->
      clipper.caretPos = clipper.getCaretPosition(this)
      divText = $(this).html()
      $(this).prev().val divText
      return

    if !@prepared.snippet
      $(".bl-start").click (e) =>
        currTime = @player.getCurrentTime()
        that.setStartTime currTime
        that.checkErrors()
        return

      $(".bl-end").click (e) =>
        currTime = @player.getCurrentTime()
        that.setEndTime currTime
        that.checkErrors()
        return

      $(".bl-done").click (e) =>
        that.modal.close()
        that.clipper.update that.generateTag(that.clipper)
        return

      $(".bl-reset").click (e) =>
        VideoClipper.clearInputs()
        @player.cueVideoById 
          videoId: that.clipper.videoId
          startSeconds: 0
          suggestedQuality: "large"
        return

      @prepared.snippet = true

    return this

  @generateTag: (clipper) =>

    # Get in and out points
    clipper.startTime = @getStartTime()
    clipper.endTime = @getEndTime()

    # Check for errors and proceed
    if VideoClipper.checkErrors()

      # Default for endTime is an empty string
      clipper.endTime = @player.getDuration() if isNaN parseFloat clipper.endTime 

      # Generate an anchor tag with encoded JSON as text
      newTag = ""
      dataString = @generateBLDataString "show", clipper
      # Logging for edX
      # Logger.log('video_clip', $.parseJSON(dataString));
      blDataEncoded = encodeURI(dataString)
      newTag = $("<a rel='blModal' href='#bl-vid' class='bl'>"+ blDataEncoded+ "</a>").css
        'background-image': clipper.reel

      that = this

      clipper.clips = clipper.clips.concat(newTag)

      return newTag
    else
      return ""

  @generateVideoBox: =>
    $("""
      <div id='bl-vid'>
        <div class='bl-video-wrap'>
          <div id='bl-playerV'></div>
        </div>
      </div>
      """).appendTo("body") if $("#bl-vid").length is 0

    return this

  @getBLData: (el) =>
    blData = undefined
    if typeof ($(el).attr("data-bl")) isnt "undefined"
      blData = $.parseJSON(decodeURI($(el).attr("data-bl")))
    else blData = $.parseJSON(decodeURI($(el).text()))  if typeof ($(el).text()) isnt "undefined"
    return blData

  @modal:
    Id: "" # bl or bl-vid
    
    close: (modalId) =>
      modalId = modalId or @modal.Id
      $("#bookMarklet-overlay").fadeOut 200
      $("##{modalId}").css display: "none"
      if modalId is "bl"
        VideoClipper.player.stopVideo()
      else 
        VideoClipper.playerV.stopVideo()  if modalId is "bl-vid"
      return VideoClipper  

    open: (element, clipper) =>
      that = this
      @modal.close()
      blData = @getBLData(element)
      @clipper = clipper

      if blData.modal.Id is "bl"
        clipper.videoId = blData.videoId
        clipper.videoType = blData.videoType

        url = ""
        url = "http://www.youtube.com/embed/" + clipper.videoId  if clipper.videoType is "YT"
        $(".bl-srcURL").attr "href", url
        $(".bl-srcURL").text url

        @clearInputs()
        if @player is false || @player.videoType != blData.videoType || @playerV.videoId == blData.videoId
          @player.remove() if @player? && @player
          @player = new OmniPlayer blData
        else
          @player.cueVideoById(blData)
      else
        # OPTIMIZE: This works, 
        #   but it would be nice if it didn't need to delete the video
        if @playerV is false || @playerV.videoType != blData.videoType || @playerV.videoId == blData.videoId
          @playerV.remove() if @playerV? && @playerV
          @playerV = new OmniPlayer blData
        else
          @playerV.cueVideoById blData

      @modal.Id = blData.modal.Id

      modalWidth = $("##{@modal.Id}").outerWidth()
      $("#bookMarklet-overlay").css
        display: "block"
        opacity: 0

      $("#bookMarklet-overlay").fadeTo 200, 0.5
      $("##{@modal.Id}").css
        display: "block"
        position: "fixed"
        opacity: 0
        "z-index": 11000
        left: 50 + "%"
        "margin-left": -(modalWidth / 2) + "px"
        top: "100px"

      $("##{@modal.Id}").fadeTo 200, 1

      return this

  @stripHTML: (html) ->
    tmp = document.createElement("DIV")
    tmp.innerHTML = html
    tmp.textContent or tmp.innerText

  @secondsToTime: (seconds) ->
    if seconds == ""
      return seconds
    else
      seconds = parseFloat(seconds).toFixed(2)

      hours = parseInt(seconds / 3600)
      minutes = parseInt(seconds / 60) % 60
      seconds = parseFloat(seconds % 60).toFixed(2)
      result = ""

      if hours > 0
        minutes = "0#{minutes}" if (minutes / 10) < 1
        seconds = "0#{seconds}" if (seconds / 10) < 1
        result = "#{hours}:#{minutes}:#{seconds}"
      else if minutes > 0
        seconds = "0#{seconds}" if (seconds / 10) < 1
        result = "#{minutes}:#{seconds}"
      else
        result = "#{seconds}"

      return result

  @timeToSeconds: (time) ->
    amounts = time.split(':')
    seconds = 0

    len = amounts.length
    for amount, index in amounts
      seconds += parseFloat(amount)*Math.pow(60, len-(index+1))

    return seconds.toFixed(2)

  @getEndTime: ->
    val = $("input[name='bl-end']").val() 
    return @timeToSeconds(val)

  @getStartTime: ->
    val = $("input[name='bl-start']").val()
    return @timeToSeconds(val)

  @setEndTime: (val) ->
    val = @secondsToTime val
    $("input[name='bl-end']").val val
    return val

  @setStartTime: (val) ->
    val = @secondsToTime val
    $("input[name='bl-start']").val val
    return val

# TODO: Add Tests
coeVideoId = $('#combined-open-ended').data('videoId')

if coeVideoId? && coeVideoId != ""
  textarea = $('#combined-open-ended').find('textarea')
  textarea.attr('id','video-clipper')

  new VideoClipper
    textareaId: "video-clipper"
    videoType: "YT"
    videoId: coeVideoId

VideoClipper.generate()
if window.onVideoClipperReady?
  VideoClipper.callback = true
  window.onVideoClipperReady()