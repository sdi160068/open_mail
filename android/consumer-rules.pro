# Keep the EmailContent class and its members from being obfuscated or removed.
-keep class com.cuboid.open_mail.EmailContent { *; }
-keepclassmembers class com.cuboid.open_mail.EmailContent { *; }

# Keep the App class and its members from being obfuscated or removed.
-keep class com.cuboid.open_mail.App { *; }
-keepclassmembers class com.cuboid.open_mail.App { *; }

# Keep GSON specific annotations and classes
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; } # Keep all Gson classes

# If you use @SerializedName annotation, keep the fields
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep constructors of data classes used with Gson
-keepclassmembers class com.cuboid.open_mail.EmailContent { 
    <init>(...);
}
-keepclassmembers class com.cuboid.open_mail.App { 
    <init>(...);
}
