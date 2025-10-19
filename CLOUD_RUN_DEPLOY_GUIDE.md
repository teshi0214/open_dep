# ☁️ Cloud Run 完全デプロイガイド

## 🎯 この構成でできること

- ✅ Vertex AI Reasoning Engineをどこからでも使える
- ✅ 自動スケーリング (アクセス増減に対応)
- ✅ HTTPS自動設定
- ✅ 世界中からアクセス可能
- ✅ 従量課金 (使った分だけ支払い)

---

## 📋 前提条件

### 1. Google Cloudの準備

```bash
# gcloud CLIがインストール済みであること
gcloud --version

# Google Cloudにログイン
gcloud auth login

# プロジェクトを確認
gcloud config list project
```

### 2. 必要な権限

- Cloud Run Admin
- Cloud Build Editor  
- Service Account User
- Storage Admin (Container Registry用)

### 3. サービスアカウントの設定

すでに `vertex-service-account.json` があるので、このサービスアカウントに以下の権限を付与:

```bash
# プロジェクトID
PROJECT_ID="agent-vi-473112"
SERVICE_ACCOUNT="open-webui-vertex@agent-vi-473112.iam.gserviceaccount.com"

# 必要な権限を付与
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/aiplatform.user"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/run.invoker"
```

---

## 🚀 デプロイ手順

### 方法1: 自動デプロイスクリプト（推奨）

```bash
# スクリプトに実行権限を付与
chmod +x deploy-cloud-run.sh

# デプロイ実行
./deploy-cloud-run.sh
```

**これだけで完了！**

---

### 方法2: 手動デプロイ

#### ステップ1: 設定の確認

`deploy-cloud-run.sh` を開いて、以下を確認:

```bash
PROJECT_ID="522847804541"  # あなたのプロジェクト番号
REGION="us-central1"       # リージョン
SERVICE_NAME="open-webui"  # サービス名
```

#### ステップ2: Dockerイメージをビルド

```bash
# プロジェクトディレクトリで実行
cd /path/to/open-webui-main

# Cloud Buildでビルド
gcloud builds submit --tag gcr.io/${PROJECT_ID}/open-webui:latest
```

**所要時間:** 約10-15分

#### ステップ3: Cloud Runにデプロイ

```bash
gcloud run deploy open-webui \
    --image gcr.io/${PROJECT_ID}/open-webui:latest \
    --platform managed \
    --region us-central1 \
    --service-account open-webui-vertex@agent-vi-473112.iam.gserviceaccount.com \
    --memory 2Gi \
    --cpu 2 \
    --allow-unauthenticated \
    --port 8080
```

#### ステップ4: URLを取得

```bash
gcloud run services describe open-webui \
    --region us-central1 \
    --format 'value(status.url)'
```

**例:**
```
https://open-webui-abc123-uc.a.run.app
```

---

## 🔧 デプロイ後の設定

### 1. Open WebUIにアクセス

取得したURLをブラウザで開く

### 2. 管理者アカウントを作成

初回アクセス時に管理者アカウントを作成

### 3. Pipelineを追加

#### Option A: Web UIで追加

1. Settings → Admin Panel → Functions
2. `+` ボタンクリック
3. `multi_agent_pipe.py` の内容を貼り付け
4. Save

#### Option B: APIで追加（自動化）

```bash
# 後述のスクリプトを使用
./setup-pipelines-cloud-run.sh
```

### 4. エージェント設定の編集

Functions → `Vertex AI Multi-Agent Manager` を選択して、`AGENTS_CONFIG` を編集:

```json
[
    {
        "id": "root-agent",
        "name": "Root Agent (Research Assistant)",
        "engine_id": "1795410129181474816",
        "description": "学術調査、ニュース、情報収集"
    }
]
```

---

## 💰 コスト見積もり

### Cloud Run 料金（us-central1リージョン）

| リソース | 無料枠 | 料金 |
|---------|--------|------|
| CPU | 180,000 vCPU-秒/月 | $0.00002400/vCPU-秒 |
| メモリ | 360,000 GiB-秒/月 | $0.00000250/GiB-秒 |
| リクエスト | 2,000,000件/月 | $0.40/100万件 |

### 例: 月間1,000ユーザー利用時

**想定:**
- 1ユーザーあたり10リクエスト/月
- 平均レスポンス時間: 3秒
- メモリ使用: 2GB

