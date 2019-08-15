package com.jvtd.flutter_pjsip.ui;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.media.AudioManager;
import android.media.SoundPool;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.PowerManager;
import android.os.Vibrator;
import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.jvtd.flutter_pjsip.FlutterPjsipPlugin;
import com.jvtd.flutter_pjsip.R;
import com.jvtd.flutter_pjsip.entity.MSG_TYPE;
import com.jvtd.flutter_pjsip.entity.MyCall;
import com.jvtd.flutter_pjsip.utils.PermissionsUtils;
import com.jvtd.flutter_pjsip.utils.SimpleDateFormatUtils;
import com.jvtd.flutter_pjsip.utils.SoundPoolUtil;
import com.jvtd.flutter_pjsip.utils.ToastUtil;

import org.pjsip.pjsua2.CallInfo;
import org.pjsip.pjsua2.CallOpParam;
import org.pjsip.pjsua2.pjsip_inv_state;
import org.pjsip.pjsua2.pjsip_role_e;
import org.pjsip.pjsua2.pjsip_status_code;

import java.util.Timer;
import java.util.TimerTask;

public class CallActivity extends AppCompatActivity implements SensorEventListener, SoundPool.OnLoadCompleteListener, View.OnClickListener
{
  private final String[] mSipPermission = {Manifest.permission.RECORD_AUDIO, Manifest.permission.MODIFY_AUDIO_SETTINGS, Manifest.permission.PROCESS_OUTGOING_CALLS};
  //创建监听权限的接口对象
  private PermissionsUtils.IPermissionsResult permissionsResult = new PermissionsUtils.IPermissionsResult()
  {
    @Override
    public void passPermissons()
    {
      initSoundPool();
    }

    @Override
    public void forbitPermissons()
    {
      ToastUtil.showToast(CallActivity.this, "语音通话需要您开启电话权限");
    }
  };

  private TextView tvName;
  private TextView tvPhone;
  private TextView tvStatus;
  private TextView tvTips;
  private LinearLayout llCallingState;
  private TextView tvMute;
  private TextView tvHandsFree;
  private ImageView ivHangup;
  private LinearLayout llReceiveCallState;
  private TextView tvRefuse;
  private TextView tvAccept;

  private String mUsername;
  private String mIp;
  private String mPort;

  public static Handler handler_;
  private final Handler handler = new Handler(new Handler.Callback()
  {
    @Override
    public boolean handleMessage(Message msg)
    {
      int what = msg.what;
      switch (what)
      {
        case MSG_TYPE.CALL_STATE:
          mLastCallInfo = (CallInfo) msg.obj;
          updateCallState(mLastCallInfo);
          break;

        case MSG_TYPE.CALL_MEDIA_STATE:
          // 未实现视频，不用实现
          break;
      }
      return false;
    }
  });


  private AudioManager mAudioManager;// 音频管理器
  private Vibrator mVibrator;
  private SoundPoolUtil mSoundPoolUtil;
  private int mSoundWaitId = 0;
  private PowerManager.WakeLock mWakeLock;// 电源锁
  private SensorManager mSensorManager;// 传感器管理对象
  private boolean mIsMute;// 是否静音的标志
  private boolean mIsHF;// 是否免提的标志

  private TelephonyManager telephony;
  private MyPhoneStateListener linPhoneStateListener;
  private Timer timer = new Timer();
  private long time = 0L;
  private TimerTask task = new TimerTask()
  {
    @Override
    public void run()
    {
      runOnUiThread(new Runnable()
      {
        @Override
        public void run()
        {
          time++;
          updateTime();
        }
      });
    }
  };
  /**
   * 通话是否已经建立过连接的标志
   */
  private boolean mCallIsConnected;
  /**
   * 是否为来电
   */
  private boolean mIsIncomingCall;
  /**
   * 记录已存在的CallInfo
   */
  private CallInfo mLastCallInfo;

