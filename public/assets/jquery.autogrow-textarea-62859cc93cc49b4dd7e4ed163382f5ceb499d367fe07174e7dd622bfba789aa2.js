!function(e){e.fn.autogrow=function(t){return this.filter("textarea").each(function(){var t=this,n=e(t),i=n.height(),s=n.hasClass("autogrow-short")?0:parseInt(n.css("lineHeight")),o=e("<div></div>").css({position:"absolute",top:-1e4,left:-1e4,width:n.width(),fontSize:n.css("fontSize"),fontFamily:n.css("fontFamily"),fontWeight:n.css("fontWeight"),lineHeight:n.css("lineHeight"),resize:"none"}).appendTo(document.body),r=function(){var e=function(e,t){for(var n=0,i="";t>n;n++)i+=e;return i},r=t.value.replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/&/g,"&amp;").replace(/\n$/,"<br/>&nbsp;").replace(/\n/g,"<br/>").replace(/ {2,}/g,function(t){return e("&nbsp;",t.length-1)+" "});o.css("width",n.width()),o.html(r),n.css("height",Math.max(o.height()+s,i))};n.change(r).keyup(r).keydown(r),e(window).resize(r),r()})}}(jQuery);