(function(){var t;t=this,t.MapSettings=function(){return this.init()},MapSettings.prototype.init=function(){return find_geocodes(),$(".leaflet-control-zoom-out, .leaflet-control-zoom-in").click(function(){return $("html, body").animate({scrollTop:0},0)}),$("[id$=form_zoom_level]").change(function(){var t;return leaf.map.setZoom(t=$("[id$=form_zoom_level]").val())}),leaf.map.on("zoomend",function(){return $("[id$=form_zoom_level]").val(leaf.map.getZoom())}),$("#map_settings_form_chosen_map").change(function(){var t;return t="",$("select option:selected").each(function(){return map_settings.chosen_map=$(this).val(),initLeafletMap(map_settings)})})}}).call(this);