package local.frame.floatinghome;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.provider.Settings;

public class BootReceiver extends BroadcastReceiver {
    @Override public void onReceive(Context context, Intent intent) {
        if ((Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())
                || Intent.ACTION_MY_PACKAGE_REPLACED.equals(intent.getAction()))
                && context.getSharedPreferences("home", Context.MODE_PRIVATE).getBoolean("enabled", true)
                && Settings.canDrawOverlays(context)) {
            context.startService(new Intent(context, HomeService.class));
            android.util.Log.i("FloatingHome", "Automatic start: " + intent.getAction());
        }
    }
}
