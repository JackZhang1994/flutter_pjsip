package com.jvtd.flutter_pjsip;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ApplicationInfo;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;

import com.jvtd.flutter_pjsip.app.MyApp;
import com.jvtd.flutter_pjsip.entity.MSG_TYPE;
import com.jvtd.flutter_pjsip.entity.MyAccount;
import com.jvtd.flutter_pjsip.entity.MyBuddy;
import com.jvtd.flutter_pjsip.entity.MyCall;
import com.jvtd.flutter_pjsip.interfaces.MyAppObserver;
import com.jvtd.flutter_pjsip.ui.CallActivity;

import org.pjsip.pjsua2.AccountConfig;
import org.pjsip.pjsua2.AuthCredInfo;
import org.pjsip.pjsua2.AuthCredInfoVector;
import org.pjsip.pjsua2.CallInfo;
import org.pjsip.pjsua2.CallOpParam;
import org.pjsip.pjsua2.pjsip_inv_state;
import org.pjsip.pjsua2.pjsip_status_code;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterPjsipPlugin
 */
public class FlutterPjsipPlugin implements MethodCallHandler
{
  private static final String CHANNEL = "flutter_pjsip";
  private static final String METHOD_PJSIP_INIT = "method_pjsip_init";
  private static final String METHOD_PJSIP_LOGIN = "method_pjsip_login";
  private static final String METHOD_PJSIP_CALL = "method_pjsip_call";
  private static final String METHOD_PJSIP_LOGOUT = "method_pjsip_logout";
  private static final String METHOD_PJSIP_DEINIT = "method_pjsip_deinit";

  private Activity mActivity;
  private Result mResult;
  private String mMethod;
  private MyApp mApp;
  private AccountConfig mAccountConfig;
  public static MyAccount mAccount;
  private MyBroadcastReceiver mReceiver;
  private String mIp;// sip服务器的IP
  private String mPort;// sip服务器的端口号
  public static MyCall mCurrentCall;// 记录当前通话，若没有通话，为null
  private boolean mIsLogin;
  private boolean mIsInit;

  private final Handler handler = new Handler(new Handler.Callback()
  {
    @Override
    public boolean handleMessage(Message msg)
    {
      int what = msg.what;
      switch (what)
      {
        case MSG_TYPE.REG_STATE:
          boolean loginResult = (boolean) msg.obj;
          mResult.success(loginResult);
          break;

        case MSG_TYPE.CALL_STATE:
          CallInfo callInfo = (CallInfo) msg.obj;

          if (mCurrentCall == null || callInfo == null || callInfo.getId() != mCurrentCall.getId())
          {
            System.out.println("Call state event received, but call info is invalid");
            return true;
          }

          /* Forward the call info to CallActivity */
          if (CallActivity.handler_ != null)
          {
            Message m2 = Message.obtain(CallActivity.handler_, MSG_TYPE.CALL_STATE, callInfo);
            m2.sendToTarget();
          }

          if (callInfo.getState() == pjsip_inv_state.PJSIP_INV_STATE_DISCONNECTED)
          {
            mCurrentCall.delete();
            mCurrentCall = null;
          }
          break;

        case MSG_TYPE.CALL_MEDIA_STATE:
          /* Forward the message to CallActivity */
          if (CallActivity.handler_ != null)
          {
            Message m2 = Message.obtain(CallActivity.handler_, MSG_TYPE.CALL_MEDIA_STATE, null);
            m2.sendToTarget();
          }
          break;

        case MSG_TYPE.INCOMING_CALL:
          /* Incoming call */
          MyCall call = (MyCall) msg.obj;
          CallOpParam prm = new CallOpParam();
          /* Only one call at anytime */
          if (mCurrentCall != null)
          {
            try
            {
              // 设置StatusCode
              prm.setStatusCode(pjsip_status_code.PJSIP_SC_BUSY_HERE);
              call.hangup(prm);
              call.delete();
            } catch (Exception e)
            {
              e.printStackTrace();
            }
            return true;
          } else
          {
            try
            {
              /* Answer with ringing */
              prm.setStatusCode(pjsip_status_code.PJSIP_SC_RINGING);
              call.answer(prm);
              mCurrentCall = call;

              Intent intent = new Intent(mActivity, CallActivity.class);
              intent.putExtra("is_incoming_call", true);
              mActivity.startActivity(intent);
            } catch (Exception e)
            {
              e.printStackTrace();
            }
          }
          break;

        case MSG_TYPE.CHANGE_NETWORK:
          if (mApp != null)
            mApp.handleNetworkChange();
          break;
      }
      return false;
    }
  });

