# =====================================
# - WSL内プロキシ設定 & aptプロキシ設定
# - ログファイル出力対応（成功/失敗の記録）
# =====================================

# ログファイルパス（実行時刻付き）
$logFile = "$PSScriptRoot\setup_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Log-Info {
    param([string]$message)
    $time = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMsg = "[$time] INFO: $message"
    Write-Output $logMsg
    Add-Content -Path $logFile -Value $logMsg
}

function Log-Warning {
    param([string]$message)
    $time = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMsg = "[$time] WARNING: $message"
    Write-Warning $message
    Add-Content -Path $logFile -Value $logMsg
}

function Log-Error {
    param([string]$message)
    $time = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMsg = "[$time] ERROR: $message"
    Write-Error $message
    Add-Content -Path $logFile -Value $logMsg
}

# WSL内のプロキシ設定

$wslProxyHttp = "http://proxy.example.com:8080"
$wslProxyHttps = "http://proxy.example.com:8080"
$wslNoProxy = "localhost,127.0.0.1,::1"

try {
    Log-Info "WSLの~/.bashrc にプロキシ環境変数を追記開始"

    $wslBashrcCmd = @"
echo 'export http_proxy=$wslProxyHttp' >> ~/.bashrc
echo 'export https_proxy=$wslProxyHttps' >> ~/.bashrc
echo 'export no_proxy=$wslNoProxy' >> ~/.bashrc
"@

    wsl bash -c "$wslBashrcCmd"

    Log-Info "WSLの.bashrcへのプロキシ環境変数追記完了"
}
catch {
    Log-Warning "WSLの.bashrc追記でエラー発生: $_"
}

try {
    Log-Info "WSLのaptプロキシ設定ファイル作成開始"

    $aptConf = @"
Acquire::http::Proxy \"$wslProxyHttp\";
Acquire::https::Proxy \"$wslProxyHttps\";
"@

    $cmd = "echo '$aptConf' | sudo tee /etc/apt/apt.conf.d/95proxies"

    wsl bash -c $cmd

    Log-Info "WSLのaptプロキシ設定ファイル作成完了"
}
catch {
    Log-Warning "WSLのaptプロキシ設定でエラー発生: $_"
}

Log-Info "WSLのプロキシ設定処理が完了しました"
