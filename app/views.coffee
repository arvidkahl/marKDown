{Settings, Ace}   = Kodepad
{LiveViewer, AppCreator, HelpView} = Kodepad.Core
{log} = console
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
    
    @preview = new KDView
      cssClass: "preview-pane"
      
    @liveViewer.setPreviewView @preview
    
    @editor = new Editor
      defaultValue: Settings.exampleCodes[0].markdown
      callback: =>
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
      sizes     : ["10%","90%"]
      views     : [@mdHelpView,@aceWrapperView]

    
    #@editorSplitView.addSubView @aceWrapperView

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

    @splitView = new KDSplitView
      cssClass  : "kodepad-editors"
      type      : "vertical"
      resizable : yes
      sizes     : ["50%", "50%"]
      views     : [@editorSplitView, @preview]
      
        
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
    
    @controlButtons = new KDView
      cssClass    : 'header-buttons'
        
    #@controlButtons.addSubView new KDButtonViewWithMenu
      #cssClass        : 'clean-gray editor-button control-button save-as-kdapp'
      #title           : "Save"
      #menu            : =>
        #"Save as GitHub Gist...":
          #callback    : =>
            #
            #coffee    = @ace.getSession().getValue()
            #
            #new KDNotificationView 
              #title: "Kodepad is creating your Gist..."
              #
            #AppCreator.getSingleton().createGist coffee, '', (err, res)->
              #if err
                #new KDNotificationView 
                  #title: "An error occured while creating gist, try again."
                  #
              #modal = new KDModalView
                #overlay : yes
                #title     : "Your Gist is ready!"
                #content   : """
                                #<div class='modalformline'>
                                  #<p><b>#{res.html_url}</b></p>
                                #</div>
                            #"""
                #buttons     :
                  #"Open Gist":
                    #cssClass: "modal-clean-green"
                    #callback: ->
                      #window.open res.html_url, "_blank"
                      #
        #"Load from GitHub Gist...":
          #callback: =>
            #modal = new KDModalViewWithForms
              #overlay : yes
              #title   : "Load from Gist URL"
              #content : """
                #<div class='modalformline'>
                  #<p>
                    #You can load a gist as an application and run it in Kodepad.
                    #The gist must contain <code>index.coffee</code> and <code>style.css</code> files.
                  #</p>
                  #<p>
                      #The gist code you are going to load can reach (and modify) all of your files, settings and 
                      #all other information you shared with Koding. If you don't know what you are doing, 
                      #it's <strong>not recommended</strong> to run external code on Kodepad.
                  #</p>
                #</div>
              #"""
              #tabs                    :
                #navigable             : yes
                #forms                 :
                  #"Gist URL"          :
                    #fields            :
                      #url             :
                        #label         : "Gist URL: "
                        #name          : "url"
                        #placeholder   : "enter a gist url..."
                        #validate      :
                          #rules       :
                            #regExp    : /^https?:\/\/gist\.github\.com\//
                          #messages    :
                            #regExp    : "You must enter a real gist url."
                    #buttons           :
                      #"I know the risks, load and run":
                        #cssClass      : "modal-clean-gray"
                        #callback      : =>
                          #
                          #if not modal.modalTabs.forms["Gist URL"].inputs.url.validate()
                            #return
                            #
                          #url = modal.modalTabs.forms["Gist URL"].inputs.url.getValue()
                          #
                          #url = url.replace /^.*\/(\d+)$/g, 'https://api.github.com/gists/$1'
                          #
                          #notify = new KDNotificationView
                            #title : "Loading Gist..."
                            #
                          #kite = KD.getSingleton "kiteController"
                          #kite.run "curl -kL #{url}", (error, data) =>
                            #try data = JSON.parse data
                            #
                            #debugger
                            #
                            #if not error
                              #@ace.getSession().setValue data.files["index.coffee"].content
                              #
                              #notify.destroy()
                              #modal.destroy()
                              #notify = new KDNotificationView
                                #title : "Gist Loaded!"
                            #else
                              #notify = new KDNotificationView
                                #title : "Try again. :("
                #
      #
      #callback: =>
        #modal = new KDModalViewWithForms
          #title                     : "Save Application"
          #content                   : """
              #<div class='modalformline'>
                #<p>You can build an application using Kodepad. Please set your application up.</p>
                #<p>Don't forget to edit <code>.manifest</code> file in your application directory.</p>
              #</div>
          #"""
          #overlay                   : yes
          #height                    : "auto"
          #tabs                      :
            #navigable               : yes
            #forms                   : 
              #"Settings": 
                #fields              : 
                  #name              :
                    #label           : "Name: "
                    #name            : "name"
                    #placeholder     : "name your application..."
                    #validate        :
                      #rules         :
                        #regExp      : /^[a-z\d]+([-][a-z\d]+)*$/i
                      #messages      :
                        #regExp      : "For Application name only lowercase letters and numbers are allowed!"
                #buttons             :
                  #"Save":
                    #cssClass        : "modal-clean-gray"
                    #callback        : =>
                      #
                      #if not modal.modalTabs.forms.Settings.inputs.name.validate()
                        #return
                      #
                      #name      = modal.modalTabs.forms.Settings.inputs.name.getValue()
                      #
                      #coffee    = @ace.getSession().getValue()
                      #
                      #notify = new KDNotificationView
                        #title : "Application #{name} is being created now..."
                      #
                      #AppCreator.getSingleton().create name, coffee, '', ->
                        #
                        #notify.destroy()
                        #modal.destroy()
                        #new KDNotificationView
                          #title : "Your application #{name} is ready! Have fun. :)"
    
    #@controlButtons.addSubView new KDButtonView
      #cssClass    : 'clean-gray editor-button control-button full-preview'
      #title       : ""
      #icon        : yes
      #iconOnly    : yes
      #iconClass   : "preview"
      #callback    : =>
        #@splitView.state = !@splitView.state
        #if @splitView.state
          #@splitView.resizePanel()
          #KD.utils.wait 500, =>
            #@editor.getView().domElement.trigger "keyup"
        #else
          #($ window).trigger "resize"
          
    #toggleTransparency = new KDToggleButton
      #style       : "kdwhitebtn"
      #cssClass    : "clean-gray editor-button control-button transp"
      #states      : [
        #"Transparent", (callback)=>
          #@preview.domElement.addClass 'transparented'
          #toggleTransparency.domElement.addClass 'transparented'
          #do callback
        #"Opaque", (callback)=>
          #@preview.domElement.removeClass 'transparented'
          #toggleTransparency.domElement.removeClass 'transparented'
          #do callback
      #]   
