# Chapter 3: Blog Content Management

Welcome back! In [Chapter 1: User Roles and Management](01_user_roles_and_management_.md), we learned about the different types of users on our platform (like Users and Authors). In [Chapter 2: Permissions and Access Control (ACLs)](02_permissions_and_access_control__acls__.md), we saw how the system uses permissions and ACLs to control *who* can access *what* files and directories.

Now, let's talk about the most exciting part for Authors: the **Blog Content Management** itself! This is all about how Authors write, organize, and control their actual blog posts within the system, making sure they land in the right place and are visible to the right people, according to their role and permissions.

Imagine you're an Author. You've got ideas buzzing in your head, and you want to share them! How do you get those thoughts from your computer screen onto the platform? How do you decide if a post is just a draft, ready for everyone to read, or maybe only for your special subscribers? This is exactly what Blog Content Management handles.

The core concept is quite simple:

*   Your blog posts are stored as **plain text files**.
*   Information *about* your blog posts (like title, status, categories) is stored in a special **YAML file** next to them.
*   A dedicated **script** helps you manage these files and their information.

Let's look at how an Author uses the system to create and publish a blog post. This is a primary use case this chapter will explain.

### The Author's Workspace

When a user is promoted to an `Author` role (we'll cover promotion in [Chapter 6: Author Promotion Workflow](06_author_promotion_workflow_.md)), the system creates a dedicated workspace for them under `/home/authors/`.

For an author named `ananya`, her home directory `/home/authors/ananya/` contains specific subdirectories:

*   `/home/authors/ananya/blogs/`: This is where the **original blog post text files** are stored. Think of this as your private writing desk. Only *you* (the author) should directly manage files here.
*   `/home/authors/ananya/public/`: This directory contains **links** (specifically, symbolic links) to blog files from the `blogs/` directory that are marked as "published" for everyone (`g_user`). It's like putting a copy of your finished work on a public display board.
*   `/home/authors/ananya/subscribers_only/`: This directory contains **links** to blog files that are marked as "published" only for subscribers (`g_user` who are subscribed). This is your special display board for loyal fans.
*   `/home/authors/ananya/blogs.yaml`: This crucial **YAML file** stores all the important **metadata** about your blogs. It lists each blog file, its current status (draft, published, subscriber-only, archived), categories, etc. It also lists the categories you, as an author, use.

Here's a simplified look at the directory structure for an author:

```
/home/authors/ananya/
├── blogs/                 # Original blog text files
│   ├── my-first-post.txt
│   └── travel-adventure.txt
├── public/                # Links to publicly published blogs
│   └── travel-adventure.txt -> ../blogs/travel-adventure.txt
├── subscribers_only/      # Links to subscriber-only blogs
│   └── my-first-post.txt -> ../blogs/my-first-post.txt
└── blogs.yaml             # Metadata about all blogs
```

And a peek inside the `blogs.yaml` file:

```yaml
# File: /home/authors/ananya/blogs.yaml (Simplified Example)
categories:
  1: Sports
  2: Cinema
  # ... other categories
blogs:
  - file_name: "my-first-post.txt"
    publish_status: true # 'true' means published (either public or subscriber-only)
    cat_order: [1, 6]    # Sports, Lifestyle
    is_super_blog: true  # <-- Indicates subscriber-only
  - file_name: "travel-adventure.txt"
    publish_status: true
    cat_order: [4]       # Travel
    is_super_blog: false # <-- Indicates public
  - file_name: "draft-idea.txt"
    publish_status: false # <-- Archived/Draft
    cat_order: []
    is_super_blog: false
```

The `blogs.yaml` file is like the author's personal catalog. It doesn't contain the blog content itself, but it knows everything about each blog file in the `blogs/` directory: its name, whether it's currently published, which categories it belongs to, etc.

### The `manageblogs` Script: Your Author's Tool

As an Author (`g_author`), you interact with your content primarily using the `/scripts/manageblogs` script. This script understands the directory structure and the `blogs.yaml` file. It performs actions like creating a new entry, changing a blog's status, adding/removing categories, and handling the file links.

According to the [Usage Guide for Runtime Scripts in /scripts/ReadMe.md](scripts/ReadMe.md), the `manageblogs` script is only available to users with the `g_author` role:

```markdown
| Script           | Role      | Description                             | Usage Example                                     |
| ---------------- | --------- | --------------------------------------- | ------------------------------------------------- |
| manageblogs      | Author    | Create, edit, and publish blogs         | `bash /scripts/manageblogs -super blog1`          |
```

You run it using `bash /scripts/manageblogs <option> <blogname>`. Let's look at the main options it provides:

| Option   | Action                  | Description                                                                |
| -------- | ----------------------- | -------------------------------------------------------------------------- |
| `-h`     | Help                    | Shows usage instructions.                                                  |
| `-p`     | Publish (Public)        | Publishes a blog for all `g_user` (regular users).                         |
| `-super` | Publish (Subscriber-Only) | Publishes a blog only for subscribed `g_user`. Also sends a notification.    |
| `-a`     | Archive                 | Unpublishes a blog. It's still in `blogs/` and `blogs.yaml` but not linked. |
| `-d`     | Delete                  | Completely removes the blog file and its entry from `blogs.yaml`.          |
| `-e`     | Edit Categories         | Allows changing the categories for an existing blog entry.                 |

### How to Create and Publish a Blog (Step-by-Step)

Let's walk through the process for an Author `ananya` creating a blog post called "My First Article".

1.  **Write the Content:**
    First, `ananya` needs to write the actual text for her blog post. Since the system uses simple files, she can use any text editor she likes (like `nano` or `vim`) to create the file inside her `blogs` directory.

    ```bash
    # Assuming ananya is logged in
    cd /home/authors/ananya/blogs/
    nano my-first-article.txt
    ```

    She writes her amazing content and saves the file. At this point, it's just a file in her private `blogs/` directory. It's a draft.

2.  **Use `manageblogs` to Make it Known:**
    Now, `ananya` needs to tell the system about this new blog and publish it. Let's say she wants to publish it for *everyone* (publicly). She uses the `-p` option:

    ```bash
    # Assuming ananya is logged in
    bash /scripts/manageblogs -p my-first-article.txt
    ```

    The script will then ask her to select categories from a list by entering their numbers:

    ```
    Enter categories in preferred order (like: 2 1 3):
    1. Sports
    2. Cinema
    3. Technology
    4. Travel
    5. Food
    6. Lifestyle
    7. Finance
    Enter preferred category order (space-separated numbers): 3 6
    ```

    `ananya` enters `3 6` (for Technology and Lifestyle) and presses Enter.

    The script will then output:

    ```
    Blog 'my-first-article.txt' published to public.
    ```

3.  **What Happened Under the Hood? (Publishing Publicly)**

    When `ananya` ran `bash /scripts/manageblogs -p my-first-article.txt` and selected categories, the script did several things:

    *   **Updated `blogs.yaml`:** It added or updated an entry for `my-first-article.txt` in `/home/authors/ananya/blogs.yaml`, setting `publish_status` to `true` and saving the selected category numbers (`[3, 6]`) in `cat_order`.
    *   **Created a Symlink:** It created a symbolic link (a shortcut) in the `public/` directory pointing to the original blog file in the `blogs/` directory: `/home/authors/ananya/public/my-first-article.txt` now points to `/home/authors/ananya/blogs/my-first-article.txt`.
    *   **Set ACLs:** Crucially, it used `setfacl` (referencing [Chapter 2](02_permissions_and_access_control__acls__.md)) to give the `g_user` group read permission on the *original* file in `/home/authors/ananya/blogs/`. This allows any regular user to read the file via the public symlink.

    Here's a simplified sequence of events:

    ```mermaid
    sequenceDiagram
        participant Author as ananya (g_author)
        participant ManageBlogs as /scripts/manageblogs
        participant BlogsYaml as /home/authors/ananya/blogs.yaml
        participant BlogsDir as /home/authors/ananya/blogs/
        participant PublicDir as /home/authors/ananya/public/
        participant FileSystem as File System (ACLs)

        Author->>ManageBlogs: Run `manageblogs -p my-first-article.txt`
        ManageBlogs->>Author: Ask for categories
        Author->>ManageBlogs: Provide category numbers (e.g., 3 6)
        ManageBlogs->>BlogsYaml: Update/Add entry for blog<br/>(publish_status: true, cat_order: [3, 6])
        ManageBlogs->>PublicDir: Create symlink:<br/>my-first-article.txt -> ../blogs/my-first-article.txt
        ManageBlogs->>FileSystem: Set ACL: give g_user read on /home/authors/ananya/blogs/my-first-article.txt
        ManageBlogs-->>Author: Confirm publication
    ```

    The snippet from the `manageblogs` script handling the public publishing (`publish` function) shows these steps:

    ```bash
    # From scripts/manageblogs (Simplified 'publish' function)

    function publish() {
        # ... (asks for categories and updates blogs.yaml entry with publish_status: true) ...

        # Create the link in the public directory
        ln -sf "$blogpath" "/home/authors/$author/public/$blogname" # $blogpath is the original file in blogs/

        # Give g_user read permission on the original blog file using ACLs
        setfacl -m "g:g_user:r" "$blogpath" 2>/dev/null || echo "setfacl failed"

        echo "Blog '$blogname' published to public."
    }
    ```
    This function first updates the YAML file (details omitted for brevity, but covered by `publish_common`), then creates the symbolic link in the `public/` directory pointing to the original file, and finally uses `setfacl` to grant the `g_user` group read access to that original file.

### Other Management Actions

*   **Publishing for Subscribers Only (`-super`)**:
    This works very similarly to `-p`, but instead of creating the symlink in `public/`, it creates it in `/home/authors/ananya/subscribers_only/`. It also sets the `is_super_blog` flag to `true` in `blogs.yaml`. A key difference is that it triggers a **notification** for subscribed users (we'll explore this in [Chapter 4: Subscription Mechanism](04_subscription_mechanism_.md)).

    ```bash
    # From scripts/manageblogs (Simplified 'super_publish' function)

    function super_publish() {
        # ... (asks for categories and updates blogs.yaml entry with publish_status: true, is_super_blog: true) ...

        # Create the link in the subscribers_only directory
        ln -sf "$blogpath" "/home/authors/$author/subscribers_only/$blogname"

        # Give g_user read permission (subscribers are still g_user)
        setfacl -m "g:g_user:r" "$blogpath" 2>/dev/null || echo "setfacl failed"

        echo "Blog '$blogname' published to subscribers only."

        # Send notification (handled by the Notification System)
        echo "$author $blogname" | nc 127.0.0.1 3000 # Sends message to notification server
        echo "Notification sent to subscribers"
    }
    ```

*   **Archiving a Blog (`-a`)**:
    Archiving removes the blog from public or subscriber view without deleting the content file or its `blogs.yaml` entry.

    ```bash
    # Assuming ananya wants to archive 'my-first-article.txt'
    bash /scripts/manageblogs -a my-first-article.txt
    ```

    The script removes the symlinks from `public/` and `subscribers_only/` and sets the `publish_status` to `false` in `blogs.yaml`. It also removes the specific ACL rule for `g_user` on that file.

    ```bash
    # From scripts/manageblogs (Simplified 'archive' function)

    function archive() {
        # Remove links from public and subscriber directories
        unlink "/home/authors/$author/public/$blogname" 2>/dev/null
        unlink "/home/authors/$author/subscribers_only/$blogname" 2>/dev/null

        # Remove g_user read ACL from the original file
        setfacl -x "g:g_user" "$blogpath" 2>/dev/null

        # Update blogs.yaml to mark as not published
        yq e -i "(.blogs[] | select(.file_name == \"$blogname\")).publish_status = false" "$blogs_data_file"

        echo "Blog '$blogname' archived."
    }
    ```

*   **Deleting a Blog (`-d`)**:
    Deletion permanently removes the blog file, any links, and the entry from `blogs.yaml`.

    ```bash
    # Assuming ananya wants to delete 'draft-idea.txt'
    bash /scripts/manageblogs -d draft-idea.txt
    ```

    ```bash
    # From scripts/manageblogs (Simplified 'delete_blog' function)

    function delete_blog() {
        # Remove entry from blogs.yaml
        yq e -i "del(.blogs[] | select(.file_name == \"$blogname\"))" "$blogs_data_file"

        # Remove links
        unlink "/home/authors/$author/public/$blogname" 2>/dev/null
        unlink "/home/authors/$author/subscribers_only/$blogname" 2>/dev/null

        # Remove the original blog file
        rm -f "$blogpath"

        echo "Blog '$blogname' deleted."
    }
    ```

*   **Editing Categories (`-e`)**:
    This option lets you change the category order for an existing blog entry in `blogs.yaml` without affecting its publish status or the file itself.

    ```bash
    # Assuming ananya wants to edit categories for 'travel-adventure.txt'
    bash /scripts/manageblogs -e travel-adventure.txt
    ```

    The script will again prompt for category numbers.

    ```bash
    # From scripts/manageblogs (Simplified 'edit_categories' function)

    function edit_categories() {
        # ... (prints categories and asks for new category numbers) ...

        # Update the cat_order in blogs.yaml
        yq e -i "(.blogs[] | select(.file_name == \"$blogname\")).cat_order = $cat_order_list" "$blogs_data_file"

        echo "Categories updated for '$blogname'."
    }
    ```

### Viewing Published Blogs (`listblogs` script)

While `manageblogs` is for Authors, how do Users or Authors see the published blogs? The system provides a script `/scripts/listblogs`. This script reads the `blogs.yaml` files from *all* authors, checks the `publish_status`, and displays information only for blogs marked as published.

```bash
bash /scripts/listblogs
```

Example Output (based on our simplified `ananya` example and potentially other authors):

```
***********List of Published Blogs****************
------------------------------------------
Blog File            Author          Categories
------------------------------------------
travel-adventure.txt ananya          Travel
my-first-article.txt ananya          Technology,Lifestyle
some-other-blog.txt  bala            Sports,Cinema
------------------------------------------
```

The `listblogs` script iterates through each author's directory, reads their `blogs.yaml`, and uses `yq` to extract blog details, filtering for `publish_status: true`. It then prints the blog name, author, and category names (by looking up the numbers in the author's categories list).

### In Summary

Blog Content Management is handled by organizing author content into specific directories (`blogs/`, `public/`, `subscribers_only/`) and managing metadata in a `blogs.yaml` file. The `/scripts/manageblogs` script is the primary tool for Authors to create, edit, publish, archive, and delete their blog posts, controlling their visibility and categorization. Publishing involves updating `blogs.yaml`, creating symbolic links, and setting appropriate ACLs on the original file to allow readers access, as we learned about in [Chapter 2: Permissions and Access Control (ACLs)](02_permissions_and_access_control__acls__.md). The `/scripts/listblogs` script provides a way for users to discover published content by reading this metadata.

Now that we understand how authors manage their content, how do readers get notified when a *new* blog is published, especially for subscriber-only content? That leads us to the Subscription Mechanism.

[Next Chapter: Subscription Mechanism](04_subscription_mechanism_.md)

---

<sub><sup>Generated by [AI Codebase Knowledge Builder](https://github.com/The-Pocket/Tutorial-Codebase-Knowledge).</sup></sub> <sub><sup>**References**: [[1]](https://github.com/JACKURUVI99/Delta-Blog-Setup/blob/2ca0ab6329198dc437d264c5b624e7ba1f90f76a/ReadMe.md), [[2]](https://github.com/JACKURUVI99/Delta-Blog-Setup/blob/2ca0ab6329198dc437d264c5b624e7ba1f90f76a/scripts/ReadMe.md), [[3]](https://github.com/JACKURUVI99/Delta-Blog-Setup/blob/2ca0ab6329198dc437d264c5b624e7ba1f90f76a/scripts/adminpannel), [[4]](https://github.com/JACKURUVI99/Delta-Blog-Setup/blob/2ca0ab6329198dc437d264c5b624e7ba1f90f76a/scripts/blogfilter), [[5]](https://github.com/JACKURUVI99/Delta-Blog-Setup/blob/2ca0ab6329198dc437d264c5b624e7ba1f90f76a/scripts/blogs.yaml), [[6]](https://github.com/JACKURUVI99/Delta-Blog-Setup/blob/2ca0ab6329198dc437d264c5b624e7ba1f90f76a/scripts/blogs_initial.yaml), [[7]](https://github.com/JACKURUVI99/Delta-Blog-Setup/blob/2ca0ab6329198dc437d264c5b624e7ba1f90f76a/scripts/listblogs), [[8]](https://github.com/JACKURUVI99/Delta-Blog-Setup/blob/2ca0ab6329198dc437d264c5b624e7ba1f90f76a/scripts/manageblogs)</sup></sub>