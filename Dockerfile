# debian Ver.10 を使用する
ARG VARIANT="buster"
FROM debian:${VARIANT}

# 1. コンテナの日本語化開始 （以下 debian 公式の手順）
RUN apt-get update && apt-get install -y \
  # a) ロケールのバイナリ取得
  locales \
  # b) ロケールのコンパイル（locale-gen があればそちらを使う）
  && localedef -i ja_JP -c -f UTF-8 -A /usr/share/locale/locale.alias ja_JP.UTF-8
# 日本語指定
ENV LANG ja_JP.UTF-8

# タイムゾーンの変更（Asia/Tokyo のシンボリックリンクを作成する。通常のコピーでも大丈夫）（＊＊）
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
  # 下はあまり使われないようだが、念のため
  && echo Asia/Tokyo > /etc/timezone

# 2. COBOL 取得（＊＊）
RUN apt-get install -y \
  open-cobol \
  # （下は、デバッグ実行に必要）
  gdb

# 3. apt-get した後に良くやるおまじない。キャッシュの削除（＊＊）
RUN rm -rf /var/lib/apt/lists/*

# （＊＊） 本来なら最初の RUN と一緒にまとめて実行するが、説明のため何回かに分けておく

# おまけ
# 以下を指定すると、対話型のコマンドが問答無用で黙るようになるが、docker 公式で非推奨だよ
# RUN export DEBIAN_FRONTEND=noninteractive

# ++++++++++++++++++++++++++++++

# LT用ユーザの作成
COPY provisioning /
RUN bash /provisioning

# LT用資材のコピー
WORKDIR /lt_1-d/
COPY ./lt_1-d/ /lt_1-d/
COPY --chown=meister:cobolist tgs-tech.sh /lt_1-d/
