// patched version of private_pub.js that comes with private_pub gem
// remember to update this file when updating private_pub gem!

function buildPrivatePub(doc) {
  var self = {
    connecting: false,
    fayeClient: null,
    fayeCallbacks: [],
    subscriptions: {},
    subscriptionCallbacks: {},

    faye: function(callback) {
      if (self.fayeClient) {
        callback(self.fayeClient);
      } else {
        self.fayeCallbacks.push(callback);
        if (self.subscriptions.server && !self.connecting) {
          self.connecting = true;
          var script = doc.createElement("script");
          script.type = "text/javascript";
          script.src = self.subscriptions.server + ".js";
          script.onload = self.connectToFaye;
          doc.documentElement.appendChild(script);
        }
      }
    },

    connectToFaye: function() {
      self.fayeClient = new Faye.Client(self.subscriptions.server);
      self.fayeClient.addExtension(self.fayeExtension);
      for (var i=0; i < self.fayeCallbacks.length; i++) {
        self.fayeCallbacks[i](self.fayeClient);
      };
    },

    fayeExtension: {

      // patched to support FayeTtl
      incoming: function(message, callback) {
        if(message.channel == '/meta/subscribe') {
          var subscription = message.subscription;
          var func = self.subscriptionCallbacks[subscription];
          if(message.ext && message.ext.cached) {
            message.ext.cached.forEach(function(data) {
              func(data.data, subscription, data.timestamp);
            });
          }
        }
        callback(message);
      },
      // end of patch

      outgoing: function(message, callback) {
        if (message.channel == "/meta/subscribe") {
          // Attach the signature and timestamp to subscription messages
          var subscription = self.subscriptions[message.subscription];
          if (!message.ext) message.ext = {};
          message.ext.private_pub_signature = subscription.signature;
          message.ext.private_pub_timestamp = subscription.timestamp;
        }
        callback(message);
      }
    },

    sign: function(options) {
      if (!self.subscriptions.server) {
        self.subscriptions.server = options.server;
      }
      self.subscriptions[options.channel] = options;
      self.faye(function(faye) {
        faye.subscribe(options.channel, self.handleResponse);
      });
    },

    handleResponse: function(message) {
      if (message.eval) {
        eval(message.eval);
      }
      if (callback = self.subscriptionCallbacks[message.channel]) {
        callback(message.data, message.channel);
      }
    },

    subscribe: function(channel, callback) {
      self.subscriptionCallbacks[channel] = callback;
    }
  };
  return self;
}

var PrivatePub = buildPrivatePub(document);
