#!/usr/bin/env node
 
// Generated by CoffeeScript 1.6.3
(function() {
  var Router, argv, get_scgi, http, router, server;

  Router = require('../../lib/router');

  http = require('http');

  router = Router({
    list_dir: true
  });

  /*
  Example routes
  */


  router.get("/hello", function(req, res) {
    return res.end("Hello, World!, Hola, Mundo!");
  });

  router.get("/users", function(req, res) {
    res.writeHead(200, {
      'Content-type': 'text/html'
    });
    return res.end("<h1 style='color: navy; text-align: center;'>Active members registry</h1>");
  });

  router.post("/users", function(req, res) {
    var e, key, val, _ref, _ref1, _ref2;
    router.log("\n\nBody of request is: " + (req.body.toString()) + "\nRequest content type is: " + req.headers['content-type']);
    router.log("\nRequest Headers");
    _ref = req.headers;
    for (key in _ref) {
      val = _ref[key];
      router.log("" + key + " = " + val);
    }
    router.log("\nRequest body object properties");
    res.write("\nRequest body object properties\n");
    try {
      _ref1 = req.body;
      for (key in _ref1) {
        val = _ref1[key];
        router.log("" + key + ": " + val);
      }
    } catch (_error) {
      e = _error;
      res.write("Looks like you did something dumb: " + (e.toString()) + "\n");
    }
    _ref2 = req.body;
    for (key in _ref2) {
      val = _ref2[key];
      res.write("" + key + " = " + val + "\n");
    }
    return res.end();
  });

  router.get("/users/:id", function(req, res) {
    res.writeHead(200, {
      'Content-type': 'text/html'
    });
    return res.end("<h1>User No: <span style='color: red;'>" + req.params.id + "</span></h1>");
  });

  router.get("/crashit", function(req, res) {
    throw new Error("Crashed on purpose...");
  });

  router.post("/showrequest", function(req, res) {
    var e, key, stri, val;
    res.writeHead(200, {
      'Content-type': 'text/plain'
    });
    res.write('-----------------------------------------------------------\n\n');
    res.write("The name is Bond...hey, no, it is " + (req.post['name'] || 'unknown') + "\n");
    res.write("And the age is " + req.post['age'] + "\n\n");
    for (key in req) {
      val = req[key];
      try {
        stri = "Request " + key + " = " + (JSON.stringify(val)) + "\n";
        if (!!router.logging) {
          router.log(stri);
        }
        res.write(stri);
      } catch (_error) {
        e = _error;
        res.write("NASTY ERROR: " + e.message + "\n");
      }
    }
    return res.end();
  });

  router.get("/formrequest", function(req, res) {
    res.writeHead(200, {
      'Content-type': 'text/html'
    });
    return res.end("<title>Request vars discovery</title>\n<form action=\"/showrequest\" method=\"post\" enctype=\"application/x-www-form-urlencoded\">\n  <p>Name:<input type=\"text\" required=\"required\" size=\"40\" name=\"name\" /></p>\n  <p>Age:&nbsp;&nbsp;&nbsp;<input type=\"number\" required=\"required\" size=\"4\" name=\"age\" /></p>\n  <p><input type=\"submit\" value=\"Submit to /showrequest\" /><input type=\"reset\" value=\"Reset\" /></p>\n</form>");
  });

  router.get("/google", function(req, res) {
    return router.proxy_pass("http://www.google.com.ar", res);
  });

  router.get("/testing", function(req, res) {
    return router.proxy_pass("http://testing.savos.ods.org/", res);
  });

  router.get("/testing/:route", function(req, res) {
    return router.proxy_pass("http://testing.savos.ods.org/" + req.params.route + "/", res);
  });

  router.get("/shell", function(req, res) {
    return router.proxy_pass("http://testing.savos.ods.org:10001", res);
  });

  router.get("/login", function(req, res) {
    var auth, pwd, require_credentials, usr, _ref;
    require_credentials = function() {
      res.setHeader("WWW-Authenticate", 'Basic realm="node-simple-router"');
      res.writeHead(401, 'Access denied', {
        'Content-type': 'text/html'
      });
      return res.end();
    };
    console.log(req.headers);
    console.log("----------------------------------------------------------------");
    if (!req.headers['authorization']) {
      return require_credentials();
    } else {
      console.log("req.headers['authorization'] = " + req.headers['authorization']);
      auth = req.headers['authorization'].split(/\s+/);
      console.log("AUTH: " + (auth[0] + ' - ' + auth[1]));
      _ref = new Buffer(auth[1], 'base64').toString().split(':'), usr = _ref[0], pwd = _ref[1];
      if (usr === 'sandy' && pwd === 'ygnas') {
        res.writeHead(200, {
          'Content-type': 'text/plain'
        });
        res.write("usr: " + usr + "\n");
        res.write("pwd: " + pwd + "\n");
        return res.end();
      } else {
        return require_credentials();
      }
    }
  });

  router.get("/scgi", function(req, res) {
    return router.scgi_pass('/tmp/node_scgi.sk', req, res);
  });

  get_scgi = function(req, res) {
    return router.scgi_pass(26000, req, res);
  };

  router.get("/scgiform", function(req, res) {
    res.writeHead(200, {
      'Content-type': 'text/html'
    });
    return res.end("<title>SCGI Form</title>\n<h3 style=\"text-align: center; color: #220088;\">SCGI Form</h3><hr/>\n<form action=\"/uwsgi\" method=\"post\">\n  <table>\n    <tr>\n      <td>Name</td>\n      <td style=\"text-align: right;\"><input type=\"text\" size=\"40\" name=\"name\" required=\"required\" /></td>\n    <tr>\n    <tr>\n      <td>Age</td>\n      <td style=\"text-align: right;\"><input type=\"number\" size=\"4\" name=\"age\" /></td>\n    <tr>\n    <tr>\n      <td><input type=\"submit\" value=\"Send  data\" /></td>\n      <td><input type=\"reset\" value=\"Reset\" /></td>\n    <tr>\n  </table>\n</form>");
  });

  router.get("/uwsgi", get_scgi);

  router.post("/uwsgi", get_scgi);

  /*
  End of example routes
  */


  argv = process.argv.slice(2);

  server = http.createServer(router);

  server.on('listening', function() {
    var addr;
    addr = server.address() || {
      address: '0.0.0.0',
      port: argv[0] || 8000
    };
    return router.log("Serving web content at " + addr.address + ":" + addr.port);
  });

  process.on("SIGINT", function() {
    server.close();
    router.log("\n Server shutting up...\n");
    return process.exit(0);
  });

  server.listen((argv[0] != null) && !isNaN(parseInt(argv[0])) ? parseInt(argv[0]) : 8000);

}).call(this);
