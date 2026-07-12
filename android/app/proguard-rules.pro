# Regras de R8/ProGuard do release.

# O flutter_local_notifications serializa os agendamentos com Gson para
# reagendá-los após o reboot. O R8 em full mode remove as assinaturas genéricas
# e os campos das classes de modelo, e o Gson passa a desserializar lixo — os
# lembretes simplesmente somem depois que o aparelho reinicia. Preservar:
-keep class com.dexterous.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keep class * extends com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# As APIs java.time vêm do desugaring; sem isso o R8 avisa de referências
# ausentes em aparelhos com minSdk baixo.
-dontwarn java.time.**
