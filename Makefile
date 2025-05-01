connect:
	adb tcpip 5555
	adb connect ${ip}

build-financial:
    flutter build apk --release --dart-define=USER_NAME=${name}