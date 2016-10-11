L.EditToolbar.Delete=L.Handler.extend({statics:{TYPE:"remove"},includes:L.Mixin.Events,initialize:function(e,t){if(L.Handler.prototype.initialize.call(this,e),L.Util.setOptions(this,t),this._deletableLayers=this.options.featureGroup,!(this._deletableLayers instanceof L.FeatureGroup))throw new Error("options.featureGroup must be a L.FeatureGroup");this.type=L.EditToolbar.Delete.TYPE},enable:function(){!this._enabled&&this._hasAvailableLayers()&&(this.fire("enabled",{handler:this.type}),this._map.fire("draw:deletestart",{handler:this.type}),L.Handler.prototype.enable.call(this),this._deletableLayers.on("layeradd",this._enableLayerDelete,this).on("layerremove",this._disableLayerDelete,this))},disable:function(){this._enabled&&(this._deletableLayers.off("layeradd",this._enableLayerDelete,this).off("layerremove",this._disableLayerDelete,this),L.Handler.prototype.disable.call(this),this._map.fire("draw:deletestop",{handler:this.type}),this.fire("disabled",{handler:this.type}))},addHooks:function(){var e=this._map;e&&(e.getContainer().focus(),this._deletableLayers.eachLayer(this._enableLayerDelete,this),this._deletedLayers=new L.LayerGroup,this._tooltip=new L.Tooltip(this._map),this._tooltip.updateContent({text:L.drawLocal.edit.handlers.remove.tooltip.text}),this._map.on("mousemove",this._onMouseMove,this))},removeHooks:function(){this._map&&(this._deletableLayers.eachLayer(this._disableLayerDelete,this),this._deletedLayers=null,this._tooltip.dispose(),this._tooltip=null,this._map.off("mousemove",this._onMouseMove,this))},revertLayers:function(){this._deletedLayers.eachLayer(function(e){this._deletableLayers.addLayer(e),e.fire("revert-deleted",{layer:e})},this)},save:function(){this._map.fire("draw:deleted",{layers:this._deletedLayers})},_enableLayerDelete:function(e){var t=e.layer||e.target||e;t.on("click",this._removeLayer,this)},_disableLayerDelete:function(e){var t=e.layer||e.target||e;t.off("click",this._removeLayer,this),this._deletedLayers.removeLayer(t)},_removeLayer:function(e){var t=e.layer||e.target||e;this._deletableLayers.removeLayer(t),this._deletedLayers.addLayer(t),t.fire("deleted")},_onMouseMove:function(e){this._tooltip.updatePosition(e.latlng)},_hasAvailableLayers:function(){return 0!==this._deletableLayers.getLayers().length}});