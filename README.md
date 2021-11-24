# Botty - der Datenschutz-Chatbot

## Willkommen!

"Botty - der Datenschutz-Chatbot" ist ein Projekt im Rahmen des Praktikums "IT-basiertes Lernen gestalten" des [Lehrstuhls i17 der TU München](https://www.in.tum.de/i17/chair/) im Wintersemester 2021/22.
Ziel ist die Ausgestaltung einer digitalen Unterrichtsstunde, welche Schüler*innen der gymnasialen Oberstufe zum Thema Datenschutz informiert.

Dieses Repository enthält die primäre App-Komponente von Botty, implementiert in [Flutter](https://flutter.dev/).

## App ausführen

Um die App selbst auszuführen, führe die folgenden drei Commands in einer Umgebung aus, in der [Git](https://git-scm.com/) und [Flutter](https://flutter.dev/) verfügbar sind:

```bash
git clone https://github.com/gereonelvers/datenschutz-chatbot.git
cd ./datenschutz_chatbot
flutter run
```

**Achtung: Aktuell hat das Unity Flutter Integrations-Plugin einen Bug, welcher Builds verhindert, wenn einer der Ordern-Namen ein Leerzeichen enthält! Dies beinhaltet insbesondere auch alle übergeordneten Order-Namen.**

## Hinweise

### Unity

Die Integration der Minispiele wird durch [Unity](https://unity.com/) (und insbesondere durch das [Flutter Unity Widget](https://pub.dev/packages/flutter_unity_widget)) realisiert. Platziere dazu den Unity Projekt Ordner in `./datenschutz-chatbot/unity`. Deine finale Ordnerstruktur sollte so aussehen:

```
- datenschutz-chatbot
	- unity
		- <Unity Projekt Ordner>
		- FlutterUnityIntegration-xxxx.unitypackage
	- ...
```

Um danach das Unity-Projekt erfolgreich in die App zu integrieren, führe die folgenden Schritte aus:

1. In Unity, wähle Flutter > Build Android aus
   - Hinweis: iOS Build Status ist aktuell ungetestet
   - Denk daran, vorher alle Scenen deines Projects unter `File > Build Settings... ` in `Scenes in Build` auszuwählen. Die oberste Scene wird als erstes vom Unity Player geladen werden (Sortierung via Drag-and-Drop).
   - Solltest du keinen "Flutter"-Eintrag in deiner Menu-Bar haben, musst du vermutlich `FlutterIntegration-xxx.unitypackage` neu hinzufügen. Dazu
     - Wähle `Assets > Import Package > Custom Package` aus
     - FlutterUnityIntegration-xxxx.unitypackage auswählen
     - **Im weiteren Verlauf JSONDotNet deselektieren**
     - Optional: Unity neustarten
2. In Android Studio einen Build auslösen
   - Hinweis: Unity unterstützt aktuell leider keine Emulation durch Android Studio AVDs.

Hinweis: Damit das Laden der Scene eines Mini-Games korrekt funktioniert, muss **jede** Scene ein Objekt mit Namen `Scene Loader` enthalten, welches über eine `Sceneloader`-Methode die ID der zu ladende Scene entgegennimmt. Beispielimplementierung:

```c#
    public void Sceneswitcher(string args)
    {
        string name = SceneManager.GetActiveScene().name;
        if (!(String.Equals("GameScene"+args, name)))
        {
            SceneManager.LoadSceneAsync (sceneName:"GameScene"+args);
        }
    }
```

Da jeder Build in Android Studio einen Release-Build in Unity auslöst, sind Build-Zeiten von >15 Minuten nicht unüblich. Die gute Nachricht: Der Unity-Build wird gecached, d.h. nachfolgende Builds in Android Studio sind signifikant schneller.
Extrem langsame Build Zeiten unter Windows 10 & 11: Erstelle in Windows Defender eine Ausnahme für den gesamten `datenschutz-chatbot`-Ordner. [Anleitung dazu](https://support.microsoft.com/en-us/windows/add-an-exclusion-to-windows-security-811816c0-4dfd-af4a-47e4-c301afe13b26).

Für Projekte, welche das [Android NDK](https://developer.android.com/ndk) voraussetzen (wie unser eigenes), wirst du im der Datei `./datenschutz_chatbot/android/local.properties` vermutlich den Pfad zu deinem eigenen NDK ändern. Idealerweise kannst du dazu einfach das NDK wiederverwenden, welches bereits in den Unity Android Build Tools installiert wurde. Gehe dazu in Unity auf `Preferences > External Tools` und kopiere den dort unter "Android NDK installed with Unity (recommended)" hinterlegten Pfad in den Eintrag in `local.properties`. Falls du Windows verwendest, denk daran, deinen Path zu escapen. Der korrekte Eintrag sollte so aussehen:

Linux/Unix:

```properties
ndk.dir=/path/to/ndk
```

Windows:

```properties
ndk.dir=C:\\path\to\ndk
```

### Rasa

Um die App mit deinem eigenen [Rasa](https://rasa.com/) Chatbot-Back-End zu verknüpfen, ändere die hinterlegte Domain in `./datenschutz_chatbot/lib/chat_screen.dart`:

```dart
final String chatRequestUrl = <Deine URL>; // Base URL chatbot requests are made to.
```

Alternativ kannst du auch einfach unsere [Rasa-Instanz](http://botty-chatbot.de) weiterverwenden. Das zugehörige Repository findest du [hier](https://github.com/gereonelvers/rasa-datenschutz-chatbot).