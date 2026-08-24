#Requires -Version 5.1
<#
.SYNOPSIS
  Generates AI_REPO_INDEX v2 from the current Git tracked source tree.
.DESCRIPTION
  This script uses `git ls-files` to build a deterministic index of all
  tracked source files, excluding AI-generated index/skill artifacts and
  Vivado generated build directories.
  Output is written to AI_REPO_INDEX/ in the repository root.
.NOTES
  Must be run from the Git repository root (or any subdirectory).
  Supports UTF-8 paths including Chinese characters.
  All Git-path operations use forward slash (/) exclusively.
#>

$ErrorActionPreference = "Stop"

# Resolve repository root from Git
$repoRoot = (git rev-parse --show-toplevel).Trim()
if (-not $repoRoot) {
    Write-Error "Not inside a Git repository."
    exit 1
}
Set-Location $repoRoot

$indexDir = Join-Path $repoRoot "AI_REPO_INDEX"
if (-not (Test-Path $indexDir)) {
    New-Item -ItemType Directory -Path $indexDir -Force | Out-Null
}

# Clean old index files
Get-ChildItem -Path $indexDir -File | Remove-Item -Force

# ── Exclusion patterns (AI artifacts that should not be in the source index) ──
$excludePrefixes = @(
    "AI_REPO_INDEX/",
    ".trae/skills/ax7035b-learning/",
    ".trae/.ignore",
    "AX7035B_AI_Skill.md"
)

# ── Generated artifact path-segment patterns ──
$generatedExactSegments = @(".Xil", "ip_user_files", "xsim.dir")
$generatedSuffixes = @(".runs", ".cache", ".hw", ".sim", ".gen", ".ip_user_files")

function Should-Exclude($path) {
    foreach ($prefix in $excludePrefixes) {
        if ($path.StartsWith($prefix)) { return $true }
    }
    return $false
}

function Test-GeneratedPath($path) {
    $segments = $path -split "/"
    foreach ($seg in $segments) {
        if ($generatedExactSegments -contains $seg) { return $true }
        foreach ($suffix in $generatedSuffixes) {
            if ($seg.EndsWith($suffix)) { return $true }
        }
    }
    return $false
}

function Should-Index($path) {
    if (Should-Exclude $path) { return $false }
    if (Test-GeneratedPath $path) { return $false }
    return $true
}

# ── Category classification ──
function Get-Category($ext) {
    switch ($ext) {
        ".v"       { "HDL Source" }
        ".sv"      { "HDL Source" }
        ".vh"      { "HDL Source" }
        ".vhd"     { "HDL Source" }
        ".vhdl"    { "HDL Source" }
        ".xdc"     { "Constraint" }
        ".ucf"     { "Constraint" }
        ".xpr"     { "Vivado Project" }
        ".xci"     { "IP Core" }
        ".bd"      { "IP Core" }
        ".bxml"    { "IP Core" }
        ".tcl"     { "TCL Script" }
        ".coe"     { "Memory Init" }
        ".mem"     { "Memory Init" }
        ".mif"     { "Memory Init" }
        ".c"       { "C/C++ Source" }
        ".h"       { "C/C++ Source" }
        ".cpp"     { "C/C++ Source" }
        ".pdf"     { "PDF Document" }
        ".bit"     { "Bitstream" }
        ".bin"     { "Bitstream" }
        ".bmp"     { "Image" }
        ".png"     { "Image" }
        ".jpg"     { "Image" }
        ".wav"     { "Audio" }
        ".md"      { "Markdown" }
        ".txt"     { "Text" }
        ".xls"     { "Data File" }
        ".xlsx"    { "Data File" }
        ".csv"     { "Data File" }
        ".tsv"     { "Data File" }
        ".gitignore" { "Config" }
        ".gitattributes" { "Config" }
        default    { "Other" }
    }
}

# ── Importance classification ──
function Get-Importance($path, $ext, $category) {
    if ($ext -eq ".pdf" -and $path -match "用户手册|检测指南|原理图|datasheet|芯片手册") { return "Critical" }
    if ($ext -eq ".xpr") { return "Critical" }
    if ($ext -eq ".xci") { return "High" }
    if ($ext -eq ".xdc" -or $ext -eq ".ucf") { return "High" }
    if ($category -eq "HDL Source") { return "High" }
    if ($ext -eq ".tcl") { return "Medium" }
    if ($category -eq "C/C++ Source") { return "Medium" }
    if ($category -eq "Memory Init") { return "Medium" }
    if ($ext -eq ".md" -or $ext -eq ".txt") { return "Medium" }
    return "Normal"
}

