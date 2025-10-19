#!/bin/bash

# 🔧 Open WebUI Cloud Run セットアップスクリプト

echo "🔧 Open WebUI Cloud Run セットアップ"
echo ""

# 設定ファイルの確認
if [ ! -f "deploy-cloud-run-final.sh" ]; then
    echo "❌ エラー: deploy-cloud-run-final.sh が見つかりません"
    exit 1
fi

echo "📝 設定の編集が必要です:"
echo ""
echo "1. deploy-cloud-run-final.sh を開く"
echo "2. 以下の項目を変更:"
echo "   - PROJECT_ID=\"あなたのプロジェクトID\""
echo "   - SERVICE_ACCOUNT=\"あなたのサービスアカウント\""
echo ""
echo "3. multi_agent_pipe_cloudrun.py を開く"
echo "4. 以下の項目を確認:"
echo "   - PROJECT_ID (プロジェクト番号)"
echo "   - AGENTS_CONFIG (Reasoning Engine ID)"
echo ""

read -p "設定を編集しましたか? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "設定を編集してから再度実行してください"
    exit 1
fi

# 実行権限を付与
chmod +x deploy-cloud-run-final.sh

echo ""
echo "✅ セットアップ完了"
echo ""
echo "次のコマンドを実行してデプロイ:"
echo "  ./deploy-cloud-run-final.sh"
echo ""
