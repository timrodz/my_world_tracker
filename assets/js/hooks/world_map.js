import L from "leaflet";

// Fix default marker icon path issue with bundlers
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl:
    "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png",
  iconUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png",
  shadowUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png",
});

const SHIP_COLOR = "#22c55e";
const DC_COLOR = "#3b82f6";
const OIL_COLOR = "#f97316";

function shipIcon() {
  return L.divIcon({
    className: "",
    html: `<div style="width:8px;height:8px;background:${SHIP_COLOR};border:1.5px solid white;border-radius:50%;box-shadow:0 1px 3px rgba(0,0,0,.4)"></div>`,
    iconSize: [8, 8],
    iconAnchor: [4, 4],
  });
}

function dcIcon() {
  return L.divIcon({
    className: "",
    html: `<div style="width:10px;height:10px;background:${DC_COLOR};border:1.5px solid white;border-radius:2px;box-shadow:0 1px 3px rgba(0,0,0,.4)"></div>`,
    iconSize: [10, 10],
    iconAnchor: [5, 5],
  });
}

function oilIcon() {
  return L.divIcon({
    className: "",
    html: `<div style="width:10px;height:10px;background:${OIL_COLOR};border:1.5px solid white;border-radius:50%;box-shadow:0 1px 3px rgba(0,0,0,.4)"></div>`,
    iconSize: [10, 10],
    iconAnchor: [5, 5],
  });
}

const WorldMap = {
  mounted() {
    const el = this.el;

    const ships = JSON.parse(el.dataset.ships || "[]");
    const dataCenters = JSON.parse(el.dataset.dataCenters || "[]");
    const oilFacilities = JSON.parse(el.dataset.oilFacilities || "[]");

    this.map = L.map(el, { zoomControl: true }).setView([20, 0], 2);

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      // attribution:
      // '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      maxZoom: 18,
    }).addTo(this.map);

    this.shipMarkers = {};
    this.shipLayer = L.layerGroup().addTo(this.map);
    this.dcLayer = L.layerGroup().addTo(this.map);
    this.oilLayer = L.layerGroup().addTo(this.map);

    L.control
      .layers(
        null,
        {
          "🚢 Ships": this.shipLayer,
          "🖥 Data Centers": this.dcLayer,
          "🛢 Oil Facilities": this.oilLayer,
        },
        { collapsed: false },
      )
      .addTo(this.map);

    ships.forEach((s) => this._addShip(s));
    dataCenters.forEach((dc) => this._addDc(dc));
    oilFacilities.forEach((oil) => this._addOil(oil));

    this.handleEvent("ship-updated", (ship) => this._updateShip(ship));
  },

  destroyed() {
    if (this.map) {
      this.map.remove();
      this.map = null;
    }
  },

  _addShip(ship) {
    if (ship.latitude == null || ship.longitude == null) return;

    const popup = L.popup({ closeButton: false, maxWidth: 200 }).setContent(
      `<div class="text-sm">
        <p class="font-semibold">${ship.name || "Unknown vessel"}</p>
        <p class="text-xs text-gray-500">MMSI: ${ship.mmsi}</p>
        ${ship.flag ? `<p class="text-xs">Flag: ${ship.flag}</p>` : ""}
        ${ship.speed != null ? `<p class="text-xs">Speed: ${ship.speed} kn</p>` : ""}
        ${ship.destination ? `<p class="text-xs">Dest: ${ship.destination}</p>` : ""}
      </div>`,
    );

    const marker = L.marker([ship.latitude, ship.longitude], {
      icon: shipIcon(),
    })
      .bindPopup(popup)
      .addTo(this.shipLayer);

    this.shipMarkers[ship.mmsi] = marker;
  },

  _updateShip(ship) {
    if (ship.latitude == null || ship.longitude == null) return;

    const existing = this.shipMarkers[ship.mmsi];
    if (existing) {
      existing.setLatLng([ship.latitude, ship.longitude]);
    } else {
      this._addShip(ship);
    }
  },

  _addDc(dc) {
    if (dc.latitude == null || dc.longitude == null) return;

    const popup = L.popup({ closeButton: false, maxWidth: 220 }).setContent(
      `<div class="text-sm">
        <p class="font-semibold">${dc.name}</p>
        <p class="text-xs text-blue-600 font-medium">${dc.operator}</p>
        ${dc.city ? `<p class="text-xs text-gray-500">${dc.city}${dc.country_code ? ", " + dc.country_code : ""}</p>` : ""}
      </div>`,
    );

    L.marker([dc.latitude, dc.longitude], { icon: dcIcon() })
      .bindPopup(popup)
      .addTo(this.dcLayer);
  },

  _addOil(oil) {
    if (oil.latitude == null || oil.longitude == null) return;

    const typeLabel =
      {
        oil_field: "Oil Field",
        refinery: "Refinery",
        lng_terminal: "LNG Terminal",
        offshore_platform: "Offshore Platform",
      }[oil.facility_type] || oil.facility_type;

    const popup = L.popup({ closeButton: false, maxWidth: 220 }).setContent(
      `<div class="text-sm">
        <p class="font-semibold">${oil.name}</p>
        <p class="text-xs text-orange-600 font-medium">${typeLabel}</p>
        ${oil.operator ? `<p class="text-xs text-gray-500">${oil.operator}</p>` : ""}
        ${oil.country_code ? `<p class="text-xs text-gray-400">${oil.country_code}</p>` : ""}
      </div>`,
    );

    L.marker([oil.latitude, oil.longitude], { icon: oilIcon() })
      .bindPopup(popup)
      .addTo(this.oilLayer);
  },
};

export default WorldMap;
