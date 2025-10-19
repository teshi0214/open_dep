# 🚀 Multi-Agent Manager - クイックスタート

## 📦 今すぐ使える！3ステップ

### ステップ1: Open WebUIに追加

1. Open WebUI → Settings → Admin Panel → Functions
2. `+` ボタンクリック
3. `/home/Desktop/open-webui-main/multi_agent_pipe.py` の内容をコピー&ペースト
4. Save

### ステップ2: 最初のテスト

チャット画面で:
- モデル選択 → `AGENT/Root Agent (Research Assistant)` を選択
- メッセージ送信: `こんにちは`

### ステップ3: 新しいエージェントを追加

1. Functions → `Vertex AI Multi-Agent Manager` を選択
2. `AGENTS_CONFIG` を編集:

```json
[
    {
        "id": "root-agent",
        "name": "Root Agent (Research Assistant)",
        "engine_id": "1795410129181474816",
        "description": "学術調査、ニュース、情報収集"
    },
    {
        "id": "my-new-agent",
        "name": "My New Agent",
        "engine_id": "YOUR_ENGINE_ID_HERE",
        "description": "あなたの新しいエージェント"
    }
]
```

3. Save → 完了！

---

## 💡 エージェント追加の実例

### 例1: データアナリストを追加

```json
{
    "id": "data-analyst",
    "name": "Data Analyst Pro",
    "engine_id": "2222222222222222222",
    "description": "データ分析、統計処理、ビジネスインサイト"
}
```

### 例2: コードレビューアーを追加

```json
{
    "id": "code-reviewer",
    "name": "Code Reviewer",
    "engine_id": "3333333333333333333",
    "description": "コードレビュー、セキュリティチェック、ベストプラクティス"
}
```

### 例3: ライターを追加

```json
{
    "id": "content-writer",
    "name": "Content Writer",
    "engine_id": "4444444444444444444",
    "description": "記事作成、レポート生成、ドキュメント作成"
}
```

---

## 🎯 完成形の例

```json
[
    {
        "id": "research-agent",
        "name": "Research Agent",
        "engine_id": "1111111111111111111",
        "description": "学術論文・ニュース検索"
    },
    {
        "id": "data-analyst",
        "name": "Data Analyst Pro",
        "engine_id": "2222222222222222222",
        "description": "データ分析・統計処理"
    },
    {
        "id": "code-reviewer",
        "name": "Code Reviewer",
        "engine_id": "3333333333333333333",
        "description": "コードレビュー・セキュリティ"
    },
    {
        "id": "content-writer",
        "name": "Content Writer",
        "engine_id": "4444444444444444444",
        "description": "記事作成・レポート生成"
    }
]
```

**結果:**

チャット画面のモデル選択で4つのエージェントが使えます:
- ✅ AGENT/Research Agent
- ✅ AGENT/Data Analyst Pro
- ✅ AGENT/Code Reviewer
- ✅ AGENT/Content Writer

---

## 🔧 よくある質問

### Q1: エージェントIDはどこで確認？

```bash
# gcloud コマンドで確認
gcloud ai reasoning-engines list --location=us-central1

# または Vertex AI コンソールで確認
# https://console.cloud.google.com/vertex-ai/reasoning-engines
```

### Q2: エージェントを削除したい

AGENTS_CONFIG から該当のJSONブロックを削除して Save

### Q3: エージェントの順番を変えたい

JSONの順番を入れ替えて Save

### Q4: エージェント名を日本語にできる？

はい！可能です:

```json
{
    "id": "research-agent",
    "name": "リサーチエージェント",
    "engine_id": "...",
    "description": "学術調査専門"
}
```

---

## 📚 関連ドキュメント

- **詳細手順**: `ADD_NEW_AGENT_GUIDE.md`
- **マルチエージェント例**: `MULTI_AGENT_EXAMPLES.md`
- **拡張ロードマップ**: `EXPANSION_ROADMAP.md`

---

## 🎉 完了！

これで、**1つのファイルを編集するだけ**で無限にエージェントを追加できます！

楽しんでください！🚀
