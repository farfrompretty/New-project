# 🐍 Lektion 1: Willkommen bei Python!

## 📖 Inhaltsverzeichnis
- [Was ist Python?](#was-ist-python)
- [Warum Python lernen?](#warum-python-lernen)
- [Python installieren](#python-installieren)
- [Dein erstes Programm](#dein-erstes-programm)
- [Die Python-Shell](#die-python-shell)
- [Übungen](#übungen)

---

## 🤔 Was ist Python?

**Python ist eine Programmiersprache.** Aber was bedeutet das genau?

### Programmiersprachen erklärt

Stell dir vor:
- **Menschen** sprechen Deutsch, Englisch, Spanisch, etc.
- **Computer** verstehen nur 0 und 1 (Binärcode)

Eine **Programmiersprache** ist wie eine Brücke zwischen Menschen und Computern. Du schreibst Anweisungen in Python (die du lesen kannst), und der Computer übersetzt sie in seine Sprache (0 und 1) und führt sie aus.

### Python's Geschichte

- **Erfunden:** 1991 von Guido van Rossum (einem niederländischen Programmierer)
- **Name:** Kommt NICHT von der Schlange, sondern von "Monty Python" (britische Comedy-Gruppe)
- **Philosophie:** "Code sollte einfach zu lesen sein wie Englisch"

### Python Versionen

Es gibt zwei Hauptversionen:
- **Python 2** - Alt, wird seit 2020 nicht mehr unterstützt ❌
- **Python 3** - Modern, das verwenden wir! ✅

**Wichtig:** In diesem Kurs verwenden wir Python 3.8 oder höher.

---

## 🎯 Warum Python lernen?

### 1. **Einfach zu lernen** 🎓

Python liest sich fast wie Englisch. Vergleiche:

**Andere Sprachen (z.B. Java):**
```java
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hallo Welt!");
    }
}
```

**Python:**
```python
print("Hallo Welt!")
```

Siehst du den Unterschied? Python ist **viel kürzer und klarer**!

### 2. **Extrem vielseitig** 🌍

Was kannst du mit Python alles machen?

- **🌐 Web-Entwicklung** - Websites bauen (YouTube, Instagram, Spotify nutzen Python!)
- **📊 Datenanalyse** - Daten analysieren, Diagramme erstellen
- **🤖 Künstliche Intelligenz** - Machine Learning, neuronale Netze
- **🎮 Spiele** - Einfache bis mittlere Spiele entwickeln
- **⚙️ Automatisierung** - Langweilige Aufgaben automatisieren
- **📱 Apps** - Mobile Apps entwickeln
- **🔬 Wissenschaft** - Forschung, Berechnungen
- **🐛 Hacking/Security** - Sicherheitstools entwickeln

### 3. **Große Community** 👥

- Über 10 Millionen Python-Entwickler weltweit
- Unzählige kostenlose Ressourcen
- Für jedes Problem gibt es Hilfe online

### 4. **Gutes Gehalt** 💰

Python-Entwickler verdienen gut:
- Junior: 35.000-50.000€/Jahr
- Mittel: 50.000-70.000€/Jahr
- Senior: 70.000-100.000€+/Jahr

### 5. **Zukunftssicher** 🚀

Python wächst ständig und ist seit Jahren unter den Top 3 beliebtesten Programmiersprachen.

---

## 💻 Python installieren

### Auf dem Computer (Windows/Mac/Linux)

#### **Windows:**

1. Gehe zu [python.org](https://www.python.org)
2. Klicke auf "Downloads"
3. Lade "Python 3.xx" herunter (neueste Version)
4. Führe die Installationsdatei aus
5. **WICHTIG:** Hake "Add Python to PATH" an! ✅
6. Klicke auf "Install Now"

#### **Mac:**

1. Öffne Terminal
2. Installiere Homebrew (falls nicht vorhanden):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
3. Installiere Python:
   ```bash
   brew install python
   ```

#### **Linux (Ubuntu/Debian):**

```bash
sudo apt update
sudo apt install python3 python3-pip
```

### Auf dem Handy 📱

#### **Android:**

1. **Pydroid 3** (Empfohlen!)
   - Im Google Play Store suchen
   - Kostenlos
   - Volle Python-Umgebung
   - Kann pip-Pakete installieren

2. **QPython**
   - Alternative zu Pydroid
   - Etwas komplizierter

#### **iOS (iPhone/iPad):**

1. **Pythonista**
   - Kostenpflichtig (~10€)
   - Sehr gut für iOS
   
2. **Python3IDE**
   - Kostenlos
   - Grundfunktionen

### Online (ohne Installation) 🌐

Du kannst Python auch direkt im Browser nutzen:

1. **[Replit.com](https://replit.com)** - Kostenlos, sehr gut
2. **[Python.org Shell](https://www.python.org/shell/)** - Einfach, schnell
3. **[Google Colab](https://colab.research.google.com)** - Für Notebooks
4. **[Trinket.io](https://trinket.io)** - Gut für Anfänger

---

## ✅ Installation testen

Nach der Installation, öffne Terminal/Kommandozeile/Shell und tippe:

```bash
python --version
```

oder

```bash
python3 --version
```

Du solltest etwas sehen wie:
```
Python 3.11.5
```

**Wenn das funktioniert: Herzlichen Glückwunsch! 🎉 Python ist installiert!**

---

## 🎨 Dein erstes Programm!

### Methode 1: Python-Shell (Interaktiver Modus)

1. Öffne Terminal/Kommandozeile
2. Tippe `python` oder `python3` und drücke Enter
3. Du siehst jetzt sowas:

```python
>>>
```

Das `>>>` bedeutet: Python wartet auf deine Befehle!

4. Tippe:

```python
>>> print("Hallo Welt!")
```

5. Drücke Enter

**Ergebnis:**
```
Hallo Welt!
```

🎉 **Du hast gerade dein erstes Python-Programm geschrieben!**

### Was ist passiert?

- `print()` ist eine **Funktion** (ein Befehl)
- `"Hallo Welt!"` ist ein **String** (Text)
- Die Funktion `print()` zeigt Text auf dem Bildschirm an

### Weitere Experimente in der Shell:

```python
>>> print("Ich lerne Python!")
Ich lerne Python!

>>> print(2 + 2)
4

>>> print("Mein Name ist", "Max")
Mein Name ist Max

>>> print(10 * 5)
50
```

**Probiere selbst!** Experimentiere mit verschiedenen Texten und Zahlen!

### Methode 2: Python-Datei erstellen

1. Öffne einen Texteditor (Notepad, VS Code, etc.)
2. Schreibe:

```python
print("Hallo Welt!")
print("Ich bin ein Python-Programm!")
print("2 + 2 =", 2 + 2)
```

3. Speichere als `hello.py` (wichtig: Endung `.py`)
4. Öffne Terminal im gleichen Ordner
5. Führe aus:

```bash
python hello.py
```

**Ergebnis:**
```
Hallo Welt!
Ich bin ein Python-Programm!
2 + 2 = 4
```

---

## 🔍 Die Python-Shell verstehen

Die Python-Shell (auch REPL genannt: Read-Eval-Print-Loop) ist dein Spielplatz!

### REPL erklärt:

1. **Read** - Python liest, was du tippst
2. **Eval** - Python wertet es aus
3. **Print** - Python zeigt das Ergebnis
4. **Loop** - Python wartet auf die nächste Eingabe

### Shell-Befehle:

```python
>>> # Das ist ein Kommentar (wird ignoriert)

>>> 5 + 3  # Rechnen ohne print()
8

>>> "Hallo"  # Strings ohne print()
'Hallo'

>>> x = 10  # Variable erstellen (mehr dazu in Lektion 2)

>>> x
10

>>> exit()  # Shell verlassen
```

**Oder:**
- Windows: Strg+Z dann Enter
- Mac/Linux: Strg+D

### Tipps für die Shell:

- **↑/↓ Pfeiltasten** - Vorherige Befehle durchgehen
- **Tab** - Auto-Vervollständigung (probiere: `pri` + Tab)
- **help(print)** - Hilfe zu Funktionen
- **clear()** oder Strg+L - Bildschirm leeren

---

## 🎯 Wichtige Konzepte

### 1. Syntax

**Syntax** = Die Grammatik von Python

Genau wie Deutsch Regeln hat ("Der Hund" nicht "Hund der"), hat Python Regeln:

**Richtig:**
```python
print("Hallo")
```

**Falsch:**
```python
print("Hallo"  # Klammer fehlt! ❌
```

### 2. Case-Sensitive

Python unterscheidet Groß- und Kleinschreibung!

```python
>>> print("Hallo")  # Funktioniert ✅
Hallo

>>> Print("Hallo")  # Funktioniert NICHT ❌
NameError: name 'Print' is not defined
```

`print` ≠ `Print` ≠ `PRINT`

### 3. Einrückungen sind wichtig!

In Python sind Leerzeichen am Anfang von Zeilen wichtig (mehr dazu später):

```python
# Richtig
if True:
    print("Hallo")

# Falsch
if True:
print("Hallo")  # ❌ Fehler!
```

---

## 🐛 Häufige Anfänger-Fehler

### 1. Anführungszeichen vergessen

```python
>>> print(Hallo)  # ❌ Falsch
NameError: name 'Hallo' is not defined

>>> print("Hallo")  # ✅ Richtig
Hallo
```

**Text braucht immer Anführungszeichen!**

### 2. Klammern vergessen

```python
>>> print "Hallo"  # ❌ Falsch (funktioniert nur in Python 2)
SyntaxError

>>> print("Hallo")  # ✅ Richtig
Hallo
```

### 3. Falsche Python-Version

Wenn du Python 2 verwendest, funktioniert vieles anders:

```python
# Python 2 (alt)
print "Hallo"  # Ohne Klammern

# Python 3 (neu)
print("Hallo")  # Mit Klammern
```

**Stelle sicher, dass du Python 3 verwendest!**

---

## 📝 Übungen

### Übung 1: Installation testen
Öffne die Python-Shell und tippe nacheinander:
```python
print("Python funktioniert!")
print(100 * 2)
print("Mein erstes Programm!")
```

### Übung 2: Rechnen
Berechne in der Python-Shell:
- 15 + 27
- 100 - 35
- 8 * 9
- 100 / 4

### Übung 3: Persönliche Nachricht
Schreibe ein Programm (`mein_programm.py`), das ausgibt:
```
Hallo, ich bin [Dein Name]!
Ich bin [Dein Alter] Jahre alt.
Ich lerne Python!
```

### Übung 4: Experimente
Probiere aus, was passiert wenn du eingibst:
```python
print()  # Leere Klammern
print("Python", "ist", "toll")
print("Ha" * 10)
print(5 + 3 * 2)
```

Verstehe, warum die Ergebnisse so sind!

---

## 🎓 Was du gelernt hast

✅ Was Python ist und warum es toll ist  
✅ Wie man Python installiert  
✅ Dein erstes Python-Programm geschrieben  
✅ Die Python-Shell benutzt  
✅ Die `print()` Funktion verwendet  
✅ Häufige Fehler kennengelernt  

---

## ➡️ Weiter geht's

In der nächsten Lektion lernst du über:
- **Variablen** - Wie man Daten speichert
- **Datentypen** - Verschiedene Arten von Daten
- **Type Casting** - Zwischen Typen umwandeln

**Bereit? Auf zur [Lektion 2: Variablen und Datentypen](02_variablen_datentypen.md)!**

---

## 💬 Fragen?

Wenn du etwas nicht verstehst, frag mich einfach! Ich erkläre es dir gerne nochmal anders. 🙂
