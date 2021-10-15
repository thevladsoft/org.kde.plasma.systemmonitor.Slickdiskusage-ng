/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
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
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
import org.kde.kcoreaddons 1.0 as KCoreAddons
import QtQuick.Controls 2.5
Applet {
    id: root

    onSourceAdded: {
        
        var match = source.match(/^partitions(.+)\/filllevel/);
        if (match) {
            var freeSource = "partitions" + match[1] + "/freespace";
            root.addSource(source, match[1], freeSource, match[1]);
        }
    }

    delegate: Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        //Layout.topMargin: 0
        //Layout.bottomMargin: 0
        PlasmaComponents.Label {
            id: label
            text: model.friendlyName1 == "/__root__" ? "/ " : model.friendlyName1
            style: Text.Outline
            anchors {
                left: parent.left
                bottom: progressBar.top
                bottomMargin: -10
            }
        }
        PlasmaComponents.Label {
            id: freeSpace
            style: Text.Outline
            anchors {
                right: parent.right
                bottom: progressBar.top
                bottomMargin: -10
            }
        }
        ProgressBar {
            id: progressBar
            from: 0
            to: 100
            opacity: 0.5
            //palette.highlight: Qt.rgba(Math.random(),Math.random(),Math.random(),1)//Qt.tint("#3daee9",Qt.rgba(Math.random,Math.random,Math.random,0.5))//Qt.rgba(value/100.,0.5,0.3,1)//Qt.darker("#3daee9",(value-50.)/50.)
            palette.highlight: Qt.lighter(Qt.tint("#3daee9",Qt.rgba(Math.random(),Math.random(),Math.random(),0.4)),1.5-value/100)
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
        }
        Connections {
            target: model.dataSource
            onNewData: {
                if (sourceName.indexOf(decodeURIComponent(model.source1)) != 0) {
                    return;
                }

                var data1 = model.dataSource.data[decodeURIComponent(model.source1)];
                var data2 = model.dataSource.data[decodeURIComponent(model.source2)];

                if (data1 !== undefined && data1.value !== undefined) {
                    progressBar.value = data1.value;
                }

                if (data2 !== undefined && data2.value !== undefined) {
                    freeSpace.text = KCoreAddons.Format.formatByteSize(data2.value * 1024);
                }
            }
        }
    }
}
