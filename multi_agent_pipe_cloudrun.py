"""
title: Vertex AI Multi-Agent Manager (Cloud Run対応版)
author: Your Name
version: 2.1.0
license: MIT
description: 複数のVertex AI Reasoning Engineを一元管理（Cloud Run対応）
"""

from pydantic import BaseModel, Field
from typing import Iterator, Union, List, Dict
import requests
import json
import os

class Pipe:
    class Valves(BaseModel):
        # 共通設定
        PROJECT_ID: str = Field(
            default="522847804541",
            description="Google Cloud プロジェクト番号",
        )
        LOCATION: str = Field(
            default="us-central1",
            description="ロケーション",
        )
        
        # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        # 🎯 ここだけ編集！エージェントを追加・削除
        # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        AGENTS_CONFIG: str = Field(
            default="""
[
    {
        "id": "root-agent",
        "name": "Root Agent (Research Assistant)",
        "engine_id": "1795410129181474816",
        "description": "学術調査、ニュース、情報収集のためのリサーチアシスタント"
    }
]
            """,
            description="エージェント設定 (JSON形式)",
        )

    def __init__(self):
        self.valves = self.Valves()
        self._load_agents()

    def _load_agents(self):
        """設定からエージェントリストを読み込み"""
        try:
            self.agents = json.loads(self.valves.AGENTS_CONFIG)
        except json.JSONDecodeError:
            print("⚠️ AGENTS_CONFIG のJSON解析に失敗しました")
            self.agents = []

    def pipes(self) -> List[Dict[str, str]]:
        """利用可能な全エージェントのリストを返す"""
        self._load_agents()
        
        return [
            {
                "id": agent["id"],
                "name": f"AGENT/{agent['name']}"
            }
            for agent in self.agents
        ]

    def pipe(self, body: dict, __user__: dict) -> Union[str, Iterator[str]]:
        """選択されたエージェントでクエリを実行"""
        
        # どのエージェントが選択されたかを判定
        selected_model = body.get("model", "")
        
        # エージェントIDを抽出
        agent_id = None
        for agent in self.agents:
            if agent["id"] in selected_model:
                agent_id = agent["id"]
                break
        
        if not agent_id:
            return "Error: エージェントが見つかりません"
        
        # 選択されたエージェントの設定を取得
        agent_config = next(
            (a for a in self.agents if a["id"] == agent_id),
            None
        )
        
        if not agent_config:
            return f"Error: エージェント '{agent_id}' の設定が見つかりません"
        
        # Reasoning Engine APIを呼び出し
        return self._call_reasoning_engine(
            body=body,
            __user__=__user__,
            engine_id=agent_config["engine_id"]
        )

    def _call_reasoning_engine(
        self,
        body: dict,
        __user__: dict,
        engine_id: str
    ) -> Union[str, Iterator[str]]:
        """Reasoning Engine にクエリを送信（Cloud Run対応）"""
        
        try:
            # Cloud Run環境ではWorkload Identityを使用
            from google.auth import default
            from google.auth.transport.requests import Request as GoogleRequest
            
            # デフォルト認証（Cloud Runのサービスアカウント）
            credentials, project = default(
                scopes=['https://www.googleapis.com/auth/cloud-platform']
            )
            credentials.refresh(GoogleRequest())
            
            # メッセージを取得
            messages = body.get("messages", [])
            user_message = ""
            
            for msg in reversed(messages):
                if msg.get("role") == "user":
                    user_message = msg.get("content", "")
                    break
            
            if not user_message:
                return "Error: ユーザーメッセージが見つかりません"
            
            # ユーザーIDを取得
            user_id = __user__.get("id", "default-user")
            
            # REST API エンドポイント
            url = (
                f"https://{self.valves.LOCATION}-aiplatform.googleapis.com/v1/"
                f"projects/{self.valves.PROJECT_ID}/locations/{self.valves.LOCATION}/"
                f"reasoningEngines/{engine_id}:streamQuery"
            )
            
            headers = {
                "Authorization": f"Bearer {credentials.token}",
                "Content-Type": "application/json",
            }
            
            # ペイロード
            payload = {
                "input": {
                    "message": user_message,
                    "user_id": user_id
                }
            }
            
            # ストリーミングモード
            if body.get("stream", False):
                return self._stream_response(url, payload, headers)
            
            # 非ストリーミングモード
            else:
                response = requests.post(url=url, json=payload, headers=headers)
                response.raise_for_status()
                result = response.json()
                
                # テキストを抽出
                if isinstance(result, dict):
                    if 'content' in result and 'parts' in result['content']:
                        parts = result['content']['parts']
                        if len(parts) > 0 and 'text' in parts[0]:
                            return parts[0]['text']
                    elif 'text' in result:
                        return result['text']
                    else:
                        return json.dumps(result, indent=2, ensure_ascii=False)
                else:
                    return str(result)
                
        except Exception as e:
            import traceback
            error_details = traceback.format_exc()
            print(f"Error details: {error_details}")
            return f"Error: {str(e)}\n\nDetails:\n{error_details}"

    def _stream_response(self, url: str, payload: dict, headers: dict) -> Iterator[str]:
        """ストリーミングレスポンスを処理"""
        def stream_generator():
            try:
                response = requests.post(
                    url=url,
                    json=payload,
                    headers=headers,
                    stream=True
                )
                response.raise_for_status()
                
                for line in response.iter_lines():
                    if line:
                        try:
                            event = json.loads(line.decode('utf-8'))
                            
                            if isinstance(event, dict):
                                if 'content' in event and 'parts' in event['content']:
                                    parts = event['content']['parts']
                                    if len(parts) > 0 and 'text' in parts[0]:
                                        yield parts[0]['text']
                                elif 'text' in event:
                                    yield event['text']
                        except json.JSONDecodeError:
                            pass
            except Exception as e:
                yield f"\n\nError: {str(e)}"
        
        return stream_generator()