  @Override
  protected void onCreate(Bundle savedInstanceState)
  {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_call);

    getIntentData();
    initViews();

    mAudioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
    PowerManager powerManager = (PowerManager) getSystemService(Context.POWER_SERVICE);
    // 距离感应器的电源锁
    // PowerManager.PROXIMITY_SCREEN_OFF_WAKE_LOCK 值为 32
    mWakeLock = powerManager.newWakeLock(32, getClass().getName());
    mWakeLock.setReferenceCounted(false); // 设置不启用引用计数

    // 传感器管理对象,调用距离传感器，控制屏幕
    mSensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);

    mVibrator = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);

    handler_ = handler;

    //监听电话
    telephony = (TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE);
    linPhoneStateListener = new MyPhoneStateListener();
    telephony.listen(linPhoneStateListener, PhoneStateListener.LISTEN_CALL_STATE);

    // 校验权限
    PermissionsUtils.getInstance().chekPermissions(this, mSipPermission, permissionsResult);

    if (FlutterPjsipPlugin.mCurrentCall != null)
    {
      try
      {
        mLastCallInfo = FlutterPjsipPlugin.mCurrentCall.getInfo();
        updateCallState(mLastCallInfo);
      } catch (Exception e)
      {
        e.printStackTrace();
      }
    }
  }

  private void getIntentData()
  {
    Intent intent = getIntent();
    mUsername = intent.getStringExtra("username");
    mIp = intent.getStringExtra("ip");
    mPort = intent.getStringExtra("port");
    mIsIncomingCall = intent.getBooleanExtra("is_incoming_call", false);
  }

  private void initViews()
  {
    tvName = findViewById(R.id.linphone_name);
    tvPhone = findViewById(R.id.linphone_phone);
    tvStatus = findViewById(R.id.linphone_status);
    tvTips = findViewById(R.id.linphone_tips);
    tvMute = findViewById(R.id.linphone_mute_btn);
    llCallingState = findViewById(R.id.ll_calling_state);
    tvHandsFree = findViewById(R.id.linphone_handsfree_btn);
    ivHangup = findViewById(R.id.linphone_hangup_btn);
    llReceiveCallState = findViewById(R.id.ll_reveive_call_state);
    tvRefuse = findViewById(R.id.linphone_refuse);
    tvAccept = findViewById(R.id.linphone_accept);
    tvMute.setOnClickListener(this);
    tvHandsFree.setOnClickListener(this);
    ivHangup.setOnClickListener(this);
    tvRefuse.setOnClickListener(this);
    tvAccept.setOnClickListener(this);
  }

  /**
   * 初始化SoundPool
   *
   * @author Jack Zhang
   * create at 2019-08-14 15:44
   */
  private void initSoundPool()
  {
    mSoundPoolUtil = new SoundPoolUtil(this, this);
    int rawId = mIsIncomingCall ? R.raw.incoming_ring : R.raw.ring_back;
    mSoundWaitId = mSoundPoolUtil.load(rawId);
  }

  private void stopRingBackSound()
  {
    if (mSoundPoolUtil != null && mSoundWaitId != 0)
    {
      mSoundPoolUtil.stop(mSoundWaitId);
      mSoundWaitId = 0;
      mSoundPoolUtil.destroy();
    }
  }

  /**
   * 更新电话状态，更新UI
   *
   * @author Jack Zhang
   * create at 2019-08-13 16:23
   */
  private void updateCallState(CallInfo callInfo)
  {
    if (callInfo == null)
    {
      close("语音通话异常，请稍后再试");
      return;
    }

//    int id = callInfo.getId();
//    int accId = callInfo.getAccId();
//    String callIdString = callInfo.getCallIdString();
//    String lastReason = callInfo.getLastReason();
//    String localContact = callInfo.getLocalContact();
//    String localUri = callInfo.getLocalUri();
//    String remoteContact = callInfo.getRemoteContact();
    String remoteUri = callInfo.getRemoteUri();

//    StringBuilder sb = new StringBuilder();
//    sb.append("id = ").append(id).append("\n");
//    sb.append("accId = ").append(accId).append("\n");
//    sb.append("callIdString = ").append(callIdString).append("\n");
//    sb.append("lastReason = ").append(lastReason).append("\n");
//    sb.append("localContact = ").append(localContact).append("\n");
//    sb.append("localUri = ").append(localUri).append("\n");
//    sb.append("remoteContact = ").append(remoteContact).append("\n");
//    sb.append("remoteUri = ").append(remoteUri).append("\n");
//    Log.i("CallInfo", sb.toString());

    if (!TextUtils.isEmpty(remoteUri))
    {
      tvName.setText(remoteUri.substring(remoteUri.indexOf(":") + 1, remoteUri.indexOf("@")));
      tvPhone.setText(remoteUri);
    }
    if (callInfo.getState().swigValue() < pjsip_inv_state.PJSIP_INV_STATE_CONFIRMED.swigValue())
    {
      if (callInfo.getRole() == pjsip_role_e.PJSIP_ROLE_UAS)// 电话呼入
      {
        tvStatus.setText("新的来电...");
        tvTips.setText("请接听");
        llReceiveCallState.setVisibility(View.VISIBLE);
        llCallingState.setVisibility(View.GONE);
      } else if (callInfo.getRole() == pjsip_role_e.PJSIP_ROLE_UAC)// 电话呼出
      {
        tvStatus.setText("正在呼叫...");
        tvTips.setText("请耐心等待");
        llReceiveCallState.setVisibility(View.GONE);
        llCallingState.setVisibility(View.VISIBLE);
      }
    } else if (callInfo.getState().swigValue() >= pjsip_inv_state.PJSIP_INV_STATE_CONFIRMED.swigValue())
    {
      llReceiveCallState.setVisibility(View.GONE);
      llCallingState.setVisibility(View.VISIBLE);
      if (callInfo.getState() == pjsip_inv_state.PJSIP_INV_STATE_CONFIRMED)// 已接听，正在通话中 状态
      {
        mCallIsConnected = true;

        tvMute.setVisibility(View.VISIBLE);
        tvHandsFree.setVisibility(View.VISIBLE);

        stopRingBackSound();
        // 通话状态被确认，震动500ms
        mVibrator.vibrate(500);
        // 设置
        setSpeakerphoneOn(mIsHF);
        setMicrophoneMute(mIsMute);
        tvStatus.setText("通话中...");
        updateTime();
        timer.schedule(task, 1000, 1000);// timeTask
      } else if (callInfo.getState() == pjsip_inv_state.PJSIP_INV_STATE_DISCONNECTED)// 已断开状态
      {
        close(mCallIsConnected ? "通话结束" : mIsIncomingCall ? "对方已取消" : "对方不在线或对方正忙，请稍后再试");
        mCallIsConnected = false;
      }
    }
  }

  private void updateTime()
  {
    String timeString;
    if (time < 3600)
      timeString = SimpleDateFormatUtils.newInstance().long2StringMS(time * 1000);
    else
      timeString = SimpleDateFormatUtils.newInstance().long2StringHMSNoYMD(time * 1000);
    String timeStr = "通话时长  " + timeString;
    tvTips.setText(timeStr);
  }

  @Override
  protected void onResume()
  {
    super.onResume();
    // 注册距离监听
    // 注册传感器，第一个参数为距离监听器，第二个是传感器类型，第三个是延迟类型
    if (mSensorManager != null)
      mSensorManager.registerListener(this, mSensorManager.getDefaultSensor(Sensor.TYPE_PROXIMITY), SensorManager.SENSOR_DELAY_NORMAL);
  }

  @Override
  protected void onPause()
  {
    super.onPause();
    if (mSensorManager != null)
      mSensorManager.unregisterListener(this);
  }

  /**
   * 点击事件监听
   *
   * @author Jack Zhang
   * create at 2019-08-13 15:41
   */
  @Override
  public void onClick(View v)
  {
    int id = v.getId();
    if (id == R.id.linphone_mute_btn)
    {
      mIsMute = !mIsMute;
      setMicrophoneMute(mIsMute);
    } else if (id == R.id.linphone_handsfree_btn)
    {
      mIsHF = !mIsHF;
      setSpeakerphoneOn(mIsHF);
    } else if (id == R.id.linphone_hangup_btn)
      close(mCallIsConnected ? "通话结束" : "您已取消");
    else if (id == R.id.linphone_refuse)
      close(null);
    else if (id == R.id.linphone_accept)
    {
      try
      {
        CallOpParam prm = new CallOpParam();
        prm.setStatusCode(pjsip_status_code.PJSIP_SC_OK);
        FlutterPjsipPlugin.mCurrentCall.answer(prm);
        updateCallState(FlutterPjsipPlugin.mCurrentCall.getInfo());
      } catch (Exception e)
      {
        e.printStackTrace();
      }
    }
  }

  /**
   * 设置静音
   *
   * @author Jack Zhang
   * create at 2019-08-13 15:47
   */
  private void setMicrophoneMute(boolean isMute)
  {
    tvMute.setSelected(isMute);
    mAudioManager.setMicrophoneMute(isMute);
  }

  /**
   * 设置免提
   *
   * @author Jack Zhang
   * create at 2019-08-13 15:48
   */
  private void setSpeakerphoneOn(boolean isHF)
  {
    tvHandsFree.setSelected(isHF);
    mAudioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
    mAudioManager.setSpeakerphoneOn(isHF);
    setVolumeControlStream(AudioManager.STREAM_VOICE_CALL);
  }

  private void close(String error)
  {
    handler_ = null;

    if (FlutterPjsipPlugin.mCurrentCall != null)
    {
      try
      {
        CallOpParam prm = new CallOpParam();
        prm.setStatusCode(pjsip_status_code.PJSIP_SC_DECLINE);
        FlutterPjsipPlugin.mCurrentCall.hangup(prm);
      } catch (Exception e)
      {
        System.out.println(e);
      } finally
      {
        FlutterPjsipPlugin.mCurrentCall = null;
      }
    }

    if (!TextUtils.isEmpty(error))
    {
      ToastUtil.showToast(this, error);
      new Handler().postDelayed(new Runnable()
      {
        @Override
        public void run()
        {
          finishSipActivity();

        }
      }, 500);
    } else
      finishSipActivity();
  }

  /**
   * SoundPool加载完成监听
   *
   * @author Jack Zhang
   * create at 2019-08-13 15:39
   */
  @Override
  public void onLoadComplete(SoundPool soundPool, int sampleId, int status)
  {
    if (mIsIncomingCall)
      mSoundPoolUtil.play(mSoundWaitId);
    else
    {
      MyCall call = new MyCall(FlutterPjsipPlugin.mAccount, -1);
      CallOpParam prm = new CallOpParam(true);
//    prm.getOpt().setAudioCount(1);
//    prm.getOpt().setVideoCount(1);
      String uri = "sip:" + mUsername + "@" + mIp + ":" + mPort;
      try
      {
        call.makeCall(uri, prm);
      } catch (Exception e)
      {
        call.delete();
        return;
      }
      FlutterPjsipPlugin.mCurrentCall = call;

      mSoundPoolUtil.play(mSoundWaitId);
    }
  }

  /**
   * 距离传感器监听
   *
   * @author Jack Zhang
   * create at 2019-08-13 14:49
   */
  @Override
  public void onSensorChanged(SensorEvent event)
  {
    float[] its = event.values;
    if (its != null && event.sensor.getType() == Sensor.TYPE_PROXIMITY)
    {
      // 经过测试，当手贴近距离感应器的时候its[0]返回值为0.0，当手离开时返回1.0
      if (its[0] == 0.0f)
      {
        // 贴近手机
        if (!mWakeLock.isHeld())
          mWakeLock.acquire();// 申请设备电源锁
      } else
      {
        // 远离手机
        if (mWakeLock.isHeld())
        {
          mWakeLock.setReferenceCounted(false);
          mWakeLock.release(); // 释放设备电源锁
        }
      }
    }
  }

  /**
   * 精度传感器监听
   *
   * @author Jack Zhang
   * create at 2019-08-13 14:50
   */
  @Override
  public void onAccuracyChanged(Sensor sensor, int accuracy)
  {

  }

  @Override
  public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults)
  {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    //就多一个参数this
    PermissionsUtils.getInstance().onRequestPermissionsResult(this, requestCode, permissions, grantResults);
  }

  @Override
  public boolean onKeyDown(int keyCode, KeyEvent event)
  {
//    if (keyCode == KeyEvent.KEYCODE_VOLUME_UP)
//    {
//      if (FlutterPjsipPlugin.mCurrentCall != null && mAudioManager != null)
//        mAudioManager.adjustStreamVolume(
//                mIsHF ? AudioManager.STREAM_MUSIC : AudioManager.STREAM_VOICE_CALL,
//                AudioManager.ADJUST_RAISE,
//                AudioManager.FLAG_PLAY_SOUND | AudioManager.FLAG_SHOW_UI);
//      return true;
//    } else if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN)
//    {
//      if (FlutterPjsipPlugin.mCurrentCall != null && mAudioManager != null)
//        mAudioManager.adjustStreamVolume(
//                mIsHF ? AudioManager.STREAM_MUSIC : AudioManager.STREAM_VOICE_CALL,
//                AudioManager.ADJUST_LOWER,
//                AudioManager.FLAG_PLAY_SOUND | AudioManager.FLAG_SHOW_UI);
//      return true;
//    } else
    if (keyCode == KeyEvent.KEYCODE_BACK)
      return true;
    else
      return super.onKeyDown(keyCode, event);
  }

  @Override
  protected void onDestroy()
  {
    handler_ = null;

    if (timer != null)
    {
      timer.cancel();
      timer = null;
    }
    unRegisterPhoneState();
    stopRingBackSound();
    if (mAudioManager != null)// 还原系统音频设置
    {
      mAudioManager.setMicrophoneMute(false);
      mAudioManager.setMode(AudioManager.MODE_NORMAL);
      mAudioManager.setSpeakerphoneOn(false);
      setVolumeControlStream(AudioManager.USE_DEFAULT_STREAM_TYPE);
    }
    if (mWakeLock != null)
      mWakeLock.release();// 释放电源锁
    if (mSensorManager != null)
      mSensorManager.unregisterListener(this);// 注销传感器监听
    super.onDestroy();
  }

  private void unRegisterPhoneState()
  {
    if (linPhoneStateListener != null && telephony != null)
    {
      telephony.listen(linPhoneStateListener, PhoneStateListener.LISTEN_NONE);
      linPhoneStateListener = null;
      telephony = null;
    }
    if (mVibrator != null)
      mVibrator.cancel();
  }

  /**
   * 销毁当前activity
   */
  private void finishSipActivity()
  {
    finish();
    overridePendingTransition(R.anim.no_anim, R.anim.dialog_slide_down);
  }

  private class MyPhoneStateListener extends PhoneStateListener
  {
    @Override
    public void onCallStateChanged(int state, String incomingNumber)
    {
      switch (state)
      {
        case TelephonyManager.CALL_STATE_RINGING:
          //等待接电话
          break;
        case TelephonyManager.CALL_STATE_IDLE:
          //电话挂断
          break;
        case TelephonyManager.CALL_STATE_OFFHOOK:
          //通话中
          //挂断网络电话
          close(null);
          break;
      }
      super.onCallStateChanged(state, incomingNumber);
    }
  }

}
