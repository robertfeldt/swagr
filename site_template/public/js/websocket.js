var websocket_server_ip_address = "0.0.0.0";
var websocket_server_port_number = "3000";
var websocket_mount_point = "websocket";

// initial state must be true for our output logic to work.
var connected = true;
var connect;
connect = function() {
	// Create websocket connection by connecting to the mount point we specified in config.ru
	var ws = new WebSocket("ws://" + websocket_server_ip_address + ":" + websocket_server_port_number + "/" + websocket_mount_point);

	// On web socket established.
	ws.onopen = function() {

	// Only output to the user if the connection was previously down. 
		if (connected == false) {
			console.log("Websocket connection is UP.");
		}

		// Set the connected flag.
		connected = true;

		// Send a greeting message to the server.
		hwmsg = "Hello Server!";
		ws.send(hwmsg);
		console.log("Sent: " + hwmsg);
	}

	// On connection close or connection attempt failure.
	ws.onclose = function() {

		// Only output to the user that the connection is down if it was previously up.
		if (connected == true) {
			console.log("Websocket connection is DOWN.");
		}else {
			console.log(".");
		}

		// Set the connected flag.
		connected = false;

		// Attempt reconnect once a second until we're reconnected.
		setTimeout(1000, connect);	
	}

	// On message received.
	ws.onmessage = function(e) {
		var msg = e.data;
		console.log("Received message: " + msg);
	}

	// Here is how we can send a message to the server over the websocket.
	//ws.send(message);
}

// Verify that the browser supports web sockets.
if (window.WebSocket) {

	// Announce that the browser does support web sockets.
	console.log('Websocket is supported by this browser!');

	// Initial connection attempt to the web socket app.
	connect();

} else {
	// WebSockets are not supported by this browser. Either fall back to alternate method or display error page.
	console.log("Web sockets are not supported by this browser :(");
}