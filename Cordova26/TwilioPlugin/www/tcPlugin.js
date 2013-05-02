var TwilioPlugin;
(function() {
 
  var delegate = {}
 var callback = {}
    TwilioPlugin =
    {
        Device:function()
        {
            return this;
        },
        Connection: function()
        {           
            return this;
        }
    }
TwilioPlugin.Device.prototype.setup = function(param)
{ 
         // Take a token and instantiate a new device object
        var error = function(error)
        {
            if(delegate['ondeviceerror']) delegate['ondeviceerror'](error)
            if(delegate['onconnectionerror']) delegate['onconnectionerror'](error)
        }
        var success = function()
        {
            var argument = callback['arguments'] || new Twilio.Connection();
            if (delegate[callback['callback']]) delegate[callback['callback']](argument);                
        }
     
    var tmp=window.devToken;
    alert("DeviceToken"+tmp);
    var xmlhttp=new XMLHttpRequest();
    xmlhttp.overrideMimeType("application/json");    
    xmlhttp.open("GET","https://66.228.51.14/calls/token?client="+param+"&device_token="+tmp,true);
    xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");
    xmlhttp.send(); 
    xmlhttp.onreadystatechange=function() {
    if (xmlhttp.readyState==4) {
    //a response now exists in the responseTest property.
    console.log("Registration response: " + xmlhttp.responseText);  
    var jsondata=eval("("+xmlhttp.responseText+")"); 
    var tokenTemp="'"+jsondata.token+"'";
        alert(tokenTemp);
        console.log(tokenTemp);
    //A function will call native IOS plugin files. Here deviceSetup is an IOS function and tokenTemp is params.
    Cordova.exec(success, error, "TCPlugin", "deviceSetup", [jsondata.token]);
    }
    }       
}

    // polymorphic function. if called with function as an argument, the function is invoked
    // when a connection has been established. if called with an object a connection is established with those options    
    TwilioPlugin.Device.prototype.connect = function(argument1)
    { 
        var argument = {"PhoneNumber":'+'+argument1};    
        alert(argument["PhoneNumber"]); 
        if (typeof(argument) == 'function') {
            delegate['onconnect'] = argument;
        } else if (typeof(argument) == 'object') {
        Cordova.exec("TCPlugin.connect", argument)
    }
    }
 

    TwilioPlugin.Device.prototype.disconnectAll = function() {
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
    TwilioPlugin.Device.prototype.incoming = function(fn) {
        delegate['onincoming'] = fn;
    }
    TwilioPlugin.Device.prototype.cancel = function(fn) {
        delegate['oncancel'] = fn;       
    }
    TwilioPlugin.Device.prototype.error = function(fn) {
        delegate['ondeviceerror'] = fn;
    }
    TwilioPlugin.Device.prototype.presence = function(fn) {
        delegate['onpresence'] = fn;
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
    TwilioPlugin.Connection.prototype.accept = function(argument) {
        if (typeof(argument) == 'function') {
            delegate['onaccept'] = argument;
        } else {
            Cordova.exec("TCPlugin.acceptConnection");
        }
    }
 
    TwilioPlugin.Connection.prototype.reject = function() {
        Cordova.exec("TCPlugin.rejectConnection");
    }
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
    TwilioPlugin.Connection.prototype.status = function(fn)
    {
        Cordova.exec(fn, null, "TCPlugin", "connectionStatus", []);
    }
    TwilioPlugin.install = function()
    {           
        if (!window.Twilio) window.Twilio = {};
        if (!window.Twilio.Device) window.Twilio.Device = new TwilioPlugin.Device();
        if (!window.Twilio.Connection) window.Twilio.Connection = TwilioPlugin.Connection;
    }
    Cordova.addConstructor(TwilioPlugin.install);
})()