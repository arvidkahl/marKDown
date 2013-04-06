{Settings, Ace}   = Kodepad
{LiveViewer, AppCreator, HelpView} = Kodepad.Core

class Kodepad.Views.Editor
  constructor: (options)->
    
    @view = new KDView
      tagName: "textarea"
    
    @view.domElement.css
      "font-family": "monospace"
    
    @setValue options.defaultValue if options.defaultValue
    @view.domElement.keyup options.callback if options.callback
    
  setValue: (value)-> @view.domElement.html value
  
  getValue: -> @view.domElement.val()
  
  getView: -> @view
  
  getElement: -> @view.domElement.get 0

class Kodepad.Views.MainView extends JView

  {Editor,HelpView} = Kodepad.Views
  
  constructor: ()->
    super
    @liveViewer = LiveViewer.getSingleton()
    @listenWindowResize()
    
    @autoScroll = yes
    
  delegateElements:->

    @splitViewWrapper = new KDView
    

    # OVERFLOW FIX
    overflowFix = ->
      height = ($ ".kdview.marKDown").height() - 39
      ($ ".kodepad-editors").height height
      #
    ($ window).on "resize", overflowFix
    # window.ace = [@ace, @cssAce]
    # SHOULD REPLACE WITH LEGAL RESIZE LISTENER
    do =>
      lastAceHeight = 0
      lastAceWidth = 0
      setInterval =>
        aceHeight = @aceView.getHeight()
        aceWidth = @aceView.getWidth()
        
        if aceHeight isnt lastAceHeight or aceWidth isnt lastAceWidth
          @ace.resize()
          lastAceHeight = @aceView.getHeight()
          lastAceWidth = @aceView.getWidth()
      , 20
    
    addSplitView = (type,content,selection,width,height)=>

      if @splitView
        # remove prior version of splitview
        @splitView.off 'drop'
        @splitViewWrapper.destroySubViews() 

        # and get rid of the old md preview
        @liveViewer.mdPreview.destroy()
        @liveViewer.mdPreview= null
        delete @liveViewer.mdPreview

      @preview = new KDView
        cssClass: "preview-pane"
      
      @liveViewer.setPreviewView @preview
    

      @editor = new Editor
        defaultValue: content or Settings.exampleCodes[0].markdown
        callback: =>
          console.log 'le preview?'
          @liveViewer.previewCode do @editor.getValue
      @editor.getView().hide()
        
      @aceView = new KDView
      cssClass: 'editor code-editor'

      @aceWrapperView = new KDView
      cssClass : 'ace-wrapper-view'
    
      @aceWrapperView.addSubView @aceView

      @mdHelpView = new HelpView
      cssClass : 'md-help-view'

      @editorSplitView = new KDSplitView
        type      : "horizontal"
        resizable : yes
        sizes     : ["100%"]
        views     : [@aceWrapperView]    

      @splitView = new KDSplitView
        cssClass  : "kodepad-editors"
        type      : type or "vertical"
        resizable : yes
        sizes     : [width or "50%", height or "50%"]
        views     : [@editorSplitView, @preview]
        bind      : 'drop dragenter dragover dragleave'

      @splitViewWrapper.addSubView @splitView
      
      @buildAce()
      
      @utils.defer => 
        if selection then @ace.getSession().getSelection().setSelectionRange selection.getRange()
        @liveViewer.previewCode do @editor.getValue

      @splitView.on 'ResizeDidStop', =>
        @ace?.resize()
      
      @splitView.on 'drop', (event)=>
        console.log arguments
        console.log 'item was dropped'
        event.stopPropagation()
        event.preventDefault()
        dataTransfer = event?.originalEvent?.dataTransfer
        
        if dataTransfer
          types = dataTransfer.types
          console.log types
          text = ""
          
          if "text/uri-list" in types
            uri = dataTransfer.getData 'text/uri-list'
            unless /\.(jpe?g|png|gif|ico)/.test uri
              text += """[#{uri}](#{uri})"""
            else text += """![#{uri}](#{uri})"""
            
            # now here is a hack  if I ever saw one. catch the insert, delete it again! 
            @ace.getSession().remove @ace.getSession().getSelection().getRange()
            
          if "Files" in types and files = dataTransfer.files
            console.log 'files exist, they will be uploaded here'
            if files.length then for file in files
              text += """![#{file.name}](#{file.name})"""
          
          # needs to be deferred so we can remove prior pastes
          @utils.defer => if text.length
            @ace.session.insert(@ace.renderer.screenToTextCoordinates(event.originalEvent.clientX,event.originalEvent.clientY),text)
      
    addSplitView 'vertical'
    
    @controlButtons = new KDView
      cssClass    : 'header-buttons'
   
    @controlButtons.addSubView @orientationButtons = new KDButtonGroupView
      cssClass : 'orientation-buttons fr'
      buttons : 
        'FullEditor' :
          title : 'full-editor'
          cssClass : 'clean-gray  full-editor'
          icon : yes
          iconOnly : yes
          tooltip :
            title : 'Full Editor'
          callback :=>
            addSplitView 'vertical', @ace.getSession().getValue(), @ace.getSession().getSelection(), '100%', '0%'
            @utils.wait 200, => @ace.resize()
                            
        'FullPreview' :
          title : 'full-preview'
          cssClass : 'clean-gray  full-preview'
          icon : yes
          iconOnly : yes
          tooltip :
            title : 'Full Preview'
          callback :=>
            addSplitView 'vertical', @ace.getSession().getValue(), @ace.getSession().getSelection(), '0%', '100%'
            @utils.wait 200, => @ace.resize()
                    
        'V5' :
          title : 'v5'
          cssClass : 'clean-gray  v5'
          icon : yes
          iconOnly : yes
          tooltip :
            title : 'Split vertically'
          callback :=>
            addSplitView 'vertical', @ace.getSession().getValue(), @ace.getSession().getSelection(), '50%', '50%'
            @utils.wait 200, => @ace.resize()
            
        'V3' :
          title:'v3'
          cssClass : 'clean-gray  v3'
          icon : yes
          iconOnly : yes
          tooltip :
            title : 'Split vertically, with a larger Preview'
          callback :=>
            addSplitView 'vertical', @ace.getSession().getValue(), @ace.getSession().getSelection(), '30%', '70%'
            @utils.wait 200, => @ace.resize()

        'H5' :
          title : 'h5'
          cssClass : 'clean-gray  h5'
          icon : yes
          iconOnly : yes
          tooltip :
            title : 'Split horizontally'
          callback :=>
            addSplitView 'horizontal', @ace.getSession().getValue(), @ace.getSession().getSelection(), '50%', '50%'   
            @utils.wait 200, => @ace.resize()
        'H3' :
          title : 'h3'
          cssClass : 'clean-gray  h3'
          icon : yes
          iconOnly : yes
          tooltip :
            title : 'Split horizontally, with a larger Preview'
          callback :=>
            addSplitView 'horizontal', @ace.getSession().getValue(), @ace.getSession().getSelection(), '30%', '70%'
            @utils.wait 200, => @ace.resize()

   
    #@controlButtons.addSubView new KDButtonView
      #cssClass    : 'clean-gray editor-button control-button full-preview'
      #title       : ""
      #icon        : yes
      #iconOnly    : yes
      #iconClass   : "preview"
      #callback    : =>
        #newType = if @splitView.isVertical() then 'horizontal' else 'vertical'
        #addSplitView newType, @ace.getSession().getValue(), @ace.getSession().getSelection()#, '20%', '80%'
