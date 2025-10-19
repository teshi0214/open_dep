# 🚀 新しいエージェントの追加方法

## 📋 前提条件

- Vertex AIで新しいReasoning Engineがデプロイ済み
- Reasoning Engine IDが分かっている

---

## ⚡ 超簡単！3ステップで追加

### ステップ1: Reasoning Engine IDを確認

```bash
# Vertex AIコンソールで確認
# または gcloud コマンドで取得
gcloud ai reasoning-engines list --location=us-central1
```

**例:**
```
ID: 9876543210987654321
Name: my-analyst-agent
```

---

### ステップ2: Open WebUIで設定を編集

1. **Open WebUIにアクセス**
   - Settings → Admin Panel → Functions

2. **`Vertex AI Multi-Agent Manager` を選択**

3. **`AGENTS_CONFIG` を編集**

#### 📝 編集前:

```json
[
    {
        "id": "root-agent",
        "name": "Root Agent (Research Assistant)",
        "engine_id": "1795410129181474816",
        "description": "学術調査、ニュース、情報収集のためのリサーチアシスタント"
    }
]
```

#### ✅ 編集後 (エージェント追加):

```json
[
    {
        "id": "root-agent",
        "name": "Root Agent (Research Assistant)",
        "engine_id": "1795410129181474816",
        "description": "学術調査、ニュース、情報収集のためのリサーチアシスタント"
    },
    {
        "id": "analyst-agent",
        "name": "Analyst Agent (Data Analysis)",
        "engine_id": "9876543210987654321",
        "description": "データ分析とビジネスインサイト抽出の専門家"
    }
]
```

4. **Save ボタンをクリック**

---

### ステップ3: 確認

1. **チャット画面に戻る**
2. **モデル選択ドロップダウンを開く**
3. **新しいエージェントが表示される！**

```
✅ AGENT/Root Agent (Research Assistant)
✅ AGENT/Analyst Agent (Data Analysis)  ← NEW!
```

---

## 🎯 各フィールドの説明

| フィールド | 説明 | 例 |
|-----------|------|-----|
| `id` | エージェントの一意なID<br>(英数字とハイフンのみ) | `analyst-agent` |
| `name` | Open WebUIで表示される名前 | `Analyst Agent` |
| `engine_id` | Vertex AI Reasoning Engine ID | `9876543210987654321` |
| `description` | エージェントの説明 (任意) | `データ分析専門家` |

---

## 💡 実例: 3つのエージェントを管理

```json
[
    {
        "id": "research-agent",
        "name": "Research Agent",
        "engine_id": "1795410129181474816",
        "description": "学術論文・ニュース検索"
    },
    {
        "id": "data-analyst",
        "name": "Data Analyst",
        "engine_id": "2222222222222222222",
        "description": "データ分析・統計処理"
    },
    {
        "id": "code-reviewer",
        "name": "Code Reviewer",
        "engine_id": "3333333333333333333",
        "description": "コードレビュー・セキュリティチェック"
    }
]
```

**結果:**
- ✅ AGENT/Research Agent
- ✅ AGENT/Data Analyst
- ✅ AGENT/Code Reviewer

すべてのエージェントがモデル選択で利用可能に！

---

## 🔧 トラブルシューティング

### エラー: "エージェントが見つかりません"

**原因:** JSON形式が間違っている

**解決策:**
1. JSON Validatorでチェック: https://jsonlint.com/
2. カンマ、括弧、引用符を確認
3. 最後のエージェントの後にカンマを付けない

#### ❌ 間違った例:

```json
[
    {
        "id": "agent1",
        ...
    },  ← この最後のカンマは不要
]
```

#### ✅ 正しい例:

```json
[
    {
        "id": "agent1",
        ...
    }
]
```

---

### エラー: "Authentication failed"

**原因:** Reasoning Engine IDが間違っている

**解決策:**
1. Vertex AIコンソールで正しいIDを確認
2. `gcloud` コマンドで確認:
   ```bash
   gcloud ai reasoning-engines list --location=us-central1
   ```

---

### エージェントが表示されない

**原因:** ブラウザのキャッシュ

**解決策:**
1. ブラウザをリロード (F5 または Cmd+R)
2. キャッシュをクリア
3. Open WebUIを再起動:
   ```bash
   docker compose restart open-webui
   ```

---

## 🎓 応用編: 動的設定

### .envファイルで管理

より高度な運用では、`.env`ファイルで管理できます:

```bash
# .env
AGENT_1_ID=research-agent
AGENT_1_NAME=Research Agent
AGENT_1_ENGINE=1795410129181474816

AGENT_2_ID=analyst-agent
AGENT_2_NAME=Data Analyst
AGENT_2_ENGINE=2222222222222222222
```

---

## 📊 運用のベストプラクティス

### 1. エージェントの命名規則

```
{役割}-agent
例: research-agent, analyst-agent, writer-agent
```

### 2. 説明を詳しく書く

```json
{
    "description": "学術論文検索、arXiv統合、Tavily検索を使用したリサーチエージェント"
}
```

### 3. バックアップを取る

```bash
# 設定をバックアップ
# Open WebUIのFunctionsページで「Export」をクリック
```

---

## 🚀 まとめ

**エージェント追加 = たった1つの設定を編集するだけ！**

1. Open WebUI → Functions → `Vertex AI Multi-Agent Manager`
2. `AGENTS_CONFIG` にエージェント情報を追加
3. Save

**これだけで新しいエージェントが使えます！**

---

## 💡 次のステップ

- [ ] 最初のエージェントを追加してみる
- [ ] 複数エージェントで役割分担を試す
- [ ] A2A (Agent to Agent) 連携を実験
- [ ] カスタムMCPツールを追加

何か困ったことがあれば、お気軽にどうぞ！🙌
