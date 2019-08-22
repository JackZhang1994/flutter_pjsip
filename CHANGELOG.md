## 0.0.1
带页面的PjSip，页面为platform实现

## 0.0.2
PjSip Flutter版插件，实现了语音通话功能，使用PjSip为2.9版本。
插件只提供账号及电话状态的传递，通话页需自行在Flutter端实现。

#### 插件介绍：
1. 通道名称（MethodChannel name） **flutter_pjsip**
2. 初始化FlutterPjsip对象方式：
1）FlutterPjsip pjsip = FlutterPjsip.instance;
2）FlutterPjsip pjsip = FlutterPjsip();
3. Flutter端 -> Platform端

**功能** | **方法** | **方法名称**
-|-|-
初始化 | pjsipInit() | method_pjsip_init |
登录 | pjsipLogin({String username, String password, String ip, String port}) | method_pjsip_login |
打电话  | pjsipCall({String username, String ip, String port}) | method_pjsip_call |
接听  | pjsipReceive() | method_pjsip_receive |
挂断/拒接  | pjsipRefuse() | method_pjsip_refuse |
免提  | pjsipHandsFree() | method_pjsip_hands_free |
静音  | pjsipMute() | method_pjsip_mute |
登出  | pjsipLogout() | method_pjsip_logout |
销毁  | pjsipDeinit() | method_pjsip_deinit |

以上所有方法，当处理完成后，根据方法调用成功或失败，返回对应的结果（true代表操作成功，false代表操作失败）。

4. Platform端 -> Flutter端
**方法名称**：method_call_status_changed
**传递数据类型**：Map<dynamic, dynamic>

Map类型介绍：
**key** | **字段含义** | **包含类型**
-|-|-
call_state | 通话状态 | CALLING、INCOMING、EARLY、CONNECTING、CONFIRMED、DISCONNECTED|
remote_uri | 对方Uri |

5. 确保不用插件后，需调用 [FlutterPjsip#dispose()] 方法，关闭全部StreamController