#
        #@utils.wait 200, => @ace.resize()


    @controlView = new KDView
      cssClass: 'control-pane editor-header'
      
    @exampleCode = new KDSelectBox
      label: new KDLabelView
        title: 'markdown Examples: '
        
      defaultValue: @lastSelectedItem or "0"
      cssClass: 'control-button code-examples'
      selectOptions: ({title: item.title, value: key} for item, key in Kodepad.Settings.exampleCodes)
      callback: =>
        @lastSelectedItem = @exampleCode.getValue()        
        {markdown} = Kodepad.Settings.exampleCodes[@lastSelectedItem]
        @ace.getSession().setValue markdown


        
    @controlButtons.addSubView new KDMultipleChoice
      cssClass    : "clean-gray editor-button control-button auto-manual"
      labels      : ["Update", "Manual"]
      defaultValue: "Update"
      tooltip:
        title : 'When switched on, the Preview will update on every keypress'
      callback    : (state)=>
        @liveViewer.active = if state is "Update" then yes else no
        if state is "Update"
          @liveViewer.previewCode do @editor.getValue
    
    @controlButtons.addSubView new KDMultipleChoice
      cssClass    : "clean-gray editor-button control-button scroll-switch"
      labels      : ["Scroll", "Manual"]
      defaultValue: "Scroll"
      tooltip : 
        title : 'When switched on, the Preview will scroll alongside the editor'
      callback    : (state)=>
        @autoScroll = state is "Scroll"
    
    @formatButtons = new KDButtonGroupView
      cssClass    : 'header-format-buttons'
      buttons: 
       'Bold'     :
          cssClass    : "clean-gray bold"
          title       : "B"
          icon        : yes
          iconOnly    : yes
          tooltip     :
            title     : 'Bold   **Text**'
          bind        : 'mouseenter mouseleave'
          callback: =>   
            range = @ace.selection.getRange()
            @ace.session.replace range, "**#{@ace.getCopyText()}**"
        
            @ace.selection.setSelectionRange
              start : 
                column : range.start.column+2
                row    : range.start.row
              end   : 
                column : range.end.column+2
                row    : range.end.row  
        
            @ace.focus()


        'Italic' :
          cssClass    : "clean-gray italic"
          title       : "I"
          icon        : yes
          iconOnly    : yes
          tooltip     :
            title     : 'Italic   *Text*'     
          bind        : 'mouseenter mouseleave'
          callback: =>   
            range = @ace.selection.getRange()
        
            @ace.session.replace range, "*#{@ace.getCopyText()}*"

            @ace.selection.setSelectionRange
              start : 
                column : range.start.column+1
                row    : range.start.row
              end   : 
                column : range.end.column+1
                row    : range.end.row
              
            @ace.focus()        

        'Link' :
          cssClass    : "clean-gray link"
          title       : "Link"
          icon        : yes
          iconOnly    : yes
          tooltip     :
            title     : 'Link   [Title](URL "Optional Title")'     
          bind        : 'mouseenter mouseleave'
          callback: =>   
            range = @ace.selection.getRange()
        
            @ace.session.replace range, """[#{@ace.getCopyText() or 'Link Text'}](#{@ace.getCopyText() or 'Link_URL "Link Title"'})"""
            @ace.focus()     
          
        'Image' :
          cssClass    : "clean-gray image"
          title       : "Image"
          icon        : yes
          iconOnly    : yes
          tooltip     :
            title     : 'Image    ![Alt Text](URL "Optional Title")'     
          bind        : 'mouseenter mouseleave'
          callback: =>   
            range = @ace.selection.getRange()
        
            @ace.session.replace range, """![#{@ace.getCopyText() or 'Alt Text'}](#{@ace.getCopyText() or 'Image_URL "Optional Title"'})"""
            @ace.focus()     
              
        'Inline' :
          cssClass    : "clean-gray inline"
          title       : "Inline Code"
          icon        : yes
          iconOnly    : yes
          tooltip     :
            title     : 'Inline Code    `Code`'     
          bind        : 'mouseenter mouseleave'
          callback: =>   
            range = @ace.selection.getRange()
        
            @ace.session.replace range, """`#{@ace.getCopyText() or 'Inline Code'}`"""
            @ace.focus()     
    
    formatCode = (syntax)=>
        range = @ace.selection.getRange()
        
        @ace.session.replace range, """```#{syntax}\n#{@ace.getCopyText() or 'Code Block'}\n```"""
        @ace.focus()     

    codeButton = new KDButtonViewWithMenu
      cssClass    : "clean-gray  code"
      title       : "Code Block"
      icon        : yes
      iconOnly    : yes
      tooltip     :
        title     : 'Code Block    ```language-name   Code  ```'     
      bind        : 'mouseenter mouseleave'
      menu :=>
        'JavaScript' :  
          callback: => 
             formatCode 'js'
        
        'Ruby' :  
          callback: => 
             formatCode 'ruby'   
             
        'Python' :  
          callback: => 
             formatCode 'python'
        
      callback : =>
          formatCode 'language-name-here'
        
      
    @controlView.addSubView @formatButtons
    @controlView.addSubView codeButton
    
    @controlView.addSubView @exampleCode.options.label
    @controlView.addSubView @exampleCode
    @controlView.addSubView @controlButtons
    
    @liveViewer.setSplitView @splitView
    @liveViewer.setMainView @
    
    @liveViewer.previewCode do @editor.getValue
    @utils.defer => ($ window).resize()
    @utils.wait 50, => 
        ($ window).resize()
        @ace?.resize()
    @utils.wait 1000, =>
    
      @ace.renderer.scrollBar.on 'scroll', =>
          if @autoScroll is yes
            @setPreviewScrollPercentage @getEditScrollPercentage()

  getEditScrollPercentage:->

      scrollPosition    = @ace.renderer.scrollTop
      scrollHeight      = @aceView.getHeight()
      scrollMaxHeight   =  @ace.getSession().getDocument().getLength() *@ace.renderer.lineHeight

      scrollPosition / (scrollMaxHeight- scrollHeight) * 100

  setPreviewScrollPercentage:(percentage)->
  
    s = @liveViewer.mdPreview.$()
      
    s.animate
     scrollTop : ((s[0].scrollHeight - s.height())*percentage/100)
    , 50, "linear"
    
  
  pistachio: -> 
    """
    {{> @controlView}}
    {{> @editor.getView()}}
    {{> @splitViewWrapper}}
    """
  buildAce: ->
    ace = @getOptions().ace
    try
      
      update = KD.utils.throttle =>
        @editor.setValue @ace.getSession().getValue()
        @editor.getView().domElement.trigger "keyup"
      , Settings.aceThrottle
      
      @ace = ace.edit @aceView.domElement.get 0
      @ace.setTheme Settings.theme
      @ace.getSession().setMode "ace/mode/markdown"
      @ace.getSession().setTabSize 2
      @ace.getSession().setUseSoftTabs true
      @ace.getSession().setValue @editor.getValue()
      @ace.getSession().on "change", -> do update
            
      @editor.setValue @ace.getSession().getValue()
      @ace.commands.addCommand
        name    : 'save'
        bindKey :
          win   : 'Ctrl-S'
          mac   : 'Command-S'
        exec    : => 
          @editor.setValue @ace.getSession().getValue()
      
  viewAppended:->
    @delegateElements()
    @setTemplate do @pistachio
    @buildAce()