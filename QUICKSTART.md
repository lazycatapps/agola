# Agola + GitHub 快速配置指南

本指南面向已经在懒猫平台上一键部署了 Agola 的用户，重点说明 GitHub OAuth、Agola Remote Source、用户注册、Token 管理、`.agola/config.jsonnet`、Webhook 转发以及手动触发流水线的配置流程。官方文档入口：https://agola.io/doc/ ，建议同时参考用户主动触发说明 https://agola.io/doc/concepts/user_direct_runs.html 以及配置参考 https://agola.io/doc/config/reference.html。

## 1. 环境信息

- **Agola**：由在懒猫平台上部署，例如 `https://agola.{box-name}.heiyu.space`。
- **初始 Admin Token**：懒猫平台会在部署输出中提供（默认值为 `admintoken`，若有变动请以实际输出为准）。
- 确认可以通过浏览器访问 Agola 并看到登录页，再开始后续配置。

## 2. 创建 GitHub OAuth App

1. 打开 https://github.com/settings/developers → **OAuth Apps** → **New OAuth App**。
2. 参考以下示例填写（如网关非 localhost，请替换为真实域名）：
   - Application name: `Agola CI`
   - Homepage URL: `https://agola.{box-name}.heiyu.space`
   - Authorization callback URL: `https://agola.{box-name}.heiyu.space/oauth2/callback`
3. 创建后记录 **Client ID** 和 **Client Secret**，后续在 Agola Remote Source 中使用。

## 3. 在 Agola 中注册 GitHub Remote Source

> 该操作也能在 UI 上完成。

使用 admin token 执行以下命令创建 Remote Source，使 Agola 能够代表用户访问 GitHub：

```bash
docker run --rm --network host sorintlab/agolademo \
  --token admintoken \
  --gateway-url https://agola.{box-name}.heiyu.space remotesource create \
  --name github \
  --type github \
  --api-url https://api.github.com \
  --auth-type oauth2 \
  --clientid <CLIENT_ID> \
  --secret <CLIENT_SECRET>
```

请将 `<CLIENT_ID>` 与 `<CLIENT_SECRET>` 替换为上一步获取的 OAuth 信息。创建完成后，访问 Agola 登录页，点击 **Sign up** → 选择 GitHub，完成授权即可在 Agola 中创建用户。


## 4. 创建用户

在上面注册 Remote Source 后，用户可以通过 GitHub OAuth 登录 Agola。首次登录时会自动创建用户账户。
注册成功后可以在 UI 上登录。

## 5. 创建用户 Token（CLI / 手动触发）

登录后可以使用 admin token 为指定用户创建 API Token，用于 CLI 调用与用户主动触发：

```bash
docker run --rm --network host sorintlab/agolademo \
  --token admintoken \
  --gateway-url https://agola.{box-name}.heiyu.space user token create \
  --username <AGOLA_USERNAME> \
  --tokenname default
```

妥善保存生成的 Token，它们将在后续执行 `project create`、`run create` 等命令时使用。

## 5. 编写 `.agola/config.jsonnet`

在 GitHub 仓库根目录创建 `.agola/config.jsonnet`（Agola 会在每次推送时解析）。以下为一个简单示例：

```jsonnet
{
  runs: [
    {
      name: 'ogola test run',
      tasks: [
        {
          name: 'build and test',
          runtime: {
            type: 'pod',
            arch: 'amd64',
            containers: [
              {
                image: 'alpine:latest',
              },
            ],
          },
          steps: [
            {
              type: 'run',
              name: 'print hello',
              command: 'echo "Hello from Agola!"',
            },
            {
              type: 'run',
              name: 'show system info',
              command: 'uname -a && cat /etc/os-release',
            },
            {
              type: 'run',
              name: 'list files',
              command: 'ls -la',
            },
          ],
        },
      ],
    },
  ],
}
```

更多语法（例如变量、依赖、秘密）请参考 https://agola.io/doc/config/reference.html，根据实际项目扩展。

## 6. 创建项目并启用流水线

> 该操作也能在 UI 上完成。

