# for the Python console of QGIS

from PyQt5.QtCore import QVariant

for layer in QgsProject.instance ().mapLayers ().values ():
    if layer.name () == "countries_870":
        with edit (layer):
            layer.dataProvider ().addAttributes ( [ QgsField("geo_color",   QVariant.String) ] )
            layer.dataProvider ().addAttributes ( [ QgsField("geo_label_x", QVariant.Double) ] )
            layer.dataProvider ().addAttributes ( [ QgsField("geo_label_y", QVariant.Double) ] )
