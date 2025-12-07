# ================================
# ■ bat から渡された全引数を $args で受け取る
# ================================
$partFiles = $args

# ================================
# ■ 引数チェック
# ================================
if (-not $partFiles -or $partFiles.Count -eq 0) {
    Write-Host "⚠ 結合する分割ファイルを複数指定してください！"
    Write-Host "例:"
    Write-Host "run_join.bat C:\file.txt.part1 C:\file.txt.part2"
    pause
    exit
}

# ================================
# ■ ファイル存在チェック
# ================================
$validFiles = @()

foreach ($file in $partFiles) {
    if (-not (Test-Path $file)) {
        Write-Host "❌ ファイルが存在しません: $file"
        pause
        exit
    }
    $validFiles += Get-Item $file
}

# ================================
# ■ 名前順で正しくソート
# ================================
$validFiles = $validFiles | Sort-Object Name

# ================================
# ■ 結合後の出力ファイル名を作成
# ================================
$baseName = $validFiles[0].FullName -replace '\.part\d+$', ''
$outputFile = "$baseName"

# ================================
# ■ 総サイズ計算（進捗用）
# ================================
$totalSize = ($validFiles | Measure-Object Length -Sum).Sum
$processedTotal = 0

# ================================
# ■ 結合ファイル作成開始
# ================================
$ofs = [IO.File]::OpenWrite($outputFile)

Write-Host "📂 結合対象ファイル:"
$validFiles | ForEach-Object { Write-Host "   - $($_.Name)" }

Write-Host "📦 結合後ファイル: $outputFile"
Write-Host "▶ 結合処理スタート！"
Write-Host "--------------------------------------"

# ================================
# ■ 分割ファイルを順番に結合
# ================================
foreach ($file in $validFiles) {

    Write-Host "🛠  読み込み中: $($file.Name)"

    $ifs = [IO.File]::OpenRead($file.FullName)
    $buffer = New-Object byte[] 4MB

    while ($true) {
        $read = $ifs.Read($buffer, 0, $buffer.Length)
        if ($read -le 0) { break }

        $ofs.Write($buffer, 0, $read)

        $processedTotal += $read
        $percent = [int](($processedTotal / $totalSize) * 100)

        Write-Progress `
            -Activity "ファイル結合中" `
            -Status "$percent% 完了" `
            -PercentComplete $percent
    }

    $ifs.Close()
    Write-Host "✅ 完了: $($file.Name)"
}

# ================================
# ■ 後処理
# ================================
$ofs.Close()
Write-Progress -Activity "ファイル結合中" -Completed

Write-Host "--------------------------------------"
Write-Host "🎉 すべての結合が完了しました！"
Write-Host "📄 出力ファイル: $outputFile"
pause
