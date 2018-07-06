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
     $("div.after_login").hide()
  } else {
    if (localStorage.getItem("logo_bin") == null) {

      channel.push("load_footer", {inst_id: window.currentInstitute})
    }
  };


if (localStorage.getItem("logo_bin") != null) {
  var bin = localStorage.getItem("logo_bin")
  var img = "   <img id='school_logo' style='float:left; width:auto; height: 100px;' src='data:image/png;base64, "+bin+"'>"
$("footer").append(img)
}

if (localStorage.getItem("maintain") != null) {
  var bin = localStorage.getItem("maintain")
  var maintain =  "<p style='padding-top: 40px; float:left;'>Support by "+bin+"</p>"
$("footer").append(maintain)
}

  channel.on("show_footer", payload => {
    localStorage.setItem("logo_bin", payload.logo_bin)
    localStorage.setItem("maintain", payload.maintain)
      var bin = localStorage.getItem("logo_bin")
      var img = "   <img id='school_logo' style='float:left; width:auto; height: 100px;' src='data:image/png;base64, "+bin+"'>"
    $("footer").append(img)
      var bin = localStorage.getItem("maintain")
      var maintain = "<p style='padding-top: 40px; float:left;'>Support by "+bin+"</p>"
    $("footer").append(maintain)
  })

  $("div.student").click(function(){
    var student_id = $(this).attr("id")
    channel.push("inquire_student_details", {user_id: window.currentUser, student_id: student_id})
  })

  channel.on("show_student_details", payload => {
    $("div[aria-label='student_details']").html(payload.html)
    var csrf = window.csrf
    $("input[name='_csrf_token']").val(csrf)
  })

  $("a[href='/logout']").click(function(){
    localStorage.removeItem("maintain")
    localStorage.removeItem("logo_bin")
  })
})