#!/bin/bash

# Install dependencies
apt update && apt install git curl lib32stdc++6 xz-utils android-sdk -y
curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh
bash nodesource_setup.sh
apt install -y nodejs
npm install -g firebase-tools

#Download git repo
#git clone https://gitlab.com/hector.ballegafernandez/chitchat.git
#cd chitchat
#git checkout develop

#Deploy firebase configuration and functions
cd backend/functions
npm install .
cd ..
firebase deploy --only functions --token "1/fW0DySUATxuYJs9lqHlNjwGpHhHf5kzl8oZE44SULGY"

cd ..

#Download flutter
curl -sL https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_v1.0.0-stable.tar.xz -o flutter.tar.xz
tar xf flutter.tar.xz
export PATH=$PATH:`pwd`/flutter/bin
cd frontend
flutter doctor -v

#Deploy flutter application
flutter run
