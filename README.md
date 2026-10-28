# Private Cloud

一个简洁、单用户的 PHP + MySQL 私人网盘。使用固定密码哈希登录，支持文件和多级文件夹管理。

## 功能

- 固定密码哈希登录和 Session 鉴权
- 单文件上传、下载和删除
- 新建、浏览和递归删除文件夹
- 直接上传本地文件夹并保留目录结构
- 将整个文件夹下载为 ZIP
- POST + CSRF Token 保护写操作
- 随机磁盘存储名，通过数字 ID 操作文件
- 固定夜间风格与响应式界面

## 环境要求

- PHP 8.1+
- PDO MySQL、mbstring 和 ZipArchive 扩展
- MySQL 5.7+ 或 MariaDB 10.3+
- Apache 2.4+ 或 Nginx
- Chrome / Edge 可获得最完整的文件夹上传支持

## 快速安装

1. 复制配置模板：

   ```bash
   cp config/config.example.php config/config.php
   ```

   Windows PowerShell：

   ```powershell
   Copy-Item config/config.example.php config/config.php
   ```

2. 生成登录密码哈希：

   ```bash
   php tools/generate_password_hash.php
   ```

   将输出的整行哈希填入 `config/config.php` 的 `password_hash`。

3. 在 `config/config.php` 中填写数据库连接信息。

4. 导入数据库：

   ```bash
   mysql -u YOUR_DATABASE_USER -p YOUR_DATABASE_NAME < database.sql
   ```

5. 确保 Web 进程对存储目录有读写权限：

   ```bash
   chown -R WEB_USER:WEB_GROUP storage
   find storage -type d -exec chmod 750 {} \;
   find storage -type f -exec chmod 640 {} \;
   ```

6. 将项目整体放到站点根目录，直接访问域名即可。不需要在 URL 中加入 `/public/`。

## 配置环境变量

`config/config.example.php` 也支持使用环境变量：

| 变量 | 用途 |
| --- | --- |
| `PRIVATE_CLOUD_APP_NAME` | 页面名称 |
| `PRIVATE_CLOUD_TIMEZONE` | PHP 时区，默认 `UTC` |
| `PRIVATE_CLOUD_PASSWORD_HASH` | 登录密码哈希 |
| `PRIVATE_CLOUD_DB_HOST` | MySQL 主机 |
| `PRIVATE_CLOUD_DB_PORT` | MySQL 端口 |
| `PRIVATE_CLOUD_DB_NAME` | 数据库名 |
| `PRIVATE_CLOUD_DB_USER` | 数据库用户 |
| `PRIVATE_CLOUD_DB_PASSWORD` | 数据库密码 |
| `PRIVATE_CLOUD_STORAGE_PATH` | 文件存储绝对路径 |

## 旧版数据迁移

已有单层文件数据时执行：

```bash
php tools/migrate.php
```

该命令会新建 `folders` 表，并为 `files` 表增加 `folder_id`。原有文件保留在根目录，迁移可重复执行。

## Web 服务器

### Apache

根目录 `.htaccess` 会禁止外部访问配置、存储、工具和数据库脚本。需要开启 `mod_rewrite`、`mod_headers` 并允许 `AllowOverride`。

### Nginx

Nginx 不读取 `.htaccess`，请在站点配置中添加：

```nginx
location ~ ^/(app|config|storage|tools|output)(/|$) { deny all; }
location ~ ^/public/(?!assets/) { deny all; }
location ~* ^/(database\.sql|README\.md|desktop\.ini)$ { deny all; }
```

重载配置后，建议确认以下路径返回 HTTP 403：

- `/config/config.php`
- `/storage/`
- `/tools/`
- `/database.sql`
- `/public/index.php`

`/public/assets/` 是唯一需要保持公开的 `public` 子目录。

## GitHub 发布前检查

`.gitignore` 已排除：

- `config/config.php`
- `storage/files/` 中的实际上传文件
- `output/`、日志和本地编辑器配置
- `.env` 环境文件

提交前请始终检查：

```bash
git status --short --ignored
git diff --cached
```

不要强制添加被忽略的配置、上传文件或日志。

## 安全说明

- 配置中只保存 `password_hash()` 生成的哈希，不保存明文登录密码。
- 上传、新建文件夹、删除和退出使用 POST + CSRF Token。
- 文件和文件夹仅通过数字 ID 操作，客户端不能提交磁盘路径。
- 实际文件使用随机存储名，不会被同名文件覆盖。
- 生产环境应使用 HTTPS，并关闭 `display_errors`、开启 `log_errors`。
- 文件夹上传逐个传输文件，纯空子目录不会被浏览器提供。
