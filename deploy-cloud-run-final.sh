#!/bin/bash

# ☁️ Open WebUI Cloud Run デプロイスクリプト v3
# 公式イメージをGCRにコピーしてデプロイ

set -e

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🔧 設定
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PROJECT_ID="agent-vi-473112"
REGION="us-central1"
SERVICE_NAME="open-webui"

# 公式イメージ
OFFICIAL_IMAGE="ghcr.io/open-webui/open-webui:main"

# GCRにコピー先
GCR_IMAGE="gcr.io/${PROJECT_ID}/open-webui:latest"

# サービスアカウント
SERVICE_ACCOUNT="open-webui-vertex@${PROJECT_ID}.iam.gserviceaccount.com"

# Cloud Runの設定
MEMORY="2Gi"
CPU="2"
MAX_INSTANCES="10"
MIN_INSTANCES="0"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "☁️ Open WebUI Cloud Run デプロイ開始（公式イメージ版 v3）"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ステップ1: 環境確認
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "📋 ステップ1: 環境確認"

# gcloud認証確認
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "❌ gcloud認証が必要です"
    echo "   実行: gcloud auth login"
    exit 1
fi
echo "✅ gcloud認証確認完了"

# プロジェクト設定
gcloud config set project ${PROJECT_ID}
echo "✅ プロジェクト設定: ${PROJECT_ID}"

# 必要なAPIを有効化
echo "🔌 必要なAPIを有効化中..."
gcloud services enable \
    run.googleapis.com \
    containerregistry.googleapis.com \
    --quiet

echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ステップ2: イメージをGCRにコピー
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "📦 ステップ2: 公式イメージをGCRにコピー"
echo "   ${OFFICIAL_IMAGE}"
echo "   → ${GCR_IMAGE}"

# Cloud Buildを使ってイメージをコピー
cat > /tmp/copy-image-cloudbuild.yaml <<EOF
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args: ['pull', '${OFFICIAL_IMAGE}']
  - name: 'gcr.io/cloud-builders/docker'
    args: ['tag', '${OFFICIAL_IMAGE}', '${GCR_IMAGE}']
images:
  - '${GCR_IMAGE}'
EOF

gcloud builds submit --no-source --config /tmp/copy-image-cloudbuild.yaml --quiet

echo "✅ イメージコピー完了"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ステップ3: Cloud Runにデプロイ
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "🚀 ステップ3: Cloud Runにデプロイ"

gcloud run deploy ${SERVICE_NAME} \
    --image ${GCR_IMAGE} \
    --platform managed \
    --region ${REGION} \
    --service-account ${SERVICE_ACCOUNT} \
    --memory ${MEMORY} \
    --cpu ${CPU} \
    --max-instances ${MAX_INSTANCES} \
    --min-instances ${MIN_INSTANCES} \
    --port 8080 \
    --allow-unauthenticated \
    --set-env-vars "WEBUI_SECRET_KEY=$(openssl rand -hex 32)" \
    --set-env-vars "ENV=prod" \
    --set-env-vars "ENABLE_OAUTH_SIGNUP=false" \
    --set-env-vars "OLLAMA_BASE_URL=" \
    --timeout 300

echo "✅ デプロイ完了"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ステップ4: サービスURL取得
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "🌐 サービスURL:"
SERVICE_URL=$(gcloud run services describe ${SERVICE_NAME} \
    --region ${REGION} \
    --format 'value(status.url)')

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 デプロイ成功！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📍 アクセスURL:"
echo "   ${SERVICE_URL}"
echo ""
echo "📚 次のステップ:"
echo "   1. ブラウザでURLを開く"
echo "   2. 管理者アカウントを作成"
echo "   3. Settings → Admin Panel → Functions"
echo "   4. '+' をクリックして multi_agent_pipe.py を追加"
echo "   5. AGENTS_CONFIG を編集してエージェントを追加"
echo ""
echo "💡 multi_agent_pipe.py の内容を表示:"
echo "   cat multi_agent_pipe.py"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
