# ノートPCのセットアップ自動化
## 機能
- Windowsのプロキシの環境変数を設定できる（setup_pc.ps1）
- Windowsで使用しているアプリをインストールできる（setup_pc.ps1）
- WSLの有効化ができる（setup_pc.ps1）
- Ubuntuインストールができる（setup_pc.ps1）
- WSLとaptのプロキシ設定ができる（setup_wsl.ps1）
- VSCodeで使用してた拡張機能の推奨を得られる（.vscode/extentions.json）

## 手順
1. このリポジトリをクローン
2. このプロジェクトのルートへ移動
3. poweshellで `.\setup_pc.ps1` を実行(ログファイルがこのファイルに出力される)
4. poweshellで `.\setup_wsl.ps1` を実行(ログファイルがこのファイルに出力される)
5. VSCodeでこのリポジトリを開く
6. 推奨される拡張機能をインストール