  private MyAppObserver mAppObserver = new MyAppObserver()
  {
    @Override
    public void notifyRegState(final pjsip_status_code code, String reason, final int expiration)
    {
      if (mActivity != null && mResult != null && (TextUtils.equals(mMethod, METHOD_PJSIP_LOGIN) || TextUtils.equals(mMethod, METHOD_PJSIP_LOGOUT)))
      {
//        String msg_str = "";
//        if (expiration == 0)// 注销
//          msg_str += "Unregistration";
//        else// 注册
//          msg_str += "Registration";

        boolean loginResult = code.swigValue() / 100 == 2;
        mIsLogin = loginResult;
        mMethod = "";

        Message m = Message.obtain(handler, MSG_TYPE.REG_STATE, loginResult);
        m.sendToTarget();
      }
    }

    @Override
    public void notifyIncomingCall(MyCall call)
    {
      Message m = Message.obtain(handler, MSG_TYPE.INCOMING_CALL, call);
      m.sendToTarget();
    }

    @Override
    public void notifyCallState(MyCall call)
    {
      if (mCurrentCall == null || call.getId() != mCurrentCall.getId())
        return;

      CallInfo info = null;
      try
      {
        info = call.getInfo();
      } catch (Exception e)
      {
        e.printStackTrace();
      }

      if (info != null)
      {
        Message m = Message.obtain(handler, MSG_TYPE.CALL_STATE, info);
        m.sendToTarget();
      }
    }

    @Override
    public void notifyCallMediaState(MyCall call)
    {
      Message m = Message.obtain(handler, MSG_TYPE.CALL_MEDIA_STATE, null);
      m.sendToTarget();
    }

    @Override
    public void notifyBuddyState(MyBuddy buddy)
    {
      Message m = Message.obtain(handler, MSG_TYPE.BUDDY_STATE, buddy);
      m.sendToTarget();
    }

    @Override
    public void notifyChangeNetwork()
    {
      Message m = Message.obtain(handler, MSG_TYPE.CHANGE_NETWORK, null);
      m.sendToTarget();
    }
  };

