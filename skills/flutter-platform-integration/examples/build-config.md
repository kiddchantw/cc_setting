# Build Configuration Examples

## iOS Build Configuration

### Code Signing
```bash
# Automatic signing (recommended for development)
# Configure in Xcode: Signing & Capabilities → Automatically manage signing

# Manual signing (for production)
# 1. Create provisioning profiles in Apple Developer Portal
# 2. Download and install certificates
# 3. Configure in Xcode
```

### Build Commands
```bash
# Build iOS app
flutter build ios --release

# Build with specific bundle ID
flutter build ios --release --bundle-id com.example.myapp

# Build with custom export options
flutter build ipa --export-options-plist=ExportOptions.plist
```

### ExportOptions.plist Example
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
```

## Android Build Configuration

### Signing Configuration

#### Create Keystore
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

#### key.properties
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

#### build.gradle Configuration
```gradle
// Load key properties
def keystorePropertiesFile = rootProject.file('key.properties')
def keystoreProperties = new Properties()
keystoreProperties.load(new FileInputStream(keystorePropertiesFile))

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### Build Commands
```bash
# Build Android APK
flutter build apk --release

# Build Android App Bundle (for Play Store)
flutter build appbundle --release

# Build with split APKs per ABI
flutter build apk --split-per-abi

# Build with specific flavor
flutter build apk --flavor production -t lib/main_production.dart
```

## Deep Links Configuration

### iOS Universal Links

#### apple-app-site-association (host on your server)
```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.example.myapp",
        "paths": ["/product/*", "/user/*"]
      }
    ]
  }
}
```

### Android App Links

#### AndroidManifest.xml
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="example.com" />
</intent-filter>
```

#### assetlinks.json (host on your server)
```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.example.myapp",
    "sha256_cert_fingerprints": ["YOUR_SHA256_FINGERPRINT"]
  }
}]
```

## Troubleshooting

### Common iOS Issues
| Issue | Solution |
|-------|----------|
| Pods not found | Run `pod install` in `ios/` directory |
| Signing errors | Check certificates and provisioning profiles |
| Build fails | Clean with `flutter clean` |

### Common Android Issues
| Issue | Solution |
|-------|----------|
| Gradle build fails | Check Gradle version compatibility |
| Multi-dex required | Enable `multiDexEnabled true` in build.gradle |
| Dependency conflicts | Resolve version conflicts in build.gradle |
