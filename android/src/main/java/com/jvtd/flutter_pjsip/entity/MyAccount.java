package com.jvtd.flutter_pjsip.entity;

import com.jvtd.flutter_pjsip.app.MyApp;

import org.pjsip.pjsua2.Account;
import org.pjsip.pjsua2.AccountConfig;
import org.pjsip.pjsua2.BuddyConfig;
import org.pjsip.pjsua2.OnIncomingCallParam;
import org.pjsip.pjsua2.OnInstantMessageParam;
import org.pjsip.pjsua2.OnRegStateParam;

import java.util.ArrayList;

/**
 * Description:
 * Author: Jack Zhang
 * create on: 2019-08-12 14:27
 */
public class MyAccount extends Account
{
  public ArrayList<MyBuddy> buddyList = new ArrayList<MyBuddy>();
  public AccountConfig cfg;

  public MyAccount(AccountConfig config)
  {
    super();
    cfg = config;
  }

  public MyBuddy addBuddy(BuddyConfig bud_cfg)
  {
    /* Create Buddy */
    MyBuddy bud = new MyBuddy(bud_cfg);
    try
    {
      bud.create(this, bud_cfg);
    } catch (Exception e)
    {
      bud.delete();
      bud = null;
    }

    if (bud != null)
    {
      buddyList.add(bud);
      if (bud_cfg.getSubscribe())
        try
        {
          bud.subscribePresence(true);
        } catch (Exception e)
        {
          e.printStackTrace();
        }
    }

    return bud;
  }

  public void delBuddy(MyBuddy buddy)
  {
    buddyList.remove(buddy);
    buddy.delete();
  }

  public void delBuddy(int index)
  {
    MyBuddy bud = buddyList.get(index);
    buddyList.remove(index);
    bud.delete();
  }

  /**
   * 当注册或注销已经启动时通知申请。
   * 请注意，这只会通知初始注册和注销。一旦注册会话处于活动状态，后续刷新将不会导致此回调被调用。
   */
  @Override
  public void onRegState(OnRegStateParam prm)
  {
    MyApp.observer.notifyRegState(prm.getCode(), prm.getReason(), prm.getExpiration());
  }

  /**
   * 来电话监听
   */
  @Override
  public void onIncomingCall(OnIncomingCallParam prm)
  {
    System.out.println("======== Incoming call ======== ");
    MyCall call = new MyCall(this, prm.getCallId());
    MyApp.observer.notifyIncomingCall(call);
  }

  @Override
  public void onInstantMessage(OnInstantMessageParam prm)
  {
    System.out.println("======== Incoming pager ======== ");
    System.out.println("From     : " + prm.getFromUri());
    System.out.println("To       : " + prm.getToUri());
    System.out.println("Contact  : " + prm.getContactUri());
    System.out.println("Mimetype : " + prm.getContentType());
    System.out.println("Body     : " + prm.getMsgBody());
  }
}
