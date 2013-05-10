CallCenter = function() {
  var that = this;

  this.initialize = function() {
    document.addEventListener("deviceready", that.bindEvents, false);
  };

  this.bindEvents = function() {
    $(document).on('click', '#login', that.login);
    $(document).on('click', '#mute', that.mute);
    $(document).on('click', '#unmute', that.unmute);
    $(document).on('click', '#status', that.status);
    $(document).on('click', '#hangup', that.disconnect);
    $(document).on('click', '#call', that.connect);

    //for testing
    $('#loginName').val('a');
    $('#login').click();
  };

  this.login = function() {
    var handleName2 = document.getElementById('loginName').value;       
    if (handleName2) {            
      that.getName(handleName2);
      return true;
    } else {
      document.getElementById('error').innerHTML = "You need to enter a handle name";
    }
  };

  this.getName = function(params) {
    log('get name');
    var name = params;
    TwilioPlugin.install();
    var mytest = new TwilioPlugin.Device();
    mytest.setup(name);
  };

  this.mute = function() {
    log('mute');
    var mytest  = new TwilioPlugin.Connection();
    mytest.mute();
  };

  this.unmute = function() {
    log('unmute');
    var mytest  = new TwilioPlugin.Connection();
    mytest.unmute();
  };

  this.status = function() {
    log('status');
    var mytest  = new TwilioPlugin.Connection();
    mytest.status();
  };

  this.disconnect = function() {
    log('disconnect');
    var mytest  = new TwilioPlugin.Connection();
    mytest.disconnect(temp);
  };

  this.connect = function() {
    log('call');
    var myVar  = new TwilioPlugin.Device();
    myVar.invite();
  };

  return this;
};

callCenter = CallCenter();
callCenter.initialize();

var log = function(text) {
  $('#log').append($('<li>', { text: text }));
};

var temp;

