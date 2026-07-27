pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    // Spacing tokens
    readonly property int spacingXs: 4
    readonly property int spacingSm: 8
    readonly property int spacingMd: 12
    readonly property int spacingLg: 16
    readonly property int spacingXl: 24

    // Padding tokens
    readonly property int paddingSm: 6
    readonly property int paddingMd: 12
    readonly property int paddingLg: 16

    // Border radius — ALL ZERO (square corners)
    readonly property int radiusNone: 0
    readonly property int radiusSm: 0
    readonly property int radiusMd: 0
    readonly property int radiusLg: 0
    readonly property int radiusXl: 0

    // Font sizes
    readonly property int fontSizeXs: 10
    readonly property int fontSizeSm: 12
    readonly property int fontSizeMd: 14
    readonly property int fontSizeLg: 16
    readonly property int fontSizeXl: 20

    // Animation durations (ms)
    readonly property int animFast: 100
    readonly property int animNormal: 200
    readonly property int animSlow: 350

    // Elevation levels
    readonly property int elevationNone: 0
    readonly property int elevationLow: 2
    readonly property int elevationMed: 4
}
