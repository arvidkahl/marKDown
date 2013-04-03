// Compiled by Koding Servers at Wed Apr 03 2013 01:15:16 GMT-0700 (PDT) in server time

(function() {

/* KDAPP STARTS */

/* BLOCK STARTS /Source: /Users/arvidkahl/Applications/marKDown.kdapp/app/settings.coffee */

var Kodepad;

Kodepad = {
  Settings: {
    theme: "ace/theme/monokai",
    exampleCode: null,
    exampleCSS: null,
    aceThrottle: 400
  },
  Core: {
    Utils: null,
    LiveViewer: null,
    AppCreator: null
  },
  Views: {
    Editor: null,
    MainView: null
  }
};

Kodepad.Settings.exampleCodes = [];

/*
# Sample Example
*/


Kodepad.Settings.exampleCodes.push({
  title: "Sample",
  markdown: "An h1 header\n============\n\nParagraphs are separated by a blank line.\n\n2nd paragraph. *Italic*, **bold**, `monospace`. Itemized lists\nlook like:\n\n  * this one\n  * that one\n  * the other one\n\nNote that --- not considering the asterisk --- the actual text\ncontent starts at 4-columns in.\n\n> Block quotes are\n> written like so.\n>\n> They can span multiple paragraphs,\n> if you like.\n\nUse 3 dashes for an em-dash. Use 2 dashes for ranges (ex. \"it's all in\nchapters 12--14\"). Three dots ... will be converted to an ellipsis.\n\n\n\nAn h2 header\n------------\n\nHere's a numbered list:\n\n 1. first item\n 2. second item\n 3. third item\n\nNote again how the actual text starts at 4 columns in (4 characters\nfrom the left side). Here's a code sample:\n\n    # Let me re-iterate ...\n    for i in 1 .. 10 { do-something(i) }\n\nAs you probably guessed, indented 4 spaces. By the way, instead of\nindenting the block, you can use delimited blocks, if you like:\n\n~~~\ndefine foobar() {\n    print \"Welcome to flavor country!\";\n}\n~~~\n\n(which makes copying & pasting easier). You can optionally mark the\ndelimited block for Pandoc to syntax highlight it:\n\n~~~python\nimport time\n# Quick, count to ten!\nfor i in range(10):\n    # (but not *too* quick)\n    time.sleep(0.5)\n    print i\n~~~\n\n\n\n### An h3 header ###\n\nNow a nested list:\n\n 1. First, get these ingredients:\n\n      * carrots\n      * celery\n      * lentils\n\n 2. Boil some water.\n\n 3. Dump everything in the pot and follow\n    this algorithm:\n\n        find wooden spoon\n        uncover pot\n        stir\n        cover pot\n        balance wooden spoon precariously on pot handle\n        wait 10 minutes\n        goto first step (or shut off burner when done)\n\n    Do not bump wooden spoon or it will fall.\n\nNotice again how text always lines up on 4-space indents (including\nthat last line which continues item 3 above). Here's a link to [a\nwebsite](http://foo.bar). Here's a link to a [local\ndoc](local-doc.html). Here's a footnote [^1].\n\n[^1]: Footnote text goes here.\n\nTables can look like this:\n\nsize  material      color\n----  ------------  ------------\n9     leather       brown\n10    hemp canvas   natural\n11    glass         transparent\n\nTable: Shoes, their sizes, and what they're made of\n\n(The above is the caption for the table.) Here's a definition list:\n\napples\n  : Good for making applesauce.\noranges\n  : Citrus!\ntomatoes\n  : There's no \"e\" in tomatoe.\n\nAgain, text is indented 4 spaces. (Alternately, put blank lines in\nbetween each of the above definition list lines to spread things\nout more.)\n\nInline math equations go in like so: $\omega = d\phi / dt$. Display\nmath should get its own line and be put in in double-dollarsigns:\n\n$$I = \int \rho R^{2} dV$$\n\nDone.\n"
});


/* BLOCK ENDS */



/* BLOCK STARTS /Source: /Users/arvidkahl/Applications/marKDown.kdapp/app/core.coffee */


Kodepad.Core.Utils = (function() {
  var _this = this;

  function Utils() {}

  Utils.notify = function(message) {
    var _ref;
    if ((_ref = Utils.instance) != null) {
      _ref.destroy();
    }
    return Utils.instance = new KDNotificationView({
      type: "mini",
      title: message
    });
  };

  return Utils;

}).call(this);

Kodepad.Core.LiveViewer = (function() {
  var notify;

  notify = Kodepad.Core.Utils.notify;

  LiveViewer.getSingleton = function() {
    var _ref;
    return (_ref = LiveViewer.instance) != null ? _ref : LiveViewer.instance = new LiveViewer;
  };

  LiveViewer.prototype.active = true;

  LiveViewer.prototype.pistachios = /\{(\w*)?(\#\w*)?((?:\.\w*)*)(\[(?:\b\w*\b)(?:\=[\"|\']?.*[\"|\']?)\])*\{([^{}]*)\}\s*\}/g;

  function LiveViewer() {
    this.sessionId = KD.utils.uniqueId("kodepadSession");
  }

  LiveViewer.prototype.setPreviewView = function(previewView) {
    this.previewView = previewView;
  };

  LiveViewer.prototype.setSplitView = function(splitView) {
    this.splitView = splitView;
  };

  LiveViewer.prototype.setMainView = function(mainView) {
    this.mainView = mainView;
  };

  LiveViewer.prototype.previewCode = function(code, options) {
    var _this = this;
    if (options == null) {
      options = {};
    }
    if (!this.active) {
      return;
    }
    return require(["https://raw.github.com/chjj/marked/master/lib/marked.js"], function(marked) {
      var md, _ref, _ref1, _ref2, _ref3, _ref4;
      window.appView = _this.previewView;
      try {
        if ((_ref = options.gfm) == null) {
          options.gfm = true;
        }
        if ((_ref1 = options.sanitize) == null) {
          options.sanitize = true;
        }
        if ((_ref2 = options.highlight) == null) {
          options.highlight = function(code, lang) {
            window.console.log(hljs);
            try {
              return hljs.highlight(lang, code).value;
            } catch (e) {
              try {
                return hljs.highlightAuto(code).value;
              } catch (_e) {
                return code;
              }
            }
          };
        }
        if ((_ref3 = options.breaks) == null) {
          options.breaks = true;
        }
        if ((_ref4 = options.langPrefix) == null) {
          options.langPrefix = 'lang-';
        }
        marked.setOptions(options);
        md = marked(code);
        if (!_this.mdPreview) {
          return _this.previewView.addSubView(_this.mdPreview = new KDView({
            cssClass: 'has-markdown markdown-preview',
            partial: md
          }));
        } else {
          return _this.mdPreview.updatePartial(md);
        }
      } catch (error) {
        return notify(error.message);
      } finally {
        delete window.appView;
      }
    });
  };

  LiveViewer.prototype.previewCSS = function(code) {
    var css, session;
    if (!this.active) {
      return;
    }
    session = "__kodepadCSS" + this.sessionId;
    if (window[session]) {
      try {
        window[session].remove();
      } catch (_error) {}
    }
    css = $("<style scoped></style>");
    css.html(code);
    window[session] = css;
    return this.previewView.domElement.prepend(window[session]);
  };

  return LiveViewer;

}).call(this);

Kodepad.Core.AppCreator = (function() {
  var notify;

  function AppCreator() {}

  notify = Kodepad.Core.Utils.notify;

  AppCreator.getSingleton = function() {
    var _ref;
    return (_ref = AppCreator.instance) != null ? _ref : AppCreator.instance = new AppCreator;
  };

  AppCreator.prototype.manifestTemplate = function(appName) {
    var firstName, lastName, nickname, _ref;
    _ref = KD.whoami().profile, firstName = _ref.firstName, lastName = _ref.lastName, nickname = _ref.nickname;
    return {
      manifest: "{\n  \"devMode\": true,\n  \"version\": \"0.1\",\n  \"name\": \"" + appName + "\",\n  \"identifier\": \"com.koding." + nickname + ".apps." + (appName.toLowerCase()) + "\",\n  \"path\": \"~/Applications/" + appName + ".kdapp\",\n  \"homepage\": \"" + nickname + ".koding.com/" + appName + "\",\n  \"author\": \"" + firstName + " " + lastName + "\",\n  \"repository\": \"git://github.com/" + nickname + "/" + appName + ".kdapp.git\",\n  \"description\": \"" + appName + " : a Koding application created with the Kodepad.\",\n  \"category\": \"web-app\",\n  \"source\": {\n    \"blocks\": {\n      \"app\": {\n        \"files\": [\n          \"./index.coffee\"\n        ]\n      }\n    },\n    \"stylesheets\": [\n      \"./resources/style.css\"\n    ]\n  },\n  \"options\": {\n    \"type\": \"tab\"\n  },\n  \"icns\": {\n    \"128\": \"./resources/icon.128.png\"\n  }\n}"
    };
  };

  AppCreator.prototype.create = function(name, coffee, css, callback) {
    var appPath, basePath, coffeeFile, commands, cssFile, finder, kite, manifest, manifestFile, nickname, skeleton, tree;
    manifest = this.manifestTemplate(name).manifest;
    nickname = KD.whoami().profile.nickname;
    kite = KD.getSingleton('kiteController');
    finder = KD.getSingleton("finderController");
    tree = finder.treeController;
    appPath = "/Users/" + nickname + "/Applications";
    basePath = "" + appPath + "/" + name + ".kdapp";
    coffeeFile = "" + basePath + "/index.coffee";
    cssFile = "" + basePath + "/resources/style.css";
    manifestFile = "" + basePath + "/.manifest";
    commands = ["mkdir -p " + basePath, "mkdir -p " + basePath + "/resources", "curl -kL https://koding.com/images/default.app.thumb.png -o " + basePath + "/resources/icon.128.png"];
    skeleton = commands.join(";");
    return kite.run(skeleton, function(error, response) {
      var coffeeFileInstance, cssFileInstance, manifestFileInstance;
      if (error) {
        return;
      }
      coffeeFileInstance = FSHelper.createFileFromPath(coffeeFile);
      coffeeFileInstance.save(coffee);
      cssFileInstance = FSHelper.createFileFromPath(cssFile);
      cssFileInstance.save(css);
      manifestFileInstance = FSHelper.createFileFromPath(manifestFile);
      manifestFileInstance.save(manifest);
      return KD.utils.wait(1000, function() {
        tree.refreshFolder(tree.nodes[appPath]);
        KD.getSingleton('kodingAppsController').refreshApps();
        return callback();
      });
    });
  };

  AppCreator.prototype.createGist = function(coffee, css, callback) {
    var gist, kite, nickname;
    nickname = KD.whoami().profile.nickname;
    gist = {
      description: "Kodepad Gist Share by " + nickname + " on http://koding.com\nAuthor: http://" + nickname + ".koding.com",
      "public": true,
      files: {
        "index.coffee": {
          content: coffee
        },
        "style.css": {
          content: css
        }
      }
    };
    kite = KD.getSingleton('kiteController');
    return kite.run("mkdir -p /Users/" + nickname + "/.kodepad", function(err, res) {
      var tmp, tmpFile;
      tmpFile = "/Users/" + nickname + "/.kodepad/.gist.tmp";
      tmp = FSHelper.createFileFromPath(tmpFile);
      return tmp.save(JSON.stringify(gist), function(err, res) {
        if (err) {
          return;
        }
        return kite.run("curl -kL -A\"Koding\" -X POST https://api.github.com/gists --data @" + tmpFile, function(err, res) {
          callback(err, JSON.parse(res));
          return kite.run("rm -f " + tmpFile);
        });
      });
    });
  };

  return AppCreator;

}).call(this);


/* BLOCK ENDS */



/* BLOCK STARTS /Source: /Users/arvidkahl/Applications/marKDown.kdapp/app/views.coffee */

var Ace, AppCreator, LiveViewer, Settings, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Settings = Kodepad.Settings, Ace = Kodepad.Ace;

_ref = Kodepad.Core, LiveViewer = _ref.LiveViewer, AppCreator = _ref.AppCreator;

Kodepad.Views.Editor = (function() {

  function Editor(options) {
    this.view = new KDView({
      tagName: "textarea"
    });
    this.view.domElement.css({
      "font-family": "monospace"
    });
    if (options.defaultValue) {
      this.setValue(options.defaultValue);
    }
    if (options.callback) {
      this.view.domElement.keyup(options.callback);
    }
  }

  Editor.prototype.setValue = function(value) {
    return this.view.domElement.html(value);
  };

  Editor.prototype.getValue = function() {
    return this.view.domElement.val();
  };

  Editor.prototype.getView = function() {
    return this.view;
  };

  Editor.prototype.getElement = function() {
    return this.view.domElement.get(0);
  };

  return Editor;

})();

Kodepad.Views.MainView = (function(_super) {
  var Editor;

  __extends(MainView, _super);

  Editor = Kodepad.Views.Editor;

  function MainView() {
    MainView.__super__.constructor.apply(this, arguments);
    this.liveViewer = LiveViewer.getSingleton();
  }

  MainView.prototype.delegateElements = function() {
    var item, key, overflowFix, runApp, toggleTransparency,
      _this = this;
    this.preview = new KDView({
      cssClass: "preview-pane"
    });
    this.liveViewer.setPreviewView(this.preview);
    this.editor = new Editor({
      defaultValue: Settings.exampleCodes[0].markdown,
      callback: function() {
        return _this.liveViewer.previewCode(_this.editor.getValue());
      }
    });
    this.editor.getView().hide();
    this.aceView = new KDView({
      cssClass: 'editor code-editor'
    });
    this.editorSplitView = new KDView;
    this.editorSplitView.addSubView(this.aceView);
    overflowFix = function() {};
    ($(window)).on("resize", overflowFix);
    (function() {
      var lastAceHeight, lastAceWidth;
      lastAceHeight = 0;
      return lastAceWidth = 0;
    })();
    this.splitView = new KDSplitView({
      cssClass: "kodepad-editors",
      type: "vertical",
      resizable: true,
      sizes: ["50%", "50%"],
      views: [this.editorSplitView, this.preview]
    });
    this.controlView = new KDView({
      cssClass: 'control-pane editor-header'
    });
    this.exampleCode = new KDSelectBox({
      label: new KDLabelView({
        title: 'Kode Examples: '
      }),
      defaultValue: this.lastSelectedItem || "0",
      cssClass: 'control-button code-examples',
      selectOptions: (function() {
        var _i, _len, _ref1, _results;
        _ref1 = Kodepad.Settings.exampleCodes;
        _results = [];
        for (key = _i = 0, _len = _ref1.length; _i < _len; key = ++_i) {
          item = _ref1[key];
          _results.push({
            title: item.title,
            value: key
          });
        }
        return _results;
      })(),
      callback: function() {
        var markdown;
        _this.lastSelectedItem = _this.exampleCode.getValue();
        markdown = Kodepad.Settings.exampleCodes[_this.lastSelectedItem].markdown;
        return _this.ace.getSession().setValue(markdown);
      }
    });
    this.controlButtons = new KDView({
      cssClass: 'header-buttons'
    });
    this.controlButtons.addSubView(new KDButtonViewWithMenu({
      cssClass: 'clean-gray editor-button control-button save-as-kdapp',
      title: "Save",
      menu: function() {
        return {
          "Save as GitHub Gist...": {
            callback: function() {
              var coffee;
              coffee = _this.ace.getSession().getValue();
              new KDNotificationView({
                title: "Kodepad is creating your Gist..."
              });
              return AppCreator.getSingleton().createGist(coffee, '', function(err, res) {
                var modal;
                if (err) {
                  new KDNotificationView({
                    title: "An error occured while creating gist, try again."
                  });
                }
                return modal = new KDModalView({
                  overlay: true,
                  title: "Your Gist is ready!",
                  content: "<div class='modalformline'>\n  <p><b>" + res.html_url + "</b></p>\n</div>",
                  buttons: {
                    "Open Gist": {
                      cssClass: "modal-clean-green",
                      callback: function() {
                        return window.open(res.html_url, "_blank");
                      }
                    }
                  }
                });
              });
            }
          },
          "Load from GitHub Gist...": {
            callback: function() {
              var modal;
              return modal = new KDModalViewWithForms({
                overlay: true,
                title: "Load from Gist URL",
                content: "<div class='modalformline'>\n  <p>\n    You can load a gist as an application and run it in Kodepad.\n    The gist must contain <code>index.coffee</code> and <code>style.css</code> files.\n  </p>\n  <p>\n      The gist code you are going to load can reach (and modify) all of your files, settings and \n      all other information you shared with Koding. If you don't know what you are doing, \n      it's <strong>not recommended</strong> to run external code on Kodepad.\n  </p>\n</div>",
                tabs: {
                  navigable: true,
                  forms: {
                    "Gist URL": {
                      fields: {
                        url: {
                          label: "Gist URL: ",
                          name: "url",
                          placeholder: "enter a gist url...",
                          validate: {
                            rules: {
                              regExp: /^https?:\/\/gist\.github\.com\//
                            },
                            messages: {
                              regExp: "You must enter a real gist url."
                            }
                          }
                        }
                      },
                      buttons: {
                        "I know the risks, load and run": {
                          cssClass: "modal-clean-gray",
                          callback: function() {
                            var kite, notify, url;
                            if (!modal.modalTabs.forms["Gist URL"].inputs.url.validate()) {
                              return;
                            }
                            url = modal.modalTabs.forms["Gist URL"].inputs.url.getValue();
                            url = url.replace(/^.*\/(\d+)$/g, 'https://api.github.com/gists/$1');
                            notify = new KDNotificationView({
                              title: "Loading Gist..."
                            });
                            kite = KD.getSingleton("kiteController");
                            return kite.run("curl -kL " + url, function(error, data) {
                              try {
                                data = JSON.parse(data);
                              } catch (_error) {}
                              debugger;
                              if (!error) {
                                _this.ace.getSession().setValue(data.files["index.coffee"].content);
                                notify.destroy();
                                modal.destroy();
                                return notify = new KDNotificationView({
                                  title: "Gist Loaded!"
                                });
                              } else {
                                return notify = new KDNotificationView({
                                  title: "Try again. :("
                                });
                              }
                            });
                          }
                        }
                      }
                    }
                  }
                }
              });
            }
          }
        };
      },
      callback: function() {
        var modal;
        return modal = new KDModalViewWithForms({
          title: "Save Application",
          content: "<div class='modalformline'>\n  <p>You can build an application using Kodepad. Please set your application up.</p>\n  <p>Don't forget to edit <code>.manifest</code> file in your application directory.</p>\n</div>",
          overlay: true,
          height: "auto",
          tabs: {
            navigable: true,
            forms: {
              "Settings": {
                fields: {
                  name: {
                    label: "Name: ",
                    name: "name",
                    placeholder: "name your application...",
                    validate: {
                      rules: {
                        regExp: /^[a-z\d]+([-][a-z\d]+)*$/i
                      },
                      messages: {
                        regExp: "For Application name only lowercase letters and numbers are allowed!"
                      }
                    }
                  }
                },
                buttons: {
                  "Save": {
                    cssClass: "modal-clean-gray",
                    callback: function() {
                      var coffee, name, notify;
                      if (!modal.modalTabs.forms.Settings.inputs.name.validate()) {
                        return;
                      }
                      name = modal.modalTabs.forms.Settings.inputs.name.getValue();
                      coffee = _this.ace.getSession().getValue();
                      notify = new KDNotificationView({
                        title: "Application " + name + " is being created now..."
                      });
                      return AppCreator.getSingleton().create(name, coffee, '', function() {
                        notify.destroy();
                        modal.destroy();
                        return new KDNotificationView({
                          title: "Your application " + name + " is ready! Have fun. :)"
                        });
                      });
                    }
                  }
                }
              }
            }
          }
        });
      }
    }));
    this.controlButtons.addSubView(new KDButtonView({
      cssClass: 'clean-gray editor-button control-button full-preview',
      title: "",
      icon: true,
      iconOnly: true,
      iconClass: "preview",
      callback: function() {
        _this.splitView.state = !_this.splitView.state;
        if (_this.splitView.state) {
          _this.splitView.resizePanel();
          return KD.utils.wait(500, function() {
            return _this.editor.getView().domElement.trigger("keyup");
          });
        } else {
          return ($(window)).trigger("resize");
        }
      }
    }));
    toggleTransparency = new KDToggleButton({
      style: "kdwhitebtn",
      cssClass: "clean-gray editor-button control-button transp",
      states: [
        "Transparent", function(callback) {
          _this.preview.domElement.addClass('transparented');
          toggleTransparency.domElement.addClass('transparented');
          return callback();
        }, "Opaque", function(callback) {
          _this.preview.domElement.removeClass('transparented');
          toggleTransparency.domElement.removeClass('transparented');
          return callback();
        }
      ]
    });
    this.controlButtons.addSubView(toggleTransparency);
    runApp = function(appName) {
      var appController, appManifest;
      appController = KD.getSingleton("kodingAppsController");
      appManifest = appController.constructor.manifests[appName];
      if (appManifest) {
        appController.runApp(appManifest);
        return true;
      } else {
        return false;
      }
    };
    this.controlButtons.addSubView(new KDButtonView({
      cssClass: "clean-gray editor-button control-button",
      title: "",
      icon: true,
      iconOnly: true,
      iconClass: "docs",
      callback: function() {
        var docsApp;
        docsApp = runApp("Koding Docs");
        if (!docsApp) {
          return new KDNotificationView({
            title: "Koding Docs is not installed!",
            content: "This button is a shortcut to run Koding Docs, so you must install it."
          });
        }
      }
    }));
    this.controlButtons.addSubView(new KDMultipleChoice({
      cssClass: "clean-gray editor-button control-button auto-manual",
      labels: ["Auto", "Manual"],
      defaultValue: "Auto",
      callback: function(state) {
        _this.liveViewer.active = state === "Auto" ? true : false;
        if (state === "Auto") {
          return _this.liveViewer.previewCode(_this.editor.getValue());
        }
      }
    }));
    this.controlView.addSubView(this.exampleCode.options.label);
    this.controlView.addSubView(this.exampleCode);
    this.controlView.addSubView(this.controlButtons);
    this.liveViewer.setSplitView(this.splitView);
    this.liveViewer.setMainView(this);
    return this.liveViewer.previewCode(this.editor.getValue());
  };

  MainView.prototype.pistachio = function() {
    return "{{> this.controlView}}\n{{> this.editor.getView()}}\n{{> this.splitView}}";
  };

  MainView.prototype.buildAce = function() {
    var ace, update,
      _this = this;
    ace = this.getOptions().ace;
    try {
      update = KD.utils.throttle(function() {
        _this.editor.setValue(_this.ace.getSession().getValue());
        return _this.editor.getView().domElement.trigger("keyup");
      }, Settings.aceThrottle);
      this.ace = ace.edit(this.aceView.domElement.get(0));
      this.ace.setTheme(Settings.theme);
      this.ace.getSession().setMode("ace/mode/markdown");
      this.ace.getSession().setTabSize(2);
      this.ace.getSession().setUseSoftTabs(true);
      this.ace.getSession().setValue(this.editor.getValue());
      this.ace.getSession().on("change", function() {
        return update();
      });
      this.editor.setValue(this.ace.getSession().getValue());
      return this.ace.commands.addCommand({
        name: 'save',
        bindKey: {
          win: 'Ctrl-S',
          mac: 'Command-S'
        },
        exec: function() {
          return _this.editor.setValue(_this.ace.getSession().getValue());
        }
      });
    } catch (_error) {}
  };

  MainView.prototype.viewAppended = function() {
    this.delegateElements();
    this.setTemplate(this.pistachio());
    return this.buildAce();
  };

  return MainView;

})(JView);


/* BLOCK ENDS */



/* BLOCK STARTS /Source: /Users/arvidkahl/Applications/marKDown.kdapp/index.coffee */

var MainView;

MainView = Kodepad.Views.MainView;

(function() {
  var loader, markdownModal;
  loader = new KDView({
    cssClass: "marKDown loading",
    partial: "Loading marKDown..."
  });
  KD.enableLogs();
  console.log('MEW');
  markdownModal = new KDModalView({
    width: window.innerWidth - 100,
    height: window.innerHeight - 100,
    overlay: false,
    title: 'marKDown editor',
    buttons: {
      Yes: {
        loader: {
          color: "#ffffff",
          diameter: 16
        },
        style: "modal-clean-gray",
        callback: function() {
          new KDNotificationView({
            title: "Clicked yes!"
          });
          return markdownModal.destroy();
        }
      },
      No: {
        loader: {
          color: "#ffffff",
          diameter: 16
        },
        style: "modal-clean-gray",
        callback: function() {
          new KDNotificationView({
            title: "Clicked no!"
          });
          return markdownModal.destroy();
        }
      }
    }
  });
  markdownModal.addSubView(loader);
  return require(["ace/ace"], function(Ace) {
    markdownModal.removeSubView(loader);
    markdownModal.addSubView(new MainView({
      cssClass: "marKDown",
      ace: Ace
    }));
    return markdownModal.$('.kdmodal-content').height(window.innerHeight - 100);
  });
})();


/* BLOCK ENDS */

/* KDAPP ENDS */

}).call();