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


  $("input#hw_show_class").click(function(){
    var map = $("form#semester").serializeArray();
    $("input#semester_id").val(map[0].value)
    channel.push("hw_get_classes",{map: map})
    channel.on("hw_show_classes", payload=>{
      $("form#classes").show()
      $("select#class_lists").append("<option value='all_class' >All Classes</option>")
      var i;
      for (i = 0; i < payload.classes.length; i++) { 
        
        $("select#class_lists").append("<option value=" + payload.classes[i].id + " >" + payload.classes[i].name + "</option>")
      }
    })
  })


  $("div[aria-label='std_height_weight']").click(function(){
    $("#levels").show()
    var std_id = $(this).attr('id')
    $('select#levels').attr('aria-label', std_id);
    console.log(std_id)
    var lvl_id = document.getElementById("levels").value
    channel.push("show_height_weight",{std_id: std_id, lvl_id: lvl_id})
    channel.on("display_height_weight",payload =>{
      $("div[aria-label='height_weight_details']").html(payload.html)
      $("button#submit_height_weight").click(function(){
        lvl_id = document.getElementById("levels").value
        var map = $("form").serializeArray();

        channel.push("submit_height_weight",{lvl_id: lvl_id, map: map})
        channel.on("updated_height_weight",payload => {
          $.notify({
        // options
          message: "Height and weight updated !"
        },{
          // settings
          type: 'info'
        });
        })
      })
    })
  })

  $("select#levels").click(function(){
    var std_id = $(this).attr('aria-label')
    var lvl_id = document.getElementById("levels").value
    channel.push("show_height_weight",{std_id: std_id, lvl_id: lvl_id})  
  })
  
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


       $("input[name='below_satisfy']").val(data.below_satisfy)

   $("input[name='member_reading_quantity']").val(data.member_reading_quantity)

    $("input[name='page']").val(data.page)

     $("input[name='import_from_library']").val(data.import_from_library)

 $("input[name='count_page_number']").val(data.count_page)
     $("input[name='standard_id']").val(data.standard_id)
        $("input[name='id']").val(data.ids)
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
   $("div#standard_period").hide();

$(".nav-link#standard_subject").click(function() {

   $("div#standard_subject").show();
  $("div#subject_test").hide();
    $("div#test").hide();
  $("div#result_grade").hide();
  $("div#result_default").hide();
  $("div#seq").hide();
  $("div#co_curriculum").hide();
  $("div#grade_co").hide();
   $("div#standard_period").hide();

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
   $("div#standard_period").hide();


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
   $("div#standard_period").hide();


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
   $("div#standard_period").hide();


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
   $("div#standard_period").hide();


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
   $("div#standard_period").hide();


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
   $("div#standard_period").hide();


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
    $("div#standard_period").hide();


   var standard_level=localStorage.getItem("standard_level")

  channel.push("grade_co", {user_id: window.currentUser,standard_level: standard_level})
    
  })


$(".nav-link#standard_period").click(function() {

     $("div#standard_subject").hide();
  $("div#subject_test").hide();
    $("div#test").hide();
  $("div#result_grade").hide();
  $("div#result_default").hide();
  $("div#seq").hide();
  $("div#co_curriculum").hide();
  $("div#grade_co").hide();
  $("div#standard_period").show();


   var standard_level=localStorage.getItem("standard_level")

  channel.push("period", {user_id: window.currentUser,standard_level: standard_level})
    
  })

channel.on("show_period", payload => {
    var data = payload.period
var standard_level=payload.standard_level

  $("div#period").html(standard_level)
    console.log(data)

        $("table#period").DataTable({
            
            destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [ {
                    data: 'class_name'
                },
                {
                    data: 'day'
                },
                {
                    data: 'start_time'
                },
                {
                    data: 'end_time'
                },
                {
                    data: 'subject_name'
                },
                 {
                    data: 'teacher_name'
                }

               
            ]
        });
  })


$(".nav-link#class_info").click(function() {

   

   var class_id=localStorage.getItem("class_id")

  channel.push("class_info", {user_id: window.currentUser,class_id: class_id})
    
  })


$("div#class_info").show();
$("div#class_subject").hide();
$("div#class_period").hide();
$("div#class_student").hide();
$("div#class_student_info").hide();

