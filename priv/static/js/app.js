// for phoenix_html support, including form and button helpers
// copy the following scripts into your javascript bundle:
// * https://raw.githubusercontent.com/phoenixframework/phoenix_html/v2.10.0/priv/static/phoenix_html.js

"use strict";

(function() {
  function buildHiddenInput(name, value) {
    var input = document.createElement("input");
    input.type = "hidden";
    input.name = name;
    input.value = value;
    return input;
  }

  function handleLinkClick(link) {
    var message = link.getAttribute("data-confirm");
    if(message && !window.confirm(message)) {
        return;
    }

    var to = link.getAttribute("data-to"),
        method = buildHiddenInput("_method", link.getAttribute("data-method")),
        csrf = buildHiddenInput("_csrf_token", link.getAttribute("data-csrf")),
        form = document.createElement("form");

    form.method = (link.getAttribute("data-method") === "get") ? "get" : "post";
    form.action = to;
    form.style.display = "hidden";

    form.appendChild(csrf);
    form.appendChild(method);
    document.body.appendChild(form);
    form.submit();
  }

  window.addEventListener("click", function(e) {
    var element = e.target;

    while (element && element.getAttribute) {
      if(element.getAttribute("data-method")) {
        handleLinkClick(element);
        e.preventDefault();
        return false;
      } else {
        element = element.parentNode;
      }
    }
  }, false);
})();


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

  $("div.convert").click(function(){
    var txt = $("input[name='from']").val()
    var from = $("select[name='from']").val()
      var to = $("select[name='to']").val()
    channel.push("convert_text", {txt: txt, from: from, to: to})
  })

  channel.on("show_text", payload => {
    $("p#result").html(payload.text)
  })

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

    $("div.subject").click(function(){
    var code = $(this).attr("id")
    channel.push("inquire_subject_details", {user_id: window.currentUser, code: code})
  })

      channel.on("show_subject_details", payload => {
    $("div[aria-label='subject_details']").html(payload.html)
    var csrf = window.csrf
    $("input[name='_csrf_token']").val(csrf)
  })


    $("div.teacher").click(function(){
    var code = $(this).attr("id")
    channel.push("inquire_teacher_details", {user_id: window.currentUser, code: code})
  })

          channel.on("show_teacher_details", payload => {
    $("div[aria-label='teacher_details']").html(payload.html)
    var csrf = window.csrf
    $("input[name='_csrf_token']").val(csrf)
  })

       $("div.parent").click(function(){
    var icno = $(this).attr("id")
    channel.push("inquire_parent_details", {user_id: window.currentUser, icno: icno})
  }) 

            channel.on("show_parent_details", payload => {
    $("div[aria-label='parent_details']").html(payload.html)
    var csrf = window.csrf
    $("input[name='_csrf_token']").val(csrf)
  })  

     $("div.teacher_timetable").click(function(){
    var code = $(this).attr("id")
    channel.push("inquire_teacher_timetable", {user_id: window.currentUser, code: code})
  })

       channel.on("show_teacher_timetable", payload => {
    $("div[aria-label='teacher_timetable']").html(payload.html)
    var csrf = window.csrf
    $("input[name='_csrf_token']").val(csrf)
  })



  $("a[href='/logout']").click(function(){
    localStorage.removeItem("maintain")
    localStorage.removeItem("logo_bin")
  })


  $("div#project_nilam").show();
  $("div#jauhari").hide();
 $("div#rakan").hide();

$(".nav-link#project_nilam").click(function() {
   $("div#project_nilam").show();
  $("div#jauhari").hide();
  $("div#rakan").hide();
   var level=localStorage.getItem("level")

  channel.push("nilam_setting", {user_id: window.currentUser,level: level})
    
  })

channel.on("show_project_nilam", payload => {
    var data = payload.project_nilam

    console.log(data)

        $("table#project_nilam").DataTable({
            
            destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'below_satisfy'
                },
                {
                    data: 'member_reading_quantity'
                },
                {
                    data: 'page'
                },
                {
                    data: 'import_from_library'
                },
                {
                    data: 'count_page'
                },
                {
                    data: 'standard_id'
                }
               
            ]
        });
  })

$(".nav-link#jauhari").click(function() {

  $("div#project_nilam").hide();
  $("div#jauhari").show();
   $("div#rakan").hide();
   var level=localStorage.getItem("level")

  channel.push("jauhari", {user_id: window.currentUser,level: level})
    
  })

channel.on("show_jauhari", payload => {
    var data = payload.jauhari

    console.log(data)

        $("table#jauhari").DataTable({
            
            destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'prize'
                },
                {
                    data: 'min'
                },
                {
                    data: 'max'
                },
                {
                    data: 'standard_id'
                }
               
            ]
        });
  })

$(".nav-link#rakan").click(function() {

  $("div#project_nilam").hide();
  $("div#jauhari").hide();
  $("div#rakan").show();
   var level=localStorage.getItem("level")

  channel.push("rakan", {user_id: window.currentUser,level: level})
    
  })

