package com.jvtd.flutter_pjsip.entity;

import com.jvtd.flutter_pjsip.PjSipManager;

import org.pjsip.pjsua2.AudioMedia;
import org.pjsip.pjsua2.Call;
import org.pjsip.pjsua2.CallInfo;
import org.pjsip.pjsua2.CallMediaInfo;
import org.pjsip.pjsua2.CallMediaInfoVector;
import org.pjsip.pjsua2.Media;
import org.pjsip.pjsua2.OnCallMediaStateParam;
import org.pjsip.pjsua2.OnCallStateParam;
import org.pjsip.pjsua2.pjmedia_type;
import org.pjsip.pjsua2.pjsip_inv_state;
import org.pjsip.pjsua2.pjsua_call_media_status;

/**
 * Description:
 * Author: Jack Zhang
 * create on: 2019-08-12 14:30
 */
public class MyCall extends Call
{
//  private VideoWindow vidWin;
//  private VideoPreview vidPrev;

  public MyCall(MyAccount acc, int call_id)
  {
    super(acc, call_id);
//    vidWin = null;
  }

  /***
   * 当通话状态改变时通知应用程序。
   * 然后，应用程序可以通过调用getInfo（）函数来查询调用信息以获取详细调用状态。
   */
  @Override
  public void onCallState(OnCallStateParam prm)
  {
    try
    {
      CallInfo ci = getInfo();
      if (ci.getState() == pjsip_inv_state.PJSIP_INV_STATE_DISCONNECTED)
      {
        PjSipManager.mEndPoint.utilLogWrite(3, "MyCall", this.dump(true, ""));
      }
    } catch (Exception e)
    {
      e.printStackTrace();
    }

    // Should not delete this call instance (self) in this context,
    // so the observer should manage this call instance deletion
    // out of this callback context.
    PjSipManager.observer.notifyCallState(this);
  }

  /***
   * 通话中媒体状态发生变化时通知应用程序。
   * 正常的应用程序需要实现这个回调，例如将呼叫的媒体连接到声音设备。当使用ICE时，该回调也将被调用以报告ICE协商失败。
   */
  @Override
  public void onCallMediaState(OnCallMediaStateParam prm)
  {
    CallInfo callInfo;
    try
    {
      callInfo = getInfo();
    } catch (Exception e)
    {
      return;
    }

    CallMediaInfoVector mediaInfoVector = callInfo.getMedia();

    for (int i = 0; i < mediaInfoVector.size(); i++)
    {
      CallMediaInfo mediaInfo = mediaInfoVector.get(i);
      pjmedia_type type = mediaInfo.getType();
      pjsua_call_media_status status = mediaInfo.getStatus();

      if (type == pjmedia_type.PJMEDIA_TYPE_AUDIO
              && (status == pjsua_call_media_status.PJSUA_CALL_MEDIA_ACTIVE
              || status == pjsua_call_media_status.PJSUA_CALL_MEDIA_REMOTE_HOLD))
      {
        try
        {
          // unfortunately, on Java too, the returned Media cannot be
          // downcasted to AudioMedia
          Media media = getMedia(i);
          AudioMedia am = AudioMedia.typecastFromMedia(media);
          // connect ports

          PjSipManager.mEndPoint.audDevManager().getCaptureDevMedia().startTransmit(am);
          am.startTransmit(PjSipManager.mEndPoint.audDevManager().getPlaybackDevMedia());
        } catch (Exception e)
        {
          e.printStackTrace();
        }
      }

//      else if (type == pjmedia_type.PJMEDIA_TYPE_VIDEO
//              && status == pjsua_call_media_status.PJSUA_CALL_MEDIA_ACTIVE
//              && mediaInfo.getVideoIncomingWindowId() != pjsua2.INVALID_ID)
//      {
//        vidWin = new VideoWindow(mediaInfo.getVideoIncomingWindowId());
//        vidPrev = new VideoPreview(mediaInfo.getVideoCapDev());
//      }
    }

    PjSipManager.observer.notifyCallMediaState(this);
  }
}
