# 🚀 Open WebUI Cloud Run デプロイパッケージ

このパッケージには、Open WebUIをGoogle Cloud Runにデプロイするために必要なファイルが含まれています。

## 📋 前提条件

1. Google Cloudプロジェクト
2. gcloud CLIがインストール済み
3. 認証済み (`gcloud auth login`)
4. Vertex AI Reasoning Engineがデプロイ済み

## 🚀 クイックスタート

### ステップ1: 設定ファイルを編集

`deploy-cloud-run-final.sh` を開いて、以下を自分の環境に合わせて変更:

```bash
PROJECT_ID="your-project-id"              # あなたのプロジェクトID
SERVICE_ACCOUNT="your-sa@project.iam..."  # サービスアカウント
```

### ステップ2: デプロイ実行

```bash
chmod +x deploy-cloud-run-final.sh
./deploy-cloud-run-final.sh
```

### ステップ3: Open WebUIで設定

1. デプロイされたURLにアクセス
2. 管理者アカウント作成
3. Settings → Admin Panel → Functions → `+`
4. `multi_agent_pipe_cloudrun.py` の内容を貼り付け
5. Save

### ステップ4: エージェント設定

Functions → `Vertex AI Multi-Agent Manager` を選択

`AGENTS_CONFIG` を編集して、Reasoning Engine IDを設定:

```json
[
    {
        "id": "root-agent",
        "name": "Root Agent",
        "engine_id": "YOUR_REASONING_ENGINE_ID",
        "description": "説明"
    }
]
```

## 📚 詳細ドキュメント

- `CLOUD_RUN_DEPLOY_GUIDE.md` - 完全なデプロイガイド
- `MULTI_AGENT_QUICKSTART.md` - マルチエージェント設定
- `ADD_NEW_AGENT_GUIDE.md` - エージェント追加方法

## 🔧 トラブルシューティング

### 認証エラー

```bash
gcloud auth login
gcloud auth application-default login
```

### プロジェクトIDの確認

```bash
gcloud projects list
```

### サービスアカウントの確認

```bash
gcloud iam service-accounts list
```

## 💡 ヒント

- プロジェクトIDは文字列 (例: `my-project-123`)
- プロジェクト番号は数値 (例: `522847804541`)
- Reasoning Engine APIは**プロジェクト番号**を使用

---

**問題がある場合は、ドキュメントを参照してください！**
