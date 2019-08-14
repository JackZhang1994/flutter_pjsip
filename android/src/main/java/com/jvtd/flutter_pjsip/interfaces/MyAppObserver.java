package com.jvtd.flutter_pjsip.interfaces;

import com.jvtd.flutter_pjsip.entity.MyBuddy;
import com.jvtd.flutter_pjsip.entity.MyCall;

import org.pjsip.pjsua2.pjsip_status_code;

/**
 * Description:
 * Author: Jack Zhang
 * create on: 2019-08-12 14:28
 */
public interface MyAppObserver
{
  void notifyRegState(pjsip_status_code code, String reason, int expiration);

  void notifyIncomingCall(MyCall call);

  void notifyCallState(MyCall call);

  void notifyCallMediaState(MyCall call);

  void notifyBuddyState(MyBuddy buddy);

  void notifyChangeNetwork();
}
