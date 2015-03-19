/**
 * Main function that initializes the map on different screens (eg home page, map setting page, ad page...).
 * @param map_settings_array - hash that contains all info needed to initialize the map.
 */
function initLeafletMap(map_settings_array){

    var mylat = map_settings_array['lat'];
    var mylng = map_settings_array['lng'];

    // In case a map was already loaded, we remove it, so we can reload it properly.
    if (map != null){
        map.remove();
    }

    // Map tiles initialization
    var maptiles = "";
    if (map_settings_array['chosen_map'] == 'mapbox' || map_settings_array['chosen_map'] == 'osm'){
        // Mapbox or OSM
        maptiles = L.tileLayer(map_settings_array['tiles_url'], {
            attribution: map_settings_array['attribution']
        });
    }else{
        // Mapquest
        maptiles = MQ.mapLayer();
    }

    map = L.map('map');
    maptiles.addTo(map);
    map.setView([mylat, mylng], map_settings_array['zoom_level']);


    if (map_settings_array['hasCenterMarker'] == true){
        // Center marker on the map
        // Appearing only in admin map setting, and admin location page, on page load.
        // Define first if it should be the area icon (for addresses based only on postal codes), or the default icon.
        var icon_to_use = defaultIcon;
        if (map_settings_array['is_area']){
            icon_to_use = areaIcon;
        }else if (map_settings_array['category_color'] && map_settings_array['category_icon']){
            // Used on the ad detail page (ads#show)
            icon_to_use = L.AwesomeMarkers.icon({
                prefix: 'fa',
                markerColor: map_settings_array['category_color'],
                icon: map_settings_array['category_icon']
            });
        }


        // we are displaying the center point.
        var center_marker = L.marker([ mylat, mylng ], {icon: icon_to_use});
        if (map_settings_array['marker_message'] != ""){
            center_marker.addTo(map).bindPopup(map_settings_array['marker_message']).openPopup();
        }else{
            center_marker.addTo(map);
        }

    }

    if (map_settings_array['clickableMapMarker'] != 'none'){
        // Getting latitude and longitude of clicked point on the map.
        map.on('click', onMapClickLocation);
    }

    if (map_settings_array['page'] == 'searchedLocationOnHome'){
        // Adding marker for the searched address, on the home page.
        L.marker([ mylat, mylng ], {icon: defaultIcon}).addTo(map).bindPopup(
            map_settings_array['searched_address']).openPopup();
    }

    if (map_settings_array['page'] == 'mapsettings'){
        map.on('zoomend', function() {
            $('#zoom_level').val(map.getZoom());
        });
    }

}

/**
 * Populates the map with different markers (eg exact address and area-type markers, to show ads)
 * @param locations_hash - hash containing the info to create all different markers.
 */
function putLocationMarkers(){

    // The MarkerClusterGroup object will allow to aggregate location markers (both 'exact location' and 'area' markers),
    // when they get too close to one another, as the user zooms out, on the home page.
    markers = new L.MarkerClusterGroup({spiderfyDistanceMultiplier : 2, zoomToBoundsOnClick: false});

    // Loop that create markers, to represent ads tied to exact-type location.
    for (var i=0; i<locations_exact.length; i++){
        var location = locations_exact[i];

        for (var j=0; j<location['ads'].length; j++){
            var popup_html_text;
            var marker;

            var ad = location['ads'][j];

            var marker_icon = L.AwesomeMarkers.icon({
                prefix: 'fa',
                markerColor: ad['item']['category']['marker_color'],
                icon: ad['item']['category']['icon']
            });

            // HTML snippet for the popup
            if (location['name'] != ''){
                popup_html_text = createPopupHtml("<b>"+location['name']+"</b><br />" +location['street_number'] + " " + location['address'], ad);
            }else{
                popup_html_text = createPopupHtml("<b>" +location['street_number'] + " " + location['address'], ad);
            }

            marker = L.marker([location['latitude'], location['longitude']], {icon: marker_icon, title: location['full_address']})
            var popup = L.popup({minWidth: 250}).setContent(popup_html_text);

            marker.bindPopup(popup);
            markers.addLayer(marker);

        }
    }

    // Snippet that create markers, to represent ads tied to postal-type location.
    if (locations_postal != null && Object.keys(locations_postal).length > 0){
        Object.keys(locations_postal).forEach(function (area_code) {
            var locations = locations_postal[area_code];

            var popup_html_text = createPopupHtmlArea("In this area (<b>"+area_code+"</b>)<br /><br />", locations);

            marker = new L.marker(
                [area_geocodes[area_code]['latitude'],area_geocodes[area_code]['longitude']],
                {icon: areaIcon, title: area_code}
            );

            marker.bindPopup(popup_html_text);
            markers.addLayer(marker);
        })
    }

    // Snippet that create markers, to represent ads tied to district-type location.
    if (locations_district != null && Object.keys(locations_district).length > 0){
        Object.keys(locations_district).forEach(function (district_id) {
            var locations = locations_district[district_id];

            var popup_html_text = createPopupHtmlArea("In this district (<b>"+area_geocodes[district_id]['name']+"</b>)<br /><br />", locations);

            marker = new L.marker(
                [area_geocodes[district_id]['latitude'],area_geocodes[district_id]['longitude']],
                {icon: areaIcon, title: area_geocodes[district_id]['name']}
            );

            marker.bindPopup(popup_html_text);
            markers.addLayer(marker);
        })
    }

    map.addLayer(markers);

}


