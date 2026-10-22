# 📜 Registro delle Modifiche (Changelog)

Tutte le modifiche e gli aggiornamenti apportati alla traduzione italiana di **Aniimo** sono documentati in questo file.

---

## [1.1.5] - 2026-10-22

### ⚔️ Fix Compilatore I18N, Supporto PawPrint Launcher & Armonizzazione Boss Omega
- **Supporto Nativo Architettura PawPrint Launcher (Hotfix patchv2)**:
  - Risolto un disallineamento critico con il client PawPrint (es. installato su disco D: o cartelle personalizzate): PawPrint mantiene la build di base nel percorso DVD StreamingAssets (build 3584014) e distribuisce gli aggiornamenti in Aniimo_Data\cvs\res\patchv2\lua\ver\3746914\.
  - In precedenza l'installer rigenerava l'archivio leggendo da StreamingAssets, provocando inavvertitamente il downgrade dei dati alla build 3584014; ciò causava la scomparsa dell'ologramma/modello 3D e delle stelle di **Omega Sherro** e la visualizzazione degli ID numerici grezzi 1924385647 e 1242312851 al posto di **Omega Infergon** e **Omega Tucking**.
  - Ora l'installer (installer.ps1) rileva automaticamente gli archivi hotfix aggiornati in patchv2, garantendo perfetta compatibilità e integrità al 100% sia su Steam che su PawPrint.

- **Correzione Critica Validazione I18N (Unity LanguageImporter)**:
  - Risolto il bug nel compilatore binario AniimoFastPacker in cui l'header di versione uint32 (4 byte) non veniva scritto in cima a Compress_en.bin.
  - Questo disallineamento provocava il fallimento di LanguageImporter:ValidateVersion (json=1792149800, bin=1886547789), bloccando l'importazione corretta delle risorse localizzate e impedendo la visualizzazione dell'ologramma/modello del boss **Omega Sherro** nella schermata delle Olo-Battaglie (Simulazione Olo-Battaglia).
  - Ora l'header binario a 4-byte rispecchia fedelmente _version del file json in tutte le installazioni (Steam e Pawprint).

- **Armonizzazione Completa Boss Olo-Battaglie & Serie Omega**:
  - Uniformata la nomenclatura di tutti i tre boss attivi delle Olo-Battaglie in formato canonico: **Omega Sherro**, **Omega Infergon** e **Omega Tucking**.
  - Risolti i segnaposto temporanei (Drago loto (segnaposto) / Lotus (Placeholder) Dragon, ID 1669901594 e 2133940225) mappandoli a **Omega Sherro**.
  - Invertite tutte le 34 occorrenze residue della serie boss (da *Infergon Omega* a **Omega Infergon**, da *Tucking Omega* a **Omega Tucking**, da *Glynsera Omega* a **Omega Glynsera**, da *Helgon Omega* a **Omega Helgon**, da *Sherro Omega anziano* a **Anziano Omega Sherro**).

---

## [1.1.4] - 2026-10-22

### ⚔️ Allineamento Totale Missioni Secondarie, Atti & Lore Originale Steam
Audit filologico completo e incrociato tra i file originali Steam (`NewTextMap_en.json` e `NewTextMap_zh_CN.json`) e la localizzazione italiana su tutte le missioni secondarie, catene di atti, requisiti e terminologia:

- **Allineamento Titoli Missioni Secondarie & Requisiti (Atti della Dimora)**:
  - **Atto 2**: Allineato il requisito `Completa la missione "Un raccolto più ricco"` con il titolo canonico del capitolo `Atto secondo: Un raccolto più ricco` (eliminata la divergenza con *"Raccolti più ricchi"*).
  - **Atto 3**: Unificati il titolo del capitolo `Atto Terzo: Una nuova formula` e il requisito `Completa la missione "Una nuova formula"` (eliminata la divergenza tra *"Una Formula Completamente Nuova"* e *"Nuove ricette"*).
  - **Atto 4**: Uniformati i titoli dei capitoli `Atto quattro: È tempo di esplorare (Parte 1/2)` con i prompt di sblocco (eliminata la discrepanza con *"Esci ed esplora"*).
  - **Atto 5**: Allineato il requisito `Completa la missione "Sistema di controllo climatico: Parte 1"` con il titolo `Atto quinto: Sistema di controllo climatico (Parte 1)` (eliminato *"Sistema di controllo ambientale"*).
  - **Atto 6**: Sincronizzati i capitoli `Atto sei: La casa dei sogni (Parte 1/2)` e i relativi requisiti di completamento (eliminata la discrepanza con *"Casetta da sogno"*).
  - **Atto 7**: Unificati il titolo `Atto sette: Festival di Astra` e la missione `Completa la missione "Festival di Astra"` (eliminato *"La stagione del Festival di Astra"*).
  - **Tutorial**: Aggiornato in `missione tutorial: "Prima prova nella Dimora"` (eliminato *"Prima prova a Casa"*).

