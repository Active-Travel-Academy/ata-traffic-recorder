const pgLoad = () => {
  if (window.mapsRendered) {
    return
  }
  Array.from(document.getElementsByClassName('edit_map')).forEach( (mapEl) => {
    let lat = 51.505
    let lng = -0.09
    const schemeEl = document.getElementById('scheme-default')
    if (schemeEl && schemeEl.dataset && schemeEl.dataset.lat) {
      lat = schemeEl.dataset.lat
      lng = schemeEl.dataset.lng
    }

    const map = L.map(mapEl).setView([lat, lng], 13);

    // Add OpenStreetMap tiles
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors'
    }).addTo(map);

    // Initialize Leaflet Draw
    var drawnItems = new L.FeatureGroup();
    map.addLayer(drawnItems);

    var drawControl = new L.Control.Draw({
      edit: {
        featureGroup: drawnItems
      },
      draw: {
        polygon: false,
        polyline: false,
        rectangle: false,
        circle: false,
        marker: true,
        circlemarker: false,
      }
    });
    map.addControl(drawControl);

    // Event handler for when a point is drawn
    map.on('draw:created', function (e) {
      var type = e.layerType,
          layer = e.layer;

      if (type === 'marker') {
        // Clear existing markers
        drawnItems.clearLayers();
        // Add new marker
        drawnItems.addLayer(layer);

        // Get the coordinates
        var coordinates = layer.getLatLng();
        document.getElementById(`${mapEl.dataset.formPrefix}_lat`).value = coordinates.lat;
        document.getElementById(`${mapEl.dataset.formPrefix}_lng`).value = coordinates.lng;
      }
    });
  })

  Array.from(document.getElementsByClassName('show_map')).forEach( (mapEl) => {

    const map = L.map(mapEl)

    const pts = mapEl.dataset

    const markers = []
    markers.push(new L.marker([pts.originLat, pts.originLng]).addTo(map))
    markers.push(new L.marker([pts.destLat, pts.destLng]).addTo(map))

    if(pts.waypointLat) {
      markers.push(new L.marker([pts.waypointLat, pts.waypointLng]).addTo(map))
    }

    const group = new L.featureGroup(markers);

    map.fitBounds(group.getBounds().pad(0.5))

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors'
    }).addTo(map);
  })
  window.mapsRendered = true
}
// On 422 unprocessable_entity turbo seems to render but not load,
// otherwise it seems to load and not render...
document.addEventListener('turbo:load', pgLoad)
document.addEventListener('turbo:render', pgLoad)
