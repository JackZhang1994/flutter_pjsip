package com.jvtd.flutter_pjsip.utils;

import org.pjsip.pjsua2.LogEntry;
import org.pjsip.pjsua2.LogWriter;

/**
 * Description:
 * Author: Jack Zhang
 * create on: 2019-08-12 14:29
 */
public class MyLogWriter extends LogWriter
{
  @Override
  public void write(LogEntry entry)
  {
    System.out.println(entry.getMsg());
  }
}
