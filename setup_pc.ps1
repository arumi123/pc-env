# =====================================
# Windows 環境セットアップ自動化スクリプト
# - HTTP/HTTPS/NO_PROXY環境変数設定
# - Office製品、付箋、PowerToys、VSCodeインストール（winget利用）
# - WSL有効化、Ubuntuインストール
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

# 管理者権限チェック
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Log-Error "管理者権限で実行してください！スクリプトを終了します。"
    exit 1
}

try {
    Log-Info "===== Windows 環境セットアップ開始 ====="

    # 1. 環境変数設定（ユーザー環境変数として設定）
    Log-Info "HTTP_PROXY, HTTPS_PROXY, NO_PROXY 環境変数を設定します..."

    $proxyHttp = "http://proxy.example.com:8080"
    $proxyHttps = "http://proxy.example.com:8080"
    $noProxy = "localhost,127.0.0.1,::1"

    try {
        [Environment]::SetEnvironmentVariable("HTTP_PROXY", $proxyHttp, "User")
        [Environment]::SetEnvironmentVariable("HTTPS_PROXY", $proxyHttps, "User")
        [Environment]::SetEnvironmentVariable("NO_PROXY", $noProxy, "User")
        Log-Info "環境変数設定完了"
    }
    catch {
        Log-Warning "環境変数設定で問題が発生しました: $_"
    }

    # 2. アプリインストール（winget利用）
    Log-Info "wingetで以下アプリをインストールします..."

    $apps = @(
        "Microsoft.PowerPoint",
        "Microsoft.Word",
        "Microsoft.Excel",
        "Microsoft.OneNote",
        "Microsoft.StickyNotes",
        "Microsoft.PowerToys",
        "Microsoft.VisualStudioCode"
    )

    foreach ($app in $apps) {
        Log-Info "インストール中: $app"
        try {
            winget install --id=$app -e --accept-package-agreements --accept-source-agreements -h
            Log-Info "$app のインストールに成功しました"
        }
        catch {
            Log-Warning "$app のインストールに失敗しました: $_"
        }
    }

    # 3. WSL 有効化
    Log-Info "WSLおよび仮想マシンプラットフォーム機能を有効化します..."

    $features = @(
        "Microsoft-Windows-Subsystem-Linux",
        "VirtualMachinePlatform"
    )

    foreach ($feature in $features) {
        try {
            $result = Enable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart -ErrorAction Stop
            Log-Info "$feature の有効化完了"
        }
        catch {
            Log-Warning "$feature の有効化に失敗しました（無視して続行）: $_"
        }
    }

    # 4. WSL用Ubuntuインストール
    Log-Info "Ubuntuディストリビューションをインストールします..."

    try {
        # もしすでにインストール済みならスキップ
        $wslDistros = wsl -l
        if ($wslDistros -match "Ubuntu") {
            Log-Info "Ubuntuは既にインストールされています。"
        } else {
            Invoke-WebRequest -Uri https://aka.ms/wslubuntu2004 -OutFile Ubuntu.appx -UseBasicParsing
            Add-AppxPackage .\Ubuntu.appx
            Log-Info "Ubuntuのインストール完了"
            Remove-Item .\Ubuntu.appx -Force
        }
    }
    catch {
        Log-Warning "Ubuntuのインストールで問題が発生しました: $_"
    }

    Log-Info "WSLの機能有効化完了。PCを再起動してください（スクリプトはここで終了）"
    Log-Info "===== Windows 環境セットアップ終了 ====="
    Log-Info "ログファイルはこちら: $logFile"
    exit 0
}
catch {
    Log-Error "予期せぬエラー発生: $_"
    exit 1
}
