// Generated by CoffeeScript 1.7.1
(function() {
  var createWs;

  createWs = function() {
    var ws;
    ws = new WebSocket('ws://savos.ods.org:8000');
    ws.onopen = function(evt) {
      return console.log('socket opened', evt);
    };
    ws.onclose = function(evt) {
      return console.log('socket closed.', evt != null ? evt.wasClean : void 0, evt != null ? evt.code : void 0, evt != null ? evt.reason : void 0);
    };
    ws.onerror = function(evt) {
      var _ref;
      return console.log('socket error:', evt != null ? (_ref = evt.error) != null ? _ref.message : void 0 : void 0);
    };
    ws.onmessage = function(evt) {
      return console.log("Received: " + evt.data);
    };
    return ws;
  };

}).call(this);