# ── IP purpose mapping from componentRef name ──
function Get-IPPurpose($componentName) {
    switch -Wildcard ($componentName) {
        "clk_wiz*"        { "Clock generation (PLL/MMCM)" }
        "mig_7series*"    { "DDR3 memory controller" }
        "fifo_generator*" { "FIFO buffering" }
        "blk_mem_gen*"    { "Block RAM / ROM" }
        "ila*"            { "Integrated Logic Analyzer (debug)" }
        "vio*"            { "Virtual IO (debug)" }
        "dds_compiler*"   { "DDS waveform generation" }
        "dist_mem_gen*"   { "Distributed RAM / ROM" }
        "xlconstant*"     { "Constant generator" }
        "util_vector_logic*" { "Logic functions" }
        "system_cache*"   { "Cache controller" }
        "axi_*"           { "AXI interface IP" }
        "lmb_*"           { "MicroBlaze local bus" }
        "microblaze*"     { "MicroBlaze processor" }
        "proc_sys_reset*" { "Processor system reset" }
        "smartconnect*"   { "AXI interconnect" }
        "interrupt_controller*" { "Interrupt controller" }
        "mdm*"            { "MicroBlaze debug module" }
        default           { "UNKNOWN" }
    }
}

# ── Extract top module from XPR file ──
function Get-TopModuleFromXPR($xprGitPath) {
    $fullPath = Join-Path $repoRoot $xprGitPath
    $result = @{ TopModule = ""; Evidence = ""; Confidence = "LOW" }
    try {
        $content = [System.IO.File]::ReadAllText($fullPath, [System.Text.Encoding]::UTF8)
        # Extract TopModule from sources_1 FileSet (not sim_1)
        if ($content -match '(?s)<FileSet\s+Name="sources_1"[^>]*>(.*?)</FileSet>') {
            $sourcesBlock = $matches[1]
            if ($sourcesBlock -match '<Option\s+Name="TopModule"\s+Val="([^"]+)"') {
                $result.TopModule = $matches[1]
                $result.Evidence = "XPR property (sources_1/TopModule)"
                $result.Confidence = "HIGH"
                return $result
            }
        }
        # Fallback: try any FileSet with TopModule (less reliable)
        if ($content -match '<Option\s+Name="TopModule"\s+Val="([^"]+)"') {
            $result.TopModule = $matches[1]
            $result.Evidence = "XPR property (unspecified FileSet)"
            $result.Confidence = "MEDIUM"
            return $result
        }
    } catch {}
    return $result
}

# ── Extract componentRef from XCI file ──
function Get-IPInfoFromXCI($xciGitPath) {
    $fullPath = Join-Path $repoRoot $xciGitPath
    $result = @{ ComponentName = ""; Version = ""; InstanceName = "" }
    try {
        $content = [System.IO.File]::ReadAllText($fullPath, [System.Text.Encoding]::UTF8)
        if ($content -match 'spirit:componentRef[^>]*spirit:name="([^"]+)"[^>]*spirit:version="([^"]+)"') {
            $result.ComponentName = $matches[1]
            $result.Version = $matches[2]
        }
        if ($content -match '<spirit:instanceName>([^<]+)</spirit:instanceName>') {
            $result.InstanceName = $matches[1]
        }
    } catch {}
    return $result
}

# ── Analyze XDC/UCF content ──
function Analyze-ConstraintFile($gitPath) {
    $fullPath = Join-Path $repoRoot $gitPath
    $result = @{ ClockConstraints = "NONE"; PinConstraints = "NONE"; IOSTANDARD = "UNKNOWN" }
    try {
        $rawContent = [System.IO.File]::ReadAllText($fullPath, [System.Text.Encoding]::UTF8)
        # Strip comment lines (XDC: lines starting with #, UCF: lines starting with #)
        $lines = $rawContent -split "`n" | Where-Object { $_ -notmatch '^\s*#' }
        $content = $lines -join "`n"
        $clockCount = ([regex]::Matches($content, 'create_clock\b')).Count
        $clockCount += ([regex]::Matches($content, 'TIMESPEC\s+TS_\w+\s*=\s*PERIOD')).Count
        $pinCount = ([regex]::Matches($content, 'PACKAGE_PIN\b')).Count
        $pinCount += ([regex]::Matches($content, '\bLOC\s*=')).Count
        $iostdMatches = [regex]::Matches($content, 'IOSTANDARD\s+(\S+)') | ForEach-Object {
            $_.Groups[1].Value.Trim('{}[]')
        } | Sort-Object -Unique
        if ($clockCount -gt 0) { $result.ClockConstraints = "YES($clockCount)" }
        if ($pinCount -gt 0) { $result.PinConstraints = "YES($pinCount)" }
        if ($iostdMatches) {
            $result.IOSTANDARD = ($iostdMatches -join ",")
        }
    } catch {}
    return $result
}

# ── Get all tracked files ──
Write-Host "Reading git ls-files..."
$allFiles = git ls-files
$generatedCount = 0
$indexedFiles = [System.Collections.Generic.List[string]]::new()
foreach ($f in $allFiles) {
    if (Test-GeneratedPath $f) {
        $generatedCount++
    }
    if (Should-Index $f) {
        $indexedFiles.Add($f)
    }
}
Write-Host "Total tracked: $($allFiles.Count), Generated: $generatedCount, Indexed: $($indexedFiles.Count)"

