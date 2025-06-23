CREATE DATABASE IF NOT EXISTS blogdb;
USE blogdb;

-- Authors table (optional)
CREATE TABLE IF NOT EXISTS authors (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NOT NULL UNIQUE,
  full_name TEXT
);

-- Blogs table
CREATE TABLE IF NOT EXISTS blogs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  author VARCHAR(100) NOT NULL,
  categories TEXT,
  is_subscribers_only BOOLEAN DEFAULT FALSE,
  is_published BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Read-only user for security
CREATE USER IF NOT EXISTS 'readonly'@'%' IDENTIFIED BY 'readonlypassword';
GRANT SELECT ON blogdb.* TO 'readonly'@'%';
FLUSH PRIVILEGES;
