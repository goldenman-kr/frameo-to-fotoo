package local.frame.floatinghome;

import android.app.Notification;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.graphics.drawable.GradientDrawable;
import android.os.IBinder;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.Toast;

public class HomeService extends Service {
    private WindowManager manager;
    private WindowManager.LayoutParams position;
    private LinearLayout controls;
    private int corner;
    private final Handler handler = new Handler(Looper.getMainLooper());
    private boolean backPending;
    private volatile boolean destroyed;
    private volatile Process backProcess;

    @Override public void onCreate() {
        super.onCreate();
        PendingIntent open = PendingIntent.getActivity(this, 0,
                new Intent(this, MainActivity.class), PendingIntent.FLAG_UPDATE_CURRENT);
        Notification note = new Notification.Builder(this)
                .setSmallIcon(android.R.drawable.ic_menu_view)
                .setContentTitle("Floating Home 실행 중")
                .setContentText("홈 · 뒤로가기 / 끌어 놓으면 해당 모서리로 이동")
                .setContentIntent(open).setOngoing(true).build();
        startForeground(1, note);
        if (!Settings.canDrawOverlays(this)) { stopSelf(); return; }
        manager = (WindowManager) getSystemService(WINDOW_SERVICE);
        int size = Math.round(56 * getResources().getDisplayMetrics().density);
        position = new WindowManager.LayoutParams(size * 2, size,
                WindowManager.LayoutParams.TYPE_PHONE,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
                PixelFormat.TRANSLUCENT);
        position.gravity = Gravity.TOP | Gravity.LEFT;
        // Position has its own file: the overlay process must not overwrite the
        // main process's enabled/automatic-start preference with a cached copy.
        android.content.SharedPreferences saved = getSharedPreferences("position", MODE_PRIVATE);
        if (saved.contains("corner")) {
            corner = saved.getInt("corner", 0) & 3;
        } else {
            android.content.SharedPreferences legacy = getSharedPreferences("home", MODE_PRIVATE);
            android.util.DisplayMetrics metrics = displayMetrics();
            corner = CornerPosition.quadrant(legacy.getInt("x", 16),
                    legacy.getInt("y", 180), size * 2, size, metrics.widthPixels, metrics.heightPixels);
        }
        snapToCorner();
        controls = new LinearLayout(this);
        controls.setOrientation(LinearLayout.HORIZONTAL);
        controls.setAlpha(0.25f);
        GradientDrawable background = new GradientDrawable();
        background.setColor(0xFF334658);
        background.setCornerRadius(size / 2f);
        controls.setBackground(background);
        View homeButton = makeButton(false, "홈 화면으로 이동", size);
        View backButton = makeButton(true, "뒤로가기", size);
        controls.addView(homeButton);
        controls.addView(backButton);
        homeButton.setOnClickListener(v -> {
            android.util.Log.i("FloatingHome", "Home button clicked");
            Intent home = new Intent(Intent.ACTION_MAIN);
            home.addCategory(Intent.CATEGORY_HOME);
            home.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED);
            startActivity(home);
        });
        backButton.setOnClickListener(v -> goBack());
        View.OnTouchListener drag = new View.OnTouchListener() {
            float startX, startY;
            int oldX, oldY;
            boolean moved;
            final int slop = ViewConfiguration.get(HomeService.this).getScaledTouchSlop();
            @Override public boolean onTouch(View view, MotionEvent event) {
                switch (event.getActionMasked()) {
                    case MotionEvent.ACTION_DOWN:
                        startX = event.getRawX(); startY = event.getRawY();
                        oldX = position.x; oldY = position.y; moved = false;
                        return true;
                    case MotionEvent.ACTION_MOVE:
                        float dx = event.getRawX() - startX, dy = event.getRawY() - startY;
                        if (dx * dx + dy * dy > slop * slop) moved = true;
                        if (moved) {
                            position.x = oldX + Math.round(dx); position.y = oldY + Math.round(dy);
                            clampPosition(); manager.updateViewLayout(controls, position);
                        }
                        return true;
                    case MotionEvent.ACTION_UP:
                        if (!moved) view.performClick();
                        else finishDrag();
                        return true;
                    case MotionEvent.ACTION_CANCEL:
                        snapToCorner();
                        manager.updateViewLayout(controls, position);
                        return true;
                    default: return false;
                }
            }
        };
        homeButton.setOnTouchListener(drag);
        backButton.setOnTouchListener(drag);
        manager.addView(controls, position);
        controls.post(() -> logPosition());
    }

    private View makeButton(final boolean back, String description, int size) {
        View view = new View(this) {
            private final android.graphics.Paint paint = new android.graphics.Paint(
                    android.graphics.Paint.ANTI_ALIAS_FLAG);
            @Override protected void onDraw(android.graphics.Canvas canvas) {
                super.onDraw(canvas);
                float cx = getWidth() / 2f, cy = getHeight() / 2f;
                float unit = Math.min(getWidth(), getHeight()) / 56f;
                paint.setColor(Color.WHITE);
                paint.setStyle(android.graphics.Paint.Style.STROKE);
                paint.setStrokeWidth(2.5f * unit);
                paint.setStrokeCap(android.graphics.Paint.Cap.ROUND);
                paint.setStrokeJoin(android.graphics.Paint.Join.ROUND);
                android.graphics.Path icon = new android.graphics.Path();
                if (back) {
                    icon.moveTo(cx + 5 * unit, cy - 10 * unit);
                    icon.lineTo(cx - 5 * unit, cy);
                    icon.lineTo(cx + 5 * unit, cy + 10 * unit);
                } else {
                    icon.moveTo(cx - 11 * unit, cy - 1 * unit);
                    icon.lineTo(cx, cy - 10 * unit);
                    icon.lineTo(cx + 11 * unit, cy - 1 * unit);
                    icon.moveTo(cx - 8 * unit, cy - 3 * unit);
                    icon.lineTo(cx - 8 * unit, cy + 10 * unit);
                    icon.lineTo(cx - 3 * unit, cy + 10 * unit);
                    icon.lineTo(cx - 3 * unit, cy + 3 * unit);
                    icon.lineTo(cx + 3 * unit, cy + 3 * unit);
                    icon.lineTo(cx + 3 * unit, cy + 10 * unit);
                    icon.lineTo(cx + 8 * unit, cy + 10 * unit);
                    icon.lineTo(cx + 8 * unit, cy - 3 * unit);
                }
                canvas.drawPath(icon, paint);
            }
        };
        view.setLayoutParams(new LinearLayout.LayoutParams(size, size));
        view.setContentDescription(description);
        return view;
    }

    private void goBack() {
        if (backPending) return;
        backPending = true;
        new Thread(() -> {
            int result = -1;
            Runnable timeout = null;
            Process process = null;
            try {
                process = Runtime.getRuntime().exec(new String[] {
                        "su", "-c", "/system/bin/input keyevent 4" });
                backProcess = process;
                final Process running = process;
                timeout = () -> running.destroy();
                handler.postDelayed(timeout, 5000);
                result = process.waitFor();
            } catch (Exception error) {
                if (error instanceof InterruptedException) Thread.currentThread().interrupt();
            } finally {
                if (timeout != null) handler.removeCallbacks(timeout);
                if (process != null) process.destroy();
                backProcess = null;
            }
            final int exitCode = result;
            handler.post(() -> {
                backPending = false;
                if (destroyed) return;
                android.util.Log.i("FloatingHome", "Back command exit " + exitCode);
                if (exitCode != 0) Toast.makeText(this,
                        "뒤로가기를 실행하지 못했습니다. 루트 권한을 확인해 주세요.",
                        Toast.LENGTH_LONG).show();
            });
        }, "FloatingHomeBack").start();
    }

    private void logPosition() {
        if (destroyed) return;
        int[] screen = new int[2];
        controls.getLocationOnScreen(screen);
        android.util.DisplayMetrics metrics = displayMetrics();
        android.util.Log.i("FloatingHome", "Overlay corner " + corner + " screen "
                + screen[0] + "," + screen[1] + " size " + controls.getWidth() + "x"
                + controls.getHeight() + " bounds " + metrics.widthPixels + "x"
                + metrics.heightPixels + " alpha " + controls.getAlpha());
    }

    private void clampPosition() {
        android.util.DisplayMetrics metrics = displayMetrics();
        position.x = Math.max(0, Math.min(position.x, metrics.widthPixels - position.width));
        position.y = Math.max(0, Math.min(position.y, metrics.heightPixels - position.height));
    }

    private android.util.DisplayMetrics displayMetrics() {
        android.util.DisplayMetrics metrics = new android.util.DisplayMetrics();
        manager.getDefaultDisplay().getMetrics(metrics);
        return metrics;
    }

    private void snapToCorner() {
        android.util.DisplayMetrics metrics = displayMetrics();
        position.x = CornerPosition.x(corner, position.width, metrics.widthPixels);
        position.y = CornerPosition.y(corner, position.height, metrics.heightPixels);
        getSharedPreferences("position", MODE_PRIVATE).edit().putInt("corner", corner).apply();
    }

    private void finishDrag() {
        android.util.DisplayMetrics metrics = displayMetrics();
        corner = CornerPosition.quadrant(position.x, position.y, position.width,
                position.height, metrics.widthPixels, metrics.heightPixels);
        snapToCorner();
        manager.updateViewLayout(controls, position);
        controls.post(() -> logPosition());
    }

    @Override public void onConfigurationChanged(Configuration config) {
        super.onConfigurationChanged(config);
        if (controls != null) {
            snapToCorner(); manager.updateViewLayout(controls, position);
            controls.post(() -> logPosition());
        }
    }
    @Override public int onStartCommand(Intent intent, int flags, int startId) { return START_STICKY; }
    @Override public IBinder onBind(Intent intent) { return null; }
    @Override public void onDestroy() {
        destroyed = true;
        if (backProcess != null) backProcess.destroy();
        handler.removeCallbacksAndMessages(null);
        if (controls != null) manager.removeView(controls);
        stopForeground(true);
        super.onDestroy();
    }
}
