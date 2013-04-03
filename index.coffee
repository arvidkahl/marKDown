# > index.coffee
{MainView} = Kodepad.Views
do ->
  loader = new KDView
    cssClass: "marKDown loading"
    partial : "Loading marKDown..."

  #appView.addSubView loader
  #require ["ace/ace"], (Ace)->
    #appView.removeSubView loader
    #appView.addSubView new MainView
      #cssClass: "marKDown"
      #ace: Ace
  KD.enableLogs()
  console.log 'MEW'
  
  markdownModal = new KDModalView
    width : window.innerWidth-100
    height : window.innerHeight-100
    overlay : no
    title : 'marKDown editor'
    buttons:
        Yes:
            loader:
                color: "#ffffff"
                diameter: 16
            style: "modal-clean-gray"
            callback: ->
                new KDNotificationView
                    title: "Clicked yes!"
                markdownModal.destroy()
        No:
            loader:
                color: "#ffffff"
                diameter: 16
            style: "modal-clean-gray"
            callback: ->
                new KDNotificationView
                    title: "Clicked no!"
                markdownModal.destroy()
  
  markdownModal.addSubView loader
  require ["ace/ace"], (Ace)->
    markdownModal.removeSubView loader
    markdownModal.addSubView new MainView
      cssClass: "marKDown"
      ace: Ace
    markdownModal.$('.kdmodal-content').height window.innerHeight-100