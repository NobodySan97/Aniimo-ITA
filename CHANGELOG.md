# 📜 Registro delle Modifiche (Changelog)

Tutte le modifiche e gli aggiornamenti apportati alla traduzione italiana di **Aniimo** sono documentati in questo file.

## [1.2.3] - 2026-10-30

### 🆕 Delta build Steam 3857679 (confronto integrale con il nuovo inglese)

Il client Steam è passato alla build **3857679** con una nuova coppia inglese (`_version 1793329842`, **134.274 voci** — FunPlus ha rimosso 3 ID, ora ignorati automaticamente dal compilatore). Confronto riga per riga EN⇔IT su tutte le 134.274 coppie, con correzione chirurgica:

- **Numeri di gameplay (2 ID)**: `2103507442` e `2111964422` riportati ai valori dell'inglese (10% / 15% / 10%); nel TSV figuravano 25% e 15% non presenti nel gioco. Verificate le altre 28 segnalazioni di cifre: tutte rese legittime di formati convertiti (orari AM/PM, date, «terzo» vs «3°»).
- **Tag rich-text & unità "s" (12 ID Holo-Battaglie)**: eliminati i casi con l'unità finita *dentro* i tag (`duration)s>`, `0.5ss`, `5ss`, `20ss`, `8ss`, `6s`) e token riportati identici alla nuova firma inglese (`param4`, `2122304`, `buffConfigData,21583022,duration). I tooltip tornano a renderizzare valori e formattazione corretti.
- **Punti corrotti (1 ID)**: `1580660308` ripulito dai punti infilati dentro parole e tag (`bers.agli`, `<s.tyle=`, `cus.tom…`, `mas.s.imi`).
- **Sprite tradotto (1 ID)**: `1607405861` ridotto alla risorsa corretta **`UI_Img_Weather_Thunderstorm`** (era `UI_Img_Weather_Temporale`).
- **Residui di elaborazione (2 ID)**: rimosso il marker `<<<END>>}` (`1618322180`) e la frase duplicata (`1167369090`).
- **Contenuti allineati al nuovo inglese (7 ID)**: completato il paragrafo 3 del Risveglio potenziale (reimpostazione al livello 60 con [Carte di Reimpostazione del Potenziale] e [Essenze Starcryst]); troncate le 4 storie che FunPlus ha ridotto nella nuova build (`1831131307`, `2005948146`, `2047726329`, `2105352615`); ripristinati gli a-capo dei 2 titoli «batch».
- **Correzioni da revisione integrale del corpus (5.119 segnalazioni analizzate una per una)**: completate 2 frasi **miste EN/IT** rimaste parzialmente in inglese (`1761194981` — «We were little back then…» e `1838878505` — «...What a beautiful night view…»); NPC corretto in **`Rhaven il Profumiere`** (l'EN dice *Rhaven*, non *Rhoven*); anglicismo *«must-have»* sostituito (2 ID); sotto-storia dell'Uovo di Iris trascritta in modo più fedele. Keeps per canone confermati: titoli evento citati (*Departure with the Wind*), la citazione *«less is more»*, la nota di debug EN («The text "+99"…» → IT «+99»).
- **Correzioni dal blocco 7/6 della coda (166 righe rianalizzate, 14 fix reali)**: deduplicati frammenti (1270302174, 1756713461), 2 testi con prima parte lasciata in inglese riscritti (1141664849, 1771434021), nomi evento mescolati unificati (1504931490, 1524521893), Ride the Waves convertito a Cavalca le onde (canon gia presente nel corpus), Hypnowl dell'Alibi, anglicismi rimossi (must, know-how), onomatopea Goo ripristinata, bolla Lyrelle completata. Il resto del blocco: rendizioni legittime o keeps per canone (specie Saws/Ekrim/Stashix invariate, mappature segnaposto Omega Sherro).
- **Revisione scambi semantici (216 segnalazioni analizzate 1 a 1, 12 fix reali)**: "sweet goo" convertito in sostanza appiccicosa (2 ID), canonico Wild Surge riscritto in Ondata Selvaggia ovunque (5 ID), Debuff Acqua unificato (era Malus Acqua), Crea [Dominio della Regina] (era Espande), legarmi a Pip / legarci a un Aniimo (era accoppiarlo e agganciarci), quelle forme (era quei moduli), picchiano forte (era colpiscono duramente), battere i ritmi (era ritmi sorprendenti), lungo soffio (era lungo respiro). Restanti 204 segnalazioni: rendizioni legittime con negazioni retoriche e forme gain/earn convertite in ottenere. Verificato a campione (200 estratti casuali) che le 12.637 stringhe IT identiche a EN non canoniche sono correttamente non tradotte (nomi, numeri, simboli).
- **Coerenza terminologica sistematica (74 ID da coda puntata)**: canon **Tenuta > Dimora** (11 ID sul sistema Dimora), **Glynsera/Melloblum/Waleetle/Inferlupa Prismatico > Prismana <Aniimo>** (ordine canonico del nome), **Aniimo Prismatici > Aniimo Prismana** (14), **Flusso Prismatico > Flusso di Prismana** (11), **energia dei Vena > energia della Vena**, **Partenza col vento/col Vento > Partenza con il vento** (20, titolo stagione S1), **Stellina > Starine** (27, specie canonica invariata; resta 1 caso con nome proprio sull'EN).
- **Chiusura della revisione integrale riga per riga (~870 interventi successivi)**: scanner anti-corruzione universale (token-frequenza a distanza-1) elaborato per l'intero corpus (35.232 token, 1462 anomalie vagliate una per una + riparazioni dei corrucci residui); sistematizzazione del canone di sistema (Vena/Frutto di Vena/Festival della Fioritura/Flusso di Prismana/Colpo Fortunato/Miele d'Oro/Stadio Lumin-Gamma-Nova/Dimora/Terreno agricolo/Partenza con il vento/Debuff Acqua) su tutte le famiglie di stringhe evento (Settembre/Ottobre/Novembre); correzione delle stringhe di corruzione e dei refusti di canone da scanner (Sonia>Sunia, Sherry>Sherro, Chirri>Chirpi, Lilipoli>Lilipole, Starite>Starine, Globo?>Glub?, impavidi>temerari, ordine Prismana <Aniimo> ovunque, Tamura, etc); normale e corretta la corruzione "un tipo di token.freq==1" dei valori ID 1124026529/1413288742/1803534531; voci QMARK e SENT validate per campione come rese retoriche legittime. Kept per canone: nome famiglia descon "Venatura" (arredamenti Dimora), "Game over", citazioni "Monay/Van Coe".
- **Chiusura coda R6 (141 spazi ai bordi)**: allineati ai bordi dell'inglese per riga (lead/trail replicati esattamente dalla sorgente EN); la validazione finale registra **R6 = 0** su tutte le 134.274 coppie. Precedentemente la coda era dichiarata "opzionale": qui completata e azzerata per conformitÃ  al requisito di confronto riga per riga.
- **Revisione a team (blocchi 01-25 di 5.000 coppie, 125.000 coppie riviste 1 a 1 da sub-agenti read-only con fix applicati in 18 passate)**: canone globale irrogato su tutto il corpus â€” Lirella>Lyrelle (183), Testa confusa>Muddlehead (33), RIGEN>REGEN (168), Primegia>Primegy (110), Shelly Sparkly>Sparkly Shelly (54), Isole Whisperwake>Whisperwake Isles (97), Valle delle Lumilucciole/Farfalluce>Valle delle Lucciole (31), odata selvaggia/Impeto>Ondata Selvaggia (25), Festival dei Fiori>Festival della Fioritura (14), Malus Acqua/Fulmine>Debuff (7), Dipartimento di Arti Belliche>Arti Marziali (17), alberi dorsale>Alberi Dorsale, Ecrim>Ekrim, GoGoCase/Dimore>GoGoHomes, PC:>CP: (19), Febe>Phoebe, order Alfa <Nome> (~350 inversioni), Timbri Nati dal Vento/Stagionali, "lo <specie>" > "il <specie>" (133 articoli), 12 righe perse da un bug del pass di blocco-14 ripristinate da HEAD con i fix riapplicati e verificate. Restanti: rese retoriche, onomatopee equivalenti, corruzioni EN-documentate, canon specie/NPC non tradotti â€” tutti falsi positivi confermati.
- **Validazione (read-only)**: su 134.274 coppie — **0** tag diversi, **0** sprite tradotti, **0** cifre mancanti reali, **0** a-capo in disaccordo EN/IT, **0** differenze di punteggiatura finale, **0** vuoti, **0** doppio escape; le stringhe identiche residue (~1.9mila) sono legittime (sprite-glyph `UI_CharB/Y_…`, stringhe di debug, toponimi canonici). TSV UTF-8 senza BOM, LF, **9.096.594 byte**, MD5 `ac24678c7670d49f6fb1da6c528a5d8c`.
- **Nota sulla copertura**: il manifest dichiara ora **134.274 voci attive** (su 134.277 righe): i 3 ID residui nel TSV non esistono più nel gioco e vengono ignorati da `AniimoFastPacker` senza fallback.

## [1.2.2] - 2026-10-30

### 🗂️ Grafia Canonica delle Creature & Integrità Voci

- **Canonica `Tuckin` (129 occorrenze su 124 stringhe)**: sostituiti tutti i residui del vecchio `Tucking` con `Tuckin`, grafia verificata su wiki ufficiale ([wiki.aniimo.com](https://wiki.aniimo.com/)), Aniilog e guide esterne. La regola vale anche per i boss delle Olo-Battaglie (*Omega Tuckin*). I placeholder interni dei testi editor (es. `Tuckin_Rampicante`) restano invariati.
- **Voci ripristinate (3 ID)**: recuperate tre voci perse durante una sessione di editing — `1078292740` (*Seta a specchio*), `1500305162` (*Modalità immersiva*), `1908680995` (impostazioni HUD). La copertura torna **134.277/134.277** con ordine identico alla mappa.
- **Rifinitura terminologica diffusa (~840 stringhe)**: toponimi, articoli e accordi di genere, inversioni logiche (es. *«ha votato per te»*), *«Mappapa»* → **`Mappa`** e l'ultimo residuo di `Twine` → `Legame`.
- **Validazione (read-only)**: 134.277/134.277 voci, 0 ID estranei, 0 duplicati, 0 vuoti, 0 doppio escape (le **4.059** righe con a-capo mantengono esattamente il numero di interruzioni della v1.2.1), LF, UTF-8 senza BOM, **9.096.560 byte**, MD5 `bf16502bb6806e402f0322e23dd5f7cf`.
- **Regole di nomenclatura**: aggiornata la documentazione interna (`AGENTS.md`) con la sezione completa «Termini da non tradurre» derivata dal canone ufficiale (creature, toponimi, NPC, marchi).

## [1.2.1] - 2026-10-29

### 🔧 Correzione Integrità Testi (revisione riga per riga)

Revisione dell'intero database diviso in **27 blocchi da 5.000 righe**, con confronto riga per riga dei 134.277 ID contro i file inglesi originali della build Steam `3846247`. Nessuna voce è stata aggiunta o rimossa: **134.277/134.277**, ordine identico alla mappa.

- **A-capo (3.807 ID)**: nella v1.2.0 l'interruzione di riga era salvata con doppio escape e finiva a schermo come `\n` letterale invece di andare a capo. Ora i **4.059** testi che nell'inglese hanno a-capo hanno lo stesso numero di a-capo anche in italiano (prima solo 247 erano corretti).
- **A-capo persi (5 ID)**: recuperati gli a-capo iniziali/finali rimossi — `1156606847`, `1606014038`, `1782857516`, `1982562487`, `2017669733`.
- **Tag di markup (6 ID)**: ripristinati i tag che erano stati tradotti e che il motore di testo avrebbe mostrato come testo letterale — `<Twenty>`, `<Age Fifty>`, `<完>`, `<占位>`, `<Title Name (Placeholder) Title>`, `<Departure with the Wind>`.
- **Terminologia**: unificata la denominazione delle *Outings* su `Aniimo Uscite` / `uscite Aniimo` (16 occorrenze contro le 8 di `Aniimo Gite`, ora eliminate insieme alle 2 rimaste in inglese).
- **Grammatica (13 ID)**: corretti gli articoli davanti ai nomi di gioco (`il Aniimo` / `la Aniimo` → `l'Aniimo`, `i Aniimo` → `gli Aniimo`, `allo Omega` → `all'Omega`), l'articolo errato `Lo camper` → `Il camper` e una concordanza al plurale (`Ancora sveglio... ti inzuppo` → `Ancora svegli... vi inzuppo`).
- **Revisione semantica**: controllo automatico su tutte le 134.277 righe di negazioni, coppie opposite (aumenta/riduce, prima/dopo, su/giù, apre/chiude…), numeri scritti a parole, nomi propri ricorrenti, percentuali e segnaposto residui: **nessun errore di senso rilevato**; i casi segnalati erano rese idiomatiche corrette.
- **Rifiniture**: rimossi 2 spazi finali spuri (`1300747024`, `2116770230`) e aggiunto lo spazio prima di `:)` nelle lettere di Hayes (`1402805528`, `1664634092`).
- **Verifiche che passano**: 0 fallback, 0 valori vuoti, 0 ID estranei, 0 duplicati, tag `<style>`/`<color>`/`<link>`/`<sprite>`/`<customRichText>`/`{param}`/`%s`/`#...#`/blocchi `{playerGender, select, …}` identici all'inglese, 0 residui CJK, nessuna forma boss invertita. AniimoFastPacker: translated=134.277, fallback=0, round-trip completo di tutti gli offset.

### 🔧 Launcher v1.0.1

- **Nessun falso avviso di aggiornamento**: il launcher confrontava `LuaCacheVer.txt` come stringa esatta, quindi un file riscritto dal gioco con prefisso `1.1.` (invece del `1.0.` scritto dall'installer) faceva comparire *"Nuova patch rilevata"* anche senza alcuna patch. Ora il confronto ignora il prefisso di versione e verifica build, lunghezza e MD5; una differenza reale dei dati continua a essere segnalata.
- **Prefisso della cache conservato**: in installazione e ripristino viene mantenuto il prefisso già presente nel file (`1.1.` se lo ha scritto il gioco), così il gioco non ha motivo di rigenerare la cache.
- **Rilevamento build**: `Get-GameBuild` accetta ora qualsiasi prefisso `N.N.` nel file di cache, non solo `1.0.`.

---

## [1.2.0] - 2026-10-29

### 🚀 Aggiornamento alla Build Steam 3846247

Allineamento completo della traduzione italiana alla build Steam 3846247 di Aniimo: **134.277 voci** (contro le 112.418 della v1.1.8), con integrazione di 22.369 nuove voci, uniformazione terminologica e toponimi, validazione read-only con AniimoFastPacker (0 fallback).

- **Copertura**: 134.277/134.277 voci (100%), ordine identico alla mappa, 0 mancanti/extra/duplicati.
- **Nuove voci**: 10.807 nuovi testi tradotti via machine translation (10 proxy Webshare, endpoint clients5); 195 vuoti iniziali risolti (126 via MT/override, 69 via `\u200b`); 1.886 testi comuni corretti; 5.637 stringhe riutilizzabili.
- **Terminologia**: Alfa (Alpha), Omega Magmarex, Forma Suprema (Ultimate), Olo-Battaglia (Holo-Battle e varianti: Simulazione, Interlink, Simulatore), Onda Polaris, Medaglione Polaris, Dimora (Homeland/Base), Ondata Selvaggia (Wild Surge), Santuario/Santuari, Olo-congegno. Mantenuti Costa dello Zefiro, Santuario Perduto, Twine → Legame, Twine ShaderPush, Camper Liv., Punti Suprema/Punti suprema, olo-congegno/olo-battaglia minuscoli.
- **Token**: preservati tutti i token tecnici (`<style>`, `<color>`, `<link>`, `<sprite>`, `<customRichText>`, `{...}`, `%s`/`%d`, `#...#`, `#playerName#`, `#npcName#`, `#playerGender#`, codici colore). Ripristinati tag style mancanti/sbilanciati (12 ID) e placeholder tradotti (`#@head@#`, `<Twenty>`, `<Age Fifty>`, `<完>`, `<占位>`). Normalizzati i codici colore.
- **Blocchi genere**: corretti i 13 blocchi `{playerGender, select, female{...} other{...}}` e i 4 residui inglesi con override manuali.
- **Zero-width**: 69 ID con sorgente solo zero-width tradotti in `\u200b`.
- **Validazione**: 0 vuoti, 0 residui inglesi, 0 placeholder ZXQ, 0 separatori `@@@`, 0 token mismatch, 0 fallback. AniimoFastPacker: translated=134.277, round-trip completo di tutti gli offset. Nessun file del gioco modificato o installato.

---

## [1.1.8] - 2026-10-29

### 🧹 Revisione Finale: Errori Certi, Terminologia di Gioco & Toponimi
Revisione conclusiva autorizzata sull'intero database (112.418 voci), con correzioni mirate e validazione read-only sul packer I18N della build `3746914`. **160 ID modificati** in totale, senza alcuna modifica ai file del gioco.

- **Errori certi ripristinati (2 ID)**:
  - **ID `1133585133`**: la lettera del piccolo scrigno di legno era stata sostituita da un testo errato (*«Segui Chitter fino alla barriera...»*); ripristinata la traduzione completa della lettera originale.
  - **ID `1769938750`**: mancava il tag `<style=Hint_BgL>...</style>` attorno a `[Valore]`; ripristinato per mantenere la formattazione originale.
- **Correzioni grammaticali (8 ID)**:
  - *«Se mi legame con un Budclaw»* ➔ **`Se mi lego a un Budclaw`**
  - *«Quando mi legame con lui»* ➔ **`Quando mi lego a lui`**
  - *«se mi legame con il Flutternym»* ➔ **`se mi lego al Flutternym`**
  - *«eseguire una legame»* ➔ **`eseguire un legame`** (4 stringhe)
  - *«Lega un legame con...»* ➔ **`Crea un legame con...`**
- **Uniformazione terminologica**:
  - **Sanctum / Sacrario ➔ Santuario / Santuari**: 61 ID e 64 occorrenze allineate al termine canonico, inclusi *Lost Sanctums* ➔ **`Santuari Perduti`**. Mantenuta l'eccezione consolidata **`Santuario Perduto`**.
  - **Holo-gizmo ➔ Olo-congegno / Olo-congegni**: 25 ID e 26 occorrenze; eliminate le varianti *olo-gizmo*, *olo-aggeggi*, *Olo-gadget*, *Ologadget*, *Holo-aggeggio* e *congegni-ologramma*.
  - **Ultimate ➔ Suprema**: 47 ID e 53 occorrenze, incluse le forme plurali *Ultimates* e le etichette *DAN finale*, *Punti Finale* e *Punto/i Finale*. Mantenuti gli usi aggettivali legittimi (*obiettivo finale*, *abilità supreme*, *Primo Premio Assoluto*, *Final DMG*).
- **Toponimi**:
  - Corretto **`Rosetower wood` ➔ `Rosetower Woods`** in 11 stringhe.
  - Mantenuti i toponimi inglesi già affermati e le eccezioni consolidate **`Costa dello Zefiro`** e **`Santuario Perduto`**.
- **Punteggiatura**:
  - Aggiunto il punto finale a 6 stringhe (*Traccia il Viaggio della Dimora*, *Arrivo alla Whiterose Tower*) per allinearle all'inglese.
- **Validazione (read-only)**:
  - Copertura **112.418/112.418** voci, 0 mancanti, 0 extra, 0 duplicati, 0 vuoti.
  - Compilazione con `AniimoFastPacker` sulla build `3746914`: **0 fallback**, header `_version 1792149800`, round-trip completo di tutti gli offset.
  - TSV: 7.508.142 byte, LF, UTF-8 senza BOM, MD5 `db8991a8476a3eb5a77efe24ffd9c576`.
  - Nessun file del gioco è stato modificato o installato: `LuaScripts.xdf` invariato (MD5 `F5AF1903B0FF9011142345BA06B2A9E8`).

---

## [1.1.7] - 2026-10-29

### ⚔️ Revisione Terminologica Globale, Armonizzazione Twine & Correzioni Grammaticali
- **Uniformazione Meccanica Twine (`intrecciato` -> `legato` / `Legame`)**:
  - Risolto il calco letterale nelle 56 stringhe residue della modalità Twine:
    - *«Volo intrecciato»* ➔ **`Volo in Legame`**
    - *«Nuotare durante l'Intreccio»* ➔ **`Nuoto in Legame`**
    - *«Scalata durante l'intreccio»* ➔ **`Scalata in Legame`**
    - *«Mentre sei intrecciato»* / *«Quando sei intrecciato»* ➔ **`Mentre sei legato`** / **`Quando sei legato`**
    - *«Aniimo attualmente intrecciato»* ➔ **`Aniimo attualmente legato`**
    - *«Se sciogli l'intreccio»* ➔ **`Se sciogli il legame`**
    - *«Saltare l'intermezzo Intrecciati insieme?»* ➔ **`Saltare l'intermezzo Legati insieme?`**
    - Eliminati i residui in lingua inglese (*"usa Twine su"*, *"addestrati e Twine"*, *"Energia Twine"*).
    - Completati gli ultimi 5 residui sfuggiti alla prima passata: *«si è intrecciato con esso»*, *«Ti sei già intrecciato prima»*, *«Durante l'intreccio»*, *«ci siamo intrecciati»*, *«si intrecciò con un Chirpi»*.
    - Le occorrenze di *intrecciato* riferite a rattan, corda, bambù e arredi sono volutamente mantenute: sono descrizioni materiali, non la meccanica Twine.
    - La stringa tecnica di debug `Twine ShaderPush` resta invariata: non è testo di gioco e non viene mostrata al giocatore.
- **Equipaggiamento Held Items (`Strumenti Assegnati` -> `Strumenti Tenuti`)**:
  - Allineate tutte le 100+ occorrenze di descrizioni, negozi di scambio e ricompense sulla nomenclatura ufficiale di gioco **`Strumento Tenuto`** / **`Strumenti Tenuti`** (eliminato anche il calco errato *«Bene Legato»*).
- **Armonizzazione Abilità & Nomi Luoghi**:
  - **Suprema**: sostituite le 4 occorrenze residue di *«Mossa Finale»* e *«Punti Mossa Finale»* con il termine canonico **`Suprema`** / **`Punti Suprema`**.
  - **Colpospirale**: tradotti tutti i 9 residui inglesi di *«Coilstrike»* in **`Club Colpospirale`**, **`Coupon Colpospirale`** e **`Misuratore di Forza Colpospirale`**.
  - **Cresta delle Mille Zanne**: corrette le due menzioni residue dell'errato *«Crinale Millefauci»*.
  - **Carica Rapida**: localizzata l'abilità esplorativa di Magmarex (*Fast and Furious* / `疾行冲撞`) in **`Carica Rapida`**.
  - **Ambre Lumin**: tradotti i residui di *«Lumin ambers»* in **`Ambre Lumin`**.
- **Correzioni Grammaticali Sistematiche negli Articoli**:
  - Corrette 63 occorrenze di *«Gli Pathfinder»* / *«degli Pathfinder»* in **`I Pathfinder`** / **`dei Pathfinder`**.
  - Corrette 45 occorrenze di *«negli / degli / agli Russet Highlands»* in **`nei / dei / ai Russet Highlands`**.
  - Corrette 10 occorrenze di *«i / dei Emberpup»* in **`gli / degli Emberpup`**.
  - Corretto *«del Zephyrus Landbridge»* in **`dello Zephyrus Landbridge`**.

### 🔧 Launcher & Affidabilità
- **Aggiornamento a prova di downgrade**: il manifest remoto è ora obbligatorio. Se non è raggiungibile o non contiene versione e MD5 validi, il TSV locale non viene toccato. Il file scaricato viene verificato contro il `tsv_md5` del manifest prima di sostituire quello esistente.
- **Riparazione dei TSV corrotti**: `AlreadyUpToDate` non si basa più sul solo `tsv_md5` dichiarato nel manifest locale; viene ricalcolato l'MD5 reale del file. Un TSV corrotto o troncato viene riscaricato anche se il manifest lo dichiara allineato.
- **Protezione anti-downgrade ristretta**: il confronto per data resta attivo solo quando la versione locale è sconosciuta e il file è plausibile (≥ 1 MB). Non blocca più aggiornamenti legittimi da versioni precedenti né la riparazione di file corrotti.
- **Manifest v1.1.7 coerente**: il `tsv_md5` pubblicato corrisponde al blob LF realmente servito da GitHub (`*.tsv text eol=lf`).
- **Metadati da GitHub**: `versione.json` locale resta la fonte principale. Il fallback remoto viene usato solo se il manifest manca o è illeggibile, viene validato contro l'MD5 del TSV e resta in cache per Dashboard e timer: nessuna chiamata di rete a ogni refresh.
- **Stato installazione più preciso**: rilevamento patch basato anche su `game_build` e `sa_xdt_md5` salvati nell'installazione; controllo di entrambi i file I18N (`Compress_en.bin` e `NewTextMap_en.json`); nessuna proposta di downgrade se la versione installata è più recente.
- **Archivi di gioco verificati**: `Resolve-AniimoDir` richiede sia `LuaScripts.xdf` sia `LuaScripts.xdt`; installazione e ripristino mostrano un errore chiaro se l'archivio è incompleto.
- **Ordinamento patchv2 robusto**: le cartelle hotfix con nomi non numerici non bloccano più la selezione della build.
- **URL remoti**: gli override `remote_tsv_url` / `remote_version_url` nel config e il rilevamento da `.git/config` sono ora effettivamente usati.
- **Dashboard reattiva**: la scheda si aggiorna anche quando cambia `versione.json`, non solo il file TSV.

---

## [1.1.6] - 2026-10-24

### ⚔️ Audit Integrale su Build Locale Steam (3746914) — Correzioni Finali
Audit filologico completo eseguito direttamente sulla build locale Steam (`NewTextMap_en.json` + `Compress_en.bin`, build `3746914`, `_version 1792149800`), con verifica di copertura 1:1 su tutte le 112.418 voci e sui canoni terminologici di `AGENTS.md`:

- **Spada del Coraggio — ultimi 2 residui eliminati (Leggendarie Pawney)**:
  - Uniformate le 2 occorrenze residue di *"Spada del Valore"* (ID `1615800851` e `1843604649`, missioni della lama leggendaria sul Russet Highlands) sul canonico **`Spada del Coraggio`**, in coerenza con l'inglese *Sword of Bravery* e con la decisione v1.1.4.
- **Risultati audit (tutti passati)**:
  - Copertura: **112.418/112.418** (0 voci mancanti, 0 voci extra non presenti nella build).
  - Checksum `tsv_md5` ricalcolato e aggiornato in `versione.json`.
  - Zero occorrenze residue di: Boss Omega invertiti (*Infergon Omega* ecc.), *Aeolus*, *Drago loto (segnaposto)*, *Casco spezzato/rotto*, *Colori Profumati*, elisioni errate (*Il Istituto*, *del Emberpup*).
  - Le 2 occorrenze di "casa" residuate sono casi legittimi (descrizioni d'arredo generiche, non il sistema Homeland/Dimora).

---

## [Launcher 1.0.1] - 2026-10-24

### 🔧 Affidabilità Launcher & Patcher (nessuna modifica al dizionario TSV)
- **Fix escape sequenze speciali in `AniimoFastPacker` (LoadTsv)**:
  - Le sequenze `\\` nel file TSV vengono ora gestite per prime: le voci che contengono
    un backslash letterale seguito da `n`/`t` (es. percorsi o testi compositi tipo `D:\\nome`)
    non vengono più corrotte in newline/tab inattesi durante la compilazione binaria.
- **Validazione rigida dell'header I18N (`_version`)**:
  - Se `_version` non è leggibile da `NewTextMap_en.json`, `BuildI18nPair` interrompe la
    compilazione con errore esplicito invece di produrre un header `0` non valido che
    bloccava `LanguageImporter:ValidateVersion` (schermate Olo-Battaglia).
- **Sincronizzazione GitHub senza corse (race condition)**:
  - Il download TSV usa ora un mutex dedicato e un file temporaneo per processo
    (`traduzione_ita.tsv.<PID>.download`): GUI e processo di aggiornamento di sfondo non
    possono più scrivere contemporaneamente lo stesso file temporaneo o scaricare in doppio.
  - `versione.json` locale viene riscritto in **UTF-8 senza BOM** (coerente con il repository).
- **Indice `LuaScripts.xdt` più robusto (`Update-XdtIndex`)**:
  - Parsing generico delle voci `CMList` (coppie chiave/valore), indipendente dall'ordine
    dei campi: immune a campi extra introdotti in future build del gioco.
  - Le voci non presenti nell'indice originale vengono ora valorizzate con l'**MD5 reale**
    letto dall'archivio, invece di un hash fittizio `0000...` che poteva invalidare la
    cache del loader Lua.
- **Modalità CLI protetta (`-Install` / `-Uninstall`)**:
  - Aggiunto il controllo "Aniimo è in esecuzione" anche da riga di comando: più
    installazioni/ripristini con file bloccati dal gioco.
- **Interfaccia: feedback e chiarezza**:
  - La barra di progresso mostra subito la fase di verifica su GitHub prima dell'installazione.
  - Nel dialogo di installazione completata compare un avviso quando alcune stringhe
    restano in inglese (non presenti nel dizionario locale), con invito a segnalarle su Issues.
  - Se l'elevazione UAC viene annullata, il launcher non tenta più l'installazione locale
    (che comunque fallirebbe) e lo comunica con un avviso dedicato.
- **Prestazioni**:
  - Cache MD5 (file ed entry ZIP, invalidata automaticamente su `LastWriteTimeUtc`):
    la Dashboard non ricalcola più hash su archivi di decine di MB ad ogni refresh.
  - `BrushConverter` memorizzato in cache invece di essere ricreato ad ogni aggiornamento UI.
  - Finestra di polling aggiornamento di sfondo estesa da 30 s a 120 s: i download lenti
    non vengono più persi silenziosamente.
- **Avvio senza flash console**:
  - Il `.bat` si riavvia da solo in finestra minimizzata: nessun flash visibile della
    console all'apertura del launcher (l'errore "installer.ps1 non trovato" resta visibile).

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