var TwilioPlugin;
(function() {
  var delegate = {}

  TwilioPlugin = {
    Device:function() {   
      return this;
    },
  Connection: function() {           
    return this;
  }
  };

  TwilioPlugin.Device.prototype.setup = function(param) { 
    var error = function(error) {
      if (delegate['ondeviceerror']) {
        delegate['ondeviceerror'](error);
      }
      if (delegate['onconnectionerror']) {
        delegate['onconnectionerror'](error);
      }
    }

    window.client=param;
    var tmp=window.devToken;    
    var xmlhttp=new XMLHttpRequest();
    xmlhttp.overrideMimeType("application/json");    
    xmlhttp.open("GET","https://66.228.51.14/calls/token?client="+param+"&device_token="+tmp,true);
    xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");
    xmlhttp.send(); 
    xmlhttp.onreadystatechange=function() {
      if (xmlhttp.readyState==4) {
        //a response now exists in the responseTest property.
        //console.log("Registration response: " + xmlhttp.responseText);
        var jsondata=eval("("+xmlhttp.responseText+")"); 
        var tokenTemp="'"+jsondata.token+"'";
        log("Client '" + window.client + "' is ready");

        //A function will call native IOS plugin files. Here deviceSetup is an IOS function and jsondata.token is parameter for it. Also it'll take presence user from didReceivePresenceUpdate delegate. Cordova.exec is an well defined method of phoneGap to by which JS will intract with native code.
        Cordova.exec(function(winParam) { TwilioPlugin.Device.presence(winParam.arguments) }, error, "TCPlugin", "deviceSetup", [jsondata.token]);
      }
    }       
  }

  // polymorphic function. if called with function as an argument, the function is invoked
  // when a connection has been established. if called with an object a connection is established with those options 
  TwilioPlugin.Device.prototype.invite = function() {
    TwilioPlugin.Device.connect();    
  } 

  TwilioPlugin.Device.connect = function(argument1) {
    if(argument1) {
      console.log("Client name"+argument1)
        params = {"client":argument1} ;
    } else {
      console.log("PhoneNumber case");
      params =  {"PhoneNumber":'+'+$("#number").val()};
    }
    Cordova.exec("TCPlugin.connect", params)
  }


  TwilioPlugin.Device.disconnectAll = function() {
    Cordova.exec('TCPlugin.disconnectAll');
  }
  TwilioPlugin.Device.prototype.disconnect = function(fn) {       
    delegate['ondevicedisconnect'] = fn;
  }
  TwilioPlugin.Device.prototype.ready = function(fn) {
    delegate['onready'] = fn;
  }
  TwilioPlugin.Device.prototype.offline = function(fn) {
    delegate['onoffline'] = fn;
  }
  TwilioPlugin.Device.incoming = function(fn) {

    var theIncomingCall = confirm("Incoming Call");
    //if the user presses the "OK" button,then call will be accepted."
    if (theIncomingCall)        {

      Cordova.exec("TCPlugin.acceptConnection");
    }
    else{           
      Cordova.exec("TCPlugin.rejectConnection");   
    }        

  }
  TwilioPlugin.Device.prototype.cancel = function(fn) {
    delegate['oncancel'] = fn;       
  }

  TwilioPlugin.Device.prototype.error = function(fn) {
    delegate['ondeviceerror'] = fn;
  }

  TwilioPlugin.Device.presence = function(pres) {
    if (pres.available == 1) { 
      $("<li>", {id: pres.from, text: pres.from}).on('click', function () {
        TwilioPlugin.Device.connect(pres.from);
      }).prependTo("#people");
      if(pres.from  == window.client)
      {
        console.log("Remove"+pres.from);
        $("#" + pres.from).remove();
      } 
    } else {        
      $("#" + pres.from).remove();
    }     
  }

  TwilioPlugin.Device.prototype.status = function() {
    var status = Cordova.exec("TCPlugin.deviceStatus"); 
  }

  // Noops until I figure out why the hell using sounds in Phonegap gives EXC_BAD_ACCESS
  TwilioPlugin.Device.prototype.sounds = {
    incoming: function(boolean) {},
    outgoing: function(boolean) {},
    disconnect: function(boolean) {}
  }

  /* TwilioPlugin.Connection.prototype.accept = function(argument) {
     if (typeof(argument) == 'function') {
     delegate['onaccept'] = argument;
     } else {
     Cordova.exec("TCPlugin.acceptConnection");
     }
     }

     TwilioPlugin.Connection.prototype.reject = function() {
     Cordova.exec("TCPlugin.rejectConnection");
     }*/

  TwilioPlugin.Connection.prototype.disconnect = function(fn) {
    if (typeof(argument) == 'function') {
      delegate['onconnectiondisconnect'] = argument;
    } else {
      Cordova.exec("TCPlugin.disconnectConnection");
    }
  }

  TwilioPlugin.Connection.prototype.error = function(fn) {
    delegate['onconnectionerror'] = fn;
  }

  TwilioPlugin.Connection.prototype.mute = function() {
    Cordova.exec("TCPlugin.muteConnection");
  }

  TwilioPlugin.Connection.prototype.unmute = function() {
    Cordova.exec("TCPlugin.muteConnection");
  }

  TwilioPlugin.Connection.prototype.sendDigits = function(string) {
    Cordova.exec("TCPlugin.sendDigits", string);
  }

  TwilioPlugin.Connection.prototype.status = function(fn) {
    Cordova.exec(fn, null, "TCPlugin", "connectionStatus", []);
  }

  TwilioPlugin.install = function() {           
    if (!window.Twilio) window.Twilio = {};
    if (!window.Twilio.Device) window.Twilio.Device = new TwilioPlugin.Device();
    if (!window.Twilio.Connection) window.Twilio.Connection = TwilioPlugin.Connection;
  }

  Cordova.addConstructor(TwilioPlugin.install);
})()
