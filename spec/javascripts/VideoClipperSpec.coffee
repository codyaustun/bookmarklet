describe "VideoClipper", ->

  it "should have VideoClipper class", ->
    @clippy = new VideoClipper
    expect(@clippy).toBeDefined()

  describe "when constructing", ->
    beforeEach ->
      @textareaID = 'bl-text'
      @videoId = '8f7wj_RcqYk'
      @videoType = 'TEST'

    afterEach ->
      VideoClipper.cleanUp()

    describe 'with defaults', ->
      beforeEach ->
        @clippy = new VideoClipper
          textareaID: @textareaID
          videoId: @videoId
          videoType: @videoType

      it "should use @textareaID for the instance's textareaID", ->
        expect(@clippy.textareaID).toEqual @textareaID

      it "should use @videoId for the instance's videoId", ->
        expect(@clippy.videoId).toEqual @videoId

      it "should use @videoType for the instance's videoType", ->
        expect(@clippy.videoType).toEqual @videoType

      it "should use VideoClipper.reel for the instance's reel", ->
        expect(@clippy.reel).toEqual VideoClipper.reel

      it "should use VideoClipper.answerClass for the instance's answerClass", ->
        expect(@clippy.answerClass).toEqual VideoClipper.answerClass

      it "should use VideoClipper.generateHtml for the instance's generate", ->
        expect(@clippy.generate).toEqual VideoClipper.generateHtml

      it 'should generate a buttonID for the instance', ->
        expect(@clippy.buttonID).toBeDefined()

    describe 'without using defaults', ->
      beforeEach ->
        @answerClass = 'answer-class-test'
        @reel = 'reel-test'
        @buttonID = 'button-id-test'
        @textareaID = 'bl-text'
        @generate = false

        @clippy = new VideoClipper
          textareaID: @textareaID
          videoId: @videoId
          videoType: @videoType
          generate: @generate
          reel: @reel
          buttonID: @buttonID
          answerClass: @answerClass

      it "should use @textareaID for the instance's textareaID", ->
        expect(@clippy.textareaID).toEqual @textareaID

      it "should use @videoId for the instance's videoId", ->
        expect(@clippy.videoId).toEqual @videoId

      it "should use @videoType for the instance's videoType", ->
        expect(@clippy.videoType).toEqual @videoType

      it "should use the given value for the instance's reel", ->
        expect(@clippy.reel).toEqual @reel

      it "should use the given value for the instance's answerClass", ->
        expect(@clippy.answerClass).toEqual @answerClass

      it "should use the given value for the instance's generate", ->
        expect(@clippy.generate).toEqual @generate

      it "should use the given value for the instance's buttonID", ->
        expect(@clippy.buttonID).toEqual @buttonID

    describe 'when generate is true', ->
      it 'should call #setup', ->
        # clippy.setup calls VideoClipper.generate, so
        # this tests spies on VideoClipper.generate
        spyOn(VideoClipper, 'generate')

        clippy = new VideoClipper
          textareaID: @textareaID
          videoId: @videoId
          videoType: @videoType
          generate: true

    describe 'when generate is false', ->
      it 'should not call #setup', ->
        # clippy.setup calls VideoClipper.generate, so
        # this tests spies on VideoClipper.generate
        spyOn(VideoClipper, 'generate')

        clippy = new VideoClipper
          textareaID: @textareaID
          videoId: @videoId
          videoType: @videoType
          generate: false

        expect(VideoClipper.generate).not.toHaveBeenCalled()

    it 'should add the new instance to VideoClipper.clippers', ->
      clippy = new VideoClipper
        textareaID: @textareaID
        videoId: @videoId
        videoType: @videoType
        generate: true

      addedClipper = false
      addedClipper = true for c in VideoClipper.clippers when c = clippy
      expect(addedClipper).toBeTruthy

  describe '.generateQuestionBox', ->
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      textareaID = 'bl-text'
      @selector = '#'+textareaID

      @clippy = new VideoClipper
        textareaID: textareaID
        videoId: '8f7wj_RcqYk'
        videoType: 'TEST'
        generate: false

    it 'should only have one element specified by textareaID', ->
      expect($(@selector).length).toBe(1)
        
    it 'should get height of the element with textareaID', ->
      heightSpy = spyOn($.fn, 'height')
      spyOn(@clippy, 'generateQuestionBox').andCallThrough()
      @clippy.generateQuestionBox()
      expect(@clippy.generateQuestionBox).toHaveBeenCalled()
      expect($.fn.height).toHaveBeenCalled()
      expect(heightSpy.mostRecentCall.object.selector).toEqual(@selector)

    it 'should get width of the element with textareaID', ->
      widthSpy = spyOn($.fn, 'width')
      @clippy.generateQuestionBox()
      expect($.fn.width).toHaveBeenCalled()
      expect(widthSpy.mostRecentCall.object.selector).toEqual @selector

    it 'should get the value of the element with textareaID', ->
      valSpy = spyOn $.fn, 'val'
      @clippy.generateQuestionBox()
      expect($.fn.val).toHaveBeenCalled()
      expect(valSpy.mostRecentCall.object.selector).toEqual @selector

    it 'should insert of an answerClass div after the textarea', ->
      @clippy.generateQuestionBox()
      textarea = $(@selector)
      expect(textarea.next()).toBe 'div'
      expect(textarea.next()).toHaveClass @clippy.answerClass

    it 'should make the divcontenteditable', ->
      @clippy.generateQuestionBox()
      textarea = $(@selector)
      expect(textarea.next()).toHaveAttr 'contenteditable', 'true'

    it 'should make the div have the same height and width as the textarea', ->
      @clippy.generateQuestionBox()
      textarea = $(@selector)
      div = textarea.next()
      expect(div.height()).toEqual textarea.height()
      expect(div.width()).toEqual textarea.width()

    it 'should generate a bl data string', ->
      spyOn(VideoClipper, 'generateBLDataString')
      @clippy.generateQuestionBox()
      expect(VideoClipper.generateBLDataString).toHaveBeenCalledWith 'generate', @clippy

    describe 'without a buttonid specified', ->
      it 'should create a button after the outputbox div', ->
        @clippy.generateQuestionBox()
        div = $(@selector).next()
        expect(div.next()).toBe 'input[type=button]'

      it "should set the rel attribute of the button to 'blModal'", ->
        @clippy.generateQuestionBox()
        button = $(@selector).next().next()
        expect(button).toHaveAttr 'rel', 'blModal'

      it 'should store the encoded BLDataString in the bl-data attribute', ->
        @clippy.generateQuestionBox()
        button = $(@selector).next().next()

        blData = VideoClipper.generateBLDataString 'generate', @clippy

        encoded = encodeURI(blData)
        expect(button).toHaveAttr 'data-bl', encoded

      it 'should make the button respond to clicks', ->
        @clippy.generateQuestionBox()
        expect($("#"+@clippy.buttonID)).toHandle('click')

    describe 'with a buttonid specified', ->
      beforeEach ->
        @testID = "button-test"
        textareaID = 'bl-text'

        @clippy = new VideoClipper
          textareaID: textareaID
          videoId: '8f7wj_RcqYk'
          videoType: 'TEST'
          buttonID: @testID
          generate: false

      it "should set the rel attribute of the button to 'blModal'", ->
        @clippy.generateQuestionBox()
        button = $('#'+@testID)
        expect(button).toHaveAttr 'rel', 'blModal'

      it 'should store the encoded BLDataString in the bl-data attribute', ->
        @clippy.generateQuestionBox()
        button = $('#'+@testID)

        blData = VideoClipper.generateBLDataString 'generate', @clippy

        encoded = encodeURI(blData)
        expect(button).toHaveAttr 'data-bl', encoded

      it 'should make the button respond to clicks', ->
        @clippy.generateQuestionBox()
        expect($("#"+@clippy.buttonID)).toHandle('click')

  describe '.generateOverlay', ->
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')

      @clippy = new VideoClipper
        textareaID: 'bl-text'
        videoId: '8f7wj_RcqYk'
        videoType: 'TEST'
        generate: false

    it "should create a bookMarklet-overlay div if doesn't exist", ->
      expect($("#bookMarklet-overlay").length).toEqual 0
      appendSpy = spyOn($.fn, 'appendTo').andCallThrough()
      VideoClipper.generateOverlay()
      expect($("#bookMarklet-overlay").length).toEqual 1
      expect($.fn.appendTo).toHaveBeenCalled()

    describe 'and one already exists', ->

      it 'should not create another overlay', ->
        VideoClipper.generateOverlay()
        expect($("#bookMarklet-overlay").length).toEqual 1
        appendSpy = spyOn($.fn, 'appendTo').andCallThrough()
        VideoClipper.generateOverlay()
        expect($("#bookMarklet-overlay").length).toEqual 1
        expect($.fn.appendTo).not.toHaveBeenCalled()

    it 'should make the overlay respond to click', ->
      VideoClipper.generateOverlay()
      expect($("#bookMarklet-overlay")).toHandle('click')

    describe 'and the overlay is clicked', ->
      it 'should call closeModal', ->
        VideoClipper.generateOverlay()
        spyOn(VideoClipper, "closeModal").andCallThrough
        $("#bookMarklet-overlay").click()
        expect(VideoClipper.closeModal).toHaveBeenCalled()

  describe ".generateSnippetBox", ->
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      @testID = "button-test"
      textareaID = 'bl-text'

      @clippy = new VideoClipper
        textareaID: textareaID
        videoId: '8f7wj_RcqYk'
        videoType: 'TEST'
        buttonID: @testID
        generate: true

      VideoClipper.player = new OmniPlayer
        type: "TEST"

      VideoClipper.clipper = @clippy

    it "should make the start button respond to clicks", ->
      expect($('.bl-start')).toHandle("click")

    describe "and the start button is clicked", ->
  
      it "should get the current time from the player", ->
        spyOn(VideoClipper.player, 'getCurrentTime').andCallThrough()
        spyOn(VideoClipper, 'checkErrors')
        $('.bl-start').click()
        expect(VideoClipper.player.getCurrentTime).toHaveBeenCalled()

      it "should set the bl-start input to the current time", ->
        spyOn(VideoClipper.player, 'getCurrentTime').andReturn(300)
        spyOn(VideoClipper, 'checkErrors')
        inputSelector = "input[name='bl-start']"
        valSpy = spyOn($.fn, 'val').andCallThrough()
        $('.bl-start').click()
        expect($.fn.val).toHaveBeenCalledWith(300)
        expect(valSpy.mostRecentCall.object.selector).toEqual inputSelector

      it "should check for errors", ->
        spyOn(VideoClipper, 'checkErrors')
        $('.bl-start').click()
        expect(VideoClipper.checkErrors).toHaveBeenCalled()


    it "should make the end button respond to clicks", ->
      expect($('.bl-end')).toHandle("click")

    describe 'and end button is clicked', ->
      it "should get the current time from the player", ->
        spyOn(VideoClipper.player, 'getCurrentTime').andCallThrough()
        spyOn(VideoClipper, 'checkErrors')
        $('.bl-end').click()
        expect(VideoClipper.player.getCurrentTime).toHaveBeenCalled()

      it "should set the bl-start input to the current time", ->
        spyOn(VideoClipper.player, 'getCurrentTime').andReturn(300)
        spyOn(VideoClipper, 'checkErrors')
        inputSelector = "input[name='bl-end']"
        valSpy = spyOn($.fn, 'val').andCallThrough()
        $('.bl-end').click()
        expect($.fn.val).toHaveBeenCalledWith(300)
        expect(valSpy.mostRecentCall.object.selector).toEqual inputSelector

      it "should check for errors", ->
        spyOn(VideoClipper, 'checkErrors')
        $('.bl-end').click()
        expect(VideoClipper.checkErrors).toHaveBeenCalled()

    it "should make the reset button respond to clicks", ->
      expect($(".bl-reset")).toHandle("click")

    describe 'and the reset button is clicked', ->
      it 'should clear the snippet box inputs', ->
        spyOn(VideoClipper, 'clearInputs')
        $('.bl-reset').click()
        expect(VideoClipper.clearInputs).toHaveBeenCalled

      it 'should cue the video by id', ->
        spyOn(VideoClipper.player, 'cueVideoById')
        $('.bl-reset').click()
        expect(VideoClipper.player.cueVideoById).toHaveBeenCalled()

    it "should make the done button respond to clicks", ->
      expect($('.bl-done')).toHandle("click")

    describe 'and the done button is clicked', ->
      it 'should close the modal', ->
        spyOn(VideoClipper, 'closeModal')
        $('.bl-done').click()
        expect(VideoClipper.closeModal).toHaveBeenCalled()

      it 'should generate a new tag', ->
        spyOn(VideoClipper, 'generateTag')
        $('.bl-done').click()
        expect(VideoClipper.generateTag).toHaveBeenCalled()

      it 'should use the generated tag to update', ->
        testString = 'Testing 1 2 3'
        spyOn(VideoClipper, 'generateTag').andReturn(testString)
        spyOn(@clippy, 'update')
        $('.bl-done').click()
        expect(@clippy.update).toHaveBeenCalledWith(testString)

    it 'should set VideoClipper prepared snippet to true', ->
      expect(VideoClipper.prepared.snippet).toBeTruthy()

  describe ".generateVideoBox", ->
    describe 'with a #bl-vid already', ->
      beforeEach ->
        VideoClipper.generateVideoBox()

      afterEach ->
        VideoClipper.cleanUp()
      it "should not add another #bl-vid div", ->
        expect($('#bl-vid').length).toEqual 1
        VideoClipper.generateVideoBox()
        expect($('#bl-vid').length).toEqual 1

    describe 'without a #bl-vid already', ->
      it 'should add a #bl-vid div', ->
        expect($('#bl-vid').length).toEqual 0
        VideoClipper.generateVideoBox()
        expect($('#bl-vid').length).toEqual 1

      it 'should have #bl-playerV inside #bl-vid', ->
        VideoClipper.generateVideoBox()
        expect($('#bl-vid').find('#bl-playerV').length).toEqual 1        

    it 'should return VideoClipper', ->
      result = VideoClipper.generateVideoBox()
      expect(result).toEqual VideoClipper

  describe "#setup", ->
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      @testID = "button-test"
      textareaID = 'bl-text'

      @clippy = new VideoClipper
        textareaID: textareaID
        videoId: '8f7wj_RcqYk'
        videoType: 'TEST'
        buttonID: @testID
        generate: false

    it "should generate a video box", ->
      expect($('#bl-vid').length).toBe(0)
      spyOn(VideoClipper, 'generateVideoBox')
      @clippy.setup()
      expect(VideoClipper.generateVideoBox).toHaveBeenCalled()

    it "should generate a snippet box", ->
      expect($('#bl').length).toBe(0)
      spyOn(VideoClipper, 'generateSnippetBox')
      @clippy.setup()
      expect(VideoClipper.generateSnippetBox).toHaveBeenCalled()

    it "should generate the question box", ->
      spyOn(@clippy, 'generateQuestionBox').andCallThrough()
      spyOn(VideoClipper, 'generateSnippetBox')
      @clippy.setup()
      expect(@clippy.generateQuestionBox).toHaveBeenCalled()

    it "should generate the video clipper overlay", ->
      expect($('#bookmarklet-overlay').length).toBe(0)
      spyOn(VideoClipper, 'generateOverlay')
      @clippy.setup()
      expect(VideoClipper.generateOverlay).toHaveBeenCalled()

    describe 'with a valid output box', ->
      beforeEach ->
        onSpy = spyOn($.fn,'on').andCallThrough()
        @clippy.setup()

      it 'should make the output box respond to clicks', ->
        expect($("."+@clippy.answerClass)).toHandle('click')

      it 'should make the output box respond to keyups', ->
        expect($("."+@clippy.answerClass)).toHandle('keyup')

  describe '.generate', ->
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      @testID = "button-test"
      textareaID = 'bl-text'

      @clippy = new VideoClipper
        textareaID: textareaID
        videoId: '8f7wj_RcqYk'
        videoType: 'TEST'
        buttonID: @testID
        generate: false

    describe 'with a VideoClipper instance', ->
      beforeEach ->
        @clippy.generateQuestionBox()
        loadFixtures('question.html')

      it "should generate a snippet box", ->
        expect($('#bl').length).toBe(0)
        spyOn(VideoClipper, 'generateSnippetBox')
        VideoClipper.generate @clippy
        expect(VideoClipper.generateSnippetBox).toHaveBeenCalledWith @clippy

      it "should generate the video clipper overlay", ->
        expect($('#bookmarklet-overlay').length).toBe(0)
        spyOn(VideoClipper, 'generateOverlay')
        VideoClipper.generate @clippy
        expect(VideoClipper.generateOverlay).toHaveBeenCalled()

      it "should generate a video box", ->
        expect($('#bl-vid').length).toBe(0)
        spyOn(VideoClipper, 'generateVideoBox')
        VideoClipper.generate @clippy
        expect(VideoClipper.generateVideoBox).toHaveBeenCalled()

    describe 'without a VideoClipper instance', ->
      beforeEach ->
        loadFixtures('answer.html')
      it "should not generate a snippet box", ->
        expect($('#bl').length).toBe(0)
        spyOn(VideoClipper, 'generateSnippetBox')
        VideoClipper.generate()
        expect($('#bl').length).toBe(0)
        expect(VideoClipper.generateSnippetBox).not.toHaveBeenCalled()

      it "should generate the video clipper overlay", ->
        expect($('#bookmarklet-overlay').length).toBe(0)
        spyOn(VideoClipper, 'generateOverlay')
        VideoClipper.generate()
        expect(VideoClipper.generateOverlay).toHaveBeenCalled()

      it "should generate a video box", ->
        expect($('#bl-vid').length).toBe(0)
        spyOn(VideoClipper, 'generateVideoBox')
        VideoClipper.generate()
        expect(VideoClipper.generateVideoBox).toHaveBeenCalled()

      it "should make video clips handle clicks", ->
        VideoClipper.generate()
        expect($('[rel*=blModal]')).toHandle 'click'

      describe 'when a video clip is click', ->
        it 'should open the modal window', ->
          spyOn(VideoClipper, 'openModal')
          VideoClipper.generate()
          $('[rel*=blModal]').click()
          expect(VideoClipper.openModal).toHaveBeenCalled()

  describe '.cleanUp', ->
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      @testID = "button-test"
      textareaID = 'bl-text'

      @clippy = new VideoClipper
        textareaID: textareaID
        videoId: '8f7wj_RcqYk'
        videoType: 'TEST'
        buttonID: @testID

    it 'should remove the div with id of bl', ->
      expect($('#bl')).toExist()
      VideoClipper.cleanUp()
      expect($('#bl')).not.toExist()

    it 'should remove the div with id of bl-vid', ->
      expect($('#bl-vid')).toExist()
      VideoClipper.cleanUp()
      expect($('#bl-vid')).not.toExist()

    it 'should remove the div with id of bookMarklet-overlay', ->
      expect($('#bookMarklet-overlay')).toExist()
      VideoClipper.cleanUp()
      expect($('#bookMarklet-overlay')).not.toExist()

    it 'should set VideoClipper prepared snippet to false', ->
      VideoClipper.cleanUp()
      expect(VideoClipper.prepared.snippet).toBeFalsy()

    it 'should remove all questionBoxs', ->
      removeSpy = spyOn($.fn,'remove')
      VideoClipper.cleanUp()
      expect($.fn.remove).toHaveBeenCalled()
      expect(removeSpy.mostRecentCall.object).toEqual @clippy.questionBox

  describe ".closeModal", ->
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      @testID = "button-test"
      textareaID = 'bl-text'

      @clippy = new VideoClipper
        textareaID: textareaID
        videoId: '8f7wj_RcqYk'
        videoType: 'TEST'
        buttonID: @testID

      VideoClipper.openModal $('#'+@testID), @clippy

    it "should fade out the overlay", ->
      fadeSpy = spyOn($.fn, 'fadeOut')
      VideoClipper.closeModal(@clippy.modalID)
      expect($.fn.fadeOut).toHaveBeenCalled()
      expect(fadeSpy.mostRecentCall.object.selector).toEqual "#bookMarklet-overlay"

    it "should hide the modal window", ->
      expect($(VideoClipper.modalID)).toBeVisible()
      VideoClipper.closeModal()
      expect($(VideoClipper.modalID)).toBeHidden()

    it "should stop the video player", ->
      spyOn(VideoClipper.player, 'stopVideo')
      VideoClipper.closeModal(@clippy.modalID)
      expect(VideoClipper.player.stopVideo).toHaveBeenCalled()

  describe ".openModal", ->
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      @testID = "button-test"
      textareaID = 'bl-text'

      @clippy = new VideoClipper
        textareaID: textareaID
        videoId: '8f7wj_RcqYk'
        videoType: 'TEST'
        buttonID: @testID

      @el = $('#'+@testID)
      @blData = VideoClipper.getBLData @el

    afterEach ->
      VideoClipper.closeModal()

    it 'should close any open modal windows', ->
      spyOn(VideoClipper, 'closeModal')
      VideoClipper.openModal @el, @clippy
      expect(VideoClipper.closeModal).toHaveBeenCalled()

    it "should get the data from the element", ->
      spyOn(VideoClipper, 'getBLData').andReturn @blData
      VideoClipper.openModal @el, @clippy
      expect(VideoClipper.getBLData).toHaveBeenCalledWith @el

    describe "with a snippet box", ->
      beforeEach ->
        spyOn(VideoClipper, 'getBLData').andReturn @blData

      it "should get video type and id", ->
        VideoClipper.openModal @el, @clippy
        expect(@clippy.videoId).toEqual @blData.video.id
        expect(@clippy.videoType).toEqual @blData.video.type

      it "should clear inputs", ->
        spyOn(VideoClipper, 'clearInputs').andCallThrough()
        VideoClipper.openModal @el, @clippy
        expect(VideoClipper.clearInputs).toHaveBeenCalled()

      it "should create a video player if it doesn't exist", ->
        VideoClipper.openModal @el, @clippy
        expect(VideoClipper.player).toEqual jasmine.any(OmniPlayer)

      it "should show snippet box", ->
        fadeSpy = spyOn($.fn,'fadeTo').andCallThrough()
        VideoClipper.openModal @el, @clippy
        expect($.fn.fadeTo).toHaveBeenCalled()
        expect(fadeSpy.mostRecentCall.object.selector).toEqual('#bl')

      it "should show overlay", ->
        fadeSpy = spyOn($.fn,'fadeTo').andCallThrough()
        VideoClipper.openModal @el, @clippy
        expect($.fn.fadeTo).toHaveBeenCalled()
        expect(fadeSpy.calls[0].object.selector).toEqual('#bookMarklet-overlay')

    describe "with a video box", ->
      beforeEach ->
        @clippy.startTime = '200'
        @clippy.endTime = '300'
        @blData = $.parseJSON VideoClipper.generateBLDataString('show', @clippy)
        spyOn(VideoClipper, 'getBLData').andReturn @blData

      afterEach ->
        VideoClipper.closeModal()

      it "should get video type, id, start time and end time", ->
        VideoClipper.openModal @el
        expect(@clippy.videoId).toEqual @blData.video.id
        expect(@clippy.videoType).toEqual @blData.video.type
        expect(@clippy.startTime).toEqual @blData.start
        expect(@clippy.endTime).toEqual @blData.end

      it "should create a video player if it doesn't exist", ->
        VideoClipper.openModal @el
        expect(VideoClipper.playerV).toEqual jasmine.any(OmniPlayer)

      it "should show video box", ->
        fadeSpy = spyOn($.fn,'fadeTo').andCallThrough()
        VideoClipper.openModal @el
        expect($.fn.fadeTo).toHaveBeenCalled()
        expect(fadeSpy.mostRecentCall.object.selector).toEqual('#bl-vid')

      it "should show overlay", ->
        fadeSpy = spyOn($.fn,'fadeTo').andCallThrough()
        VideoClipper.openModal @el
        expect($.fn.fadeTo).toHaveBeenCalled()
        expect(fadeSpy.calls[0].object.selector).toEqual('#bookMarklet-overlay')

  describe ".checkErrors", ->
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      @testID = "button-test"
      textareaID = 'bl-text'

      @clippy = new VideoClipper
        textareaID: textareaID
        videoId: '8f7wj_RcqYk'
        videoType: 'TEST'
        buttonID: @testID

    it "should parse floats from the  start input box", ->
      $("input[name='bl-start']").val("300")
      spyOn(window, 'parseFloat').andReturn 300
      VideoClipper.checkErrors()
      expect(window.parseFloat).toHaveBeenCalledWith "300"

    it "should parse floats from the  end input box", ->
      $("input[name='bl-end']").val("300")
      spyOn(window, 'parseFloat').andReturn 300
      VideoClipper.checkErrors()
      expect(window.parseFloat).toHaveBeenCalledWith "300"

    describe 'if correct', ->
      beforeEach ->
        $("input[name='bl-start']").val("300")
        $("input[name='bl-end']").val("400")

      it "should remove incorrect highlighting class", ->
        $("input[name='bl-start']").addClass "bl-incorrect"
        $("input[name='bl-end']").addClass "bl-incorrect"
        VideoClipper.checkErrors()
        expect($("input[name='bl-start']")).not.toHaveClass "bl-incorrect"
        expect($("input[name='bl-end']")).not.toHaveClass "bl-incorrect"

      it "should return true", ->
        expect(VideoClipper.checkErrors()).toBeTruthy()      

    describe 'if incorrect', ->
      beforeEach ->
        $("input[name='bl-start']").val("400")
        $("input[name='bl-end']").val("300")

      it "should add incorrect highlighting class", -> 
        VideoClipper.checkErrors()
        expect($("input[name='bl-start']")).toHaveClass "bl-incorrect"
        expect($("input[name='bl-end']")).toHaveClass "bl-incorrect"

      it 'should return false', ->
        expect(VideoClipper.checkErrors()).toBeFalsy() 

  describe ".getBLData", ->
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      @testID = "button-test"
      textareaID = 'bl-text'

      @clippy = new VideoClipper
        textareaID: textareaID
        videoId: '8f7wj_RcqYk'
        videoType: 'TEST'
        buttonID: @testID

      @testDataGenerate = encodeURI VideoClipper.generateBLDataString('generate', @clippy)

      @clippy.startTime = '200'
      @clippy.endTime = '300'
      @testDataShow = encodeURI VideoClipper.generateBLDataString('show', @clippy)
      
      $('body').append("<div id='test'></div>")

    afterEach ->
      $('#test').remove()

    it "should check if it has a data-bl attribute", ->
      el = $('#test').attr('data-bl', @testDataGenerate)
      attrSpy = spyOn($.fn, 'attr').andCallThrough()
      VideoClipper.getBLData(el)
      expect($.fn.attr).toHaveBeenCalledWith('data-bl')
      expect(attrSpy.calls[0].object).toEqual(el)

    describe "with a data-bl attribute", ->
      beforeEach ->
        @el = $('#test').attr 'data-bl', @testDataGenerate

      it 'should get the encoded data from the data-bl attribute', ->
        attrSpy = spyOn($.fn, 'attr').andCallThrough()
        VideoClipper.getBLData @el
        expect($.fn.attr.calls.length).toEqual 2
        expect(attrSpy.calls[1].object).toEqual @el

      it "should parse a JSON object from the data-bl attribute", ->
        spyOn($, 'parseJSON')
        VideoClipper.getBLData @el
        expect($.parseJSON).toHaveBeenCalledWith decodeURI @testDataGenerate

      it "should produce a valid JSON object with the correct data", ->
        blData = VideoClipper.getBLData @el
        expect(blData).toEqual $.parseJSON decodeURI @testDataGenerate

    describe "without a data-bl attribute", ->
      beforeEach ->
        @el = $('#test').text @testDataShow

      it 'should get the encoded data from the elements tesxt', ->
        textSpy = spyOn($.fn, 'text').andCallThrough()
        VideoClipper.getBLData @el
        expect($.fn.text).toHaveBeenCalled()
        expect(textSpy.calls[0].object).toEqual(@el)

      it "should parse a JSON object from the elements text", ->
        spyOn($, 'parseJSON')
        VideoClipper.getBLData @el
        expect($.parseJSON).toHaveBeenCalledWith decodeURI @testDataShow

      it "should produce a valid JSON object with the correct data", ->
        blData = VideoClipper.getBLData @el
        expect(blData).toEqual $.parseJSON decodeURI @testDataShow


  describe ".clearInputs", ->
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      @testID = "button-test"
      textareaID = 'bl-text'

      @clippy = new VideoClipper
        textareaID: textareaID
        videoId: '8f7wj_RcqYk'
        videoType: 'TEST'
        buttonID: @testID

    it "should clear values for input box in the snippet box", ->
      $("input[name='bl-end']").val 200
      $("input[name='bl-start']").val 300
      VideoClipper.clearInputs()
      expect($("input[name='bl-end']").val()).toEqual ""
      expect($("input[name='bl-start']").val()).toEqual ""      

    it "should clear values for the textarea in the snippet box", ->
      $(".bl-URL").text "Testing 1.. 2.. 3.."
      VideoClipper.clearInputs()
      expect($(".bl-URL").text()).toEqual "Generated URL goes here"

    it "should remove the bl-incorrect class from the input boxes", ->
      $("input[name='bl-end']").addClass "bl-incorrect"
      $("input[name='bl-start']").addClass "bl-incorrect"
      VideoClipper.clearInputs()
      expect($("input[name='bl-start']")).not.toHaveClass "bl-incorrect"
      expect($("input[name='bl-end']")).not.toHaveClass "bl-incorrect"

  describe "#update", -> 
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      @testID = "button-test"
      textareaID = 'bl-text'

      @clippy = new VideoClipper
        textareaID: textareaID
        videoId: '8f7wj_RcqYk'
        videoType: 'TEST'
        buttonID: @testID

      @clippy.startTime = '300'
      @clippy.endTime = '400'

      data = encodeURI VideoClipper.generateBLDataString('show',@clippy)

      @newTag = $("<a rel='blModal' href='#bl-vid' class='bl'>"+data+"</a>").
        css
          'background-image': @reel

      $('body').append("<div id='test'></div>")

    afterEach ->
      $('#test').remove()

    it "should put the new link into the .bl-URL textarea", ->
      textSpy = spyOn($.fn, 'text').andCallThrough()
      @clippy.update(@newTag)
      expect($('.bl-URL')).toContainText(@newTag)

    it "should get the question's current contents", ->
      contentSpy = spyOn($.fn, 'contents').andCallThrough()
      @clippy.update(@newTag)
      expect($.fn.contents).toHaveBeenCalled()
      expect(contentSpy.mostRecentCall.object).
        toEqual @clippy.questionBox

    describe "that doesn't already have contents", ->
      it "the div's text equal the new link", ->
        console.log $('.'+@clippy.answerClass).contents().length
        @clippy.update(@newTag)
        expect($('.'+@clippy.answerClass).find('a').text()).
          toEqual @newTag.text()

    describe 'that already has contents', ->
      it "should iterate through the question's text and html", ->
        expect('pending').toEqual('completed')

      it "should place the new link at the caret position", ->
        expect('pending').toEqual('completed')

      it "should replace the question's content with the new content", ->
        expect('pending').toEqual('completed')

    it "should update the question's textarea", ->
      expect('pending').toEqual('completed')

  describe ".generateTag", ->
    beforeEach ->
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      @testID = "button-test"
      textareaID = 'bl-text'

      @clippy = new VideoClipper
        textareaID: textareaID
        videoId: '8f7wj_RcqYk'
        videoType: 'TEST'
        buttonID: @testID

      @el = $('#'+@testID)
      @blData = VideoClipper.getBLData @el

      VideoClipper.openModal @el, @clippy

    afterEach ->
      VideoClipper.closeModal()

    it "should get start time from the snippet box", ->
      $("input[name='bl-start']").val("200.5")
      valSpy = spyOn($.fn, "val").andCallThrough()
      VideoClipper.generateTag @clippy
      expect($.fn.val).toHaveBeenCalled()
      expect("#{@clippy.startTime}").toEqual '200.5'
      expect(valSpy.calls[0].object.selector).toEqual("input[name='bl-start']")

    it "should get end time from the snippet box", ->
      $("input[name='bl-end']").val("300.5")
      valSpy = spyOn($.fn, "val").andCallThrough()
      VideoClipper.generateTag @clippy
      expect($.fn.val).toHaveBeenCalled()
      expect("#{@clippy.endTime}").toEqual '300.5'
      expect(valSpy.calls[1].object.selector).toEqual("input[name='bl-end']")

    it "should check for errors in the start and end times", ->
      spyOn(VideoClipper, 'checkErrors').andCallThrough()
      VideoClipper.generateTag @clippy
      expect(VideoClipper.checkErrors).toHaveBeenCalled()

    describe "with correct values", ->
      beforeEach ->
        $("input[name='bl-start']").val("200.5")
        $("input[name='bl-end']").val("300.5")
  
      it "should set the endTime to the video duration if it isn't defined", ->
        $("input[name='bl-end']").val("")
        spyOn(VideoClipper.player, 'getDuration').andReturn 400
        VideoClipper.generateTag @clippy
        expect(VideoClipper.player.getDuration).toHaveBeenCalled()

      it "should generate a show data JSON string", ->
        spyOn(VideoClipper, 'generateBLDataString').andCallThrough()
        VideoClipper.generateTag @clippy
        expect(VideoClipper.generateBLDataString).toHaveBeenCalled()

      it "should encode the data string", ->
        spyOn(window, 'encodeURI')
        str = 'Test'
        spyOn(VideoClipper, 'generateBLDataString').andReturn (str)
        VideoClipper.generateTag @clippy
        expect(window.encodeURI).toHaveBeenCalledWith(str)
  

      it "should create an a tag with the encodedData in the text", ->
        str = 'Test'
        spyOn(VideoClipper, 'generateBLDataString').andReturn (str)
        tag = VideoClipper.generateTag @clippy
        expect(tag).toBe 'a'
        expect(tag.text()).toEqual encodeURI str

      it "should the clip to the instance's clips", ->
        tag = VideoClipper.generateTag @clippy
        clipAdded = false
        clipAdded = true for clip in @clippy.clips when clip == tag
        expect(clipAdded).toBeTruthy

      it "should return the tag", ->
        tag = VideoClipper.generateTag @clippy
        expect(tag).toBe 'a'

    describe "without correct values", ->

      it "should return and empty string", ->
        spyOn(VideoClipper, 'checkErrors').andReturn false
        expect(VideoClipper.generateTag(@clippy)).toEqual ""  

  describe ".generateBLDataString", ->
    beforeEach -> 
      VideoClipper.cleanUp()
      loadFixtures('question.html')
      @testID = "button-test"
      textareaID = 'bl-text'
      @vid = '8f7wj_RcqYk'
      @videoType = 'TEST'

      @clippy = new VideoClipper
        textareaID: textareaID
        videoId: @vid
        videoType: @videoType
        buttonID: @testID

    describe "with a type of 'generate' ", ->
      beforeEach ->
        dataString = VideoClipper.generateBLDataString 'generate', @clippy
        @blData = $.parseJSON dataString

      it 'should create a JSON string with a type of generate', ->
        expect(@blData.type).toEqual "generate"

      it 'should use the vid of the instance in the JSON string', ->
        expect(@blData.video.id).toEqual @vid

      it 'should use the type of the instance in the JSON string', ->
        expect(@blData.video.type).toEqual @videoType


    describe "with a type of 'show", ->
      beforeEach ->
        @startTime = '200'
        @endTime = '300'

        @clippy.startTime = @startTime
        @clippy.endTime = @endTime

        dataString = VideoClipper.generateBLDataString 'show', @clippy
        @blData = $.parseJSON dataString

      it 'should create a JSON string with a type of show', ->
        expect(@blData.type).toEqual "show"

      it 'should use the vid of the instance in the JSON string', ->
        expect(@blData.video.id).toEqual @vid

      it 'should use the type of the instance in the JSON string', ->
        expect(@blData.video.type).toEqual @videoType

      it 'should use the start time of the instance in the JSON string', ->
        expect(@blData.start).toEqual @startTime

      it 'should use the end time of the instance in the JSON string', ->
        expect(@blData.end).toEqual @endTime

    describe "without an incorrect type", ->

      it "should return an empty string", ->
        expect(VideoClipper.generateBLDataString 'incorrect', @clippy).toEqual ""
  
  describe "#getCaretPosition", ->

    it 'should check to see if there is a window selection', ->
      spyOn(window, 'getSelection').andReturn false
      expect(window.getSelection).toHaveBeenCalled()

    describe 'and the window selection exists', ->
      it 'should get the window selection', ->
        spyOn(window, 'getSelection').andReturn false
        expect(window.getSelection).toHaveBeenCalled()


  describe "when stripping html", ->
    beforeEach ->
      @elementHtml = '<a rel="blModal" href="#bl-vid" class="bl">%7B%22start%22:%20%2243.92%22,%20%22end%22:%20%22330%22,%20%22type%22:%20%22show%22,%20%22modal%22:%20%22#bl-vid%22,%20%22video%22:%20%7B%22id%22:%20%228f7wj_RcqYk%22,%20%22type%22:%20%22YT%22%7D%7D</a>'

    it "should create a div", ->
      spyOn(document, "createElement").andCallThrough()
      VideoClipper.stripHTML(@elementHtml)
      expect(document.createElement).toHaveBeenCalledWith("DIV")

    it "should put the html into the div's innerHTML", ->
      expect('pending').toEqual('completed')

    it "should return div's textContent or innerText", ->
      expect('pending').toEqual('completed')