# ── Sort deterministically ──
$indexedFiles = $indexedFiles | Sort-Object

# ── Build directory list (parent dirs only, unique, sorted) ──
$dirSet = [System.Collections.Generic.HashSet[string]]::new()
foreach ($f in $indexedFiles) {
    $idx = $f.LastIndexOf("/")
    if ($idx -gt 0) {
        $dirSet.Add($f.Substring(0, $idx)) | Out-Null
    }
}
$dirList = $dirSet | Sort-Object

# ── Build file info list ──
$fileInfos = [System.Collections.Generic.List[object]]::new()
foreach ($f in $indexedFiles) {
    $slashIdx = $f.LastIndexOf("/")
    $fileName = if ($slashIdx -ge 0) { $f.Substring($slashIdx + 1) } else { $f }
    $ext = [System.IO.Path]::GetExtension($f).ToLower()
    $dir = if ($slashIdx -gt 0) { $f.Substring(0, $slashIdx) } else { "" }
    $category = Get-Category $ext
    $importance = Get-Importance $f $ext $category

    $project = ""
    if ($f -match "^01_demo_document/demo/([^/]+)") {
        $project = $matches[1]
    } elseif ($f -match "^09_microblaze/([^/]+)") {
        $project = $matches[1]
    } elseif ($f -match "^其它FPGA相关资料/([^/]+)") {
        $project = $matches[1]
    } else {
        $project = "(root)"
    }

    $fileInfos.Add([PSCustomObject]@{
        Path = $f
        Directory = $dir
        FileName = $fileName
        Extension = $ext
        Category = $category
        Project = $project
        Importance = $importance
    })
}

# ── Get current HEAD and LFS count ──
$headSha = (git rev-parse HEAD).Trim()
$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

$lfsCount = "NOT_CHECKED"
try {
    $lfsResult = git lfs ls-files 2>$null
    if ($LASTEXITCODE -eq 0 -and $lfsResult) {
        $lfsCount = @($lfsResult | Where-Object { $_.Trim() }).Count
    } else {
        $lfsCount = 0
    }
} catch {
    $lfsCount = "NOT_CHECKED"
}

