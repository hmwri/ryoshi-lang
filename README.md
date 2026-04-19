# Ryoshi-lang

Ryoshi-lang は、量子ゲートの詳細を意識せずに量子プログラムを書けることを目指した、量子コンピュータ向けプログラミング言語です。Processing ベースのエディタ上でコードを編集し、Ryoshi-Compiler が Python コードへ変換し、`ryoshiLibrary.py` を通して Qiskit 上で実行します。

プロジェクトの背景と狙いは、作者のプロジェクトページおよび同梱した報告書で説明されています。

- Project page: https://www.honma.site/ja/works/RyoshiLang/
- Report PDF: [docs/ryoshi-lang-report.pdf](docs/ryoshi-lang-report.pdf)

## Concept

Ryoshi-lang は、量子回路を直接組み立てるのではなく、古典的な言語に近い記法で量子プログラムを書けるように設計されています。たとえば `int4 a = all` で全状態の重ね合わせを作り、`a == b` のような比較や、`mark` による位相反転、`up` による Diffuser 適用、`?a,b` による観測を簡潔に記述できます。

量子計算の制約も言語仕様に反映されています。破壊的な再代入や値のコピーを避け、必要に応じてコンパイラ側が補助レジスタを自動生成します。

## Architecture

このリポジトリには大きく 3 つの層があります。

- `*.pde`: Processing で書かれた Ryoshi-Editor / Ryoshi-Compiler
- `data/ryoshiLibrary.py`: 生成コードが利用する Python ランタイム
- `pyproject.toml`: Python 依存関係の定義

実行の流れは次の通りです。

1. Processing 上のエディタで Ryoshi-lang のコードを編集する
2. コンパイラが字句解析、構文解析、意味解析を行う
3. Python コードを `data/compiled.py` として生成する
4. `ryoshiLibrary.py` 経由で Qiskit 上で回路を実行する
5. 実行結果と回路図を UI に反映する

## Language Overview

現在の実装で中心となる機能は以下です。

- 固定ビット幅の整数型と `bool`
- `all` による全組み合わせの重ね合わせ生成
- `2 | 3` のような 2 値の重ね合わせ生成
- `==`, `!=`, `and`, `or`, `!` などの式
- `a += b`, `a -= b` のような更新演算
- `mark` による位相反転
- `up` による Diffuser 適用
- `?a,b` による観測
- `@shots`, `@device`, `@grover` による実行設定

設計意図や各機能の意味づけは、報告書にある説明とおおむね対応しています。

## Setup

### Requirements

- Processing
- `uv`
- Python 3.11

このプロジェクトは、現在の IBMQ 依存との整合性のため Python 3.11 に固定しています。

### First Launch

アプリ起動時、`.venv` が存在しなければ `uv` を探し、自動で `uv sync` を実行します。`uv` が見つからない場合は、コンソールにセットアップ失敗が表示されます。

手動でセットアップする場合は以下を実行してください。

```bash
uv sync
```

## Running

Processing でこのプロジェクトを開いてスケッチを実行してください。エディタ上のコードは Python に変換され、プロジェクト内の仮想環境で実行されます。

ローカルシミュレータ実行は `@device simulator`、実機実行は `@device actual` を使います。

## IBM Quantum

実機実行時は `data/ryoshiLibrary.py` 内の `IBMQ.load_account()` を使います。既存実装は古い IBMQ API に依存しており、認証情報は通常、環境変数またはユーザー環境の `~/.qiskit/qiskitrc` から読み込まれます。

このリポジトリでは、ローカル認証状態や秘密情報をコミットしないように、`qiskitrc`、`qiskit-ibm.json`、`.env*`、`.venv/` などを `.gitignore` に含めています。

## Status

このリポジトリは、Processing ベースのエディタと Python ランタイムを含む、Ryoshi-lang の実装アーカイブです。公開用に、Python 環境の `uv` 管理と初回セットアップの自動化を追加しています。

一方で、実機認証まわりは旧 IBMQ API ベースのままで、将来的な移行が必要です。

## TODO

- `IBMQ` ベースの実機実行を新しい IBM Quantum 系 API に移行する
- 実機認証まわりの扱いを整理し、設定方法を明文化する

