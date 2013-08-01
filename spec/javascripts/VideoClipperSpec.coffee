describe "VideoClipper", ->
  clippy = undefined

  it "should have VideoClipper class", ->
    clippy = new VideoClipper
    expect(clippy).toBeDefined()

  # Not sure if a constructor actually makes sense yet
  # xdescribe "when constructing", ->
  #   beforeEach ->
  #     clippy = new VideoClipper

  #   it "should give reel a default but allow it to be set", ->
  #     expect(clippy.reel).not.toBeFalsy

  #     reelString = "http://web.mit.edu/colemanc/www/bookmarklet/images/film2Small.png"
  #     clippy2 = new VideoClipper
  #       reel: reelString

  #     expect(clippy2.reel).toEqual(reelString)

  #   it "should give answerClass a default but allow it to be set", ->
  #     expect(clippy.answer_class).not.toBeFalsy

  #     answer_class = "VC-answer"
  #     clippy2 = new VideoClipper
  #       answerClass: answer_class 

  #     expect(clippy2.answer_class).toEqual(answer_class)

  #   it "should require vid to be set", ->
  #     vid = "d_z2CA-o13U"
  #     clippy2 = new VideoClipper
  #       videoID: vid 

  #     expect(clippy2.vid).toEqual(vid)

  #     # Should throw error
  #     expect('pending').toEqual('completed')

  #   it "should require video_type to be set", ->
  #     video_type = "yt"
  #     clippy2 = new VideoClipper
  #       videoType: video_type

  #     expect(clippy2.video_type).toEqual(video_type)
  #     # Should throw error
  #     expect('pending').toEqual('completed')

  #   it "should require textareaid to be set", ->
  #     expect('pending').toEqual('completed')

  #   it "should allow button to be turned off", ->
  #     expect('pending').toEqual('completed')

  describe 'when generating the output box', ->
    beforeEach ->
      VideoClipper.clean_up()
      loadFixtures('question.html')
      VideoClipper.setup_yt()
      textareaid = 'bl-text'
      @selector = '#'+textareaid

      clippy = new VideoClipper
        textareaid: textareaid
        videoID: '8f7wj_RcqYk'
        videoType: 'yt'
        generate: false

    it 'should only have one element specified by textareaid', ->
      expect($(@selector).length).toBe(1)
        
    it 'should get height of the element with textareaid', ->
      heightSpy = spyOn($.fn, 'height')
      spyOn(clippy, 'generateOutputBox').andCallThrough()
      clippy.generateOutputBox()
      expect(clippy.generateOutputBox).toHaveBeenCalled()
      expect($.fn.height).toHaveBeenCalled()
      expect(heightSpy.mostRecentCall.object.selector).toEqual(@selector)

    it 'should get width of the element with textareaid', ->
      widthSpy = spyOn($.fn, 'width')
      clippy.generateOutputBox()
      expect($.fn.width).toHaveBeenCalled()
      expect(widthSpy.mostRecentCall.object.selector).toEqual @selector

    it 'should get the value of the element with textareaid', ->
      valSpy = spyOn $.fn, 'val'
      clippy.generateOutputBox()
      expect($.fn.val).toHaveBeenCalled()
      expect(valSpy.mostRecentCall.object.selector).toEqual @selector

    it 'should insert of an answer_class div after the textarea', ->
      clippy.generateOutputBox()
      textarea = $(@selector)
      expect(textarea.next()).toBe 'div'
      expect(textarea.next()).toHaveClass clippy.answer_class

    it 'should make the divcontenteditable', ->
      clippy.generateOutputBox()
      textarea = $(@selector)
      expect(textarea.next()).toHaveAttr 'contenteditable', 'true'

    it 'should make the div have the same height and width as the textarea', ->
      clippy.generateOutputBox()
      textarea = $(@selector)
      div = textarea.next()
      expect(div.height()).toEqual textarea.height()
      expect(div.width()).toEqual textarea.width()

    it 'should generate a bl data string', ->
      spyOn(clippy, 'generateBLDataString')
      clippy.generateOutputBox()
      expect(clippy.generateBLDataString).toHaveBeenCalledWith
        type: 'generate'
        vid: clippy.vid
        vtype: clippy.video_type

    describe 'without a buttonid specified', ->
      it 'should create a button after the outputbox div', ->
        clippy.generateOutputBox()
        div = $(@selector).next()
        expect(div.next()).toBe 'input[type=button]'

      it "should set the rel attribute of the button to 'blModal'", ->
        clippy.generateOutputBox()
        button = $(@selector).next().next()
        expect(button).toHaveAttr 'rel', 'blModal'

      it 'should store the encoded BLDataString in the bl-data attribute', ->
        clippy.generateOutputBox()
        button = $(@selector).next().next()

        blData = clippy.generateBLDataString
          type: 'generate'
          vid: clippy.vid
          vtype: clippy.video_type
        encoded = encodeURI(blData)
        expect(button).toHaveAttr 'data-bl', encoded

    describe 'with a buttonid specified', ->
      beforeEach ->
        @testid = "button-test"
        textareaid = 'bl-text'

        clippy = new VideoClipper
          textareaid: textareaid
          videoID: '8f7wj_RcqYk'
          videoType: 'yt'
          buttonid: @testid
          generate: false

      it "should set the rel attribute of the button to 'blModal'", ->
        clippy.generateOutputBox()
        button = $('#'+@testid)
        expect(button).toHaveAttr 'rel', 'blModal'

      it 'should store the encoded BLDataString in the bl-data attribute', ->
        clippy.generateOutputBox()
        button = $('#'+@testid)

        blData = clippy.generateBLDataString
          type: 'generate'
          vid: clippy.vid
          vtype: clippy.video_type
        encoded = encodeURI(blData)
        expect(button).toHaveAttr 'data-bl', encoded


  # xdescribe 'when generating an overlay' ->


  describe "when setting up", ->
    beforeEach ->
      VideoClipper.clean_up()
      loadFixtures('question.html')
      VideoClipper.setup_yt()

      clippy = new VideoClipper
        textareaid: 'bl-text'
        videoID: '8f7wj_RcqYk'
        videoType: 'yt'
        generate: false

    it "should generate a video box if it doesnt't exist", ->
      expect($('#bl-vid').length).toBe(0)
      spyOn(clippy, 'generateVideoBox')
      clippy.setup()
      expect(clippy.generateVideoBox).toHaveBeenCalled()

    it "should generate a snippet box if it doesn't exist", ->
      expect($('#bl').length).toBe(0)
      spyOn(clippy, 'generateSnippetBox')
      clippy.setup()
      expect(clippy.generateSnippetBox).toHaveBeenCalled()

    it "should generate the output box", ->
      spyOn(clippy, 'generateOutputBox')
      clippy.setup()
      expect(clippy.generateOutputBox).toHaveBeenCalled()

    it "should generate the video clipper overlay it it doesn't exist", ->
      expect($('#bookmarklet-overlay').length).toBe(0)
      spyOn(clippy, 'generateOverlay')
      clippy.setup()
      expect(clippy.generateOverlay).toHaveBeenCalled()

    describe 'with a valid output box', ->
      beforeEach ->
        clippy.setup()

      it 'should make the output box respond to clicks', ->
        expect($("."+clippy.answer_class)).toHandle('click')

      it 'should make the output box respond to keyups', ->
        expect($("."+clippy.answer_class)).toHandle('keyup')

    describe "with a valid snippet box", ->
      beforeEach ->
        clippy.setup()

      it "should make the start button respond to clicks", ->
        expect($('.bl-start')).toHandle("click")

      it "should make the end button respond to clicks", ->
        expect($('.bl-end')).toHandle("click")

      it "should make the reset button respond to clicks", ->
        expect($(".bl-reset")).toHandle("click")

      it "should make the done button respond to clicks", ->
        expect($('.bl-done')).toHandle("click")

  # describe "when closing a modal window", ->

  #   it "should hide overlay", ->
  #     expect('pending').toEqual('completed')

  #   it "should stop the video player", ->
  #     expect('pending').toEqual('completed')

  #   it "should hide the modal window", ->
  #     expect('pending').toEqual('completed')

  # describe "when opening a modal window", ->

  #   it "should get the data from the element", ->
  #     expect('pending').toEqual('completed')

  #   it "should determine which modal window to open", ->
  #     expect('pending').toEqual('completed')

  #   describe "with a snippet box", ->
  #     it "should get video type and id", ->
  #       expect('pending').toEqual('completed')

  #     it "should clear inputs", ->
  #       expect('pending').toEqual('completed')

  #     it "should create a video player if it doesn't exist", ->
  #       expect('pending').toEqual('completed')

  #     it "should show snippet box", ->
  #       expect('pending').toEqual('completed')

  #     it "should show overlay", ->
  #       expect('pending').toEqual('completed')

  #   describe "with a video box", ->

  #     it "should get video type, id, start time and end time", ->
  #       expect('pending').toEqual('completed')

  #     it "should create a video player if it doesn't exist", ->
  #       expect('pending').toEqual('completed')

  #     it "should show video box", ->
  #       expect('pending').toEqual('completed')

  #     it "should show overlay", ->
  #       expect('pending').toEqual('completed')

  # describe "when checking for errors", ->
  #   it "should parse floats from the input box", ->
  #     expect('pending').toEqual('completed')

  #   it "should remove incorrect highlighting class if correct", ->
  #      expect('pending').toEqual('completed')

  #   it "should add incorrect highlighting class if incorrect", ->
  #     expect('pending').toEqual('completed') 

  # describe "when getting data from an element", ->
  #   it "should check if it has a data-bl attribute", ->
  #     expect('pending').toEqual('completed') 

  #   describe "with a data-bl attribute", ->

  #     it "should parse a JSON object from the data-bl attribute", ->
  #       expect('pending').toEqual('completed')

  #     it "should produce a valid JSON object with the correct data", ->
  #       expect('pending').toEqual('completed')

  #   describe "without a data-bl attribute", ->

  #     it "should parse a JSON object from the elements text", ->
  #       expect('pending').toEqual('completed')

  #     it "should produce a valid JSON object with the correct data", ->
  #       expect('pending').toEqual('completed')

  # describe "when clearing start and end time inputs", ->
  #   it "should clear values for input box in the snippet box", ->
  #     expect('pending').toEqual('completed')

  #   it "should clear values for the textarea in the snippet box", ->
  #     expect('pending').toEqual('completed')

  #   it "should remove the incorrect highlighting class from the input boxes", ->
  #     expect('pending').toEqual('completed')

  # describe "when updating output box", -> 

  #   it "should generate a string representing the JSON data object", ->
  #     expect('pending').toEqual('completed')

  #   it "should encoded the data string", ->
  #     expect('pending').toEqual('completed') 

  #   it "should find the source question", ->
  #     expect('pending').toEqual('completed')

  #   it "should get the question's current contents", ->
  #     expect('pending').toEqual('completed')

  #   it "should iterate through the question's text and html", ->
  #     expect('pending').toEqual('completed')

  #   it "should place the new link at the caret position", ->
  #     expect('pending').toEqual('completed')

  #   it "should replace the question's content with the new content", ->
  #     expect('pending').toEqual('completed')

  #   it "should update the question's textarea", ->
  #     expect('pending').toEqual('completed')

  # describe "when YouTube clip player is ready", ->
  #   it "should cue the video in the video box at the correct start and end times", ->
  #     expect('pending').toEqual('completed')

  # describe "when setting up for YouTube Videos", ->
  #   it "should create a script element", ->
  #     expect('pending').toEqual('completed')

  #   it "should set the script element's source to YouTube iframe API", ->
  #     expect('pending').toEqual('completed')

  #   it "should the first script tag", ->
  #     expect('pending').toEqual('completed')

  #   it "should insert the new script tag before the first script tag", ->
  #     expect('pending').toEqual('completed') 

  # describe "when generating output box", ->
  #   it "should find the textarea by id", ->
  #     expect('pending').toEqual('completed')

  #   it "should get the textarea's width, height and value", ->
  #     expect('pending').toEqual('completed')

  #   it "should insert an div after the textarea area and hide the textarea", ->
  #     expect('pending').toEqual('completed')

  #   it "should give the new div the same height, width and value", ->
  #     expect('pending').toEqual('completed')

  #   it "should add an input button after the div", ->
  #     expect('pending').toEqual('completed')

  #   it "should store an encoded data string in the button", ->
  #     expect('pending').toEqual('completed')

  # describe "when generating clip a tag", ->

  #   it "should get start and end times from snippet box", ->
  #     expect('pending').toEqual('completed')

  #   it "should check for errors in the start and end times", ->
  #     expect('pending').toEqual('completed')

  #   describe "with correct values", ->

  #     it "should make sure there is a correct value for end_time", ->
  #       expect('pending').toEqual('completed')

  #     it "should generate a show data JSON string", ->
  #       expect('pending').toEqual('completed')

  #     it "should encode the data string", ->
  #       expect('pending').toEqual('completed')

  #     it "should create an a tag with the encodedData in the text", ->
  #       expect('pending').toEqual('completed')

  #     it "should return the tag", ->
  #       expect('pending').toEqual('completed')

  #   describe "without correct values", ->

  #     it "should return and empty string", ->
  #       expect('pending').toEqual('completed')

  # describe "when generating JSON clip data", ->

  #   it "should check for data in the argument and default to instance values if needed", ->
  #     expect('pending').toEqual('completed')

  #   it "should return a data string according to the type in the argument", ->
  #     expect('pending').toEqual('completed')

  #   describe "without a type", ->

  #     it "should return an empty string", ->
  #       expect('pending').toEqual('completed')

  # describe "when generating video box", -> 

  #   it "should create a div with an id of bl-vid", ->
  #     expect('pending').toEqual('completed')

  #   it "should have a div with the id of bl-playerV inside", ->
  #     expect('pending').toEqual('completed')

  # describe "when generating clipping box", ->

  #   it "should create a div with an id of bl", ->
  #     expect('pending').toEqual('completed')

  #   it "should have a div with the id of bl-player inside", ->
  #     expect('pending').toEqual('completed')

  # describe "when getting caret position", ->

  #   it "should have a spec", ->
  #     expect('pending').toEqual('completed')


  # describe "when stripping html", ->

  #   it "should create a div", ->
  #     expect('pending').toEqual('completed')

  #   it "should put the html into the div's innerHTML", ->
  #     expect('pending').toEqual('completed')

  #   it "should return div's textContent or innerText", ->
  #     expect('pending').toEqual('completed')