# ── Write REPO_REVISION.txt ──
$revFile = Join-Path $indexDir "REPO_REVISION.txt"
@"
RepositoryHeadAtGeneration=$headSha
IndexedSourceCommit=$headSha
GeneratedAt=$timestamp
IndexMethod=git ls-files
IndexScope=tracked source corpus excluding AI-generated index/skill artifacts and Vivado generated directories
IndexExcludes=AI_REPO_INDEX/**, .trae/skills/ax7035b-learning/**, AX7035B_AI_Skill.md
GeneratedArtifactsCurrentlyTracked=$generatedCount
Phase3HistoricalGeneratedArtifactsRemoved=9504
TotalIndexedFiles=$($indexedFiles.Count)
TotalDirectories=$($dirList.Count)
"@ | Out-File -FilePath $revFile -Encoding UTF8

# ── Write REPO_DIRS.txt ──
$dirsFile = Join-Path $indexDir "REPO_DIRS.txt"
$dirList | Out-File -FilePath $dirsFile -Encoding UTF8

# ── Write REPO_FILES.tsv ──
$filesTsv = Join-Path $indexDir "REPO_FILES.tsv"
$filesLines = [System.Collections.Generic.List[string]]::new()
$filesLines.Add("Path`tDirectory`tFileName`tExtension`tSizeBytes`tCategory`tProject`tImportance")
foreach ($fi in $fileInfos) {
    $fullPath = Join-Path $repoRoot $fi.Path
    $size = 0
    try { $size = (Get-Item -LiteralPath $fullPath -ErrorAction Stop).Length } catch {}
    $filesLines.Add("$($fi.Path)`t$($fi.Directory)`t$($fi.FileName)`t$($fi.Extension)`t$size`t$($fi.Category)`t$($fi.Project)`t$($fi.Importance)")
}
$filesLines | Out-File -FilePath $filesTsv -Encoding UTF8

# ── Write EXPERIMENTS.txt ──
$expFile = Join-Path $indexDir "EXPERIMENTS.txt"
$expLines = [System.Collections.Generic.List[string]]::new()
$expLines.Add("# Demo Experiment Index")
$expLines.Add("# Only project directories with .xpr are listed. Loose assets (BMP/WAV) are NOT experiments.")
$expLines.Add("# Generated: $timestamp")
$expLines.Add("")

$demoRoot = "01_demo_document/demo"
$demoProjects = @{}

foreach ($fi in $fileInfos) {
    if ($fi.Path.StartsWith($demoRoot + "/")) {
        $relPath = $fi.Path.Substring($demoRoot.Length + 1)
        $parts = $relPath -split "/"
        if ($parts.Count -ge 2) {
            $demoName = $parts[0]
            if (-not $demoProjects.ContainsKey($demoName)) {
                $demoProjects[$demoName] = @{ XPR = @(); HDL = 0; XDC = 0; XCI = 0; TCL = 0 }
            }
            if ($fi.Extension -eq ".xpr") {
                $demoProjects[$demoName].XPR += $fi.Path
            }
            if ($fi.Category -eq "HDL Source") { $demoProjects[$demoName].HDL++ }
            if ($fi.Category -eq "Constraint") { $demoProjects[$demoName].XDC++ }
            if ($fi.Category -eq "IP Core") { $demoProjects[$demoName].XCI++ }
            if ($fi.Category -eq "TCL Script") { $demoProjects[$demoName].TCL++ }
        }
    }
}

# Check demo_test directory
$demoTestDir = "demo_test"
$demoTestExists = $false
foreach ($fi in $fileInfos) {
    if ($fi.Path.StartsWith($demoTestDir + "/")) {
        if (-not $demoProjects.ContainsKey($demoTestDir)) {
            $demoProjects[$demoTestDir] = @{ XPR = @(); HDL = 0; XDC = 0; XCI = 0; TCL = 0 }
            $demoTestExists = $true
        }
        if ($fi.Extension -eq ".xpr") {
            $demoProjects[$demoTestDir].XPR += $fi.Path
        }
        if ($fi.Category -eq "HDL Source") { $demoProjects[$demoTestDir].HDL++ }
        if ($fi.Category -eq "Constraint") { $demoProjects[$demoTestDir].XDC++ }
        if ($fi.Category -eq "IP Core") { $demoProjects[$demoTestDir].XCI++ }
        if ($fi.Category -eq "TCL Script") { $demoProjects[$demoTestDir].TCL++ }
    }
}

$expLines.Add("DemoName`tRepoPath`tXPR`tHDLCount`tConstraintCount`tIPCount`tTCLCount`tStatus")
foreach ($name in ($demoProjects.Keys | Sort-Object)) {
    $info = $demoProjects[$name]
    $repoPath = "$demoRoot/$name"
    if ($name -eq $demoTestDir) { $repoPath = $demoTestDir }
    $xprPath = if ($info.XPR.Count -gt 0) { $info.XPR[0] } else { "NONE" }
    $status = if ($info.XPR.Count -gt 0) { "COMPLETE" } elseif ($name -eq $demoTestDir) { "SPECIAL_NO_XPR" } else { "MISSING_XPR" }
    $expLines.Add("$name`t$repoPath`t$xprPath`t$($info.HDL)`t$($info.XDC)`t$($info.XCI)`t$($info.TCL)`t$status")
}
$expLines | Out-File -FilePath $expFile -Encoding UTF8

$demoCount = $demoProjects.Count
$actualXprCount = ($fileInfos | Where-Object { $_.Extension -eq ".xpr" }).Count

# ── Write FPGA_PROJECTS.txt ──
Write-Host "Generating FPGA_PROJECTS.txt (parsing XPR files for top module)..."
$fpgaFile = Join-Path $indexDir "FPGA_PROJECTS.txt"
$fpgaLines = [System.Collections.Generic.List[string]]::new()
$fpgaLines.Add("# FPGA Vivado Project Index")
$fpgaLines.Add("# Each project has at least one .xpr file")
$fpgaLines.Add("# Generated: $timestamp")
$fpgaLines.Add("")

$xprFiles = $fileInfos | Where-Object { $_.Extension -eq ".xpr" } | Sort-Object Path
$fpgaLines.Add("ProjectName`tXPRPath`tProjectRoot`tDemo`tHDLCount`tConstraintCount`tIPCount`tBDCount`tTopModule`tTopModuleEvidence")
foreach ($xpr in $xprFiles) {
    # Use forward-slash path operations (NOT Split-Path which uses backslash on Windows)
    $slashIdx = $xpr.Path.LastIndexOf("/")
    $projRoot = if ($slashIdx -gt 0) { $xpr.Path.Substring(0, $slashIdx) } else { "" }
    $projName = [System.IO.Path]::GetFileNameWithoutExtension($xpr.FileName)
    $demo = $xpr.Project

    # Count source files using forward-slash prefix matching
    $projPrefix = if ($projRoot) { "$projRoot/" } else { "" }
    $projFiles = $fileInfos | Where-Object {
        ($_.Path.StartsWith($projPrefix) -or $_.Path -eq $xpr.Path)
    }
    $hdlCount = @($projFiles | Where-Object { $_.Category -eq "HDL Source" }).Count
    $constraintCount = @($projFiles | Where-Object { $_.Category -eq "Constraint" }).Count
    $ipCount = @($projFiles | Where-Object { $_.Extension -eq ".xci" }).Count
    $bdCount = @($projFiles | Where-Object { $_.Extension -eq ".bd" }).Count

    # Extract top module from XPR
    $topResult = Get-TopModuleFromXPR $xpr.Path
    $topModule = $topResult.TopModule
    if (-not $topModule) { $topModule = "UNKNOWN" }
    $topEvidence = if ($topResult.Evidence) { $topResult.Evidence } else { "Not determined - requires XPR property or TCL inspection" }

    $fpgaLines.Add("$projName`t$($xpr.Path)`t$projRoot`t$demo`t$hdlCount`t$constraintCount`t$ipCount`t$bdCount`t$topModule`t$topEvidence")
}
$fpgaLines | Out-File -FilePath $fpgaFile -Encoding UTF8

# ── Write HDL_TOP_MODULES.txt ──
Write-Host "Generating HDL_TOP_MODULES.txt..."
$hdlFile = Join-Path $indexDir "HDL_TOP_MODULES.txt"
$hdlLines = [System.Collections.Generic.List[string]]::new()
$hdlLines.Add("# HDL Top Module Index")
$hdlLines.Add("# Top modules identified from XPR properties and project source context")
$hdlLines.Add("# Generated: $timestamp")
$hdlLines.Add("")
$hdlLines.Add("Project`tTopModule`tSourceFile`tEvidence`tConfidence")

foreach ($xpr in $xprFiles) {
    $projName = [System.IO.Path]::GetFileNameWithoutExtension($xpr.FileName)

    $topResult = Get-TopModuleFromXPR $xpr.Path
    $topModule = $topResult.TopModule
    $evidence = $topResult.Evidence
    $confidence = $topResult.Confidence

    if (-not $topModule -or $topModule -eq "") {
        # Fallback: filename convention
        $slashIdx = $xpr.Path.LastIndexOf("/")
        $projRoot = if ($slashIdx -gt 0) { $xpr.Path.Substring(0, $slashIdx) } else { "" }
        $projPrefix = if ($projRoot) { "$projRoot/" } else { "" }
        $projFiles = $fileInfos | Where-Object { $_.Path.StartsWith($projPrefix) -and $_.Category -eq "HDL Source" }

        $topCandidates = $projFiles | Where-Object {
            $_.FileName -match "^(top|top_module)\." -or
            $_.FileName -match "^${projName}\.(v|sv|vhd|vhdl)$" -or
            $_.FileName -match "^(top)\.(v|sv|vhd|vhdl)$"
        } | Sort-Object Path

        if ($topCandidates -and $topCandidates.Count -gt 0) {
            $top = $topCandidates | Select-Object -First 1
            # Module name = filename without extension
            $topModule = [System.IO.Path]::GetFileNameWithoutExtension($top.FileName)
            $evidence = "Filename match + project source context"
            $confidence = "MEDIUM"
            $hdlLines.Add("$projName`t$topModule`t$($top.Path)`t$evidence`t$confidence")
        } else {
            $hdlLines.Add("$projName`tUNKNOWN`tN/A`tNo top module found in XPR or by name convention`tLOW")
        }
    } else {
        # Find the source file for the top module
        $slashIdx = $xpr.Path.LastIndexOf("/")
        $projRoot = if ($slashIdx -gt 0) { $xpr.Path.Substring(0, $slashIdx) } else { "" }
        $projPrefix = if ($projRoot) { "$projRoot/" } else { "" }
        $projFiles = $fileInfos | Where-Object { $_.Path.StartsWith($projPrefix) -and $_.Category -eq "HDL Source" }

        $sourceFile = "N/A"
        $matchedFile = $projFiles | Where-Object {
            [System.IO.Path]::GetFileNameWithoutExtension($_.FileName) -eq $topModule
        } | Select-Object -First 1
        if ($matchedFile) {
            $sourceFile = $matchedFile.Path
        }

        $hdlLines.Add("$projName`t$topModule`t$sourceFile`t$evidence`t$confidence")
    }
}
$hdlLines | Out-File -FilePath $hdlFile -Encoding UTF8

# ── Write CONSTRAINT_FILES.txt ──
Write-Host "Generating CONSTRAINT_FILES.txt (parsing XDC/UCF content)..."
$constFile = Join-Path $indexDir "CONSTRAINT_FILES.txt"
$constLines = [System.Collections.Generic.List[string]]::new()
$constLines.Add("# Constraint File Index (.xdc and .ucf)")
$constLines.Add("# Generated: $timestamp")
$constLines.Add("")
$constLines.Add("ConstraintPath`tAssociatedProject`tPurpose`tClockConstraints`tPinConstraints`tIOSTANDARD`tNotes")

$constFiles = $fileInfos | Where-Object { $_.Extension -eq ".xdc" -or $_.Extension -eq ".ucf" } | Sort-Object Path
foreach ($c in $constFiles) {
    $projName = $c.Project
    $purpose = "Pin assignment and timing"
    $notes = ""

    $analysis = Analyze-ConstraintFile $c.Path
    $clockStr = $analysis.ClockConstraints
    $pinStr = $analysis.PinConstraints
    $iostdStr = $analysis.IOSTANDARD

    $constLines.Add("$($c.Path)`t$projName`t$purpose`t$clockStr`t$pinStr`t$iostdStr`t$notes")
}
$constLines | Out-File -FilePath $constFile -Encoding UTF8

# ── Write IP_CORES.txt ──
Write-Host "Generating IP_CORES.txt (parsing XCI content)..."
$ipFile = Join-Path $indexDir "IP_CORES.txt"
$ipLines = [System.Collections.Generic.List[string]]::new()
$ipLines.Add("# IP Core Index (.xci and .bd)")
$ipLines.Add("# Generated: $timestamp")
$ipLines.Add("")
$ipLines.Add("Project`tIPName`tIPType`tXCIPath`tBDPath`tPurpose`tEvidence")

$ipFiles = $fileInfos | Where-Object { $_.Extension -eq ".xci" -or $_.Extension -eq ".bd" } | Sort-Object Path
foreach ($ip in $ipFiles) {
    $ipName = [System.IO.Path]::GetFileNameWithoutExtension($ip.FileName)
    $ipType = if ($ip.Extension -eq ".xci") { "XCI" } else { "BD" }
    $xciPath = if ($ip.Extension -eq ".xci") { $ip.Path } else { "" }
    $bdPath = if ($ip.Extension -eq ".bd") { $ip.Path } else { "" }

    $purpose = "UNKNOWN"
    $evidence = "Repository tracked file"
    if ($ip.Extension -eq ".xci") {
        $ipInfo = Get-IPInfoFromXCI $ip.Path
        if ($ipInfo.ComponentName) {
            $purpose = Get-IPPurpose $ipInfo.ComponentName
            $evidence = "XCI componentRef: $($ipInfo.ComponentName) v$($ipInfo.Version)"
            if ($purpose -eq "UNKNOWN" -and $ipInfo.ComponentName -ne "unknown") {
                $purpose = "$($ipInfo.ComponentName) (unclassified)"
            }
        }
    }

    $ipLines.Add("$($ip.Project)`t$ipName`t$ipType`t$xciPath`t$bdPath`t$purpose`t$evidence")
}
$ipLines | Out-File -FilePath $ipFile -Encoding UTF8

# ── Write MICROBLAZE_PROJECTS.txt ──
$mbFile = Join-Path $indexDir "MICROBLAZE_PROJECTS.txt"
$mbLines = [System.Collections.Generic.List[string]]::new()
$mbLines.Add("# MicroBlaze Project Index")
$mbLines.Add("# Based on 09_microblaze directory content")
$mbLines.Add("# Generated: $timestamp")
$mbLines.Add("")
$mbLines.Add("ProjectPath`tCategory`tFileType`tFilePath`tNotes")

$mbFiles = $fileInfos | Where-Object { $_.Path.StartsWith("09_microblaze/") } | Sort-Object Path
foreach ($mf in $mbFiles) {
    $cat = "unknown"
    $parts = $mf.Path -split "/"
    if ($parts -contains "src" -or $parts -contains "source") { $cat = "C/H source" }
    elseif ($parts -contains "bsp") { $cat = "BSP" }
    elseif ($parts -contains "data") { $cat = "linker/config" }
    elseif ($mf.Extension -eq ".xpr") { $cat = "hardware design" }
    elseif ($mf.Extension -eq ".c" -or $mf.Extension -eq ".h") { $cat = "C/H source" }
    elseif ($mf.Extension -eq ".tcl") { $cat = "build script" }
    elseif ($mf.Extension -eq ".xml" -or $mf.Extension -eq ".mss" -or $mf.Extension -eq ".mhs") { $cat = "linker/config" }
    $mbLines.Add("$($mf.Path)`t$cat`t$($mf.Extension)`t$($mf.Path)`t")
}
$mbLines | Out-File -FilePath $mbFile -Encoding UTF8

# ── Write IMPORTANT_FILES.txt ──
$impFile = Join-Path $indexDir "IMPORTANT_FILES.txt"
$impLines = [System.Collections.Generic.List[string]]::new()
$impLines.Add("# Important Files by Learning Value")
$impLines.Add("# Organized by topic for learning navigation")
$impLines.Add("# Generated: $timestamp")
$impLines.Add("")

$topics = [ordered]@{
    "Board Manuals" = @("用户手册","检测指南","开发板")
    "Schematics" = @("原理图","PCB","结构图")
    "FPGA Device Docs" = @("芯片手册","datasheet","7a35t","artix")
    "Vivado Projects" = @()
    "Top RTL" = @()
    "Constraints" = @()
    "IP Configurations" = @()
    "Tutorials" = @("教程","学习")
}

$impLines.Add("Topic`tPath`tReason`tRelatedDemo")
foreach ($topic in $topics.Keys) {
    $patterns = $topics[$topic]
    $matched = $false
    if ($topic -eq "Vivado Projects") {
        $xprList = $fileInfos | Where-Object { $_.Extension -eq ".xpr" } | Sort-Object Path
        foreach ($x in $xprList) {
            $impLines.Add("$topic`t$($x.Path)`tVivado project file`t$($x.Project)")
            $matched = $true
        }
    } elseif ($topic -eq "Top RTL") {
        $topFiles = $fileInfos | Where-Object { $_.FileName -match "^(top|top_module)\." -and $_.Category -eq "HDL Source" } | Sort-Object Path
        foreach ($t in $topFiles) {
            $impLines.Add("$topic`t$($t.Path)`tTop-level HDL module`t$($t.Project)")
            $matched = $true
        }
    } elseif ($topic -eq "Constraints") {
        $xdcFiles = $fileInfos | Where-Object { $_.Extension -eq ".xdc" } | Sort-Object Path | Select-Object -First 30
        foreach ($x in $xdcFiles) {
            $impLines.Add("$topic`t$($x.Path)`tConstraint file`t$($x.Project)")
            $matched = $true
        }
    } elseif ($topic -eq "IP Configurations") {
        $xciFiles = $fileInfos | Where-Object { $_.Extension -eq ".xci" } | Sort-Object Path | Select-Object -First 30
        foreach ($x in $xciFiles) {
            $impLines.Add("$topic`t$($x.Path)`tIP configuration file`t$($x.Project)")
            $matched = $true
        }
    } else {
        foreach ($pat in $patterns) {
            $matchList = $fileInfos | Where-Object { $_.Path -match $pat } | Sort-Object Path
            foreach ($m in $matchList) {
                $impLines.Add("$topic`t$($m.Path)`t$topic reference`t$($m.Project)")
                $matched = $true
            }
        }
    }
    if (-not $matched) {
        $impLines.Add("$topic`tN/A`tNo matching files found`t")
    }
}
$impLines | Out-File -FilePath $impFile -Encoding UTF8

# ── Calculate summary metrics ──
$categoryCounts = $fileInfos | Group-Object Category | Sort-Object Count -Descending
$dirCount = $dirList.Count
$xprCount = ($fileInfos | Where-Object { $_.Extension -eq ".xpr" }).Count
$xciCount = ($fileInfos | Where-Object { $_.Extension -eq ".xci" }).Count
$bdCount = ($fileInfos | Where-Object { $_.Extension -eq ".bd" }).Count
$xdcCount = ($fileInfos | Where-Object { $_.Extension -eq ".xdc" }).Count
$ucfCount = ($fileInfos | Where-Object { $_.Extension -eq ".ucf" }).Count
$constraintTotal = $xdcCount + $ucfCount
$hdlCount = ($fileInfos | Where-Object { $_.Category -eq "HDL Source" }).Count
$pdfCount = ($fileInfos | Where-Object { $_.Extension -eq ".pdf" }).Count
$mbCount = ($fileInfos | Where-Object { $_.Path.StartsWith("09_microblaze/") }).Count

# ── Write INDEX_SUMMARY.md ──
$summaryFile = Join-Path $indexDir "INDEX_SUMMARY.md"
$summaryLines = [System.Collections.Generic.List[string]]::new()
$summaryLines.Add("# AI Repository Index Summary")
$summaryLines.Add("")
$summaryLines.Add("**Repository:** AX7035B-learning-materials")
$summaryLines.Add("**GitHub:** https://github.com/yeblue1029/AX7035B-learning-materials")
$summaryLines.Add("**RepositoryHeadAtGeneration:** ``$headSha``")
$summaryLines.Add("**IndexedSourceCommit:** ``$headSha``")
$summaryLines.Add("**Generated:** $timestamp")
$summaryLines.Add("")
$summaryLines.Add("## Overview")
$summaryLines.Add("")
$summaryLines.Add("- **IndexedFileCount:** $($indexedFiles.Count)")
$summaryLines.Add("- **DirectoryCount:** $dirCount")
$summaryLines.Add("- **VivadoProjectCount (XPR):** $xprCount")
$summaryLines.Add("- **DemoCount:** $demoCount")
$summaryLines.Add("- **HDLCount:** $hdlCount")
$summaryLines.Add("- **ConstraintCount:** $constraintTotal (XDC: $xdcCount, UCF: $ucfCount)")
$summaryLines.Add("- **XCICount:** $xciCount")
$summaryLines.Add("- **BDCount:** $bdCount")
$summaryLines.Add("- **MicroBlazeSourceCount:** $mbCount")
$summaryLines.Add("- **PDFCount:** $pdfCount")
$summaryLines.Add("- **GeneratedArtifactsCurrentlyTracked:** $generatedCount")
$summaryLines.Add("- **Phase3HistoricalGeneratedArtifactsRemoved:** 9504")
$summaryLines.Add("- **LFSCount:** $lfsCount")
$summaryLines.Add("")
$summaryLines.Add("## Top-Level Structure")
$summaryLines.Add("")
$topLevel = $fileInfos | Group-Object { ($_.Path -split "/")[0] } | Sort-Object Count -Descending
foreach ($tl in $topLevel) {
    $summaryLines.Add("- ``$($tl.Name)`` ($($tl.Count) files)")
}
$summaryLines.Add("")
$summaryLines.Add("## File Categories")
$summaryLines.Add("")
$summaryLines.Add("| Category | Count |")
$summaryLines.Add("|----------|-------|")
foreach ($c in $categoryCounts) {
    $summaryLines.Add("| $($c.Name) | $($c.Count) |")
}
$summaryLines.Add("")
$summaryLines.Add("## Key Metrics")
$summaryLines.Add("")
$summaryLines.Add("- Vivado projects (.xpr): $xprCount")
$summaryLines.Add("- IP cores (.xci): $xciCount")
$summaryLines.Add("- Block designs (.bd): $bdCount")
$summaryLines.Add("- Constraint files: $constraintTotal (XDC: $xdcCount, UCF: $ucfCount)")
$summaryLines.Add("- HDL source files: $hdlCount")
$summaryLines.Add("- MicroBlaze files: $mbCount")
$summaryLines.Add("- PDF documents: $pdfCount")
$summaryLines.Add("- LFS files: $lfsCount")
$summaryLines.Add("- Demo entries: $demoCount")
$summaryLines.Add("")
$summaryLines.Add("## Index Scope")
$summaryLines.Add("")
$summaryLines.Add("This index covers the tracked source corpus after Phase 3 cleanup.")
$summaryLines.Add("Vivado generated build artifacts (*.runs, *.cache, *.hw, *.sim, *.gen,")
$summaryLines.Add("ip_user_files, .Xil, xsim.dir) are excluded from the index.")
$summaryLines.Add("AI-generated index and skill artifacts are excluded from the index scope.")
$summaryLines.Add("")
$summaryLines.Add("- GeneratedArtifactsCurrentlyTracked: $generatedCount (should be 0)")
$summaryLines.Add("- Phase3HistoricalGeneratedArtifactsRemoved: 9504 (historical record)")
$summaryLines.Add("- LFSCount: $lfsCount (from git lfs ls-files)")
$summaryLines | Out-File -FilePath $summaryFile -Encoding UTF8

# ── Write README.md ──
$readmeFile = Join-Path $indexDir "README.md"
@"
# AI_REPO_INDEX

**AI_REPO_INDEX is a navigation layer, not the source of truth.**

## Purpose

This directory contains a machine-readable index of the repository's tracked
source files. It helps AI assistants (and humans) navigate the repository
without scanning every file.

## Important Rule

```
Index entry != authoritative hardware fact
```

The index tells you WHERE to find information.
The actual hardware facts come from:

1. Board manuals, schematics, and PCB layout files in the repository
2. AMD/Xilinx official device documentation
3. Actual Vivado project files (XPR, XDC, XCI, BD)
4. Actual HDL source code (Verilog, VHDL)
5. Chip datasheets

## How to Use

1. Use REPO_DIRS.txt to find directories
2. Use REPO_FILES.tsv to find specific files
3. Use EXPERIMENTS.txt to find demo projects
4. Use FPGA_PROJECTS.txt to find Vivado projects
5. Use HDL_TOP_MODULES.txt to find top modules
6. Use CONSTRAINT_FILES.txt to find constraints
7. Use IP_CORES.txt to find IP configurations
8. Use MICROBLAZE_PROJECTS.txt to find MicroBlaze content
9. Use IMPORTANT_FILES.txt to find key learning resources
10. Always open the actual file to verify facts

## Regenerating

Run the generator script:

```
.trae/skills/ax7035b-learning/GENERATE_REPO_INDEX.cmd
```

Or directly:

```
powershell -File .trae/skills/ax7035b-learning/GENERATE_REPO_INDEX.ps1
```

## IndexedSourceCommit

See REPO_REVISION.txt for the commit SHA this index was generated from.
"@ | Out-File -FilePath $readmeFile -Encoding UTF8

Write-Host ""
Write-Host "=== AI_REPO_INDEX v2 Generation Complete ==="
Write-Host "RepositoryHeadAtGeneration: $headSha"
Write-Host "IndexedFileCount: $($indexedFiles.Count)"
Write-Host "DirectoryCount: $dirCount"
Write-Host "VivadoProjectCount: $xprCount"
Write-Host "DemoCount: $demoCount"
Write-Host "HDLCount: $hdlCount"
Write-Host "ConstraintCount: $constraintTotal (XDC: $xdcCount, UCF: $ucfCount)"
Write-Host "XCICount: $xciCount"
Write-Host "BDCount: $bdCount"
Write-Host "MicroBlazeSourceCount: $mbCount"
Write-Host "PDFCount: $pdfCount"
Write-Host "GeneratedArtifactsCurrentlyTracked: $generatedCount"
Write-Host "LFSCount: $lfsCount"
Write-Host ""
Write-Host "Output directory: $indexDir"
