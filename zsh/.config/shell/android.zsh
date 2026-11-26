NDK_VERSION=android-ndk-r11b
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_NDK_HOME="${ANDROID_NDK_HOME:-$ANDROID_HOME/ndk/$NDK_VERSION}"
[ -d "$ANDROID_HOME/platform-tools" ] && export PATH="$PATH:$ANDROID_HOME/platform-tools"
[ -d "$ANDROID_NDK_HOME" ] && export PATH="$PATH:$ANDROID_NDK_HOME"