完成 Remote Source 和 Token 后，使用 CLI 将 GitHub 仓库接入 Agola：

```bash
docker run --rm --network host sorintlab/agolademo \
  --token <USER_TOKEN> \
  --gateway-url https://agola.{box-name}.heiyu.space project create \
  --parent user/<AGOLA_USERNAME> \
  --name <PROJECT_NAME> \
  --remote-source github \
  --repo-path <GITHUB_ORG>/<REPO_NAME>
```

随后向 GitHub 仓库推送含 `.agola/config.jsonnet` 的提交，Agola 即会自动触发流水线。若需手动触发，可使用 `run create --from <RUN_CONFIG>` 或遵循 https://agola.io/doc/concepts/user_direct_runs.html 的操作。

**注意**: 

- 创建项目后，该工具会自动在 GitHub 仓库中添加 Webhook，用于接收推送事件。
    - 该回调地址是： https://agola.{box-name}.heiyu.space/webhooks?agolaid=agola&projectid=e586f873-2772-4097-a3fb-424e5da91e0e
- 但由于 GitHub Webhook 只能访问公网，若 Agola 部署在内网或私有网络中，则需要使用 Gosmee 等工具进行转发，详见下一节。

## 7. 使用 Gosmee 转发 GitHub Webhook

如果 Agola 仅在内网可访问，可通过 Gosmee 将 GitHub Webhook 事件转发至内网：

1. 从 https://github.com/chmouel/gosmee/releases/v0.28.0 下载 gosmee，并加入 `$PATH`。
2. 访问 `https://hook.pipelinesascode.com` 在 `Use this Webhook URL` 会自动生成一个随机的 relay 地址。例如: `https://hook.pipelinesascode.com/{GTzCkZZwEGTv}`
3. 保存在 GitHub 仓库的 Webhook 地址，稍后会用到。
4. 修改 GitHub 仓库的 Webhook 地址为上一步生成的 relay 地址。
5. 在本地或可访问 Agola 的环境中运行 gosmee，将 relay 地址的请求转发至 Agola Webhook 入口：

```bash
gosmee client --target-connection-timeout 60 \
  https://hook.pipelinesascode.com/GTzCkZZwEGTv \
  "https://agola.{box-name}.heiyu.space/webhooks?agolaid=agola&projectid=c77721a1-15f3-4353-a089-54240c2d90c9"
```

第一个 URL 是 hook.pipelinesascode.com 的 relay，第二个是 Agola Webhook 入口。请替换 `agolaid`、`projectid` 与域名，以匹配自己的项目。

## 8. 常用场景提示

- **用户主动触发**：参考 https://agola.io/doc/concepts/user_direct_runs.html，借助用户 Token 推送参数化运行或重放失败的流水线。
    ```bash
    docker run --rm --network host sorintlab/agolademo \
      --token <USER_TOKEN> \
      --gateway-url https://agola.{box-name}.heiyu.space run create \
      --project user/<AGOLA_USERNAME>/<PROJECT_NAME> \
      --branch <BRANCH_NAME>
    ```

- **Webhook 调试**：确保 GitHub Webhook 返回 `200 OK`，也可以在 gomee 运行环境查看转发日志，确认请求已成功送达 Agola。
- **Token 管理**：可在 Agola Web UI → User → Tokens 中查看、禁用或删除 Token。
- **流水线自动触发**：配置好了上面的 webhook 和 gosmee 后，每次向包含 `.agola/config.jsonnet` 的分支推送代码时，Agola 会自动解析并执行流水线。

## 9. 参考链接

- 官方文档：https://agola.io/doc/
- 用户主动触发：https://agola.io/doc/concepts/user_direct_runs.html
- 配置参考：https://agola.io/doc/config/reference.html
- GitHub OAuth：https://github.com/settings/developers

完成以上配置后，Agola 便能与 GitHub 丝滑联动：OAuth 负责身份，Remote Source 负责仓库访问，`.agola/config.jsonnet` 定义流水线逻辑，Webhook 与 Token 则确保推送与手动触发都能正常工作。
