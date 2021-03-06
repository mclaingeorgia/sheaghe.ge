(function() {
  var map = {
    default_options: {
      zoom: 16,
      coordinates: [41.74288345375358, 44.74130630493165],
      type: 'coordinate' // locator uses inputs, data uses data attributes,
      // coordinate uses options coordinates, coordinates - multiple markers from gon.coordinates

    },
    maps: {},
    init: function(id, options) { // id without #

      var t = map
      var $mp = $('#' + id)
      var lat
      var lon
      var opts = {}
      options = $.extend({}, t.default_options, options)
      var type = options.type
      var coordinates = options.coordinates

      if($mp.length) {
        if(type === 'locator') {
          lat = +$("input[name$='[latitude]'").val()
          lon = +$("input[name$='[longitude]'").val()
        }
        else if(type === 'data') {
          lat = +$mp.attr("data-latitude")
          lon = +$mp.attr("data-longitude")
        }
        else if(type === 'coordinate') {
          // already merged
        }

        if(lat > 0) { coordinates[0] = lat }
        if(lon > 0) { coordinates[1] = lon }

        var mp = L.map(id, {zoomControl: false,
         maxBounds: [ // only georgia and area around can be selected
          [46.119,35.618],
          [39.419,49.197]
          // only georgia can be selected
          // [43.784728, 39.891357],
          // [40.919480, 46.845703]
        ]
      }).setView(coordinates, options.zoom);
        t.maps[id] = mp
        // mp.fitBounds();


        pollution.elements[id] = mp

        L.tileLayer(gon.osm, { attribution: gon.osm_attribution, accessToken: gon.osm_accessToken, id: gon.osm_id })
          .addTo(mp)

        var markerGroup = L.layerGroup().addTo(mp)
        pollution.elements[id + '_marker_group'] = markerGroup

        if(type !== 'coordinates') {
          var marker = L.marker(coordinates, {icon: pollution.elements.pin })
            .addTo(markerGroup)
            if(options.hasOwnProperty('popup')) {
              marker.bindPopup(options.popup);
            }
        }

        if (options.scrollWheelZoom === false){
          mp.scrollWheelZoom.disable()
        }

        var map_container = $mp.parent()

        map_container.find('.map-zoomer .in').click(function(){
          mp.setZoom(mp.getZoom() + 1)
        });

        map_container.find('.map-zoomer .out').click(function(){
          mp.setZoom(mp.getZoom() - 1)
        });


        if(options.locate) {
          mp.locate({setView: true, maxZoom: 12});
        }
        if(type === 'locator') {
          mp.on('click', function(e) {
            locate(e.latlng)
          });
          $('#place_region_id').on('change', function(){
            var $selected_option = $(this).find('option:selected')
            mp.flyTo([$selected_option.data('lat'), $selected_option.data('lon')], 10)
          })
          $('#place_municipality_id').on('change', function(){
            var $selected_option = $(this).find('option:selected')
            mp.flyTo([$selected_option.data('lat'), $selected_option.data('lon')], 12)
          })
          $('.map-locator').click(function () {
            mp.locate({setView: true, maxZoom: 16});
          })
          mp.on('locationfound', function(e) {
            locate(e.latlng)
          });
          mp.on('locationerror', function(e) {
            $('.map-locator').addClass('disabled')
          });

          function locate(latlng) {
            $("input[name$='[latitude]'").val(latlng.lat)
            $("input[name$='[longitude]'").val(latlng.lng)
            marker.setLatLng(L.latLng(latlng.lat, latlng.lng));
          }
        }
      }
    },
    render_markers: function (id, locations) {
      if(pollution.elements.hasOwnProperty(id)) {
        var markerGroup = pollution.elements[id + '_marker_group']
        var popup_template = '<div class="header"><a href="%path">%name</a></div><ul class="contact"><li><span class="icon address"></span>%address</li><li><span class="icon phone"></span>%phone</li></ul>'

        // console.log("-----------------------------",locations)
        locations.forEach(function(location) {
          // console.log(location.coordinates)
          var mrk = L.marker(location.coordinates.map(function(m) { return +m }), {icon: pollution.elements.pin, alt: location.name, title: location.name }).addTo(markerGroup)
          // add place_id field so can find marker and highlight when hover over place in the sidebar
          mrk.place_id = location.id
          mrk.bindPopup(popup_template.replace(/%path/g, location.path).replace(/%name/g, location.name).replace(/%address/g, location.address).replace(/%phone/g, location.phone));
          mrk.on('popupclose', function () {
            // change the icon
            this.setIcon(pollution.elements.pin)

            // remove place highlight
            $('.results-container.slide-in .place-card.highlighted').removeClass('highlighted')
          })
          if(device.desktop()) {
            mrk.on('click', function() {
              // change the icon
              this.setIcon(pollution.elements.pin_highlight)

              // if the details view is open, highlight this place
              var $results = $('.results-container.slide-in')
              if ($results.length > 0){
                var results = $results.get(0)
                var $place_card = $results.find('.place-card[data-place-id="' + location.id + '"]')
                var place_card = $place_card.get(0)

                if(typeof place_card.scrollIntoView === 'function') {
                  place_card.scrollIntoView({block: "end", behavior: "smooth"});
                }
                else {
                  results.scrollTop = place_card.offsetTop - results.offsetTop
                }
                $place_card.addClass('highlighted')

                $place_card.one(animationEvent, function(event) { console.log('transition end'); $place_card.removeClass('highlighted') })
              }
            })
          }
        })
      }
    },
    set_view: function (id, coordinates, zoom, fly) {
      var t = map
      if(t.maps.hasOwnProperty(id)) {
        if(fly) {
          t.maps[id].flyTo(L.latLng(coordinates[0], coordinates[1]), zoom)
        } else {
          t.maps[id].setView(L.latLng(coordinates[0], coordinates[1]), zoom)
        }

      }
    }
  }


  map.init('contact_map', { zoom: 17, coordinates: [41.70978, 44.76133], type: 'coordinate' })
  map.init('locator_map', { zoom: 13, type: 'locator' })
  pollution.components.map = map
}())
