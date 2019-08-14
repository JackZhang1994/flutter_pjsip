package com.jvtd.flutter_pjsip.app;

import com.jvtd.flutter_pjsip.interfaces.MyAppObserver;
import com.jvtd.flutter_pjsip.utils.MyLogWriter;

import org.pjsip.pjsua2.Endpoint;
import org.pjsip.pjsua2.EpConfig;
import org.pjsip.pjsua2.IpChangeParam;
import org.pjsip.pjsua2.LogConfig;
import org.pjsip.pjsua2.TransportConfig;
import org.pjsip.pjsua2.UaConfig;
import org.pjsip.pjsua2.pj_log_decoration;
import org.pjsip.pjsua2.pjsip_transport_type_e;

/**
 * Description:
 * Author: Jack Zhang
 * create on: 2019-08-12 14:25
 */
public class MyApp
{
  static
  {
    try
    {
      System.loadLibrary("openh264");
      // Ticket #1937: libyuv is now included as static lib
      //System.loadLibrary("yuv");
    } catch (UnsatisfiedLinkError e)
    {
      System.out.println("UnsatisfiedLinkError: " + e.getMessage());
      System.out.println("This could be safely ignored if you don't need video.");
    }
//    try
//    {
      System.loadLibrary("pjsua2");
      System.out.println("Library loaded");
//    } catch (Exception e)
//    {
//      e.printStackTrace();
//    } catch (Error error)
//    {
//      error.printStackTrace();
//    }
  }

  public static Endpoint mEndPoint;
  public static MyAppObserver observer;

  /**
   * 初始化方法
   *
   * @author Jack Zhang
   * create at 2019-08-12 14:34
   */
  public void init(MyAppObserver obs)
  {
    init(obs, false);
  }

  /**
   * 初始化方法
   *
   * @author Jack Zhang
   * create at 2019-08-12 14:34
   */
  public void init(MyAppObserver obs, boolean own_worker_thread)
  {
    observer = obs;

    /* Create endpoint */
    try
    {
      if (mEndPoint == null)
        mEndPoint = new Endpoint();
      mEndPoint.libCreate();
    } catch (Exception e)
    {
      return;
    }

    EpConfig epConfig = new EpConfig();

    // TODO: 2019-08-14 注销掉日志部分
//    // LogConfig来自定义日志设置
//    LogConfig log_cfg = epConfig.getLogConfig();
//    /* Override log level setting */
//    int LOG_LEVEL = 4;
//    log_cfg.setLevel(LOG_LEVEL);
//    log_cfg.setConsoleLevel(LOG_LEVEL);
//    /* Maintain reference to log writer to avoid premature cleanup by GC */
//    MyLogWriter logWriter = new MyLogWriter();
//    log_cfg.setWriter(logWriter);
//    log_cfg.setDecor(log_cfg.getDecor() &
//            ~(pj_log_decoration.PJ_LOG_HAS_CR.swigValue() |
//                    pj_log_decoration.PJ_LOG_HAS_NEWLINE.swigValue()));

    /* Write log to file (just uncomment whenever needed) */
    //String log_path = android.os.Environment.getExternalStorageDirectory().toString();
    //log_cfg.setFilename(log_path + "/pjsip.log");

    // UAConfig，指定核心SIP用户代理设置
    UaConfig ua_cfg = epConfig.getUaConfig();
    ua_cfg.setUserAgent("Pjsua2 Android " + mEndPoint.libVersion().getFull());

    /* STUN server. */
    //StringVector stun_servers = new StringVector();
    //stun_servers.add("stun.pjsip.org");
    //ua_cfg.setStunServer(stun_servers);

    /* No worker thread */
    if (own_worker_thread)
    {
      ua_cfg.setThreadCnt(0);
      ua_cfg.setMainThreadOnly(true);
    }

    // 指定ep_cfg中设置的自定义
    try
    {
      mEndPoint.libInit(epConfig);
    } catch (Exception e)
    {
      return;
    }

    TransportConfig sipTpConfig = new TransportConfig();
    int SIP_PORT = 6050;

    /* Set SIP port back to default for JSON saved config */
    sipTpConfig.setPort(SIP_PORT);

    // 创建一个或多个传输
    try
    {
      mEndPoint.transportCreate(pjsip_transport_type_e.PJSIP_TRANSPORT_UDP, sipTpConfig);
    } catch (Exception e)
    {
      e.printStackTrace();
    }

//    try
//    {
//      mEndPoint.transportCreate(pjsip_transport_type_e.PJSIP_TRANSPORT_TCP, sipTpConfig);
//    } catch (Exception e)
//    {
//      e.printStackTrace();
//    }
//
//    try
//    {
//      sipTpConfig.setPort(SIP_PORT + 1);
//      mEndPoint.transportCreate(pjsip_transport_type_e.PJSIP_TRANSPORT_TLS, sipTpConfig);
//    } catch (Exception e)
//    {
//      e.printStackTrace();
//    }

    /* Start. */
    try
    {
      mEndPoint.libStart();
    } catch (Exception e)
    {
      e.printStackTrace();
    }
  }

  public void handleNetworkChange()
  {
    try
    {
      System.out.println("Network change detected");
      IpChangeParam changeParam = new IpChangeParam();
      mEndPoint.handleIpChange(changeParam);
    } catch (Exception e)
    {
      e.printStackTrace();
    }
  }

  public void deinit()
  {
    /* Try force GC to avoid late destroy of PJ objects as they should be
     * deleted before lib is destroyed.
     */
    Runtime.getRuntime().gc();

    /* Shutdown pjsua. Note that Endpoint destructor will also invoke
     * libDestroy(), so this will be a test of double libDestroy().
     */
    try
    {
      mEndPoint.libDestroy();
    } catch (Exception e)
    {
      e.printStackTrace();
    }

    /* Force delete Endpoint here, to avoid deletion from a non-
     * registered thread (by GC?).
     */
    mEndPoint.delete();
    mEndPoint = null;
  }
}
