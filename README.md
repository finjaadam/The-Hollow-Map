# The-Hollow-Map
[FigJam](https://www.figma.com/board/RMrylh33ynIodOLGp1EUmt/The-Hollow-Map?node-id=0-1&t=1OBZOppV7AXBnz2c-1)


## Setup

> Godot hat kein integriertes GUI für Git-Operationen. Nutze daher **git in der Konsole** oder **GitHub Desktop** (Empfehlung von Janek)   

- Klone das Repository in einen Ordner deiner Wahl
- Installiere und öffne Godot Version 4.6.2 (https://godotengine.org/download/windows/)
- Klicke "Importieren"
- Navigiere zum root-Ordner deines geklonten Repositories (Standard-Name: The-Hollow-Map)
- Klicke "Diesen Ordner auswählen"
- Bestätigen, dass du importieren willst

**Fertig**

## Regeln

Der main-branch ist geschützt, das heißt, niemand kann direkt darauf pushen oder ihn löschen. Das ist eine Schutzmaßnahme, damit nicht ausversehen upsis passieren. Zum Mergen wird ein Pull-Request benötigt, der aber nicht von einer zweiten Person bestätigt werden muss.

Die Vorgehensweise ist daher:
- Neuen Branch aus Main erstellen
- Änderungen vornehmen
- Pull Request erstellen
- Wirklich nochmal überlgen, ob die Änderungen auf main sollen
- Pull Request durchführen

## Tips zur Benennung

> Wäre cool wenn ihr euch dran haltet, lässt einfach einen schnelleren Überblick zu un

### Branches: 
ArtDerÄnderung/Inhalt (siehe https://www.geeksforgeeks.org/git/how-to-naming-conventions-for-git-branches/)

Beispiele: 
- feature/add-enemies
- bugfix/stopped-player-falling-through-floor

### Commits: 
ArtDerÄnderung:Inhalt (siehe https://gist.github.com/qoomon/5dfcdf8eec66a051ecd85625518cfd13)

Beispiele: 
- feature: add enemies
- docs: add Setup Instruction to README
