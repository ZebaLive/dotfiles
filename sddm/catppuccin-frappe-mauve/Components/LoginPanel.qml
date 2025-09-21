import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import "../assets"

Item {
  property var user: userField.text
  property var password: passwordField.text
  property var session: sessionPanel.session
  // DPI-aware sizing - use minimum size with DPI scaling
  property var inputHeight: Math.max(Screen.height * 0.032, 48 * Screen.devicePixelRatio)
  property var inputWidth: Math.max(Screen.width * 0.16, 280 * Screen.devicePixelRatio)
  
  Rectangle {
    id: loginBackground
    anchors {
      verticalCenter: parent.verticalCenter
      horizontalCenter: parent.horizontalCenter
    }
    height: inputHeight * ( config.UserIcon == "true" ? 11.2 : 5.3 )
    width: inputWidth * 1.2
    radius: 8 * Screen.devicePixelRatio
    visible: config.LoginBackground == "true" ? true : false
    color: "#292C3C"
  }
  Column {
    spacing: 12 * Screen.devicePixelRatio
    anchors {
      bottom: parent.bottom
      left: parent.left
    }
    PowerButton {
      id: powerButton
    }
    RebootButton {
      id: rebootButton
    }
    SleepButton {
      id: sleepButton
    }
    z: 5
  }
  Column {
    spacing: 12 * Screen.devicePixelRatio
    anchors {
      bottom: parent.bottom
      right: parent.right
    }
    SessionPanel {
      id: sessionPanel
    }
    z: 5
  }
  Column {
    spacing: 12 * Screen.devicePixelRatio
    z: 5
    width: inputWidth
    anchors {
      verticalCenter: parent.verticalCenter
      horizontalCenter: parent.horizontalCenter
    }
    Rectangle {
      visible: config.UserIcon == "true" ? true : false
      width: inputHeight * 5.7 ; height: inputHeight * 5.7
      color: "transparent"
      Image {
        source: Qt.resolvedUrl("../assets/defaultIcon.png")
        height: parent.width
        width: parent.width
      }
      Image {
        // common icon path for KDE and GNOME
        source: Qt.resolvedUrl("/var/lib/AccountsService/icons/" + user)
        height: parent.width
        width: parent.width
      }
      Image {
        source: Qt.resolvedUrl(config.LoginBackground == "true" ? "../assets/maskDark.svg" : "../assets/mask.svg")
        height: parent.width
        width: parent.width
      }
      Image {
        source: Qt.resolvedUrl("../assets/ring.svg")
        height: parent.width
        width: parent.width
      }
      anchors {
        horizontalCenter: parent.horizontalCenter
      }
    }
    UserField {
      id: userField
      height: inputHeight
      width: parent.width
    }
    PasswordField {
      id: passwordField
      height: inputHeight
      width: parent.width
      onAccepted: loginButton.clicked()
    }
    Button {
      id: loginButton
      height: inputHeight
      width: parent.width
      enabled: user != "" && password != "" ? true : false
      hoverEnabled: true
      contentItem: Text {
        id: buttonText
        renderType: Text.NativeRendering
        font {
          family: config.Font
          pointSize: config.FontSize
          bold: true
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "#232634"
        text: "Login"
      }
      background: Rectangle {
        id: buttonBackground
        color: "#CA9EE6"
        radius: 5 * Screen.devicePixelRatio
      }
      states: [
        State {
          name: "pressed"
          when: loginButton.down
          PropertyChanges {
            target: buttonBackground
            color: "#A5ADCE"
          }
          PropertyChanges {
            target: buttonText
          }
        },
        State {
          name: "hovered"
          when: loginButton.hovered
          PropertyChanges {
            target: buttonBackground
            color: "#A5ADCE"
          }
          PropertyChanges {
            target: buttonText
          }
        },
        State {
          name: "enabled"
          when: loginButton.enabled
          PropertyChanges {
            target: buttonBackground
          }
          PropertyChanges {
            target: buttonText
          }
        }
      ]
      transitions: Transition {
        PropertyAnimation {
          properties: "color"
          duration: 300
        }
      }
      onClicked: {
        sddm.login(user, password, session)
      }
    }
  }
  Connections {
    target: sddm

    function onLoginFailed() {
      passwordField.text = ""
      passwordField.focus = true
    }
  }
}
