$(document).ready(function(){$("#redhatSubscriptionTable").treeTable({expandable:true,initialState:"collapsed",clickableNodeNames:true,onNodeShow:function(){$.sparkline_display_visible()}});KT.common.jscroll_init($(".scroll-pane"));KT.common.jscroll_resize($(".jspPane"));$("#products_table").treeTable({expandable:true,initialState:"collapsed",clickableNodeNames:true,onNodeShow:function(){$.sparkline_display_visible()}});$('#products_table input[type="checkbox"]').live("change",function(){KT.redhat_provider_page.checkboxChanged($(this))});$("#upload_submit").click(function(){$(this).closest("form").submit()})});KT.redhat_provider_page=(function(c){var a=function(g){var f=g.attr("name");var e={};if(g.attr("checked")!==undefined){e[f]="1"}else{e[f]="0"}var d=g.attr("data-url");var h=g.attr("value");c(g).hide();c("#spinner_"+h).removeClass("hidden").show();c.ajax({type:"PUT",url:d,data:e,cache:false,success:function(j,k,i){KT.redhat_provider_page.checkboxHighlightRow(j)}});return false};var b=function(d){c("#repo-"+d).effect("highlight",{color:"#390"},1000);c("#spinner_"+d).hide().addClass("hidden");c("#input_repo_"+d).show()};return{checkboxChanged:a,checkboxHighlightRow:b}}(jQuery));