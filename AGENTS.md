# Linee Guida e Regole per la Traduzione di Aniimo

Questo file contiene le regole architetturali, tecniche e di stile da seguire tassativamente in ogni futuro aggiornamento o creazione di una nuova versione della traduzione italiana di **Aniimo**.

---

## 1. Struttura Binaria I18N (`Compress_en.bin` & `NewTextMap_en.json`)

- **Header a 4-Byte di Versione (`uint32`)**:
  - `Compress_en.bin` **DEVE SEMPRE** iniziare con 4 byte contenenti il numero di versione a 32 bit (`uint32`, little-endian) corrispondente al valore `_version` del file `NewTextMap_en.json` di riferimento.
  - Se questi 4 byte mancano o non coincidono, Unity (`FunPlus.WorldX.I18N.LanguageImporter:ValidateVersion`) fallisce con errore critico:
    `[I18N] 本地化版本不一致! json=..., bin=...，请重新同步本地化资源`
    bloccando l'intero loader della localizzazione e rompendo schermate dinamiche come le **Olo-Battaglie** (Boss Rush).
- **Offset delle Stringhe**:
  - Gli offset `[offset, length]` scritti in `NewTextMap_en.json` devono essere calcolati rispetto all'inizio del file `Compress_en.bin` (pertanto il primo testo compilato parte dall'offset `4`).
- **Dinamismo delle Build**:
  - Non cablare numeri di versione fissi: `AniimoFastPacker` estrae `_version` direttamente dal `NewTextMap_en.json` del client locale (es. `1792149800` su Steam, `1790073981` su PawPrint).

---

## 2. Nomenclatura Canonica e Convenzioni Terminologiche

- **Boss Omega & Olo-Battaglie**:
  - Il prefisso è tassativamente **`Omega <Nome>`** (es. **Omega Sherro**, **Omega Infergon**, **Omega Tucking**, **Omega Helgon**, **Omega Glynsera**). Mai usare la forma inversa (*<Nome> Omega*).
  - Varianti d'età: **`Anziano Omega <Nome>`** e **`Giovane Omega <Nome>`** (es. *Anziano Omega Sherro*).
- **Risoluzione Segnaposto**:
  - Stringhe come ID `1669901594` e `2133940225` (*Lotus (Placeholder) Dragon* / *Drago loto (segnaposto)*) devono essere mappate canonicamente al boss effettivo (**Omega Sherro**).
- **Lore, Divinità & Sistema Dimora**:
  - Divinità dei venti: sempre **`Eolo`** / **`Eone Eolo`** (mai `Aeolus`).
  - Sistema Homeland: sempre **`Dimora`** (mai `Casa`).
  - Oggetti di quest cardine:
    - **`Elmo rotto`** (unificato, vietati *Casco spezzato* / *Elmo Spezzato*).
    - **`Spada del Coraggio`** (unificata per Pawney, vietato *Spada del Valore*).
    - **`Spada di ferro arrugginita`**.

---

## 3. Gestione Release e Packaging

- **Archivio `Aniimo_Traduzione_ITA_v1.0.zip`**:
  - Deve rimanere **snello (~3 MB)** e contenere solo i file essenziali:
    1. `Installa Traduzione ITA.bat`
    2. `LEGGIMI.txt`
    3. `CHANGELOG.md`
    4. `README.md`
    5. `dati/installer.ps1`
    6. `dati/sfondo.jpg`
    7. `dati/traduzione_ita.tsv`
    8. `dati/versione.json`
  - **NON** includere file binari proprietari pesanti o dump del gioco (`pmdata.bin`, `LuaScripts.xdf`); la patch li genera dinamicamente all'installazione partendo dai file dell'utente.
- **Aggiornamento Metadati**:
  - Ad ogni modifica del file `.tsv`, ricalcolare l'MD5 e aggiornare `versione.json`, incrementando la versione (`versione_traduzione`).
  - Aggiornare `CHANGELOG.md` e sincronizzare la release GitHub (tag `v1.0` o successiva).

---

## 4. Codifica File (BOM) & Script

- `installer.ps1` deve essere salvato in **UTF-8 con BOM** (`System.Text.UTF8Encoding($true)`) per garantire che PowerShell 5.1 su Windows legga correttamente caratteri accentati ed emoji dell'interfaccia WPF.
- `traduzione_ita.tsv` deve essere salvato in **UTF-8 standard (senza BOM)** con separatore tabulazione `\t`.
