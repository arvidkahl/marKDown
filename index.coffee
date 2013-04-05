# > index.coffee
{MainView} = Kodepad.Views
do ->
  
  KD.enableLogs()

  console.log 'Development version of marKDown starting...'  
    
  loader     = new KDView
    cssClass : "marKDown loading"
    partial  : "Loading marKDown..."  
  
  mainView = {}
  
  markdownModal    = new KDModalView
    width          : window.innerWidth-100
    height         : window.innerHeight-100
    overlay        : no
    title          : 'marKDown Editor'
    buttons        :
      Yes          :
        loader     :
          color    : "#ffffff"
          diameter : 16
        style      : "modal-clean-gray"
        callback   : ->
          new KDNotificationView
            title  : "Clicked yes!"
          
          value = mainView.ace.getSession().getValue()
          console.log value
          
          markdownModal.destroy()
          return value
      No           :
        loader     :
          color    : "#ffffff"
          diameter : 16
        style      : "modal-clean-gray"
        callback   : ->
          new KDNotificationView
            title  : "Clicked no!"          
          
          value = mainView.ace.getSession().getValue()
          console.log value
          
          markdownModal.destroy()
          return value
          
  markdownModal.addSubView loader
    
  require ["ace/ace"], (Ace)->
    mainView   = new MainView
      cssClass : "marKDown"
      ace      : Ace

    markdownModal.removeSubView loader
    markdownModal.addSubView mainView
    markdownModal.$('.kdmodal-content').height window.innerHeight-95