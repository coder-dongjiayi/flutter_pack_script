# 使用swift 编写自动化打包脚本
> 本教程适合中小型公司，内部实现自动化打包，方便、稳定。彻底解放程序员的双手，无需部署繁琐的Jenkins，只要简单几步即可，可以不局限于flutter，原生Android和iOS都可以，思路都一样。使用jenkins打完包以后 钉钉机器人在群里通知打包的测试同学。

![20210918113209.jpg](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b8ce95f03c0b4149bbde1004e9f53b45~tplv-k3u1fbpfcp-watermark.image?)
## 为什么要自动化(手动打包存在的痛点)
 ### 1.加班到半夜打包发版，容易出错，因为此时的人极度疲劳，更容易出问题
 
  在flutter工程中我们一般用多个文件入口来表示多套开发环境比如```main.dart ```表示生产环境``` main_t.dart```表示测试环境，如下图所示
 
![20210918111345.jpg](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1b4d87a53a044f2f8a60976c7292f7e1~tplv-k3u1fbpfcp-watermark.image?)
我们通过运行不同的入口文件来运行不同的环境，如下

![20210918111543.jpg](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/499e3c5d3211405cb501a4e21a41fdc6~tplv-k3u1fbpfcp-watermark.image?)
但是这种方式存在一个问题，我们无法在原生工程中一眼就看出当前运行的环境，以iOS为例，我可能需要打开```Generated.xcconfig ```这个文件才能看到我当前的环境 如下图

![20210918111906.jpg](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ae4af8aa78074770a0f3ca5450791eea~tplv-k3u1fbpfcp-watermark.image?)
**假设如果此时加班到很晚，人会感到疲劳，极其容易忽略当前打包的环境，导致可能发错包。这样的话造成的后果是灾难性的**

### 2. 打包效率问题
   一般情况下稍微有点规模的app 怎么也得打个3、5分钟，比如我现在用的这台电脑每次打包都得10多分钟，如果你在打包的同时想在运行其他的项目，那么效率会更低，尤其是在发版的前几天可能需要频繁的打包，这一天下来啥也没干成，净给测试同学打包了
### 3.测试同学以及其他有关联的部门总跟你要包
  我觉得这个原因可能是绝大多数移动端开发同学的的困惑，改点东西，就要给测试打包，测试同学翻来覆去老找你要包。而且有多个测试同学，可能测的分支、功能都不一样，总是要给测试打包。非常影响我们对业务的专注度。我们在解决Bug或者是写业务的时候，突然有个人跟你要包，又很着急的样子。你要马上给他打包，这样就中断了自己的思路，效率反而又降低了
  > 总之不管什么原因，我们自动化的目的都是为了公司或者个人提高工作效率，只要能达到这个目的就可以了
   
## 编写swift代码 
> 打包原理：使用```swift```编写打包命令，其本质就是 整合flutter和iOS平台提供的打包命令，来达到自动打包的目的，所以在编写代码之前 要先认识几条我们常用的命令

* ```Flutter```平台

```js
flutter clean
flutter pub upgrade
```

* ```Android```平台打包命令
```js
// 正常可测试的aab文件
flutter build apk lib/mian.dart 
// 上架google商店的aab文件
flutter build appbundle --target-platform android-arm64
```
* ```iOS```平台

```js
flutter build ios lib/main.dart
//生产archive文件
xcodebuild  archive -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release -archivePath \(archivePath)  -destination 'generic/platform=iOS' | xcpretty > \(xcodeBuildLogPath)
//导出ipa文件
xcodebuild -exportArchive -archivePath \(archivePath).xcarchive -exportPath \(exportPath) -exportOptionsPlist ExportOptions_development.plist
```
对于以上几个命令明确以后，剩下的代码就简单了，核心代码就一句，就是执行上面几行命令，如下

