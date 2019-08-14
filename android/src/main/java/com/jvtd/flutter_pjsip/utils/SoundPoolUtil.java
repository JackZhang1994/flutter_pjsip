package com.jvtd.flutter_pjsip.utils;

import android.content.Context;
import android.media.AudioAttributes;
import android.media.AudioManager;
import android.media.SoundPool;
import android.os.Build;
import android.support.annotation.RawRes;

/**
 * Description:
 * Author: Jack Zhang
 * create on: 2019-08-14 15:39
 */
public class SoundPoolUtil
{
  private Context mContext;
  private SoundPool mSoundPool;

  public SoundPoolUtil(Context context, SoundPool.OnLoadCompleteListener listener)
  {
    this.mContext = context;
    //sdk版本21是SoundPool 的一个分水岭
    if (Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP)
    {
      AudioAttributes audioAttributes = null;
      audioAttributes = new AudioAttributes.Builder()
              .setUsage(AudioAttributes.USAGE_MEDIA)
              .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
              .build();

      mSoundPool = new SoundPool.Builder()
              .setMaxStreams(3)
              .setAudioAttributes(audioAttributes)
              .build();
    } else
    {
      /**
       * 第一个参数：int maxStreams：SoundPool对象的最大并发流数
       * 第二个参数：int streamType：AudioManager中描述的音频流类型
       * 第三个参数：int srcQuality：采样率转换器的质量。 目前没有效果。 使用0作为默认值。
       */
      mSoundPool = new SoundPool(3, AudioManager.STREAM_MUSIC, 0);
    }
    mSoundPool.setOnLoadCompleteListener(listener);
  }

  /**
   * 加载音频资源
   *
   * @author Jack Zhang
   * create at 2019-08-14 15:41
   */
  public int load(@RawRes int resId)
  {
    return mSoundPool.load(mContext, resId, 1);
  }

  public void play(int soundId)
  {
    if (soundId > 0)
      //第一个参数soundID
      //第二个参数leftVolume为左侧音量值（范围= 0.0到1.0）
      //第三个参数rightVolume为右的音量值（范围= 0.0到1.0）
      //第四个参数priority 为流的优先级，值越大优先级高，影响当同时播放数量超出了最大支持数时SoundPool对该流的处理
      //第五个参数loop 为音频重复播放次数，0为值播放一次，-1为无限循环，其他值为播放loop+1次
      //第六个参数 rate为播放的速率，范围0.5-2.0(0.5为一半速率，1.0为正常速率，2.0为两倍速率)
      mSoundPool.play(soundId, 1.0f, 1.0f, 1, -1, 1.0f);
  }

  public void stop(int soundId)
  {
    mSoundPool.stop(soundId);
  }

  public void destroy()
  {
    mSoundPool.release();
    mSoundPool = null;
  }
}
