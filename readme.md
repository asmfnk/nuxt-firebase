# 概要
Firebase上でNuxtを動かしている様々なサイトを参考にしつつ、詰まる部分が多かったので動作した流れをメモ
デプロイすると動くけど `firebase serve --only functions,hosting` はどうしてもダメだった

## デプロイ
```
# build
yarn build

# 静的ファイルの移動
bash deploy.sh

# こっちは動かない（原因不明）
# ブラウザで開くと `Cannot GET /{your-project}/us-central1/ssr/` と出る
firebase serve --only functions,hosting

# Firebaseデプロイ
firebase deploy
```

## 注意
cloud functionsにアップロードされるのは `/functions` なのでこのディレクトリでパッケージの追加と `yarn` するのを忘れないように  
 `firebase serve --only functions,hosting` が意外と信用ならないので、 `yarn dev` で開発して、Staging環境はFirebaseのプロジェクトをもう一つ作るのがいいと思われる

## ここまでの構成方法
nuxtアプリの作成
```
yarn create nuxt-app

=============

? Project name nuxt-firebase
? Project description My stellar Nuxt.js project
? Author name asmfnk
? Choose the package manager Yarn
? Choose UI framework Bulma
? Choose custom server framework None (Recommended)
? Choose Nuxt.js modules (Press <space> to select, <a> to toggle all, <i> to invert selection)
? Choose linting tools (Press <space> to select, <a> to toggle all, <i> to invert selection)
? Choose test framework None
? Choose rendering mode Universal (SSR)
```
PWA用のパッケージを追加
```
yarn add @nuxtjs/pwa
```
`nuxt.config.js` の修正
modulesとbuildDirに以下のものを追加
```
  modules: [
    '@nuxtjs/pwa',
  ],
  buildDir: './functions/nuxt',
```
firebaseのセットアップ
```
firebase init

================

? Which Firebase CLI features do you want to set up for this folder? Press Space to select features, then Enter to confirm your choices.
functions, hosting, firestoreを選択
? What language would you like to use to write Cloud Functions?
JavaScript
あとはデフォルトで
```
ここらへんで一回nuxtをbuild
```
yarn build
```
静的ファイルをコピーする `deploy.sh` の作成
```
#!/usr/bin/env bash

rm -rf public/*

cp -R functions/nuxt/dist/client public/assets

cp -R static/* public
```
`firebase.json` の修正
```
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "hosting": {
    "public": "public",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [{
      "source": "**",
      "function": "ssr"
    }]
  },
  "functions": {
    "source": "functions"
  }
}
```
`/functions/index.js` の修正
```
const functions = require('firebase-functions');
const { Nuxt } = require('nuxt');

const nuxt = new Nuxt({buildDir: 'nuxt', dev: false});

exports.ssr = functions.https.onRequest(nuxt.render);
```
`/functions` にもnuxtを入れる
```
yarn add nuxt
```
