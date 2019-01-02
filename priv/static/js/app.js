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


// BOOTGRID
// -----------------------------------

(function(window, document, $, undefined) {
    'use strict';

    $(initBootgrid);

    function initBootgrid() {

        if (!$.fn.bootgrid) return;

        $('#bootgrid-basic').bootgrid({
            templates: {
                // templates for BS4
                actionButton: '<button class="btn btn-secondary" type="button" title="{{ctx.text}}">{{ctx.content}}</button>',
                actionDropDown: '<div class="{{css.dropDownMenu}}"><button class="btn btn-secondary dropdown-toggle dropdown-toggle-nocaret" type="button" data-toggle="dropdown"><span class="{{css.dropDownMenuText}}">{{ctx.content}}</span></button><ul class="{{css.dropDownMenuItems}}" role="menu"></ul></div>',
                actionDropDownItem: '<li class="dropdown-item"><a href="" data-action="{{ctx.action}}" class="dropdown-link {{css.dropDownItemButton}}">{{ctx.text}}</a></li>',
                actionDropDownCheckboxItem: '<li class="dropdown-item"><label class="dropdown-item p-0"><input name="{{ctx.name}}" type="checkbox" value="1" class="{{css.dropDownItemCheckbox}}" {{ctx.checked}} /> {{ctx.label}}</label></li>',
                paginationItem: '<li class="page-item {{ctx.css}}"><a href="" data-page="{{ctx.page}}" class="page-link {{css.paginationButton}}">{{ctx.text}}</a></li>',
            }
        });

        $('#bootgrid-selection').bootgrid({
            selection: true,
            multiSelect: true,
            rowSelect: true,
            keepSelection: true,
            templates: {
                select:
                    '<div class="checkbox c-checkbox">' +
                        '<label class="mb-0">' +
                            '<input type="{{ctx.type}}" class="{{css.selectBox}}" value="{{ctx.value}}" {{ctx.checked}}>' +
                            '<span class="fa fa-check"></span>' +
                        '</label>'+
                    '</div>',
                // templates for BS4
                actionButton: '<button class="btn btn-secondary" type="button" title="{{ctx.text}}">{{ctx.content}}</button>',
                actionDropDown: '<div class="{{css.dropDownMenu}}"><button class="btn btn-secondary dropdown-toggle dropdown-toggle-nocaret" type="button" data-toggle="dropdown"><span class="{{css.dropDownMenuText}}">{{ctx.content}}</span></button><ul class="{{css.dropDownMenuItems}}" role="menu"></ul></div>',
                actionDropDownItem: '<li class="dropdown-item"><a href="" data-action="{{ctx.action}}" class="dropdown-link {{css.dropDownItemButton}}">{{ctx.text}}</a></li>',
                actionDropDownCheckboxItem: '<li class="dropdown-item"><label class="dropdown-item p-0"><input name="{{ctx.name}}" type="checkbox" value="1" class="{{css.dropDownItemCheckbox}}" {{ctx.checked}} /> {{ctx.label}}</label></li>',
                paginationItem: '<li class="page-item {{ctx.css}}"><a href="" data-page="{{ctx.page}}" class="page-link {{css.paginationButton}}">{{ctx.text}}</a></li>',
            }
        });



        var grid = $('#bootgrid-command').bootgrid({
            formatters: {
                commands: function(column, row) {
                    return '<button type="button" class="btn btn-sm btn-info mr-2 command-edit" data-row-id="' + row.id + "/" + row.c_id + "/" + row.s_id +'"><em class="fa fa-edit fa-fw"></em> Marking</button>';
                }
            },
            templates: {
                // templates for BS4
                actionButton: '<button class="btn btn-secondary" type="button" title="{{ctx.text}}">{{ctx.content}}</button>',
                actionDropDown: '<div class="{{css.dropDownMenu}}"><button class="btn btn-secondary dropdown-toggle dropdown-toggle-nocaret" type="button" data-toggle="dropdown"><span class="{{css.dropDownMenuText}}">{{ctx.content}}</span></button><ul class="{{css.dropDownMenuItems}}" role="menu"></ul></div>',
                actionDropDownItem: '<li class="dropdown-item"><a href="" data-action="{{ctx.action}}" class="dropdown-link {{css.dropDownItemButton}}">{{ctx.text}}</a></li>',
                actionDropDownCheckboxItem: '<li class="dropdown-item"><label class="dropdown-item p-0"><input name="{{ctx.name}}" type="checkbox" value="1" class="{{css.dropDownItemCheckbox}}" {{ctx.checked}} /> {{ctx.label}}</label></li>',
                paginationItem: '<li class="page-item {{ctx.css}}"><a href="" data-page="{{ctx.page}}" class="page-link {{css.paginationButton}}">{{ctx.text}}</a></li>',
            }
        }).on('loaded.rs.jquery.bootgrid', function() {
            /* Executes after data is loaded and rendered */
            grid.find('.command-edit').on('click', function() {


              window.location.href = "/exam/marking/" + $(this).data('row-id') ;

                console.log('You pressed edit on row: ' + $(this).data('row-id'));
            }).end().find('.command-delete').on('click', function() {
                console.log('You pressed delete on row: ' + $(this).data('row-id'));
            });
        });


// +"/"+ $(this).data('row-c_id')+ "/" + $(this).data('row-s_id')

}

})(window, document, window.jQuery);

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

  $('#selection').change(function(){ 
        var std_id = $(this).val();
        channel.push("ed_show_parents",{std_id: std_id})
        
    })
  channel.on("parents_details",payload =>{
          $("#message").show()
          $("div#parents_list").html(payload.html)
          $('#parents').change(function(){ 
            var parent_id = $(this).val();
            console.log(parent_id)
            $("input#parent_id").val(parent_id)
          })
  })

  $("div.setting-color label").click(function(){
    var color = $(this).attr("data-load-css")
    console.log(color);

    channel.push("save_ui_color", {color: color, user_id: window.currentUser})
  })

  channel.on("load_ui_color", payload => {
    $("link#autoloaded-stylesheet").attr("href", "/" + payload.color)
  })

  $("button#select_all").click(function() {
      var li_list = $("ol#unmark_list").find("li")
      $(li_list).each(function() {

          var li = $(this);
          var student_id = $(this).attr("id");
          var class_id = location.pathname.split("/")[2]
          var name = $(this).html();


          channel.push("add_to_class_attendance",{ student_id: student_id,
            semester_id:  window.currentSemester, institution_id: window.currentInstitute,
            class_id: class_id, name: name})
          $("ol.mark").append(li);
      })
      channel.on("show_add_results_attendance", payload=>{
        $.notify({message: payload.student+" "+payload.action+" "+payload.class},{type: payload.type});
      })


    })

  $("button#unselect_all").click(function() {

      var li_list = $("ol#mark_list").find("li")
      console.log(li_list)
      $(li_list).each(function() {

          var li = $(this);
          var student_id = $(this).attr("id");
          var class_id = location.pathname.split("/")[2]
          var name = $(this).html();



          channel.push("add_to_class_attendance",{ student_id: student_id,
            semester_id:  window.currentSemester, institution_id: window.currentInstitute,
            class_id: class_id, name: name})
          $("ol.unmark").append(li);
      })
      channel.on("show_abs_results_attendance", payload=>{
        $.notify({message: payload.student+" "+payload.action+" "+payload.class},{type: payload.type});
      })


    })


  $("input#hw_show_class").click(function(){
    var map = $("form#semester").serializeArray();
    var institution_id = window.currentInstitute;

    if (map[0].value != "certificate") {
      $("select#class_lists").append("<option value='all_class' >All Classes</option>") 
    }
    $("input#semester_id").val(map[1].value)
    channel.push("hw_get_classes",{map: map, institution_id: institution_id})
    channel.on("hw_show_classes", payload=>{
      $("form#classes").show()
      $("div#gne").show()
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


// if (localStorage.getItem("logo_bin") != null) {
//   var bin = localStorage.getItem("logo_bin")
//   var img = "   <img id='school_logo' style='float:left; width:auto; height: 100px;' src='data:image/png;base64, "+bin+"'>"
// $("footer").append(img)
// }

// if (localStorage.getItem("maintain") != null) {
//   var bin = localStorage.getItem("maintain")
//   var maintain =  "<p style='padding-top: 40px; float:left;'>Support by "+bin+"</p>"
// $("footer").append(maintain)
// }

//   channel.on("show_footer", payload => {
//     localStorage.setItem("logo_bin", payload.logo_bin)
//     localStorage.setItem("maintain", payload.maintain)
//       var bin = localStorage.getItem("logo_bin")
//       var img = "   <img id='school_logo' style='float:left; width:auto; height: 100px;' src='data:image/png;base64, "+bin+"'>"
//     $("footer").append(img)
//       var bin = localStorage.getItem("maintain")
//       var maintain = "<p style='padding-top: 40px; float:left;'>Support by "+bin+"</p>"
//     $("footer").append(maintain)
//   })

  $("div.student").click(function(){
    var student_id = $(this).attr("id")
    var institution_id = window.currentInstitute



    channel.push("inquire_student_details", {user_id: window.currentUser ,student_id: student_id,inst_id: window.currentInstitute })
     
  })


  

channel.on("show_student_details", payload => {
    $("div[aria-label='student_upload']").hide()
    $("div[aria-label='student_table']").hide()
    $("div[aria-label='student_details']").html(payload.html)
    var csrf = window.csrf
    $("input[name='_csrf_token']").val(csrf)
    $("button#delete_student").click(function(){
      var student_id = $("button#delete_student").attr("aria-label");
      channel.push("delete_student",{student_id: student_id})
    })
  })





  channel.on("show_student_details2", payload => {
    $("div[aria-label='student_details2']").html(payload.html)
    var csrf = payload.csrf;

    $("input[name='_csrf_token']").val(csrf)
    $("button#delete_student").click(function(){
      var student_id = $("button#delete_student").attr("aria-label");
      channel.push("delete_student",{student_id: student_id})
    })
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




       $("div.parent").click(function(){
    var icno = $(this).attr("id")
    channel.push("inquire_parent_details", {user_id: window.currentUser, institution_id: window.currentInstitute,semester_id: window.currentSemester, icno: icno})
  })




   channel.on("show_parent_details", payload => {
    $("div[aria-label='p_upload']").hide()
    $("div[aria-label='p_table']").hide()
    $("div[aria-label='parent_details']").html(payload.html)
    var csrf = window.csrf
    $("input[name='_csrf_token']").val(csrf)
  }) 



     $("div.teacher_timetable").click(function(){
    var code = $(this).attr("id")
    channel.push("inquire_teacher_timetable", {user_id: window.currentUser, code: code,institution_id: window.currentInstitute})
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



      if (data == null) {




        $("div#show_ni").hide();

         $("div#var").val("Please Create Project Nilam")
      }

      if (data != null) {
       $("input[name='below_satisfy']").val(data.below_satisfy)

   $("input[name='member_reading_quantity']").val(data.member_reading_quantity)

    $("input[name='page']").val(data.page)

     $("input[name='import_from_library']").val(data.import_from_library)

 $("input[name='count_page_number']").val(data.count_page)
     $("input[name='standard_id']").val(data.standard_id)
        $("input[name='id']").val(data.ids)

        }
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

  channel.push("standard_subject", {user_id: window.currentUser,standard_level: standard_level,ins_id: window.currentInstitute})
    
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

  channel.push("subject_test", {user_id: window.currentUser,institution_id: window.currentInstitute,standard_level: standard_level})
    
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

channel.on("show_standard_grade", payload => {
    var data = payload.grade

    console.log(data)

        $("table#standard_grade").DataTable({
            
            destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [ {
                    data: 'name'
                },
                {
                    data: 'max'
                },
                {
                    data: 'min'
                },
                {
                    data: 'gpa'
                },
                {
                    data: 'standard_id'
                }
               
            ]
        });
  })


channel.on("show_grade_co", payload => {
    var data = payload.grade

    console.log(data)

        $("table#co_grade").DataTable({
            
            destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [ {
                    data: 'name'
                },
                {
                    data: 'max'
                },
                {
                    data: 'min'
                },
                {
                    data: 'gpa'
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

  channel.push("result_grade", {user_id: window.currentUser,inst_id: window.currentInstitute,standard_level: standard_level})
    
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

  channel.push("grade_co", {user_id: window.currentUser,inst_id: window.currentInstitute,standard_level: standard_level})
    
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


$("div#class_info").hide();
$("div#class_subject").hide();
$("div#class_period").hide();
$("div#class_student").hide();
$("div#class_student_info").hide();

channel.on("show_class_info", payload => {

$("div#class_info").show();
$("div#class_msg").hide();
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
var teacher_id = payload.teacher_id

var teacher_name = payload.teacher_name

   $("input[name='class_name']").val(name)

   $("input[name='remark']").val(remark)

   $("input[name='institution_id']").val(institution_id)

   $("input[name='level_id']").val(level_id)

   $("select[name='teacher_id']").val(teacher_id)

   $("input[name='teacher_name']").val(teacher_name)
   
  })




$(".nav-link#class_subject").click(function() {

   
   var class_id=localStorage.getItem("class_id")
   var institution_id = window.currentInstitute;

  channel.push("class_subject", {user_id: window.currentUser,class_id: class_id,institution_id: institution_id})
    
  })



channel.on("show_class_subject", payload => {

$("div#class_info").hide();
$("div#class_msg").hide();
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
$("div#class_msg").hide();
$("div#class_subject").hide();
$("div#class_period").show();
$("div#class_student").hide();
$("div#class_student_info").hide();



 var data = payload.period
 $("table#period_list").DataTable({
            
            destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [ {
                    data: 'day_name'
                },
                {
                    data: 'end_time'
                },
                {
                    data: 'start_time'
                },
                {
                    data: 's_code'
                },
                {
                    data: 'id',
                    'fnCreatedCell': function(nTd, sData, oData, iRow, iCol) {
                   
                          $(nTd).html("<a href='/period/"+ oData.id +"/edit' target='_blank' >Edit</button>")
                    }
                },
               
            ]
        });




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

  channel.push("class_student", {semester_id: window.currentSemester,user_id: window.currentUser,class_id: class_id, inst_id: window.currentInstitute })
    
  })


channel.on("show_class_student", payload => {

$("div#class_info").hide();
$("div#class_msg").hide();
$("div#class_subject").hide();
$("div#class_period").hide();
$("div#class_student").show();
$("div#class_student_info").hide();

    $("#m1").html(payload.html);

  })


$(".nav-link#class_student_info").click(function() {
  $("div#class_msg").hide();

      var csrf = window.csrf

   var class_id=localStorage.getItem("class_id")

  channel.push("class_student_info", {csrf: csrf,semester_id: window.currentSemester, inst_id: window.currentInstitute,user_id: window.currentUser,class_id: class_id})
    
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



$("button[name='edit_period']").click(function() {

  var class_id=localStorage.getItem("class_id")
   var csrf = window.csrf

  channel.push("edit_period_class", {csrf: csrf,user_id: window.currentUser,class_id: class_id})
    
  })

      channel.on("show_class_edit_period", payload => {

    $("#drf").html(payload.html);

  })


$("button[aria-label='edit_a_period']").click(function() {
   var period_id = this.id


alert(period_id)
        channel2.push("edit_period", {period_id: period_id})
     
  });




     $(document).on('click', 'button[name="view_co_student"]', function () {
   var co_id = this.id


        channel.push("view_co_student", {co_id: co_id, inst_id: window.currentInstitute})
     
  });


      channel.on("show_class_edit_period", payload => {

    $("#drf").html(payload.html);

  })
  

        channel.on("show_co_student", payload => {

    $("#hyg").html(payload.html);

  })



  
  


  
})

