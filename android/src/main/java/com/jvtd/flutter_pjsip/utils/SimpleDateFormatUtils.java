package com.jvtd.flutter_pjsip.utils;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;

/**
 * Created by Administrator on 2017/10/16.
 * 时间格式
 */

public class SimpleDateFormatUtils
{
  private Date mDate;
  private SimpleDateFormat sDateTimeFormat;

  private SimpleDateFormatUtils()
  {
    mDate = new Date();
  }

  private static class Build
  {
    private static SimpleDateFormatUtils sInstance = new SimpleDateFormatUtils();
  }

  public static SimpleDateFormatUtils newInstance()
  {
    return Build.sInstance;
  }

  /**
   * 毫秒值转字符串
   *
   * @param millisecond 毫秒值
   * @return 2017-07-07 08:00:00
   */
  public String long2StringHMS(long millisecond)
  {
    sDateTimeFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.CHINA);
    mDate.setTime(millisecond);
    return sDateTimeFormat.format(mDate);
  }

  public String long2StringYMDHM(long millisecond)
  {
    sDateTimeFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.CHINA);
    mDate.setTime(millisecond);
    return sDateTimeFormat.format(mDate);
  }

  public String long2StringHM(long millisecond)
  {
    sDateTimeFormat = new SimpleDateFormat("HH:mm", Locale.CHINA);
    mDate.setTime(millisecond);
    return sDateTimeFormat.format(mDate);
  }

  public String long2StringMS(long millisecond)
  {
    sDateTimeFormat = new SimpleDateFormat("mm:ss", Locale.CHINA);
    mDate.setTime(millisecond);
    return sDateTimeFormat.format(mDate);
  }

  public String long2StringHMSNoYMD(long millisecond)
  {
    sDateTimeFormat = new SimpleDateFormat("HH:mm:ss", Locale.CHINA);
    mDate.setTime(millisecond);
    return sDateTimeFormat.format(mDate);
  }

  public static String getTime(Date date)
  {
    SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd", Locale.CHINA);
    return format.format(date);
  }

  public static String getTimeToDate(Date date)
  {
    SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.CHINA);
    return format.format(date);
  }

  public String long2StringEEEE(long millisecond)
  {
    Calendar c = Calendar.getInstance();
    c.setTime(new Date(millisecond));
    int i = c.get(Calendar.DAY_OF_WEEK);
    switch (i)
    {
      case 1:
        return "星期日";
      case 2:
        return "星期一";
      case 3:
        return "星期二";
      case 4:
        return "星期三";
      case 5:
        return "星期四";
      case 6:
        return "星期五";
      case 7:
        return "星期六";
      default:
        return "";
    }
  }

  /**
   * 将时间戳转换为时间
   */
  public static String stampToDate(long s)
  {
    String res;
    SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.CHINA);
    Date date = new Date(s);
    res = simpleDateFormat.format(date);
    return res;
  }

  public long stringYMD2Long(String ymd)
  {
    sDateTimeFormat = new SimpleDateFormat("yyyy-MM-dd", Locale.CHINA);
    long times = 0;
    try
    {
      Date ymdDate = sDateTimeFormat.parse(ymd);
      times = ymdDate.getTime();
    } catch (ParseException e)
    {
      e.printStackTrace();
    }
    return times;
  }

  /**
   * 获取当前系统时间
   */
  public static String getCurrentTime()
  {
    String currentTime;
    Date day = new Date();
    SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.CHINA);
    currentTime = df.format(day);
    return currentTime;
  }

  /**
   * 选择时间和当前时间进行比较
   *
   * @param endTime 选择时间
   * @param selectTime 比较时间
   * @param type 0表示比较当前时间  1表示截止时间和提醒时间的比较
   */
  public static long selectTimeReduce(String endTime, String selectTime, int type)
  {
    long time = 0;
    Date d1 = null;
    Date d2 = null;
    DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.CHINA);
    //选择时间
    try
    {
      if (type == 0)//跟当前时间比较
      {
        d1 = df.parse(endTime);
        d2 = df.parse(getCurrentTime());
      } else if (type == 1)//跟提醒时间比较
      {
        d1 = df.parse(endTime);
        d2 = df.parse(selectTime);
      }
      time = d1.getTime() - d2.getTime();
    } catch (ParseException e)
    {
      e.printStackTrace();
    }
    return time;
  }
}