![20210918135523.jpg](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8c4e09f6d4ea4682a12035acefa517c3~tplv-k3u1fbpfcp-watermark.image?)
全部流程的代码，我放到了 [github上](https://github.com/coder-dongjiayi/flutter_pack_script)，有兴趣的可以自行查看。文章里面只阐述主要流程的代码
#### 1.入口参数选择
为了使我们的打包命令既能在命令行方便的执行，又能兼容jenkins传参


![20210918141857.jpg](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4845c367d6ee41f7a14b7a4e59e423ef~tplv-k3u1fbpfcp-watermark.image?)


上图中 ```readLine()``` 就是获取命令行输入的参数 编译我们的工程```cmd+B```，在工程中的Products目录下得到我们的 ```match-o```文件如下

![20210918142235.jpg](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4daaf6cb2f864e94859a59fa74056abf~tplv-k3u1fbpfcp-watermark.image?)
在flutter工程下执行这个二进制文件,如下

![20210918142656.jpg](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5a8417babd57433783ac4ff6cba7edd5~tplv-k3u1fbpfcp-watermark.image?)

### 2.ipad导出
  我的打包命令在测试环境只能导出一个dev开头的包但是在生产环境打包的时候iOS端会产出两个ipa文件，Android也会产出两个包，如下图所示
  
![20210918143238.jpg](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/25baab9eec554dbabfcf05c64b044bbe~tplv-k3u1fbpfcp-watermark.image?)

![20210918143153.jpg](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/944e3b466c9a4e1ab2021c5cd4880c11~tplv-k3u1fbpfcp-watermark.image?)

> 为什么要这么设计呢? 我们知道iOS端正常情况下Development的这种发布方式，只能通过添加内测udid这种方式安装到手机上，却不能发布到AppStore。而使用AppStore这种方式，又不能直接安装到手机上，为了保证测试测的代码和上传AppStore的代码的一致性，在最后导出ipa的时候，就把两种包都导出来，一旦测试通过 就可以直接通过 ```Transporter ```提交到应用商店。既保证了代码一致性又提高了效率，重点是 这样提包的方式不依赖于```Xcode``` 如果开发人员不在，测试和产品也可以提交App到应用商店。 

### 3.钉钉通知打包的同学进行测试，代码如下

![20210918145039.jpg](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4ec75a73e65d41f088f1f90302c0fe35~tplv-k3u1fbpfcp-watermark.image?)
其实就是执行了一个 ```curl ``` 的命令，至于如何@钉钉群里的同事，[请查看钉钉官方文档](https://developers.dingtalk.com/document/robots/custom-robot-access?spm=ding_open_doc.document.0.0.62846573szVHol#topic-2026027)
> 至此编写代码的核心流程就完成，下面就是如何部署jenkins的问题

## 部署Jenkins
> 本文不教你怎么安装jenkins ，请自行搜索 我假设你已经安装好了jenkins 并且可以看到下面的登录页面

![20210918150922.jpg](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/56e3fd3369464eabadc0efd415752ec8~tplv-k3u1fbpfcp-watermark.image?)

曾几何时，对于使用```Jenkins```，尤其是部署 iOS工程，真是一顿折腾，而且还没那么稳定。今天提供一种新的思路，就是用jenkins直接调用我们上面编写的二进制文件，所有jenkins上关于``iOS`` 或者 ``Xcode``的插件都不需要安装，也不需要知道怎么使用。只需要用到一个Jenkins插件``build user vars `` 这个插件是用来获取当前登录用户信息的，如果你不需要在最后钉钉机器人上显示打包人的姓名，那么这个插件也不需要了。
#### 1.创建一个自由风格的软件项目

![20210918152057.jpg](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cd7bbebb77b74454894e968bd2ae169f~tplv-k3u1fbpfcp-watermark.image?)

#### 2.添加构建参数，平台、环境、和git地址

![20210918152305.jpg](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7ac05a2ae87744d2a7135969fd329d04~tplv-k3u1fbpfcp-watermark.image?)

![20210918152325.jpg](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/64c5af8831f24ef08189da0b0bfb0e2c~tplv-k3u1fbpfcp-watermark.image?)

![20210918152414.jpg](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c09e18852f6840a49b5a74ee9f0ece69~tplv-k3u1fbpfcp-watermark.image?)

#### 3.执行打包命令
注意：这里有个问题，好像jenkins不能直接调用 ``` match-o```,所以我这里先让jenkins执行 ``shell ``，在``shell``里面调用 ```match-o ```如下

![20210918153049.jpg](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/84a65fa192824fe9ae519764807c918a~tplv-k3u1fbpfcp-watermark.image?)


![20210918153130.jpg](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/924fbd63ccd844c9a4c4e816aa35f258~tplv-k3u1fbpfcp-watermark.image?)
保存，开始构建 可以试一下效果了

![20210918153506.jpg](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2ecf0c6977cf4431a8d227d1631cc8e5~tplv-k3u1fbpfcp-watermark.image?)
> 所以基于以上步骤来看，只要我们用``swift ``编写的打包命令没有问题，那么jenkins就可以正常打包，如果jenkins出现了异常，程序员手动执行命令也是一样的效果