#
    #@controlButtons.addSubView toggleTransparency
    #
    #runApp = (appName)-> 
      #appController = KD.getSingleton "kodingAppsController"
      #appManifest = appController.constructor.manifests[appName]
      #if appManifest
        #appController.runApp appManifest
        #return true
      #else
        #return false
    #
    #@controlButtons.addSubView new KDButtonView
      #cssClass    : "clean-gray editor-button control-button"
      #title       : ""
      #icon        : yes
      #iconOnly    : yes
      #iconClass   : "docs"
      #callback: =>
        #docsApp = runApp "Koding Docs"
        #if not docsApp 
          #new KDNotificationView
            #title: "Koding Docs is not installed!"
            #content: "This button is a shortcut to run Koding Docs, so you must install it."
              
    @controlButtons.addSubView new KDMultipleChoice
      cssClass    : "clean-gray editor-button control-button auto-manual"
      labels      : ["Auto-Update", "Manual"]
      defaultValue: "Auto-Update"
      callback    : (state)=>
        @liveViewer.active = if state is "Auto-Update" then yes else no
        if state is "Auto-Update"
          @liveViewer.previewCode do @editor.getValue
    
    @controlButtons.addSubView new KDMultipleChoice
      cssClass    : "clean-gray editor-button control-button scroll-switch"
      labels      : ["Auto-Scroll", "Manual"]
      defaultValue: "Auto-Scroll"
      callback    : (state)=>
        @autoScroll = state is "Auto-Scroll"
            
    @formatButtons = new KDView
      cssClass    : 'header-format-buttons'
    
    @formatButtons.addSubView boldButton = new KDButtonView
      cssClass    : "clean-gray editor-button control-button bold"
      title       : "B"
      #icon        : yes
      #iconOnly    : yes
      #iconClass   : "bold"
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
    
    boldButton.on 'mouseenter', =>
        @mdHelpView.emit 'bold'
    
    boldButton.on 'mouseleave', =>
        @mdHelpView.setDefault()

    @formatButtons.addSubView italicButton = new KDButtonView
      cssClass    : "clean-gray editor-button control-button italic"
      title       : "I"
      #icon        : yes
      #iconOnly    : yes
      #iconClass   : "italic"
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
    italicButton.on 'mouseenter', =>
        @mdHelpView.emit 'italic'
    
    italicButton.on 'mouseleave', =>
        @mdHelpView.setDefault()
        
      
    @controlView.addSubView @formatButtons
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
    {{> @splitView}}
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