**計算:**
```
リクエスト数: 1,000 × 10 = 10,000リクエスト
CPU時間: 10,000 × 3秒 × 2 vCPU = 60,000 vCPU-秒
メモリ時間: 10,000 × 3秒 × 2GB = 60,000 GiB-秒

すべて無料枠内！
```

**月額コスト:** $0 (無料枠内)

### 大規模利用時（月間100万リクエスト）

**計算:**
```
CPU: (100万 × 3秒 × 2 vCPU - 180,000) × $0.000024 ≈ $143
メモリ: (100万 × 3秒 × 2GB - 360,000) × $0.0000025 ≈ $14
リクエスト: (100万 - 200万) × $0.40/100万 = $0

合計: 約 $157/月
```

---

## 🔐 セキュリティ設定

### 1. 認証の有効化（推奨）

```bash
# 認証を必須にする
gcloud run services update open-webui \
    --region us-central1 \
    --no-allow-unauthenticated
```

**アクセス方法:**
```bash
# トークン付きでアクセス
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
    https://your-service-url.run.app
```

### 2. カスタムドメインの設定

```bash
# カスタムドメインをマッピング
gcloud beta run domain-mappings create \
    --service open-webui \
    --domain your-domain.com \
    --region us-central1
```

### 3. 環境変数の暗号化

```bash
# Secret Managerを使用
gcloud secrets create webui-secret-key \
    --data-file=- <<< "$(openssl rand -hex 32)"

# Cloud Runで使用
gcloud run services update open-webui \
    --update-secrets WEBUI_SECRET_KEY=webui-secret-key:latest \
    --region us-central1
```

---

## 📊 モニタリング

### Cloud Runメトリクス

```bash
# ログを確認
gcloud run services logs read open-webui \
    --region us-central1 \
    --limit 50

# リアルタイムログ
gcloud run services logs tail open-webui \
    --region us-central1
```

### Cloud Consoleで確認

1. https://console.cloud.google.com/run
2. `open-webui` サービスを選択
3. メトリクスタブで以下を確認:
   - リクエスト数
   - レスポンス時間
   - エラー率
   - コンテナインスタンス数

---

## 🔄 更新とロールバック

### アプリケーションの更新

```bash
# コード変更後
gcloud builds submit --tag gcr.io/${PROJECT_ID}/open-webui:v2

# 新バージョンをデプロイ
gcloud run deploy open-webui \
    --image gcr.io/${PROJECT_ID}/open-webui:v2 \
    --region us-central1
```

### ロールバック

```bash
# リビジョン一覧を確認
gcloud run revisions list \
    --service open-webui \
    --region us-central1

# 前のリビジョンに戻す
gcloud run services update-traffic open-webui \
    --to-revisions open-webui-00001-abc=100 \
    --region us-central1
```

---

## 🐛 トラブルシューティング

### デプロイが失敗する

```bash
# ビルドログを確認
gcloud builds log $(gcloud builds list --limit 1 --format 'value(id)')

# よくある原因:
# 1. Dockerfileのパスが間違っている
# 2. 権限不足
# 3. リージョン設定ミス
```

### サービスが起動しない

```bash
# ログを確認
gcloud run services logs read open-webui --region us-central1 --limit 100

# よくある原因:
# 1. ポート8080でリッスンしていない
# 2. 環境変数が不足
# 3. サービスアカウント権限不足
```

### Reasoning Engineに接続できない

```bash
# サービスアカウントの権限を確認
gcloud projects get-iam-policy agent-vi-473112 \
    --flatten="bindings[].members" \
    --filter="bindings.members:serviceAccount:open-webui-vertex@*"

# 必要な権限:
# - roles/aiplatform.user
```

---

## 🚀 次のステップ

- [ ] カスタムドメインを設定
- [ ] 認証を有効化
- [ ] モニタリングアラートを設定
- [ ] 自動バックアップを構成
- [ ] CI/CDパイプラインを構築

---

## 📚 参考リンク

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Vertex AI Pricing](https://cloud.google.com/vertex-ai/pricing)
- [Open WebUI Documentation](https://docs.openwebui.com/)

---

## 💡 ベストプラクティス

1. **最小権限の原則**
   - サービスアカウントには必要最小限の権限のみ付与

2. **環境変数の管理**
   - Secret Managerを使用して機密情報を保護

3. **ログとモニタリング**
   - Cloud Loggingで集中管理
   - アラートを設定

4. **コスト最適化**
   - MIN_INSTANCESを0に設定（使わない時は課金なし）
   - 不要なリージョンへのデプロイを避ける

5. **バックアップ**
   - 定期的にデータをエクスポート
   - リビジョン管理を活用