/**
 * Creates the text to be shown in a marker popup, giving details about the selected exact location.
 * @param first_sentence
 * @param location
 * @returns Popup text content.
 */
function createPopupHtml(first_sentence, ad){
    var second_sentence = '';
    var result = '';

    var popup_ad_link = "<a href='/ads/"+ad['id']+"/'>"+ad['title']+"</a>";
    var popup_item_name = "<span style='color:" + marker_colors[ad['item']['category']['marker_color']] + "';><strong>" + ad['item']['name'] + "</strong></span>";

    if (ad['is_giving'] == true){
        second_sentence = "Item(s) being given away:<br />" + popup_item_name + ': ' + popup_ad_link + '<br />';
    }else{
        second_sentence = "Item(s) being searched for:<br />" + popup_item_name + ': ' + popup_ad_link + '<br />';
    }

    if (ad['image']['thumb']['url'] != null && ad['image']['thumb']['url'] != ''){
        // Popup is created with a thumbnail image in it.
        var ad_image = "<img src='"+ad['image']['thumb']['url']+"'>";
        result =  "<div style='overflow: auto;'><div class='col-sm-6'>"+first_sentence+"</div><div class='col-sm-6'>"+ad_image+"</div><div class='col-sm-12'><br>"+second_sentence+"</div></div>";
    }else{
        // Popup is created without any thumbnail image.
        result =  "<div style='overflow: auto;'>"+first_sentence+"<br><br>"+second_sentence+"</div>";
    }

    return result;
}

/**
 * Creates the text to be shown in a marker popup,
 * giving details about the selected area-type location (postal or district).
 * @param first_sentence
 * @param location
 * @returns Popup text content.
 */
function createPopupHtmlArea(first_sentence, locations_from_same_area){
    var is_giving_item = false;
    var is_accepting_item = false;

    var people_give = "Item(s) being given away:<br />";
    var people_accept = "Item(s) being searched for:<br />";
    for (var i=0; i<locations_from_same_area.length; i++){
        var location = locations_from_same_area[i];
        for (var j= 0; j<location['ads'].length; j++){
            var ad = location['ads'][j];

            var popup_item_name = "<span style='color:" + marker_colors[ad['item']['category']['marker_color']] + "';><strong>" + ad['item']['name'] + "</strong></span>";
            var popup_ad_link = "<a href='/ads/"+ad['id']+"/'>"+ad['title']+"</a>";

            if (ad['is_giving'] == true){
                is_giving_item = true;
                people_give = people_give + popup_item_name + ': ' + popup_ad_link + '<br />';
            }else{
                is_accepting_item = true;
                people_accept = people_accept + popup_item_name + ': ' + popup_ad_link + '<br />';
            }
        }
    }

    if (!is_giving_item && is_accepting_item){
        first_sentence = first_sentence + people_accept;
    }else if (!is_accepting_item && is_giving_item){
        first_sentence = first_sentence + people_give;
    }else{
        first_sentence = first_sentence + people_give + '<br />' + people_accept;
    }

    return first_sentence;

}

