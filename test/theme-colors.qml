import QtQuick
import Quickshell
import qs.Commons as OmarchyTheme
import qs.services
import qs.components
import qs.Ui

// Run through tools/check-colors: qs supplies the same imports as the app.
ShellRoot {
  id: root
  property var failures: []
  property int checks: 0
  property int phase: 0

  Window {
    width: 800
    height: 600
    Item {
      anchors.fill: parent
      FindBar { id: find }
      Toast { id: toast }
      ShortcutSheet { id: shortcuts; anchors.fill: parent }
      PanelToolTip { id: tooltip; text: "Theme check" }
    }
  }

  function expect(label, actual, expected) {
    checks++
    if (String(actual) !== String(expected))
      failures.push(label + ": got " + actual + ", expected " + expected)
  }

  function check() {
    var light = phase === 1
    var bg = light ? "#f4f0e8" : "#16202a"
    var fg = light ? "#202830" : "#e0e8f0"
    var accent = light ? "#2244aa" : "#88aaff"
    var popup = light ? "#e8e0d0" : "#243444"
    var tip = light ? "#ded4c4" : "#304050"
    var colors = 'background = "' + bg + '"\nforeground = "' + fg
               + '"\naccent = "' + accent + '"\n'
    OmarchyTheme.Color.loadColors(colors)
    Theme.named = Theme.parseNamed(colors)
    OmarchyTheme.Color.loadShell('[popups]\nbackground = "' + popup
      + '"\n[tooltip]\nbackground = "' + tip + '"\ntext = "' + fg
      + '"\nborder = "' + accent + '"\n')
    Qt.callLater(function() {
      var prefix = light ? "light " : "dark "
      expect(prefix + "theme directory", Theme.themeDir, OmarchyTheme.Color.currentThemePath)
      expect(prefix + "page background", Theme.bg, bg)
      expect(prefix + "foreground", Theme.fg, fg)
      expect(prefix + "text", Theme.text, fg)
      expect(prefix + "accent", Theme.accent, accent)
      expect(prefix + "link", Theme.link, accent)
      expect(prefix + "light mode", Theme.light, light)
      expect(prefix + "find background", find.color, popup)
      expect(prefix + "toast background", toast.color, popup)
      var card = null
      for (var i = 0; i < shortcuts.children.length; i++) {
        var child = shortcuts.children[i]
        if (child.border !== undefined) card = child
      }
      expect(prefix + "shortcut background", card ? card.color : "missing card", popup)
      expect(prefix + "tooltip background", tooltip.panelBackground, tip)
      expect(prefix + "tooltip text", tooltip.panelForeground, fg)
      expect(prefix + "tooltip border", tooltip.panelBorder, accent)
      expect(prefix + "border theme lookup", OmarchyTheme.Border.value("tooltip", "background"), tip)
      expect(prefix + "border foreground role", OmarchyTheme.Border.cssColor("foreground"), fg)
      expect(prefix + "border accent role", OmarchyTheme.Border.cssColor("accent"), accent)
      expect(prefix + "style foreground role", OmarchyTheme.Style.resolveStateColor("foreground"), fg)
      expect(prefix + "style background role", OmarchyTheme.Style.resolveStateColor("background"), bg)
      if (phase++ === 0) {
        check()
      } else {
        console.log("THEME_COLORS_RESULT " + JSON.stringify({checks: checks, failures: failures}))
        Qt.quit()
      }
    })
  }

  // Let initial FileView reads settle before exercising two live palettes.
  Timer { interval: 300; running: true; onTriggered: root.check() }
}
