# DELTA TASK 1 - README

Scripts are organized by user roles: General Users (`g_user`), Authors (`g_author`), Moderators (`g_mod`), and Admins (`g_admin`).

## ->General Users (`g_user`)

### Available Scripts:

- `view_notifs`

  - Displays unread notifications from `notifications.log`.
  - Usage:
    ```bash
    ~/view_notifs
    ```

- `promote-req`

  - Request author promotion.
  - Requires limited sudo (allowed via `sudoers`).
  - Usage:
    ```bash
    sudo /scripts/promote-req
    ```

---

## ->Authors (`g_author`)

### Available Scripts:

- `manageblogs`

  - Create/edit blog entries.
  - Usage:
    ```bash
    /scripts/manageblogs -p <filename>   # Post a blog
    /scripts/manageblogs -e <filename>   # Edit a blog
    ```

- `notifyserver`

  - Run server to listen for blog post notifications.
  - Usage:
    ```bash
    nohup bash /scripts/notifyserver &
    ```

- `sendnotif`

  - Notify subscribers of a new post via Netcat.
  - Usage:
    ```bash
    echo "<username> <blogfile.txt>" | nc 127.0.0.1 3000
    ```

- `author_cleanup`

  - Remove inactive users (if implemented).
  - Usage:
    ```bash
    /scripts/author_cleanup
    ```

---

## -> Moderators (`g_mod`)

### Available Scripts:

- `blogfilter`
  - Scan author's blogs for blacklisted words.
  - Usage:
    ```bash
    /scripts/blogfilter <author_username>
    ```

---

## ->Admins (`g_admin`)

### Available Scripts:

- `initUsers.sh`

  - Load users from `users.yaml` and set up home directories.
  - Usage:
    ```bash
    sudo /scripts/initUsers.sh /scripts/users.yaml
    ```

- `admindash`

  - Admin dashboard for blogs, reports, users, etc.
  - Usage:
    ```bash
    /scripts/admindash
    ```

- `blogstats`

  - Show user frequency, year-end stats.
  - Usage:
    ```bash
    /scripts/blogstats
    ```

- `promote-respond`

  - Approve or reject author promotion requests.
  - Usage:
    ```bash
    sudo /scripts/promote-respond <username> <approve|reject>
    ```

- `grant_sudo_acces`

  - Grant group-based sudo for promote-req.
  - Usage:
    ```bash
    sudo /scripts/grant_sudo_acces
    ```

- `cronrunner`, `notifycron`

  - Setup and manage cron-based scripts.
  - Usage:
    ```bash
    /scripts/cronrunner
    /scripts/notifycron
    ```

- `setupPromotion`

  - Optional: handles YAML-based promote queue.
  - Usage:
    ```bash
    sudo /scripts/setupPromotion
    ```

---

## ->Notification System

- `notifyserver`

  - Netcat server that listens on port 3000 for post announcements.
  - Run in background:
    ```bash
    nohup bash /scripts/notifyserver &
    ```

- `notifycron`

  - Poller for users who missed netcat-based push.
  - Usage:
    ```bash
    /scripts/notifycron
    ```

- `setupNotifyView`

  - Deploy `view_notifs` to all user home directories.
  - Usage:
    ```bash
    /scripts/setupNotifyView
    ```

---

## -> Config/Data Files

| File                 | Purpose                        |
| -------------------- | ------------------------------ |
| `users.yaml`         | Base user data                 |
| `blogs.yaml`         | Blog listings                  |
| `subscriptions.yaml` | Author-to-user subscriptions   |
| `userpref.yaml`      | User preferences               |
| `requests.yaml`      | Author promotion request queue |
| `cronrunner`         | Invoked by cron                |
| `permission`         | Sets up group permissions      |

---

## -> Author Promotion Flow

1. User runs:

   ```bash
   sudo /scripts/promote-req
   ```

2. Admin runs:

   ```bash
   sudo /scripts/promote-respond <username> <approve|reject>
   ```

3. On Approval:

   - User moved to `/home/authors/<username>`
   - Added to `g_authors`
   - Directories `blogs/`, `public/`, and `blogs.yaml` are created
   - Symlink to public folder is created in every user's `all_blogs/`

---

## -> Notes

- All scripts should have appropriate `chmod +x` permissions.
- Ensure `/etc/sudoers.d/blogscripts` exists for `g_user` sudo whitelisting.
- Log files such as `/tmp/ncdebug.log` or `notifications.log` are essential for debug.

---

## -> Maintainer

- Contact your system admin for extending this setup or updating script permissions.

---

> ## How It Works – Visual Summary

> **👤 User → ✉️ Request → 👮 Admin → ✅ Approve → ✍️ Author**

### 1. User requests to become an author:

```bash
sudo /scripts/promote-req
```

- Adds username to `/scripts/requests.yaml`.

---

### 2. Admin reviews and responds:

```bash
sudo /scripts/promote-respond <username> <approve|reject>
```

- **Approve**:

  - Moves user to `/home/authors/<username>/`
  - Creates `blogs/`, `public/`, `blogs.yaml`
  - Updates group to `g_authors`
  - Adds symlink in `/home/users/*/all_blogs/<username>`

- **Reject**:

  - Simply removes entry from `requests.yaml`

---

### 3. Result:

| Role        | Directory              | Access                    | Example Tool                      |
| ----------- | ---------------------- | ------------------------- | --------------------------------- |
| `g_user`    | `/home/users/<user>`   | View + Request Promotion  | `view_notifs`                     |
| `g_authors` | `/home/authors/<user>` | Post, Notify, Edit Blogs  | `manageblogs`, `sendnotif`        |
| `g_admin`   | `/home/admins/<admin>` | Approve, Setup, Dashboard | `promote-respond`, `initUsers.sh` |

---

## -> Full Project Workflow

1. `root` runs `delta-setup` to create users, groups, and directories permission..etc.
2. Users use `promote-req` (via limited sudo) to request author rights.
3. Admins use `promote-respond` to approve/reject based on `requests.yaml`.
4. Authors use `manageblogs` to post/edit and `sendnotif` to alert subscribers.
5. Subscribers receive alerts in `notifications.log`, read using `view_notifs`.
6. Moderators run `blogfilter` to scan for issues.
7. Notification system uses `notifyserver` (Netcat) + fallback `notifycron`.
8. All users can access public blogs via `all_blogs` symlinks.