  private FlutterPjsipPlugin(Activity activity)
  {
    this.mActivity = activity;
  }

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar)
  {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL);

    FlutterPjsipPlugin instance = new FlutterPjsipPlugin(registrar.activity());
    //setMethodCallHandler在此通道上接收方法调用的回调
    channel.setMethodCallHandler(instance);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result)
  {
    mMethod = call.method;
    mResult = result;
    switch (mMethod)
    {
      case METHOD_PJSIP_INIT:
        if (mIsInit)
        {
          mResult.success(false);
          return;
        } else
        {
          pjsipInit();
          mIsInit = true;
          mResult.success(true);
        }
        break;

      case METHOD_PJSIP_LOGIN:
        if (mIsInit)
        {
          String username = call.argument("username");
          String password = call.argument("password");
          mIp = call.argument("ip");
          mPort = call.argument("port");
          pjsipLogin(username, password, mIp, mPort);
        } else
        {
          mResult.success(false);
          return;
        }
        break;

      case METHOD_PJSIP_CALL:
        if (!mIsInit || !mIsLogin) return;
        String toUsername = call.argument("username");
        String toIp = call.argument("ip");
        String toPort = call.argument("port");
        pjsipCall(toUsername, TextUtils.isEmpty(toIp) ? mIp : toIp, TextUtils.isEmpty(toPort) ? mPort : toPort);
        break;

      case METHOD_PJSIP_LOGOUT:
        if (mIsInit)
        {
          mAccountConfig.delete();
          mAccount.delete();
          mIsLogin = false;
          mResult.success(true);
        } else
        {
          mResult.success(false);
          return;
        }

        break;

      case METHOD_PJSIP_DEINIT:
        if (mIsInit && mApp != null)
        {
          mApp.deinit();
          mApp = null;

          if (mReceiver != null)
            mActivity.getApplication().unregisterReceiver(mReceiver);
          mReceiver = null;

          mIsInit = false;
          mResult.success(true);
        } else
          mResult.success(false);
        break;

      default:
        result.notImplemented();
        break;
    }
  }

  /**
   * PjSip初始化方法
   *
   * @author Jack Zhang
   * create at 2019-08-12 23:37
   */
  private void pjsipInit()
  {
    if (mApp == null)
    {
      mApp = new MyApp();
      // Wait for GDB to init, for native debugging only
      if (false && (mActivity.getApplicationInfo().flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0)
      {
        try
        {
          Thread.sleep(500);
        } catch (InterruptedException e)
        {
          e.printStackTrace();
        }
      }
      mApp.init(mAppObserver);
    }

    if (mReceiver == null)
    {
      mReceiver = new MyBroadcastReceiver();
      IntentFilter intentFilter = new IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION);
      mActivity.getApplication().registerReceiver(mReceiver, intentFilter);
    }
  }

  /**
   * PjSip登录方法
   *
   * @author Jack Zhang
   * create at 2019-08-12 23:38
   */
  private void pjsipLogin(String username, String password, String ip, String port)
  {
    mAccountConfig = new AccountConfig();
    mAccountConfig.getNatConfig().setIceEnabled(true);
    // 未实现视频功能，先置位false
    mAccountConfig.getVideoConfig().setAutoTransmitOutgoing(false);// 自动向外传输视频流
    mAccountConfig.getVideoConfig().setAutoShowIncoming(false);// 自动接收并显示来的视频流
    mAccountConfig.setIdUri("sip:" + username + "@" + ip + ":" + port);
    mAccountConfig.getRegConfig().setRegistrarUri("sip:" + ip + ":" + port);
    AuthCredInfoVector creds = mAccountConfig.getSipConfig().getAuthCreds();
    if (creds != null)
    {
      creds.clear();
      if (username != null && username.length() != 0)
        creds.add(new AuthCredInfo("Digest", "*", username, 0, password));
    }

    mAccount = new MyAccount(mAccountConfig);
    try
    {
      mAccount.create(mAccountConfig);
    } catch (Exception e)
    {
      e.printStackTrace();
      mAccount = null;
    }
    // 重置账户使用
//    try
//    {
//      mAccount.modify(mAccountConfig);
//    } catch (Exception e)
//    {
//      e.printStackTrace();
//    }
  }

  /**
   * PjSip打电话方法
   *
   * @author Jack Zhang
   * create at 2019-08-12 23:45
   */
  private void pjsipCall(String username, String ip, String port)
  {
    /* Only one call at anytime */
    if (mCurrentCall != null)
      return;

    Intent intent = new Intent(mActivity, CallActivity.class);
    intent.putExtra("username", username);
    intent.putExtra("ip", ip);
    intent.putExtra("port", port);
    intent.putExtra("is_incoming_call", false);
    mActivity.startActivity(intent);
  }

  public void notifyChangeNetwork()
  {
    Message m = Message.obtain(handler, MSG_TYPE.CHANGE_NETWORK, null);
    m.sendToTarget();
  }

  private class MyBroadcastReceiver extends BroadcastReceiver
  {
    private String conn_name = "";

    @Override
    public void onReceive(Context context, Intent intent)
    {
      if (isNetworkChange(context))
        notifyChangeNetwork();
    }

    private boolean isNetworkChange(Context context)
    {
      boolean network_changed = false;
      ConnectivityManager connectivity_mgr = ((ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE));
      if (connectivity_mgr != null)
      {
        NetworkInfo net_info = connectivity_mgr.getActiveNetworkInfo();
        if (net_info != null && net_info.isConnectedOrConnecting() && !conn_name.equalsIgnoreCase(""))
        {
          String new_con = net_info.getExtraInfo();
          if (new_con != null && !new_con.equalsIgnoreCase(conn_name))
            network_changed = true;

          conn_name = (new_con == null) ? "" : new_con;
        } else
        {
          if (conn_name.equalsIgnoreCase(""))
            conn_name = net_info.getExtraInfo();
        }
      }
      return network_changed;
    }
  }
}


