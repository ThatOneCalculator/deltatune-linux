import Quickshell
import QtQuick
import Quickshell.Io

import "./config.js" as Config

import "./fonts/MusicTitleFont.js" as MusicTitleFont
import "./fonts/ShinonomeGothic.js" as ShinonomeGothic
import "./fonts/Ramche.js" as Ramche

PanelWindow {
    id: deltatune

    anchors {
        top: Config.c.anchors.top ?? true
        right: Config.c.anchors.right ?? true
        bottom: Config.c.anchors.bottom ?? false
        left: Config.c.anchors.left ?? false
    }

    margins {
        top: Config.c.margins.top ?? 25
        right: Config.c.margins.right ?? 25
        bottom: Config.c.margins.bottom ?? 0
        left: Config.c.margins.left ?? 0
    }

    color: Config.c.backgroundColor ?? "transparent"
    property real configScale: Config.c.scale ?? 2

    implicitWidth: bitmapTitle.width * configScale
    implicitHeight: bitmapTitle.height * configScale + bitmapArtist.height * configScale

    property bool showArtist: Config.c.showArtist ?? true
    property bool artistFirst: Config.c.artistFirst ?? false
    property bool staggerArtist: Config.c.staggerArtist ?? false

    property string musicTitleFontImage: "./fonts/MusicTitleFont.png"
    property string shinonomeGothicImage: "./fonts/ShinonomeGothic.png"
    property string ramcheImage: "./fonts/Ramche.png"

    Item {
        id: child
        width: deltatune.implicitWidth
        height: deltatune.implicitHeight - bitmapArtist.height

        Item {
            id: bitmapTitle

            property string text: ""
            property real characterSpacing: Config.c.characterSpacing ?? 1.2
            property string fontImage: "./fonts/MusicTitleFont.png"
            property string currentTitle: ""
            property string currentStatus: ""
            property bool isAnimating: false
            property real baseX: deltatune.implicitWidth - width
            property real slideOffset: Config.c.slideOffset ?? 30
            property real animationDuration: Config.c.animationDuration ?? 600
            property real titleDuration: Config.c.titleDuration ?? 7000

            width: textRow.width
            height: MusicTitleFont.fontInfo.lineHeight

            opacity: 0.0
            x: baseX + slideOffset

            Behavior on opacity {
                enabled: !bitmapTitle.isAnimating
                NumberAnimation {
                    duration: bitmapTitle.animationDuration
                    easing.type: Easing.InOutQuad
                    onRunningChanged: {
                        if (!running && bitmapTitle.opacity === 0.0) {
                            bitmapTitle.x = bitmapTitle.baseX - bitmapTitle.slideOffset;
                        }
                    }
                }
            }

            Behavior on x {
                enabled: !bitmapTitle.isAnimating
                NumberAnimation {
                    duration: bitmapTitle.animationDuration
                    easing.type: Easing.InOutQuad
                }
            }

            function getFontForChar(charCode) {
                if (charCode === 32) {
                    return {
                        charMap: {},
                        getCharData: function (code) {
                            return {
                                x: 0,
                                y: 0,
                                width: 3.5,
                                height: 19,
                                xoffset: 0,
                                yoffset: 0,
                                xadvance: 10
                            };
                        },
                        fontImage: "" // no image for space
                    };
                } else
                // Musical note and basic ASCII (English) - use MusicTitleFont
                if (charCode === 9834 || (charCode >= 33 && charCode <= 126)) {
                    return {
                        charMap: MusicTitleFont.charMap,
                        getCharData: MusicTitleFont.getCharData,
                        fontImage: musicTitleFontImage
                    };
                } else
                // Hiragana, Katakana, Kanji ranges (Japanese) - use ShinonomeGothic
                if ((charCode >= 0x3040 && charCode <= 0x309F) ||  // Hiragana
                (charCode >= 0x30A0 && charCode <= 0x30FF) ||  // Katakana
                (charCode >= 0x4E00 && charCode <= 0x9FAF)) {
                    // CJK Unified Ideographs
                    return {
                        charMap: ShinonomeGothic.charMap,
                        getCharData: function (code) {
                            var data = ShinonomeGothic.getCharData(code);
                            // Push Japanese characters down by 5 pixels (will be scaled 2x to 10px)
                            return {
                                x: data.x,
                                y: data.y,
                                width: data.width,
                                height: data.height,
                                xoffset: data.xoffset,
                                yoffset: data.yoffset + 5,
                                xadvance: data.xadvance
                            };
                        },
                        fontImage: shinonomeGothicImage
                    };
                } else
                // Hangul ranges (Korean) - use Ramche
                if ((charCode >= 0xAC00 && charCode <= 0xD7AF) ||  // Hangul Syllables
                (charCode >= 0x1100 && charCode <= 0x11FF) ||  // Hangul Jamo
                (charCode >= 0x3130 && charCode <= 0x318F)) {
                    // Hangul Compatibility Jamo
                    return {
                        charMap: Ramche.charMap,
                        getCharData: function (code) {
                            var data = Ramche.getCharData(code);
                            // Push Korean characters down by 5 pixels (will be scaled 2x to 10px)
                            return {
                                x: data.x,
                                y: data.y,
                                width: data.width,
                                height: data.height,
                                xoffset: data.xoffset,
                                yoffset: data.yoffset + 5,
                                xadvance: data.xadvance
                            };
                        },
                        fontImage: ramcheImage
                    };
                } else
                // Default fallback to MusicTitleFont
                {
                    return {
                        charMap: MusicTitleFont.charMap,
                        getCharData: MusicTitleFont.getCharData,
                        fontImage: musicTitleFontImage
                    };
                }
            }

            Row {
                id: textRow
                spacing: bitmapTitle.characterSpacing

                Repeater {
                    model: bitmapTitle.text.length

                    Image {
                        property int charCode: bitmapTitle.text.charCodeAt(index)
                        property var fontData: bitmapTitle.getFontForChar(charCode)
                        property var charData: fontData.getCharData(charCode)
                        property real configScale: Config.c.scale ?? 2

                        source: fontData.fontImage
                        sourceClipRect: Qt.rect(charData.x, charData.y, charData.width, charData.height)

                        width: charData.width * configScale
                        height: charData.height * configScale
                        x: charData.xoffset * configScale
                        y: charData.yoffset // * configScale

                        smooth: false
                    }
                }
            }

            function updateMusicInfo() {
                var statusProc = Qt.createQmlObject(`
                    import Quickshell.Io
                    Process {
                        command: ["playerctl", "status"]
                        running: true
                        stdout: StdioCollector {
                            onStreamFinished: {
                                bitmapTitle.currentStatus = this.text.trim();
                                bitmapTitle.checkTitleUpdate();
                            }
                        }
                    }
                `, bitmapTitle);
            }

            function checkTitleUpdate() {
                if (currentStatus === "Playing") {
                    var fmt = "{{artist}} - {{title}}";
                    if (showArtist) {
                        if (staggerArtist) {
                            fmt = "{{title}}"
                            var titleProc = Qt.createQmlObject(`
                                import Quickshell.Io
                                Process {
                                    command: ["playerctl", "metadata", "--format", "${fmt}"]
                                    running: true
                                    stdout: StdioCollector {
                                        onStreamFinished: {
                                            var newTitle = this.text.trim();
                                            if (newTitle.length > 0 && newTitle !== bitmapTitle.currentTitle) {
                                                bitmapTitle.currentTitle = newTitle;
                                                bitmapTitle.text = "♪ ~ " + newTitle;
                                                bitmapTitle.showTitle();
                                            } else if (newTitle.length === 0) {
                                                bitmapTitle.hideTitle();
                                                destroy();
                                            }
                                        }
                                    }
                                }
                            `, bitmapTitle);
                            var artistProc = Qt.createQmlObject(`
                                import Quickshell.Io
                                Process {
                                    command: ["playerctl", "metadata", "--format", "${fmt}"]
                                    running: true
                                    stdout: StdioCollector {
                                        onStreamFinished: {
                                            var newTitle = this.text.trim();
                                            if (newTitle.length > 0 && newTitle !== bitmapTitle.currentTitle) {
                                                bitmapTitle.currentTitle = newTitle;
                                                bitmapTitle.text = "♪ ~ " + newTitle;
                                                bitmapTitle.showTitle();
                                            } else if (newTitle.length === 0) {
                                                bitmapTitle.hideTitle();
                                                destroy();
                                            }
                                        }
                                    }
                                }
                            `, bitmapTitle);
                            return;
                        } else {
                            if (artistFirst) {
                                fmt = "{{artist}} - {{title}}";
                            } else {
                                fmt = "{{title}} - {{artist}}";
                            }
                        }
                    } else {
                        fmt = "{{title}}";
                    }
                    var titleProc = Qt.createQmlObject(`
                        import Quickshell.Io
                        Process {
                            command: ["playerctl", "metadata", "--format", "${fmt}"]
                            running: true
                            stdout: StdioCollector {
                                onStreamFinished: {
                                    var newTitle = this.text.trim();
                                    if (newTitle.length > 0 && newTitle !== bitmapTitle.currentTitle) {
                                        bitmapTitle.currentTitle = newTitle;
                                        bitmapTitle.text = "♪ ~ " + newTitle;
                                        bitmapTitle.showTitle();
                                    } else if (newTitle.length === 0) {
                                        bitmapTitle.hideTitle();
                                        destroy();
                                    }
                                }
                            }
                        }
                    `, bitmapTitle);
                } else {
                    hideTitle();
                }
            }

            function showTitle() {
                hideTimer.stop();
                isAnimating = true;
                opacity = 0.0;
                x = baseX - slideOffset;
                showAnimationTimer.start();
            }

            Timer {
                id: showAnimationTimer
                interval: 10
                repeat: false
                onTriggered: {
                    bitmapTitle.isAnimating = false;
                    bitmapTitle.opacity = 1.0;
                    bitmapTitle.x = bitmapTitle.baseX;
                    hideTimer.restart();
                }
            }

            function hideTitle() {
                hideTimer.stop();
                showAnimationTimer.stop();
                isAnimating = false;
                opacity = 0.0;
                x = baseX - slideOffset;
            }

            Timer {
                id: hideTimer
                interval: bitmapTitle.titleDuration
                running: false
                repeat: false
                onTriggered: bitmapTitle.hideTitle()
            }

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: bitmapTitle.updateMusicInfo()
            }

            Component.onCompleted: updateMusicInfo()
        }
        Item {
            id: bitmapArtist

            property string text: ""
            property real characterSpacing: Config.c.characterSpacing ?? 1.2
            property string fontImage: "./fonts/MusicTitleFont.png"
            property string currentTitle: ""
            property string currentStatus: ""
            property bool isAnimating: false
            property real baseX: deltatune.implicitWidth - textaRow.width
            property real slideOffset: Config.c.slideOffset ?? 30
            property real animationDuration: Config.c.animationDuration ?? 600
            property real titleDuration: Config.c.titleDuration ?? 7000

            width: textRow.width
            height: MusicTitleFont.fontInfo.lineHeight

            opacity: 0.0
            x: baseX + slideOffset
            y: 10

            Behavior on opacity {
                enabled: !bitmapArtist.isAnimating
                NumberAnimation {
                    duration: bitmapArtist.animationDuration
                    easing.type: Easing.InOutQuad
                    onRunningChanged: {
                        if (!running && bitmapArtist.opacity === 0.0) {
                            bitmapArtist.x = bitmapArtist.baseX - bitmapArtist.slideOffset;
                        }
                    }
                }
            }

            Behavior on x {
                enabled: !bitmapArtist.isAnimating
                NumberAnimation {
                    duration: bitmapArtist.animationDuration
                    easing.type: Easing.InOutQuad
                }
            }

            function getFontForChar(charCode) {
                if (charCode === 32) {
                    return {
                        charMap: {},
                        getCharData: function (code) {
                            return {
                                x: 0,
                                y: 0,
                                width: 3.5,
                                height: 19,
                                xoffset: 0,
                                yoffset: 0,
                                xadvance: 10
                            };
                        },
                        fontImage: "" // no image for space
                    };
                } else
                // Musical note and basic ASCII (English) - use MusicTitleFont
                if (charCode === 9834 || (charCode >= 33 && charCode <= 126)) {
                    return {
                        charMap: MusicTitleFont.charMap,
                        getCharData: MusicTitleFont.getCharData,
                        fontImage: musicTitleFontImage
                    };
                } else
                // Hiragana, Katakana, Kanji ranges (Japanese) - use ShinonomeGothic
                if ((charCode >= 0x3040 && charCode <= 0x309F) ||  // Hiragana
                (charCode >= 0x30A0 && charCode <= 0x30FF) ||  // Katakana
                (charCode >= 0x4E00 && charCode <= 0x9FAF)) {
                    // CJK Unified Ideographs
                    return {
                        charMap: ShinonomeGothic.charMap,
                        getCharData: function (code) {
                            var data = ShinonomeGothic.getCharData(code);
                            // Push Japanese characters down by 5 pixels (will be scaled 2x to 10px)
                            return {
                                x: data.x,
                                y: data.y,
                                width: data.width,
                                height: data.height,
                                xoffset: data.xoffset,
                                yoffset: data.yoffset + 5,
                                xadvance: data.xadvance
                            };
                        },
                        fontImage: shinonomeGothicImage
                    };
                } else
                // Hangul ranges (Korean) - use Ramche
                if ((charCode >= 0xAC00 && charCode <= 0xD7AF) ||  // Hangul Syllables
                (charCode >= 0x1100 && charCode <= 0x11FF) ||  // Hangul Jamo
                (charCode >= 0x3130 && charCode <= 0x318F)) {
                    // Hangul Compatibility Jamo
                    return {
                        charMap: Ramche.charMap,
                        getCharData: function (code) {
                            var data = Ramche.getCharData(code);
                            // Push Korean characters down by 5 pixels (will be scaled 2x to 10px)
                            return {
                                x: data.x,
                                y: data.y,
                                width: data.width,
                                height: data.height,
                                xoffset: data.xoffset,
                                yoffset: data.yoffset + 5,
                                xadvance: data.xadvance
                            };
                        },
                        fontImage: ramcheImage
                    };
                } else
                // Default fallback to MusicTitleFont
                {
                    return {
                        charMap: MusicTitleFont.charMap,
                        getCharData: MusicTitleFont.getCharData,
                        fontImage: musicTitleFontImage
                    };
                }
            }

            Row {
                id: textaRow
                spacing: bitmapArtist.characterSpacing

                Repeater {
                    model: bitmapArtist.text.length

                    Image {
                        property int charCode: bitmapArtist.text.charCodeAt(index)
                        property var fontData: bitmapArtist.getFontForChar(charCode)
                        property var charData: fontData.getCharData(charCode)
                        property real configScale: Config.c.scale ?? 2

                        source: fontData.fontImage
                        sourceClipRect: Qt.rect(charData.x, charData.y, charData.width, charData.height)

                        width: charData.width * configScale / 1.4
                        height: charData.height * configScale / 1.4
                        x: charData.xoffset * configScale / 1.4
                        y: charData.yoffset + bitmapTitle.height

                        smooth: false
                    }
                }
            }

            function updateMusicInfo() {
                var statusProc = Qt.createQmlObject(`
                    import Quickshell.Io
                    Process {
                        command: ["playerctl", "status"]
                        running: true
                        stdout: StdioCollector {
                            onStreamFinished: {
                                bitmapArtist.currentStatus = this.text.trim();
                                bitmapArtist.checkTitleUpdate();
                            }
                        }
                    }
                `, bitmapArtist);
            }

            function checkTitleUpdate() {
                if (currentStatus === "Playing") {
                    var fmt = "{{artist}}"
                    var titleProc = Qt.createQmlObject(`
                        import Quickshell.Io
                        Process {
                            command: ["playerctl", "metadata", "--format", "${fmt}"]
                            running: true
                            stdout: StdioCollector {
                                onStreamFinished: {
                                    var newTitle = this.text.trim();
                                    if (newTitle.length > 0 && newTitle !== bitmapArtist.currentTitle) {
                                        bitmapArtist.currentTitle = newTitle;
                                        bitmapArtist.text = newTitle;
                                        bitmapArtist.showArtist();
                                    } else if (newTitle.length === 0) {
                                        bitmapArtist.hideArtist();
                                        destroy();
                                    }
                                }
                            }
                        }
                    `, bitmapArtist);
                } else {
                    hideArtist();
                }
            }

            function showArtist() {
                ahideTimer.stop();
                isAnimating = true;
                opacity = 0.0;
                x = baseX - slideOffset;
                ashowAnimationTimer.start();
            }

            Timer {
                id: ashowAnimationTimer
                interval: 10
                repeat: false
                onTriggered: {
                    bitmapArtist.isAnimating = false;
                    bitmapArtist.opacity = 1.0;
                    bitmapArtist.x = bitmapArtist.baseX;
                    ahideTimer.restart();
                }
            }

            function hideArtist() {
                ahideTimer.stop();
                ashowAnimationTimer.stop();
                isAnimating = false;
                opacity = 0.0;
                x = baseX - slideOffset;
            }

            Timer {
                id: ahideTimer
                interval: bitmapArtist.titleDuration
                running: false
                repeat: false
                onTriggered: bitmapArtist.hideArtist()
            }

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: bitmapArtist.updateMusicInfo()
            }
            
            Component.onCompleted: updateMusicInfo()
        }
        
    }
}