channel.on("show_class_info", payload => {

$("div#class_info").show();
$("div#class_subject").hide();
$("div#class_period").hide();
$("div#class_student").hide();
$("div#class_student_info").hide();
    var data = payload.all
var standard_level=payload.standard_level
var name = payload.name
var institution_id = payload.institution_id
var level_id = payload.level_id
var remark = payload.remark

   $("input[name='class_name']").val(name)

   $("input[name='remark']").val(remark)

    $("input[name='institution_id']").val(institution_id)

     $("input[name='level_id']").val(level_id)



      
  })



$(".nav-link#class_subject").click(function() {

   

   var class_id=localStorage.getItem("class_id")

  channel.push("class_subject", {user_id: window.currentUser,class_id: class_id})
    
  })



channel.on("show_class_subject", payload => {

$("div#class_info").hide();
$("div#class_subject").show();
$("div#class_period").hide();
$("div#class_student").hide();
$("div#class_student_info").hide();
var class_id = payload.class_id

  $("button[name='class_id']").val(class_id)   
  var data = payload.all
 $("table#class_subject").DataTable({
            
            destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [ {
                    data: 'subject_code'
                },
                {
                    data: 'subject_name'
                },
                {
                    data: 'teacher_code'
                },
                {
                    data: 'teacher_name'
                }
               
            ]
        });
  })


$(".nav-link#class_period").click(function() {

   

   var class_id=localStorage.getItem("class_id")

  channel.push("class_period", {user_id: window.currentUser,class_id: class_id})
    
  })



channel.on("show_class_period", payload => {

$("div#class_info").hide();
$("div#class_subject").hide();
$("div#class_period").show();
$("div#class_student").hide();
$("div#class_student_info").hide();


    var maps = JSON.parse(payload.all2)

   $(maps).each(function(i,v) {
          console.log(v)
             v["start"]= start(v["start_hour"],v["start_minute"])
             v["end"]= end(v["end_hour"],v["end_minute"])
        })


            // --------------------------- Data --------------------------------
            var locations = [
                {id: '1', name: 'Sunday'},
                {id: '2', name: 'Monday'},
                {id: '3', name: 'Tuesday'},
                {id: '4', name: 'Wednesday'},
                {id: '5', name: 'Thursday'},
                {id: '6', name: 'Friday'},
                {id: '7', name: 'Saturday'}
                  
              
                ];

            var events =maps;
            // -------------------------- Helpers ------------------------------
             function start(hours, minutes) {
                var date = new Date();
                date.setUTCHours(hours, minutes, 0, 0);
                console.log(date)
                return date;

            }
              function end(hours, minutes) {
                var date = new Date();
                date.setUTCHours(hours, minutes, 0, 0);
                return date;
            }
            
            
          
            // --------------------------- Example 1 ---------------------------
            var $sked1 = $('#sked5').skedTape({
                caption: 'Day',
                start: start(8,0),
                end: end(18, 0),
                showEventTime: true,
                showEventDuration: true,
                scrollWithYWheel: true,
                locations: locations,
                events: events
               
            });
           


  })

$(".nav-link#class_student").click(function() {

   

   var class_id=localStorage.getItem("class_id")

  channel.push("class_student", {semester_id: window.currentSemester, inst_id: window.currentInstitute,user_id: window.currentUser,class_id: class_id})
    
  })


channel.on("show_class_student", payload => {

$("div#class_info").hide();
$("div#class_subject").hide();
$("div#class_period").hide();
$("div#class_student").show();
$("div#class_student_info").hide();

    $("#m1").html(payload.html);

  })


$(".nav-link#class_student_info").click(function() {

   

   var class_id=localStorage.getItem("class_id")

  channel.push("class_student_info", {semester_id: window.currentSemester, inst_id: window.currentInstitute,user_id: window.currentUser,class_id: class_id})
    
  })







$("button[name='class_id']").click(function() {

    var class_id = $(this).val()
   var csrf = window.csrf

  channel.push("subject_class_teach", {csrf: csrf,user_id: window.currentUser,class_id: class_id})
    
  })

      channel.on("show_subject_class_teach", payload => {
    $("#modal_form1").html(payload.html);

  })



$("button[name='create_period']").click(function() {

 var class_id=localStorage.getItem("class_id")

var csrf = window.csrf
  channel.push("create_period", {csrf: csrf,user_id: window.currentUser,class_id: class_id})
    
  })

      channel.on("show_create_period", payload => {
   
    $("div#period_bod").html(payload.html);

  })




  
})

