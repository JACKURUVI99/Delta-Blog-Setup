# 📘 USER MANUAL - BLOG PLATFORM (USAGE.md)

This user manual provides detailed instructions for each user role in the blogging platform. The system is role-based and uses Linux groups, YAML configuration, and shell scripts.

---

## 🔑 USER ROLES

| Role      | Group      | Home Directory Prefix |
| --------- | ---------- | --------------------- |
| General   | `g_user`   | `/home/users/`        |
| Author    | `g_author` | `/home/authors/`      |
| Moderator | `g_mod`    | `/home/mods/`         |
| Admin     | `g_admin`  | `/home/admins/`       |

---

## 👥 GENERAL USERS (`g_user`)

### `view_notifs`

- View unread blog notifications.

```bash
~/view_notifs
```

### `promote-req`

- Submit request to become an author (runs with limited sudo).

```bash
sudo /scripts/promote-req
```

---

## ✍️ AUTHORS (`g_author`)

### `manageblogs`

- Create or edit blogs.

```bash
/scripts/manageblogs -p <filename>  # Post a new blog
/scripts/manageblogs -e <filename>  # Edit an existing blog
```

### `sendnotif`

- Send notification to subscribers.

```bash
echo "<author_username> <blogfile>" | nc 127.0.0.1 3000
```

### `notifyserver`

- Start Netcat server to receive notification requests.

```bash
nohup bash /scripts/notifyserver &
```

---

## 🧹 MODERATORS (`g_mod`)

### `blogfilter`

- Scan blogs for blacklisted content.

```bash
/scripts/blogfilter <author_username>
```

---

## 🛠️ ADMINISTRATORS (`g_admin`)

### `initUsers.sh`

- Initialize users from YAML config.

```bash
sudo /scripts/initUsers.sh /scripts/users.yaml
```

### `promote-respond`

- Approve or reject author promotion requests.

```bash
sudo /scripts/promote-respond <username> <approve|reject>
```

### `grant_sudo_acces`

- Allow group `g_user` to run promote-req via sudo without full sudo access.

```bash
sudo /scripts/grant_sudo_acces
```

### `setupPromotion`

- Setup promote scripts and permission logic.

```bash
sudo /scripts/setupPromotion
```

### `admindash`

- Admin dashboard for monitoring blog activity.

```bash
/scripts/admindash
```

### `blogstats`

- View global stats and blog usage history.

```bash
/scripts/blogstats
```

---

## 🔔 NOTIFICATIONS

### `notifyserver`

- Run once per system to receive all blog post notifications.

```bash
nohup bash /scripts/notifyserver &
```

### `notifycron`

- Fallback cron job for missed Netcat alerts.

```bash
/scripts/notifycron
```

### `setupNotifyView`

- Deploy `view_notifs` script to every user directory.

```bash
/scripts/setupNotifyView
```

---

## 🗃️ YAML / DATA FILES

| File                 | Purpose                       |
| -------------------- | ----------------------------- |
| `users.yaml`         | All users + groups            |
| `subscriptions.yaml` | Who follows which author      |
| `requests.yaml`      | Queue for author promotion    |
| `blogs.yaml`         | Blogs written by the author   |
| `blogs_initial.yaml` | Blog template for new authors |

---

## 💡 COMMON WORKFLOWS

### Become an Author

1. **User**:
   ```bash
   sudo /scripts/promote-req
   ```
2. **Admin**:
   ```bash
   sudo /scripts/promote-respond <username> approve
   ```

### Post a Blog

```bash
/scripts/manageblogs -p new_blog.txt
```

### Notify Followers

```bash
echo "your_username new_blog.txt" | nc 127.0.0.1 3000
```

### Read Notifications

```bash
~/view_notifs
```

---

## 📦 EXTRA SETUP REQUIRED BY ROOT

- Ensure `/scripts/notifyserver` is running in background
- Add this to crontab for fallback:

```cron
*/5 * * * * /scripts/notifycron
```

---

---

##