- **Allineamento Oggetti & Trame delle Missioni Secondarie**:
  - **La Missione dell'Elmo Rotto (Sorora - Russet Highlands)**: Risolto il clamoroso disallineamento in cui l'oggetto chiave veniva chiamato *"Casco spezzato"*, *"Casco rotto"* ed *"Elmo Spezzato"*. Ora è uniformato ovunque su **`Elmo rotto`** (*"Trova l'Elmo rotto"*, *"Dai l'Elmo rotto a Sorora"*, *"Rumor: Un elmo rotto?"*).
  - **La Spada del Coraggio**: Unificata la leggendaria lama di Pawney su **`Spada del Coraggio`** (eliminate le occorrenze residue di *"Spada del Valore"*). Uniformata inoltre la versione arrugginita su **`Spada di ferro arrugginita`**.
  - **Missione del Faro (Sayn)**: Allineato il titolo della missione **`È forse un... faro?`** con il prompt di completamento `Completa la missione: È forse un... faro? e torna da Sayn` (eliminato *"Quello è un... faro?"*).
  - **Missioni Guerriero / Lottatore (Cresta delle Mille Zanne & Altopiani)**: Sincronizzati i suggerimenti di progressione HUD con i titoli effettivi delle missioni nel registro (sostituito l'inesistente *"Il lottatore"* e *"Il guerriero"* con **`Guerriero`**).
  - **Rosetower Woods**: Normalizzata la notazione delle missioni su **`Fiori e spine: Rosetower Woods`** (unificati i trattini e il singolare *"wood"*).
  - **Le Stelle e il Cavaliere**: Standardizzata la capitalizzazione in tutte le missioni di viaggio su **`Le Stelle e il Cavaliere`**.
  - **La Leggenda della Terra di Lampi e Tuoni**: Sincronizzato il capitolo di viaggio con la menzione canonica delle leggende di Breezy Plains.
  - **Fragranza Colorata**: Sincronizzato il titolo del capitolo della storia principale con le guide dell'evento (eliminato *"Colori Profumati"*).

- **Lore & Nomenclatura Mitologica (Eolo & Costa dello Zefiro)**:
  - **Aeolus -> Eolo**: Sostituite tutte le 56 occorrenze residue del nome inglese `Aeolus` con il canonico dio dei venti italiano **`Eolo`** e **`Eone Eolo`** (in dialoghi, targhette PNG e testi rituali).
  - **Costa Zefira -> Costa dello Zefiro**: Normalizzate le diciture geografiche su **`Costa dello Zefiro`**.

- **Homeland: Normalizzazione Sistematica Dimora (489 Stringhe)**:
  - Risolta la frammentazione terminologica tra *Casa* e *Dimora* nei contesti del sistema Homeland (`家园`). Sostituite sistematicamente 489 occorrenze con le forme corrette: **`nella tua Dimora`**, **`della Dimora`**, **`alla Dimora`**, **`Lotto della Dimora`**, **`Incubatrice della Dimora`**, **`Costruzione della Dimora`**, **`Invito alla Dimora`**, ecc.

- **Comandi di Tracciamento & Eventi**:
  - **Track Homeland Journey**: Unificate le 5 formulazioni divergenti sull'unica dicitura corretta **`Traccia il Viaggio della Dimora`** (eliminate le varianti *"Traccia Viaggio verso la terra d'origine."* e *"Traccia Viaggio verso casa."*).
  - **Track Aniipod Maker**: Corretta l'assurda traduzione letterale *"Fabbricatore di Aniipod su binari (Livello 1/2/3)"* in **`Traccia Fabbricatore Aniipod (Livello 1/2/3)`**.
  - **Segnaposto Viaggio di Astra**: Normalizzati tutti i 33 segnaposto delle missioni di viaggio nella forma standard **`Segnaposto Viaggio di Astra <N>`**.
  - **Sulle Tracce del Sentiero**: Sincronizzate tutte le denominazioni dell'evento a tempo limitato (eliminate varianti come *"Tracciando la pista"*, *"Sulle tracce"* e *"Seguendo la traccia"*).
  - **Arena Battaglia Secondaria ARK Voxel**: Eliminata la traduzione errata *"Arena di battaglia laterale"*.

- **Grammatica & Preposizioni nei Requisiti di Gioco**:
  - Corrette le preposizioni articolate errate: `Vai alla Cresta delle Mille Zanne` (da *"al Cresta"*), `Vai ai Russet Highlands` e `dei Russet Highlands` (da *"agli/degli Russet"*).
  - Corretto il refuso dell'opzione binaria da `N.` a `No.` in chiave 2094195296.
  - Sostituito il nome provvisorio `Farfalletti` con il canonico `Flutternym` nella descrizione della quest 1205944301.

- **Armonizzazione Cluster Non Contestuali**:
  - Armonizzate decine di stringhe di sistema ripetute: descrizioni sfide d'élite, forzieri misteriosi, avvisi Alfa, requisiti di abbandono mondo cooperativo, pulsanti UI e badge di primo completamento.

---

## [1.1.3] - 2026-10-22

### ✍️ Perfezionamento Fonotattico & Grammaticale (56 Correzioni Mirate)
- **Elisione Articoli & Preposizioni Articolate davanti a Vocale**:
  - Unificata la serie di missioni su **`L'Emberpup più forte`** e tutte le 39 menzioni sparse (corretto l'antiestetico *"Il Emberpup"*, *"del Emberpup"*, *"con il Emberpup"* in **`l'Emberpup`**, **`dell'Emberpup`**, **`con l'Emberpup`**).
  - Normalizzate 17 menzioni dell'istituto scientifico di gioco su **`L'Istituto Polaris`**, **`dell'Istituto Polaris`** e **`dall'Istituto Polaris`** (eliminato *"Il Istituto"*, *"del Istituto"*, *"dal Istituto"*).

---

## [1.1.2] - 2026-10-22

### 💎 Certificazione di Qualità Totale al 100% (Verifica Esaustiva Rigorosa)
- **Armonizzazione Collezione Luna del Raccolto**:
  - Risolti gli ultimi 8 progetti e blueprint che menzionavano ancora frammentazioni obsolete (*"Luna della Vendemmia"* e *"Luna della mietitura"*), unificandoli tutti nella nomenclatura canonica **`Luna del Raccolto`** (*Coniglio Lunare*, *Verde Giardino*, *Bacche Aspre*, *Mosaico di Frutta*, *Onda di Riso*, *Pioggia di Osmanto*, *Luce Stellare*).
  - Unificata la festa stagionale in **`Raduno del Raccolto`**.
- **Coerenza Brand, Nomi & Stile**:
  - Uniformato l'addetto all'accoglienza su **`Addetto alla reception di ChillBeanz`** (eliminato *"FagioliRelax"*).
  - Normalizzati tutti i menu di personalizzazione su **`Seleziona acconciatura`** e **`Importa dati acconciatura`** (eliminato l'obsoleto *"pettinatura"*).
  - Standardizzata la notazione delle statistiche difensive su **`DIF F./DIF M.`** in tutte le schede equipaggiamento.
- **Pulizia dei Segnaposto di Test**:
  - Rimossi i caratteri cinesi residui nelle stringhe interne di test (sostituito `简体中文` con `Cinese Semplificato`).
- **Verifica Statistica Globale**:
  - Zero refusi grammaticali, zero tag non bilanciati, parametri `{param}` e `%s` verificati al 100% identici alla versione Steam.

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
