# Instrucciones para Integrar Google Maps SDK

Este documento explica cómo integrar Google Maps en la pantalla de detalle de propiedad.

## Paso 1: Agregar la dependencia

Agrega el paquete `google_maps_flutter` a tu archivo `pubspec.yaml`:

```yaml
dependencies:
  google_maps_flutter: ^2.5.0
```

Luego ejecuta:
```bash
flutter pub get
```

## Paso 2: Obtener una API Key de Google Maps

1. Ve a la [Consola de Google Cloud](https://console.cloud.google.com/)
2. Selecciona tu proyecto (o crea uno nuevo)
3. Ve a **APIs & Services** > **Credentials**
4. Haz clic en **Create Credentials** > **API Key**
5. Copia la API Key generada

## Paso 3: Configurar la API Key en Android

### 3.1. Agregar la API Key en `android/app/src/main/AndroidManifest.xml`

Agrega la siguiente línea dentro de la etiqueta `<application>`:

```xml
<application>
    <!-- ... otras configuraciones ... -->
    
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="TU_API_KEY_AQUI"/>
</application>
```

### 3.2. Habilitar la API de Maps SDK para Android

1. En la [Consola de Google Cloud](https://console.cloud.google.com/)
2. Ve a **APIs & Services** > **Library**
3. Busca "Maps SDK for Android"
4. Haz clic en **Enable**

## Paso 4: Configurar la API Key en iOS (si aplica)

### 4.1. Agregar la API Key en `ios/Runner/AppDelegate.swift`

Agrega el siguiente código al inicio del método `application(_:didFinishLaunchingWithOptions:)`:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("TU_API_KEY_AQUI")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 4.2. Habilitar la API de Maps SDK para iOS

1. En la [Consola de Google Cloud](https://console.cloud.google.com/)
2. Ve a **APIs & Services** > **Library**
3. Busca "Maps SDK for iOS"
4. Haz clic en **Enable**

## Paso 5: Actualizar el modelo Property

Asegúrate de que el modelo `Property` tenga campos para la latitud y longitud:

```dart
final double? latitude;
final double? longitude;
```

Y actualiza los métodos `toMap()` y `fromMap()` para incluir estos campos.

## Paso 6: Actualizar PropertyDetailScreen

Reemplaza la sección de ubicación en `property_detail_screen.dart` con:

```dart
// Importar el paquete
import 'package:google_maps_flutter/google_maps_flutter.dart';

// En el widget de ubicación, reemplazar el Container con:
Container(
  height: 200,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.grey.shade300),
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(
          property.latitude ?? -33.4489, // Coordenadas por defecto (Santiago, Chile)
          property.longitude ?? -70.6693,
        ),
        zoom: 15.0,
      ),
      markers: {
        Marker(
          markerId: MarkerId(property.id),
          position: LatLng(
            property.latitude ?? -33.4489,
            property.longitude ?? -70.6693,
          ),
          infoWindow: InfoWindow(
            title: property.name,
            snippet: property.address,
          ),
        ),
      },
      mapType: MapType.normal,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
    ),
  ),
),
```

## Paso 7: Restricciones de la API Key (Recomendado)

Para mayor seguridad, restringe tu API Key:

1. En la [Consola de Google Cloud](https://console.cloud.google.com/)
2. Ve a **APIs & Services** > **Credentials**
3. Haz clic en tu API Key
4. En **Application restrictions**, selecciona:
   - **Android apps**: Agrega el package name y SHA-1 certificate fingerprint
   - **iOS apps**: Agrega el bundle identifier
5. En **API restrictions**, selecciona:
   - **Restrict key**
   - Selecciona solo "Maps SDK for Android" y/o "Maps SDK for iOS"

## Paso 8: Obtener el SHA-1 Certificate Fingerprint (Android)

Para desarrollo:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Para producción, usa el keystore de tu app.

## Notas Importantes

- **No subas tu API Key a repositorios públicos**. Usa variables de entorno o archivos de configuración que estén en `.gitignore`.
- La API Key tiene límites de uso. Considera implementar límites de cuota en la consola de Google Cloud.
- Para producción, crea una API Key separada con restricciones más estrictas.

## Solución de Problemas

### Error: "API key not valid"
- Verifica que la API Key esté correctamente configurada en los archivos de configuración
- Asegúrate de que las APIs estén habilitadas en Google Cloud Console
- Verifica que las restricciones de la API Key permitan tu aplicación

### El mapa no se muestra
- Verifica que tengas conexión a internet
- Revisa los logs de la consola para errores específicos
- Asegúrate de que las coordenadas sean válidas

### Error en iOS: "GMSServices not initialized"
- Verifica que hayas llamado a `GMSServices.provideAPIKey()` antes de usar el mapa
- Asegúrate de haber importado `GoogleMaps` en `AppDelegate.swift`

