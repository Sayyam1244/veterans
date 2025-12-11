# Stripe Android SDK ProGuard rules
-keep class com.stripe.android.** { *; }
-keep class com.stripe.android.stripe3ds2.** { *; }
-keep class com.stripe.android.view.** { *; }
-dontwarn com.stripe.android.**

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep Stripe model classes
-keep class com.stripe.android.model.** { *; }
-keep class com.stripe.android.core.** { *; }

# Keep classes that use reflection
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}