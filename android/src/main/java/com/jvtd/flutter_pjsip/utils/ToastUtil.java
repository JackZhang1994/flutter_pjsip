package com.jvtd.flutter_pjsip.utils;

import android.content.Context;
import android.widget.Toast;

/**
 * Description:
 * Author: Jack Zhang
 * create on: 2019-08-13 15:00
 */
public class ToastUtil
{
  public static void showToast(Context context, String string)
  {
    Toast.makeText(context, string, Toast.LENGTH_SHORT).show();
  }
}
