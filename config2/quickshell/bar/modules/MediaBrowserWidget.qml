import QtQuick
import Quickshell

// Combined screenshots/videos browser launcher.
// Left-click = screenshots, right-click = videos. Sits left of the theme icon.
Item {
    id: rootMod
    required property var root

    visible: implicitWidth > 0.5
    implicitWidth: root.modMediaBrowser ? 22 : 0
    opacity: root.modMediaBrowser ? 1 : 0
    Behavior on implicitWidth { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    implicitHeight: 28

    Text {
        anchors.centerIn: parent
        text: String.fromCodePoint(0xF021B)   // nf-md-image_multiple
        font.family: root.mono; font.pixelSize: 14
        color: root.mediaBrowserVisible
            ? root.seal
            : Qt.rgba(root.ink.r, root.ink.g, root.ink.b, 0.65)
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    TooltipMixin {
        id: tip; root: rootMod.root; owner: rootMod
        text: "L: Screenshots  R: Videos"
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onEntered: tip.show()
        onExited:  tip.hide()
        onClicked: function(mouse) {
            tip.hide()
            if (root.mediaBrowserVisible) {
                root.mediaBrowserVisible = false
                return
            }
            root.mediaBrowserMode    = (mouse.button === Qt.RightButton) ? "videos" : "screenshots"
            root.mediaBrowserVisible = true
        }
    }
}
