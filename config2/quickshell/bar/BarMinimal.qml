// ─────────────────────────────────────────────────────────────────────────────
// BarMinimal — a compact, minimal top bar (alternative to BarSlot).
// Launcher (bob2 → control center) pinned left; clock + status group pinned right.
// Reuses the existing *Widget modules (they all take `root: theme`), so the widget
// visibility toggles (mod*) keep working here too. No drag/splits/island — by design.
// Selected via theme.barStyle === "minimal" (shell.qml Loader).
// ─────────────────────────────────────────────────────────────────────────────
import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "modules"

PanelWindow {
    id: bar
    required property var root

    color: "transparent"
    anchors { top: true; left: true; right: true }

    // bar strip height (where widgets live) + corner radius for the descending feet.
    readonly property int barH: 30
    readonly property int cornerR: 12

    // window is taller than the strip so the side "feet" can hang below it; only barH
    // is reserved in the layout, so the feet overlap the window below (don't push it).
    implicitHeight: barH + cornerR
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: barH

    // keep Hyprland awake while the idle-inhibitor toggle is on (same as BarSlot)
    IdleInhibitor { window: bar; enabled: bar.root.idleInhibited }

    // hide the whole bar (and release its reserved space) when toggled off
    visible: !bar.root.barHidden

    readonly property color barColor: Qt.rgba(bar.root.paper.r, bar.root.paper.g, bar.root.paper.b, bar.root.barOpacity)

    // ── inverted-rounding corner piece (adapted from Kriti-shell/InvertedRounding):
    //    a r×r square filled with bar colour EXCEPT a concave quarter-arc, so the bar
    //    appears to flow down into the screen edge. `flip` mirrors it for the right. ──
    component InvertedCorner: Shape {
        id: ic
        property real r: bar.cornerR
        property color col: bar.barColor
        property bool flip: false           // false = left corner, true = right
        width: r; height: r
        preferredRendererType: Shape.CurveRenderer
        transform: Scale { xScale: ic.flip ? -1 : 1; origin.x: ic.width / 2 }
        ShapePath {
            fillColor: ic.col
            strokeColor: "transparent"
            // fill the INNER region (complement of the previous shape): close the
            // polygon via the TOP edge so the solid hugs the inner side and the
            // concave arc faces outward. Arc direction unchanged (Counterclockwise).
            startX: 0;        startY: 0
            PathLine { x: ic.r;     y: 0 }      // across the top edge
            PathLine { x: ic.r;     y: ic.r }   // down the inner edge
            PathArc {
                x: 0; y: 0
                radiusX: ic.r; radiusY: ic.r
                direction: PathArc.Counterclockwise
            }
        }
    }

    // ── main bar strip: flat full-width rectangle, flush to top + sides ──
    Rectangle {
        id: strip
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: bar.barH
        color: bar.barColor

        // bottom hairline separator (stops short of the corners)
        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            anchors.leftMargin: bar.cornerR
            anchors.rightMargin: bar.cornerR
            height: 1
            color: bar.root.sep
        }
    }

    // descending corner pieces, hung right below the strip at each end.
    // (flip values kept as-is; only the left/right anchors are swapped so each
    //  curved piece sits on the correct side.)
    InvertedCorner {
        anchors { top: strip.bottom; left: strip.left }
        flip: true
    }
    InvertedCorner {
        anchors { top: strip.bottom; right: strip.right }
        flip: false
    }

    // ── LEFT: launcher (bob2 → control center) ──
    Item {
        id: leftGroup
        anchors.left: strip.left
        anchors.leftMargin: 10
        anchors.verticalCenter: strip.verticalCenter
        height: 28
        width: childrenRect.width

        Row {
            spacing: 10
            anchors.verticalCenter: parent.verticalCenter
            LauncherWidget  { id: wLauncher;  root: bar.root; anchors.verticalCenter: parent.verticalCenter }
            WorkspaceWidget { id: wWorkspace; root: bar.root; anchors.verticalCenter: parent.verticalCenter }
        }
    }

    // ── RIGHT: status group + clock, grouped together (macOS menu-bar feel) ──
    Item {
        id: rightGroup
        anchors.right: strip.right
        anchors.rightMargin: 10
        anchors.verticalCenter: strip.verticalCenter
        height: 28
        width: rightRow.implicitWidth

        Row {
            id: rightRow
            spacing: 10
            anchors.verticalCenter: parent.verticalCenter

            // Widgets grouped by function (each self-hides via its mod* flag, so the
            // Row's spacing collapses naturally when one is off). Left→right:
            //   media/capture · system resources · connectivity/power ·
            //   alerts & system actions · clock+date (rightmost).
            // (workspaces live in the LEFT group, next to the launcher.)

            // — media / capture —
            MprisWidget           { id: wMpris;   root: bar.root; anchors.verticalCenter: parent.verticalCenter }
            VoxtypeWidget         { root: bar.root; anchors.verticalCenter: parent.verticalCenter }
            MediaBrowserWidget    { root: bar.root; anchors.verticalCenter: parent.verticalCenter }
            ScreenRecordWidget    { root: bar.root; anchors.verticalCenter: parent.verticalCenter }

            // — system resources / info —
            ClaudeWidget          { root: bar.root; anchors.verticalCenter: parent.verticalCenter }
            NetworkWidget         { id: wNetwork; root: bar.root; anchors.verticalCenter: parent.verticalCenter }
            CpuWidget             { id: wCpu;     root: bar.root; anchors.verticalCenter: parent.verticalCenter }
            MemoryWidget          { id: wMemory;  root: bar.root; anchors.verticalCenter: parent.verticalCenter }

            // — connectivity & power —
            BluetoothWidget       { id: wBluetooth; root: bar.root; anchors.verticalCenter: parent.verticalCenter }
            AudioWidget           { id: wAudio;     root: bar.root; anchors.verticalCenter: parent.verticalCenter }
            BrightnessWidget      { id: wBrightness; root: bar.root; anchors.verticalCenter: parent.verticalCenter }
            PowerProfileWidget    { id: wPower;     root: bar.root; anchors.verticalCenter: parent.verticalCenter }
            BatteryWidget         { id: wBattery;   root: bar.root; anchors.verticalCenter: parent.verticalCenter }

            // — alerts & system actions —
            ArchUpdaterWidget     { id: wArch;  root: bar.root; anchors.verticalCenter: parent.verticalCenter }
            UpdateWidget          { root: bar.root; anchors.verticalCenter: parent.verticalCenter }
            TrayWidget            { id: wTray;  root: bar.root; anchors.verticalCenter: parent.verticalCenter }
            WeatherWidget         { id: wWeather; root: bar.root; anchors.verticalCenter: parent.verticalCenter }
            NotificationWidget    { id: wNotif; root: bar.root; anchors.verticalCenter: parent.verticalCenter }
            NotificationSilenceWidget { root: bar.root; anchors.verticalCenter: parent.verticalCenter }
            IdleWidget            { root: bar.root; anchors.verticalCenter: parent.verticalCenter }
            IdleInhibitorWidget   { root: bar.root; anchors.verticalCenter: parent.verticalCenter }
            ThemeDisplayWidget    { root: bar.root; anchors.verticalCenter: parent.verticalCenter }
            ClockWidget           { id: clock; root: bar.root; anchors.verticalCenter: parent.verticalCenter }

            // ── date (right of the time) → click toggles the calendar popup,
            //    same behaviour as the default bar's center block ──
            Item {
                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: dateLabel.implicitWidth
                implicitHeight: 28
                Text {
                    id: dateLabel
                    anchors.centerIn: parent
                    text: {
                        clock.now;   // re-evaluate each minute tick from ClockWidget
                        var days = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
                        var d = new Date();
                        return days[d.getDay()] + " " + d.getDate();
                    }
                    color: Qt.rgba(bar.root.ink.r, bar.root.ink.g, bar.root.ink.b, 0.5)
                    font.family: bar.root.mono
                    font.pixelSize: 10
                    font.letterSpacing: 0.5
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: { bar.root.calendarTick++; bar.root.calendarVisible = !bar.root.calendarVisible }
                }
            }
        }
    }

    // ── report each widget's on-screen X centre to the Theme, so the popups/panels
    //    (Network, Volume, Battery, …) open aligned under the widget that triggers
    //    them — just like the default bar does via its own Bindings. The expression
    //    references rightRow.width / strip.width so it re-evaluates on any relayout. ──
    //   centreX → global X of the widget's centre (panels that do `x: barX - w/2`).
    //   edgeX   → global X of the widget's LEFT edge (panels that do `x: barX`).
    // Matches BarSlot's groupX(gid, frac) with frac 0.5 vs 0.0 respectively.
    function centreX(w) {
        if (!w || !w.visible || w.width <= 0) return 0
        return Math.round(w.mapToItem(null, w.width / 2, 0).x)
    }
    function edgeX(w) {
        if (!w || !w.visible || w.width <= 0) return 0
        return Math.round(w.mapToItem(null, 0, 0).x)
    }
    Binding { target: bar.root; property: "workspaceBarX";  value: (rightRow.width, strip.width, bar.centreX(wWorkspace)) }
    Binding { target: bar.root; property: "mprisBarX";      value: (rightRow.width, strip.width, bar.centreX(wMpris)) }
    Binding { target: bar.root; property: "networkBarX";    value: (rightRow.width, strip.width, bar.centreX(wNetwork)) }
    Binding { target: bar.root; property: "cpuBarX";        value: (rightRow.width, strip.width, bar.centreX(wCpu)) }
    Binding { target: bar.root; property: "memoryBarX";     value: (rightRow.width, strip.width, bar.centreX(wMemory)) }
    Binding { target: bar.root; property: "bluetoothBarX";  value: (rightRow.width, strip.width, bar.centreX(wBluetooth)) }
    Binding { target: bar.root; property: "volumeBarX";     value: (rightRow.width, strip.width, bar.centreX(wAudio)) }
    Binding { target: bar.root; property: "brightnessBarX"; value: (rightRow.width, strip.width, bar.centreX(wBrightness)) }
    Binding { target: bar.root; property: "powerBarX";      value: (rightRow.width, strip.width, bar.centreX(wPower)) }
    Binding { target: bar.root; property: "batteryBarX";    value: (rightRow.width, strip.width, bar.centreX(wBattery)) }
    Binding { target: bar.root; property: "weatherBarX";    value: (rightRow.width, strip.width, bar.centreX(wWeather)) }
    Binding { target: bar.root; property: "launcherBarX";   value: (rightRow.width, strip.width, bar.centreX(wLauncher)) }
    Binding { target: bar.root; property: "archBarX";       value: (rightRow.width, strip.width, bar.centreX(wArch)) }
    // these two panels anchor on the widget's LEFT edge (frac 0.0)
    Binding { target: bar.root; property: "trayBarX";       value: (rightRow.width, strip.width, bar.edgeX(wTray)) }
    Binding { target: bar.root; property: "notifBarX";      value: (rightRow.width, strip.width, bar.edgeX(wNotif)) }
}
