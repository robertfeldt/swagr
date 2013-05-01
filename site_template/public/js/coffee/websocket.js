(function() {
  var root;

  root = typeof exports !== "undefined" && exports !== null ? exports : window;

  root.Swagr = root.Swagr ? root.Swagr : {};

  root.Swagr.Websocket = (function() {
    function Websocket(ipAddress, portNumber, mountPoint) {
      if (ipAddress == null) {
        ipAddress = "0.0.0.0";
      }
      if (portNumber == null) {
        portNumber = "3000";
      }
      if (mountPoint == null) {
        mountPoint = "websocket";
      }
      this.ip_address = ipAddress;
      this.port_number = portNumber;
      this.mount_point = mountPoint;
      this.connected = false;
      this.connect_to_mount_point();
    }

    Websocket.prototype.connect_to_mount_point = function() {
      this.ws = new WebSocket("ws://" + this.ip_address + ":" + this.port_number + "/" + this.mount_point);
      this.ws.onopen = this.onopen;
      this.ws.onclose = this.onerror;
      return this.ws.onmessage = this.onmessage;
    };

    Websocket.prototype.onopen = function() {
      if (!this.connected) {
        console.log("Websocket connection is UP.");
      }
      this.connected = true;
      return this.send("Hello Server!");
    };

    Websocket.prototype.send = function(msg) {
      this.ws.send(msg);
      return console.log("Sent to server: " + msg);
    };

    Websocket.prototype.onclose = function() {
      if (this.connected === true) {
        console.log("Websocket connection is DOWN.");
      } else {
        console.log(".");
      }
      this.connected = false;
      return setTimeout(1000, this.connect_to_mount_point);
    };

    Websocket.prototype.onmessage = function(e) {
      var msg;

      msg = e.data;
      return console.log("Received message: " + msg);
    };

    return Websocket;

  })();

  if (window.WebSocket) {
    console.log('Websocket is supported by this browser!');
    root.websocket = new root.Swagr.Websocket;
  } else {
    console.log("Web sockets are not supported by this browser :(");
  }

}).call(this);