/**
 * This method initialize the right-hand side navigation bar, on the home page.
 */
function initializeSideBar(sidebar){

    // Side bar is shown, right before initializing it, after map is fully loaded.
    $('#sidebar').removeClass('hide');

    var sidebar = L.control.sidebar('sidebar', {
        closeButton: true,
        position: 'right'
    });

    // Navigation toggle button
    var btn = L.functionButtons([{ content: '<strong>Categories</strong>' }]);

    map.addControl(sidebar);

    var isSidebarOpen = false;
    var window_width = $(window).width();

    if (window_width < 768){
        map.addControl(btn);
    }else{
        sidebar.show();
        isSidebarOpen = true;
    }

    map.on('click', function () {
        if (isSidebarOpen){
            sidebar.hide();
            map.addControl(btn);
            isSidebarOpen = false;
        }
    });

    btn.on('clicked', function(data) {
        if( data.idx == 0 ) {
            sidebar.show();
            isSidebarOpen = true;
            map.removeControl(btn);
        }else{
            sidebar.hide();
            isSidebarOpen = false;
            map.addControl(btn);
        }
    });

    $('.leaflet-sidebar .close').click(function(){
        map.addControl(btn);
        isSidebarOpen = false;
    });

    // By default, we hide the navigation bar on phones and tablets (width < 992).
    // We should only see the map, when home page loads on mobile device.
    $(window).resize(function() {
        window_width = $(window).width();
        if (window_width < 768){
            sidebar.hide();
            if (isSidebarOpen){
                map.addControl(btn);
                isSidebarOpen = false;
            }
        }else{
            sidebar.show();
            if (!isSidebarOpen){
                map.removeControl(btn);
                isSidebarOpen = true;
            }
        }
    });

}


/**
 * Defines latitude and longitude, after a click on a map (eg on map settings page...).
 * Updates hidden fields, if needed, if the geocodes are part of a form.
 */
function onMapClickLocation(e) {
    var newGeocodes = onMapClick(e);
    var geocodeSplit= newGeocodes.split(',');

    // latitude_text and longitude_text are classes used on area settings page.
    $(".latitude_text").text(geocodeSplit[0]);
    $(".longitude_text").text(geocodeSplit[1]);
    $("#new_district_button_add").removeClass('disabled');


    $(".latitude_hidden").val(geocodeSplit[0]);
    $(".longitude_hidden").val(geocodeSplit[1]);

}

/**
 * Callback fundtion that returns geocodes of clicked location.
 * @param e
 * @returns "latitude,longitude"
 */
function onMapClick(e) {

	if (newmarker != null){
		map.removeLayer(newmarker);
	}
	
	var myNewLat = e.latlng.lat;
	var myNewLng = e.latlng.lng;

    // Rounding up latitude and longitude, with 5 decimals
    myNewLat = Math.round(myNewLat*100000)/100000;
    myNewLng = Math.round(myNewLng*100000)/100000;

    if (location_marker_type == 'exact'){
        newmarker = new L.Marker(e.latlng, {icon: newIcon}, {draggable:false});
    }else if (location_marker_type == 'area'){
        newmarker = new L.Marker(e.latlng, {icon: areaIcon}, {draggable:false});
    }

    map.addLayer(newmarker);

    return myNewLat+','+myNewLng;
}

/**
 * Function that display a single marker, with its relevant location details, on a map.
 * @param lat
 * @param lng
 * @param location_marker_type
 * @param name
 */
function putSingleMarker(lat, lng, location_marker_type, name){
    if (newmarker != null){
        map.removeLayer(newmarker);
    }

    if (location_marker_type == 'exact'){
        newmarker = new L.Marker([lat,lng], {icon: newIcon}, {draggable:false});
    }else if (location_marker_type == 'area'){
        newmarker = new L.Marker([lat,lng], {icon: areaIcon}, {draggable:false});
    }

    map.addLayer(newmarker);

    newmarker.bindPopup(name).openPopup();
}