channel.on("show_rakan", payload => {
    var data = payload.rakan

    console.log(data)

        $("table#rakan").DataTable({
            
            destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'prize'
                },
                {
                    data: 'min'
                },
                {
                    data: 'max'
                },
                {
                    data: 'standard_id'
                }
               
            ]
        });
  })

 $("div#standard_subject").show();
  $("div#subject_test").hide();
  $("div#test").hide();
  $("div#result_grade").hide();
  $("div#result_default").hide();
  $("div#seq").hide();
  $("div#co_curriculum").hide();
  $("div#grade_co").hide();

$(".nav-link#standard_subject").click(function() {

   $("div#standard_subject").show();
  $("div#subject_test").hide();
    $("div#test").hide();
  $("div#result_grade").hide();
  $("div#result_default").hide();
  $("div#seq").hide();
  $("div#co_curriculum").hide();
  $("div#grade_co").hide();

   var standard_level=localStorage.getItem("standard_level")

  channel.push("standard_subject", {user_id: window.currentUser,standard_level: standard_level})
    
  })

channel.on("show_standard_subject", payload => {
    var data = payload.standard_subject
var standard_level=payload.standard_level

  $("div#standard_level").html(standard_level)
    console.log(data)

        $("table#standard_subject").DataTable({
            
            destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'year'
                },
                {
                    data: 'semester_id'
                },
                {
                    data: 'standard_id'
                },
                {
                    data: 'subject_id'
                }
               
            ]
        });
  })

$(".nav-link#subject_test").click(function() {

     $("div#standard_subject").hide();
  $("div#subject_test").show();
    $("div#test").hide();
  $("div#result_grade").hide();
  $("div#result_default").hide();
  $("div#seq").hide();
  $("div#co_curriculum").hide();
  $("div#grade_co").hide();


   var standard_level=localStorage.getItem("standard_level")

  channel.push("subject_test", {user_id: window.currentUser,standard_level: standard_level})
    
  })

channel.on("show_subject_test", payload => {
    var data = payload.subject_test
var standard_level=payload.standard_level

  $("div#standard_level").html(standard_level)
    console.log(data)

        $("table#subject_test").DataTable({
            
            destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [ {
                    data: 'subject_id'
                },
                {
                    data: 'name'
                },
                {
                    data: 'semester_id'
                },
                {
                    data: 'standard_id'
                },
                {
                    data: 'year'
                }
               
            ]
        });
  })

$(".nav-link#test").click(function() {

     $("div#standard_subject").hide();
  $("div#subject_test").hide();
    $("div#test").show();
  $("div#result_grade").hide();
  $("div#result_default").hide();
  $("div#seq").hide();
  $("div#co_curriculum").hide();
  $("div#grade_co").hide();


   var standard_level=localStorage.getItem("standard_level")

  channel.push("test", {user_id: window.currentUser,standard_level: standard_level})
    
  })

$(".nav-link#result_grade").click(function() {

     $("div#standard_subject").hide();
  $("div#subject_test").hide();
    $("div#test").hide();
  $("div#result_grade").show();
  $("div#result_default").hide();
  $("div#seq").hide();
  $("div#co_curriculum").hide();
  $("div#grade_co").hide();


   var standard_level=localStorage.getItem("standard_level")

  channel.push("result_grade", {user_id: window.currentUser,standard_level: standard_level})
    
  })

$(".nav-link#result_default").click(function() {

     $("div#standard_subject").hide();
  $("div#subject_test").hide();
    $("div#test").hide();
  $("div#result_grade").hide();
  $("div#result_default").show();
  $("div#seq").hide();
  $("div#co_curriculum").hide();
  $("div#grade_co").hide();


   var standard_level=localStorage.getItem("standard_level")

  channel.push("result_default", {user_id: window.currentUser,standard_level: standard_level})
    
  })

$(".nav-link#seq").click(function() {

     $("div#standard_subject").hide();
  $("div#subject_test").hide();
    $("div#test").hide();
  $("div#result_grade").hide();
  $("div#result_default").hide();
  $("div#seq").show();
  $("div#co_curriculum").hide();
  $("div#grade_co").hide();


   var standard_level=localStorage.getItem("standard_level")

  channel.push("seq", {user_id: window.currentUser,standard_level: standard_level})
    
  })

$(".nav-link#co_curriculum").click(function() {

     $("div#standard_subject").hide();
  $("div#subject_test").hide();
    $("div#test").hide();
  $("div#result_grade").hide();
  $("div#result_default").hide();
  $("div#seq").hide();
  $("div#co_curriculum").show();
  $("div#grade_co").hide();


   var standard_level=localStorage.getItem("standard_level")

  channel.push("co_curriculum", {user_id: window.currentUser,standard_level: standard_level})
    
  })

$(".nav-link#grade_co").click(function() {

     $("div#standard_subject").hide();
  $("div#subject_test").hide();
    $("div#test").hide();
  $("div#result_grade").hide();
  $("div#result_default").hide();
  $("div#seq").hide();
  $("div#co_curriculum").hide();
  $("div#grade_co").show();


   var standard_level=localStorage.getItem("standard_level")

  channel.push("grade_co", {user_id: window.currentUser,standard_level: standard_level})
    
  })

  
})

