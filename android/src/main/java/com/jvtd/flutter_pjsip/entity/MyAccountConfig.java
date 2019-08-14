package com.jvtd.flutter_pjsip.entity;

import org.pjsip.pjsua2.AccountConfig;
import org.pjsip.pjsua2.BuddyConfig;
import org.pjsip.pjsua2.ContainerNode;

import java.util.ArrayList;

/**
 * Description:
 * Author: Jack Zhang
 * create on: 2019-08-12 14:27
 */
public class MyAccountConfig
{
  public AccountConfig accCfg = new AccountConfig();
  public ArrayList<BuddyConfig> buddyCfgs = new ArrayList<BuddyConfig>();

  public void readObject(ContainerNode node)
  {
    try
    {
      ContainerNode acc_node = node.readContainer("Account");
      accCfg.readObject(acc_node);
      ContainerNode buddies_node = acc_node.readArray("buddies");
      buddyCfgs.clear();
      while (buddies_node.hasUnread())
      {
        BuddyConfig bud_cfg = new BuddyConfig();
        bud_cfg.readObject(buddies_node);
        buddyCfgs.add(bud_cfg);
      }
    } catch (Exception e)
    {
      e.printStackTrace();
    }
  }

  public void writeObject(ContainerNode node)
  {
    try
    {
      ContainerNode acc_node = node.writeNewContainer("Account");
      accCfg.writeObject(acc_node);
      ContainerNode buddies_node = acc_node.writeNewArray("buddies");
      for (int j = 0; j < buddyCfgs.size(); j++)
      {
        buddyCfgs.get(j).writeObject(buddies_node);
      }
    } catch (Exception e)
    {
      e.printStackTrace();
    }
  }
}
