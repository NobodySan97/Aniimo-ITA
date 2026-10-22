# 📜 Registro delle Modifiche (Changelog)

Tutte le modifiche e gli aggiornamenti apportati alla traduzione italiana di **Aniimo** sono documentati in questo file.

---

## [1.1.1] - 2026-10-22

### 🎯 Perfezionamento Entità & Discrepanze Residue (308 Correzioni Mirate)
- **Nomi Propri dei PNG & Lore**:
  - Ripristinato **`Clovis`** (eliminato l'arcaico *"Clodoveo"* in *"Diario di Clovis"*, *"Clovis III"* e *"Clovis Junior"*).
  - Unificato **`Floret`** in tutte le targhette di dialogo e diari (eliminate 11 occorrenze residue di *"Fiorellino"*).
  - Normalizzato il nome di **`ChillBeanz`** (eliminato *"FagioliFreddi"*).
- **Dimora, Terreni & Coltivazione**:
  - Corretto l'errore di traduzione sui terreni coltivabili: **`Sblocca lotto 4`** e **`Nome del lotto`** (eliminata la bizzarra traduzione letterale *"Sblocca trama 4"* e *"Nome della trama"* da *plot*).
  - Unificato il comando di ritorno alla base in **`Vai alla Dimora`** e **`Segnala Dimora`** (eliminati gli ultimi *"Vai alla Casa"* e *"Segnala casa"*).
- **Estrazione, Abilità & Combattimento**:
  - Corretto il nodo di estrazione mineraria in **`Miniera`** (eliminato il clamoroso pronome possessivo inglese tradotto *"Mio"*).
  - Corretta l'abilità berserker in **`Furia scatenata`** (eliminato il ridicolo calco *"Furia Furiosa"* da *Raging Rampage*).
  - Rimosso l'a capo spurio su **`Santuario: Acque Frigide`** e **`Aggiungi dal profilo`**.
  - Unificati termini come **`Corsa con timbro`**, **`Ambra Sogno di Farfalla`**, **`Riduzione tempo di ricarica`**, **`Vigore massimo`**.

---

## [1.1.0] - 2026-10-22

### 🔬 Controllo Globale Riga per Riga con Database Steam (17.406 Perfezionamenti)
Confronto filologico ed esaustivo di tutte le 112.418 righe di gioco direttamente con il dump estratto dai file di gioco Steam (`NewTextMap_en.json` e `Compress_en.bin`) e i sorgenti originali (`NewTextMap_zh_CN.json`):

- **Armonizzazione di Massa dei Testi Duplicati (17.393 righe sincronizzate)**:
  - Eliminata la dispersione generata da traduzioni automatiche incoerenti su **7.045 gruppi di testi identici**. Ogni stringa ripetuta nel gioco (descrizioni di forzieri, uova di Aniimo, missioni secondarie, avvisi HUD, requisiti di livello) ora impiega la medesima formulazione italiana certificata.
  - Sincronizzate decine di colture e materiali (es. *Grano variopinto gigante*, *Minerale di rame pregiato*).
  - Unificata la dicitura delle lavorazioni (*Lavorazione della dimora* al posto di *Lavorazione domestica* / *Lavorazione della Casa*).
  - Normalizzate le formule di schiusa uova (*Incubatrici dell'Avamposto* e *Incubatrici della Dimora*).
- **Risoluzione Voci Residue in Inglese**:
  - *Sea of Flowers* tradotto ovunque in **`Mare di Fiori`** (11 istanze residue).
  - *Drop the Beat* localizzato in **`A ritmo di musica`**.
- **Coerenza Assoluta dei Nomi di Entità & Bottoni**:
  - Unificati i negozi evento (*Negozio Luna del Raccolto* eliminando *Vendemmia* e *Mietitura*).
  - Standardizzati i titoli e ruoli dei personaggi (*Cecelia Veterana*, *Loulla Senior*, *Budsquire Cantastorie*).
  - Risolti i pulsanti di navigazione (*Indietro* per il ritorno a menu, distinguendolo dal parametro anatomico *Schiena*).

---

## [1.0.1] - 2026-10-19

### 🌟 Revisione Terminologica Specialistica Globale (968 Perfezionamenti)
Audit filologico e linguistico condotto da 4 specialisti incrociando l'italiano con i file originali in inglese (`en`), spagnolo (`es_ES`) e francese (`fr_FR`).

#### 🐾 Lore, Creature Aniimo, Allevamento & Dimora (352 correzioni)
- **Homeland unificato:** eliminata l'inappropriata traduzione letterale *"Patria"* / *"Madrepatria"* (127 stringhe) in favore del termine canonico del gioco **`Dimora`**.
- **Nomi Propri delle Specie Aniimo:** ripristinati i nomi registrati che erano stati tradotti come parole comuni:
  - Il drago compagno **`Whelpy`** (da *"Cucciolotto"* / *"Draghetto"*).
  - **`Stellalord`** (da *"Signore delle Stelle"* / *"Signore Stellare"*).
  - **`Shrout`** (da *"Cespuglino Panicato"*, *"Grumetto Panicato"*, *"Urlalbero Sbadato"*).
  - **`Lucklet`** (da *"Fortunello"*), **`Big Chillmut`** (da *"Gelomut grande"*), **`Pouchwisp`** (da *"Borsaspirito"*), **`Wolferno`** (da *"Lupinferno"*).
- **Incubazione & Cure:** unificata la macchina di cova su **`Incubatrice`** (eliminate le frammentazioni *"Schiuditore"* e *"Incubatore"*).
- **Interazione *Pet*:** corretto il verbo d'azione *Pet* nel pulsante in **`Accarezza`** (anziché il sostantivo isolato *"Animale"*); nelle schermate dei box corretto *"tutti gli animali domestici"* in **`Tutti gli Aniimo`**.
- **Varianti e Camper:** normalizzato `Alpha` in **`Alfa`** (31 casi) e unificati i livelli di potenziamento del camper su **`Livello Camper`** (anziché *"Livello RV"*).

#### ⚔️ Combattimento, Statistiche & Abilità (230 correzioni)
- **Standardizzazione Statistiche Difensive:** normalizzate tutte le difese su **`DIF F.`** (Difesa Fisica) e **`DIF M.`** (Difesa Magica), eliminando forme miste con la *P.* inglese (`DIF P.`, `DEF P.`), refusi con doppi punti (`DIF F..`) e sigle isolate (`D. MAG`, `DEF FIS`).
- **Punti Energia:** convertito l'acronimo inglese residuo `EP` nel corretto **`PE`** (*Punti Energia*).
- **Tasso Critico:** corretto il calco sgrammaticato *"Tasso di critico"* (18 stringhe) in **`Tasso critico`** / **`Tasso CRIT`**.
- **I 6 Attributi Primari:** unificata la nomenclatura ufficiale dei parametri base del personaggio:
  - `Might` -> **Potenza** (eliminati *"Forza"*, *"Possanza"*, *"Vigore"*).
  - `Gusto` -> **Grinta** (eliminati *"Slancio"*, *"Entusiasmo"*, *"Brio"*).
  - `Penetration` -> **Penetrazione** (eliminato *"Perforazione"*).
- **Meccaniche Chiave:**
  - Abilità definitiva unificata su **`Suprema`** (eliminati i calchi spagnoli *"Definitiva"* e le varianti *"Mossa Finale"*).
  - Distinzione rigorosa tra **`Vigore`** (la barra *Stamina* per corsa e schivata) e **`Resistenza`** (l'attributo difensivo *Endurance*).
  - Meccanica *Lock-on* uniformata ad **`Aggancio`** (eliminati *"Puntamento"* e *"Mira"*).
  - Corretto *"Raggiungi la posizione bersaglio"* nell'appropriato **`Raggiungi la posizione indicata`**.
  - Status *Burn* corretto da verbo (*"Brucia"*) a sostantivo canonico **`Bruciatura`**, e l'abilità *Burn Breaker* unificata in **`Spezzabruciatura`**.

#### 🗺️ Mondo, Esplorazione, Missioni & UI (252 correzioni)
- **Pianure Ventose (*Breezy Plains*):** risolte 84 traduzioni discordanti (*Pianure Ventilate*, *Pianure Briose*, *Pianure Ariose*, *Pianure della Brezza*) unificandole tutte in **`Pianure Ventose`**.
- **Cresta delle Mille Zanne & Luoghi:** unificate 23 varianti della *Thousand-Fang Ridge* su **`Cresta delle Mille Zanne`**, la *Zephyr Coast* in **`Costa dello Zefiro`**, e corretto il letterale *"Bosco dei Barbuti"* in **`Boschi di Beardow`**.
- **Falso Amico Giudiziario *Doctor's Trial*:** eliminato il clamoroso errore *"Processo del Dottore: Fallito"* (da tribunale penale!) in **`Prova del Dottore: Fallita`**.
- **Template Pin Mappa e Viaggio Rapido:**
  - Corretto l'errore grammaticale *"Gli Pathfinder"* in **`I Pathfinder`**.
  - Unificato il termine d'attivazione *Bloom* in **`Bocciolo`** (erano presenti *"lo Sboccio"*, *"la Fioritura"*, *"il Fiore"*).
- **Falsi Amici UI:**
  - Corretto *"Dopo aver completato la festa"* (Party) in **`Dopo aver completato la squadra`**.
  - Corretto il pulsante di uscita da un dungeon *"Lascia"* in **`Esci`**.
  - Opzioni telecamera unificate in **`Inverti controlli verticali/orizzontali telecamera`**.

#### 📦 Oggetti, Materiali, Fabbricazione ed Economia (148 correzioni)
- **Valute Primarie:** corretto l'errore dei *Credits* (la valuta di gioco) scambiati per titoli di coda cinematografici (**"Riconoscimenti"**) in **`Crediti`**; la valuta energetica è stata unificata in **`Primegia`** (eliminato l'involontario refuso *"Consuma Primangia"*!).
- **Pulsanti di Fabbricazione:**
  - Il pulsante *Cook* incredibilmente tradotto con lo chef di cucina (**"Cuoco"**) è stato corretto nel verbo d'azione **`Cucina`**.
  - Corretta l'allucinazione *"Fabbricatore di Aniibozzoli"* in **`Fabbricatore di Aniipod`**.
- **Equipaggiamento *Held Items*:** eliminato il calco *"Strumenti Trattenuti"* (come fossero pacchi doganali sequestrati) in favore del corretto **`Strumenti Tenuti`**.
- **Falso Amico *Coilstrike Club*:** la palestra di pugilato di Tysen (*Club Colpospirale*), scambiata a turno per un'arma (*"Mazza Spirafulmine"*, *"Clava a spirale"*), è stata riallineata a **`Club Colpospirale`** e i relativi tagliandi a **`Coupon Colpospirale`**.
- **Minerali:** corretto il minerale *Wood Tin* da *"Latta di legno"* (un barattolo di latta in legno!) nell'effettivo minerale fibroso **`Stagno di legno`**; unificata la *Glintstone* in **`Brillapietra`**.
- **Parole Fuse:** separati tutti i glitch di traduzione automatica (*"Baccalce"* -> *Bacca dolce*, *"Albadentidileone"* -> *Denti d'aurora*, *"sussurridelcrepuscolo"* -> *sussurri del crepuscolo*).

---

## [1.0.0] - 2026-10-18

### 🚀 Release Iniziale Ufficiale
- **Localizzazione Completa al 100%:** 112.418 stringhe allineate alla Build `3746914`.
- **Avvio Diretto in Italiano:** la traduzione sostituisce lo slot lingua inglese (`en`), avviando il gioco direttamente in italiano senza modifiche ai menu.
- **Compilatore C# In-Memory (`AniimoFastPacker`):** patcha `StreamingAssets` al volo in 1,5 secondi senza sovrascrivere o distribuire file binari protetti (`pmdata.bin` o script Lua).
- **Interfaccia Grafica Moderna (*Polaris UI*):** launcher a schede orizzontali con rilevamento automatico del percorso di Steam/Xbox/Pawprint, verifica di build in tempo reale e monitoraggio dello stato.
- **Dizionario Bilingue Interattivo (IT ↔ EN):** oltre 18.000 termini ricercabili in tempo reale all'interno del launcher per facilitare la consultazione di wiki e guide internazionali.
- **Sistema di Ripristino Sicuro:** disinstallazione della traduzione e ripristino dell'inglese originale della build in 1 clic.
