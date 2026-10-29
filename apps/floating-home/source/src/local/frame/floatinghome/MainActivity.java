package local.frame.floatinghome;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Settings;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

public class MainActivity extends Activity {
    private TextView status;
    private boolean permissionRequested;

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setPadding(32, 32, 32, 32);
        TextView info = new TextView(this);
        info.setText("Floating Home\n\n왼쪽은 홈, 오른쪽은 뒤로가기입니다.\n어느 버튼이든 끌어 놓으면 해당 사분면의 모서리로 붙습니다.\n버튼의 불투명도는 25%입니다.\n뒤로가기는 이 단말의 su 권한을 사용합니다.\n\n켜 둔 상태에서는 부팅 후 자동으로 표시합니다.");
        info.setTextSize(20);
        root.addView(info);
        status = new TextView(this);
        root.addView(status);
        Button start = new Button(this);
        start.setText("홈 버튼 켜기 / 표시 권한 허용");
        start.setOnClickListener(v -> {
            if (!Settings.canDrawOverlays(this)) {
                permissionRequested = true;
                startActivity(new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:" + getPackageName())));
            } else enable();
        });
        root.addView(start);
        Button stop = new Button(this);
        stop.setText("홈 버튼 끄기 (자동 시작도 끔)");
        stop.setOnClickListener(v -> {
            getSharedPreferences("home", MODE_PRIVATE).edit().putBoolean("enabled", false).apply();
            stopService(new Intent(this, HomeService.class));
            status.setText("꺼짐");
        });
        root.addView(stop);
        Button settings = new Button(this);
        settings.setText("Android 설정 열기");
        settings.setOnClickListener(v -> startActivity(new Intent(Settings.ACTION_SETTINGS)));
        root.addView(settings);
        setContentView(root);
    }

    private void enable() {
        getSharedPreferences("home", MODE_PRIVATE).edit().putBoolean("enabled", true).apply();
        startService(new Intent(this, HomeService.class));
        status.setText("홈 버튼 켜짐");
    }

    @Override public void onResume() {
        super.onResume();
        boolean allowed = Settings.canDrawOverlays(this);
        if (permissionRequested && allowed) {
            permissionRequested = false;
            enable();
        } else if (allowed && getSharedPreferences("home", MODE_PRIVATE).getBoolean("enabled", true)) {
            enable();
        } else status.setText(allowed ? "홈 버튼 꺼짐" : "먼저 표시 권한을 허용해 주세요.");
    }
}
