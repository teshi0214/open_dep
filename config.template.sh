# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🔧 設定テンプレート
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Google Cloudプロジェクト設定
PROJECT_ID="your-project-id"              # プロジェクトID（文字列）
PROJECT_NUMBER="123456789012"             # プロジェクト番号（数値）

# サービスアカウント
SERVICE_ACCOUNT="your-service-account@your-project-id.iam.gserviceaccount.com"

# Vertex AI Reasoning Engine
REASONING_ENGINE_ID="1234567890123456789"  # Reasoning Engine ID

# リージョン
REGION="us-central1"                       # デプロイ先リージョン

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 確認コマンド
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# プロジェクトID確認
# gcloud projects list

# プロジェクト番号確認
# gcloud projects describe ${PROJECT_ID} --format='value(projectNumber)'

# サービスアカウント確認
# gcloud iam service-accounts list

# Reasoning Engine確認
# gcloud ai reasoning-engines list --location=${REGION}
