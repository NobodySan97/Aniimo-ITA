# =====================================================================
#  ANIIMO - LOCALIZZAZIONE ITALIANA COMPLETA (POLARIS PATCHER v1.0)
#  Compilatore binario in-memory C# (AniimoFastPacker) + Interfaccia WPF
#  Architettura universale su StreamingAssets (preserva pmdata.bin e Lua)
# =====================================================================
param(
    [switch]$Install,
    [switch]$Uninstall,
    [switch]$UpdateTsv,
    [switch]$GuiAutoInstall,
    [switch]$GuiAutoRestore,
    [string]$GameDir = "",
    [string]$ExportPreview = "",
    [string]$InitialTab = ""
)

$ErrorActionPreference = 'Stop'

# Nasconde immediatamente la finestra console quando avviato in modalita' grafica
if (-not $Install -and -not $Uninstall -and -not $UpdateTsv) {
    try {
        Add-Type -Name Win32ConsoleHide -Namespace AniimoWin32 -MemberDefinition '
            [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
            [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
        ' -ErrorAction SilentlyContinue
        $consoleHwnd = [AniimoWin32.Win32ConsoleHide]::GetConsoleWindow()
        if ($consoleHwnd -ne [IntPtr]::Zero) {
            [void][AniimoWin32.Win32ConsoleHide]::ShowWindow($consoleHwnd, 0)
        }
    } catch {}
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# ---------------------------------------------------------------------
#  Compilatore C# In-Memory (AniimoFastPacker) + Estrattore Dizionario
# ---------------------------------------------------------------------
$csharpCode = @"
using System;
using System.IO;
using System.IO.Compression;
using System.Text;
using System.Collections.Generic;
using System.Text.RegularExpressions;

public class GlossaryRecord {
    public string TermIt       { get; set; }
    public string TermEn       { get; set; }
    public string CategoryName { get; set; }
    public string SearchToken  { get; set; }
}

public static class AniimoFastPacker {
    public static Dictionary<string, string> LoadTsv(string path) {
        var dict = new Dictionary<string, string>(130000, StringComparer.Ordinal);
        using (var sr = new StreamReader(path, Encoding.UTF8)) {
            string line;
            while ((line = sr.ReadLine()) != null) {
                if (line.Length == 0 || line[0] == '#') continue;
                int tab = line.IndexOf('\t');
                if (tab <= 0) continue;
                string id = line.Substring(0, tab);
                string val = line.Substring(tab + 1)
                    .Replace("\\n", "\n")
                    .Replace("\\r", "\r")
                    .Replace("\\t", "\t")
                    .Replace("\\\\", "\\");
                dict[id] = val;
            }
        }
        return dict;
    }

    public static object[] BuildI18nPair(string enMapJson, byte[] enBlob, Dictionary<string, string> trad) {
        string version = "0";
        var mVer = Regex.Match(enMapJson, "\"_version\"\\s*:\\s*(\\d+)");
        if (mVer.Success) version = mVer.Groups[1].Value;

        var enDict = new Dictionary<string, string>(130000, StringComparer.Ordinal);
        var sortedKeys = new List<string>(130000);

        var rx = new Regex("\"([^\"]+)\"\\s*:\\s*\\[\\s*(\\d+)\\s*,\\s*(\\d+)\\s*\\]", RegexOptions.Compiled);
        var matches = rx.Matches(enMapJson);
        foreach (Match m in matches) {
            string k = m.Groups[1].Value;
            if (k == "_count" || k == "_version") continue;
            int off = int.Parse(m.Groups[2].Value);
            int len = int.Parse(m.Groups[3].Value);
            string s = (len > 0 && off + len <= enBlob.Length)
                ? Encoding.UTF8.GetString(enBlob, off, len)
                : "";
            enDict[k] = s;
            sortedKeys.Add(k);
        }

        sortedKeys.Sort(StringComparer.Ordinal);

        var dedup = new Dictionary<string, int[]>(sortedKeys.Count, StringComparer.Ordinal);
        var msBlob = new MemoryStream(enBlob.Length + 1024 * 1024);
        var sbMap = new StringBuilder(6 * 1024 * 1024);
        sbMap.Append("{\n    \"_count\": ").Append(sortedKeys.Count).Append(",\n    \"_version\": ").Append(version);

        int translatedCount = 0;
        int fallbackCount = 0;

        foreach (string k in sortedKeys) {
            string txt;
            if (trad.TryGetValue(k, out txt)) {
                translatedCount++;
            } else {
                txt = enDict[k];
                fallbackCount++;
            }

            int[] pos;
            if (!dedup.TryGetValue(txt, out pos)) {
                byte[] b = Encoding.UTF8.GetBytes(txt);
                pos = new int[] { (int)msBlob.Length, b.Length };
                dedup[txt] = pos;
                msBlob.Write(b, 0, b.Length);
            }
            sbMap.Append(",\n    \"").Append(k).Append("\": [\n        ").Append(pos[0]).Append(",\n        ").Append(pos[1]).Append("\n    ]");
        }
        sbMap.Append("\n}");

        byte[] mapBytes = new UTF8Encoding(false).GetBytes(sbMap.ToString());
        byte[] binBytes = msBlob.ToArray();
        return new object[] { mapBytes, binBytes, translatedCount, fallbackCount, version };
    }

    private static bool IsCleanTerm(string s) {
        int len = s.Length;
        if (len < 2 || len > 42) return false;
        char first = s[0];
        if (!char.IsLetter(first)) return false;
        if (len >= 4 && s[1] == ' ' && s[2] == '-' && s[3] == ' ') return false;
        if (len >= 3 && s[1] == ':') return false;
        char last = s[len - 1];
        if (last == '.' || last == '?' || last == '!' || last == ':' || last == ';' || last == ',') return false;
        int spaces = 0;
        for (int i = 0; i < len; i++) {
            char c = s[i];
            if (c == ' ') {
                spaces++;
                if (spaces > 4) return false;
            }
            if (c == '\n' || c == '\r' || c == '<' || c == '>' || c == '{' || c == '}' || c == '[' || c == ']' || c == '#' || c == '%' || c == '_' || c == '?' || c == '!' || c == '"') return false;
            if (c == '.' && i + 1 < len && s[i + 1] == '.') return false;
        }
        return true;
    }

    private static bool ContainsWord(string textLower, string[] words) {
        for (int i = 0; i < words.Length; i++) {
            if (textLower.IndexOf(words[i], StringComparison.Ordinal) >= 0) return true;
        }
        return false;
    }

    private static readonly string[] WordsCombat = new string[] {
        "skill", "ability", "damage", "attack", "crit", "buff", "debuff", "shield", "heal", "stamina", "cooldown", "element", "aura", "blast", "strike", "slash",
        "attacco", "danno", "difesa", "critico", "scudo", "guarigione", "cura", "energia", "colpo", "raffica", "raggio", "esplosione"
    };
    private static readonly string[] WordsItems = new string[] {
        "ore", "wood", "stone", "seed", "berry", "potion", "crystal", "fragment", "coin", "chest", "box", "egg", "food", "recipe", "ingot", "gem", "pack", "voucher", "ticket", "shard", "powder", "fruit", "mushroom", "fish", "meat",
        "minerale", "legno", "pietra", "seme", "bacca", "pozione", "cristallo", "frammento", "moneta", "forziere", "baule", "cassa", "uovo", "cibo", "ricetta", "lingotto", "gemma", "buono", "biglietto", "polvere", "frutto", "fungo", "pesce", "carne"
    };
    private static readonly string[] WordsPlaces = new string[] {
        "woods", "forest", "island", "square", "tower", "valley", "cave", "mountain", "river", "lake", "ruins", "bridge", "camp", "port", "bay", "plains", "ridge", "peak", "hill", "village", "city", "town", "sanctuary", "shrine", "coast", "meadow", "landing", "strait", "highlands", "fields",
        "bosco", "foresta", "isola", "piazza", "torre", "valle", "grotta", "montagna", "fiume", "lago", "rovine", "ponte", "accampamento", "porto", "baia", "pianura", "crinale", "vetta", "collina", "villaggio", "santuario", "costa", "prato"
    };
    private static readonly string[] WordsHomeland = new string[] {
        "chair", "table", "bed", "lamp", "sofa", "carpet", "wall", "roof", "floor", "fence", "tile", "loft", "homeland", "cabinet", "shelf", "desk", "bench", "stool", "window", "door", "pillar", "planter", "rv",
        "sedia", "tavolo", "letto", "lampada", "divano", "tappeto", "muro", "tetto", "pavimento", "recinto", "mattonella", "armadio", "scaffale", "scrivania", "panca", "sgabello", "finestra", "porta", "pilastro", "fioriera", "camper"
    };
    private static readonly string[] WordsClothes = new string[] {
        "hat", "cap", "shirt", "pants", "shoes", "boots", "gloves", "jacket", "dress", "hair", "glasses", "mask", "skirt", "coat", "earrings", "necklace", "backpack", "outfit", "costume", "headwear",
        "cappello", "berretto", "maglia", "camicia", "pantaloni", "scarpe", "stivali", "guanti", "giacca", "abito", "capelli", "acconciatura", "occhiali", "maschera", "gonna", "cappotto", "orecchini", "collana", "zaino", "completo"
    };

    private static string Classify(string it, string en) {
        string comb = (it + " " + en).ToLowerInvariant();
        if (ContainsWord(comb, WordsPlaces))   return "Luoghi e Mappa";
        if (ContainsWord(comb, WordsCombat))   return "Abilit\u00E0 e Combattimento";
        if (ContainsWord(comb, WordsItems))    return "Oggetti e Materiali";
        if (ContainsWord(comb, WordsHomeland)) return "Camper e Arredo";
        if (ContainsWord(comb, WordsClothes))  return "Abbigliamento e Stile";
        return "Termini e Interfaccia";
    }

    private static ZipArchiveEntry GetEntrySafe(ZipArchive zip, string entryName) {
        var e = zip.GetEntry(entryName);
        if (e != null) return e;
        foreach (var entry in zip.Entries) {
            if (string.Equals(entry.FullName, entryName, StringComparison.OrdinalIgnoreCase))
                return entry;
        }
        return null;
    }

    public static List<GlossaryRecord> LoadGlossaryRecords(string saXdfPath, string tsvPath) {
        var result = new List<GlossaryRecord>(20000);
        if (string.IsNullOrEmpty(saXdfPath) || !File.Exists(saXdfPath) || !File.Exists(tsvPath)) return result;

        var trad = LoadTsv(tsvPath);
        string enMapTxt = null;
        byte[] enBlob = null;
        using (var zip = ZipFile.OpenRead(saXdfPath)) {
            var eMap = GetEntrySafe(zip, "xfs/luascripts/Data/I18N/NewTextMap_en.json");
            var eBin = GetEntrySafe(zip, "xfs/luascripts/Data/I18N/Compress_en.bin");
            if (eMap == null || eBin == null) return result;

            using (var sr = new StreamReader(eMap.Open(), Encoding.UTF8)) {
                enMapTxt = sr.ReadToEnd();
            }
            using (var s = eBin.Open())
            using (var ms = new MemoryStream((int)eBin.Length)) {
                s.CopyTo(ms);
                enBlob = ms.ToArray();
            }
        }

        var seenPairs = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var rx = new Regex("\"([^\"]+)\"\\s*:\\s*\\[\\s*(\\d+)\\s*,\\s*(\\d+)\\s*\\]", RegexOptions.Compiled);
        var matches = rx.Matches(enMapTxt);
        foreach (Match m in matches) {
            string id = m.Groups[1].Value;
            if (id == "_count" || id == "_version") continue;
            string it;
            if (!trad.TryGetValue(id, out it)) continue;
            if (!IsCleanTerm(it)) continue;

            int off = int.Parse(m.Groups[2].Value);
            int len = int.Parse(m.Groups[3].Value);
            if (len <= 0 || off + len > enBlob.Length) continue;
            string en = Encoding.UTF8.GetString(enBlob, off, len);
            if (!IsCleanTerm(en)) continue;
            if (string.Equals(it, en, StringComparison.OrdinalIgnoreCase)) continue;

            string pairKey = it + "\t" + en;
            if (!seenPairs.Add(pairKey)) continue;

            result.Add(new GlossaryRecord {
                TermIt       = it,
                TermEn       = en,
                CategoryName = Classify(it, en),
                SearchToken  = (it + " " + en).ToLowerInvariant()
            });
        }

        result.Sort((a, b) => string.Compare(a.TermIt, b.TermIt, StringComparison.CurrentCultureIgnoreCase));
        return result;
    }
}
"@
Add-Type -TypeDefinition $csharpCode -ReferencedAssemblies "System.IO.Compression", "System.IO.Compression.FileSystem"

# ---------------------------------------------------------------------
#  Percorsi, Configurazione e Metadati
# ---------------------------------------------------------------------
$ScriptDir       = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir         = Split-Path -Parent $ScriptDir
$TsvPath         = Join-Path $ScriptDir 'traduzione_ita.tsv'
$VersionJsonPath = Join-Path $ScriptDir 'versione.json'
$ArtPath         = Join-Path $ScriptDir 'sfondo.jpg'
$ConfigPath      = Join-Path $env:APPDATA 'Aniimo_ITA_Installer\config.json'

# URL ufficiali per aggiornamento diretto da GitHub
$RemoteVersionUrl = "https://raw.githubusercontent.com/NobodySan97/Aniimo-ITA/main/dati/versione.json"
$RemoteTsvUrl     = "https://raw.githubusercontent.com/NobodySan97/Aniimo-ITA/main/dati/traduzione_ita.tsv"

function Format-NumberDot([string]$Value) {
    if (-not $Value) { return '0' }
    $digits = ($Value -replace '[^\d]', '')
    if (-not $digits) { return $Value }
    $n = 0L
    if ([long]::TryParse($digits, [ref]$n)) {
        return $n.ToString('#,0').Replace(',', '.')
    }
    return $Value
}

function Get-InstallerConfig {
    if (Test-Path -LiteralPath $ConfigPath) {
        try {
            return (Get-Content -LiteralPath $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json)
        } catch {}
    }
    return [pscustomobject]@{
        game_dir           = ""
        remote_tsv_url     = ""
        remote_version_url = ""
    }
}

function Save-InstallerConfig([string]$SavedGameDir) {
    try {
        $dir = Split-Path -Parent $ConfigPath
        if (-not (Test-Path -LiteralPath $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
        $cfg = Get-InstallerConfig
        $obj = [pscustomobject]@{
            game_dir           = $SavedGameDir
            remote_tsv_url     = if ($cfg.PSObject.Properties.Name -contains 'remote_tsv_url') { $cfg.remote_tsv_url } else { "" }
            remote_version_url = if ($cfg.PSObject.Properties.Name -contains 'remote_version_url') { $cfg.remote_version_url } else { "" }
        }
        $json = $obj | ConvertTo-Json -Depth 3
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($ConfigPath, $json, $utf8NoBom)
    } catch {}
}

function Get-TsvMetadata([string]$PathToTsv) {
    $meta = [pscustomobject]@{
        versione  = '1.1.4'
        build     = '3746914'
        data      = '2026-10-22'
        voci      = '112418'
        voci_fmt  = '112.418'
        tsv_md5   = '8471262cdad8739618ec9d96729bc33a'
        changelog = 'Controllo totale Steam: allineamento missioni secondarie, atti Dimora, Eolo, Spada del Coraggio e armonizzazione cluster.'
    }
    # Lettura ultra-rapida da versione.json se presente
    if (Test-Path -LiteralPath $VersionJsonPath) {
        try {
            $vj = Get-Content -LiteralPath $VersionJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($vj.versione_traduzione) { $meta.versione = [string]$vj.versione_traduzione }
            elseif ($vj.versione)        { $meta.versione = [string]$vj.versione }
            if ($vj.build_gioco)          { $meta.build    = [string]$vj.build_gioco }
            elseif ($vj.build)            { $meta.build    = [string]$vj.build }
            if ($vj.data_rilascio)        { $meta.data     = [string]$vj.data_rilascio }
            elseif ($vj.data)             { $meta.data     = [string]$vj.data }
            if ($vj.voci)                 { $meta.voci     = [string]$vj.voci }
            if ($vj.tsv_md5)              { $meta.tsv_md5  = [string]$vj.tsv_md5 }
            if ($vj.changelog_breve)      { $meta.changelog = [string]$vj.changelog_breve }
            elseif ($vj.changelog)        { $meta.changelog = [string]$vj.changelog }
            if ($vj.changelog_dettagliato) { $meta | Add-Member -MemberType NoteProperty -Name 'changelog_dettagliato' -Value $vj.changelog_dettagliato -Force }
        } catch {}
    }
    if (Test-Path -LiteralPath $PathToTsv) {
        try {
            $sr = New-Object System.IO.StreamReader($PathToTsv, [System.Text.Encoding]::UTF8)
            try {
                for ($i = 0; $i -lt 5; $i++) {
                    $line = $sr.ReadLine()
                    if ($null -eq $line) { break }
                    if ($line.StartsWith('#')) {
                        if ($line -match 'Versione:\s*([^|\s]+)') { $meta.versione = $Matches[1].Trim() }
                        if ($line -match 'Build:\s*([^|\s]+)')    { $meta.build    = $Matches[1].Trim() }
                        if ($line -match 'Data:\s*([^|\s]+)')     { $meta.data     = $Matches[1].Trim() }
                        if ($line -match 'Voci:\s*(\d+)')         { $meta.voci     = $Matches[1].Trim() }
                    }
                }
            } finally {
                $sr.Close()
            }
        } catch {}
    }
    $meta.voci_fmt = Format-NumberDot $meta.voci
    return $meta
}

function Get-RemoteRepoTsvUrl {
    if ($RemoteTsvUrl) { return $RemoteTsvUrl }
    $cfg = Get-InstallerConfig
    if ($cfg.PSObject.Properties.Name -contains 'remote_tsv_url' -and $cfg.remote_tsv_url) {
        return [string]$cfg.remote_tsv_url
    }
    $gitCfg = Join-Path $RootDir '.git\config'
    if (Test-Path -LiteralPath $gitCfg) {
        try {
            $txt = Get-Content -LiteralPath $gitCfg -Raw
            if ($txt -match 'github\.com[:/]([^/\s]+)/([^/\s\.]+)') {
                $owner = $Matches[1]
                $repo  = $Matches[2]
                return "https://raw.githubusercontent.com/$owner/$repo/main/dati/traduzione_ita.tsv"
            }
        } catch {}
    }
    return ""
}

function Get-RemoteRepoVersionUrl {
    if ($RemoteVersionUrl) { return $RemoteVersionUrl }
    $cfg = Get-InstallerConfig
    if ($cfg.PSObject.Properties.Name -contains 'remote_version_url' -and $cfg.remote_version_url) {
        return [string]$cfg.remote_version_url
    }
    $tsvUrl = Get-RemoteRepoTsvUrl
    if ($tsvUrl) {
        return ($tsvUrl -replace 'traduzione_ita\.tsv$', 'versione.json')
    }
    return ""
}

function Update-TranslationTsvFromGitHub([switch]$Silent) {
    $verUrl = Get-RemoteRepoVersionUrl
    $tsvUrl = Get-RemoteRepoTsvUrl
    if (-not $tsvUrl) {
        return [pscustomobject]@{ Success = $false; Status = 'NoUrl'; Message = 'URL repository remoto non configurato.' }
    }

    $wc = $null
    $tmpTsv = "$TsvPath.download"
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $wc = New-Object System.Net.WebClient
        $wc.Encoding = [System.Text.Encoding]::UTF8
        $wc.Headers.Add('User-Agent', 'Aniimo-ITA-Installer/1.0')

        # FASE 1: Controllo smart ultra-rapido (solo ~300 byte) tramite versione.json
        $remoteVerJson = $null
        $jsonText = $null
        if ($verUrl) {
            try {
                $jsonText = $wc.DownloadString($verUrl)
                if ($jsonText) {
                    $remoteVerJson = $jsonText | ConvertFrom-Json
                }
            } catch {}
        }

        # Se il manifest remoto ha lo stesso MD5 del file locale, non riscarichiamo 7.5 MB inutilmente
        if ($remoteVerJson -and (Test-Path -LiteralPath $TsvPath)) {
            $localMeta = Get-TsvMetadata $TsvPath
            if ($localMeta.tsv_md5 -and $remoteVerJson.tsv_md5 -and ($localMeta.tsv_md5 -ieq $remoteVerJson.tsv_md5)) {
                if ($jsonText) { try { [System.IO.File]::WriteAllText($VersionJsonPath, $jsonText, [System.Text.Encoding]::UTF8) } catch {} }
                return [pscustomobject]@{ Success = $false; Status = 'AlreadyUpToDate'; Message = 'La traduzione locale è già allineata.' }
            }
            $localFileMd5 = Get-Md5File $TsvPath
            if ($localFileMd5 -and $remoteVerJson.tsv_md5 -and ($localFileMd5 -ieq $remoteVerJson.tsv_md5)) {
                if ($jsonText) { try { [System.IO.File]::WriteAllText($VersionJsonPath, $jsonText, [System.Text.Encoding]::UTF8) } catch {} }
                return [pscustomobject]@{ Success = $false; Status = 'AlreadyUpToDate'; Message = 'La traduzione locale è già allineata.' }
            }
            # Se la versione locale è già uguale o più recente della remota, non sovrascrivere
            try {
                $remVerStr = if ($remoteVerJson.versione_traduzione) { $remoteVerJson.versione_traduzione } else { $remoteVerJson.versione }
                $remVer = [version]($remVerStr -replace '[^\d\.]', '')
                $locVer = [version]($localMeta.versione -replace '[^\d\.]', '')
                if ($locVer -ge $remVer) {
                    return [pscustomobject]@{ Success = $false; Status = 'AlreadyUpToDate'; Message = "La traduzione locale (v$($localMeta.versione)) è già aggiornata o più recente di quella remota (v$remVerStr)." }
                }
            } catch {}
        }

        # FASE 2: Scaricamento completo della nuova traduzione
        $wc.DownloadFile($tsvUrl, $tmpTsv)
        if (-not (Test-Path -LiteralPath $tmpTsv)) {
            return [pscustomobject]@{ Success = $false; Status = 'DownloadFailed'; Message = 'Download non completato.' }
        }
        $len = (Get-Item -LiteralPath $tmpTsv).Length
        if ($len -lt 1000000) {
            Remove-Item -LiteralPath $tmpTsv -Force -ErrorAction SilentlyContinue
            return [pscustomobject]@{ Success = $false; Status = 'InvalidData'; Message = 'File scaricato incompleto o non valido.' }
        }

        if (Test-Path -LiteralPath $TsvPath) {
            $localMd5 = Get-Md5File $TsvPath
            $remoteMd5 = Get-Md5File $tmpTsv
            if ($localMd5 -eq $remoteMd5) {
                Remove-Item -LiteralPath $tmpTsv -Force -ErrorAction SilentlyContinue
                if ($remoteVerJson -and $jsonText) {
                    try { [System.IO.File]::WriteAllText($VersionJsonPath, $jsonText, [System.Text.Encoding]::UTF8) } catch {}
                }
                return [pscustomobject]@{ Success = $false; Status = 'AlreadyUpToDate'; Message = 'La traduzione locale è già allineata.' }
            }
        }

        Move-Item -LiteralPath $tmpTsv -Destination $TsvPath -Force
        if ($remoteVerJson -and $jsonText) {
            try { [System.IO.File]::WriteAllText($VersionJsonPath, $jsonText, [System.Text.Encoding]::UTF8) } catch {}
        }
        return [pscustomobject]@{ Success = $true; Status = 'Updated'; Message = 'Nuova traduzione scaricata con successo.' }
    } catch {
        if (Test-Path -LiteralPath $tmpTsv) {
            Remove-Item -LiteralPath $tmpTsv -Force -ErrorAction SilentlyContinue
        }
        return [pscustomobject]@{ Success = $false; Status = 'NetworkError'; Message = $_.Exception.Message }
    } finally {
        if ($wc) { $wc.Dispose() }
    }
}

# ---------------------------------------------------------------------
#  Ricerca e Stato Cartella di Aniimo
# ---------------------------------------------------------------------
function Resolve-AniimoDir([string]$Candidate) {
    if (-not $Candidate) { return $null }
    $Candidate = $Candidate.Trim().Trim('"')
    if (-not (Test-Path -LiteralPath $Candidate)) { return $null }

    if ((Split-Path -Leaf $Candidate) -ieq 'Aniimo_Data') {
        $Candidate = Split-Path -Parent $Candidate
    }

    # Controllo rapido percorsi noti e combinazioni tipiche (Steam, PawPrint, Xbox, Standalone)
    foreach ($sub in @(
        '',
        'game',
        'Aniimo\game',
        'Aniimo',
        'PawPrint\Aniimo\game',
        'PawPrint\Aniimo',
        'PawPrint\game',
        'Content\game',
        'Content'
    )) {
        $testDir = if ($sub) { Join-Path $Candidate $sub } else { $Candidate }
        $xdf = Join-Path $testDir 'Aniimo_Data\StreamingAssets\cvs\res\lua\LuaScripts.xdf'
        if (Test-Path -LiteralPath $xdf) {
            return $testDir
        }
    }

    # Ricerca ricorsiva intelligente (fino a 4 livelli di profondità)
    try {
        $foundXdf = Get-ChildItem -LiteralPath $Candidate -Filter 'LuaScripts.xdf' -Recurse -Depth 4 -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($foundXdf) {
            $p = $foundXdf.FullName
            $idx = $p.IndexOf('\Aniimo_Data\', [System.StringComparison]::OrdinalIgnoreCase)
            if ($idx -gt 0) {
                $dir = $p.Substring(0, $idx)
                if (Test-Path -LiteralPath $dir) { return $dir }
            }
        }
    } catch {}

    return $null
}

function Find-AllAniimoInstallations {
    $results = @{}

    # 1. Ricerca librerie Steam (Registry e libraryfolders.vdf)
    $steamPaths = New-Object System.Collections.Generic.List[string]
    foreach ($regPath in @('HKCU:\Software\Valve\Steam', 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam')) {
        $regProps = Get-ItemProperty $regPath -ErrorAction SilentlyContinue
        if ($regProps) {
            foreach ($val in @($regProps.SteamPath, $regProps.InstallPath)) {
                if ($val -and -not $steamPaths.Contains($val)) { $steamPaths.Add($val) }
            }
        }
    }
    foreach ($basePath in @($steamPaths.ToArray())) {
        $vdfFile = Join-Path $basePath 'steamapps\libraryfolders.vdf'
        if (Test-Path -LiteralPath $vdfFile) {
            $rawVdf = Get-Content -LiteralPath $vdfFile -Raw -ErrorAction SilentlyContinue
            if ($rawVdf) {
                foreach ($match in [regex]::Matches($rawVdf, '"path"\s+"([^"]+)"')) {
                    $libDir = $match.Groups[1].Value.Replace('\\', '\')
                    if (-not $steamPaths.Contains($libDir)) { $steamPaths.Add($libDir) }
                }
            }
        }
    }
    foreach ($libRoot in $steamPaths) {
        $manifest = Join-Path $libRoot 'steamapps\appmanifest_4126040.acf'
        if (Test-Path -LiteralPath $manifest) {
            $acfContent = Get-Content -LiteralPath $manifest -Raw -ErrorAction SilentlyContinue
            $mDir = [regex]::Match([string]$acfContent, '"installdir"\s+"([^"]+)"')
            if ($mDir.Success) {
                $p = Resolve-AniimoDir (Join-Path $libRoot ('steamapps\common\' + $mDir.Groups[1].Value))
                if ($p -and -not $results.ContainsKey('Steam')) { $results['Steam'] = $p }
            }
        }
        $p = Resolve-AniimoDir (Join-Path $libRoot 'steamapps\common\Aniimo')
        if ($p -and -not $results.ContainsKey('Steam')) { $results['Steam'] = $p }
    }

    # 2. Ricerca tramite Registro di Windows (PawPrint Launcher, Standalone, ecc.)
    foreach ($regRoot in @(
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
    )) {
        if (Test-Path -LiteralPath $regRoot) {
            $subKeys = Get-ChildItem -LiteralPath $regRoot -ErrorAction SilentlyContinue
            if ($subKeys) {
                foreach ($sk in $subKeys) {
                    $dn = $sk.GetValue('DisplayName')
                    if ($dn -and ($dn -like '*Aniimo*' -or $dn -like '*PawPrint*')) {
                        $il = $sk.GetValue('InstallLocation')
                        if ($il) {
                            $p = Resolve-AniimoDir $il
                            if ($p) {
                                if ($il -like '*PawPrint*' -or $dn -like '*PawPrint*') {
                                    if (-not $results.ContainsKey('PawPrint')) { $results['PawPrint'] = $p }
                                } elseif ($p -notlike '*steamapps*') {
                                    if (-not $results.ContainsKey('PawPrint')) { $results['PawPrint'] = $p }
                                }
                            }
                        }
                        $us = $sk.GetValue('UninstallString')
                        if ($us) {
                            $usClean = ($us -replace '^"|"[^"]*$', '').Trim()
                            $parentDir = Split-Path -Parent $usClean
                            $p = Resolve-AniimoDir $parentDir
                            if ($p) {
                                if ($parentDir -like '*PawPrint*' -or $dn -like '*PawPrint*') {
                                    if (-not $results.ContainsKey('PawPrint')) { $results['PawPrint'] = $p }
                                } elseif ($p -notlike '*steamapps*') {
                                    if (-not $results.ContainsKey('PawPrint')) { $results['PawPrint'] = $p }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    # 3. Scansione dischi fissi (tutti i drive con cartelle tipiche PawPrint, Steam, Xbox e Standalone)
    foreach ($drv in [System.IO.DriveInfo]::GetDrives() | Where-Object { $_.IsReady -and $_.DriveType -eq 'Fixed' }) {
        $root = $drv.RootDirectory.FullName
        if (-not $results.ContainsKey('PawPrint')) {
            foreach ($sub in @(
                'PawPrint\Aniimo\game',
                'PawPrint\Aniimo',
                'PawPrint',
                'Program Files\PawPrint\Aniimo\game',
                'Program Files\PawPrint\Aniimo',
                'Program Files\PawPrint',
                'Program Files (x86)\PawPrint\Aniimo\game',
                'Program Files (x86)\PawPrint\Aniimo',
                'Program Files (x86)\PawPrint',
                'Games\PawPrint\Aniimo\game',
                'Games\PawPrint\Aniimo',
                'Games\PawPrint'
            )) {
                $cand = Join-Path $root $sub
                if (Test-Path -LiteralPath $cand) {
                    $p = Resolve-AniimoDir $cand
                    if ($p) {
                        $results['PawPrint'] = $p
                        break
                    }
                }
            }
        }
        if (-not $results.ContainsKey('Steam')) {
            foreach ($sub in @(
                'SteamLibrary\steamapps\common\Aniimo',
                'Program Files (x86)\Steam\steamapps\common\Aniimo',
                'Program Files\Steam\steamapps\common\Aniimo'
            )) {
                $cand = Join-Path $root $sub
                if (Test-Path -LiteralPath $cand) {
                    $p = Resolve-AniimoDir $cand
                    if ($p) {
                        $results['Steam'] = $p
                        break
                    }
                }
            }
        }
    }

    return $results
}

function Find-AniimoDir([string]$ExplicitDir) {
    $resolved = Resolve-AniimoDir $ExplicitDir
    if ($resolved) { return $resolved }

    $cfg = Get-InstallerConfig
    if ($cfg.PSObject.Properties.Name -contains 'game_dir' -and $cfg.game_dir) {
        $resolved = Resolve-AniimoDir ([string]$cfg.game_dir)
        if ($resolved) { return $resolved }
    }

    $all = Find-AllAniimoInstallations
    if ($all.ContainsKey('Steam')) { return $all['Steam'] }
    if ($all.ContainsKey('PawPrint')) { return $all['PawPrint'] }

    return $null
}

function Select-AniimoFolderDialog {
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = "Seleziona la cartella di installazione di Aniimo (es. ...\steamapps\common\Aniimo)"
    $dlg.ShowNewFolderButton = $false
    if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $res = Resolve-AniimoDir $dlg.SelectedPath
        if ($res) { return $res }
        return "" # Stringa vuota indica selezione non valida (mentre $null indica annullato)
    }
    return $null
}

function Test-AniimoRunning {
    return [bool](Get-Process -Name 'Aniimo' -ErrorAction SilentlyContinue)
}

function Test-GameDirWritable([string]$TargetDir) {
    if (-not $TargetDir) { return $false }
    $probeDir = Join-Path $TargetDir 'Aniimo_Data\cvs\res\lua'
    $probe    = Join-Path $probeDir "_write_test_$PID.tmp"
    try {
        if (-not (Test-Path -LiteralPath $probeDir)) {
            New-Item -ItemType Directory -Path $probeDir -Force -ErrorAction Stop | Out-Null
        }
        [System.IO.File]::WriteAllText($probe, 'ok')
        Remove-Item -LiteralPath $probe -Force -ErrorAction SilentlyContinue
        return $true
    } catch {
        return $false
    }
}

function Request-GuiElevation([string]$TargetDir, [string]$ActionSwitch) {
    try {
        $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $ActionSwitch -GameDir `"$TargetDir`""
        Start-Process -FilePath "powershell.exe" -ArgumentList $argList -Verb RunAs
        return $true
    } catch {
        return $false
    }
}

function Get-Md5File([string]$Path) {
    $md5 = [System.Security.Cryptography.MD5]::Create()
    $fs = [System.IO.File]::OpenRead($Path)
    try {
        return [BitConverter]::ToString($md5.ComputeHash($fs)).Replace('-', '').ToLower()
    } finally {
        $fs.Dispose()
        $md5.Dispose()
    }
}

function Get-Md5Bytes([byte[]]$Bytes) {
    $md5 = [System.Security.Cryptography.MD5]::Create()
    try {
        return [BitConverter]::ToString($md5.ComputeHash($Bytes)).Replace('-', '').ToLower()
    } finally {
        $md5.Dispose()
    }
}

function Get-GameBuild([string]$TargetDir) {
    if (-not $TargetDir) { return 'Sconosciuta' }

    # 1. Controlla manifest di patch online (aggiornamenti hotfix scaricati in cvs)
    $patchVer = Join-Path $TargetDir 'Aniimo_Data\cvs\res\uab\win\DefaultPackage\ManifestFiles\PackageManifest_DefaultPackage.version'
    if (Test-Path -LiteralPath $patchVer) {
        $v = (Get-Content -LiteralPath $patchVer -Raw -ErrorAction SilentlyContinue).Trim()
        if ($v) { return $v }
    }

    # 2. Controlla verlist.txt (nella cartella principale del gioco o in StreamingAssets)
    foreach ($vlRel in @('verlist.txt', 'Aniimo_Data\StreamingAssets\verlist.txt')) {
        $vl = Join-Path $TargetDir $vlRel
        if (Test-Path -LiteralPath $vl) {
            $txt = (Get-Content -LiteralPath $vl -Raw -ErrorAction SilentlyContinue).Trim()
            if ($txt) { return ($txt.Split(',')[0]).Trim() }
        }
    }

    # 3. Controlla salvataggio patch launcher (res_save.json di PawPrint)
    $resSave = Join-Path $TargetDir 'Aniimo_Data\cvs\res\patchv2\res\res_save.json'
    if (Test-Path -LiteralPath $resSave) {
        try {
            $json = Get-Content -LiteralPath $resSave -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json
            if ($json -and $json.ThisVer) { return [string]$json.ThisVer }
        } catch {}
    }

    # 4. Controlla manifest base StreamingAssets
    $saVer = Join-Path $TargetDir 'Aniimo_Data\StreamingAssets\cvs\res\uab\win\DefaultPackage\PackageManifest_DefaultPackage.version'
    if (Test-Path -LiteralPath $saVer) {
        $v = (Get-Content -LiteralPath $saVer -Raw -ErrorAction SilentlyContinue).Trim()
        if ($v) { return $v }
    }

    # 5. Controlla indice cache Lua (1.0.<build>)
    $lcv = Join-Path $TargetDir 'Aniimo_Data\cvs\res\lua\LuaCacheVer.txt'
    if (Test-Path -LiteralPath $lcv) {
        $txt = (Get-Content -LiteralPath $lcv -Raw -ErrorAction SilentlyContinue).Trim()
        $m = [regex]::Match($txt, '1\.0\.(\d+)')
        if ($m.Success) { return $m.Groups[1].Value }
    }

    return 'Sconosciuta'
}

function Get-ZipEntryMd5([string]$ZipPath, [string]$EntryName) {
    if (-not (Test-Path -LiteralPath $ZipPath)) { return $null }
    try {
        $z = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
        try {
            $e = $z.GetEntry($EntryName)
            if (-not $e) {
                $e = $z.Entries | Where-Object { $_.FullName -ieq $EntryName } | Select-Object -First 1
            }
            if (-not $e) { return $null }
            $s = $e.Open()
            $md5 = [System.Security.Cryptography.MD5]::Create()
            try {
                return [BitConverter]::ToString($md5.ComputeHash($s)).Replace('-', '').ToLower()
            } finally {
                $s.Dispose()
                $md5.Dispose()
            }
        } finally {
            $z.Dispose()
        }
    } catch {
        return $null
    }
}

function Get-TranslationStatus([string]$TargetDir, $CurrentTsvMeta) {
    if (-not $TargetDir) {
        return [pscustomobject]@{
            Code      = 'NO_GAME'
            Title     = 'Cartella non trovata'
            Sub       = 'Seleziona manualmente il percorso di installazione di Aniimo'
            DotColor  = '#F43F5E'
            BtnText   = 'SELEZIONA CARTELLA E INSTALLA'
            CanRemove = $false
        }
    }

    $saLuaDir  = Join-Path $TargetDir 'Aniimo_Data\StreamingAssets\cvs\res\lua'
    $saXdf     = Join-Path $saLuaDir 'LuaScripts.xdf'
    $saXdt     = Join-Path $saLuaDir 'LuaScripts.xdt'
    $cvsLuaDir = Join-Path $TargetDir 'Aniimo_Data\cvs\res\lua'
    $cvsXdf    = Join-Path $cvsLuaDir 'LuaScripts.xdf'
    $cvsBin    = Join-Path $cvsLuaDir 'LuaScripts\Data\I18N\Compress_en.bin'
    $cacheFile = Join-Path $cvsLuaDir 'LuaCacheVer.txt'
    $metaFile  = Join-Path $cvsLuaDir 'aniimo_ita_meta.json'

    $buildNum  = Get-GameBuild $TargetDir
    $saXdtLen  = (Get-Item -LiteralPath $saXdt).Length
    $saXdtMd5  = Get-Md5File $saXdt
    $expectedCacheVer = "1.0.$buildNum,$saXdtLen,$saXdtMd5"

    $actualCacheVer = if (Test-Path -LiteralPath $cacheFile) {
        (Get-Content -LiteralPath $cacheFile -Raw -ErrorAction SilentlyContinue).Trim()
    } else { '' }

    $marker = $null
    if (Test-Path -LiteralPath $metaFile) {
        try { $marker = Get-Content -LiteralPath $metaFile -Raw -Encoding UTF8 | ConvertFrom-Json } catch {}
    }

    $entryRel = 'xfs/luascripts/Data/I18N/Compress_en.bin'
    $saEntryMd5  = Get-ZipEntryMd5 $saXdf $entryRel
    $cvsEntryMd5 = Get-ZipEntryMd5 $cvsXdf $entryRel

    if (-not $cvsEntryMd5 -or ($cvsEntryMd5 -eq $saEntryMd5)) {
        return [pscustomobject]@{
            Code      = 'NOT_INSTALLED'
            Title     = 'Non installata'
            Sub       = 'Il gioco utilizza attualmente i file originali in Inglese'
            DotColor  = '#F43F5E'
            BtnText   = 'INSTALLA TRADUZIONE ITALIANA'
            CanRemove = $false
        }
    }

    if ($actualCacheVer -ne $expectedCacheVer) {
        return [pscustomobject]@{
            Code      = 'OUTDATED_GAME_UPDATE'
            Title     = 'Nuova patch rilevata'
            Sub       = "Gioco aggiornato da Steam (Build $buildNum): premi Aggiorna!"
            DotColor  = '#F59E0B'
            BtnText   = 'AGGIORNA ALLA NUOVA BUILD DEL GIOCO'
            CanRemove = $true
        }
    }

    if (-not (Test-Path -LiteralPath $cvsBin) -or ((Get-Md5File $cvsBin) -ne $cvsEntryMd5)) {
        return [pscustomobject]@{
            Code      = 'PARTIAL'
            Title     = 'Da riallineare'
            Sub       = 'Alcuni file della cache necessitano di riallineamento'
            DotColor  = '#F59E0B'
            BtnText   = 'RIPARA TRADUZIONE ITALIANA'
            CanRemove = $true
        }
    }

    if ($marker -and $marker.tsv_version -and ($marker.tsv_version -ne $CurrentTsvMeta.versione)) {
        return [pscustomobject]@{
            Code      = 'UPDATE_AVAILABLE'
            Title     = "Aggiornabile a v$($CurrentTsvMeta.versione)"
            Sub       = "Versione installata: v$($marker.tsv_version)"
            DotColor  = '#F59E0B'
            BtnText   = "AGGIORNA A VERSIONE $($CurrentTsvMeta.versione)"
            CanRemove = $true
        }
    }

    $verStr = if ($marker -and $marker.tsv_version) { "v$($marker.tsv_version)" } else { "v$($CurrentTsvMeta.versione)" }
    return [pscustomobject]@{
        Code      = 'ACTIVE'
        Title     = "Attiva ($verStr)"
        Sub       = "Allineata alla Build $buildNum · Pronta per giocare"
        DotColor  = '#10B981'
        BtnText   = 'REINSTALLA / AGGIORNA TRADUZIONE'
        CanRemove = $true
    }
}

# ---------------------------------------------------------------------
#  Operazioni Core: Installazione e Ripristino
# ---------------------------------------------------------------------
function Get-ZipEntrySafe($Zip, [string]$EntryName) {
    $e = $Zip.GetEntry($EntryName)
    if ($e) { return $e }
    return ($Zip.Entries | Where-Object { $_.FullName -ieq $EntryName } | Select-Object -First 1)
}

function Read-ZipEntryBytes($Zip, [string]$EntryName) {
    $e = Get-ZipEntrySafe $Zip $EntryName
    if (-not $e) { throw "Voce mancante nell'archivio del gioco: $EntryName" }
    $s = $e.Open()
    $ms = New-Object System.IO.MemoryStream
    try { $s.CopyTo($ms) } finally { $s.Dispose() }
    return ,$ms.ToArray()
}

function Update-XdtIndex([string]$OrigXdtPath, [string]$NewXdfPath, [string]$OutXdtPath, [hashtable]$ModifiedEntries) {
    $xdtTxt = [System.IO.File]::ReadAllText($OrigXdtPath, [System.Text.Encoding]::UTF8)
    $cmPos  = $xdtTxt.IndexOf('"CMList"')
    if ($cmPos -lt 0) {
        throw "Formato file indice LuaScripts.xdt non riconosciuto: $OrigXdtPath"
    }

    $container = @{}
    $known     = @{}
    foreach ($m in [regex]::Matches($xdtTxt, '"CEName"\s*:\s*"([^"]+)"\s*,\s*"CEMD5"\s*:\s*"([0-9a-fA-F]{32})"\s*,\s*"CESize"\s*:\s*(\d+)[^}]*?"CEContainer"\s*:\s*(\d+)')) {
        $container[$m.Groups[1].Value] = $m.Groups[4].Value
        $known[$m.Groups[1].Value]     = @($m.Groups[2].Value.ToLower(), $m.Groups[3].Value)
    }

    $fs = [System.IO.File]::OpenRead($NewXdfPath)
    try {
        $br = New-Object System.IO.BinaryReader($fs)
        $searchLen = [int][Math]::Min(66000L, $fs.Length)
        $fs.Position = $fs.Length - $searchLen
        $tail = $br.ReadBytes($searchLen)
        $eocd = -1
        for ($i = $tail.Length - 22; $i -ge 0; $i--) {
            if ($tail[$i] -eq 0x50 -and $tail[$i+1] -eq 0x4B -and $tail[$i+2] -eq 5 -and $tail[$i+3] -eq 6) {
                $eocd = $i
                break
            }
        }
        if ($eocd -lt 0) { throw "Archivio ZIP/XDF non valido: $NewXdfPath" }
        $cdSize = [long][BitConverter]::ToUInt32($tail, $eocd + 12)
        $cdOff  = [long][BitConverter]::ToUInt32($tail, $eocd + 16)
        $fs.Position = $cdOff
        $cd = $br.ReadBytes([int]$cdSize)

        $sb  = New-Object System.Text.StringBuilder(1024 * 1024)
        $p   = 0
        $idx = 0
        $h4  = New-Object byte[] 4
        while (($p + 46) -le $cd.Length -and [BitConverter]::ToUInt32($cd, $p) -eq 0x02014B50) {
            $csize = [BitConverter]::ToUInt32($cd, $p + 20)
            $nl    = [BitConverter]::ToUInt16($cd, $p + 28)
            $xl    = [BitConverter]::ToUInt16($cd, $p + 30)
            $cl    = [BitConverter]::ToUInt16($cd, $p + 32)
            $hdr   = [long][BitConverter]::ToUInt32($cd, $p + 42)
            $name  = [System.Text.Encoding]::UTF8.GetString($cd, $p + 46, $nl)

            $fs.Position = $hdr + 26
            $readBytes = $fs.Read($h4, 0, 4)
            if ($readBytes -lt 4) { throw "Header locale troncato nell'archivio: $name" }
            $dataOff = $hdr + 30 + [BitConverter]::ToUInt16($h4, 0) + [BitConverter]::ToUInt16($h4, 2)

            if ($ModifiedEntries.ContainsKey($name)) {
                $raw   = $ModifiedEntries[$name]
                $md5   = Get-Md5Bytes $raw
                $usize = $raw.Length
            } elseif ($known.ContainsKey($name)) {
                $md5   = $known[$name][0]
                $usize = $known[$name][1]
            } else {
                $md5   = '00000000000000000000000000000000'
                $usize = $csize
            }
            $cont = if ($container.ContainsKey($name)) { $container[$name] } else { '0' }
            if ($idx -gt 0) { [void]$sb.Append(",`n") }
            [void]$sb.Append("        {`n            `"CEName`": `"$name`",`n            `"CEMD5`": `"$md5`",`n            `"CESize`": $usize,`n            `"CEIndex`": $idx,`n            `"CEOffset`": $dataOff,`n            `"CECSize`": $csize,`n            `"CEContainer`": $cont`n        }")
            $idx++
            $p += 46 + $nl + $xl + $cl
        }
    } finally {
        $fs.Dispose()
    }

    $len  = (Get-Item -LiteralPath $NewXdfPath).Length
    $md5x = Get-Md5File $NewXdfPath
    $head = $xdtTxt.Substring(0, $cmPos)
    $head = [regex]::Replace($head, '"CMDataLen"\s*:\s*\d+', "`"CMDataLen`": $len")
    $head = [regex]::Replace($head, '"CMDataMD5"\s*:\s*"[0-9a-fA-F]*"', "`"CMDataMD5`": `"$md5x`"")
    $head = [regex]::Replace($head, '"CMEntryNum"\s*:\s*\d+', "`"CMEntryNum`": $idx")

    $tmpXdt    = "$OutXdtPath.tmp"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($tmpXdt, $head + "`"CMList`": [`n" + $sb.ToString() + "`n    ]`n}`n", $utf8NoBom)
    if (Test-Path -LiteralPath $OutXdtPath) { Remove-Item -LiteralPath $OutXdtPath -Force }
    Move-Item -LiteralPath $tmpXdt -Destination $OutXdtPath -Force
}

function Invoke-TranslationInstall([string]$TargetDir, $Meta, [scriptblock]$OnProgress) {
    if (-not (Test-Path -LiteralPath $TsvPath)) {
        throw "File dizionario mancante: $TsvPath"
    }

    $saLuaDir  = Join-Path $TargetDir 'Aniimo_Data\StreamingAssets\cvs\res\lua'
    $saXdf     = Join-Path $saLuaDir 'LuaScripts.xdf'
    $saXdt     = Join-Path $saLuaDir 'LuaScripts.xdt'
    $cvsLuaDir = Join-Path $TargetDir 'Aniimo_Data\cvs\res\lua'
    $cvsI18n   = Join-Path $cvsLuaDir 'LuaScripts\Data\I18N'
    $cvsData   = Join-Path $cvsLuaDir 'LuaScripts\Common\Data'

    New-Item -ItemType Directory -Path $cvsI18n -Force | Out-Null
    New-Item -ItemType Directory -Path $cvsData -Force | Out-Null

    if ($OnProgress) { & $OnProgress 15 "Caricamento dizionario italiano v$($Meta.versione)..." }
    $trad = [AniimoFastPacker]::LoadTsv($TsvPath)

    if ($OnProgress) { & $OnProgress 35 "Lettura archivio del gioco (StreamingAssets)..." }
    $zip = [System.IO.Compression.ZipFile]::OpenRead($saXdf)
    try {
        $enMapTxt = [System.Text.Encoding]::UTF8.GetString((Read-ZipEntryBytes $zip 'xfs/luascripts/Data/I18N/NewTextMap_en.json'))
        $enBlob   = Read-ZipEntryBytes $zip 'xfs/luascripts/Data/I18N/Compress_en.bin'
        $pmData   = Read-ZipEntryBytes $zip 'xfs/luascripts/Common/Data/pmdata.bin'

        foreach ($entry in $zip.Entries) {
            if ($entry.FullName.StartsWith('xfs/luascripts/Data/I18N/Compress_') -and $entry.FullName.EndsWith('.bin') -and $entry.Name -ne 'Compress_en.bin') {
                $targetBin = Join-Path $cvsI18n $entry.Name
                if (Test-Path -LiteralPath $targetBin) {
                    [System.IO.File]::WriteAllBytes($targetBin, (Read-ZipEntryBytes $zip $entry.FullName))
                }
            }
        }
    } finally {
        $zip.Dispose()
    }

    if ($OnProgress) { & $OnProgress 60 "Compilazione binaria testi italiani (AniimoFastPacker)..." }
    $res = [AniimoFastPacker]::BuildI18nPair($enMapTxt, $enBlob, $trad)
    [byte[]]$newMapBytes = $res[0]
    [byte[]]$newBinBytes = $res[1]
    $translatedCount     = $res[2]
    $fallbackCount       = $res[3]

    if ($OnProgress) { & $OnProgress 80 "Aggiornamento LuaScripts.xdf e pmdata.bin..." }
    $outXdf = Join-Path $cvsLuaDir 'LuaScripts.xdf'
    $tmpXdf = Join-Path $cvsLuaDir 'LuaScripts.xdf.tmp'
    if (Test-Path -LiteralPath $tmpXdf) { Remove-Item -LiteralPath $tmpXdf -Force -ErrorAction SilentlyContinue }
    [System.IO.File]::Copy($saXdf, $tmpXdf, $true)

    try {
        $fsU = [System.IO.File]::Open($tmpXdf, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite)
        $zu  = New-Object System.IO.Compression.ZipArchive($fsU, [System.IO.Compression.ZipArchiveMode]::Update)
        try {
            $eMap = Get-ZipEntrySafe $zu 'xfs/luascripts/Data/I18N/NewTextMap_en.json'
            $sMap = $eMap.Open()
            try { $sMap.SetLength(0); $sMap.Write($newMapBytes, 0, $newMapBytes.Length) } finally { $sMap.Dispose() }

            $eBin = Get-ZipEntrySafe $zu 'xfs/luascripts/Data/I18N/Compress_en.bin'
            $sBin = $eBin.Open()
            try { $sBin.SetLength(0); $sBin.Write($newBinBytes, 0, $newBinBytes.Length) } finally { $sBin.Dispose() }
        } finally {
            $zu.Dispose()
            $fsU.Dispose()
        }

        if (Test-Path -LiteralPath $outXdf) { Remove-Item -LiteralPath $outXdf -Force }
        Move-Item -LiteralPath $tmpXdf -Destination $outXdf -Force
    } finally {
        if (Test-Path -LiteralPath $tmpXdf) { Remove-Item -LiteralPath $tmpXdf -Force -ErrorAction SilentlyContinue }
    }

    [System.IO.File]::WriteAllBytes((Join-Path $cvsI18n 'Compress_en.bin'), $newBinBytes)
    [System.IO.File]::WriteAllBytes((Join-Path $cvsI18n 'NewTextMap_en.json'), $newMapBytes)
    [System.IO.File]::WriteAllBytes((Join-Path $cvsData 'pmdata.bin'), $pmData)

    if ($OnProgress) { & $OnProgress 95 "Allineamento indice LuaScripts.xdt e LuaCacheVer.txt..." }
    $outXdt = Join-Path $cvsLuaDir 'LuaScripts.xdt'
    Update-XdtIndex $saXdt $outXdf $outXdt @{
        'xfs/luascripts/Data/I18N/NewTextMap_en.json' = $newMapBytes
        'xfs/luascripts/Data/I18N/Compress_en.bin'    = $newBinBytes
    }

    $buildNum  = Get-GameBuild $TargetDir
    $saXdtLen  = (Get-Item -LiteralPath $saXdt).Length
    $saXdtMd5  = Get-Md5File $saXdt
    $cacheVer  = "1.0.$buildNum,$saXdtLen,$saXdtMd5"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText((Join-Path $cvsLuaDir 'LuaCacheVer.txt'), $cacheVer, $utf8NoBom)

    $installMeta = [pscustomobject]@{
        installed       = $true
        tsv_version     = $Meta.versione
        tsv_build       = $Meta.build
        tsv_date        = $Meta.data
        game_build      = $buildNum
        sa_xdt_md5      = $saXdtMd5
        installed_at    = (Get-Date).ToString('s')
    } | ConvertTo-Json -Depth 3
    [System.IO.File]::WriteAllText((Join-Path $cvsLuaDir 'aniimo_ita_meta.json'), $installMeta, $utf8NoBom)

    $fmtCount = Format-NumberDot ([string]$translatedCount)
    if ($OnProgress) { & $OnProgress 100 "Installazione completata ($fmtCount stringhe attive)." }
    return [pscustomobject]@{
        BuildNum   = $buildNum
        Translated = $translatedCount
        Fallback   = $fallbackCount
    }
}

function Invoke-TranslationRestore([string]$TargetDir, [scriptblock]$OnProgress) {
    $saLuaDir  = Join-Path $TargetDir 'Aniimo_Data\StreamingAssets\cvs\res\lua'
    $saXdf     = Join-Path $saLuaDir 'LuaScripts.xdf'
    $saXdt     = Join-Path $saLuaDir 'LuaScripts.xdt'
    $cvsLuaDir = Join-Path $TargetDir 'Aniimo_Data\cvs\res\lua'
    $cvsI18n   = Join-Path $cvsLuaDir 'LuaScripts\Data\I18N'
    $cvsData   = Join-Path $cvsLuaDir 'LuaScripts\Common\Data'
    $metaFile  = Join-Path $cvsLuaDir 'aniimo_ita_meta.json'

    if ($OnProgress) { & $OnProgress 30 "Ripristino archivi originali da StreamingAssets..." }
    New-Item -ItemType Directory -Path $cvsI18n -Force | Out-Null
    New-Item -ItemType Directory -Path $cvsData -Force | Out-Null

    Copy-Item -LiteralPath $saXdf -Destination (Join-Path $cvsLuaDir 'LuaScripts.xdf') -Force
    Copy-Item -LiteralPath $saXdt -Destination (Join-Path $cvsLuaDir 'LuaScripts.xdt') -Force

    if ($OnProgress) { & $OnProgress 70 "Estrazione file lingua originale inglese..." }
    $zip = [System.IO.Compression.ZipFile]::OpenRead($saXdf)
    try {
        [System.IO.File]::WriteAllBytes((Join-Path $cvsI18n 'Compress_en.bin'), (Read-ZipEntryBytes $zip 'xfs/luascripts/Data/I18N/Compress_en.bin'))
        [System.IO.File]::WriteAllBytes((Join-Path $cvsI18n 'NewTextMap_en.json'), (Read-ZipEntryBytes $zip 'xfs/luascripts/Data/I18N/NewTextMap_en.json'))
        [System.IO.File]::WriteAllBytes((Join-Path $cvsData 'pmdata.bin'), (Read-ZipEntryBytes $zip 'xfs/luascripts/Common/Data/pmdata.bin'))
    } finally {
        $zip.Dispose()
    }

    $buildNum  = Get-GameBuild $TargetDir
    $saXdtLen  = (Get-Item -LiteralPath $saXdt).Length
    $saXdtMd5  = Get-Md5File $saXdt
    $cacheVer  = "1.0.$buildNum,$saXdtLen,$saXdtMd5"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText((Join-Path $cvsLuaDir 'LuaCacheVer.txt'), $cacheVer, $utf8NoBom)

    if (Test-Path -LiteralPath $metaFile) {
        Remove-Item -LiteralPath $metaFile -Force -ErrorAction SilentlyContinue
    }
    if ($OnProgress) { & $OnProgress 100 "Lingua originale inglese ripristinata." }
}

# ---------------------------------------------------------------------
#  Modalita' Riga di Comando (-Install / -Uninstall / -UpdateTsv)
# ---------------------------------------------------------------------
$TsvMeta = Get-TsvMetadata $TsvPath
$ResolvedGameDir = Find-AniimoDir $GameDir
if ($ResolvedGameDir) { Save-InstallerConfig $ResolvedGameDir }

if ($UpdateTsv) {
    [void](Update-TranslationTsvFromGitHub)
    exit 0
}
if ($Install) {
    if (-not $ResolvedGameDir) { throw "Cartella di Aniimo non trovata." }
    [void](Invoke-TranslationInstall $ResolvedGameDir $TsvMeta $null)
    exit 0
}
if ($Uninstall) {
    if (-not $ResolvedGameDir) { throw "Cartella di Aniimo non trovata." }
    [void](Invoke-TranslationRestore $ResolvedGameDir $null)
    exit 0
}

# ---------------------------------------------------------------------
#  Finestra Modale Polaris Starlight (Show-PolarisDialog)
# ---------------------------------------------------------------------
function Show-PolarisDialog {
    param(
        [string[]]$Messages,
        [string]$Title = '',
        [string]$Badge = '',
        [string]$Buttons = 'OK',
        [string]$Severity = 'Information'
    )

    $accentColor = switch ($Severity) {
        'Success'  { '#10B981' }
        'Error'    { '#F43F5E' }
        'Warning'  { '#F59E0B' }
        'Question' { '#38BDF8' }
        default    { '#38BDF8' }
    }
    $glyphChar = switch ($Severity) {
        'Success'  { [string][char]0x2713 }
        'Error'    { [string][char]0x2715 }
        'Warning'  { '!' }
        'Question' { '?' }
        default    { 'i' }
    }
    if (-not $Badge) {
        $Badge = switch ($Severity) {
            'Success'  { 'COMPLETATO' }
            'Error'    { 'ERRORE' }
            'Warning'  { 'AVVISO' }
            'Question' { 'CONFERMA' }
            default    { 'INFO SISTEMA' }
        }
    }
    $softAccent = '#26' + $accentColor.Substring(1)

    [xml]$dlgXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Aniimo Patcher ITA" SizeToContent="Height" Width="560" MaxHeight="680"
        WindowStartupLocation="CenterOwner" ResizeMode="NoResize" WindowStyle="None"
        AllowsTransparency="True" Background="Transparent" FontFamily="Segoe UI">
  <Window.Resources>
    <Style x:Key="ModalPrimaryBtn" TargetType="Button">
      <Setter Property="Foreground" Value="#FFFFFF"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" CornerRadius="10" Background="$accentColor">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bd" Property="Opacity" Value="0.88"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style x:Key="ModalSecondaryBtn" TargetType="Button">
      <Setter Property="Foreground" Value="#CBD5E1"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" CornerRadius="10" Background="#1E293B" BorderBrush="#334155" BorderThickness="1">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#334155"/>
                <Setter Property="Foreground" Value="#FFFFFF"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
  </Window.Resources>
  <Grid Margin="26">
    <Border CornerRadius="16" Background="#0F172A" BorderBrush="$accentColor" BorderThickness="1.5">
      <Border.Effect>
        <DropShadowEffect Color="$accentColor" BlurRadius="26" ShadowDepth="0" Opacity="0.28"/>
      </Border.Effect>
    </Border>
    <Border CornerRadius="16" BorderThickness="1.5" BorderBrush="Transparent">
      <Grid>
        <Canvas x:Name="StarlightCanvas" IsHitTestVisible="False" ClipToBounds="True"/>
        <Grid Margin="26,22,26,22">
          <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
          </Grid.RowDefinitions>
          <Grid Grid.Row="0">
            <Grid.ColumnDefinitions>
              <ColumnDefinition Width="Auto"/>
              <ColumnDefinition Width="*"/>
              <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <Border Grid.Column="0" Width="40" Height="40" CornerRadius="12" Background="$softAccent" BorderBrush="$accentColor" BorderThickness="1" VerticalAlignment="Center" Margin="0,0,14,0">
              <TextBlock x:Name="DlgIcon" FontFamily="Segoe UI Symbol" FontSize="20" FontWeight="Bold" Foreground="$accentColor" HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <TextBlock x:Name="DlgTitle" Grid.Column="1" FontSize="19" FontWeight="Bold" Foreground="#F8FAFC" TextWrapping="Wrap" VerticalAlignment="Center" Margin="0,0,14,0"/>
            <Border Grid.Column="2" CornerRadius="6" Background="$softAccent" BorderBrush="$accentColor" BorderThickness="1" Padding="10,4" VerticalAlignment="Center">
              <TextBlock x:Name="DlgBadge" FontSize="10" FontWeight="Bold" Foreground="$accentColor"/>
            </Border>
          </Grid>
          <Border Grid.Row="1" Height="1" Background="#1E293B" VerticalAlignment="Top" Margin="0,16,0,0"/>
          <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto" Margin="0,26,0,0" Padding="0,0,6,0">
            <StackPanel x:Name="DlgContentStack"/>
          </ScrollViewer>
          <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,22,0,0">
            <Button x:Name="BtnCancel" Style="{StaticResource ModalSecondaryBtn}" Content="ANNULLA" Width="125" Height="38" FontSize="12" FontWeight="SemiBold" Margin="0,0,10,0" Visibility="Collapsed"/>
            <Button x:Name="BtnConfirm" Style="{StaticResource ModalPrimaryBtn}" Content="OK" Width="135" Height="38" FontSize="12" FontWeight="Bold"/>
          </StackPanel>
        </Grid>
      </Grid>
    </Border>
  </Grid>
</Window>
"@
    $reader = New-Object System.Xml.XmlNodeReader $dlgXaml
    $dlg = [Windows.Markup.XamlReader]::Load($reader)
    if ($win -and $win.IsVisible) { $dlg.Owner = $win }

    $dlg.FindName('DlgTitle').Text = if ($Title) { $Title } else { $Badge }
    $dlg.FindName('DlgBadge').Text = $Badge
    $dlg.FindName('DlgIcon').Text  = $glyphChar

    $stack = $dlg.FindName('DlgContentStack')
    $first = $true
    foreach ($msg in $Messages) {
        if ($null -eq $msg) { continue }
        $tb = New-Object Windows.Controls.TextBlock
        $tb.TextWrapping = 'Wrap'
        $tb.Foreground   = '#CBD5E1'
        $tb.FontSize     = 13
        $tb.LineHeight   = 20
        if (-not $first) { $tb.Margin = New-Object Windows.Thickness 0, 10, 0, 0 }
        $first = $false
        $tb.Text = [string]$msg
        $stack.Children.Add($tb) | Out-Null
    }

    $state = @{ choice = 'OK' }
    $btnOk = $dlg.FindName('BtnConfirm')
    $btnNo = $dlg.FindName('BtnCancel')
    if ($Buttons -eq 'YesNo') {
        $btnOk.Content = 'CONFERMA'
        $btnNo.Content = 'ANNULLA'
        $btnNo.Visibility = 'Visible'
        $state.choice = 'No'
        $btnOk.Add_Click({ $state.choice = 'Yes'; $dlg.Close() }.GetNewClosure())
        $btnNo.Add_Click({ $state.choice = 'No';  $dlg.Close() }.GetNewClosure())
    } else {
        $btnOk.Add_Click({ $state.choice = 'OK'; $dlg.Close() }.GetNewClosure())
    }
    $dlg.Add_KeyDown({ if ($_.Key -eq 'Escape' -or $_.Key -eq 'Return') { $dlg.Close() } }.GetNewClosure())
    $dlg.Add_MouseLeftButtonDown({ $dlg.DragMove() })

    $ownerWin = if ($dlg.Owner) { $dlg.Owner } else { $null }
    $prevEffect = $null
    if ($ownerWin) {
        $prevEffect = $ownerWin.Effect
        $blur = New-Object Windows.Media.Effects.BlurEffect
        $blur.Radius = 6
        $ownerWin.Effect = $blur
    }
    try { $dlg.ShowDialog() | Out-Null }
    finally {
        if ($ownerWin) { $ownerWin.Effect = $prevEffect }
    }
    return $state.choice
}

# ---------------------------------------------------------------------
#  Interfaccia Grafica WPF "Aniimo Polaris / Prismana UI" (100% Originale)
# ---------------------------------------------------------------------
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Aniimo — Localizzazione Italiana (Launcher v1.0)" Height="800" Width="1250"
        WindowStartupLocation="CenterScreen" ResizeMode="NoResize"
        WindowStyle="None" AllowsTransparency="True" Background="Transparent" FontFamily="Segoe UI">
  <Window.Resources>

    <!-- ScrollBar Moderna Sottile Prismana -->
    <Style TargetType="Thumb" x:Key="PolarisScrollThumb">
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Thumb">
            <Border x:Name="tr" CornerRadius="3" Background="#334155" Margin="2,0"/>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="tr" Property="Background" Value="#38BDF8"/></Trigger>
              <Trigger Property="IsDragging" Value="True"><Setter TargetName="tr" Property="Background" Value="#06B6D4"/></Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style TargetType="ScrollBar">
      <Setter Property="Width" Value="8"/>
      <Setter Property="Background" Value="Transparent"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="ScrollBar">
            <Grid Background="Transparent">
              <Border CornerRadius="3" Background="#0B101B" Margin="2,0"/>
              <Track x:Name="PART_Track" IsDirectionReversed="True">
                <Track.Thumb><Thumb Style="{StaticResource PolarisScrollThumb}"/></Track.Thumb>
                <Track.DecreaseRepeatButton><RepeatButton Command="ScrollBar.PageUpCommand" Opacity="0" Focusable="False"/></Track.DecreaseRepeatButton>
                <Track.IncreaseRepeatButton><RepeatButton Command="ScrollBar.PageDownCommand" Opacity="0" Focusable="False"/></Track.IncreaseRepeatButton>
              </Track>
            </Grid>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <!-- Navigazione Top Bar a Pillola (PolarisNavTab) -->
    <Style x:Key="PolarisNavTab" TargetType="RadioButton">
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Foreground" Value="#94A3B8"/>
      <Setter Property="FontSize" Value="12"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Margin" Value="1.5,0"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="RadioButton">
            <Border x:Name="pill" CornerRadius="9" Background="Transparent" BorderBrush="Transparent" BorderThickness="1" Padding="10,6">
              <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                <TextBlock x:Name="ico" Text="{TemplateBinding Tag}" FontFamily="Segoe MDL2 Assets" FontSize="13"
                           Foreground="#64748B" VerticalAlignment="Center" Margin="0,0,8,0"/>
                <TextBlock x:Name="txt" Text="{TemplateBinding Content}" VerticalAlignment="Center"/>
              </StackPanel>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="pill" Property="Background" Value="#162032"/>
                <Setter Property="Foreground" Value="#E2E8F0"/>
                <Setter TargetName="ico" Property="Foreground" Value="#38BDF8"/>
              </Trigger>
              <Trigger Property="IsChecked" Value="True">
                <Setter TargetName="pill" Property="Background">
                  <Setter.Value>
                    <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                      <GradientStop Color="#2638BDF8" Offset="0"/>
                      <GradientStop Color="#266366F1" Offset="1"/>
                    </LinearGradientBrush>
                  </Setter.Value>
                </Setter>
                <Setter TargetName="pill" Property="BorderBrush" Value="#6638BDF8"/>
                <Setter Property="Foreground" Value="#F8FAFC"/>
                <Setter TargetName="ico" Property="Foreground" Value="#38BDF8"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <!-- Pulsante Primario Prismana Cyan-Indigo (PolarisPrimaryButton) -->
    <Style x:Key="PolarisPrimaryButton" TargetType="Button">
      <Setter Property="Foreground" Value="#FFFFFF"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Grid>
              <Border x:Name="glow" CornerRadius="11" Background="#0EA5E9" Opacity="0.25">
                <Border.Effect>
                  <DropShadowEffect Color="#38BDF8" BlurRadius="20" ShadowDepth="0" Opacity="0.65"/>
                </Border.Effect>
              </Border>
              <Border x:Name="bd" CornerRadius="11" BorderThickness="1" BorderBrush="#7DD3FC">
                <Border.Background>
                  <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                    <GradientStop Color="#06B6D4" Offset="0"/>
                    <GradientStop Color="#0284C7" Offset="0.5"/>
                    <GradientStop Color="#4F46E5" Offset="1"/>
                  </LinearGradientBrush>
                </Border.Background>
                <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
              </Border>
            </Grid>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="glow" Property="Opacity" Value="0.55"/>
                <Setter TargetName="bd" Property="BorderBrush" Value="#E0F2FE"/>
              </Trigger>
              <Trigger Property="IsEnabled" Value="False">
                <Setter TargetName="bd" Property="Opacity" Value="0.38"/>
                <Setter TargetName="glow" Property="Opacity" Value="0"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <!-- Pulsante Secondario Glass (PolarisSecondaryButton) -->
    <Style x:Key="PolarisSecondaryButton" TargetType="Button">
      <Setter Property="Foreground" Value="#E2E8F0"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" CornerRadius="10" Background="#162238" BorderBrush="#3338BDF8" BorderThickness="1">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#1E304F"/>
                <Setter TargetName="bd" Property="BorderBrush" Value="#8038BDF8"/>
                <Setter Property="Foreground" Value="#FFFFFF"/>
              </Trigger>
              <Trigger Property="IsEnabled" Value="False">
                <Setter TargetName="bd" Property="Opacity" Value="0.35"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <!-- Pulsante Ripristino Inglese (PolarisDangerButton) -->
    <Style x:Key="PolarisDangerButton" TargetType="Button">
      <Setter Property="Foreground" Value="#FDA4AF"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" CornerRadius="10" Background="#1F1220" BorderBrush="#4DF43F5E" BorderThickness="1">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#361629"/>
                <Setter TargetName="bd" Property="BorderBrush" Value="#99F43F5E"/>
                <Setter Property="Foreground" Value="#FFE4E6"/>
              </Trigger>
              <Trigger Property="IsEnabled" Value="False">
                <Setter TargetName="bd" Property="Opacity" Value="0.35"/>
                <Setter Property="Foreground" Value="#64748B"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <!-- Pulsante Ghost / Link (PolarisGhostButton) -->
    <Style x:Key="PolarisGhostButton" TargetType="Button">
      <Setter Property="Foreground" Value="#94A3B8"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border Background="Transparent"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True"><Setter Property="Foreground" Value="#38BDF8"/></Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <!-- Pulsante Switcher Client Rapido (PolarisClientSwitchBtn) -->
    <Style x:Key="PolarisClientSwitchBtn" TargetType="Button">
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" CornerRadius="7" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter Property="Opacity" Value="0.85"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <!-- Casella di Ricerca (PolarisSearchBox) -->
    <Style x:Key="PolarisSearchBox" TargetType="TextBox">
      <Setter Property="Foreground" Value="#F8FAFC"/>
      <Setter Property="CaretBrush" Value="#38BDF8"/>
      <Setter Property="SelectionBrush" Value="#4D38BDF8"/>
      <Setter Property="FontSize" Value="13"/>
      <Setter Property="Padding" Value="14,8"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="TextBox">
            <Border x:Name="bd" CornerRadius="10" Background="#0B101B" BorderBrush="#26334D" BorderThickness="1">
              <ScrollViewer x:Name="PART_ContentHost" VerticalAlignment="{TemplateBinding VerticalContentAlignment}"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="bd" Property="BorderBrush" Value="#4D38BDF8"/></Trigger>
              <Trigger Property="IsFocused" Value="True"><Setter TargetName="bd" Property="BorderBrush" Value="#38BDF8"/></Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <!-- Tendina Categorie (PolarisComboBoxItem & PolarisComboBox) -->
    <Style x:Key="PolarisComboBoxItem" TargetType="ComboBoxItem">
      <Setter Property="Foreground" Value="#CBD5E1"/>
      <Setter Property="FontSize" Value="12.5"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="ComboBoxItem">
            <Border x:Name="bd" Background="Transparent" Padding="12,8" CornerRadius="6" Margin="4,1">
              <ContentPresenter/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsHighlighted" Value="True"><Setter TargetName="bd" Property="Background" Value="#1E293B"/></Trigger>
              <Trigger Property="IsSelected" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#2638BDF8"/>
                <Setter Property="Foreground" Value="#38BDF8"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="PolarisComboBox" TargetType="ComboBox">
      <Setter Property="Foreground" Value="#F8FAFC"/>
      <Setter Property="ItemContainerStyle" Value="{StaticResource PolarisComboBoxItem}"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="ComboBox">
            <Grid>
              <ToggleButton Focusable="False" ClickMode="Press"
                            IsChecked="{Binding IsDropDownOpen, Mode=TwoWay, RelativeSource={RelativeSource TemplatedParent}}">
                <ToggleButton.Template>
                  <ControlTemplate TargetType="ToggleButton">
                    <Border x:Name="bd" CornerRadius="10" Background="#0B101B" BorderBrush="#26334D" BorderThickness="1">
                      <TextBlock Text="&#xE70D;" FontFamily="Segoe MDL2 Assets" FontSize="10" Foreground="#38BDF8"
                                 HorizontalAlignment="Right" VerticalAlignment="Center" Margin="0,0,14,0"/>
                    </Border>
                    <ControlTemplate.Triggers>
                      <Trigger Property="IsMouseOver" Value="True">
                        <Setter TargetName="bd" Property="BorderBrush" Value="#6638BDF8"/>
                        <Setter TargetName="bd" Property="Background" Value="#111A2E"/>
                      </Trigger>
                    </ControlTemplate.Triggers>
                  </ControlTemplate>
                </ToggleButton.Template>
              </ToggleButton>
              <ContentPresenter Margin="14,0,32,0" VerticalAlignment="Center" IsHitTestVisible="False"
                                Content="{TemplateBinding SelectionBoxItem}" TextElement.Foreground="#F8FAFC"/>
              <Popup IsOpen="{TemplateBinding IsDropDownOpen}" Placement="Bottom" AllowsTransparency="True" Focusable="False" PopupAnimation="Fade">
                <Border Background="#0F172A" BorderBrush="#4D38BDF8" BorderThickness="1" CornerRadius="10"
                        MinWidth="{TemplateBinding ActualWidth}" Margin="0,4,0,0">
                  <Border.Effect><DropShadowEffect Color="#000000" BlurRadius="16" ShadowDepth="4" Opacity="0.7"/></Border.Effect>
                  <ScrollViewer MaxHeight="260"><StackPanel IsItemsHost="True" Margin="0,4"/></ScrollViewer>
                </Border>
              </Popup>
            </Grid>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <!-- Tabella Dizionario Bilingue -->
    <Style x:Key="PolarisColumnHeader" TargetType="GridViewColumnHeader">
      <Setter Property="Foreground" Value="#38BDF8"/>
      <Setter Property="FontSize" Value="10.5"/>
      <Setter Property="FontWeight" Value="Bold"/>
      <Setter Property="HorizontalContentAlignment" Value="Left"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="GridViewColumnHeader">
            <Border Background="#0D1322" BorderBrush="#26334D" BorderThickness="0,0,0,1" Padding="14,10">
              <ContentPresenter/>
            </Border>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="PolarisDictionaryRow" TargetType="ListViewItem">
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="ListViewItem">
            <Border x:Name="bd" Background="Transparent" BorderBrush="#14FFFFFF" BorderThickness="0,0,0,1">
              <GridViewRowPresenter Content="{TemplateBinding Content}"
                                    Columns="{TemplateBinding GridView.ColumnCollection}"
                                    VerticalAlignment="Center" Margin="4,8"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#1A38BDF8"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Storyboard x:Key="OrbPulseAnim" RepeatBehavior="Forever" AutoReverse="True">
      <DoubleAnimation Storyboard.TargetName="StatusOrb" Storyboard.TargetProperty="Opacity" From="1" To="0.45" Duration="0:0:1.5">
        <DoubleAnimation.EasingFunction><SineEase EasingMode="EaseInOut"/></DoubleAnimation.EasingFunction>
      </DoubleAnimation>
    </Storyboard>
  </Window.Resources>

  <Window.Triggers>
    <EventTrigger RoutedEvent="FrameworkElement.Loaded">
      <BeginStoryboard Storyboard="{StaticResource OrbPulseAnim}"/>
    </EventTrigger>
  </Window.Triggers>

  <Grid Margin="14">
    <!-- Ombra Esterna Finestra -->
    <Border CornerRadius="18" Background="#090D16">
      <Border.Effect>
        <DropShadowEffect Color="#000000" BlurRadius="26" ShadowDepth="5" Opacity="0.82"/>
      </Border.Effect>
    </Border>

    <Border x:Name="OuterFrame" CornerRadius="18" BorderThickness="1" BorderBrush="#2E38BDF8" Background="#090D16" ClipToBounds="True">
      <Grid>
        <Grid.RowDefinitions>
          <RowDefinition Height="62"/>
          <RowDefinition Height="*"/>
          <RowDefinition Height="82"/>
        </Grid.RowDefinitions>

        <!-- ================= FASCIA 1: TOP NAVIGATION BAR ================= -->
        <Border x:Name="TopHeaderBar" Grid.Row="0" Background="#0D1322" BorderThickness="0,0,0,1" BorderBrush="#1F38BDF8">
          <Grid Margin="22,0,14,0">
            <Grid.ColumnDefinitions>
              <ColumnDefinition Width="Auto"/>
              <ColumnDefinition Width="*"/>
              <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>

            <!-- Brand Identity Orizzontale: Cristallo Vettoriale Prismana + Pillole Tricolore -->
            <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
              <Border Width="38" Height="38" CornerRadius="11" BorderThickness="1.5" BorderBrush="#7DD3FC">
                <Border.Background>
                  <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                    <GradientStop Color="#06B6D4" Offset="0"/>
                    <GradientStop Color="#4F46E5" Offset="1"/>
                  </LinearGradientBrush>
                </Border.Background>
                <Grid>
                  <Path Data="M19,5 L22.2,14.8 L32,18 L22.2,21.2 L19,31 L15.8,21.2 L6,18 L15.8,14.8 Z"
                        Fill="#FFFFFF" Stretch="Uniform" Margin="7"/>
                </Grid>
              </Border>

              <StackPanel VerticalAlignment="Center" Margin="12,0,0,0">
                <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                  <TextBlock Text="ANIIMO" Foreground="#F8FAFC" FontSize="15" FontWeight="Bold" VerticalAlignment="Center"/>
                  <TextBlock Text="·" Foreground="#38BDF8" FontSize="15" FontWeight="Bold" Margin="6,0" VerticalAlignment="Center"/>
                  <TextBlock Text="ITALIAN LOCALIZATION" Foreground="#BAE6FD" FontSize="11.5" FontWeight="Bold" VerticalAlignment="Center"/>
                </StackPanel>
                <StackPanel Orientation="Horizontal" Margin="0,3,0,0">
                  <Border Width="14" Height="3" CornerRadius="1.5" Background="#10B981" Margin="0,0,3,0"/>
                  <Border Width="14" Height="3" CornerRadius="1.5" Background="#F8FAFC" Margin="0,0,3,0"/>
                  <Border Width="14" Height="3" CornerRadius="1.5" Background="#F43F5E" Margin="0,0,8,0"/>
                  <TextBlock x:Name="HeaderSubMeta" Text="Polaris FastPacker v1.0 · Traduzione v1.1.4 (112.418 voci)" Foreground="#64748B" FontSize="10.5" VerticalAlignment="Center"/>
                </StackPanel>
              </StackPanel>
            </StackPanel>

            <!-- Switcher Centrale a Pillole Orizzontali -->
            <Border Grid.Column="1" HorizontalAlignment="Center" VerticalAlignment="Center"
                    CornerRadius="12" Background="#090D16" BorderBrush="#1E293B" BorderThickness="1" Padding="4">
              <StackPanel Orientation="Horizontal">
                <RadioButton x:Name="TabDashboard" Style="{StaticResource PolarisNavTab}" GroupName="MainNav" Content="Dashboard &amp; Patch" IsChecked="True" Tag="&#xE80F;"/>
                <RadioButton x:Name="TabDictionary" Style="{StaticResource PolarisNavTab}" GroupName="MainNav" Content="Dizionario IT &#8596; EN" Tag="&#xE721;"/>
                <RadioButton x:Name="TabArchitecture" Style="{StaticResource PolarisNavTab}" GroupName="MainNav" Content="Changelog &amp; Guida" Tag="&#xE81C;"/>
              </StackPanel>
            </Border>

            <!-- Azioni Destra & Controlli Finestra -->
            <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Center">
              <Border CornerRadius="8" Background="#111A2E" BorderBrush="#1E293B" BorderThickness="1" Padding="10,6" Margin="0,0,10,0" VerticalAlignment="Center">
                <StackPanel Orientation="Horizontal">
                  <Ellipse x:Name="HeaderStatusDot" Width="7" Height="7" Fill="#10B981" VerticalAlignment="Center"/>
                  <TextBlock x:Name="HeaderStatusText" Text="Build 3746914 · Allineata" Foreground="#CBD5E1" FontSize="11" FontWeight="SemiBold" Margin="7,0,0,0" VerticalAlignment="Center"/>
                </StackPanel>
              </Border>

              <Button x:Name="BtnCheckGitHub" Style="{StaticResource PolarisSecondaryButton}" Height="32" Padding="12,0" Margin="0,0,10,0"
                      ToolTip="Verifica la versione online e aggiorna la traduzione da GitHub">
                <StackPanel Orientation="Horizontal" Margin="10,0">
                  <TextBlock Text="&#xE895;" FontFamily="Segoe MDL2 Assets" FontSize="11" Foreground="#38BDF8" VerticalAlignment="Center" Margin="0,0,7,0"/>
                  <TextBlock Text="Aggiorna Traduzione" FontSize="11.5" FontWeight="SemiBold" VerticalAlignment="Center"/>
                </StackPanel>
              </Button>

              <Button x:Name="BtnMinimizeWin" Style="{StaticResource PolarisGhostButton}" Content="&#8211;" Width="32" Height="32" FontSize="16"/>
              <Button x:Name="BtnCloseWin" Style="{StaticResource PolarisGhostButton}" Content="&#10005;" Width="32" Height="32" FontSize="13"/>
            </StackPanel>
          </Grid>
        </Border>

        <!-- ================= FASCIA 2: WORKSPACE CENTRALE ================= -->
        <Grid Grid.Row="1">

          <!-- ===================================================================== -->
          <!-- VISTA 1: DASHBOARD (CINEMA HERO 16:9 SPLIT + 2 BENTO CARDS)           -->
          <!-- ===================================================================== -->
          <Grid x:Name="ViewDashboard" Margin="22,16,22,14">
            <Grid.RowDefinitions>
              <RowDefinition Height="318"/>
              <RowDefinition Height="14"/>
              <RowDefinition Height="*"/>
            </Grid.RowDefinitions>

            <!-- CINEMA HERO BANNER SPLIT (Artwork 16:9 nitido e non coperto a destra + Showcase editoriale a sinistra) -->
            <Border Grid.Row="0" CornerRadius="16" BorderBrush="#3338BDF8" BorderThickness="1" ClipToBounds="True">
              <Border.Background>
                <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                  <GradientStop Color="#0D1526" Offset="0"/>
                  <GradientStop Color="#111C33" Offset="0.5"/>
                  <GradientStop Color="#0B101D" Offset="1"/>
                </LinearGradientBrush>
              </Border.Background>

              <Grid>
                <!-- Artwork 16:9 sulla destra (630x318 = formato 16:9 perfetto: logo ANI!MO e tutti i 5 Aniimo interamente visibili!) -->
                <Grid HorizontalAlignment="Right" Width="640" Height="318">
                  <Grid.OpacityMask>
                    <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                      <GradientStop Color="#00000000" Offset="0"/>
                      <GradientStop Color="#99000000" Offset="0.16"/>
                      <GradientStop Color="#FF000000" Offset="0.34"/>
                      <GradientStop Color="#FF000000" Offset="1"/>
                    </LinearGradientBrush>
                  </Grid.OpacityMask>
                  <Image x:Name="HeroArtworkImg" Stretch="UniformToFill" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Grid>

                <!-- Sfumatura inferiore morbida -->
                <Rectangle VerticalAlignment="Bottom" Height="56" IsHitTestVisible="False">
                  <Rectangle.Fill>
                    <LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
                      <GradientStop Color="#000D1526" Offset="0"/>
                      <GradientStop Color="#B30B101D" Offset="1"/>
                    </LinearGradientBrush>
                  </Rectangle.Fill>
                </Rectangle>

                <!-- Showcase Editoriale a Sinistra -->
                <StackPanel HorizontalAlignment="Left" VerticalAlignment="Center" Width="560" Margin="30,0,0,0">
                  <!-- Badge Flottante Compatibilità Build -->
                  <StackPanel Orientation="Horizontal" Margin="0,0,0,12">
                    <Border CornerRadius="8" Background="#1A10B981" BorderBrush="#6610B981" BorderThickness="1" Padding="12,5">
                      <StackPanel Orientation="Horizontal">
                        <TextBlock x:Name="HeroCompatIcon" Text="&#xE73E;" FontFamily="Segoe MDL2 Assets" FontSize="11.5" Foreground="#34D399" VerticalAlignment="Center" Margin="0,0,7,0"/>
                        <TextBlock x:Name="HeroCompatLabel" Text="TRADUZIONE v1.1.4 · AGGIORNATA ALL'ULTIMA BUILD (3746914)" Foreground="#ECFDF5" FontSize="10.5" FontWeight="Bold" VerticalAlignment="Center"/>
                      </StackPanel>
                    </Border>
                  </StackPanel>

                  <TextBlock Text="TRADUZIONE ITALIANA COMPLETA · SLOT EN DIRETTO" Foreground="#38BDF8" FontSize="11" FontWeight="Bold" Margin="0,0,0,4"/>
                  <TextBlock Text="Gioca ad Aniimo in Italiano" Foreground="#F8FAFC" FontSize="30" FontWeight="Bold" Margin="0,0,0,8"/>

                  <TextBlock Foreground="#CBD5E1" FontSize="12.5" LineHeight="19" TextWrapping="Wrap" Margin="0,0,20,16"
                             Text="Localizzazione integrale in italiano con compilazione binaria C# in-memory su StreamingAssets. Avvia il gioco direttamente in italiano senza mai sostituire pmdata.bin o gli script Lua con file obsoleti."/>

                  <!-- 3 Pillole Informative Orizzontali -->
                  <WrapPanel Orientation="Horizontal">
                    <Border CornerRadius="8" Background="#162235" BorderBrush="#26FFFFFF" BorderThickness="1" Padding="11,6" Margin="0,0,8,6">
                      <StackPanel Orientation="Horizontal">
                        <TextBlock Text="&#xE8A5;" FontFamily="Segoe MDL2 Assets" FontSize="11" Foreground="#38BDF8" VerticalAlignment="Center" Margin="0,0,6,0"/>
                        <TextBlock x:Name="HeroStringsChip" Text="112.418 stringhe · 2026-10-18" Foreground="#E2E8F0" FontSize="11" FontWeight="SemiBold"/>
                      </StackPanel>
                    </Border>
                    <Border CornerRadius="8" Background="#162235" BorderBrush="#26FFFFFF" BorderThickness="1" Padding="11,6" Margin="0,0,8,6">
                      <StackPanel Orientation="Horizontal">
                        <TextBlock Text="&#xE774;" FontFamily="Segoe MDL2 Assets" FontSize="11" Foreground="#34D399" VerticalAlignment="Center" Margin="0,0,6,0"/>
                        <TextBlock Text="Avvio Diretto in ITA (100%)" Foreground="#E2E8F0" FontSize="11" FontWeight="SemiBold"/>
                      </StackPanel>
                    </Border>
                    <Border CornerRadius="8" Background="#162235" BorderBrush="#26FFFFFF" BorderThickness="1" Padding="11,6" Margin="0,0,0,6">
                      <StackPanel Orientation="Horizontal">
                        <TextBlock Text="&#xE945;" FontFamily="Segoe MDL2 Assets" FontSize="11" Foreground="#A5B4FC" VerticalAlignment="Center" Margin="0,0,6,0"/>
                        <TextBlock x:Name="HeroVersionChip" Text="Traduzione v1.1.4 · Build 3746914" Foreground="#E2E8F0" FontSize="11" FontWeight="SemiBold"/>
                      </StackPanel>
                    </Border>
                  </WrapPanel>
                </StackPanel>
              </Grid>
            </Border>

            <!-- GRIGLIA BENTO INFERIORE A 2 CARD AFFIANCATE -->
            <Grid Grid.Row="2">
              <Grid.ColumnDefinitions>
                <ColumnDefinition Width="1.15*"/>
                <ColumnDefinition Width="16"/>
                <ColumnDefinition Width="0.85*"/>
              </Grid.ColumnDefinitions>

              <!-- BENTO CARD SINISTRA: STATO TRADUZIONE, TELEMETRIA BUILD E CARTELLA GIOCO -->
              <Border Grid.Column="0" CornerRadius="16" Background="#0F1626" BorderBrush="#2438BDF8" BorderThickness="1" Padding="20,16">
                <Grid>
                  <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                  </Grid.RowDefinitions>

                  <!-- Header Stato -->
                  <Grid Grid.Row="0">
                    <Grid.ColumnDefinitions>
                      <ColumnDefinition Width="Auto"/>
                      <ColumnDefinition Width="*"/>
                      <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <Border Grid.Column="0" Width="40" Height="40" CornerRadius="12" Background="#16243D" BorderBrush="#2E38BDF8" BorderThickness="1" VerticalAlignment="Center">
                      <Ellipse x:Name="StatusOrb" Width="13" Height="13" Fill="#10B981" HorizontalAlignment="Center" VerticalAlignment="Center">
                        <Ellipse.Effect><DropShadowEffect x:Name="StatusOrbGlow" Color="#10B981" BlurRadius="14" ShadowDepth="0" Opacity="0.9"/></Ellipse.Effect>
                      </Ellipse>
                    </Border>
                    <StackPanel Grid.Column="1" Margin="12,0,0,0" VerticalAlignment="Center">
                      <TextBlock x:Name="TxtStatusTitle" Text="Attiva (v1.0)" Foreground="#F8FAFC" FontSize="17.5" FontWeight="Bold"/>
                      <TextBlock x:Name="TxtStatusSub" Text="Allineata alla Build 3746914 · Pronta per giocare" Foreground="#94A3B8" FontSize="11.5" Margin="0,1,0,0"/>
                    </StackPanel>
                    <Border Grid.Column="2" CornerRadius="6" Background="#0B101B" BorderBrush="#1E293B" BorderThickness="1" Padding="10,4" VerticalAlignment="Center">
                      <TextBlock Text="STEAM · XBOX · PAWPRINT" Foreground="#64748B" FontSize="9.5" FontWeight="Bold"/>
                    </Border>
                  </Grid>

                  <!-- Strip Telemetria 3 Box + Messaggio Match -->
                  <Border Grid.Row="1" CornerRadius="11" Background="#090D16" BorderBrush="#1E293B" BorderThickness="1" Padding="14,10" Margin="0,12,0,0">
                    <StackPanel>
                      <Grid>
                        <Grid.ColumnDefinitions>
                          <ColumnDefinition Width="*"/>
                          <ColumnDefinition Width="*"/>
                          <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        <StackPanel Grid.Column="0">
                          <TextBlock Text="BUILD GIOCO RILEVATA" Foreground="#64748B" FontSize="9.5" FontWeight="Bold"/>
                          <TextBlock x:Name="TxtDetectedBuild" Text="3746914" Foreground="#F8FAFC" FontSize="13.5" FontWeight="Bold" Margin="0,2,0,0"/>
                        </StackPanel>
                        <StackPanel Grid.Column="1">
                          <TextBlock Text="BUILD DIZIONARIO ITA" Foreground="#64748B" FontSize="9.5" FontWeight="Bold"/>
                          <TextBlock x:Name="TxtPatchBuild" Text="3746914 (v1.0)" Foreground="#38BDF8" FontSize="13.5" FontWeight="Bold" Margin="0,2,0,0"/>
                        </StackPanel>
                        <StackPanel Grid.Column="2">
                          <TextBlock Text="SLOT DI DESTINAZIONE" Foreground="#64748B" FontSize="9.5" FontWeight="Bold"/>
                          <TextBlock Text="Inglese (en) -> ITA" Foreground="#A5B4FC" FontSize="12.5" FontWeight="SemiBold" Margin="0,3,0,0"/>
                        </StackPanel>
                      </Grid>
                      <Border BorderBrush="#162032" BorderThickness="0,1,0,0" Margin="0,8,0,0" Padding="0,7,0,0">
                        <TextBlock x:Name="TxtBuildMatchBanner" Text="&#10004; Traduzione aggiornata all'ultima build del gioco!" Foreground="#34D399" FontSize="11.5" FontWeight="SemiBold"/>
                      </Border>
                    </StackPanel>
                  </Border>

                  <!-- Selettore Client & Cartella di Gioco (con Switcher Rapido Steam / PawPrint) -->
                  <Border Grid.Row="2" VerticalAlignment="Bottom" CornerRadius="12" Background="#090D16" BorderBrush="#1E293B" BorderThickness="1" Padding="14,10" Margin="0,10,0,0">
                    <Grid>
                      <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                      </Grid.RowDefinitions>

                      <!-- Riga 0: Selettore Rapido Client & Azioni Cartella -->
                      <Grid Grid.Row="0" Margin="0,0,0,8">
                        <Grid.ColumnDefinitions>
                          <ColumnDefinition Width="Auto"/>
                          <ColumnDefinition Width="*"/>
                          <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>

                        <!-- Bottoni Selezione Rapida Client (Steam / PawPrint) -->
                        <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                          <TextBlock Text="INSTALLAZIONE:" Foreground="#64748B" FontSize="9.5" FontWeight="Bold" VerticalAlignment="Center" Margin="0,0,8,0"/>

                          <!-- Pulsante Steam -->
                          <Button x:Name="BtnSwitchSteam" Style="{StaticResource PolarisClientSwitchBtn}" Height="28" Padding="10,0" Margin="0,0,6,0" Cursor="Hand" ToolTip="Passa all'installazione Steam di Aniimo">
                            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                              <Ellipse x:Name="IcoBtnSteamDot" Width="6" Height="6" Fill="#38BDF8" Margin="0,0,6,0" VerticalAlignment="Center"/>
                              <TextBlock Text="🎮" FontSize="10.5" Margin="0,0,4,0" VerticalAlignment="Center"/>
                              <TextBlock x:Name="TxtBtnSteamLabel" Text="Steam" FontSize="11.5" FontWeight="SemiBold" VerticalAlignment="Center"/>
                            </StackPanel>
                          </Button>

                          <!-- Pulsante PawPrint -->
                          <Button x:Name="BtnSwitchPawPrint" Style="{StaticResource PolarisClientSwitchBtn}" Height="28" Padding="10,0" Margin="0,0,6,0" Cursor="Hand" ToolTip="Passa all'installazione del Launcher ufficiale PawPrint">
                            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                              <Ellipse x:Name="IcoBtnPawPrintDot" Width="6" Height="6" Fill="#F59E0B" Margin="0,0,6,0" VerticalAlignment="Center"/>
                              <TextBlock Text="🐾" FontSize="10.5" Margin="0,0,4,0" VerticalAlignment="Center"/>
                              <TextBlock x:Name="TxtBtnPawPrintLabel" Text="PawPrint" FontSize="11.5" FontWeight="SemiBold" VerticalAlignment="Center"/>
                            </StackPanel>
                          </Button>

                          <!-- Badge Personalizzato (se percorso manuale diverso) -->
                          <Border x:Name="BadgeCustomFolder" CornerRadius="6" Background="#162032" BorderBrush="#334155" BorderThickness="1" Padding="8,3" Margin="0,0,6,0" Visibility="Collapsed" VerticalAlignment="Center">
                            <TextBlock Text="📁 Personalizzato" Foreground="#94A3B8" FontSize="11" FontWeight="SemiBold"/>
                          </Border>
                        </StackPanel>

                        <!-- Pulsanti Apri / Cambia Percorso -->
                        <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Center">
                          <Button x:Name="BtnOpenFolder" Style="{StaticResource PolarisGhostButton}" Content="Apri cartella" FontSize="11.5" FontWeight="SemiBold" Margin="0,0,12,0"/>
                          <Button x:Name="BtnSelectFolder" Style="{StaticResource PolarisGhostButton}" Content="📁 Sfoglia..." Foreground="#38BDF8" FontSize="11.5" FontWeight="Bold"/>
                        </StackPanel>
                      </Grid>

                      <!-- Riga 1: Indicatore e Percorso Completo su Disco -->
                      <Border Grid.Row="1" BorderBrush="#141E30" BorderThickness="0,1,0,0" Padding="0,7,0,0">
                        <Grid>
                          <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                          </Grid.ColumnDefinitions>
                          <TextBlock Grid.Column="0" Text="&#xE73E;" FontFamily="Segoe MDL2 Assets" FontSize="12.5" Foreground="#10B981" VerticalAlignment="Center" Margin="0,0,8,0"/>
                          <TextBlock Grid.Column="1" x:Name="TxtInstallPath" Text="" Foreground="#CBD5E1" FontSize="11" TextTrimming="CharacterEllipsis" VerticalAlignment="Center" ToolTip="Percorso attivo su disco"/>
                        </Grid>
                      </Border>
                    </Grid>
                  </Border>
                </Grid>
              </Border>

              <!-- BENTO CARD DESTRA: GUIDA RAPIDA IN 4 PASSI & ARCHITETTURA -->
              <Border Grid.Column="2" CornerRadius="16" Background="#0F1626" BorderBrush="#2438BDF8" BorderThickness="1" Padding="20,16">
                <StackPanel>
                  <StackPanel Orientation="Horizontal" Margin="0,0,0,12">
                    <TextBlock Text="&#xE736;" FontFamily="Segoe MDL2 Assets" FontSize="12" Foreground="#38BDF8" VerticalAlignment="Center" Margin="0,0,8,0"/>
                    <TextBlock Text="GUIDA OPERATIVA &amp; COMPATIBILITÀ STEAM" FontSize="10.5" Foreground="#94A3B8" FontWeight="Bold" VerticalAlignment="Center"/>
                  </StackPanel>

                  <Grid Margin="0,0,0,10">
                    <Grid.ColumnDefinitions><ColumnDefinition Width="32"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                    <Border Grid.Column="0" Width="22" Height="22" CornerRadius="7" Background="#1A38BDF8" BorderBrush="#4D38BDF8" BorderThickness="1" VerticalAlignment="Top" HorizontalAlignment="Left">
                      <TextBlock Text="1" Foreground="#38BDF8" FontSize="11" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                    </Border>
                    <TextBlock Grid.Column="1" Text="Assicurati che Aniimo sia chiuso prima di installare o aggiornare la patch." Foreground="#E2E8F0" FontSize="12" LineHeight="18" TextWrapping="Wrap"/>
                  </Grid>

                  <Grid Margin="0,0,0,10">
                    <Grid.ColumnDefinitions><ColumnDefinition Width="32"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                    <Border Grid.Column="0" Width="22" Height="22" CornerRadius="7" Background="#1A38BDF8" BorderBrush="#4D38BDF8" BorderThickness="1" VerticalAlignment="Top" HorizontalAlignment="Left">
                      <TextBlock Text="2" Foreground="#38BDF8" FontSize="11" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                    </Border>
                    <TextBlock Grid.Column="1" Text="Premi il pulsante azzurro in basso a destra: la compilazione richiede circa 1,5 secondi." Foreground="#E2E8F0" FontSize="12" LineHeight="18" TextWrapping="Wrap"/>
                  </Grid>

                  <Grid Margin="0,0,0,10">
                    <Grid.ColumnDefinitions><ColumnDefinition Width="32"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                    <Border Grid.Column="0" Width="22" Height="22" CornerRadius="7" Background="#1A38BDF8" BorderBrush="#4D38BDF8" BorderThickness="1" VerticalAlignment="Top" HorizontalAlignment="Left">
                      <TextBlock Text="3" Foreground="#38BDF8" FontSize="11" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                    </Border>
                    <TextBlock Grid.Column="1" Text="Avvia il gioco: partirà subito in ITALIANO (lascia pure English nelle impostazioni)." Foreground="#E2E8F0" FontSize="12" LineHeight="18" TextWrapping="Wrap"/>
                  </Grid>

                  <Grid>
                    <Grid.ColumnDefinitions><ColumnDefinition Width="32"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                    <Border Grid.Column="0" Width="22" Height="22" CornerRadius="7" Background="#1A38BDF8" BorderBrush="#4D38BDF8" BorderThickness="1" VerticalAlignment="Top" HorizontalAlignment="Left">
                      <TextBlock Text="4" Foreground="#38BDF8" FontSize="11" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                    </Border>
                    <TextBlock Grid.Column="1" Text="Dopo ogni aggiornamento di Steam, riapri questo patcher e premi Aggiorna." Foreground="#E2E8F0" FontSize="12" LineHeight="18" TextWrapping="Wrap"/>
                  </Grid>
                </StackPanel>
              </Border>
            </Grid>
          </Grid>

          <!-- ===================================================================== -->
          <!-- VISTA 2: DIZIONARIO BILINGUE INTERATTIVO (IT <-> EN)                  -->
          <!-- ===================================================================== -->
          <Grid x:Name="ViewDictionary" Visibility="Collapsed" Margin="22,18,22,14">
            <Grid.RowDefinitions>
              <RowDefinition Height="Auto"/>
              <RowDefinition Height="Auto"/>
              <RowDefinition Height="*"/>
              <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <StackPanel Grid.Row="0" Margin="0,0,0,12">
              <TextBlock Text="Dizionario Bilingue Interattivo (IT &#8596; EN)" Foreground="#F8FAFC" FontSize="22" FontWeight="Bold"/>
              <TextBlock Text="Generato al volo dai file del tuo gioco e da traduzione_ita.tsv per consultare wiki, guide e build in inglese senza cambiare lingua."
                         Foreground="#94A3B8" FontSize="12" Margin="0,3,0,0"/>
            </StackPanel>

            <Grid Grid.Row="1" Margin="0,0,0,12">
              <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="12"/>
                <ColumnDefinition Width="260"/>
              </Grid.ColumnDefinitions>

              <Grid Grid.Column="0">
                <TextBox x:Name="TxtDictionarySearch" Style="{StaticResource PolarisSearchBox}" Height="38" VerticalContentAlignment="Center"/>
                <TextBlock x:Name="TxtDictionaryHint" Text="Cerca un oggetto, abilità, luogo o termine in italiano o in inglese..."
                           Foreground="#64748B" FontSize="13" Margin="16,0,0,0" VerticalAlignment="Center" IsHitTestVisible="False"/>
              </Grid>

              <ComboBox x:Name="CmbDictionaryCategory" Grid.Column="2" Style="{StaticResource PolarisComboBox}" Height="38" FontSize="12.5"/>
            </Grid>

            <Border Grid.Row="2" CornerRadius="14" Background="#0D1322" BorderBrush="#2638BDF8" BorderThickness="1" Padding="2">
              <ListView x:Name="LvDictionaryTerms" Background="Transparent" BorderThickness="0"
                        ItemContainerStyle="{StaticResource PolarisDictionaryRow}"
                        VirtualizingStackPanel.IsVirtualizing="True"
                        VirtualizingStackPanel.VirtualizationMode="Recycling"
                        ScrollViewer.HorizontalScrollBarVisibility="Disabled">
                <ListView.View>
                  <GridView ColumnHeaderContainerStyle="{StaticResource PolarisColumnHeader}">
                    <GridViewColumn Header="TERMINE IN ITALIANO" Width="430">
                      <GridViewColumn.CellTemplate>
                        <DataTemplate>
                          <TextBlock Text="{Binding TermIt}" Foreground="#F8FAFC" FontSize="12.5" FontWeight="SemiBold" TextTrimming="CharacterEllipsis" Margin="8,0"/>
                        </DataTemplate>
                      </GridViewColumn.CellTemplate>
                    </GridViewColumn>
                    <GridViewColumn Header="NOME ORIGINALE INGLESE" Width="430">
                      <GridViewColumn.CellTemplate>
                        <DataTemplate>
                          <TextBlock Text="{Binding TermEn}" Foreground="#CBD5E1" FontSize="12.5" TextTrimming="CharacterEllipsis" Margin="8,0"/>
                        </DataTemplate>
                      </GridViewColumn.CellTemplate>
                    </GridViewColumn>
                    <GridViewColumn Header="CATEGORIA" Width="260">
                      <GridViewColumn.CellTemplate>
                        <DataTemplate>
                          <TextBlock Text="{Binding CategoryName}" Foreground="#38BDF8" FontSize="11.5" FontWeight="SemiBold" TextTrimming="CharacterEllipsis" Margin="8,0"/>
                        </DataTemplate>
                      </GridViewColumn.CellTemplate>
                    </GridViewColumn>
                  </GridView>
                </ListView.View>
              </ListView>
            </Border>

            <TextBlock x:Name="TxtDictionaryCount" Grid.Row="3" Text="" Foreground="#64748B" FontSize="11.5" Margin="4,8,0,0"/>
          </Grid>

          <!-- ===================================================================== -->
          <!-- VISTA 3: CHANGELOG & GUIDA TECNICA                                    -->
          <!-- ===================================================================== -->
          <ScrollViewer x:Name="ViewArchitecture" Visibility="Collapsed" VerticalScrollBarVisibility="Auto" Margin="22,18,22,14">
            <StackPanel Margin="0,0,10,0">
              <TextBlock Text="Registro delle Modifiche &amp; Guida Tecnica" Foreground="#F8FAFC" FontSize="22" FontWeight="Bold"/>
              <TextBlock Text="Migliorie della traduzione, standardizzazione terminologica e architettura in-memory di Polaris."
                         Foreground="#94A3B8" FontSize="12" Margin="0,3,0,16"/>

              <!-- CARD CHANGELOG v1.0.1 -->
              <Border CornerRadius="14" Background="#0F1626" BorderBrush="#2638BDF8" BorderThickness="1" Padding="20,16" Margin="0,0,0,14">
                <StackPanel>
                  <!-- Header Release v1.0.1 -->
                  <Grid Margin="0,0,0,12">
                    <Grid.ColumnDefinitions>
                      <ColumnDefinition Width="*"/>
                      <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <StackPanel Grid.Column="0">
                      <StackPanel Orientation="Horizontal">
                        <Border CornerRadius="6" Background="#1D2A44" BorderBrush="#38BDF8" BorderThickness="1" Padding="8,2" Margin="0,0,8,0">
                          <TextBlock x:Name="ChangelogVersionBadge" Text="VERSIONE 1.1.4" Foreground="#38BDF8" FontSize="10" FontWeight="Bold"/>
                        </Border>
                        <Border CornerRadius="6" Background="#132E27" BorderBrush="#10B981" BorderThickness="1" Padding="8,2">
                          <TextBlock x:Name="ChangelogBuildBadge" Text="BUILD 3746914 ALLINEATA" Foreground="#34D399" FontSize="10" FontWeight="Bold"/>
                        </Border>
                      </StackPanel>
                      <TextBlock x:Name="ChangelogTitle" Text="Revisione Terminologica Specialistica Globale (968 Perfezionamenti)" Foreground="#F8FAFC" FontSize="14.5" FontWeight="Bold" Margin="0,6,0,2"/>
                      <TextBlock x:Name="ChangelogDesc" Text="Audit filologico e linguistico condotto confrontando i testi con inglese, spagnolo e francese ufficiali." Foreground="#94A3B8" FontSize="11.5"/>
                    </StackPanel>
                    <TextBlock x:Name="ChangelogReleaseDate" Grid.Column="1" Text="2026-10-19" Foreground="#64748B" FontSize="11.5" FontWeight="SemiBold" VerticalAlignment="Top"/>
                  </Grid>

                  <!-- 4 Categorie a Griglia 2x2 -->
                  <Grid>
                    <Grid.ColumnDefinitions>
                      <ColumnDefinition Width="*"/>
                      <ColumnDefinition Width="12"/>
                      <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>
                    <Grid.RowDefinitions>
                      <RowDefinition Height="Auto"/>
                      <RowDefinition Height="10"/>
                      <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <!-- Lore & Dimora -->
                    <Border Grid.Row="0" Grid.Column="0" CornerRadius="10" Background="#0B101B" BorderBrush="#1E293B" BorderThickness="1" Padding="14,12">
                      <StackPanel>
                        <TextBlock x:Name="Cat1Title" Text="🐾 Lore, Creature &amp; Dimora (352 fix)" Foreground="#38BDF8" FontSize="12" FontWeight="Bold" Margin="0,0,0,5"/>
                        <TextBlock x:Name="Cat1Text" Foreground="#CBD5E1" FontSize="11.5" LineHeight="17" TextWrapping="Wrap"
                                   Text="• Dimora: unificata la traduzione canonica di Homeland (eliminata la letterale 'Madrepatria').&#x0a;• Nomi Specie: ripristinati Whelpy, Stellalord, Shrout, Lucklet, Big Chillmut, Wolferno.&#x0a;• Accarezza: corretto il verbo 'Pet' (non più sostantivo 'Animale').&#x0a;• Varie: macchina unificata su 'Incubatrice', normalizzate forme 'Alfa' e Livello Camper."/>
                      </StackPanel>
                    </Border>

                    <!-- Combattimento -->
                    <Border Grid.Row="0" Grid.Column="2" CornerRadius="10" Background="#0B101B" BorderBrush="#1E293B" BorderThickness="1" Padding="14,12">
                      <StackPanel>
                        <TextBlock x:Name="Cat2Title" Text="⚔️ Combattimento &amp; Statistiche (230 fix)" Foreground="#F43F5E" FontSize="12" FontWeight="Bold" Margin="0,0,0,5"/>
                        <TextBlock x:Name="Cat2Text" Foreground="#CBD5E1" FontSize="11.5" LineHeight="17" TextWrapping="Wrap"
                                   Text="• Difese: standardizzate tutte le sigle su DIF F. e DIF M. (eliminate forme miste inglesi).&#x0a;• Parametri: Punti Energia (PE), Tasso critico, attributi Potenza e Grinta.&#x0a;• Meccaniche: mossa 'Suprema', distinzione Vigore (schivata) vs Resistenza.&#x0a;• Status: corretto 'Bruciatura' (da verbo brucia) e abilità Spezzabruciatura."/>
                      </StackPanel>
                    </Border>

                    <!-- Mondo & Missioni -->
                    <Border Grid.Row="2" Grid.Column="0" CornerRadius="10" Background="#0B101B" BorderBrush="#1E293B" BorderThickness="1" Padding="14,12">
                      <StackPanel>
                        <TextBlock x:Name="Cat3Title" Text="🗺️ Mondo, Luoghi &amp; UI (252 fix)" Foreground="#34D399" FontSize="12" FontWeight="Bold" Margin="0,0,0,5"/>
                        <TextBlock x:Name="Cat3Text" Foreground="#CBD5E1" FontSize="11.5" LineHeight="17" TextWrapping="Wrap"
                                   Text="• Regioni: Pianure Ventose (84 correzioni discordanti), Cresta delle Mille Zanne.&#x0a;• Prova del Dottore: risolto il clamoroso calco giudiziario 'Processo del Dottore'.&#x0a;• Falsi Amici UI: 'Squadra' al posto di festa (Party), pulsante 'Esci' dai dungeon.&#x0a;• Coerenza: I Pathfinder (grammatica) e boccioli mappa standardizzati."/>
                      </StackPanel>
                    </Border>

                    <!-- Oggetti ed Economia -->
                    <Border Grid.Row="2" Grid.Column="2" CornerRadius="10" Background="#0B101B" BorderBrush="#1E293B" BorderThickness="1" Padding="14,12">
                      <StackPanel>
                        <TextBlock x:Name="Cat4Title" Text="📦 Oggetti, Fabbricazione &amp; Shop (148 fix)" Foreground="#F59E0B" FontSize="12" FontWeight="Bold" Margin="0,0,0,5"/>
                        <TextBlock x:Name="Cat4Text" Foreground="#CBD5E1" FontSize="11.5" LineHeight="17" TextWrapping="Wrap"
                                   Text="• Valute: 'Crediti' (non più Riconoscimenti da cinema!) ed energia 'Primegia'.&#x0a;• Fabbricazione: verbo 'Cucina' (non più il sostantivo cuoco!) e Fabbricatore Aniipod.&#x0a;• Equipaggiamento: 'Strumenti Tenuti' (non più Trattenuti doganali).&#x0a;• Palestra &amp; Minerali: Club Colpospirale, Stagno di legno e separazione parole fuse."/>
                      </StackPanel>
                    </Border>
                  </Grid>
                </StackPanel>
              </Border>

              <!-- CARD GUIDA TECNICA 1 -->
              <Border CornerRadius="14" Background="#0F1626" BorderBrush="#2638BDF8" BorderThickness="1" Padding="20,16" Margin="0,0,0,12">
                <StackPanel>
                  <TextBlock Text="1. PATCHING IN-MEMORY SU STREAMINGASSETS (ZERO FILE OBSOLETI)" Foreground="#38BDF8" FontSize="11" FontWeight="Bold" Margin="0,0,0,6"/>
                  <TextBlock Foreground="#CBD5E1" FontSize="12.5" LineHeight="20" TextWrapping="Wrap"
                             Text="A differenza delle patch tradizionali che sovrascrivono l'intero archivio LuaScripts.xdf o pmdata.bin con copie statiche di vecchie build (causando blocchi o schermate nere quando il gioco si aggiorna), questo programma legge l'archivio originale presente nella tua cartella StreamingAssets, inietta in memoria le 112.418 stringhe italiane nel blocco binario Compress_en.bin + NewTextMap_en.json tramite il compilatore C# AniimoFastPacker e ricalcola gli indici MD5/offset in LuaScripts.xdt e LuaCacheVer.txt."/>
                </StackPanel>
              </Border>

              <!-- CARD GUIDA TECNICA 2 -->
              <Border CornerRadius="14" Background="#0F1626" BorderBrush="#2638BDF8" BorderThickness="1" Padding="20,16" Margin="0,0,0,12">
                <StackPanel>
                  <TextBlock Text="2. AVVIO DIRETTO IN ITALIANO (SLOT INGLESE NATIVO)" Foreground="#34D399" FontSize="11" FontWeight="Bold" Margin="0,0,0,6"/>
                  <TextBlock Foreground="#CBD5E1" FontSize="12.5" LineHeight="20" TextWrapping="Wrap"
                             Text="La traduzione viene applicata direttamente sullo slot principale inglese (en). Non è necessario selezionare lo spagnolo o altre lingue secondarie nelle impostazioni del gioco: basta avviare Aniimo normalmente da Steam e tutti i menu, i dialoghi, la storia e le abilità saranno subito in italiano."/>
                </StackPanel>
              </Border>

              <!-- CARD GUIDA TECNICA 3 -->
              <Border CornerRadius="14" Background="#0F1626" BorderBrush="#2638BDF8" BorderThickness="1" Padding="20,16">
                <StackPanel>
                  <TextBlock Text="3. COSA FARE DOPO UN AGGIORNAMENTO DI STEAM O DELLA TRADUZIONE" Foreground="#A5B4FC" FontSize="11" FontWeight="Bold" Margin="0,0,0,6"/>
                  <TextBlock Foreground="#CBD5E1" FontSize="12.5" LineHeight="20" TextWrapping="Wrap"
                             Text="Quando Steam scarica una nuova patch di Aniimo o pubblichiamo una nuova revisione delle traduzioni, ti basterà aprire l'app e premere il pulsante in basso a destra. L'applicazione riallineerà i file in 1,5 secondi senza dover riscaricare file o rifare procedure manuali."/>
                </StackPanel>
              </Border>
            </StackPanel>
          </ScrollViewer>

        </Grid>

        <!-- ================= FASCIA 3: BOTTOM ACTION DOCK ================= -->
        <Border x:Name="BottomActionDock" Grid.Row="2" Background="#0D1322" BorderThickness="0,1,0,0" BorderBrush="#1F38BDF8">
          <Grid Margin="22,0,22,0">
            <Grid.ColumnDefinitions>
              <ColumnDefinition Width="*"/>
              <ColumnDefinition Width="18"/>
              <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>

            <!-- Barra Progresso & Stato Operazione -->
            <Border Grid.Column="0" Height="48" CornerRadius="12" Background="#090D16" BorderBrush="#1E293B" BorderThickness="1" Padding="16,0" VerticalAlignment="Center">
              <Grid>
                <Grid.ColumnDefinitions>
                  <ColumnDefinition Width="230"/>
                  <ColumnDefinition Width="*"/>
                  <ColumnDefinition Width="48"/>
                </Grid.ColumnDefinitions>
                <TextBlock Grid.Column="0" x:Name="TxtProgressStatus" Text="Motore C# pronto." Foreground="#CBD5E1" FontSize="12" FontWeight="SemiBold" VerticalAlignment="Center" TextTrimming="CharacterEllipsis" Margin="0,0,12,0"/>
                <ProgressBar Grid.Column="1" x:Name="BarInstallProgress" Minimum="0" Maximum="100" Value="100" Height="6"
                             Background="#162032" Foreground="#38BDF8" BorderThickness="0" VerticalAlignment="Center"/>
                <TextBlock Grid.Column="2" x:Name="TxtProgressPercent" Text="" Foreground="#38BDF8" FontSize="11.5" FontWeight="Bold" HorizontalAlignment="Right" VerticalAlignment="Center"/>
                <TextBlock Grid.Column="2" x:Name="IcoProgressReady" Text="&#xE73E;" FontFamily="Segoe MDL2 Assets" FontSize="13" Foreground="#10B981" HorizontalAlignment="Right" VerticalAlignment="Center"/>
              </Grid>
            </Border>

            <!-- Pulsanti Azione Principali -->
            <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Center">
              <Button x:Name="BtnRestoreOriginal" Style="{StaticResource PolarisDangerButton}" Height="48" Padding="16,0" Margin="0,0,10,0">
                <TextBlock Text="Ripristina Inglese" FontSize="12" FontWeight="SemiBold" Margin="12,0"/>
              </Button>

              <Button x:Name="BtnLaunchGame" Style="{StaticResource PolarisSecondaryButton}" Height="48" Padding="18,0" Margin="0,0,10,0">
                <StackPanel Orientation="Horizontal" Margin="12,0">
                  <TextBlock Text="&#xE768;" FontFamily="Segoe MDL2 Assets" FontSize="12" Foreground="#34D399" VerticalAlignment="Center" Margin="0,0,8,0"/>
                  <TextBlock Text="Avvia Aniimo" FontSize="12.5" FontWeight="Bold" VerticalAlignment="Center"/>
                </StackPanel>
              </Button>

              <Button x:Name="BtnApplyPatch" Style="{StaticResource PolarisPrimaryButton}" Height="48" Width="300"
                      FontSize="13" FontWeight="Bold" Content="INSTALLA / AGGIORNA TRADUZIONE"/>
            </StackPanel>
          </Grid>
        </Border>

      </Grid>
    </Border>
  </Grid>
</Window>
"@

$xmlReader = New-Object System.Xml.XmlNodeReader $xaml
$win = [Windows.Markup.XamlReader]::Load($xmlReader)

# Collegamento controlli WPF
$TopHeaderBar          = $win.FindName('TopHeaderBar')
$BtnMinimizeWin        = $win.FindName('BtnMinimizeWin')
$BtnCloseWin           = $win.FindName('BtnCloseWin')
$BtnCheckGitHub        = $win.FindName('BtnCheckGitHub')
$HeaderStatusDot       = $win.FindName('HeaderStatusDot')
$HeaderStatusText      = $win.FindName('HeaderStatusText')
$HeaderSubMeta         = $win.FindName('HeaderSubMeta')

$TabDashboard          = $win.FindName('TabDashboard')
$TabDictionary         = $win.FindName('TabDictionary')
$TabArchitecture       = $win.FindName('TabArchitecture')

$ViewDashboard         = $win.FindName('ViewDashboard')
$ViewDictionary        = $win.FindName('ViewDictionary')
$ViewArchitecture      = $win.FindName('ViewArchitecture')

$HeroArtworkImg        = $win.FindName('HeroArtworkImg')
$HeroCompatIcon        = $win.FindName('HeroCompatIcon')
$HeroCompatLabel       = $win.FindName('HeroCompatLabel')
$HeroVersionChip       = $win.FindName('HeroVersionChip')
$HeroStringsChip       = $win.FindName('HeroStringsChip')

$StatusOrb             = $win.FindName('StatusOrb')
$StatusOrbGlow         = $win.FindName('StatusOrbGlow')
$TxtStatusTitle        = $win.FindName('TxtStatusTitle')
$TxtStatusSub          = $win.FindName('TxtStatusSub')
$TxtDetectedBuild      = $win.FindName('TxtDetectedBuild')
$TxtPatchBuild         = $win.FindName('TxtPatchBuild')
$TxtBuildMatchBanner   = $win.FindName('TxtBuildMatchBanner')
$TxtInstallPath        = $win.FindName('TxtInstallPath')
$BtnOpenFolder         = $win.FindName('BtnOpenFolder')
$BtnSelectFolder       = $win.FindName('BtnSelectFolder')
$BtnSwitchSteam        = $win.FindName('BtnSwitchSteam')
$BtnSwitchPawPrint     = $win.FindName('BtnSwitchPawPrint')
$TxtBtnSteamLabel      = $win.FindName('TxtBtnSteamLabel')
$TxtBtnPawPrintLabel   = $win.FindName('TxtBtnPawPrintLabel')
$IcoBtnSteamDot        = $win.FindName('IcoBtnSteamDot')
$IcoBtnPawPrintDot     = $win.FindName('IcoBtnPawPrintDot')
$BadgeCustomFolder     = $win.FindName('BadgeCustomFolder')

$TxtProgressStatus     = $win.FindName('TxtProgressStatus')
$BarInstallProgress    = $win.FindName('BarInstallProgress')
$TxtProgressPercent    = $win.FindName('TxtProgressPercent')
$IcoProgressReady      = $win.FindName('IcoProgressReady')
$BtnRestoreOriginal    = $win.FindName('BtnRestoreOriginal')
$BtnLaunchGame         = $win.FindName('BtnLaunchGame')
$BtnApplyPatch         = $win.FindName('BtnApplyPatch')

$TxtDictionarySearch   = $win.FindName('TxtDictionarySearch')
$TxtDictionaryHint     = $win.FindName('TxtDictionaryHint')
$CmbDictionaryCategory = $win.FindName('CmbDictionaryCategory')
$LvDictionaryTerms     = $win.FindName('LvDictionaryTerms')
$TxtDictionaryCount    = $win.FindName('TxtDictionaryCount')

$ChangelogVersionBadge = $win.FindName('ChangelogVersionBadge')
$ChangelogBuildBadge   = $win.FindName('ChangelogBuildBadge')
$ChangelogReleaseDate  = $win.FindName('ChangelogReleaseDate')
$ChangelogTitle        = $win.FindName('ChangelogTitle')
$ChangelogDesc         = $win.FindName('ChangelogDesc')
$Cat1Title             = $win.FindName('Cat1Title')
$Cat1Text              = $win.FindName('Cat1Text')
$Cat2Title             = $win.FindName('Cat2Title')
$Cat2Text              = $win.FindName('Cat2Text')
$Cat3Title             = $win.FindName('Cat3Title')
$Cat3Text              = $win.FindName('Cat3Text')
$Cat4Title             = $win.FindName('Cat4Title')
$Cat4Text              = $win.FindName('Cat4Text')

# Caricamento Artwork Hero (sfondo.jpg)
if (Test-Path -LiteralPath $ArtPath) {
    try {
        $bmp = New-Object System.Windows.Media.Imaging.BitmapImage
        $bmp.BeginInit()
        $bmp.UriSource = New-Object System.Uri($ArtPath, [System.UriKind]::Absolute)
        $bmp.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
        $bmp.EndInit()
        $bmp.Freeze()
        $HeroArtworkImg.Source = $bmp
    } catch {}
}

$script:CurrentGameDir   = $ResolvedGameDir
$script:DetectedInstalls = Find-AllAniimoInstallations
$script:CurrentMeta      = $TsvMeta
$script:GlossaryData   = $null
$script:GlossaryLoaded = $false
$script:IsBusy         = $false

function Invoke-UiRefresh {
    [System.Windows.Forms.Application]::DoEvents()
}

function Set-ProgressBarState([int]$Percent, [string]$LabelText, [bool]$Finished) {
    $BarInstallProgress.Value = $Percent
    $TxtProgressStatus.Text   = $LabelText
    if ($Finished) {
        $TxtProgressPercent.Text        = ''
        $IcoProgressReady.Visibility    = 'Visible'
        $BarInstallProgress.Foreground  = ([Windows.Media.BrushConverter]::new()).ConvertFromString('#38BDF8')
    } else {
        $TxtProgressPercent.Text        = "$Percent%"
        $IcoProgressReady.Visibility    = 'Collapsed'
        $BarInstallProgress.Foreground  = ([Windows.Media.BrushConverter]::new()).ConvertFromString('#06B6D4')
    }
    Invoke-UiRefresh
}

function Update-UiDashboard {
    $script:CurrentMeta = Get-TsvMetadata $TsvPath
    $m = $script:CurrentMeta

    if ($win) { $win.Title = "Aniimo — Localizzazione Italiana (Launcher v1.0 · Traduzione v$($m.versione))" }
    $HeaderSubMeta.Text   = "Polaris FastPacker v1.0 · Traduzione v$($m.versione) ($($m.voci_fmt) voci)"
    $HeroVersionChip.Text = "Traduzione v$($m.versione) · Build $($m.build)"
    $HeroStringsChip.Text = "$($m.voci_fmt) stringhe · $($m.data)"
    $TxtPatchBuild.Text   = "$($m.build) (v$($m.versione))"

    if ($m.PSObject.Properties.Name -contains 'changelog_dettagliato' -and $m.changelog_dettagliato) {
        $cd = $m.changelog_dettagliato
        if ($ChangelogVersionBadge) { $ChangelogVersionBadge.Text = "VERSIONE $($m.versione)" }
        if ($ChangelogBuildBadge)   { $ChangelogBuildBadge.Text   = "BUILD $($m.build) ALLINEATA" }
        if ($ChangelogReleaseDate)  { $ChangelogReleaseDate.Text  = [string]$m.data }
        if ($ChangelogTitle -and $cd.titolo) { $ChangelogTitle.Text = [string]$cd.titolo }
        if ($ChangelogDesc -and $cd.descrizione) { $ChangelogDesc.Text = [string]$cd.descrizione }
        if ($Cat1Title -and $cd.cat1_titolo) { $Cat1Title.Text = [string]$cd.cat1_titolo }
        if ($Cat1Text -and $cd.cat1_testo)   { $Cat1Text.Text  = [string]$cd.cat1_testo }
        if ($Cat2Title -and $cd.cat2_titolo) { $Cat2Title.Text = [string]$cd.cat2_titolo }
        if ($Cat2Text -and $cd.cat2_testo)   { $Cat2Text.Text  = [string]$cd.cat2_testo }
        if ($Cat3Title -and $cd.cat3_titolo) { $Cat3Title.Text = [string]$cd.cat3_titolo }
        if ($Cat3Text -and $cd.cat3_testo)   { $Cat3Text.Text  = [string]$cd.cat3_testo }
        if ($Cat4Title -and $cd.cat4_titolo) { $Cat4Title.Text = [string]$cd.cat4_titolo }
        if ($Cat4Text -and $cd.cat4_testo)   { $Cat4Text.Text  = [string]$cd.cat4_testo }
    }

    $st = Get-TranslationStatus $script:CurrentGameDir $m
    $TxtStatusTitle.Text = $st.Title
    $TxtStatusSub.Text   = $st.Sub
    $BtnApplyPatch.Content = $st.BtnText
    $BtnRestoreOriginal.IsEnabled = $st.CanRemove
    $BtnOpenFolder.IsEnabled      = [bool]$script:CurrentGameDir
    $BtnLaunchGame.IsEnabled      = [bool]$script:CurrentGameDir

    $brushConv = New-Object System.Windows.Media.BrushConverter
    $StatusOrb.Fill = $brushConv.ConvertFromString($st.DotColor)
    $StatusOrbGlow.Color = [System.Windows.Media.ColorConverter]::ConvertFromString($st.DotColor)

    # Aggiornamento Selettore Client Rapido (Steam / PawPrint)
    $hasSteam    = $script:DetectedInstalls.ContainsKey('Steam')
    $hasPawPrint = $script:DetectedInstalls.ContainsKey('PawPrint')
    $steamPath   = if ($hasSteam) { $script:DetectedInstalls['Steam'] } else { '' }
    $pawPath     = if ($hasPawPrint) { $script:DetectedInstalls['PawPrint'] } else { '' }

    $isSteamActive    = $script:CurrentGameDir -and ($script:CurrentGameDir.TrimEnd('\') -ieq $steamPath.TrimEnd('\'))
    $isPawPrintActive = $script:CurrentGameDir -and ($script:CurrentGameDir.TrimEnd('\') -ieq $pawPath.TrimEnd('\'))

    if ($BtnSwitchSteam) {
        $BtnSwitchSteam.Visibility = if ($hasSteam) { 'Visible' } else { 'Collapsed' }
        if ($isSteamActive) {
            $BtnSwitchSteam.Background = $brushConv.ConvertFromString('#162E44')
            $BtnSwitchSteam.BorderBrush = $brushConv.ConvertFromString('#38BDF8')
            $BtnSwitchSteam.BorderThickness = New-Object Windows.Thickness 1.2
            $TxtBtnSteamLabel.Foreground = $brushConv.ConvertFromString('#38BDF8')
            $TxtBtnSteamLabel.FontWeight = [Windows.FontWeights]::Bold
            $IcoBtnSteamDot.Fill = $brushConv.ConvertFromString('#38BDF8')
        } else {
            $BtnSwitchSteam.Background = $brushConv.ConvertFromString('#0D1526')
            $BtnSwitchSteam.BorderBrush = $brushConv.ConvertFromString('#1E293B')
            $BtnSwitchSteam.BorderThickness = New-Object Windows.Thickness 1
            $TxtBtnSteamLabel.Foreground = $brushConv.ConvertFromString('#94A3B8')
            $TxtBtnSteamLabel.FontWeight = [Windows.FontWeights]::SemiBold
            $IcoBtnSteamDot.Fill = $brushConv.ConvertFromString('#475569')
        }
    }

    if ($BtnSwitchPawPrint) {
        $BtnSwitchPawPrint.Visibility = if ($hasPawPrint) { 'Visible' } else { 'Collapsed' }
        if ($isPawPrintActive) {
            $BtnSwitchPawPrint.Background = $brushConv.ConvertFromString('#2A2016')
            $BtnSwitchPawPrint.BorderBrush = $brushConv.ConvertFromString('#F59E0B')
            $BtnSwitchPawPrint.BorderThickness = New-Object Windows.Thickness 1.2
            $TxtBtnPawPrintLabel.Foreground = $brushConv.ConvertFromString('#FBBF24')
            $TxtBtnPawPrintLabel.FontWeight = [Windows.FontWeights]::Bold
            $IcoBtnPawPrintDot.Fill = $brushConv.ConvertFromString('#F59E0B')
        } else {
            $BtnSwitchPawPrint.Background = $brushConv.ConvertFromString('#0D1526')
            $BtnSwitchPawPrint.BorderBrush = $brushConv.ConvertFromString('#1E293B')
            $BtnSwitchPawPrint.BorderThickness = New-Object Windows.Thickness 1
            $TxtBtnPawPrintLabel.Foreground = $brushConv.ConvertFromString('#94A3B8')
            $TxtBtnPawPrintLabel.FontWeight = [Windows.FontWeights]::SemiBold
            $IcoBtnPawPrintDot.Fill = $brushConv.ConvertFromString('#475569')
        }
    }

    if ($BadgeCustomFolder) {
        $isCustom = (-not $isSteamActive) -and (-not $isPawPrintActive) -and ($null -ne $script:CurrentGameDir)
        $BadgeCustomFolder.Visibility = if ($isCustom) { 'Visible' } else { 'Collapsed' }
    }

    if ($script:CurrentGameDir) {
        $TxtInstallPath.Text = $script:CurrentGameDir
        $gb = Get-GameBuild $script:CurrentGameDir
        $TxtDetectedBuild.Text = $gb

        if ($gb -eq $m.build) {
            $TxtBuildMatchBanner.Text       = "✔ Traduzione aggiornata all'ultima build del gioco!"
            $TxtBuildMatchBanner.Foreground = $brushConv.ConvertFromString('#34D399')
            $HeroCompatLabel.Text           = "TRADUZIONE v$($m.versione) · AGGIORNATA ALL'ULTIMA BUILD ($gb)"
            $HeroCompatIcon.Text            = [string][char]0xE73E
            $HeroCompatIcon.Foreground      = $brushConv.ConvertFromString('#34D399')
            $HeaderStatusDot.Fill           = $brushConv.ConvertFromString('#10B981')
            $HeaderStatusText.Text          = "Build $gb · Allineata (v$($m.versione))"
        } else {
            $TxtBuildMatchBanner.Text       = "⚡ Build gioco: $gb | Build dizionario: $($m.build) (Patching compatibile attivo)"
            $TxtBuildMatchBanner.Foreground = $brushConv.ConvertFromString('#FBBF24')
            $HeroCompatLabel.Text           = "TRADUZIONE v$($m.versione) · COMPATIBILE CON BUILD $gb"
            $HeroCompatIcon.Text            = [string][char]0xE946
            $HeroCompatIcon.Foreground      = $brushConv.ConvertFromString('#FBBF24')
            $HeaderStatusDot.Fill           = $brushConv.ConvertFromString('#F59E0B')
            $HeaderStatusText.Text          = "Build $gb rilevata · Patch v$($m.versione)"
        }
    } else {
        $TxtInstallPath.Text            = "Cartella non rilevata automaticamente (clicca 'Cambia percorso')"
        $TxtDetectedBuild.Text          = "N/D"
        $TxtBuildMatchBanner.Text       = "Seleziona la cartella di Aniimo per verificare la build."
        $TxtBuildMatchBanner.Foreground = $brushConv.ConvertFromString('#F43F5E')
        $HeroCompatLabel.Text           = "TRADUZIONE v$($m.versione) · BUILD $($m.build)"
        $HeaderStatusDot.Fill           = $brushConv.ConvertFromString('#F43F5E')
        $HeaderStatusText.Text          = "Cartella di gioco da selezionare"
    }
}

# ---------------------------------------------------------------------
#  Gestione Dizionario Bilingue Live (IT <-> EN)
# ---------------------------------------------------------------------
function Initialize-DictionaryData {
    if ($script:GlossaryLoaded) { return }
    $TxtDictionaryCount.Text = "Estrazione termini bilingue dall'archivio del gioco in corso..."
    Invoke-UiRefresh

    $saXdf = if ($script:CurrentGameDir) {
        Join-Path $script:CurrentGameDir 'Aniimo_Data\StreamingAssets\cvs\res\lua\LuaScripts.xdf'
    } else { '' }

    if ($saXdf -and (Test-Path -LiteralPath $saXdf) -and (Test-Path -LiteralPath $TsvPath)) {
        try {
            $script:GlossaryData = [AniimoFastPacker]::LoadGlossaryRecords($saXdf, $TsvPath)
            $script:GlossaryLoaded = $true
        } catch {
            $script:GlossaryData = New-Object 'System.Collections.Generic.List[GlossaryRecord]'
        }
    } else {
        $script:GlossaryData = New-Object 'System.Collections.Generic.List[GlossaryRecord]'
    }

    $CmbDictionaryCategory.Items.Clear()
    [void]$CmbDictionaryCategory.Items.Add('Tutte le categorie')
    foreach ($cat in @('Luoghi e Mappa', 'Abilità e Combattimento', 'Oggetti e Materiali', 'Camper e Arredo', 'Abbigliamento e Stile', 'Termini e Interfaccia')) {
        [void]$CmbDictionaryCategory.Items.Add($cat)
    }
    $CmbDictionaryCategory.SelectedIndex = 0
    Update-DictionaryFilter
}

function Update-DictionaryFilter {
    if (-not $script:GlossaryData) { return }
    $q = $TxtDictionarySearch.Text.Trim().ToLowerInvariant()
    $TxtDictionaryHint.Visibility = if ($q.Length -eq 0) { 'Visible' } else { 'Collapsed' }
    $selCat = [string]$CmbDictionaryCategory.SelectedItem
    $filterCat = ($selCat -and $selCat -ne 'Tutte le categorie')

    $filtered = New-Object 'System.Collections.Generic.List[GlossaryRecord]'
    foreach ($item in $script:GlossaryData) {
        if ($filterCat -and $item.CategoryName -ne $selCat) { continue }
        if ($q.Length -gt 0 -and (-not $item.SearchToken.Contains($q))) { continue }
        $filtered.Add($item)
    }
    $LvDictionaryTerms.ItemsSource = $filtered
    $cntFmt = Format-NumberDot ([string]$filtered.Count)
    $TxtDictionaryCount.Text = "$cntFmt termini trovati nel dizionario bilingue"
}

$TxtDictionarySearch.Add_TextChanged({ Update-DictionaryFilter })
$CmbDictionaryCategory.Add_SelectionChanged({ Update-DictionaryFilter })

# ---------------------------------------------------------------------
#  Eventi Navigazione Finestra e Schede Orizzontali
# ---------------------------------------------------------------------
$TopHeaderBar.Add_MouseLeftButtonDown({ $win.DragMove() })
$BtnMinimizeWin.Add_Click({ $win.WindowState = 'Minimized' })
$BtnCloseWin.Add_Click({ $win.Close() })

$TabDashboard.Add_Checked({
    $ViewDashboard.Visibility    = 'Visible'
    $ViewDictionary.Visibility   = 'Collapsed'
    $ViewArchitecture.Visibility = 'Collapsed'
})
$TabDictionary.Add_Checked({
    $ViewDashboard.Visibility    = 'Collapsed'
    $ViewDictionary.Visibility   = 'Visible'
    $ViewArchitecture.Visibility = 'Collapsed'
    Initialize-DictionaryData
})
$TabArchitecture.Add_Checked({
    $ViewDashboard.Visibility    = 'Collapsed'
    $ViewDictionary.Visibility   = 'Collapsed'
    $ViewArchitecture.Visibility = 'Visible'
})

$BtnSwitchSteam.Add_Click({
    if ($script:DetectedInstalls.ContainsKey('Steam')) {
        $script:CurrentGameDir = $script:DetectedInstalls['Steam']
        $script:GlossaryLoaded = $false
        Save-InstallerConfig $script:CurrentGameDir
        Update-UiDashboard
        Set-ProgressBarState 100 "Installazione attiva: Steam" $true
    }
})

$BtnSwitchPawPrint.Add_Click({
    if ($script:DetectedInstalls.ContainsKey('PawPrint')) {
        $script:CurrentGameDir = $script:DetectedInstalls['PawPrint']
        $script:GlossaryLoaded = $false
        Save-InstallerConfig $script:CurrentGameDir
        Update-UiDashboard
        Set-ProgressBarState 100 "Installazione attiva: PawPrint Launcher" $true
    }
})

$BtnOpenFolder.Add_Click({
    if ($script:CurrentGameDir -and (Test-Path -LiteralPath $script:CurrentGameDir)) {
        Start-Process explorer.exe -ArgumentList "`"$($script:CurrentGameDir)`""
    }
})

$BtnSelectFolder.Add_Click({
    $picked = Select-AniimoFolderDialog
    if ($picked) {
        $script:CurrentGameDir = $picked
        $script:GlossaryLoaded = $false
        Save-InstallerConfig $picked
        Update-UiDashboard
        Set-ProgressBarState 100 "Percorso di gioco aggiornato." $true
    } elseif ($picked -eq "") {
        [void](Show-PolarisDialog -Title "Cartella non valida" -Badge "ERRORE PERCORSO" -Severity "Error" -Messages @(
            "Nella cartella selezionata non è stato trovato l'archivio Aniimo_Data\StreamingAssets\cvs\res\lua\LuaScripts.xdf.",
            "Seleziona la cartella principale di Aniimo (es. C:\Program Files (x86)\Steam\steamapps\common\Aniimo)."
        ))
    }
})

$BtnLaunchGame.Add_Click({
    if (-not $script:CurrentGameDir) { return }
    try {
        $exePath = Join-Path $script:CurrentGameDir 'Aniimo.exe'
        $steamAcf = Join-Path (Split-Path -Parent (Split-Path -Parent $script:CurrentGameDir)) 'appmanifest_4126040.acf'
        if (Test-Path -LiteralPath $steamAcf) {
            Start-Process "steam://rungameid/4126040"
        } elseif (Test-Path -LiteralPath $exePath) {
            Start-Process -FilePath $exePath -WorkingDirectory $script:CurrentGameDir
        } else {
            Start-Process explorer.exe -ArgumentList "`"$($script:CurrentGameDir)`""
        }
    } catch {
        [void](Show-PolarisDialog -Title "Impossibile avviare il gioco" -Badge "ERRORE" -Severity "Error" -Messages @("Dettaglio: $($_.Exception.Message)"))
    }
})

$BtnCheckGitHub.Add_Click({
    if ($script:IsBusy) { return }
    $url = Get-RemoteRepoTsvUrl
    if (-not $url) {
        [void](Show-PolarisDialog -Title "Repository GitHub non configurato" -Badge "INFO" -Severity "Information" -Messages @(
            "La traduzione locale (v$($script:CurrentMeta.versione) · Build $($script:CurrentMeta.build)) è già presente e pronta all'uso in dati\traduzione_ita.tsv.",
            "Quando la cartella sarà collegata al repository GitHub remoto, questo pulsante verificherà in automatico eventuali aggiornamenti online."
        ))
        return
    }
    Set-ProgressBarState 40 "Verifica versione traduzione su GitHub in corso..." $false
    $upd = Update-TranslationTsvFromGitHub
    if ($upd.Status -eq 'Updated') {
        $script:GlossaryLoaded = $false
        Update-UiDashboard
        Set-ProgressBarState 100 "Traduzione aggiornata da GitHub (v$($script:CurrentMeta.versione))." $true
        [void](Show-PolarisDialog -Title "Nuova traduzione scaricata!" -Badge "AGGIORNATA" -Severity "Success" -Messages @(
            "È stata scaricata l'ultima versione di traduzione_ita.tsv da GitHub (v$($script:CurrentMeta.versione)):",
            "Build $($script:CurrentMeta.build) · $($script:CurrentMeta.voci_fmt) stringhe.",
            "$($script:CurrentMeta.changelog)",
            "Premi ora il pulsante azzurro in basso a destra per applicarla al gioco!"
        ))
    } elseif ($upd.Status -eq 'AlreadyUpToDate') {
        Set-ProgressBarState 100 "Traduzione locale già allineata (v$($script:CurrentMeta.versione))." $true
        [void](Show-PolarisDialog -Title "Traduzione già aggiornata" -Badge "ALLINEATA" -Severity "Information" -Messages @(
            "La traduzione locale (v$($script:CurrentMeta.versione) · Build $($script:CurrentMeta.build)) è già allineata all'ultima versione disponibile online."
        ))
    } else {
        Set-ProgressBarState 100 "Verifica aggiornamenti non riuscita." $false
        [void](Show-PolarisDialog -Title "Verifica aggiornamenti non riuscita" -Badge "ERRORE RETE" -Severity "Warning" -Messages @(
            "Non è stato possibile verificare gli aggiornamenti su GitHub.",
            "Assicurati che la connessione a Internet sia attiva e riprova.",
            "Dettaglio: $($upd.Message)"
        ))
    }
})

function Start-GuiInstallAction {
    if ($script:IsBusy) { return }
    if (-not $script:CurrentGameDir) {
        $picked = Select-AniimoFolderDialog
        if (-not $picked) {
            if ($picked -eq "") {
                [void](Show-PolarisDialog -Title "Cartella non valida" -Badge "ERRORE PERCORSO" -Severity "Error" -Messages @(
                    "Nella cartella selezionata non è stato trovato l'archivio Aniimo_Data\StreamingAssets\cvs\res\lua\LuaScripts.xdf.",
                    "Seleziona la cartella principale di Aniimo."
                ))
            }
            return
        }
        $script:CurrentGameDir = $picked
        Save-InstallerConfig $picked
        Update-UiDashboard
    }

    if (Test-AniimoRunning) {
        [void](Show-PolarisDialog -Title "Aniimo è in esecuzione" -Badge "GIOCO APERTO" -Severity "Warning" -Messages @(
            "Chiudi Aniimo prima di installare o aggiornare la traduzione italiana, altrimenti i file di gioco risulteranno bloccati."
        ))
        return
    }

    if (-not (Test-GameDirWritable $script:CurrentGameDir)) {
        $ans = Show-PolarisDialog -Title "Permessi di Amministratore richiesti" -Badge "PERMESSI UAC" -Buttons "YesNo" -Severity "Question" -Messages @(
            "La cartella di installazione di Aniimo richiede i permessi di Amministratore per modificare i file.",
            "Vuoi riavviare automaticamente l'installer come Amministratore e completare l'installazione?"
        )
        if ($ans -eq 'Yes') {
            if (Request-GuiElevation $script:CurrentGameDir '-GuiAutoInstall') {
                $win.Close()
                return
            }
        } else {
            return
        }
    }

    $script:IsBusy = $true
    $BtnApplyPatch.IsEnabled      = $false
    $BtnRestoreOriginal.IsEnabled = $false
    try {
        $upd = Update-TranslationTsvFromGitHub -Silent
        if ($upd -and $upd.Success) {
            Update-UiDashboard
        }
        $res = Invoke-TranslationInstall $script:CurrentGameDir $script:CurrentMeta {
            param($p, $msg)
            Set-ProgressBarState $p $msg ($p -ge 100)
        }
        Update-UiDashboard
        $fmtCount = Format-NumberDot ([string]$res.Translated)
        [void](Show-PolarisDialog -Title "Traduzione Italiana Installata!" -Badge "COMPLETATO" -Severity "Success" -Messages @(
            "La traduzione italiana v$($script:CurrentMeta.versione) ($fmtCount stringhe) è stata compilata e attivata con successo!",
            "✔ Allineata alla Build del gioco: $($res.BuildNum)",
            "✔ Avvia pure Aniimo: il gioco partirà direttamente in ITALIANO (lascia pure English nelle impostazioni)."
        ))
    } catch {
        Set-ProgressBarState 0 "Errore durante l'installazione." $false
        [void](Show-PolarisDialog -Title "Errore durante l'installazione" -Badge "ERRORE" -Severity "Error" -Messages @(
            "Si è verificato un problema durante l'installazione:",
            "$($_.Exception.Message)"
        ))
    } finally {
        $script:IsBusy = $false
        $BtnApplyPatch.IsEnabled = $true
        Update-UiDashboard
    }
}

function Start-GuiRestoreAction {
    if ($script:IsBusy -or -not $script:CurrentGameDir) { return }
    if (Test-AniimoRunning) {
        [void](Show-PolarisDialog -Title "Aniimo è in esecuzione" -Badge "GIOCO APERTO" -Severity "Warning" -Messages @(
            "Chiudi Aniimo prima di ripristinare la lingua originale inglese."
        ))
        return
    }

    $ans = Show-PolarisDialog -Title "Ripristinare la lingua originale inglese?" -Badge "CONFERMA" -Buttons "YesNo" -Severity "Question" -Messages @(
        "Vuoi rimuovere la traduzione italiana e ripristinare i file originali in Inglese dalla cartella StreamingAssets?"
    )
    if ($ans -ne 'Yes') { return }

    if (-not (Test-GameDirWritable $script:CurrentGameDir)) {
        if (Request-GuiElevation $script:CurrentGameDir '-GuiAutoRestore') {
            $win.Close()
            return
        }
    }

    $script:IsBusy = $true
    $BtnApplyPatch.IsEnabled      = $false
    $BtnRestoreOriginal.IsEnabled = $false
    try {
        Invoke-TranslationRestore $script:CurrentGameDir {
            param($p, $msg)
            Set-ProgressBarState $p $msg ($p -ge 100)
        }
        Update-UiDashboard
        [void](Show-PolarisDialog -Title "Lingua Inglese Ripristinata" -Badge "RIPRISTINATO" -Severity "Information" -Messages @(
            "I file originali in lingua inglese sono stati ripristinati correttamente."
        ))
    } catch {
        Set-ProgressBarState 0 "Errore durante il ripristino." $false
        [void](Show-PolarisDialog -Title "Errore durante il ripristino" -Badge "ERRORE" -Severity "Error" -Messages @(
            "$($_.Exception.Message)"
        ))
    } finally {
        $script:IsBusy = $false
        $BtnApplyPatch.IsEnabled = $true
        Update-UiDashboard
    }
}

$BtnApplyPatch.Add_Click({ Start-GuiInstallAction })
$BtnRestoreOriginal.Add_Click({ Start-GuiRestoreAction })

Update-UiDashboard

if ($InitialTab -eq 'Dictionary') {
    $TabDictionary.IsChecked = $true
} elseif ($InitialTab -eq 'Architecture') {
    $TabArchitecture.IsChecked = $true
}

if ($ExportPreview -or $GuiAutoInstall -or $GuiAutoRestore) {
    $win.Add_ContentRendered({
        if ($ExportPreview) {
            Invoke-UiRefresh
            Start-Sleep -Milliseconds 350
            Invoke-UiRefresh
            $dpi = 96
            $w = [int]$win.ActualWidth
            $h = [int]$win.ActualHeight
            $rtb = New-Object System.Windows.Media.Imaging.RenderTargetBitmap($w, $h, $dpi, $dpi, [System.Windows.Media.PixelFormats]::Pbgra32)
            $rtb.Render($win)
            $enc = New-Object System.Windows.Media.Imaging.PngBitmapEncoder
            $enc.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($rtb))
            $fs = [System.IO.File]::Open($ExportPreview, [System.IO.FileMode]::Create)
            try { $enc.Save($fs) } finally { $fs.Close() }
            $win.Close()
        } elseif ($GuiAutoInstall) {
            Start-GuiInstallAction
        } elseif ($GuiAutoRestore) {
            Start-GuiRestoreAction
        }
    })
} else {
    try {
        $initTsvTime = if (Test-Path -LiteralPath $TsvPath) { (Get-Item -LiteralPath $TsvPath).LastWriteTimeUtc } else { [DateTime]::MinValue }
        Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`" -UpdateTsv" -WindowStyle Hidden

        $script:BgPollCount = 0
        $bgTimer = New-Object System.Windows.Threading.DispatcherTimer
        $bgTimer.Interval = [TimeSpan]::FromSeconds(2)
        $bgTimer.Add_Tick({
            $script:BgPollCount++
            if (Test-Path -LiteralPath $TsvPath) {
                $currTime = (Get-Item -LiteralPath $TsvPath).LastWriteTimeUtc
                if ($currTime -gt $initTsvTime) {
                    $bgTimer.Stop()
                    $script:CurrentMeta = Get-TsvMetadata $TsvPath
                    $script:GlossaryLoaded = $false
                    Update-UiDashboard
                    Set-ProgressBarState 100 "Nuova versione traduzione v$($script:CurrentMeta.versione) scaricata da GitHub! Clicca su Installa per applicarla." $true
                    return
                }
            }
            if ($script:BgPollCount -ge 15) {
                $bgTimer.Stop()
            }
        })
        $bgTimer.Start()
    } catch {}
}

[void]$win.ShowDialog()
