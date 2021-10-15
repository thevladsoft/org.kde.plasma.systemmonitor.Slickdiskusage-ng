/*
 *   Copyright 2014 Marco Martin <mart@kde.org>
 *
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons

Item {
    id: rootItem

    signal sourceAdded(string source)
    property Component delegate

    width: units.gridUnit * 2
    height: units.gridUnit * 10
    Plasmoid.preferredRepresentation: plasmoid.fullRepresentation
    Layout.minimumWidth: units.gridUnit * 8 * (plasmoid.formFactor == PlasmaCore.Types.Horizontal ? sourcesModel.count : 1)
    Layout.minimumHeight: units.gridUnit * 4 * (plasmoid.formFactor == PlasmaCore.Types.Vertical ? sourcesModel.count : 1)

    Layout.preferredHeight: Layout.minimumHeight

    function addSource(source1, friendlyName1, source2, friendlyName2) {
        var found = false;
        for (var i = 0; i < sourcesModel.count; ++i) {
            var obj = sourcesModel.get(i);
            if (obj.source1 == encodeURIComponent(source1) &&
                obj.source2 == encodeURIComponent(source2)) {
                found = true;
                break;
            }
        }
        if (found) {
            return;
        }

        smSource.connectSource(source1);
        if (source2) {
            smSource.connectSource(source2);
        }

        sourcesModel.append(
           {"source1": encodeURIComponent(source1),
            "friendlyName1": friendlyName1,
            "source2": encodeURIComponent(source2),
            "friendlyName2": friendlyName2,
            "dataSource": smSource});
    }

    ListModel {
        id: sourcesModel
    }

    Component.onCompleted: {
        plasmoid.backgroundHints = PlasmaCore.Types.ShadowBackground
        for (var i in smSource.sources) {
            smSource.sourceAdded(smSource.sources[i]);
        }
    }

    PlasmaCore.DataSource {
        id: smSource

        engine: "systemmonitor"
        interval: 2000
        onSourceAdded: {
            if (plasmoid.configuration.sources.length > 0 &&
                plasmoid.configuration.sources.indexOf(encodeURIComponent(source)) === -1) {
                return;
            }
            rootItem.sourceAdded(source);
        }
        onSourceRemoved: {
            for (var i = sourcesModel.count - 1; i >= 0; --i) {
                var obj = sourcesModel.get(i);
                if (obj.source1 == source || obj.source2 == source) {
                    sourcesModel.remove(i);
                }
            }
            smSource.disconnectSource(source);
        }
    }
    Connections {
        target: plasmoid.configuration
        onSourcesChanged: {
            if (plasmoid.configuration.sources.length == 0) {
                for (var i in smSource.sources) {
                    var source = smSource.sources[i];
                    smSource.sourceAdded(source);
                }

            } else {
                var sourcesToRemove = [];

                for (var i = sourcesModel.count - 1; i >= 0; --i) {
                    var obj = sourcesModel.get(i);

                    if (plasmoid.configuration.sources.indexOf(encodeURIComponent(obj.source1)) === -1) {
                        sourcesToRemove.push(obj.source1);
                    }
                }

                for (i = 0; i < sourcesToRemove.length; ++i) {
                    smSource.sourceRemoved(sourcesToRemove[i]);
                }


                for (var i in plasmoid.configuration.sources) {
                    var source = decodeURIComponent(plasmoid.configuration.sources[i]);
                    smSource.sourceAdded(source);
                }
            }
        }
    }

    PlasmaExtras.Heading {
        id: heading
//         width: parent.width
//         height: 0
        level: 10
        text: plasmoid.title
//         visible: plasmoid.formFactor != PlasmaCore.Types.Horizontal && plasmoid.formFactor != PlasmaCore.Types.Vertical
        visible: false
    }

    ColumnLayout {
        //rows: 1
        //columns: 1
        //flow: plasmoid.formFactor != PlasmaCore.Types.Horizontal ? GridLayout.LeftToRight : GridLayout.TopToBottom
        anchors {
            top: heading.visible ? heading.bottom : parent.top
            bottom: parent.bottom
        }
        width: parent.width
//         Layout.topMargin: 0
//         Layout.bottomMargin: 0

        Repeater {
            model: sourcesModel
            delegate: rootItem.delegate
        }
    }
}
