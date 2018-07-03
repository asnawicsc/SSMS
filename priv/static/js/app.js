// for phoenix_html support, including form and button helpers
// copy the following scripts into your javascript bundle:
// * https://raw.githubusercontent.com/phoenixframework/phoenix_html/v2.10.0/priv/static/phoenix_html.js


var socket = new Phoenix.Socket("/socket", {
  params: { token: window.userToken }
});
socket.connect();
// Now that you are connected, you can join channels with a topic:
var topic = "user:" + window.currentUser;
// Join the topic
let channel = socket.channel(topic, {});
channel
  .join()

  .receive("ok", data => {
    console.log("Joined topic", topic);
  })

  .receive("error", resp => {
    console.log("Unable to join topic", topic);
  });


$(document).ready(function(){

if (window.currentUser == "lobby") {
  $("nav.after_login").hide()
}

})